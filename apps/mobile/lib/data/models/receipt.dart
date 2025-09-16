import 'package:uuid/uuid.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';

enum ReceiptStatus { captured, processing, ready, exported, error }

class Receipt {
  final String id;
  final String? userId;
  final String imageUri;
  final String? thumbnailUri;
  final DateTime capturedAt;
  final ReceiptStatus status;
  final String? batchId;
  final ProcessingResult? ocrResults;
  final DateTime lastModified;
  final String? notes;

  // Additional fields for Supabase integration
  final String? merchant;
  final String? receiptDate;
  final double? total;
  final double? tax;
  final String? category;
  final String? paymentMethod;
  final String? imageUrl;
  final double? ocrConfidence;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? syncStatus;
  final DateTime? lastSyncAt;

  Receipt({
    String? id,
    this.userId,
    required this.imageUri,
    this.thumbnailUri,
    DateTime? capturedAt,
    this.status = ReceiptStatus.captured,
    this.batchId,
    this.ocrResults,
    DateTime? lastModified,
    this.notes,
    this.merchant,
    this.receiptDate,
    this.total,
    this.tax,
    this.category,
    this.paymentMethod,
    this.imageUrl,
    this.ocrConfidence,
    this.createdAt,
    this.updatedAt,
    this.syncStatus,
    this.lastSyncAt,
  }) :
    id = id ?? const Uuid().v4(),
    capturedAt = capturedAt ?? DateTime.now(),
    lastModified = lastModified ?? DateTime.now();

  Receipt copyWith({
    String? id,
    String? userId,
    String? imageUri,
    String? thumbnailUri,
    DateTime? capturedAt,
    ReceiptStatus? status,
    String? batchId,
    ProcessingResult? ocrResults,
    DateTime? lastModified,
    String? notes,
    String? merchant,
    String? receiptDate,
    double? total,
    double? tax,
    String? category,
    String? paymentMethod,
    String? imageUrl,
    double? ocrConfidence,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    DateTime? lastSyncAt,
  }) {
    return Receipt(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUri: imageUri ?? this.imageUri,
      thumbnailUri: thumbnailUri ?? this.thumbnailUri,
      capturedAt: capturedAt ?? this.capturedAt,
      status: status ?? this.status,
      batchId: batchId ?? this.batchId,
      ocrResults: ocrResults ?? this.ocrResults,
      lastModified: lastModified ?? this.lastModified,
      notes: notes ?? this.notes,
      merchant: merchant ?? this.merchant,
      receiptDate: receiptDate ?? this.receiptDate,
      total: total ?? this.total,
      tax: tax ?? this.tax,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      imageUrl: imageUrl ?? this.imageUrl,
      ocrConfidence: ocrConfidence ?? this.ocrConfidence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  // Convenience getters for OCR data
  String? get merchantName => ocrResults?.merchant?.value?.toString();
  String? get receiptDate => ocrResults?.date?.value?.toString();
  double? get totalAmount {
    final value = ocrResults?.total?.value;
    if (value == null) return null;
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }
  double? get taxAmount {
    final value = ocrResults?.tax?.value;
    if (value == null) return null;
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }

  bool get hasOCRResults => ocrResults != null;
  bool get isComplete => 
      merchantName?.isNotEmpty == true && 
      receiptDate?.isNotEmpty == true && 
      totalAmount != null && 
      totalAmount! > 0;

  double get overallConfidence => ocrResults?.overallConfidence ?? 0.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'imageUri': imageUri,
      'thumbnailUri': thumbnailUri,
      'capturedAt': capturedAt.toIso8601String(),
      'status': status.name,
      'batchId': batchId,
      'lastModified': lastModified.toIso8601String(),
      'notes': notes,
      // Direct fields for Supabase
      'merchant': merchant ?? merchantName,
      'receiptDate': receiptDate ?? this.receiptDate,
      'total': total ?? totalAmount,
      'tax': tax ?? taxAmount,
      'category': category,
      'paymentMethod': paymentMethod,
      'imageUrl': imageUrl ?? imageUri,
      'ocrConfidence': ocrConfidence ?? overallConfidence,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'syncStatus': syncStatus,
      'lastSyncAt': lastSyncAt?.toIso8601String(),
      // OCR results would need custom serialization for complex objects
      'merchantName': merchantName,
      'totalAmount': totalAmount,
      'taxAmount': taxAmount,
      'overallConfidence': overallConfidence,
    };
  }

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'],
      userId: json['userId'] ?? json['user_id'],
      imageUri: json['imageUri'] ?? json['image_url'] ?? '',
      thumbnailUri: json['thumbnailUri'],
      capturedAt: json['capturedAt'] != null
          ? DateTime.parse(json['capturedAt'])
          : DateTime.now(),
      status: ReceiptStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReceiptStatus.captured,
      ),
      batchId: json['batchId'],
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'])
          : DateTime.now(),
      notes: json['notes'],
      // Supabase fields
      merchant: json['merchant'],
      receiptDate: json['receiptDate'] ?? json['receipt_date'],
      total: json['total'] != null ? (json['total'] as num).toDouble() : null,
      tax: json['tax'] != null ? (json['tax'] as num).toDouble() : null,
      category: json['category'],
      paymentMethod: json['paymentMethod'] ?? json['payment_method'],
      imageUrl: json['imageUrl'] ?? json['image_url'],
      ocrConfidence: json['ocrConfidence'] != null
          ? (json['ocrConfidence'] as num).toDouble()
          : (json['ocr_confidence'] != null
              ? (json['ocr_confidence'] as num).toDouble()
              : null),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : (json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null),
      syncStatus: json['syncStatus'] ?? json['sync_status'],
      lastSyncAt: json['lastSyncAt'] != null
          ? DateTime.parse(json['lastSyncAt'])
          : (json['last_sync_at'] != null
              ? DateTime.parse(json['last_sync_at'])
              : null),
      // OCR results would need to be reconstructed from individual fields
    );
  }

  @override
  String toString() {
    return 'Receipt(id: $id, imageUri: $imageUri, capturedAt: $capturedAt, status: $status, batchId: $batchId, merchant: $merchantName, total: $totalAmount)';
  }
}