import 'dart:async';
import 'package:receipt_organizer/domain/interfaces/i_sync_service.dart';
import 'package:receipt_organizer/core/models/result.dart';
import 'package:uuid/uuid.dart';

/// Mock implementation of ISyncService for testing.
/// 
/// Simulates synchronization operations including conflict generation,
/// progress tracking, and real-time change notifications without
/// requiring network connectivity or cloud infrastructure.
class MockSyncService implements ISyncService {
  final _uuid = const Uuid();
  final List<PendingSync> _pendingQueue = [];
  final List<SyncConflict> _conflicts = [];
  final List<SyncHistoryEntry> _history = [];
  final _progressController = StreamController<SyncProgress>.broadcast();
  final _remoteChangesController = StreamController<RemoteChange>.broadcast();
  
  SyncServiceStatus _status = SyncServiceStatus.idle;
  DateTime? _lastSuccessfulSync;
  bool _isPaused = false;
  SyncConfig _config = const SyncConfig();
  
  // Configuration for testing scenarios
  bool shouldFailNextSync = false;
  bool shouldGenerateConflicts = false;
  int conflictsToGenerate = 0;
  Duration? simulatedDelay;
  double networkFailureRate = 0.0; // 0.0 to 1.0
  
  // Statistics tracking for test assertions
  int syncAllCallCount = 0;
  int syncReceiptCallCount = 0;
  int resolveConflictCallCount = 0;
  int retryCallCount = 0;
  
  MockSyncService({
    this.simulatedDelay,
    this.networkFailureRate = 0.0,
  });
  
  @override
  Future<Result<SyncStatus>> syncAll() async {
    syncAllCallCount++;
    await _simulateDelay();
    
    if (_isPaused) {
      return const Result.failure(
        AppError.sync(
          message: 'Sync is paused',
          code: 'SYNC_PAUSED',
        ),
      );
    }
    
    _status = SyncServiceStatus.syncing;
    final syncStarted = DateTime.now();
    
    // Simulate network failure
    if (shouldFailNextSync || _shouldSimulateNetworkFailure()) {
      shouldFailNextSync = false;
      _status = SyncServiceStatus.error;
      
      // Add failed items to pending queue
      _addFailedItemsToPending();
      
      return Result.failure(
        AppError.network(
          message: 'Network error during sync',
          code: 'NETWORK_ERROR',
        ),
      );
    }
    
    // Emit progress updates
    await _emitProgressUpdates();
    
    // Generate conflicts if configured
    final conflicts = <SyncConflict>[];
    if (shouldGenerateConflicts) {
      conflicts.addAll(_generateConflicts());
      _conflicts.addAll(conflicts);
      shouldGenerateConflicts = false;
    }
    
    // Simulate sync operations
    final itemsUploaded = 5 + DateTime.now().second % 10;
    final itemsDownloaded = 3 + DateTime.now().second % 7;
    final itemsFailed = _pendingQueue.length > 3 ? 2 : 0;
    
    // Clear some pending items (simulating successful sync)
    if (_pendingQueue.isNotEmpty) {
      final toRemove = _pendingQueue.length > 5 ? 5 : _pendingQueue.length;
      _pendingQueue.removeRange(0, toRemove);
    }
    
    final syncCompleted = DateTime.now();
    _lastSuccessfulSync = syncCompleted;
    _status = SyncServiceStatus.idle;
    
    // Add to history
    _addHistoryEntry(
      operation: SyncOperation.update,
      itemId: 'batch-${_uuid.v4()}',
      itemType: 'batch',
      successful: true,
    );
    
    // Emit remote changes
    _simulateRemoteChanges(itemsDownloaded);
    
    return Result.success(
      SyncStatus(
        itemsUploaded: itemsUploaded,
        itemsDownloaded: itemsDownloaded,
        itemsFailed: itemsFailed,
        conflicts: conflicts,
        syncStarted: syncStarted,
        syncCompleted: syncCompleted,
        syncDuration: syncCompleted.difference(syncStarted),
        isFullSync: true,
      ),
    );
  }
  
  @override
  Future<Result<void>> syncReceipt(String receiptId, {bool force = false}) async {
    syncReceiptCallCount++;
    await _simulateDelay();
    
    if (_isPaused) {
      return const Result.failure(
        AppError.sync(
          message: 'Sync is paused',
          code: 'SYNC_PAUSED',
        ),
      );
    }
    
    if (shouldFailNextSync || _shouldSimulateNetworkFailure()) {
      shouldFailNextSync = false;
      
      // Add to pending queue
      _pendingQueue.add(
        PendingSync(
          itemId: receiptId,
          itemType: 'receipt',
          operation: SyncOperation.update,
          createdAt: DateTime.now(),
        ),
      );
      
      return const Result.failure(
        AppError.network(
          message: 'Failed to sync receipt',
          code: 'SYNC_FAILED',
        ),
      );
    }
    
    // Check for conflicts (unless forced)
    if (!force && shouldGenerateConflicts) {
      final conflict = SyncConflict(
        conflictId: _uuid.v4(),
        itemId: receiptId,
        itemType: 'receipt',
        localData: {'version': 1, 'modified': DateTime.now().toIso8601String()},
        remoteData: {'version': 2, 'modified': DateTime.now().add(const Duration(minutes: -5)).toIso8601String()},
        localModified: DateTime.now(),
        remoteModified: DateTime.now().add(const Duration(minutes: -5)),
        description: 'Receipt modified both locally and remotely',
      );
      
      _conflicts.add(conflict);
      
      return Result.failure(
        AppError.sync(
          message: 'Conflict detected',
          code: 'CONFLICT',
          conflictIds: [conflict.conflictId],
        ),
      );
    }
    
    // Simulate successful sync
    _addHistoryEntry(
      operation: SyncOperation.update,
      itemId: receiptId,
      itemType: 'receipt',
      successful: true,
    );
    
    // Emit remote change notification
    _remoteChangesController.add(
      RemoteChange(
        itemId: receiptId,
        itemType: 'receipt',
        changeType: ChangeType.updated,
        timestamp: DateTime.now(),
        userId: 'mock-user',
      ),
    );
    
    return const Result.success(null);
  }
  
  @override
  Stream<SyncProgress> watchSyncProgress() {
    return _progressController.stream;
  }
  
  @override
  Future<Result<void>> resolveConflict(ConflictResolution resolution) async {
    resolveConflictCallCount++;
    await _simulateDelay();
    
    final conflict = _conflicts.firstWhere(
      (c) => c.conflictId == resolution.conflictId,
      orElse: () => throw StateError('Conflict not found'),
    );
    
    // Remove conflict from list
    _conflicts.removeWhere((c) => c.conflictId == resolution.conflictId);
    
    // Add to history
    _addHistoryEntry(
      operation: SyncOperation.update,
      itemId: conflict.itemId,
      itemType: conflict.itemType,
      successful: true,
      metadata: {
        'resolution': resolution.strategy.toString(),
        'conflictId': resolution.conflictId,
      },
    );
    
    return const Result.success(null);
  }
  
  @override
  Future<Result<List<PendingSync>>> getPendingSync() async {
    await _simulateDelay();
    return Result.success(List.from(_pendingQueue));
  }
  
  @override
  Future<Result<int>> retryFailedSync({int maxRetries = 3}) async {
    retryCallCount++;
    await _simulateDelay();
    
    if (_pendingQueue.isEmpty) {
      return const Result.success(0);
    }
    
    int successCount = 0;
    final toRetry = List.from(_pendingQueue);
    
    for (final item in toRetry) {
      if (item.retryCount >= maxRetries) {
        continue;
      }
      
      // Simulate retry with 70% success rate
      if (DateTime.now().millisecondsSinceEpoch % 10 > 3) {
        _pendingQueue.remove(item);
        successCount++;
        
        _addHistoryEntry(
          operation: item.operation,
          itemId: item.itemId,
          itemType: item.itemType,
          successful: true,
          metadata: {'retry': true, 'retryCount': item.retryCount + 1},
        );
      } else {
        // Update retry count
        final index = _pendingQueue.indexOf(item);
        if (index >= 0) {
          _pendingQueue[index] = PendingSync(
            itemId: item.itemId,
            itemType: item.itemType,
            operation: item.operation,
            createdAt: item.createdAt,
            retryCount: item.retryCount + 1,
            lastError: 'Retry failed',
          );
        }
      }
      
      await _simulateDelay();
    }
    
    return Result.success(successCount);
  }
  
  @override
  Stream<RemoteChange> subscribeToRemoteChanges() {
    // Simulate periodic remote changes
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_remoteChangesController.isClosed && !_isPaused) {
        _remoteChangesController.add(
          RemoteChange(
            itemId: _uuid.v4(),
            itemType: 'receipt',
            changeType: ChangeType.values[DateTime.now().second % 3],
            timestamp: DateTime.now(),
            userId: 'remote-user',
          ),
        );
      }
    });
    
    return _remoteChangesController.stream;
  }
  
  @override
  Future<Result<void>> pauseSync() async {
    await _simulateDelay();
    _isPaused = true;
    _status = SyncServiceStatus.paused;
    return const Result.success(null);
  }
  
  @override
  Future<Result<void>> resumeSync() async {
    await _simulateDelay();
    _isPaused = false;
    _status = SyncServiceStatus.idle;
    
    // Trigger sync if there are pending items
    if (_pendingQueue.isNotEmpty) {
      Timer(const Duration(seconds: 1), () => syncAll());
    }
    
    return const Result.success(null);
  }
  
  @override
  Future<Result<SyncState>> getSyncState() async {
    await _simulateDelay();
    
    return Result.success(
      SyncState(
        status: _status,
        lastSuccessfulSync: _lastSuccessfulSync,
        pendingChanges: _pendingQueue.length,
        failedItems: _pendingQueue.where((p) => p.retryCount > 0).length,
        isConnected: !_isPaused && networkFailureRate < 1.0,
        currentOperation: _status == SyncServiceStatus.syncing ? 'Syncing...' : null,
      ),
    );
  }
  
  @override
  Future<Result<void>> configureSyncSettings(SyncConfig config) async {
    await _simulateDelay();
    _config = config;
    return const Result.success(null);
  }
  
  @override
  Future<Result<void>> resetSyncState() async {
    await _simulateDelay();
    
    _pendingQueue.clear();
    _conflicts.clear();
    _history.clear();
    _lastSuccessfulSync = null;
    _status = SyncServiceStatus.idle;
    
    return const Result.success(null);
  }
  
  @override
  Future<Result<List<SyncHistoryEntry>>> getSyncHistory({int limit = 100}) async {
    await _simulateDelay();
    
    final history = _history.reversed.take(limit).toList();
    return Result.success(history);
  }
  
  // Helper methods for testing
  
  /// Clear all data (useful for test setup/teardown)
  void clear() {
    _pendingQueue.clear();
    _conflicts.clear();
    _history.clear();
    _lastSuccessfulSync = null;
    _status = SyncServiceStatus.idle;
    _isPaused = false;
    syncAllCallCount = 0;
    syncReceiptCallCount = 0;
    resolveConflictCallCount = 0;
    retryCallCount = 0;
  }
  
  /// Get current conflicts (for test assertions)
  List<SyncConflict> getConflicts() => List.from(_conflicts);
  
  /// Get pending queue (for test assertions)
  List<PendingSync> getPendingQueue() => List.from(_pendingQueue);
  
  /// Inject pending items (for test setup)
  void injectPendingItems(List<PendingSync> items) {
    _pendingQueue.addAll(items);
  }
  
  /// Inject conflicts (for test setup)
  void injectConflicts(List<SyncConflict> conflicts) {
    _conflicts.addAll(conflicts);
  }
  
  /// Get statistics (for test assertions)
  Map<String, dynamic> getStats() {
    return {
      'syncAllCount': syncAllCallCount,
      'syncReceiptCount': syncReceiptCallCount,
      'resolveConflictCount': resolveConflictCallCount,
      'retryCount': retryCallCount,
      'pendingCount': _pendingQueue.length,
      'conflictCount': _conflicts.length,
      'historyCount': _history.length,
      'isPaused': _isPaused,
      'status': _status.toString(),
    };
  }
  
  // Private helper methods
  
  Future<void> _simulateDelay() async {
    if (simulatedDelay != null) {
      await Future.delayed(simulatedDelay!);
    }
  }
  
  bool _shouldSimulateNetworkFailure() {
    if (networkFailureRate <= 0) return false;
    if (networkFailureRate >= 1) return true;
    return DateTime.now().millisecondsSinceEpoch % 100 < (networkFailureRate * 100);
  }
  
  Future<void> _emitProgressUpdates() async {
    const totalItems = 20;
    for (int i = 0; i <= totalItems; i++) {
      if (_progressController.isClosed) break;
      
      _progressController.add(
        SyncProgress(
          percentage: (i / totalItems) * 100,
          operation: i < 10 ? 'Uploading changes...' : 'Downloading updates...',
          itemsProcessed: i,
          totalItems: totalItems,
          timestamp: DateTime.now(),
        ),
      );
      
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }
  
  List<SyncConflict> _generateConflicts() {
    final conflicts = <SyncConflict>[];
    final count = conflictsToGenerate > 0 ? conflictsToGenerate : 2;
    
    for (int i = 0; i < count; i++) {
      conflicts.add(
        SyncConflict(
          conflictId: _uuid.v4(),
          itemId: 'receipt-${_uuid.v4()}',
          itemType: 'receipt',
          localData: {
            'version': 1,
            'merchantName': 'Local Store $i',
            'amount': 10.00 + i,
          },
          remoteData: {
            'version': 2,
            'merchantName': 'Remote Store $i',
            'amount': 15.00 + i,
          },
          localModified: DateTime.now(),
          remoteModified: DateTime.now().add(const Duration(minutes: -10)),
          description: 'Concurrent modification detected',
        ),
      );
    }
    
    conflictsToGenerate = 0;
    return conflicts;
  }
  
  void _addFailedItemsToPending() {
    for (int i = 0; i < 3; i++) {
      _pendingQueue.add(
        PendingSync(
          itemId: 'failed-${_uuid.v4()}',
          itemType: 'receipt',
          operation: SyncOperation.values[i % 3],
          createdAt: DateTime.now(),
          lastError: 'Network timeout',
        ),
      );
    }
  }
  
  void _simulateRemoteChanges(int count) {
    for (int i = 0; i < count; i++) {
      if (!_remoteChangesController.isClosed) {
        _remoteChangesController.add(
          RemoteChange(
            itemId: 'remote-${_uuid.v4()}',
            itemType: 'receipt',
            changeType: ChangeType.values[i % 3],
            timestamp: DateTime.now(),
            userId: 'remote-user',
          ),
        );
      }
    }
  }
  
  void _addHistoryEntry({
    required SyncOperation operation,
    required String itemId,
    required String itemType,
    required bool successful,
    Map<String, dynamic>? metadata,
  }) {
    _history.add(
      SyncHistoryEntry(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        operation: operation,
        itemId: itemId,
        itemType: itemType,
        successful: successful,
        error: successful ? null : 'Simulated error',
        metadata: metadata,
      ),
    );
  }
  
  /// Dispose resources
  void dispose() {
    _progressController.close();
    _remoteChangesController.close();
  }
}