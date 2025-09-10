// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QueueEntryImpl _$$QueueEntryImplFromJson(Map<String, dynamic> json) =>
    _$QueueEntryImpl(
      id: json['id'] as String,
      endpoint: json['endpoint'] as String,
      method: json['method'] as String,
      headers: json['headers'] as Map<String, dynamic>,
      body: json['body'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAttemptAt: json['lastAttemptAt'] == null
          ? null
          : DateTime.parse(json['lastAttemptAt'] as String),
      retryCount: (json['retryCount'] as num).toInt(),
      maxRetries: (json['maxRetries'] as num).toInt(),
      errorMessage: json['errorMessage'] as String?,
      status: $enumDecode(_$QueueEntryStatusEnumMap, json['status']),
      feature: json['feature'] as String?,
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$$QueueEntryImplToJson(_$QueueEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'endpoint': instance.endpoint,
      'method': instance.method,
      'headers': instance.headers,
      'body': instance.body,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastAttemptAt': instance.lastAttemptAt?.toIso8601String(),
      'retryCount': instance.retryCount,
      'maxRetries': instance.maxRetries,
      'errorMessage': instance.errorMessage,
      'status': _$QueueEntryStatusEnumMap[instance.status]!,
      'feature': instance.feature,
      'userId': instance.userId,
    };

const _$QueueEntryStatusEnumMap = {
  QueueEntryStatus.pending: 'pending',
  QueueEntryStatus.processing: 'processing',
  QueueEntryStatus.failed: 'failed',
  QueueEntryStatus.completed: 'completed',
};
