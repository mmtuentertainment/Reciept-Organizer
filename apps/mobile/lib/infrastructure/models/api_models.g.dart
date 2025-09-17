// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateReceiptResponseImpl _$$CreateReceiptResponseImplFromJson(
  Map<String, dynamic> json,
) => _$CreateReceiptResponseImpl(
  jobId: json['jobId'] as String,
  deduped: json['deduped'] as bool,
);

Map<String, dynamic> _$$CreateReceiptResponseImplToJson(
  _$CreateReceiptResponseImpl instance,
) => <String, dynamic>{'jobId': instance.jobId, 'deduped': instance.deduped};

_$ReceiptUploadByUrlImpl _$$ReceiptUploadByUrlImplFromJson(
  Map<String, dynamic> json,
) => _$ReceiptUploadByUrlImpl(
  source: json['source'] as String? ?? 'url',
  url: json['url'] as String,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$ReceiptUploadByUrlImplToJson(
  _$ReceiptUploadByUrlImpl instance,
) => <String, dynamic>{
  'source': instance.source,
  'url': instance.url,
  'metadata': instance.metadata,
};

_$ReceiptUploadByBase64Impl _$$ReceiptUploadByBase64ImplFromJson(
  Map<String, dynamic> json,
) => _$ReceiptUploadByBase64Impl(
  source: json['source'] as String? ?? 'base64',
  contentType: json['contentType'] as String,
  data: json['data'] as String,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$ReceiptUploadByBase64ImplToJson(
  _$ReceiptUploadByBase64Impl instance,
) => <String, dynamic>{
  'source': instance.source,
  'contentType': instance.contentType,
  'data': instance.data,
  'metadata': instance.metadata,
};

_$ProblemDetailsImpl _$$ProblemDetailsImplFromJson(Map<String, dynamic> json) =>
    _$ProblemDetailsImpl(
      type: json['type'] as String,
      title: json['title'] as String,
      status: (json['status'] as num?)?.toInt(),
      detail: json['detail'] as String?,
      instance: json['instance'] as String?,
      extensions: json['extensions'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ProblemDetailsImplToJson(
  _$ProblemDetailsImpl instance,
) => <String, dynamic>{
  'type': instance.type,
  'title': instance.title,
  'status': instance.status,
  'detail': instance.detail,
  'instance': instance.instance,
  'extensions': instance.extensions,
};

_$JobStatusImpl _$$JobStatusImplFromJson(Map<String, dynamic> json) =>
    _$JobStatusImpl(
      jobId: json['jobId'] as String,
      status: json['status'] as String,
      message: json['message'] as String?,
      result: json['result'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$JobStatusImplToJson(_$JobStatusImpl instance) =>
    <String, dynamic>{
      'jobId': instance.jobId,
      'status': instance.status,
      'message': instance.message,
      'result': instance.result,
      'createdAt': instance.createdAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };
