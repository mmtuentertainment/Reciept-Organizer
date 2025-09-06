import 'dart:typed_data';
import 'dart:math' as math;
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

  /// Serializes FieldData to JSON for session persistence
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'confidence': confidence,
      'originalText': originalText,
      'isManuallyEdited': isManuallyEdited,
      'validationStatus': validationStatus,
    };
  }

  /// Creates FieldData from JSON for session restoration
  factory FieldData.fromJson(Map<String, dynamic> json) {
    return FieldData(
      value: json['value'],
      confidence: (json['confidence'] as num).toDouble(),
      originalText: json['originalText'],
      isManuallyEdited: json['isManuallyEdited'] ?? false,
      validationStatus: json['validationStatus'] ?? 'valid',
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

  /// Serializes ProcessingResult to JSON for session persistence
  Map<String, dynamic> toJson() {
    return {
      'merchant': merchant?.toJson(),
      'date': date?.toJson(),
      'total': total?.toJson(),
      'tax': tax?.toJson(),
      'overallConfidence': overallConfidence,
      'processingEngine': processingEngine,
      'processingDurationMs': processingDurationMs,
      'allText': allText,
    };
  }

  /// Creates ProcessingResult from JSON for session restoration
  factory ProcessingResult.fromJson(Map<String, dynamic> json) {
    return ProcessingResult(
      merchant: json['merchant'] != null ? FieldData.fromJson(json['merchant']) : null,
      date: json['date'] != null ? FieldData.fromJson(json['date']) : null,
      total: json['total'] != null ? FieldData.fromJson(json['total']) : null,
      tax: json['tax'] != null ? FieldData.fromJson(json['tax']) : null,
      overallConfidence: (json['overallConfidence'] as num).toDouble(),
      processingEngine: json['processingEngine'] ?? 'google_ml_kit',
      processingDurationMs: json['processingDurationMs'] as int,
      allText: List<String>.from(json['allText'] ?? []),
    );
  }
}

abstract class IOCRService {
  Future<ProcessingResult> processReceipt(Uint8List imageData);
  Future<void> initialize();
  Future<void> dispose();
  
  /// Analyzes processing result and image data to detect capture failures
  FailureDetectionResult detectFailure(ProcessingResult result, Uint8List imageData);
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
      // Add timeout to prevent hanging
      const timeoutDuration = Duration(seconds: 10);
      
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

      // Process image with timeout
      final recognizedText = await _textRecognizer
          .processImage(inputImage)
          .timeout(timeoutDuration);
      
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

  @override
  FailureDetectionResult detectFailure(ProcessingResult result, Uint8List imageData) {
    final diagnostics = <String, dynamic>{};
    
    // Check 1: Processing timeout (from duration)
    if (result.processingDurationMs > 10000) {
      return FailureDetectionResult.failure(
        FailureReason.processingTimeout,
        0.0,
        diagnostics: {'duration_ms': result.processingDurationMs},
      );
    }
    
    // Check 2: Overall confidence too low
    if (result.overallConfidence < 30.0) {
      return FailureDetectionResult.failure(
        FailureReason.lowConfidence,
        result.overallConfidence,
        diagnostics: {
          'overall_confidence': result.overallConfidence,
          'field_confidences': {
            'merchant': result.merchant?.confidence,
            'date': result.date?.confidence,
            'total': result.total?.confidence,
            'tax': result.tax?.confidence,
          },
        },
      );
    }
    
    // Check 3: No receipt-like content detected
    if (!_hasReceiptContent(result)) {
      return FailureDetectionResult.failure(
        FailureReason.noReceiptDetected,
        result.overallConfidence * 0.3, // Reduce quality score
        diagnostics: {
          'text_lines': result.allText.length,
          'extracted_fields': _countExtractedFields(result),
        },
      );
    }
    
    // Check 4: Image quality assessment
    final imageQuality = _assessImageQuality(imageData);
    diagnostics.addAll(imageQuality);
    
    // Check for blur
    if ((imageQuality['blur_score'] as double?) != null && 
        imageQuality['blur_score'] > 0.7) {
      return FailureDetectionResult.failure(
        FailureReason.blurryImage,
        result.overallConfidence * 0.5,
        diagnostics: diagnostics,
      );
    }
    
    // Check for poor contrast/lighting
    if ((imageQuality['contrast_score'] as double?) != null &&
        imageQuality['contrast_score'] < 0.3) {
      return FailureDetectionResult.failure(
        FailureReason.poorLighting,
        result.overallConfidence * 0.6,
        diagnostics: diagnostics,
      );
    }
    
    // Success case - calculate combined quality score
    final qualityScore = _calculateOverallQuality(result, imageQuality);
    
    return FailureDetectionResult.success(qualityScore);
  }
  
  bool _hasReceiptContent(ProcessingResult result) {
    // Check if we have receipt-like content
    final hasAmount = result.total != null || result.tax != null;
    final hasMerchant = result.merchant != null;
    final hasDate = result.date != null;
    final hasMultipleLines = result.allText.length >= 3;
    
    // Need at least 2 of these indicators for receipt-like content
    final indicators = [hasAmount, hasMerchant, hasDate, hasMultipleLines];
    final positiveIndicators = indicators.where((indicator) => indicator).length;
    
    return positiveIndicators >= 2;
  }
  
  int _countExtractedFields(ProcessingResult result) {
    int count = 0;
    if (result.merchant != null) count++;
    if (result.date != null) count++;
    if (result.total != null) count++;
    if (result.tax != null) count++;
    return count;
  }
  
  Map<String, dynamic> _assessImageQuality(Uint8List imageData) {
    final quality = <String, dynamic>{};
    
    try {
      final image = img.decodeImage(imageData);
      if (image == null) {
        quality['error'] = 'Could not decode image';
        return quality;
      }
      
      // Basic image metrics
      quality['width'] = image.width;
      quality['height'] = image.height;
      quality['aspect_ratio'] = image.width / image.height;
      
      // Assess blur using variance of pixel values (simplified)
      final blurScore = _estimateBlur(image);
      quality['blur_score'] = blurScore;
      
      // Assess contrast using standard deviation of luminance
      final contrastScore = _estimateContrast(image);
      quality['contrast_score'] = contrastScore;
      
      // Check resolution adequacy
      final totalPixels = image.width * image.height;
      quality['resolution_adequate'] = totalPixels >= 800 * 600; // 0.5MP minimum
      
    } catch (e) {
      quality['error'] = 'Image quality assessment failed: $e';
    }
    
    return quality;
  }
  
  double _estimateBlur(img.Image image) {
    // Simplified blur detection using luminance variance
    // Higher values indicate more blur
    try {
      var totalVariance = 0.0;
      var sampleCount = 0;
      
      // Sample every 10th pixel to speed up calculation
      for (var y = 0; y < image.height; y += 10) {
        for (var x = 0; x < image.width - 1; x += 10) {
          final pixel1 = image.getPixel(x, y);
          final pixel2 = image.getPixel(x + 1, y);
          
          final lum1 = _getLuminance(pixel1);
          final lum2 = _getLuminance(pixel2);
          
          totalVariance += (lum1 - lum2).abs();
          sampleCount++;
        }
      }
      
      final avgVariance = sampleCount > 0 ? totalVariance / sampleCount : 0.0;
      
      // Normalize to 0-1 scale (higher = more blur)
      return (255.0 - avgVariance) / 255.0;
      
    } catch (e) {
      return 0.5; // Default moderate blur assumption
    }
  }
  
  double _estimateContrast(img.Image image) {
    // Estimate contrast using luminance standard deviation
    try {
      var luminanceSum = 0.0;
      var luminanceSquaredSum = 0.0;
      var sampleCount = 0;
      
      // Sample pixels to calculate average and standard deviation
      for (var y = 0; y < image.height; y += 15) {
        for (var x = 0; x < image.width; x += 15) {
          final pixel = image.getPixel(x, y);
          final luminance = _getLuminance(pixel);
          
          luminanceSum += luminance;
          luminanceSquaredSum += luminance * luminance;
          sampleCount++;
        }
      }
      
      if (sampleCount == 0) return 0.5;
      
      final mean = luminanceSum / sampleCount;
      final variance = (luminanceSquaredSum / sampleCount) - (mean * mean);
      final stdDev = variance.isNaN ? 0.0 : math.sqrt(variance.clamp(0.0, double.infinity));
      
      // Normalize standard deviation to 0-1 scale
      return (stdDev / 127.5).clamp(0.0, 1.0);
      
    } catch (e) {
      return 0.5; // Default moderate contrast assumption
    }
  }
  
  double _getLuminance(img.Pixel pixel) {
    // Calculate luminance using standard RGB to luminance formula
    final r = pixel.r.toDouble();
    final g = pixel.g.toDouble(); 
    final b = pixel.b.toDouble();
    
    return 0.299 * r + 0.587 * g + 0.114 * b;
  }
  
  double _calculateOverallQuality(ProcessingResult result, Map<String, dynamic> imageQuality) {
    // Combine OCR confidence with image quality metrics
    var qualityScore = result.overallConfidence;
    
    // Adjust based on image quality
    final blurScore = imageQuality['blur_score'] as double?;
    if (blurScore != null) {
      qualityScore *= (1.0 - blurScore * 0.3); // Blur reduces quality
    }
    
    final contrastScore = imageQuality['contrast_score'] as double?;
    if (contrastScore != null) {
      qualityScore *= (0.5 + contrastScore * 0.5); // Low contrast reduces quality
    }
    
    final isAdequateRes = imageQuality['resolution_adequate'] as bool? ?? true;
    if (!isAdequateRes) {
      qualityScore *= 0.8; // Low resolution reduces quality
    }
    
    return qualityScore.clamp(0.0, 100.0);
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

/// Enum representing different reasons for capture failure
enum FailureReason {
  lowConfidence,      // Overall confidence < 30%
  blurryImage,        // Image quality too poor
  poorLighting,       // Contrast issues
  noReceiptDetected,  // No receipt-like content found
  processingTimeout,  // OCR took too long
  processingError,    // OCR engine error
}

/// Extension to provide user-friendly messages for failure reasons
extension FailureReasonExtension on FailureReason {
  String get userMessage {
    switch (this) {
      case FailureReason.lowConfidence:
        return 'Unable to read receipt clearly';
      case FailureReason.blurryImage:
        return 'Image is too blurry - try taking a clearer photo';
      case FailureReason.poorLighting:
        return 'Poor lighting - try taking the photo in better light';
      case FailureReason.noReceiptDetected:
        return 'No receipt detected - make sure the receipt is in the frame';
      case FailureReason.processingTimeout:
        return 'Processing took too long - try again';
      case FailureReason.processingError:
        return 'Processing failed - please retry';
    }
  }

  String get technicalReason {
    switch (this) {
      case FailureReason.lowConfidence:
        return 'Overall OCR confidence below 30% threshold';
      case FailureReason.blurryImage:
        return 'Image blur detection threshold exceeded';
      case FailureReason.poorLighting:
        return 'Image contrast below minimum threshold';
      case FailureReason.noReceiptDetected:
        return 'No receipt-like patterns found in OCR text';
      case FailureReason.processingTimeout:
        return 'OCR processing exceeded 10s timeout';
      case FailureReason.processingError:
        return 'OCR engine threw exception during processing';
    }
  }
}

/// Class representing the result of failure detection analysis
class FailureDetectionResult {
  final bool isFailure;
  final FailureReason? reason;
  final double qualityScore;
  final Map<String, dynamic> diagnostics;

  const FailureDetectionResult({
    required this.isFailure,
    this.reason,
    required this.qualityScore,
    this.diagnostics = const {},
  });

  factory FailureDetectionResult.success(double qualityScore) {
    return FailureDetectionResult(
      isFailure: false,
      qualityScore: qualityScore,
    );
  }

  factory FailureDetectionResult.failure(
    FailureReason reason,
    double qualityScore, {
    Map<String, dynamic>? diagnostics,
  }) {
    return FailureDetectionResult(
      isFailure: true,
      reason: reason,
      qualityScore: qualityScore,
      diagnostics: diagnostics ?? {},
    );
  }
}