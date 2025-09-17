import 'package:uuid/uuid.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';

enum ReceiptStatus { pending, captured, processing, ready, exported, error }

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

  // Database fields matching exact schema from docs/stories/1.1-enhanced-database-schema.md
  final String? vendorName;       // vendor_name VARCHAR(255)
  final DateTime? receiptDate;    // receipt_date DATE
  final double? totalAmount;      // total_amount DECIMAL(10,2)
  final double? taxAmount;        // tax_amount DECIMAL(10,2)
  final double? tipAmount;        // tip_amount DECIMAL(10,2)
  final String? currency;         // currency VARCHAR(3)
  final String? categoryId;       // category_id UUID
  final String? subcategory;      // subcategory VARCHAR(100)
  final String? paymentMethod;    // payment_method VARCHAR(50)
  final double? ocrConfidence;    // ocr_confidence DECIMAL(5,2)
  final String? ocrRawText;       // ocr_raw_text TEXT
  final bool? isProcessed;        // is_processed BOOLEAN
  final bool? needsReview;        // needs_review BOOLEAN
  final String? imageUrl;         // image_url TEXT (same as imageUri for compatibility)
  final String? businessPurpose;  // business_purpose TEXT
  final List<String>? tags;        // tags TEXT[]
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Not in database but used for sync tracking
  final String? syncStatus;
  final DateTime? lastSyncAt;

  // Metadata for API integration
  final Map<String, dynamic>? metadata;

  // Alias for vendorName for API compatibility
  String? get merchantName => vendorName;

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
    this.vendorName,
    this.receiptDate,
    this.totalAmount,
    this.taxAmount,
    this.tipAmount,
    this.currency,
    this.categoryId,
    this.subcategory,
    this.paymentMethod,
    this.ocrConfidence,
    this.ocrRawText,
    this.isProcessed,
    this.needsReview,
    this.imageUrl,
    this.businessPurpose,
    this.tags,
    this.createdAt,
    this.updatedAt,
    this.syncStatus,
    this.lastSyncAt,
    this.metadata,
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
    String? vendorName,
    DateTime? receiptDate,
    double? totalAmount,
    double? taxAmount,
    double? tipAmount,
    String? currency,
    String? categoryId,
    String? subcategory,
    String? paymentMethod,
    double? ocrConfidence,
    String? ocrRawText,
    bool? isProcessed,
    bool? needsReview,
    String? imageUrl,
    String? businessPurpose,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    DateTime? lastSyncAt,
    Map<String, dynamic>? metadata,
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
      vendorName: vendorName ?? this.vendorName,
      receiptDate: receiptDate ?? this.receiptDate,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      tipAmount: tipAmount ?? this.tipAmount,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      subcategory: subcategory ?? this.subcategory,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      ocrConfidence: ocrConfidence ?? this.ocrConfidence,
      ocrRawText: ocrRawText ?? this.ocrRawText,
      isProcessed: isProcessed ?? this.isProcessed,
      needsReview: needsReview ?? this.needsReview,
      imageUrl: imageUrl ?? this.imageUrl,
      businessPurpose: businessPurpose ?? this.businessPurpose,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Convenience getters - prefer database fields over OCR extraction
  String? get merchant => vendorName ?? ocrResults?.merchant?.value?.toString();
  double? get total => totalAmount ?? _extractOcrAmount(ocrResults?.total?.value);
  double? get tax => taxAmount ?? _extractOcrAmount(ocrResults?.tax?.value);

  double? _extractOcrAmount(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }

  bool get hasOCRResults => ocrResults != null;
  bool get isComplete =>
      merchant?.isNotEmpty == true &&
      receiptDate != null &&
      total != null &&
      total! > 0;

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
      // Database fields - using snake_case for database compatibility
      'user_id': userId,
      'vendor_name': vendorName,
      'receipt_date': receiptDate?.toIso8601String()?.substring(0, 10), // DATE format
      'total_amount': totalAmount,
      'tax_amount': taxAmount,
      'tip_amount': tipAmount,
      'currency': currency,
      'category_id': categoryId,
      'subcategory': subcategory,
      'payment_method': paymentMethod,
      'ocr_confidence': ocrConfidence,
      'ocr_raw_text': ocrRawText,
      'is_processed': isProcessed,
      'needs_review': needsReview,
      'image_url': imageUrl ?? imageUri,
      'business_purpose': businessPurpose,
      'tags': tags,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'sync_status': syncStatus,
      'last_sync_at': lastSyncAt?.toIso8601String(),
    };
  }

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'],
      userId: json['userId'] ?? json['user_id'],
      imageUri: json['imageUri'] ?? json['image_url'] ?? '',
      thumbnailUri: json['thumbnailUri'] ?? json['thumbnail_uri'],
      capturedAt: json['capturedAt'] != null
          ? DateTime.parse(json['capturedAt'])
          : (json['captured_at'] != null
              ? DateTime.parse(json['captured_at'])
              : DateTime.now()),
      status: ReceiptStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReceiptStatus.captured,
      ),
      batchId: json['batchId'] ?? json['batch_id'],
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'])
          : (json['last_modified'] != null
              ? DateTime.parse(json['last_modified'])
              : DateTime.now()),
      notes: json['notes'],
      // Database fields
      vendorName: json['vendor_name'] ?? json['vendorName'],
      receiptDate: json['receipt_date'] != null
          ? DateTime.parse(json['receipt_date'])
          : (json['receiptDate'] != null
              ? DateTime.parse(json['receiptDate'])
              : null),
      totalAmount: json['total_amount'] != null
          ? (json['total_amount'] as num).toDouble()
          : (json['totalAmount'] != null
              ? (json['totalAmount'] as num).toDouble()
              : null),
      taxAmount: json['tax_amount'] != null
          ? (json['tax_amount'] as num).toDouble()
          : (json['taxAmount'] != null
              ? (json['taxAmount'] as num).toDouble()
              : null),
      tipAmount: json['tip_amount'] != null
          ? (json['tip_amount'] as num).toDouble()
          : (json['tipAmount'] != null
              ? (json['tipAmount'] as num).toDouble()
              : null),
      currency: json['currency'],
      categoryId: json['category_id'] ?? json['categoryId'],
      subcategory: json['subcategory'],
      paymentMethod: json['payment_method'] ?? json['paymentMethod'],
      ocrConfidence: json['ocr_confidence'] != null
          ? (json['ocr_confidence'] as num).toDouble()
          : (json['ocrConfidence'] != null
              ? (json['ocrConfidence'] as num).toDouble()
              : null),
      ocrRawText: json['ocr_raw_text'] ?? json['ocrRawText'],
      isProcessed: json['is_processed'] ?? json['isProcessed'],
      needsReview: json['needs_review'] ?? json['needsReview'],
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? json['imageUri'],
      businessPurpose: json['business_purpose'] ?? json['businessPurpose'],
      tags: json['tags'] != null
          ? List<String>.from(json['tags'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : (json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : null),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : (json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : null),
      syncStatus: json['sync_status'] ?? json['syncStatus'],
      lastSyncAt: json['last_sync_at'] != null
          ? DateTime.parse(json['last_sync_at'])
          : (json['lastSyncAt'] != null
              ? DateTime.parse(json['lastSyncAt'])
              : null),
      // OCR results would need to be reconstructed from individual fields
    );
  }

  @override
  String toString() {
    return 'Receipt(id: $id, imageUri: $imageUri, capturedAt: $capturedAt, status: $status, batchId: $batchId, merchant: $vendorName, total: $totalAmount)';
  }
}