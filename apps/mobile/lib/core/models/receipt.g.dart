// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReceiptImpl _$$ReceiptImplFromJson(
  Map<String, dynamic> json,
) => _$ReceiptImpl(
  id: json['id'] as String,
  merchantName: json['merchantName'] as String?,
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  totalAmount: (json['totalAmount'] as num?)?.toDouble(),
  taxAmount: (json['taxAmount'] as num?)?.toDouble(),
  ocrResults: json['ocrResults'] == null
      ? null
      : ProcessingResult.fromJson(json['ocrResults'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  imagePath: json['imagePath'] as String?,
  thumbnailPath: json['thumbnailPath'] as String?,
  lastExportedAt: json['lastExportedAt'] == null
      ? null
      : DateTime.parse(json['lastExportedAt'] as String),
  lastExportFormat: json['lastExportFormat'] as String?,
);

Map<String, dynamic> _$$ReceiptImplToJson(_$ReceiptImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'merchantName': instance.merchantName,
      'date': instance.date?.toIso8601String(),
      'totalAmount': instance.totalAmount,
      'taxAmount': instance.taxAmount,
      'ocrResults': instance.ocrResults,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'imagePath': instance.imagePath,
      'thumbnailPath': instance.thumbnailPath,
      'lastExportedAt': instance.lastExportedAt?.toIso8601String(),
      'lastExportFormat': instance.lastExportFormat,
    };

_$ProcessingResultImpl _$$ProcessingResultImplFromJson(
  Map<String, dynamic> json,
) => _$ProcessingResultImpl(
  merchantName: StringFieldData.fromJson(
    json['merchantName'] as Map<String, dynamic>,
  ),
  totalAmount: DoubleFieldData.fromJson(
    json['totalAmount'] as Map<String, dynamic>,
  ),
  date: DateFieldData.fromJson(json['date'] as Map<String, dynamic>),
  taxAmount: DoubleFieldData.fromJson(
    json['taxAmount'] as Map<String, dynamic>,
  ),
  processingEngine: json['processingEngine'] as String,
  processedAt: DateTime.parse(json['processedAt'] as String),
  overallConfidence: (json['overallConfidence'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$ProcessingResultImplToJson(
  _$ProcessingResultImpl instance,
) => <String, dynamic>{
  'merchantName': instance.merchantName,
  'totalAmount': instance.totalAmount,
  'date': instance.date,
  'taxAmount': instance.taxAmount,
  'processingEngine': instance.processingEngine,
  'processedAt': instance.processedAt.toIso8601String(),
  'overallConfidence': instance.overallConfidence,
};

_$StringFieldDataImpl _$$StringFieldDataImplFromJson(
  Map<String, dynamic> json,
) => _$StringFieldDataImpl(
  value: json['value'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  rawText: json['rawText'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$StringFieldDataImplToJson(
  _$StringFieldDataImpl instance,
) => <String, dynamic>{
  'value': instance.value,
  'confidence': instance.confidence,
  'rawText': instance.rawText,
  'metadata': instance.metadata,
};

_$DoubleFieldDataImpl _$$DoubleFieldDataImplFromJson(
  Map<String, dynamic> json,
) => _$DoubleFieldDataImpl(
  value: (json['value'] as num).toDouble(),
  confidence: (json['confidence'] as num).toDouble(),
  rawText: json['rawText'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$DoubleFieldDataImplToJson(
  _$DoubleFieldDataImpl instance,
) => <String, dynamic>{
  'value': instance.value,
  'confidence': instance.confidence,
  'rawText': instance.rawText,
  'metadata': instance.metadata,
};

_$DateFieldDataImpl _$$DateFieldDataImplFromJson(Map<String, dynamic> json) =>
    _$DateFieldDataImpl(
      value: DateTime.parse(json['value'] as String),
      confidence: (json['confidence'] as num).toDouble(),
      rawText: json['rawText'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$DateFieldDataImplToJson(_$DateFieldDataImpl instance) =>
    <String, dynamic>{
      'value': instance.value.toIso8601String(),
      'confidence': instance.confidence,
      'rawText': instance.rawText,
      'metadata': instance.metadata,
    };
