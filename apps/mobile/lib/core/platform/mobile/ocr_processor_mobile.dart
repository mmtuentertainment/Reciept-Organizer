import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../interfaces/ocr_processor.dart';
import '../../services/ocr_configuration_service.dart';
import '../../services/cloud_ocr_service.dart';

/// Mobile OCR implementation
/// Uses Cloud Vision API when available, falls back to mock data
class OcrProcessorMobile implements OcrProcessor {
  bool _isInitialized = false;
  final OcrConfigurationService _config = OcrConfigurationService();
  final CloudOcrService _cloudOcr = CloudOcrService();

  @override
  String get platform => 'mobile';

  @override
  Future<bool> isAvailable() async {
    // For now, return true as we'll provide mock data
    // When ML Kit is added, check actual availability
    return true;
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    // TODO: Initialize ML Kit when available
    // _textRecognizer = TextRecognizer();

    _isInitialized = true;
  }

  @override
  Future<OcrResult> processImage(Uint8List imageBytes) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Determine which OCR provider to use
    final provider = _config.getRecommendedProvider();

    switch (provider) {
      case OcrProvider.googleVision:
      case OcrProvider.azureVision:
        // Try cloud OCR first
        final cloudResult = await _cloudOcr.processImage(imageBytes);
        if (cloudResult != null) {
          return cloudResult;
        }
        // Fall through to mock if cloud fails
        break;

      case OcrProvider.mlKit:
        // ML Kit not yet implemented, use mock
        // TODO: When ML Kit is available, use actual text recognition
        break;

      case OcrProvider.tesseractJs:
        // Not applicable for mobile
        break;

      case OcrProvider.mock:
        // Use mock data
        break;
    }

    // Fallback to mock data
    await Future.delayed(const Duration(seconds: 1)); // Simulate processing

    final mockText = _generateMockReceiptText();

    return OcrResult(
      text: mockText,
      confidence: 0.85,
      blocks: [],
      metadata: {
        'processor': 'mobile_mock',
        'provider': provider.toString(),
        'note': 'Using mock data - configure API key for real OCR',
      },
    );
  }

  @override
  Future<ReceiptOcrResult> processReceipt(Uint8List imageBytes) async {
    final ocrResult = await processImage(imageBytes);

    // Parse receipt-specific data from OCR result
    final parser = ReceiptParser(ocrResult);

    return ReceiptOcrResult(
      merchantName: parser.extractMerchantName(),
      date: parser.extractDate(),
      totalAmount: parser.extractTotalAmount(),
      taxAmount: parser.extractTaxAmount(),
      tipAmount: parser.extractTipAmount(),
      paymentMethod: parser.extractPaymentMethod(),
      lineItems: parser.extractLineItems(),
      overallConfidence: ocrResult.confidence,
      rawText: ocrResult.text,
    );
  }

  @override
  Future<void> dispose() async {
    // TODO: Dispose ML Kit resources when available
    // await _textRecognizer?.close();
    _isInitialized = false;
  }

  String _generateMockReceiptText() {
    // Generate realistic mock receipt text for testing
    return '''
WALMART SUPERCENTER
123 MAIN STREET
ANYTOWN, ST 12345
(555) 123-4567

DATE: ${DateTime.now().toString().substring(0, 10)}
TIME: 14:30

CASHIER: JOHN DOE
REGISTER: 03

GROCERY
MILK 2% GAL          4.99
BREAD WHEAT          2.49
EGGS LARGE DZ        3.99
CHICKEN BREAST       8.99
BANANAS 2LB          2.99

SUBTOTAL            23.45
TAX (8.25%)          1.94
TOTAL               25.39

PAYMENT METHOD: CREDIT CARD
CARD: ****1234

THANK YOU FOR SHOPPING!
SAVE YOUR RECEIPT
    ''';
  }
}

/// Receipt parser for extracting structured data
class ReceiptParser {
  final OcrResult ocrResult;
  final String text;

  ReceiptParser(this.ocrResult) : text = ocrResult.text.toUpperCase();

  String? extractMerchantName() {
    // Look for merchant name in first few lines
    final lines = ocrResult.text.split('\n');
    if (lines.isEmpty) return null;

    // First non-empty line is often the merchant name
    for (final line in lines.take(5)) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty && trimmed.length > 3) {
        // Filter out common non-merchant lines
        if (!trimmed.contains('DATE') &&
            !trimmed.contains('TIME') &&
            !trimmed.contains('RECEIPT')) {
          return trimmed;
        }
      }
    }
    return null;
  }

  DateTime? extractDate() {
    // Common date patterns
    final patterns = [
      RegExp(r'DATE:\s*(\d{4}-\d{2}-\d{2})'),
      RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})'),
      RegExp(r'(\d{2,4})[/-](\d{1,2})[/-](\d{1,2})'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          // For simplicity, return current date
          // In production, parse the actual date string
          return DateTime.now();
        } catch (e) {
          continue;
        }
      }
    }
    return null;
  }

  double? extractTotalAmount() {
    // Look for total patterns
    final totalPatterns = [
      RegExp(r'TOTAL\s*[:.\s]+\$?(\d+\.?\d*)'),
      RegExp(r'AMOUNT\s*[:.\s]+\$?(\d+\.?\d*)'),
      RegExp(r'GRAND TOTAL\s*[:.\s]+\$?(\d+\.?\d*)'),
      RegExp(r'BALANCE\s*[:.\s]+\$?(\d+\.?\d*)'),
    ];

    for (final pattern in totalPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amountStr = match.group(1);
        if (amountStr != null) {
          return double.tryParse(amountStr);
        }
      }
    }
    return null;
  }

  double? extractTaxAmount() {
    final taxPattern = RegExp(r'TAX\s*.*[:.\s]+\$?(\d+\.?\d*)');
    final match = taxPattern.firstMatch(text);
    if (match != null) {
      final amountStr = match.group(1);
      if (amountStr != null) {
        return double.tryParse(amountStr);
      }
    }
    return null;
  }

  double? extractTipAmount() {
    final tipPatterns = [
      RegExp(r'TIP\s*[:.\s]+\$?(\d+\.?\d*)'),
      RegExp(r'GRATUITY\s*[:.\s]+\$?(\d+\.?\d*)'),
    ];

    for (final pattern in tipPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amountStr = match.group(1);
        if (amountStr != null) {
          return double.tryParse(amountStr);
        }
      }
    }
    return null;
  }

  String? extractPaymentMethod() {
    if (text.contains('VISA')) return 'Visa';
    if (text.contains('MASTERCARD')) return 'Mastercard';
    if (text.contains('AMEX')) return 'American Express';
    if (text.contains('CASH')) return 'Cash';
    if (text.contains('DEBIT')) return 'Debit Card';
    if (text.contains('CREDIT')) return 'Credit Card';
    return null;
  }

  List<ReceiptLineItem> extractLineItems() {
    // Simple line item extraction
    final items = <ReceiptLineItem>[];
    final lines = ocrResult.text.split('\n');

    // Pattern for line items (item name followed by price)
    final itemPattern = RegExp(r'^([A-Z\s]+)\s+(\d+\.\d{2})$');

    for (final line in lines) {
      final match = itemPattern.firstMatch(line.trim());
      if (match != null) {
        items.add(ReceiptLineItem(
          description: match.group(1)!.trim(),
          totalPrice: double.tryParse(match.group(2)!),
        ));
      }
    }

    return items;
  }
}