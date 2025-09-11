import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/core/models/receipt.dart';
import 'package:receipt_organizer/core/models/audit_log.dart';
import 'package:receipt_organizer/core/repositories/interfaces/i_receipt_repository.dart';

/// User roles for RBAC
enum UserRole {
  user,
  admin,
  viewer,
}

/// User model for authorization
class User {
  final String id;
  final String email;
  final UserRole role;
  final bool isActive;
  
  const User({
    required this.id,
    required this.email,
    required this.role,
    this.isActive = true,
  });
  
  bool get canDelete => role != UserRole.viewer && isActive;
  bool get canBulkDelete => role == UserRole.admin && isActive;
  bool get canExport => isActive;
  bool get canView => isActive;
}

/// Service for handling authorization and access control
class AuthorizationService {
  final IReceiptRepository _repository;
  final User _currentUser;
  
  AuthorizationService({
    required IReceiptRepository repository,
    required User currentUser,
  }) : _repository = repository,
       _currentUser = currentUser;
  
  /// Check if user can delete a specific receipt
  Future<bool> canDeleteReceipt(Receipt receipt) async {
    // Check basic delete permission
    if (!_currentUser.canDelete) {
      await _logAuthorizationFailure(
        attemptedAction: 'delete_receipt',
        targetId: receipt.id,
        reason: 'User lacks delete permission',
      );
      return false;
    }
    
    // Admin can delete any receipt
    if (_currentUser.role == UserRole.admin) {
      return true;
    }
    
    // Regular users can only delete their own receipts
    // Note: This assumes Receipt has a userId field - may need to be added
    // For MVP, we'll check if receipt exists in user's receipts
    final userReceipts = await _repository.getReceiptsByUserId(_currentUser.id);
    final canDelete = userReceipts.any((r) => r.id == receipt.id);
    
    if (!canDelete) {
      await _logAuthorizationFailure(
        attemptedAction: 'delete_receipt',
        targetId: receipt.id,
        reason: 'User does not own this receipt',
      );
    }
    
    return canDelete;
  }
  
  /// Filter receipts to only those the user owns
  Future<List<Receipt>> filterOwnedReceipts(List<Receipt> receipts) async {
    // Admin can access all receipts
    if (_currentUser.role == UserRole.admin) {
      return receipts;
    }
    
    // Get user's receipts
    final userReceipts = await _repository.getReceiptsByUserId(_currentUser.id);
    final userReceiptIds = userReceipts.map((r) => r.id).toSet();
    
    // Filter to only owned receipts
    final ownedReceipts = receipts.where((r) => userReceiptIds.contains(r.id)).toList();
    
    // Log if any receipts were filtered out
    final filteredCount = receipts.length - ownedReceipts.length;
    if (filteredCount > 0) {
      await _repository.logAudit(
        AuditLog.create(
          userId: _currentUser.id,
          action: AuditAction.authorizationDenied,
          targetId: 'bulk_filter',
          targetType: 'receipts',
          metadata: {
            'total_receipts': receipts.length,
            'owned_receipts': ownedReceipts.length,
            'filtered_out': filteredCount,
          },
        ),
      );
    }
    
    return ownedReceipts;
  }
  
  /// Check if user can perform bulk delete
  Future<bool> canBulkDelete(int count) async {
    // Check basic bulk delete permission
    if (!_currentUser.canBulkDelete && count > 10) {
      await _logAuthorizationFailure(
        attemptedAction: 'bulk_delete',
        targetId: 'bulk_operation',
        reason: 'User lacks bulk delete permission for >10 items',
      );
      return false;
    }
    
    // Regular users have a limit
    if (_currentUser.role != UserRole.admin && count > 50) {
      await _logAuthorizationFailure(
        attemptedAction: 'bulk_delete',
        targetId: 'bulk_operation', 
        reason: 'Exceeded maximum bulk delete limit (50)',
      );
      return false;
    }
    
    return _currentUser.canDelete;
  }
  
  /// Require re-authentication for large operations
  Future<bool> requireReauthentication(int operationSize) async {
    // Require re-auth for operations > 50 items
    return operationSize > 50;
  }
  
  /// Check if user can export receipts
  bool canExport() {
    return _currentUser.canExport;
  }
  
  /// Check if user can view receipts
  bool canView() {
    return _currentUser.canView;
  }
  
  /// Validate operation and log any authorization failures
  Future<bool> validateOperation({
    required String operation,
    required List<Receipt> receipts,
  }) async {
    // Check if user is active
    if (!_currentUser.isActive) {
      await _logAuthorizationFailure(
        attemptedAction: operation,
        targetId: 'multiple',
        reason: 'User account is inactive',
      );
      return false;
    }
    
    // Check operation-specific permissions
    switch (operation) {
      case 'delete':
      case 'soft_delete':
        if (!_currentUser.canDelete) {
          await _logAuthorizationFailure(
            attemptedAction: operation,
            targetId: receipts.map((r) => r.id).join(','),
            reason: 'User lacks delete permission',
          );
          return false;
        }
        
        // Check bulk delete limits
        if (receipts.length > 10 && !await canBulkDelete(receipts.length)) {
          return false;
        }
        
        // Verify ownership of all receipts
        for (final receipt in receipts) {
          if (!await canDeleteReceipt(receipt)) {
            return false;
          }
        }
        return true;
        
      case 'export':
        return canExport();
        
      case 'view':
        return canView();
        
      default:
        await _logAuthorizationFailure(
          attemptedAction: operation,
          targetId: 'unknown',
          reason: 'Unknown operation type',
        );
        return false;
    }
  }
  
  /// Log authorization failure
  Future<void> _logAuthorizationFailure({
    required String attemptedAction,
    required String targetId,
    required String reason,
  }) async {
    await _repository.logAudit(
      AuditLog.authorizationFailure(
        userId: _currentUser.id,
        attemptedAction: attemptedAction,
        targetId: targetId,
        reason: reason,
      ),
    );
  }
}

/// Provider for AuthorizationService
final authorizationServiceProvider = Provider<AuthorizationService>((ref) {
  final repository = ref.watch(receiptRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider);
  
  return AuthorizationService(
    repository: repository,
    currentUser: currentUser,
  );
});

// These providers would need to be defined elsewhere
final receiptRepositoryProvider = Provider<IReceiptRepository>((ref) {
  throw UnimplementedError('Repository provider needs to be implemented');
});

final currentUserProvider = Provider<User>((ref) {
  // This would typically come from an auth service
  throw UnimplementedError('Current user provider needs to be implemented');
});