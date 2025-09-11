import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'audit_log.freezed.dart';
part 'audit_log.g.dart';

/// Audit log actions
enum AuditAction {
  @JsonValue('soft_delete')
  softDelete,
  @JsonValue('permanent_delete')
  permanentDelete,
  @JsonValue('restore')
  restore,
  @JsonValue('bulk_delete')
  bulkDelete,
  @JsonValue('bulk_restore')
  bulkRestore,
  @JsonValue('export')
  export,
  @JsonValue('authorization_denied')
  authorizationDenied,
}

/// Audit log model for tracking all sensitive operations
@freezed
class AuditLog with _$AuditLog {
  const AuditLog._();
  
  const factory AuditLog({
    required String id,
    required String userId,
    required AuditAction action,
    required String targetId,
    required String targetType,
    required DateTime timestamp,
    Map<String, dynamic>? metadata,
    String? ipAddress,
    String? userAgent,
    String? sessionId,
    bool? success,
    String? errorMessage,
  }) = _AuditLog;

  factory AuditLog.fromJson(Map<String, dynamic> json) => 
      _$AuditLogFromJson(json);
  
  /// Create a new audit log entry
  factory AuditLog.create({
    required String userId,
    required AuditAction action,
    required String targetId,
    required String targetType,
    Map<String, dynamic>? metadata,
    String? ipAddress,
    String? userAgent,
    String? sessionId,
    bool? success,
    String? errorMessage,
  }) {
    return AuditLog(
      id: const Uuid().v4(),
      userId: userId,
      action: action,
      targetId: targetId,
      targetType: targetType,
      timestamp: DateTime.now(),
      metadata: metadata,
      ipAddress: ipAddress,
      userAgent: userAgent,
      sessionId: sessionId,
      success: success ?? true,
      errorMessage: errorMessage,
    );
  }
  
  /// Create audit log for deletion
  factory AuditLog.deletion({
    required String userId,
    required String receiptId,
    required bool isSoftDelete,
    Map<String, dynamic>? additionalData,
  }) {
    return AuditLog.create(
      userId: userId,
      action: isSoftDelete ? AuditAction.softDelete : AuditAction.permanentDelete,
      targetId: receiptId,
      targetType: 'receipt',
      metadata: {
        'operation': isSoftDelete ? 'soft_delete' : 'permanent_delete',
        if (additionalData != null) ...additionalData,
      },
    );
  }
  
  /// Create audit log for bulk operations
  factory AuditLog.bulkOperation({
    required String userId,
    required List<String> receiptIds,
    required AuditAction action,
    Map<String, dynamic>? additionalData,
  }) {
    return AuditLog.create(
      userId: userId,
      action: action,
      targetId: receiptIds.join(','),
      targetType: 'receipts_bulk',
      metadata: {
        'count': receiptIds.length,
        'receipt_ids': receiptIds,
        if (additionalData != null) ...additionalData,
      },
    );
  }
  
  /// Create audit log for authorization failure
  factory AuditLog.authorizationFailure({
    required String userId,
    required String attemptedAction,
    required String targetId,
    String? reason,
  }) {
    return AuditLog.create(
      userId: userId,
      action: AuditAction.authorizationDenied,
      targetId: targetId,
      targetType: 'receipt',
      success: false,
      metadata: {
        'attempted_action': attemptedAction,
        'reason': reason ?? 'Insufficient permissions',
      },
      errorMessage: 'Authorization denied: $reason',
    );
  }
}