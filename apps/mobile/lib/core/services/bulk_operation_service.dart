import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/core/models/receipt.dart';
import 'package:receipt_organizer/core/models/audit_log.dart';
import 'package:receipt_organizer/core/repositories/interfaces/i_receipt_repository.dart';
import 'package:receipt_organizer/core/services/authorization_service.dart';
import 'package:receipt_organizer/core/services/undo_service.dart';
import 'package:path/path.dart' as path;

/// Progress information for bulk operations
class BulkOperationProgress {
  final int total;
  final int current;
  final String? currentItem;
  final String operation;
  final bool isComplete;
  final String? error;
  
  BulkOperationProgress({
    required this.total,
    required this.current,
    this.currentItem,
    required this.operation,
    this.isComplete = false,
    this.error,
  });
  
  double get percentage => total > 0 ? (current / total) * 100 : 0;
  
  BulkOperationProgress copyWith({
    int? total,
    int? current,
    String? currentItem,
    String? operation,
    bool? isComplete,
    String? error,
  }) {
    return BulkOperationProgress(
      total: total ?? this.total,
      current: current ?? this.current,
      currentItem: currentItem ?? this.currentItem,
      operation: operation ?? this.operation,
      isComplete: isComplete ?? this.isComplete,
      error: error ?? this.error,
    );
  }
}

/// Service for handling bulk operations on receipts
class BulkOperationService {
  final IReceiptRepository _repository;
  final AuthorizationService _authService;
  final UndoService _undoService;
  final String _userId;
  final int _batchSize;
  final String _imagePath;
  
  // Progress stream controller
  final _progressController = StreamController<BulkOperationProgress>.broadcast();
  Stream<BulkOperationProgress> get progressStream => _progressController.stream;
  
  BulkOperationService({
    required IReceiptRepository repository,
    required AuthorizationService authService,
    required UndoService undoService,
    required String userId,
    String? imagePath,
    int? batchSize,
  }) : _repository = repository,
       _authService = authService,
       _undoService = undoService,
       _userId = userId,
       _imagePath = imagePath ?? 'storage/receipts',
       _batchSize = (batchSize != null && batchSize > 0 && batchSize <= 10) 
           ? batchSize 
           : 10; // Enforce max batch size of 10
  
  /// Delete receipts with authorization checks and progress tracking
  Future<void> deleteReceipts(
    List<Receipt> receipts, {
    bool permanent = false,
    bool requireReauth = false,
  }) async {
    try {
      // Step 1: Validate authorization
      final ownedReceipts = await _authService.filterOwnedReceipts(receipts);
      
      if (ownedReceipts.isEmpty) {
        throw AuthorizationException('No authorized receipts to delete');
      }
      
      if (ownedReceipts.length != receipts.length) {
        await _repository.logAudit(
          AuditLog.create(
            userId: _userId,
            action: AuditAction.authorizationDenied,
            targetId: 'bulk_delete',
            targetType: 'receipts',
            metadata: {
              'requested': receipts.length,
              'authorized': ownedReceipts.length,
            },
          ),
        );
      }
      
      // Step 2: Check if re-authentication is required
      if (requireReauth || await _authService.requireReauthentication(ownedReceipts.length)) {
        // In a real app, this would trigger a re-auth flow
        // For now, we'll just log it
        await _repository.logAudit(
          AuditLog.create(
            userId: _userId,
            action: AuditAction.bulkDelete,
            targetId: 'reauth_required',
            targetType: 'security',
            metadata: {
              'count': ownedReceipts.length,
            },
          ),
        );
      }
      
      // Step 3: Process in batches
      final total = ownedReceipts.length;
      var processed = 0;
      
      for (var i = 0; i < ownedReceipts.length; i += _batchSize) {
        final batch = ownedReceipts.skip(i).take(_batchSize).toList();
        final batchIds = batch.map((r) => r.id).toList();
        
        // Update progress
        _progressController.add(BulkOperationProgress(
          total: total,
          current: processed,
          currentItem: batch.first.merchantName ?? batch.first.id,
          operation: permanent ? 'Permanently deleting' : 'Deleting',
        ));
        
        // Perform deletion
        if (permanent) {
          await _repository.permanentDelete(batchIds, _userId);
          await _deleteImages(batch);
        } else {
          await _repository.softDelete(batchIds, _userId);
          // Schedule permanent deletion
          await _undoService.schedulePermanentDeletion(batchIds);
        }
        
        processed += batch.length;
        
        // Small delay between batches to prevent UI freezing
        if (i + _batchSize < ownedReceipts.length) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
      
      // Log successful bulk operation
      await _repository.logAudit(
        AuditLog.bulkOperation(
          userId: _userId,
          receiptIds: ownedReceipts.map((r) => r.id).toList(),
          action: permanent ? AuditAction.permanentDelete : AuditAction.bulkDelete,
          additionalData: {
            'batch_size': _batchSize,
            'total_batches': (ownedReceipts.length / _batchSize).ceil(),
          },
        ),
      );
      
      // Final progress update
      _progressController.add(BulkOperationProgress(
        total: total,
        current: total,
        operation: 'Complete',
        isComplete: true,
      ));
      
    } catch (e) {
      // Log error
      await _repository.logAudit(
        AuditLog.create(
          userId: _userId,
          action: AuditAction.bulkDelete,
          targetId: 'bulk_operation',
          targetType: 'error',
          success: false,
          errorMessage: e.toString(),
        ),
      );
      
      // Send error in progress stream
      _progressController.add(BulkOperationProgress(
        total: receipts.length,
        current: 0,
        operation: 'Failed',
        error: e.toString(),
      ));
      
      rethrow;
    }
  }
  
  /// Calculate total storage to be freed
  Future<int> calculateStorageToBeFreed(List<Receipt> receipts) async {
    var totalBytes = 0;
    
    for (final receipt in receipts) {
      // Calculate image sizes
      if (receipt.imagePath != null) {
        final imageFile = File(path.join(_imagePath, receipt.imagePath!));
        if (await imageFile.exists()) {
          totalBytes += await imageFile.length();
        }
      }
      
      if (receipt.thumbnailPath != null) {
        final thumbFile = File(path.join(_imagePath, receipt.thumbnailPath!));
        if (await thumbFile.exists()) {
          totalBytes += await thumbFile.length();
        }
      }
      
      // Estimate database record size (roughly 1KB per receipt)
      totalBytes += 1024;
    }
    
    return totalBytes;
  }
  
  /// Restore soft-deleted receipts
  Future<void> restoreReceipts(List<String> receiptIds) async {
    try {
      // Cancel scheduled deletions
      await _undoService.cancelScheduledDeletion(receiptIds);
      
      // Note: The actual restoration is done by the UndoService
      // which calls repository.restore()
      
      // Send completion progress
      _progressController.add(BulkOperationProgress(
        total: receiptIds.length,
        current: receiptIds.length,
        operation: 'Restored',
        isComplete: true,
      ));
      
    } catch (e) {
      // Log error
      await _repository.logAudit(
        AuditLog.create(
          userId: _userId,
          action: AuditAction.restore,
          targetId: receiptIds.join(','),
          targetType: 'receipts',
          success: false,
          errorMessage: e.toString(),
        ),
      );
      
      rethrow;
    }
  }
  
  /// Delete image files associated with receipts
  Future<void> _deleteImages(List<Receipt> receipts) async {
    for (final receipt in receipts) {
      try {
        if (receipt.imagePath != null) {
          final imageFile = File(path.join(_imagePath, receipt.imagePath!));
          if (await imageFile.exists()) {
            await imageFile.delete();
          }
        }
        
        if (receipt.thumbnailPath != null) {
          final thumbFile = File(path.join(_imagePath, receipt.thumbnailPath!));
          if (await thumbFile.exists()) {
            await thumbFile.delete();
          }
        }
      } catch (e) {
        // Log but don't fail the whole operation
        await _repository.logAudit(
          AuditLog.create(
            userId: _userId,
            action: AuditAction.permanentDelete,
            targetId: receipt.id,
            targetType: 'image',
            success: false,
            errorMessage: 'Failed to delete image: $e',
          ),
        );
      }
    }
  }
  
  /// Format storage size for display
  static String formatStorageSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  /// Dispose of the service
  void dispose() {
    _progressController.close();
  }
}

/// Exception for authorization failures
class AuthorizationException implements Exception {
  final String message;
  
  AuthorizationException(this.message);
  
  @override
  String toString() => 'AuthorizationException: $message';
}

/// Provider for BulkOperationService
final bulkOperationServiceProvider = Provider.family<BulkOperationService, String>((ref, userId) {
  final repository = ref.watch(receiptRepositoryProvider);
  final authService = ref.watch(authorizationServiceProvider);
  final undoService = ref.watch(undoServiceProvider(userId));
  
  final service = BulkOperationService(
    repository: repository,
    authService: authService,
    undoService: undoService,
    userId: userId,
  );
  
  ref.onDispose(() => service.dispose());
  
  return service;
});

// These providers would need to be defined elsewhere
final receiptRepositoryProvider = Provider<IReceiptRepository>((ref) {
  throw UnimplementedError('Repository provider needs to be implemented');
});