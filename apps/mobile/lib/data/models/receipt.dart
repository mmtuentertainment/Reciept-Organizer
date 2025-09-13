import 'package:uuid/uuid.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';

enum ReceiptStatus { captured, processing, ready, exported, error }

class Receipt {
  final String id;
  final String imageUri;
  final String? thumbnailUri;
  final DateTime capturedAt;
  final ReceiptStatus status;
  final String? batchId;
  final ProcessingResult? ocrResults;
  final DateTime lastModified;
  final String? notes;

  Receipt({
    String? id,
    required this.imageUri,
    this.thumbnailUri,
    DateTime? capturedAt,
    this.status = ReceiptStatus.captured,
    this.batchId,
    this.ocrResults,
    DateTime? lastModified,
    this.notes,
  }) : 
    id = id ?? const Uuid().v4(),
    capturedAt = capturedAt ?? DateTime.now(),
    lastModified = lastModified ?? DateTime.now();

  Receipt copyWith({
    String? id,
    String? imageUri,
    String? thumbnailUri,
    DateTime? capturedAt,
    ReceiptStatus? status,
    String? batchId,
    ProcessingResult? ocrResults,
    DateTime? lastModified,
    String? notes,
  }) {
    return Receipt(
      id: id ?? this.id,
      imageUri: imageUri ?? this.imageUri,
      thumbnailUri: thumbnailUri ?? this.thumbnailUri,
      capturedAt: capturedAt ?? this.capturedAt,
      status: status ?? this.status,
      batchId: batchId ?? this.batchId,
      ocrResults: ocrResults ?? this.ocrResults,
      lastModified: lastModified ?? this.lastModified,
      notes: notes ?? this.notes,
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
      'imageUri': imageUri,
      'thumbnailUri': thumbnailUri,
      'capturedAt': capturedAt.toIso8601String(),
      'status': status.name,
      'batchId': batchId,
      'lastModified': lastModified.toIso8601String(),
      'notes': notes,
      // OCR results would need custom serialization for complex objects
      'merchantName': merchantName,
      'receiptDate': receiptDate,
      'totalAmount': totalAmount,
      'taxAmount': taxAmount,
      'overallConfidence': overallConfidence,
    };
  }

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'],
      imageUri: json['imageUri'],
      thumbnailUri: json['thumbnailUri'],
      capturedAt: DateTime.parse(json['capturedAt']),
      status: ReceiptStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReceiptStatus.captured,
      ),
      batchId: json['batchId'],
      lastModified: json['lastModified'] != null 
          ? DateTime.parse(json['lastModified'])
          : DateTime.now(),
      notes: json['notes'],
      // OCR results would need to be reconstructed from individual fields
    );
  }

  @override
  String toString() {
    return 'Receipt(id: $id, imageUri: $imageUri, capturedAt: $capturedAt, status: $status, batchId: $batchId, merchant: $merchantName, total: $totalAmount)';
  }
}