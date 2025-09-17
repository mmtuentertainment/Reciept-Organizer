import 'dart:typed_data';

import '../../core/repositories/interfaces/i_receipt_repository.dart';
import '../../data/models/receipt.dart';
import '../../data/repositories/receipt_repository.dart';
import '../../core/services/network_connectivity_service.dart';
import '../services/receipt_api_service.dart';
import '../../core/models/receipt.dart' as core_models;

/// Hybrid receipt repository that uses API when online and local storage offline
///
/// This repository provides seamless offline/online functionality by:
/// 1. Using the API as the primary data source when online
/// 2. Falling back to local SQLite storage when offline
/// 3. Queuing changes for sync when connectivity is restored
/// 4. Maintaining a local cache for fast access and offline support
class HybridReceiptRepository implements IReceiptRepository {
  final ReceiptRepository _localRepository;
  final ReceiptApiService _apiService;
  final NetworkConnectivityService _connectivity;

  // Track pending changes for sync
  final Set<String> _pendingCreates = {};
  final Set<String> _pendingUpdates = {};
  final Set<String> _pendingDeletes = {};

  HybridReceiptRepository({
    ReceiptRepository? localRepository,
    ReceiptApiService? apiService,
    NetworkConnectivityService? connectivity,
  })  : _localRepository = localRepository ?? ReceiptRepository(),
        _apiService = apiService ?? ReceiptApiService(),
        _connectivity = connectivity ?? NetworkConnectivityService() {
    // Listen for connectivity changes to trigger sync
    _connectivity.connectivityStream.listen((isConnected) {
      if (isConnected) {
        _syncPendingChanges();
      }
    });
  }

  @override
  Future<List<Receipt>> getAllReceipts() async {
    // Always return from local cache for speed
    // Background sync will update the cache
    return _localRepository.getAllReceipts();
  }

  @override
  Future<Receipt?> getReceiptById(String id) async {
    // Try local first for speed
    final localReceipt = await _localRepository.getReceiptById(id);

    // If online and not found locally, try API
    if (localReceipt == null && _connectivity.canMakeApiCall()) {
      try {
        final apiReceipt = await _apiService.getReceipt(id);
        if (apiReceipt != null) {
          // Convert from API model to local model
          final receipt = _convertFromApiModel(apiReceipt);
          // Cache locally
          await _localRepository.createReceipt(receipt);
          return receipt;
        }
      } catch (e) {
        // Fall through to return null
      }
    }

    return localReceipt;
  }

  @override
  Future<List<Receipt>> getReceiptsByBatchId(String batchId) async {
    return _localRepository.getReceiptsByBatchId(batchId);
  }

  @override
  Future<List<Receipt>> getReceiptsByDateRange(DateTime start, DateTime end) async {
    return _localRepository.getReceiptsByDateRange(start, end);
  }

  @override
  Future<Receipt> createReceipt(Receipt receipt) async {
    // Save locally first
    final savedReceipt = await _localRepository.createReceipt(receipt);

    // If online, upload to API
    if (_connectivity.canMakeApiCall()) {
      try {
        final jobId = await _uploadReceiptToApi(savedReceipt);
        // Update receipt with job ID
        final updatedReceipt = savedReceipt.copyWith(
          metadata: {
            ...?savedReceipt.metadata,
            'apiJobId': jobId,
          },
        );
        await _localRepository.updateReceipt(updatedReceipt);
        return updatedReceipt;
      } catch (e) {
        // Mark for later sync
        _pendingCreates.add(savedReceipt.id);
      }
    } else {
      // Mark for later sync
      _pendingCreates.add(savedReceipt.id);
    }

    return savedReceipt;
  }

  @override
  Future<void> updateReceipt(Receipt receipt) async {
    // Update locally first
    await _localRepository.updateReceipt(receipt);

    // Mark for sync if online operations needed
    if (!_connectivity.canMakeApiCall()) {
      _pendingUpdates.add(receipt.id);
    } else {
      try {
        // TODO: Implement API update when endpoint is available
        // For now, just track that it needs syncing
        _pendingUpdates.add(receipt.id);
      } catch (e) {
        _pendingUpdates.add(receipt.id);
      }
    }
  }

  @override
  Future<void> deleteReceipt(String id) async {
    // Delete locally
    await _localRepository.deleteReceipt(id);

    // Track for API sync
    _pendingDeletes.add(id);
    _pendingCreates.remove(id); // Remove from creates if it was pending
    _pendingUpdates.remove(id); // Remove from updates if it was pending

    if (_connectivity.canMakeApiCall()) {
      try {
        // TODO: Implement API delete when endpoint is available
      } catch (e) {
        // Already tracked in _pendingDeletes
      }
    }
  }

  @override
  Future<void> deleteReceipts(List<String> ids) async {
    for (final id in ids) {
      await deleteReceipt(id);
    }
  }

  @override
  Future<int> getReceiptCount() async {
    return _localRepository.getReceiptCount();
  }

  @override
  Future<List<Receipt>> getReceiptsPaginated(int offset, int limit) async {
    return _localRepository.getReceiptsPaginated(offset, limit);
  }

  /// Upload receipt to API
  Future<String> _uploadReceiptToApi(Receipt receipt) async {
    // Check if we have image data
    if (receipt.imageUri == null) {
      throw Exception('Cannot upload receipt without image');
    }

    // Determine if it's a URL or local file
    String? imageUrl;
    Uint8List? imageData;

    if (receipt.imageUri!.startsWith('http')) {
      imageUrl = receipt.imageUri;
    } else {
      // TODO: Load image from local file system
      // For now, we'll skip local files
      throw Exception('Local file upload not yet implemented');
    }

    // Create metadata from receipt fields
    final metadata = {
      'merchantName': receipt.merchantName,
      'receiptDate': receipt.receiptDate?.toIso8601String(),
      'totalAmount': receipt.totalAmount,
      'taxAmount': receipt.taxAmount,
      'notes': receipt.notes,
      'batchId': receipt.batchId,
      ...?receipt.metadata,
    };

    // Upload to API
    return await _apiService.createReceiptJob(
      imageUrl: imageUrl,
      imageData: imageData,
      metadata: metadata,
    );
  }

  /// Sync pending changes with API
  Future<void> _syncPendingChanges() async {
    // Sync creates
    for (final id in _pendingCreates.toList()) {
      try {
        final receipt = await _localRepository.getReceiptById(id);
        if (receipt != null) {
          await _uploadReceiptToApi(receipt);
          _pendingCreates.remove(id);
        }
      } catch (e) {
        // Keep in pending for next sync
      }
    }

    // TODO: Sync updates when API supports it
    // TODO: Sync deletes when API supports it
  }

  /// Convert API receipt model to local model
  Receipt _convertFromApiModel(core_models.Receipt apiReceipt) {
    // TODO: Implement proper conversion when API model is complete
    // For now, return a basic receipt
    return Receipt(
      id: apiReceipt.id,
      imageUri: '', // Empty string instead of null since it's required
      capturedAt: DateTime.now(),
      status: ReceiptStatus.pending,
      lastModified: DateTime.now(),
    );
  }

  /// Force sync all pending changes
  Future<void> forceSyncNow() async {
    if (_connectivity.canMakeApiCall()) {
      await _syncPendingChanges();
    }
  }

  /// Get count of pending changes
  int get pendingChangesCount {
    return _pendingCreates.length + _pendingUpdates.length + _pendingDeletes.length;
  }
}