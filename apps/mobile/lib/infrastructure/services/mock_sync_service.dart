import 'dart:async';
import '../../domain/services/interfaces/i_sync_service.dart';
import '../../core/models/receipt.dart';

/// Mock implementation of sync service for testing
class MockSyncService implements ISyncService {
  final List<Receipt> _localReceipts = [];
  final List<Receipt> _remoteReceipts = [];
  final StreamController<SyncStatus> _statusController = StreamController<SyncStatus>.broadcast();
  
  DateTime? _lastSync;
  SyncStatus _currentStatus = SyncStatus.idle;
  
  @override
  Future<bool> get isAvailable async => true;
  
  @override
  Future<bool> get hasPendingChanges async => _localReceipts.isNotEmpty;
  
  @override
  Future<DateTime?> get lastSyncTime async => _lastSync;
  
  @override
  Stream<SyncStatus> get syncStatusStream => _statusController.stream;
  
  @override
  Future<void> syncReceipt(Receipt receipt) async {
    _updateStatus(SyncStatus.syncing);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    _localReceipts.add(receipt);
    _remoteReceipts.add(receipt);
    _lastSync = DateTime.now();
    
    _updateStatus(SyncStatus.idle);
  }
  
  @override
  Future<void> syncReceipts(List<Receipt> receipts) async {
    _updateStatus(SyncStatus.syncing);
    
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 50 * receipts.length));
    
    _localReceipts.addAll(receipts);
    _remoteReceipts.addAll(receipts);
    _lastSync = DateTime.now();
    
    _updateStatus(SyncStatus.idle);
  }
  
  @override
  Future<List<Receipt>> pullChanges({DateTime? since}) async {
    _updateStatus(SyncStatus.syncing);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));
    
    final changes = since != null
        ? _remoteReceipts.where((r) => r.updatedAt != null && r.updatedAt!.isAfter(since)).toList()
        : _remoteReceipts;
    
    _lastSync = DateTime.now();
    _updateStatus(SyncStatus.idle);
    
    return changes;
  }
  
  @override
  Future<void> pushChanges() async {
    _updateStatus(SyncStatus.syncing);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    _remoteReceipts.addAll(_localReceipts);
    _localReceipts.clear();
    _lastSync = DateTime.now();
    
    _updateStatus(SyncStatus.idle);
  }
  
  @override
  Future<SyncResult> performSync() async {
    _updateStatus(SyncStatus.syncing);
    
    // Simulate full sync
    await Future.delayed(const Duration(milliseconds: 500));
    
    final result = SyncResult(
      itemsPushed: _localReceipts.length,
      itemsPulled: _remoteReceipts.length,
      conflictsResolved: 0,
      errors: [],
      timestamp: DateTime.now(),
    );
    
    _localReceipts.clear();
    _lastSync = DateTime.now();
    
    _updateStatus(SyncStatus.idle);
    
    return result;
  }
  
  @override
  Future<Receipt> resolveConflict(Receipt local, Receipt remote) async {
    // Simple strategy: keep the most recently updated
    final localTime = local.updatedAt ?? DateTime.now();
    final remoteTime = remote.updatedAt ?? DateTime.now();
    return localTime.isAfter(remoteTime) ? local : remote;
  }
  
  @override
  Future<void> cancelSync() async {
    _updateStatus(SyncStatus.idle);
  }
  
  @override
  Future<void> clearSyncMetadata() async {
    _localReceipts.clear();
    _remoteReceipts.clear();
    _lastSync = null;
    _updateStatus(SyncStatus.idle);
  }
  
  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }
  
  // Test helpers
  void addRemoteReceipt(Receipt receipt) {
    _remoteReceipts.add(receipt);
  }
  
  List<Receipt> get remoteReceipts => List.unmodifiable(_remoteReceipts);
  List<Receipt> get localReceipts => List.unmodifiable(_localReceipts);
}