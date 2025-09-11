// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuditLogImpl _$$AuditLogImplFromJson(Map<String, dynamic> json) =>
    _$AuditLogImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      action: $enumDecode(_$AuditActionEnumMap, json['action']),
      targetId: json['targetId'] as String,
      targetType: json['targetType'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      sessionId: json['sessionId'] as String?,
      success: json['success'] as bool?,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$AuditLogImplToJson(_$AuditLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'action': _$AuditActionEnumMap[instance.action]!,
      'targetId': instance.targetId,
      'targetType': instance.targetType,
      'timestamp': instance.timestamp.toIso8601String(),
      'metadata': instance.metadata,
      'ipAddress': instance.ipAddress,
      'userAgent': instance.userAgent,
      'sessionId': instance.sessionId,
      'success': instance.success,
      'errorMessage': instance.errorMessage,
    };

const _$AuditActionEnumMap = {
  AuditAction.softDelete: 'soft_delete',
  AuditAction.permanentDelete: 'permanent_delete',
  AuditAction.restore: 'restore',
  AuditAction.bulkDelete: 'bulk_delete',
  AuditAction.bulkRestore: 'bulk_restore',
  AuditAction.export: 'export',
  AuditAction.authorizationDenied: 'authorization_denied',
};
