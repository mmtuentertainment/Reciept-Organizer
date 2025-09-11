import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'receipt.freezed.dart';
part 'receipt.g.dart';

/// Core receipt model for the application
@freezed
class Receipt with _$Receipt {
  const Receipt._();
  
  const factory Receipt({
    required String id,
    String? merchantName,
    DateTime? date,
    double? totalAmount,
    double? taxAmount,
    
    // OCR processing results
    ProcessingResult? ocrResults,
    
    // Metadata
    required DateTime createdAt,
    DateTime? updatedAt,
    String? imagePath,
    String? thumbnailPath,
    
    // Export tracking
    DateTime? lastExportedAt,
    String? lastExportFormat,
    bool? wasExported,
    
    // Soft delete fields
    DateTime? deletedAt,
    String? deletedBy,
  }) = _Receipt;
  
  /// Check if the receipt is soft deleted
  bool get isDeleted => deletedAt != null;
  
  /// Check if the receipt was exported
  bool get hasBeenExported => wasExported ?? false;

  factory Receipt.fromJson(Map<String, dynamic> json) => _$ReceiptFromJson(json);
  
  /// Create a new receipt with generated ID
  factory Receipt.create({
    String? merchantName,
    DateTime? date,
    double? totalAmount,
    double? taxAmount,
    ProcessingResult? ocrResults,
    String? imagePath,
    String? thumbnailPath,
  }) {
    return Receipt(
      id: const Uuid().v4(),
      merchantName: merchantName,
      date: date,
      totalAmount: totalAmount,
      taxAmount: taxAmount,
      ocrResults: ocrResults,
      createdAt: DateTime.now(),
      imagePath: imagePath,
      thumbnailPath: thumbnailPath,
    );
  }
}

/// OCR processing result with confidence scores
@freezed
class ProcessingResult with _$ProcessingResult {
  const factory ProcessingResult({
    required StringFieldData merchantName,
    required DoubleFieldData totalAmount,
    required DateFieldData date,
    required DoubleFieldData taxAmount,
    required String processingEngine,
    required DateTime processedAt,
    double? overallConfidence,
  }) = _ProcessingResult;

  factory ProcessingResult.fromJson(Map<String, dynamic> json) =>
      _$ProcessingResultFromJson(json);
}

/// Field data for string values with confidence score
@freezed
class StringFieldData with _$StringFieldData {
  const factory StringFieldData({
    required String value,
    required double confidence,
    String? rawText,
    Map<String, dynamic>? metadata,
  }) = _StringFieldData;

  factory StringFieldData.fromJson(Map<String, dynamic> json) =>
      _$StringFieldDataFromJson(json);
}

/// Field data for double values with confidence score  
@freezed
class DoubleFieldData with _$DoubleFieldData {
  const factory DoubleFieldData({
    required double value,
    required double confidence,
    String? rawText,
    Map<String, dynamic>? metadata,
  }) = _DoubleFieldData;

  factory DoubleFieldData.fromJson(Map<String, dynamic> json) =>
      _$DoubleFieldDataFromJson(json);
}

/// Field data for date values with confidence score
@freezed
class DateFieldData with _$DateFieldData {
  const factory DateFieldData({
    required DateTime value,
    required double confidence,
    String? rawText,
    Map<String, dynamic>? metadata,
  }) = _DateFieldData;

  factory DateFieldData.fromJson(Map<String, dynamic> json) =>
      _$DateFieldDataFromJson(json);
}