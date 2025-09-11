import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/core/repositories/interfaces/i_receipt_repository.dart';
import 'package:receipt_organizer/core/models/audit_log.dart';

/// Service for managing undo operations and scheduled permanent deletions
class UndoService {
  final IReceiptRepository _repository;
  final String _userId;
  final Map<String, Timer> _scheduledDeletions = {};
  final Duration _defaultUndoWindow;
  
  UndoService({
    required IReceiptRepository repository,
    required String userId,
    Duration? undoWindow,
  }) : _repository = repository,
       _userId = userId,
       _defaultUndoWindow = undoWindow ?? const Duration(days: 7);
  
  /// Schedule permanent deletion after undo window expires
  Future<void> schedulePermanentDeletion(
    List<String> receiptIds, {
    Duration? customWindow,
  }) async {
    final window = customWindow ?? _defaultUndoWindow;
    
    // Cancel any existing timers for these IDs
    for (final id in receiptIds) {
      _scheduledDeletions[id]?.cancel();
    }
    
    // Schedule new deletion
    final timer = Timer(window, () async {
      try {
        await _repository.permanentDelete(receiptIds, _userId);
        
        // Log the permanent deletion
        await _repository.logAudit(
          AuditLog.bulkOperation(
            userId: _userId,
            receiptIds: receiptIds,
            action: AuditAction.permanentDelete,
            additionalData: {
              'scheduled': true,
              'window_duration': window.inDays,
            },
          ),
        );
        
        // Remove from scheduled map
        for (final id in receiptIds) {
          _scheduledDeletions.remove(id);
        }
      } catch (e) {
        // Log error but don't throw - this runs in a timer
        await _repository.logAudit(
          AuditLog.create(
            userId: _userId,
            action: AuditAction.permanentDelete,
            targetId: receiptIds.join(','),
            targetType: 'receipts_bulk',
            success: false,
            errorMessage: e.toString(),
          ),
        );
      }
    });
    
    // Store timer references
    for (final id in receiptIds) {
      _scheduledDeletions[id] = timer;
    }
  }
  
  /// Cancel scheduled deletion and restore receipts
  Future<void> cancelScheduledDeletion(List<String> receiptIds) async {
    // Cancel timers
    for (final id in receiptIds) {
      _scheduledDeletions[id]?.cancel();
      _scheduledDeletions.remove(id);
    }
    
    // Restore the receipts
    await _repository.restore(receiptIds, _userId);
    
    // Log the restoration
    await _repository.logAudit(
      AuditLog.bulkOperation(
        userId: _userId,
        receiptIds: receiptIds,
        action: AuditAction.restore,
        additionalData: {
          'reason': 'user_undo',
        },
      ),
    );
  }
  
  /// Check if a receipt has a scheduled deletion
  bool isScheduledForDeletion(String receiptId) {
    return _scheduledDeletions.containsKey(receiptId);
  }
  
  /// Get remaining time before permanent deletion
  Duration? getRemainingTime(String receiptId) {
    final timer = _scheduledDeletions[receiptId];
    if (timer == null || !timer.isActive) return null;
    
    // Note: Timer doesn't expose remaining time directly
    // This would need additional tracking in production
    return _defaultUndoWindow;
  }
  
  /// Clean up expired soft deletes (to be called periodically)
  Future<void> cleanupExpiredDeletes() async {
    try {
      // Get receipts that have been soft deleted for longer than the window
      final expiredReceipts = await _repository.getExpiredSoftDeletes(
        _defaultUndoWindow.inDays,
      );
      
      if (expiredReceipts.isNotEmpty) {
        final ids = expiredReceipts.map((r) => r.id).toList();
        
        // Permanently delete them
        await _repository.permanentDelete(ids, 'system');
        
        // Log the cleanup
        await _repository.logAudit(
          AuditLog.bulkOperation(
            userId: 'system',
            receiptIds: ids,
            action: AuditAction.permanentDelete,
            additionalData: {
              'reason': 'expired_cleanup',
              'days_old': _defaultUndoWindow.inDays,
            },
          ),
        );
      }
    } catch (e) {
      // Log error
      await _repository.logAudit(
        AuditLog.create(
          userId: 'system',
          action: AuditAction.permanentDelete,
          targetId: 'cleanup_task',
          targetType: 'system',
          success: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }
  
  /// Dispose of the service and cancel all timers
  void dispose() {
    for (final timer in _scheduledDeletions.values) {
      timer.cancel();
    }
    _scheduledDeletions.clear();
  }
}

/// Provider for UndoService
final undoServiceProvider = Provider.family<UndoService, String>((ref, userId) {
  final repository = ref.watch(receiptRepositoryProvider);
  
  // Get undo window from settings if available
  final undoWindow = ref.watch(settingsProvider.select((s) => s.undoWindow));
  
  final service = UndoService(
    repository: repository,
    userId: userId,
    undoWindow: undoWindow,
  );
  
  // Dispose when provider is disposed
  ref.onDispose(() => service.dispose());
  
  return service;
});

// These providers would need to be defined elsewhere
final receiptRepositoryProvider = Provider<IReceiptRepository>((ref) {
  throw UnimplementedError('Repository provider needs to be implemented');
});

final settingsProvider = Provider<Settings>((ref) {
  throw UnimplementedError('Settings provider needs to be implemented');
});

class Settings {
  final Duration? undoWindow;
  
  Settings({this.undoWindow});
}