import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../interfaces/ocr_processor.dart';
import '../../services/ocr_configuration_service.dart';
import '../../services/cloud_ocr_service.dart';

/// Web OCR implementation using cloud API or mock data
class OcrProcessorWeb implements OcrProcessor {
  bool _isInitialized = false;
  final OcrConfigurationService _config = OcrConfigurationService();
  final CloudOcrService _cloudOcr = CloudOcrService();

  @override
  String get platform => 'web';

  @override
  Future<bool> isAvailable() async {
    // OCR on web requires either:
    // 1. Cloud API (needs API key)
    // 2. Tesseract.js (client-side)
    // For now, we'll use a mock implementation
    return true;
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    // TODO: Initialize Tesseract.js or cloud API
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
        // Try cloud OCR
        final cloudResult = await _cloudOcr.processImage(imageBytes);
        if (cloudResult != null) {
          return cloudResult;
        }
        // Fall through to mock if cloud fails
        break;

      case OcrProvider.tesseractJs:
        // Tesseract.js implementation would go here
        // For now, fall through to mock
        // TODO: Implement Tesseract.js integration
        break;

      case OcrProvider.mlKit:
        // Not applicable for web
        break;

      case OcrProvider.mock:
        // Use mock data
        break;
    }

    // Fallback to mock data
    await Future.delayed(const Duration(seconds: 1)); // Simulate processing

    return OcrResult(
      text: _getMockText(),
      confidence: 0.75,
      blocks: [],
      metadata: {
        'processor': 'web_mock',
        'provider': provider.toString(),
        'note': 'Using mock data - configure API key for real OCR',
      },
    );
  }

  @override
  Future<ReceiptOcrResult> processReceipt(Uint8List imageBytes) async {
    final ocrResult = await processImage(imageBytes);

    // Parse mock data
    final parser = WebReceiptParser(ocrResult);

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
    _isInitialized = false;
  }

  String _getMockText() {
    return '''
TARGET STORE #1234
456 SHOPPING CENTER DR
CITY, STATE 54321

Date: ${DateTime.now().toString().substring(0, 10)}
Time: 12:30 PM
Register: 5
Cashier: JANE SMITH

ELECTRONICS
HDMI CABLE              12.99
USB CHARGER             19.99

HOME & GARDEN
PLANT POT               15.99
SOIL 10LB               8.99

GROCERY
COFFEE BEANS            14.99
MILK ALMOND             4.99

Subtotal:               77.94
Tax (8.25%):            6.43
Total:                  84.37

Payment: Credit Card
Card: **** 5678

Thank you for shopping at Target!
Save 5% with RedCard
    ''';
  }

  /// Alternative: Call cloud OCR API (example implementation)
  Future<OcrResult> _callCloudOcr(Uint8List imageBytes) async {
    // Example using Google Cloud Vision API
    // NOTE: In production, store API key securely
    const apiKey = 'YOUR_API_KEY'; // Should come from environment
    const apiUrl = 'https://vision.googleapis.com/v1/images:annotate?key=$apiKey';

    final base64Image = base64Encode(imageBytes);
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'requests': [
          {
            'image': {'content': base64Image},
            'features': [
              {'type': 'TEXT_DETECTION', 'maxResults': 1}
            ],
          }
        ],
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final text = json['responses'][0]['fullTextAnnotation']['text'] ?? '';
      return OcrResult(
        text: text,
        confidence: 0.9,
        blocks: [],
      );
    } else {
      throw Exception('OCR API failed: ${response.statusCode}');
    }
  }
}

/// Web-specific receipt parser
class WebReceiptParser {
  final OcrResult ocrResult;
  final String text;

  WebReceiptParser(this.ocrResult) : text = ocrResult.text.toUpperCase();

  String? extractMerchantName() {
    final lines = ocrResult.text.split('\n');
    if (lines.isEmpty) return null;

    for (final line in lines.take(3)) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty &&
          trimmed.length > 3 &&
          !trimmed.contains(RegExp(r'\d{3,}'))) {
        return trimmed;
      }
    }
    return null;
  }

  DateTime? extractDate() {
    final datePattern = RegExp(r'DATE:\s*(\S+)');
    final match = datePattern.firstMatch(text);
    if (match != null) {
      try {
        // For simplicity, return current date
        // In production, parse the actual date string
        return DateTime.now();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  double? extractTotalAmount() {
    final totalPattern = RegExp(r'TOTAL:\s*\$?(\d+\.\d{2})');
    final match = totalPattern.firstMatch(text);
    if (match != null) {
      final amountStr = match.group(1);
      if (amountStr != null) {
        return double.tryParse(amountStr);
      }
    }
    return null;
  }

  double? extractTaxAmount() {
    final taxPattern = RegExp(r'TAX.*:\s*\$?(\d+\.\d{2})');
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
    final tipPattern = RegExp(r'TIP:\s*\$?(\d+\.\d{2})');
    final match = tipPattern.firstMatch(text);
    if (match != null) {
      final amountStr = match.group(1);
      if (amountStr != null) {
        return double.tryParse(amountStr);
      }
    }
    return null;
  }

  String? extractPaymentMethod() {
    if (text.contains('CREDIT CARD')) return 'Credit Card';
    if (text.contains('DEBIT CARD')) return 'Debit Card';
    if (text.contains('CASH')) return 'Cash';
    if (text.contains('VISA')) return 'Visa';
    if (text.contains('MASTERCARD')) return 'Mastercard';
    return null;
  }

  List<ReceiptLineItem> extractLineItems() {
    final items = <ReceiptLineItem>[];
    final lines = ocrResult.text.split('\n');

    // Simple pattern for items with prices
    final itemPattern = RegExp(r'^([A-Z][A-Z\s&]+)\s+(\d+\.\d{2})$');

    for (final line in lines) {
      final trimmed = line.trim();
      final match = itemPattern.firstMatch(trimmed);
      if (match != null) {
        final description = match.group(1)!.trim();
        final price = double.tryParse(match.group(2)!);

        // Filter out totals and tax lines
        if (!description.contains('TOTAL') &&
            !description.contains('TAX') &&
            !description.contains('SUBTOTAL')) {
          items.add(ReceiptLineItem(
            description: description,
            totalPrice: price,
          ));
        }
      }
    }

    return items;
  }
}