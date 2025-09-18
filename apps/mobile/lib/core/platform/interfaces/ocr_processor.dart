import 'dart:typed_data';

/// Platform-agnostic OCR interface
abstract class OcrProcessor {
  /// Initialize the OCR processor
  Future<void> initialize();

  /// Process image and extract text
  Future<OcrResult> processImage(Uint8List imageBytes);

  /// Process receipt-specific data
  Future<ReceiptOcrResult> processReceipt(Uint8List imageBytes);

  /// Check if OCR is available on this platform
  Future<bool> isAvailable();

  /// Dispose resources
  Future<void> dispose();

  /// Platform identifier
  String get platform;
}

/// General OCR result
class OcrResult {
  final String text;
  final double confidence;
  final List<OcrBlock> blocks;
  final Map<String, dynamic>? metadata;

  OcrResult({
    required this.text,
    required this.confidence,
    this.blocks = const [],
    this.metadata,
  });

  bool get hasText => text.isNotEmpty;
}

/// OCR text block with position
class OcrBlock {
  final String text;
  final double confidence;
  final OcrBoundingBox boundingBox;
  final List<OcrLine> lines;

  OcrBlock({
    required this.text,
    required this.confidence,
    required this.boundingBox,
    this.lines = const [],
  });
}

/// OCR line within a block
class OcrLine {
  final String text;
  final double confidence;
  final OcrBoundingBox boundingBox;

  OcrLine({
    required this.text,
    required this.confidence,
    required this.boundingBox,
  });
}

/// Bounding box for OCR elements
class OcrBoundingBox {
  final double left;
  final double top;
  final double width;
  final double height;

  OcrBoundingBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  double get right => left + width;
  double get bottom => top + height;
}

/// Receipt-specific OCR result
class ReceiptOcrResult {
  final String? merchantName;
  final DateTime? date;
  final double? totalAmount;
  final double? taxAmount;
  final double? tipAmount;
  final String? paymentMethod;
  final List<ReceiptLineItem> lineItems;
  final double overallConfidence;
  final String rawText;

  ReceiptOcrResult({
    this.merchantName,
    this.date,
    this.totalAmount,
    this.taxAmount,
    this.tipAmount,
    this.paymentMethod,
    this.lineItems = const [],
    required this.overallConfidence,
    required this.rawText,
  });

  bool get isValid => merchantName != null && totalAmount != null;
}

/// Line item in a receipt
class ReceiptLineItem {
  final String description;
  final double? quantity;
  final double? unitPrice;
  final double? totalPrice;

  ReceiptLineItem({
    required this.description,
    this.quantity,
    this.unitPrice,
    this.totalPrice,
  });
}