import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:receipt_organizer/core/services/supabase_service.dart';
import 'package:receipt_organizer/core/models/receipt.dart';
import 'package:flutter/foundation.dart';

/// Provider for managing real-time synchronization of receipts
class RealtimeSyncNotifier extends StateNotifier<RealtimeSyncState> {
  final SupabaseService _supabaseService;
  RealtimeChannel? _channel;
  
  RealtimeSyncNotifier(this._supabaseService) : super(const RealtimeSyncState());
  
  /// Initialize real-time sync
  Future<void> initialize() async {
    if (!_supabaseService.isAuthenticated) {
      state = state.copyWith(
        isConnected: false,
        lastError: 'User not authenticated',
      );
      return;
    }
    
    try {
      // Subscribe to receipt changes
      _channel = _supabaseService.subscribeToReceipts(
        onInsert: _handleInsert,
        onUpdate: _handleUpdate,
        onDelete: _handleDelete,
      );
      
      state = state.copyWith(
        isConnected: true,
        lastSyncTime: DateTime.now(),
        lastError: null,
      );
      
      debugPrint('✅ Real-time sync initialized');
    } catch (e) {
      state = state.copyWith(
        isConnected: false,
        lastError: e.toString(),
      );
      debugPrint('❌ Failed to initialize real-time sync: $e');
    }
  }
  
  /// Handle new receipt insertion
  void _handleInsert(PostgresChangePayload payload) {
    debugPrint('📥 New receipt received: ${payload.newRecord}');
    
    state = state.copyWith(
      lastSyncTime: DateTime.now(),
      pendingChanges: state.pendingChanges + 1,
    );
    
    // Notify listeners about the new receipt
    _notifyReceiptInserted(payload.newRecord);
  }
  
  /// Handle receipt update
  void _handleUpdate(PostgresChangePayload payload) {
    debugPrint('📝 Receipt updated: ${payload.newRecord}');
    
    state = state.copyWith(
      lastSyncTime: DateTime.now(),
      pendingChanges: state.pendingChanges + 1,
    );
    
    // Notify listeners about the updated receipt
    _notifyReceiptUpdated(payload.newRecord);
  }
  
  /// Handle receipt deletion
  void _handleDelete(PostgresChangePayload payload) {
    debugPrint('🗑️ Receipt deleted: ${payload.oldRecord}');
    
    state = state.copyWith(
      lastSyncTime: DateTime.now(),
      pendingChanges: state.pendingChanges + 1,
    );
    
    // Notify listeners about the deleted receipt
    _notifyReceiptDeleted(payload.oldRecord);
  }
  
  /// Notify about inserted receipt
  void _notifyReceiptInserted(Map<String, dynamic> record) {
    // This would typically trigger a refresh of the receipts list
    // or add the new receipt to the local cache
    state = state.copyWith(
      lastInsertedId: record['id']?.toString(),
      pendingChanges: state.pendingChanges - 1,
    );
  }
  
  /// Notify about updated receipt
  void _notifyReceiptUpdated(Map<String, dynamic> record) {
    // This would typically update the receipt in the local cache
    state = state.copyWith(
      lastUpdatedId: record['id']?.toString(),
      pendingChanges: state.pendingChanges - 1,
    );
  }
  
  /// Notify about deleted receipt
  void _notifyReceiptDeleted(Map<String, dynamic> record) {
    // This would typically remove the receipt from the local cache
    state = state.copyWith(
      lastDeletedId: record['id']?.toString(),
      pendingChanges: state.pendingChanges - 1,
    );
  }
  
  /// Disconnect from real-time sync
  Future<void> disconnect() async {
    if (_channel != null) {
      await _supabaseService.unsubscribe(_channel!);
      _channel = null;
    }
    
    state = state.copyWith(
      isConnected: false,
      lastError: null,
    );
    
    debugPrint('🔌 Real-time sync disconnected');
  }
  
  /// Force sync all receipts from cloud
  Future<void> forceSyncFromCloud() async {
    try {
      state = state.copyWith(isSyncing: true);
      
      final receipts = await _supabaseService.getReceipts();
      
      // Process receipts and update local database
      debugPrint('📥 Synced ${receipts.length} receipts from cloud');
      
      state = state.copyWith(
        isSyncing: false,
        lastSyncTime: DateTime.now(),
        totalSyncedReceipts: receipts.length,
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        lastError: e.toString(),
      );
      debugPrint('❌ Failed to sync from cloud: $e');
    }
  }
  
  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

/// State for real-time sync
@immutable
class RealtimeSyncState {
  final bool isConnected;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final String? lastError;
  final int pendingChanges;
  final int totalSyncedReceipts;
  final String? lastInsertedId;
  final String? lastUpdatedId;
  final String? lastDeletedId;
  
  const RealtimeSyncState({
    this.isConnected = false,
    this.isSyncing = false,
    this.lastSyncTime,
    this.lastError,
    this.pendingChanges = 0,
    this.totalSyncedReceipts = 0,
    this.lastInsertedId,
    this.lastUpdatedId,
    this.lastDeletedId,
  });
  
  RealtimeSyncState copyWith({
    bool? isConnected,
    bool? isSyncing,
    DateTime? lastSyncTime,
    String? lastError,
    int? pendingChanges,
    int? totalSyncedReceipts,
    String? lastInsertedId,
    String? lastUpdatedId,
    String? lastDeletedId,
  }) {
    return RealtimeSyncState(
      isConnected: isConnected ?? this.isConnected,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastError: lastError ?? this.lastError,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      totalSyncedReceipts: totalSyncedReceipts ?? this.totalSyncedReceipts,
      lastInsertedId: lastInsertedId ?? this.lastInsertedId,
      lastUpdatedId: lastUpdatedId ?? this.lastUpdatedId,
      lastDeletedId: lastDeletedId ?? this.lastDeletedId,
    );
  }
}

/// Provider for Supabase service
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});

/// Provider for real-time sync
final realtimeSyncProvider = StateNotifierProvider<RealtimeSyncNotifier, RealtimeSyncState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return RealtimeSyncNotifier(supabaseService);
});

/// Provider to auto-initialize real-time sync
final realtimeSyncInitializerProvider = FutureProvider<void>((ref) async {
  final syncNotifier = ref.read(realtimeSyncProvider.notifier);
  await syncNotifier.initialize();
});