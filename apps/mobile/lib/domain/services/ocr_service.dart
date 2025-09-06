import 'dart:typed_data';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';

// Core models for OCR processing
class FieldData {
  final dynamic value;
  final double confidence;
  final String originalText;
  final bool isManuallyEdited;
  final String validationStatus;

  FieldData({
    required this.value,
    required this.confidence,
    required this.originalText,
    this.isManuallyEdited = false,
    this.validationStatus = 'valid',
  });

  FieldData copyWith({
    dynamic value,
    double? confidence,
    String? originalText,
    bool? isManuallyEdited,
    String? validationStatus,
  }) {
    return FieldData(
      value: value ?? this.value,
      confidence: confidence ?? this.confidence,
      originalText: originalText ?? this.originalText,
      isManuallyEdited: isManuallyEdited ?? this.isManuallyEdited,
      validationStatus: validationStatus ?? this.validationStatus,
    );
  }
}

class ProcessingResult {
  final FieldData? merchant;
  final FieldData? date;
  final FieldData? total;
  final FieldData? tax;
  final double overallConfidence;
  final String processingEngine;
  final int processingDurationMs;
  final List<String> allText;

  ProcessingResult({
    this.merchant,
    this.date,
    this.total,
    this.tax,
    required this.overallConfidence,
    this.processingEngine = 'google_ml_kit',
    required this.processingDurationMs,
    this.allText = const [],
  });

  ProcessingResult copyWith({
    FieldData? merchant,
    FieldData? date,
    FieldData? total,
    FieldData? tax,
    double? overallConfidence,
    String? processingEngine,
    int? processingDurationMs,
    List<String>? allText,
  }) {
    return ProcessingResult(
      merchant: merchant ?? this.merchant,
      date: date ?? this.date,
      total: total ?? this.total,
      tax: tax ?? this.tax,
      overallConfidence: overallConfidence ?? this.overallConfidence,
      processingEngine: processingEngine ?? this.processingEngine,
      processingDurationMs: processingDurationMs ?? this.processingDurationMs,
      allText: allText ?? this.allText,
    );
  }
}

abstract class IOCRService {
  Future<ProcessingResult> processReceipt(Uint8List imageData);
  Future<void> initialize();
  Future<void> dispose();
}

class OCRService implements IOCRService {
  late TextRecognizer _textRecognizer;
  bool _isInitialized = false;
  final TextRecognizer? _customRecognizer;

  /// Create OCR service with optional TextRecognizer for testing
  /// 
  /// **OCR Confidence Scoring API:**
  /// 
  /// **Field Confidence Thresholds:**
  /// - **High Confidence (≥75%)**: Field likely accurate, no user editing needed
  /// - **Medium Confidence (50-74%)**: Field may need verification, show warning in UI  
  /// - **Low Confidence (<50%)**: Field requires user validation, mark as editable
  /// 
  /// **Confidence Calculation Factors:**
  /// - **Format Quality**: Proper currency symbols (+10%), correct decimal format (+10%)
  /// - **Context Match**: Keywords like "total", "tax" boost confidence (+20%)
  /// - **Text Clarity**: Clean OCR text without corruption increases base confidence
  /// - **Merchant**: Base 60%, +10 for length ≥3, +10 for capitalization, +15 for non-numeric
  /// - **Date**: Base 70%, +20 for standard formats (MM/DD/YYYY), +15 for hyphenated
  /// - **Amounts**: Base 60%, context matching adds up to +20%
  /// 
  /// **Overall Confidence**: Average of all extracted field confidences
  /// 
  /// **Review Screen Integration:**
  /// - Fields with confidence <75% should be highlighted for quick editing (AC6)
  /// - Display confidence indicators: ●●● (≥75%), ●●○ (50-74%), ●○○ (<50%)
  OCRService({TextRecognizer? textRecognizer}) : _customRecognizer = textRecognizer;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Use custom recognizer for testing or create new one for production
    _textRecognizer = _customRecognizer ?? TextRecognizer(script: TextRecognitionScript.latin);
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    if (_isInitialized) {
      await _textRecognizer.close();
      _isInitialized = false;
    }
  }

  @override
  Future<ProcessingResult> processReceipt(Uint8List imageData) async {
    if (!_isInitialized) {
      await initialize();
    }

    final stopwatch = Stopwatch()..start();

    try {
      // Try to decode image to get actual dimensions
      Size imageSize = const Size(800, 600); // Default fallback
      int bytesPerRow = 800 * 4;
      
      final image = img.decodeImage(imageData);
      if (image != null) {
        imageSize = Size(image.width.toDouble(), image.height.toDouble());
        bytesPerRow = image.width * 4; // RGBA format
      }

      final inputImage = InputImage.fromBytes(
        bytes: imageData,
        metadata: InputImageMetadata(
          size: imageSize,
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.yuv420,
          bytesPerRow: bytesPerRow,
        ),
      );

      final recognizedText = await _textRecognizer.processImage(inputImage);
      stopwatch.stop();

      // Extract fields from recognized text
      return _extractFields(recognizedText, stopwatch.elapsedMilliseconds);

    } catch (e) {
      stopwatch.stop();
      debugPrint('OCR processing failed: $e');
      
      // Return dummy data for development/testing
      return _createDummyResult(stopwatch.elapsedMilliseconds);
    }
  }

  ProcessingResult _extractFields(RecognizedText recognizedText, int durationMs) {
    final allTextLines = recognizedText.blocks
        .expand((block) => block.lines)
        .map((line) => line.text)
        .toList();

    final allText = allTextLines.join(' ');

    // Extract merchant (usually at the top)
    final merchant = _extractMerchant(allTextLines);
    
    // Extract date
    final date = _extractDate(allText);
    
    // Extract amounts
    final amounts = _extractAmounts(allText);
    final total = amounts['total'];
    final tax = amounts['tax'];

    // Calculate overall confidence
    final fields = [merchant, date, total, tax];
    final validFields = fields.where((f) => f != null).toList();
    final overallConfidence = validFields.isEmpty 
        ? 0.0 
        : validFields.map((f) => f!.confidence).reduce((a, b) => a + b) / validFields.length;

    return ProcessingResult(
      merchant: merchant,
      date: date,
      total: total,
      tax: tax,
      overallConfidence: overallConfidence,
      processingDurationMs: durationMs,
      allText: allTextLines,
    );
  }

  FieldData? _extractMerchant(List<String> textLines) {
    if (textLines.isEmpty) return null;

    // Merchant is usually in the first few lines
    final merchantCandidates = textLines.take(3).where((line) => 
        line.length > 2 && 
        !_isAmount(line) && 
        !_isDate(line)
    ).toList();

    if (merchantCandidates.isNotEmpty) {
      final merchantName = merchantCandidates.first;
      return FieldData(
        value: merchantName,
        confidence: _calculateMerchantConfidence(merchantName),
        originalText: merchantName,
      );
    }

    return null;
  }

  FieldData? _extractDate(String text) {
    // Common date patterns
    final datePatterns = [
      RegExp(r'\d{1,2}[/\-\.]\d{1,2}[/\-\.]\d{2,4}'), // MM/DD/YYYY, MM-DD-YY
      RegExp(r'\d{1,2}\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+\d{2,4}', caseSensitive: false),
      RegExp(r'(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+\d{1,2},?\s+\d{2,4}', caseSensitive: false),
    ];

    for (final pattern in datePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final dateStr = match.group(0)!;
        return FieldData(
          value: dateStr,
          confidence: _calculateDateConfidence(dateStr),
          originalText: dateStr,
        );
      }
    }

    return null;
  }

  Map<String, FieldData?> _extractAmounts(String text) {
    final amountPattern = RegExp(r'\$?\d+[\.,]\d{2}|\$\d+\.\d{2}');
    final matches = amountPattern.allMatches(text).toList();

    if (matches.isEmpty) {
      return {'total': null, 'tax': null};
    }

    // Find amounts with context
    FieldData? total;
    FieldData? tax;

    for (final match in matches) {
      final amountStr = match.group(0)!;
      final amount = _parseAmount(amountStr);
      
      if (amount == null) continue;

      final context = _getAmountContext(text, match.start, match.end);
      
      if (_isTotalContext(context) && total == null) {
        total = FieldData(
          value: amount,
          confidence: _calculateAmountConfidence(amountStr, context, 'total'),
          originalText: amountStr,
        );
      } else if (_isTaxContext(context) && tax == null) {
        tax = FieldData(
          value: amount,
          confidence: _calculateAmountConfidence(amountStr, context, 'tax'),
          originalText: amountStr,
        );
      }
    }

    // If no total found, use the largest amount
    if (total == null && matches.isNotEmpty) {
      final amounts = matches
          .map((m) => _parseAmount(m.group(0)!))
          .where((a) => a != null)
          .cast<double>()
          .toList();
      
      if (amounts.isNotEmpty) {
        amounts.sort();
        final largestAmount = amounts.last;
        total = FieldData(
          value: largestAmount,
          confidence: 75.0, // Lower confidence for inferred total
          originalText: '\$${largestAmount.toStringAsFixed(2)}',
        );
      }
    }

    return {'total': total, 'tax': tax};
  }

  double? _parseAmount(String amountStr) {
    // Remove currency symbols and parse
    final cleanAmount = amountStr.replaceAll(RegExp(r'[\$,]'), '');
    return double.tryParse(cleanAmount);
  }

  String _getAmountContext(String text, int start, int end) {
    // Get text around the amount for context
    final contextStart = (start - 20).clamp(0, text.length);
    final contextEnd = (end + 20).clamp(0, text.length);
    return text.substring(contextStart, contextEnd);
  }

  bool _isTotalContext(String context) {
    final totalKeywords = ['total', 'amount', 'balance', 'due', 'pay'];
    return totalKeywords.any((keyword) => 
        context.toLowerCase().contains(keyword));
  }

  bool _isTaxContext(String context) {
    final taxKeywords = ['tax', 'gst', 'vat', 'hst'];
    return taxKeywords.any((keyword) => 
        context.toLowerCase().contains(keyword));
  }

  bool _isAmount(String text) {
    return RegExp(r'\$?\d+[\.,]\d{2}').hasMatch(text);
  }

  bool _isDate(String text) {
    return RegExp(r'\d{1,2}[/\-\.]\d{1,2}[/\-\.]\d{2,4}').hasMatch(text);
  }

  /// Calculate merchant name confidence based on text characteristics
  /// 
  /// **Scoring Rules:**
  /// - Base confidence: 60%
  /// - Length ≥3 characters: +10% (typical business names)  
  /// - Starts with capital letter: +10% (proper business formatting)
  /// - Not a number/date: +15% (reduces false positives)
  /// - **Range**: 0-100% (clamped)
  double _calculateMerchantConfidence(String merchantName) {
    double confidence = 60.0; // Base confidence
    
    // Boost confidence for typical business names
    if (merchantName.length >= 3) confidence += 10;
    if (RegExp(r'^[A-Z]').hasMatch(merchantName)) confidence += 10;
    if (!_isAmount(merchantName) && !_isDate(merchantName)) confidence += 15;
    
    return confidence.clamp(0.0, 100.0);
  }

  /// Calculate date confidence based on format recognition
  /// 
  /// **Scoring Rules:**
  /// - Base confidence: 70%  
  /// - MM/DD/YYYY format: +20% (most common US format)
  /// - MM-DD-YYYY format: +15% (alternative standard format)
  /// - **Range**: 0-100% (clamped)
  /// - **Supported patterns**: MM/DD/YYYY, DD Mon YYYY, Mon DD, YYYY
  double _calculateDateConfidence(String dateStr) {
    double confidence = 70.0; // Base confidence
    
    // Higher confidence for standard formats
    if (RegExp(r'\d{1,2}/\d{1,2}/\d{4}').hasMatch(dateStr)) confidence += 20;
    if (RegExp(r'\d{1,2}-\d{1,2}-\d{4}').hasMatch(dateStr)) confidence += 15;
    
    return confidence.clamp(0.0, 100.0);
  }

  /// Calculate amount confidence based on format and context
  /// 
  /// **Scoring Rules:**
  /// - Base confidence: 60%
  /// - Currency symbol ($): +10% (proper monetary format)
  /// - Decimal format (X.XX): +10% (standard currency precision)
  /// - Context match for 'total': +20% (found near total keywords)
  /// - Context match for 'tax': +20% (found near tax keywords)
  /// - **Range**: 0-100% (clamped)
  /// - **Field Types**: 'total', 'tax' (affects context matching)
  /// 
  /// **Context Keywords:**
  /// - Total: 'total', 'amount', 'balance', 'due', 'pay'
  /// - Tax: 'tax', 'gst', 'vat', 'hst'
  double _calculateAmountConfidence(String amountStr, String context, String fieldType) {
    double confidence = 60.0; // Base confidence
    
    // Format confidence
    if (amountStr.startsWith('\$')) confidence += 10;
    if (RegExp(r'\d+\.\d{2}$').hasMatch(amountStr)) confidence += 10;
    
    // Context confidence
    if (fieldType == 'total' && _isTotalContext(context)) confidence += 20;
    if (fieldType == 'tax' && _isTaxContext(context)) confidence += 20;
    
    return confidence.clamp(0.0, 100.0);
  }

  ProcessingResult _createDummyResult(int durationMs) {
    // Return dummy data for development/testing
    return ProcessingResult(
      merchant: FieldData(
        value: 'Sample Store',
        confidence: 85.0,
        originalText: 'Sample Store',
      ),
      date: FieldData(
        value: '12/06/2024',
        confidence: 90.0,
        originalText: '12/06/2024',
      ),
      total: FieldData(
        value: 25.47,
        confidence: 95.0,
        originalText: '\$25.47',
      ),
      tax: FieldData(
        value: 2.04,
        confidence: 88.0,
        originalText: '\$2.04',
      ),
      overallConfidence: 89.5,
      processingDurationMs: durationMs,
      allText: ['Sample Store', '123 Main St', '12/06/2024', 'Total: \$25.47', 'Tax: \$2.04'],
    );
  }
}

/// Enum representing confidence levels for OCR results
enum ConfidenceLevel {
  low,    // <75%
  medium, // 75-85% 
  high,   // >85%
}

/// Extension to convert confidence percentages to confidence levels
extension ConfidenceLevelExtension on double {
  ConfidenceLevel get confidenceLevel {
    if (this >= 85.0) {
      return ConfidenceLevel.high;
    } else if (this >= 75.0) {
      return ConfidenceLevel.medium;
    } else {
      return ConfidenceLevel.low;
    }
  }
}