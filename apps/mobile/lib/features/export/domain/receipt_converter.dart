import 'package:receipt_organizer/core/models/receipt.dart' as core;
import 'package:receipt_organizer/data/models/receipt.dart' as data;

/// Converts between data layer Receipt and core layer Receipt models
class ReceiptConverter {
  /// Convert data layer Receipt to core layer Receipt for validation
  static core.Receipt fromDataReceipt(data.Receipt dataReceipt) {
    // Extract values using the convenience getters
    String? merchantName = dataReceipt.merchantName;
    DateTime? date = dataReceipt.receiptDate;
    double? totalAmount = dataReceipt.totalAmount;
    double? taxAmount = dataReceipt.taxAmount;
    
    // Convert ProcessingResult to core model if available
    core.ProcessingResult? ocrResults;
    if (dataReceipt.ocrResults != null) {
      final ocr = dataReceipt.ocrResults!;
      
      // Extract confidence values from FieldData
      double merchantConfidence = ocr.merchant?.confidence ?? 0.0;
      double totalConfidence = ocr.total?.confidence ?? 0.0;
      double dateConfidence = ocr.date?.confidence ?? 0.0;
      double taxConfidence = ocr.tax?.confidence ?? 0.0;
      
      ocrResults = core.ProcessingResult(
        merchantName: core.StringFieldData(
          value: merchantName ?? '',
          confidence: merchantConfidence,
          rawText: ocr.merchant?.originalText,
        ),
        totalAmount: core.DoubleFieldData(
          value: totalAmount ?? 0.0,
          confidence: totalConfidence,
          rawText: ocr.total?.originalText,
        ),
        date: core.DateFieldData(
          value: date ?? DateTime.now(),
          confidence: dateConfidence,
          rawText: ocr.date?.originalText,
        ),
        taxAmount: core.DoubleFieldData(
          value: taxAmount ?? 0.0,
          confidence: taxConfidence,
          rawText: ocr.tax?.originalText,
        ),
        processingEngine: ocr.processingEngine,
        processedAt: DateTime.now(), // Use current time as processedAt
        overallConfidence: ocr.overallConfidence,
      );
    }
    
    return core.Receipt(
      id: dataReceipt.id,
      merchantName: merchantName,
      date: date,
      totalAmount: totalAmount,
      taxAmount: taxAmount,
      ocrResults: ocrResults,
      createdAt: dataReceipt.capturedAt,
      updatedAt: dataReceipt.lastModified,
      imagePath: dataReceipt.imageUri,
      thumbnailPath: dataReceipt.thumbnailUri,
      lastExportedAt: dataReceipt.status == data.ReceiptStatus.exported
          ? dataReceipt.lastModified
          : null,
    );
  }
  
  /// Convert a list of data layer Receipts to core layer Receipts
  static List<core.Receipt> fromDataReceipts(List<data.Receipt> dataReceipts) {
    return dataReceipts.map((r) => fromDataReceipt(r)).toList();
  }
  
  /// Check if a data Receipt has minimum required fields for export
  static bool hasMinimumFieldsForExport(data.Receipt receipt) {
    if (receipt.ocrResults == null) return false;

    // Use the receipt's convenience getters to check for required fields
    return receipt.merchantName != null &&
           receipt.merchantName!.isNotEmpty &&
           receipt.receiptDate != null &&
           receipt.totalAmount != null &&
           receipt.totalAmount! > 0;
  }
  
  /// Filter receipts that are ready for export
  static List<data.Receipt> filterExportableReceipts(List<data.Receipt> receipts) {
    return receipts.where((r) => 
      r.status == data.ReceiptStatus.ready && 
      hasMinimumFieldsForExport(r)
    ).toList();
  }
}