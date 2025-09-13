import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/services/interfaces/i_sync_service.dart';
import '../../core/models/receipt.dart';
import '../../core/exceptions/service_exception.dart';

/// Production implementation of sync service using Supabase
class SupabaseSyncService implements ISyncService {
  final SupabaseClient _client;
  final StreamController<SyncStatus> _statusController = StreamController<SyncStatus>.broadcast();
  
  static const String _receiptsTable = 'receipts';
  static const String _syncMetaTable = 'sync_metadata';
  
  SyncStatus _currentStatus = SyncStatus.idle;
  DateTime? _lastSyncTime;
  String? _deviceId;
  
  SupabaseSyncService(this._client) {
    _initializeDeviceId();
    _setupRealtimeSync();
  }
  
  @override
  Future<bool> get isAvailable async {
    try {
      // Check if user is authenticated and network is available
      final user = _client.auth.currentUser;
      if (user == null) return false;
      
      // Ping Supabase to check connectivity
      await _client.from(_syncMetaTable).select('id').limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<bool> get hasPendingChanges async {
    try {
      final result = await _client
          .from(_receiptsTable)
          .select('id')
          .eq('sync_status', 'pending')
          .eq('user_id', _client.auth.currentUser!.id)
          .limit(1);
      
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<DateTime?> get lastSyncTime async {
    if (_lastSyncTime != null) return _lastSyncTime;
    
    try {
      final result = await _client
          .from(_syncMetaTable)
          .select('last_sync')
          .eq('user_id', _client.auth.currentUser!.id)
          .eq('device_id', _deviceId ?? '')
          .single();
      
      if (result['last_sync'] != null) {
        _lastSyncTime = DateTime.parse(result['last_sync']);
      }
      return _lastSyncTime;
    } catch (e) {
      return null;
    }
  }
  
  @override
  Stream<SyncStatus> get syncStatusStream => _statusController.stream;
  
  @override
  Future<void> syncReceipt(Receipt receipt) async {
    _updateStatus(SyncStatus.syncing);
    
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw ServiceException('User not authenticated');
      }
      
      final data = _receiptToSupabase(receipt, userId);
      
      await _client.from(_receiptsTable).upsert(
        data,
        onConflict: 'local_id',
      );
      
      await _updateSyncMetadata();
      _updateStatus(SyncStatus.idle);
      
    } catch (e) {
      _updateStatus(SyncStatus.error);
      throw ServiceException('Failed to sync receipt: $e');
    }
  }
  
  @override
  Future<void> syncReceipts(List<Receipt> receipts) async {
    _updateStatus(SyncStatus.syncing);
    
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw ServiceException('User not authenticated');
      }
      
      // Batch sync in chunks of 100
      const batchSize = 100;
      for (var i = 0; i < receipts.length; i += batchSize) {
        final batch = receipts.skip(i).take(batchSize).toList();
        final data = batch.map((r) => _receiptToSupabase(r, userId)).toList();
        
        await _client.from(_receiptsTable).upsert(
          data,
          onConflict: 'local_id',
        );
      }
      
      await _updateSyncMetadata();
      _updateStatus(SyncStatus.idle);
      
    } catch (e) {
      _updateStatus(SyncStatus.error);
      throw ServiceException('Failed to sync receipts: $e');
    }
  }
  
  @override
  Future<List<Receipt>> pullChanges({DateTime? since}) async {
    _updateStatus(SyncStatus.syncing);
    
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw ServiceException('User not authenticated');
      }
      
      var query = _client
          .from(_receiptsTable)
          .select()
          .eq('user_id', userId)
          .isFilter('deleted_at', null);  // Use isFilter for null checks
      
      if (since != null) {
        query = query.gte('updated_at', since.toIso8601String());
      }
      
      final result = await query.order('updated_at', ascending: false);
      
      final receipts = (result as List)
          .map((data) => _receiptFromSupabase(data))
          .toList();
      
      await _updateSyncMetadata();
      _updateStatus(SyncStatus.idle);
      
      return receipts;
      
    } catch (e) {
      _updateStatus(SyncStatus.error);
      throw ServiceException('Failed to pull changes: $e');
    }
  }
  
  @override
  Future<void> pushChanges() async {
    _updateStatus(SyncStatus.syncing);
    
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw ServiceException('User not authenticated');
      }
      
      // Get pending local changes
      final pendingReceipts = await _client
          .from(_receiptsTable)
          .select()
          .eq('user_id', userId)
          .eq('sync_status', 'pending');
      
      if (pendingReceipts.isEmpty) {
        _updateStatus(SyncStatus.idle);
        return;
      }
      
      // Update sync status - using inFilter for multiple IDs
      final ids = (pendingReceipts as List).map((r) => r['id']).toList();
      await _client
          .from(_receiptsTable)
          .update({'sync_status': 'synced', 'updated_at': DateTime.now().toIso8601String()})
          .inFilter('id', ids);
      
      await _updateSyncMetadata();
      _updateStatus(SyncStatus.idle);
      
    } catch (e) {
      _updateStatus(SyncStatus.error);
      throw ServiceException('Failed to push changes: $e');
    }
  }
  
  @override
  Future<SyncResult> performSync() async {
    _updateStatus(SyncStatus.syncing);
    
    try {
      final lastSync = await lastSyncTime;
      
      // Pull remote changes
      final pulledReceipts = await pullChanges(since: lastSync);
      
      // Push local changes
      await pushChanges();
      
      final result = SyncResult(
        itemsPushed: 0, // TODO: Track actual count
        itemsPulled: pulledReceipts.length,
        conflictsResolved: 0,
        errors: [],
        timestamp: DateTime.now(),
      );
      
      _updateStatus(SyncStatus.idle);
      return result;
      
    } catch (e) {
      _updateStatus(SyncStatus.error);
      return SyncResult(
        itemsPushed: 0,
        itemsPulled: 0,
        conflictsResolved: 0,
        errors: [e.toString()],
        timestamp: DateTime.now(),
      );
    }
  }
  
  @override
  Future<Receipt> resolveConflict(Receipt local, Receipt remote) async {
    // Conflict resolution strategy: Last Write Wins with field-level merging
    final localTime = local.updatedAt ?? DateTime.now();
    final remoteTime = remote.updatedAt ?? DateTime.now();
    
    if (localTime.isAfter(remoteTime)) {
      return local;
    } else if (remoteTime.isAfter(localTime)) {
      return remote;
    } else {
      // Same timestamp - merge fields with higher confidence
      return _mergeReceipts(local, remote);
    }
  }
  
  @override
  Future<void> cancelSync() async {
    _updateStatus(SyncStatus.idle);
  }
  
  @override
  Future<void> clearSyncMetadata() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;
      
      await _client
          .from(_syncMetaTable)
          .delete()
          .eq('user_id', userId)
          .eq('device_id', _deviceId ?? '');
      
      _lastSyncTime = null;
    } catch (e) {
      // Ignore errors
    }
  }
  
  // Private helper methods
  
  void _initializeDeviceId() {
    // Generate unique device ID
    _deviceId = 'flutter_${DateTime.now().millisecondsSinceEpoch}';
  }
  
  void _setupRealtimeSync() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    
    // Subscribe to realtime changes for user's receipts
    _client
        .channel('receipts')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: _receiptsTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            // Handle realtime updates
            _updateStatus(SyncStatus.syncing);
            // Process changes...
            _updateStatus(SyncStatus.idle);
          },
        )
        .subscribe();
  }
  
  Map<String, dynamic> _receiptToSupabase(Receipt receipt, String userId) {
    return {
      'user_id': userId,
      'local_id': receipt.id,
      'merchant_name': receipt.merchantName,
      'date': receipt.date?.toIso8601String(),
      'total_amount': receipt.totalAmount,
      'tax_amount': receipt.taxAmount,
      'image_url': receipt.imagePath,
      'ocr_confidence': receipt.ocrResults?.overallConfidence,
      'sync_status': 'synced',
      'device_id': _deviceId,
      'created_at': receipt.createdAt.toIso8601String(),
      'updated_at': receipt.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
  
  Receipt _receiptFromSupabase(Map<String, dynamic> data) {
    return Receipt(
      id: data['local_id'] ?? data['id'],
      merchantName: data['merchant_name'],
      date: data['date'] != null ? DateTime.parse(data['date']) : null,
      totalAmount: data['total_amount']?.toDouble(),
      taxAmount: data['tax_amount']?.toDouble(),
      imagePath: data['image_url'],
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at']) : null,
    );
  }
  
  Receipt _mergeReceipts(Receipt local, Receipt remote) {
    // Merge based on field confidence
    return Receipt(
      id: local.id,
      merchantName: _selectBestValue(
        local.merchantName,
        remote.merchantName,
        local.ocrResults?.merchantName?.confidence,
        remote.ocrResults?.merchantName?.confidence,
      ),
      date: _selectBestValue(
        local.date,
        remote.date,
        local.ocrResults?.date?.confidence,
        remote.ocrResults?.date?.confidence,
      ),
      totalAmount: _selectBestValue(
        local.totalAmount,
        remote.totalAmount,
        local.ocrResults?.totalAmount?.confidence,
        remote.ocrResults?.totalAmount?.confidence,
      ),
      taxAmount: _selectBestValue(
        local.taxAmount,
        remote.taxAmount,
        local.ocrResults?.taxAmount?.confidence,
        remote.ocrResults?.taxAmount?.confidence,
      ),
      imagePath: local.imagePath ?? remote.imagePath,
      createdAt: local.createdAt,
      updatedAt: DateTime.now(),
      ocrResults: local.ocrResults ?? remote.ocrResults,
    );
  }
  
  T _selectBestValue<T>(T? localValue, T? remoteValue, double? localConf, double? remoteConf) {
    if (localValue == null) return remoteValue as T;
    if (remoteValue == null) return localValue;
    
    final localConfidence = localConf ?? 0.0;
    final remoteConfidence = remoteConf ?? 0.0;
    
    return localConfidence >= remoteConfidence ? localValue : remoteValue;
  }
  
  Future<void> _updateSyncMetadata() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;
      
      _lastSyncTime = DateTime.now();
      
      await _client.from(_syncMetaTable).upsert({
        'user_id': userId,
        'device_id': _deviceId,
        'last_sync': _lastSyncTime!.toIso8601String(),
        'sync_version': 1,
      }, onConflict: 'user_id,device_id');
      
    } catch (e) {
      // Log error but don't fail sync
      print('Failed to update sync metadata: $e');
    }
  }
  
  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }
  
  void dispose() {
    _statusController.close();
  }
}