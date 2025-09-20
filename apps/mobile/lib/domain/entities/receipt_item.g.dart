// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReceiptItemImpl _$$ReceiptItemImplFromJson(Map<String, dynamic> json) =>
    _$ReceiptItemImpl(
      name: json['name'] as String,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
      unit: json['unit'] as String? ?? 'each',
      unitPrice: json['unitPrice'] == null
          ? null
          : Money.fromJson(json['unitPrice'] as Map<String, dynamic>),
      totalPrice: json['totalPrice'] == null
          ? null
          : Money.fromJson(json['totalPrice'] as Map<String, dynamic>),
      category: json['category'] == null
          ? null
          : Category.fromJson(json['category'] as Map<String, dynamic>),
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      isTaxable: json['isTaxable'] as bool? ?? true,
      discount: json['discount'] == null
          ? null
          : Money.fromJson(json['discount'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$ReceiptItemImplToJson(_$ReceiptItemImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
      'category': instance.category,
      'sku': instance.sku,
      'barcode': instance.barcode,
      'isTaxable': instance.isTaxable,
      'discount': instance.discount,
      'notes': instance.notes,
    };
