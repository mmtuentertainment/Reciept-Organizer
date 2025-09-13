import '../../../core/models/receipt.dart';

/// Interface for synchronization service
/// 
/// This interface defines the contract for syncing data between
/// local storage and cloud storage (Supabase, Firebase, etc.)
abstract class ISyncService {
  /// Check if sync is currently available
  Future<bool> get isAvailable;
  
  /// Check if there are pending changes to sync
  Future<bool> get hasPendingChanges;
  
  /// Get the last sync timestamp
  Future<DateTime?> get lastSyncTime;
  
  /// Sync a single receipt to cloud
  Future<void> syncReceipt(Receipt receipt);
  
  /// Sync multiple receipts to cloud
  Future<void> syncReceipts(List<Receipt> receipts);
  
  /// Pull changes from cloud
  Future<List<Receipt>> pullChanges({DateTime? since});
  
  /// Push local changes to cloud
  Future<void> pushChanges();
  
  /// Perform full two-way sync
  Future<SyncResult> performSync();
  
  /// Handle sync conflicts
  Future<Receipt> resolveConflict(Receipt local, Receipt remote);
  
  /// Get sync status stream for UI updates
  Stream<SyncStatus> get syncStatusStream;
  
  /// Cancel ongoing sync operation
  Future<void> cancelSync();
  
  /// Clear sync metadata (for testing)
  Future<void> clearSyncMetadata();
}

/// Result of a sync operation
class SyncResult {
  final int itemsPushed;
  final int itemsPulled;
  final int conflictsResolved;
  final List<String> errors;
  final DateTime timestamp;
  
  SyncResult({
    required this.itemsPushed,
    required this.itemsPulled,
    required this.conflictsResolved,
    required this.errors,
    required this.timestamp,
  });
  
  bool get hasErrors => errors.isNotEmpty;
  bool get isSuccess => errors.isEmpty;
}

/// Current sync status
enum SyncStatus {
  idle,
  syncing,
  error,
  offline,
  unauthorized,
}

/// Sync conflict resolution strategy
enum ConflictResolution {
  keepLocal,
  keepRemote,
  merge,
  manual,
}