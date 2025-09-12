import 'dart:io';
import 'package:workmanager/workmanager.dart';
import 'request_queue_service.dart';
import 'network_connectivity_service.dart';

/// Background sync service for processing queue
/// 
/// EXPERIMENT: Phase 4 - Minimal background processing
/// Uses WorkManager for Android and iOS background execution
class BackgroundSyncService {
  static final BackgroundSyncService _instance = BackgroundSyncService._internal();
  factory BackgroundSyncService() => _instance;
  BackgroundSyncService._internal();
  
  // Task identifiers
  static const String _syncTaskName = 'receipt_queue_sync';
  static const String _syncTaskTag = 'queue_sync';
  
  // Configuration
  static const Duration _syncInterval = Duration(minutes: 15);
  static const Duration _initialDelay = Duration(minutes: 5);
  
  /// Initialize background sync
  /// This should be called from main() before runApp()
  static Future<void> initialize() async {
    await Workmanager().initialize(
      _callbackDispatcher,
      isInDebugMode: false, // Set to true for testing
    );
  }
  
  /// Register periodic sync task
  Future<void> registerPeriodicSync() async {
    try {
      // Cancel any existing tasks
      await cancelSync();
      
      if (Platform.isAndroid) {
        // Android: Use periodic task with constraints
        await Workmanager().registerPeriodicTask(
          _syncTaskName,
          _syncTaskName,
          frequency: _syncInterval,
          initialDelay: _initialDelay,
          constraints: Constraints(
            networkType: NetworkType.connected,
            requiresBatteryNotLow: false, // Allow on low battery
            requiresCharging: false,
            requiresDeviceIdle: false,
            requiresStorageNotLow: false,
          ),
          existingWorkPolicy: ExistingWorkPolicy.replace,
          backoffPolicy: BackoffPolicy.exponential,
          backoffPolicyDelay: const Duration(seconds: 30),
          tag: _syncTaskTag,
        );
        
        print('BackgroundSyncService: Registered periodic sync for Android');
      } else if (Platform.isIOS) {
        // iOS: Register background task
        // Note: iOS requires Info.plist configuration
        await Workmanager().registerPeriodicTask(
          _syncTaskName,
          _syncTaskName,
          frequency: _syncInterval,
          initialDelay: _initialDelay,
          constraints: Constraints(
            networkType: NetworkType.connected,
          ),
          existingWorkPolicy: ExistingWorkPolicy.replace,
          tag: _syncTaskTag,
        );
        
        print('BackgroundSyncService: Registered periodic sync for iOS');
      }
    } catch (e) {
      print('BackgroundSyncService: Failed to register sync: $e');
    }
  }
  
  /// Register one-time sync task
  /// Useful for immediate retry after queue operation
  Future<void> registerOneTimeSync({
    Duration delay = const Duration(minutes: 1),
  }) async {
    try {
      await Workmanager().registerOneOffTask(
        '${_syncTaskName}_oneoff_${DateTime.now().millisecondsSinceEpoch}',
        _syncTaskName,
        initialDelay: delay,
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        existingWorkPolicy: ExistingWorkPolicy.append,
        tag: _syncTaskTag,
      );
      
      print('BackgroundSyncService: Registered one-time sync');
    } catch (e) {
      print('BackgroundSyncService: Failed to register one-time sync: $e');
    }
  }
  
  /// Cancel all sync tasks
  Future<void> cancelSync() async {
    try {
      await Workmanager().cancelByTag(_syncTaskTag);
      print('BackgroundSyncService: Cancelled all sync tasks');
    } catch (e) {
      print('BackgroundSyncService: Failed to cancel sync: $e');
    }
  }
  
  /// Check if background sync is available
  /// Some devices may restrict background execution
  bool isBackgroundSyncAvailable() {
    // Basic check - can be enhanced with device-specific logic
    return Platform.isAndroid || Platform.isIOS;
  }
  
  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    return {
      'available': isBackgroundSyncAvailable(),
      'platform': Platform.operatingSystem,
      'syncInterval': _syncInterval.inMinutes,
      'taskName': _syncTaskName,
    };
  }
}

/// Top-level callback for WorkManager
/// This MUST be a top-level function or static method
@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('BackgroundSyncService: Executing task: $task');
    
    try {
      // Initialize services in background isolate
      final queueService = RequestQueueService();
      final connectivity = NetworkConnectivityService();
      
      // Check connectivity
      final canSync = await connectivity.forceCheck();
      if (!canSync) {
        print('BackgroundSyncService: No connectivity, skipping sync');
        return Future.value(true); // Return true to indicate task completed
      }
      
      // Process queue
      print('BackgroundSyncService: Processing queue in background');
      await queueService.processQueue();
      
      // Get statistics for logging
      final stats = await queueService.getStatistics();
      print('BackgroundSyncService: Queue stats: $stats');
      
      return Future.value(true);
    } catch (e) {
      print('BackgroundSyncService: Error during background sync: $e');
      // Return false to indicate failure - WorkManager will retry
      return Future.value(false);
    }
  });
}