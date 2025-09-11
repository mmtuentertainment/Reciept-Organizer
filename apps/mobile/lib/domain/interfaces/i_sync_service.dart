import 'package:receipt_organizer/core/models/result.dart';

/// Service interface for data synchronization between local and cloud storage.
/// 
/// This interface manages bi-directional sync, conflict resolution, and real-time updates
/// for hybrid cloud architecture. Supports offline-first with eventual consistency.
abstract class ISyncService {
  /// Synchronize all local data with the cloud.
  /// 
  /// Performs a full synchronization:
  /// - Uploads local changes to the cloud
  /// - Downloads remote changes to local storage
  /// - Identifies and reports conflicts
  /// 
  /// Returns a Result containing the sync status with details about:
  /// - Number of items uploaded
  /// - Number of items downloaded
  /// - Any conflicts that need resolution
  /// 
  /// Example:
  /// ```dart
  /// final result = await syncService.syncAll();
  /// result.onSuccess((status) => print('Synced: ${status.itemsSynced} items'))
  ///       .onFailure((error) => print('Sync failed: ${error.message}'));
  /// ```
  Future<Result<SyncStatus>> syncAll();
  
  /// Synchronize a specific receipt.
  /// 
  /// [receiptId] The ID of the receipt to sync.
  /// [force] If true, overwrite any conflicts with local version.
  /// 
  /// Returns a Result indicating success or describing the failure.
  /// Useful for immediate sync after important changes.
  Future<Result<void>> syncReceipt(String receiptId, {bool force = false});
  
  /// Watch synchronization progress in real-time.
  /// 
  /// Returns a stream that emits progress updates during sync operations.
  /// Useful for showing progress bars or status indicators.
  /// 
  /// The stream emits:
  /// - Progress percentage (0-100)
  /// - Current operation description
  /// - Items processed and total
  Stream<SyncProgress> watchSyncProgress();
  
  /// Resolve a synchronization conflict.
  /// 
  /// [resolution] The conflict resolution strategy to apply.
  /// 
  /// Returns a Result indicating whether the resolution was successful.
  /// The resolution can choose local version, remote version, or merge.
  Future<Result<void>> resolveConflict(ConflictResolution resolution);
  
  /// Get list of pending items waiting to be synced.
  /// 
  /// Returns a Result containing pending sync items including:
  /// - Local changes not yet uploaded
  /// - Failed sync attempts waiting for retry
  /// - Items in conflict state
  Future<Result<List<PendingSync>>> getPendingSync();
  
  /// Retry failed synchronization attempts.
  /// 
  /// [maxRetries] Maximum number of retry attempts (default: 3).
  /// 
  /// Returns a Result containing the number of successfully retried items.
  /// Uses exponential backoff between retries.
  Future<Result<int>> retryFailedSync({int maxRetries = 3});
  
  /// Subscribe to real-time remote changes.
  /// 
  /// Returns a stream that emits whenever remote data changes.
  /// This enables real-time collaboration features.
  /// 
  /// The stream emits change events including:
  /// - Type of change (create, update, delete)
  /// - Affected item IDs
  /// - Change timestamp
  Stream<RemoteChange> subscribeToRemoteChanges();
  
  /// Pause synchronization.
  /// 
  /// Temporarily stops all sync operations.
  /// Useful for bandwidth management or user preference.
  /// Local changes continue to be tracked for later sync.
  Future<Result<void>> pauseSync();
  
  /// Resume synchronization.
  /// 
  /// Resumes sync operations after pause.
  /// Automatically processes any queued changes.
  Future<Result<void>> resumeSync();
  
  /// Get current synchronization state.
  /// 
  /// Returns a Result containing the current sync state including:
  /// - Whether sync is active, paused, or failed
  /// - Last successful sync timestamp
  /// - Number of pending changes
  Future<Result<SyncState>> getSyncState();
  
  /// Configure synchronization settings.
  /// 
  /// [config] The sync configuration to apply.
  /// 
  /// Allows customization of:
  /// - Sync frequency
  /// - Conflict resolution strategy
  /// - Bandwidth limits
  /// - Sync filters
  Future<Result<void>> configureSyncSettings(SyncConfig config);
  
  /// Clear all sync metadata and reset sync state.
  /// 
  /// WARNING: This will require a full re-sync on next operation.
  /// Use only for troubleshooting sync issues.
  Future<Result<void>> resetSyncState();
  
  /// Get sync history/audit log.
  /// 
  /// [limit] Maximum number of history entries to return.
  /// 
  /// Returns recent sync operations for debugging and auditing.
  Future<Result<List<SyncHistoryEntry>>> getSyncHistory({int limit = 100});
}

/// Current synchronization status after a sync operation
class SyncStatus {
  final int itemsUploaded;
  final int itemsDownloaded;
  final int itemsFailed;
  final List<SyncConflict> conflicts;
  final DateTime syncStarted;
  final DateTime syncCompleted;
  final Duration syncDuration;
  final bool isFullSync;
  
  const SyncStatus({
    required this.itemsUploaded,
    required this.itemsDownloaded,
    required this.itemsFailed,
    required this.conflicts,
    required this.syncStarted,
    required this.syncCompleted,
    required this.syncDuration,
    required this.isFullSync,
  });
  
  int get totalItemsSynced => itemsUploaded + itemsDownloaded;
  bool get hasConflicts => conflicts.isNotEmpty;
  bool get hasFailures => itemsFailed > 0;
  bool get isSuccessful => !hasFailures && !hasConflicts;
}

/// Real-time sync progress information
class SyncProgress {
  final double percentage; // 0-100
  final String operation; // Current operation description
  final int itemsProcessed;
  final int totalItems;
  final String? currentItemId;
  final DateTime timestamp;
  
  const SyncProgress({
    required this.percentage,
    required this.operation,
    required this.itemsProcessed,
    required this.totalItems,
    this.currentItemId,
    required this.timestamp,
  });
  
  bool get isComplete => percentage >= 100.0;
}

/// Conflict resolution strategy
class ConflictResolution {
  final String conflictId;
  final ResolutionStrategy strategy;
  final Map<String, dynamic>? mergedData; // For custom merge strategy
  
  const ConflictResolution({
    required this.conflictId,
    required this.strategy,
    this.mergedData,
  });
}

/// Available resolution strategies
enum ResolutionStrategy {
  useLocal,    // Keep local version
  useRemote,   // Use remote version
  merge,       // Custom merge (requires mergedData)
  skip,        // Skip this item for now
}

/// Item waiting to be synchronized
class PendingSync {
  final String itemId;
  final String itemType; // 'receipt', 'image', etc.
  final SyncOperation operation;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;
  final Map<String, dynamic>? metadata;
  
  const PendingSync({
    required this.itemId,
    required this.itemType,
    required this.operation,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
    this.metadata,
  });
}

/// Type of sync operation
enum SyncOperation {
  create,
  update,
  delete,
}

/// Remote change notification
class RemoteChange {
  final String itemId;
  final String itemType;
  final ChangeType changeType;
  final DateTime timestamp;
  final String? userId; // Who made the change
  final Map<String, dynamic>? changeData;
  
  const RemoteChange({
    required this.itemId,
    required this.itemType,
    required this.changeType,
    required this.timestamp,
    this.userId,
    this.changeData,
  });
}

/// Type of remote change
enum ChangeType {
  created,
  updated,
  deleted,
}

/// Synchronization conflict
class SyncConflict {
  final String conflictId;
  final String itemId;
  final String itemType;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;
  final DateTime localModified;
  final DateTime remoteModified;
  final String? description;
  
  const SyncConflict({
    required this.conflictId,
    required this.itemId,
    required this.itemType,
    required this.localData,
    required this.remoteData,
    required this.localModified,
    required this.remoteModified,
    this.description,
  });
}

/// Current state of the sync service
class SyncState {
  final SyncServiceStatus status;
  final DateTime? lastSuccessfulSync;
  final int pendingChanges;
  final int failedItems;
  final bool isConnected;
  final String? currentOperation;
  
  const SyncState({
    required this.status,
    this.lastSuccessfulSync,
    required this.pendingChanges,
    required this.failedItems,
    required this.isConnected,
    this.currentOperation,
  });
  
  bool get needsSync => pendingChanges > 0 || failedItems > 0;
}

/// Sync service status
enum SyncServiceStatus {
  idle,
  syncing,
  paused,
  error,
  offline,
}

/// Sync configuration
class SyncConfig {
  final Duration syncInterval;
  final ResolutionStrategy defaultConflictStrategy;
  final int maxRetries;
  final int bandwidthLimitKbps;
  final bool syncOnCellular;
  final bool autoSync;
  final List<String>? includedTypes; // Types to sync
  final List<String>? excludedTypes; // Types to exclude
  
  const SyncConfig({
    this.syncInterval = const Duration(minutes: 5),
    this.defaultConflictStrategy = ResolutionStrategy.useRemote,
    this.maxRetries = 3,
    this.bandwidthLimitKbps = 0, // 0 = unlimited
    this.syncOnCellular = true,
    this.autoSync = true,
    this.includedTypes,
    this.excludedTypes,
  });
}

/// Sync history entry for audit trail
class SyncHistoryEntry {
  final String id;
  final DateTime timestamp;
  final SyncOperation operation;
  final String itemId;
  final String itemType;
  final bool successful;
  final String? error;
  final Map<String, dynamic>? metadata;
  
  const SyncHistoryEntry({
    required this.id,
    required this.timestamp,
    required this.operation,
    required this.itemId,
    required this.itemType,
    required this.successful,
    this.error,
    this.metadata,
  });
}