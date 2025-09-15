import 'receipt.dart';

/// Extended Receipt model with backward compatibility fields
/// This provides the old field names for compatibility with existing code
extension ReceiptCompatibility on Receipt {
  // Old field name mappings
  String? get merchant => merchantName;
  String? get receiptDate => date?.toIso8601String();
  double? get total => totalAmount;
  double? get tax => taxAmount;
  String? get category => null; // Not in new model
  String? get paymentMethod => null; // Not in new model
  String? get notes => null; // Not in new model
  String? get imageUrl => imagePath;
  double? get ocrConfidence => ocrResults?.overallConfidence;
  String? get status => null; // Not in new model
  String? get userId => null; // Not in new model

  // Create a map with old field names for Supabase
  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'merchant': merchantName,
      'receipt_date': date?.toIso8601String(),
      'total': totalAmount,
      'tax': taxAmount,
      'category': null,
      'payment_method': null,
      'notes': null,
      'image_url': imagePath,
      'ocr_confidence': ocrResults?.overallConfidence,
      'status': 'active',
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Create from Supabase JSON with old field names
  static Receipt fromSupabaseJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'] as String,
      merchantName: json['merchant'] as String?,
      date: json['receipt_date'] != null
          ? DateTime.parse(json['receipt_date'] as String)
          : null,
      totalAmount: (json['total'] as num?)?.toDouble(),
      taxAmount: (json['tax'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      imagePath: json['image_url'] as String?,
      ocrResults: json['ocr_confidence'] != null
          ? ProcessingResult(
              merchantName: StringFieldData(
                value: json['merchant'] ?? '',
                confidence: (json['ocr_confidence'] as num).toDouble(),
              ),
              totalAmount: DoubleFieldData(
                value: (json['total'] as num?)?.toDouble() ?? 0.0,
                confidence: (json['ocr_confidence'] as num).toDouble(),
              ),
              date: DateFieldData(
                value: json['receipt_date'] != null
                    ? DateTime.parse(json['receipt_date'] as String)
                    : DateTime.now(),
                confidence: (json['ocr_confidence'] as num).toDouble(),
              ),
              taxAmount: DoubleFieldData(
                value: (json['tax'] as num?)?.toDouble() ?? 0.0,
                confidence: (json['ocr_confidence'] as num).toDouble(),
              ),
              processingEngine: 'supabase',
              processedAt: DateTime.now(),
              overallConfidence: (json['ocr_confidence'] as num?)?.toDouble(),
            )
          : null,
    );
  }
}