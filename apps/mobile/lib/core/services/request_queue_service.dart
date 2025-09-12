import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../models/queue_entry.dart';
import 'queue_database_service.dart';
import 'network_connectivity_service.dart';

/// Service for queuing and retrying failed API requests
/// 
/// EXPERIMENT: Phase 3 - Request queue with retry logic
/// Provides automatic retry with exponential backoff
class RequestQueueService {
  static final RequestQueueService _instance = RequestQueueService._internal();
  factory RequestQueueService() => _instance;
  RequestQueueService._internal();
  
  final _database = QueueDatabaseService();
  final _connectivity = NetworkConnectivityService();
  final _uuid = const Uuid();
  
  // Processing state
  bool _isProcessing = false;
  Timer? _processTimer;
  StreamSubscription? _connectivitySubscription;
  
  // Configuration
  static const int maxQueueSize = 100;
  static const int defaultMaxRetries = 3;
  static const Duration processInterval = Duration(seconds: 30);
  static const Duration baseRetryDelay = Duration(seconds: 2);
  
  /// Initialize the queue service
  Future<void> initialize() async {
    // Clean up old completed entries
    await _database.deleteOldCompleted();
    
    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.connectivityStream.listen((isConnected) {
      if (isConnected) {
        // Process queue when connectivity restored
        processQueue();
      }
    });
    
    // Start periodic processing
    _startPeriodicProcessing();
    
    // Process any pending entries
    if (_connectivity.canMakeApiCall()) {
      processQueue();
    }
  }
  
  /// Dispose resources
  void dispose() {
    _processTimer?.cancel();
    _connectivitySubscription?.cancel();
  }
  
  /// Queue a request for later processing
  Future<String> queueRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? body,
    String? feature,
    int maxRetries = defaultMaxRetries,
  }) async {
    // Check queue size limit
    final currentSize = await _database.getQueueSize();
    if (currentSize >= maxQueueSize) {
      throw Exception('Queue is full. Maximum size: $maxQueueSize');
    }
    
    final entry = QueueEntry(
      id: _uuid.v4(),
      endpoint: endpoint,
      method: method,
      headers: headers ?? {},
      body: body,
      createdAt: DateTime.now(),
      retryCount: 0,
      maxRetries: maxRetries,
      status: QueueEntryStatus.pending,
      feature: feature,
    );
    
    await _database.insert(entry);
    
    // Try to process immediately if online
    if (_connectivity.canMakeApiCall()) {
      processQueue();
    }
    
    return entry.id;
  }
  
  /// Process all pending entries in the queue
  Future<void> processQueue() async {
    if (_isProcessing) return; // Prevent concurrent processing
    
    if (!_connectivity.canMakeApiCall()) {
      print('RequestQueueService: Cannot process queue - offline');
      return;
    }
    
    _isProcessing = true;
    
    try {
      final pendingEntries = await _database.getPendingEntries();
      
      if (pendingEntries.isEmpty) {
        print('RequestQueueService: No pending entries to process');
        return;
      }
      
      print('RequestQueueService: Processing ${pendingEntries.length} entries');
      
      for (final entry in pendingEntries) {
        // Check if we should retry based on backoff
        if (!_shouldRetryNow(entry)) {
          continue;
        }
        
        await _processEntry(entry);
        
        // Small delay between requests to avoid overwhelming the server
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Check connectivity between requests
        if (!_connectivity.canMakeApiCall()) {
          print('RequestQueueService: Lost connectivity, stopping queue processing');
          break;
        }
      }
    } finally {
      _isProcessing = false;
    }
  }
  
  /// Process a single queue entry
  Future<void> _processEntry(QueueEntry entry) async {
    print('RequestQueueService: Processing entry ${entry.id} (${entry.feature})');
    
    // Update status to processing
    final processingEntry = entry.copyWith(
      status: QueueEntryStatus.processing,
      lastAttemptAt: DateTime.now(),
    );
    await _database.update(processingEntry);
    
    try {
      // Make the HTTP request
      final response = await _makeHttpRequest(entry);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success - mark as completed
        print('RequestQueueService: Entry ${entry.id} completed successfully');
        final completedEntry = processingEntry.copyWith(
          status: QueueEntryStatus.completed,
        );
        await _database.update(completedEntry);
        
        // Delete completed entry after success
        await _database.delete(entry.id);
      } else if (response.statusCode >= 500 || response.statusCode == 429) {
        // Server error or rate limit - retry later
        await _handleRetry(processingEntry, 'Server error: ${response.statusCode}');
      } else {
        // Client error (4xx except 429) - don't retry
        print('RequestQueueService: Entry ${entry.id} failed with client error: ${response.statusCode}');
        final failedEntry = processingEntry.copyWith(
          status: QueueEntryStatus.failed,
          errorMessage: 'Client error: ${response.statusCode}',
        );
        await _database.update(failedEntry);
      }
    } catch (e) {
      // Network or other error - retry
      await _handleRetry(processingEntry, e.toString());
    }
  }
  
  /// Make the actual HTTP request
  Future<http.Response> _makeHttpRequest(QueueEntry entry) async {
    final uri = Uri.parse(entry.endpoint);
    final headers = entry.headers.map((k, v) => MapEntry(k, v.toString()));
    
    switch (entry.method.toUpperCase()) {
      case 'GET':
        return await http.get(uri, headers: headers)
            .timeout(const Duration(seconds: 30));
      
      case 'POST':
        return await http.post(
          uri,
          headers: headers,
          body: entry.body != null ? json.encode(entry.body) : null,
        ).timeout(const Duration(seconds: 30));
      
      case 'PUT':
        return await http.put(
          uri,
          headers: headers,
          body: entry.body != null ? json.encode(entry.body) : null,
        ).timeout(const Duration(seconds: 30));
      
      case 'DELETE':
        return await http.delete(uri, headers: headers)
            .timeout(const Duration(seconds: 30));
      
      default:
        throw Exception('Unsupported HTTP method: ${entry.method}');
    }
  }
  
  /// Handle retry logic for failed requests
  Future<void> _handleRetry(QueueEntry entry, String error) async {
    final newRetryCount = entry.retryCount + 1;
    
    if (newRetryCount >= entry.maxRetries) {
      // Max retries reached - mark as failed
      print('RequestQueueService: Entry ${entry.id} failed after ${entry.maxRetries} retries');
      final failedEntry = entry.copyWith(
        status: QueueEntryStatus.failed,
        retryCount: newRetryCount,
        errorMessage: error,
      );
      await _database.update(failedEntry);
    } else {
      // Schedule retry
      print('RequestQueueService: Entry ${entry.id} will retry (${newRetryCount}/${entry.maxRetries})');
      final retryEntry = entry.copyWith(
        status: QueueEntryStatus.pending,
        retryCount: newRetryCount,
        errorMessage: error,
      );
      await _database.update(retryEntry);
    }
  }
  
  /// Check if we should retry now based on exponential backoff
  bool _shouldRetryNow(QueueEntry entry) {
    if (entry.lastAttemptAt == null) return true;
    
    // Calculate backoff delay: 2^retryCount * baseDelay
    final backoffMultiplier = pow(2, entry.retryCount);
    final backoffDelay = baseRetryDelay * backoffMultiplier;
    
    final nextRetryTime = entry.lastAttemptAt!.add(backoffDelay);
    return DateTime.now().isAfter(nextRetryTime);
  }
  
  /// Start periodic queue processing
  void _startPeriodicProcessing() {
    _processTimer?.cancel();
    _processTimer = Timer.periodic(processInterval, (_) {
      if (_connectivity.canMakeApiCall()) {
        processQueue();
      }
    });
  }
  
  /// Get queue statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final pendingCount = await _database.getQueueSize();
    final allEntries = await _database.getPendingEntries();
    
    return {
      'pendingCount': pendingCount,
      'isProcessing': _isProcessing,
      'oldestEntry': allEntries.isNotEmpty 
        ? allEntries.first.createdAt.toIso8601String()
        : null,
    };
  }
  
  /// Clear the queue (for testing/debugging)
  Future<void> clearQueue() async {
    await _database.clearAll();
  }
}