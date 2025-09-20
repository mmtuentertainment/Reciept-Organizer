// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReceiptModelImpl _$$ReceiptModelImplFromJson(Map<String, dynamic> json) =>
    _$ReceiptModelImpl(
      id: ReceiptId.fromJson(json['id'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: $enumDecode(_$ReceiptStatusEnumMap, json['status']),
      imagePath: json['imagePath'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      merchant: json['merchant'] as String?,
      totalAmount: json['totalAmount'] == null
          ? null
          : Money.fromJson(json['totalAmount'] as Map<String, dynamic>),
      taxAmount: json['taxAmount'] == null
          ? null
          : Money.fromJson(json['taxAmount'] as Map<String, dynamic>),
      purchaseDate: json['purchaseDate'] == null
          ? null
          : DateTime.parse(json['purchaseDate'] as String),
      category: json['category'] == null
          ? null
          : Category.fromJson(json['category'] as Map<String, dynamic>),
      paymentMethod: $enumDecodeNullable(
        _$PaymentMethodEnumMap,
        json['paymentMethod'],
      ),
      notes: json['notes'] as String?,
      businessPurpose: json['businessPurpose'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => ReceiptItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      isFavorite: json['isFavorite'] as bool? ?? false,
      batchId: json['batchId'] as String?,
      ocrConfidence: (json['ocrConfidence'] as num?)?.toDouble(),
      ocrRawText: json['ocrRawText'] as String?,
      errorMessage: json['errorMessage'] as String?,
      cloudStorageUrl: json['cloudStorageUrl'] as String?,
      needsReview: json['needsReview'] as bool? ?? false,
    );

Map<String, dynamic> _$$ReceiptModelImplToJson(_$ReceiptModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'status': _$ReceiptStatusEnumMap[instance.status]!,
      'imagePath': instance.imagePath,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'merchant': instance.merchant,
      'totalAmount': instance.totalAmount,
      'taxAmount': instance.taxAmount,
      'purchaseDate': instance.purchaseDate?.toIso8601String(),
      'category': instance.category,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod],
      'notes': instance.notes,
      'businessPurpose': instance.businessPurpose,
      'items': instance.items,
      'tags': instance.tags,
      'isFavorite': instance.isFavorite,
      'batchId': instance.batchId,
      'ocrConfidence': instance.ocrConfidence,
      'ocrRawText': instance.ocrRawText,
      'errorMessage': instance.errorMessage,
      'cloudStorageUrl': instance.cloudStorageUrl,
      'needsReview': instance.needsReview,
    };

const _$ReceiptStatusEnumMap = {
  ReceiptStatus.pending: 'pending',
  ReceiptStatus.captured: 'captured',
  ReceiptStatus.processing: 'processing',
  ReceiptStatus.processed: 'processed',
  ReceiptStatus.reviewed: 'reviewed',
  ReceiptStatus.error: 'error',
  ReceiptStatus.exported: 'exported',
  ReceiptStatus.deleted: 'deleted',
  ReceiptStatus.archived: 'archived',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.creditCard: 'creditCard',
  PaymentMethod.debitCard: 'debitCard',
  PaymentMethod.check: 'check',
  PaymentMethod.bankTransfer: 'bankTransfer',
  PaymentMethod.digitalWallet: 'digitalWallet',
  PaymentMethod.paypal: 'paypal',
  PaymentMethod.venmo: 'venmo',
  PaymentMethod.crypto: 'crypto',
  PaymentMethod.other: 'other',
};
