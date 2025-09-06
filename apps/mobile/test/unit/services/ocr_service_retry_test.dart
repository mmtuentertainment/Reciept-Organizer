import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';

import 'ocr_service_retry_test.mocks.dart';

@GenerateMocks([TextRecognizer])
void main() {
  group('OCRService Failure Detection', () {
    late OCRService ocrService;
    late MockTextRecognizer mockTextRecognizer;

    setUp(() {
      mockTextRecognizer = MockTextRecognizer();
      ocrService = OCRService(textRecognizer: mockTextRecognizer);
    });

    tearDown(() async {
      await ocrService.dispose();
    });

    group('detectFailure', () {
      test('should detect failure when overall confidence is below 30%', () {
        // Arrange
        final result = ProcessingResult(
          merchant: FieldData(value: 'Store', confidence: 25.0, originalText: 'Store'),
          date: FieldData(value: '2024-01-01', confidence: 20.0, originalText: '2024-01-01'),
          total: FieldData(value: 10.0, confidence: 15.0, originalText: '\$10.00'),
          overallConfidence: 20.0,
          processingDurationMs: 3000,
          allText: ['Store', '2024-01-01', '\$10.00'],
        );
        final imageData = Uint8List.fromList([1, 2, 3]);

        // Act
        final detection = ocrService.detectFailure(result, imageData);

        // Assert
        expect(detection.isFailure, isTrue);
        expect(detection.reason, equals(FailureReason.lowConfidence));
        expect(detection.qualityScore, equals(20.0));
      });

      test('should detect failure when processing timeout occurs', () {
        // Arrange
        final result = ProcessingResult(
          overallConfidence: 80.0,
          processingDurationMs: 15000, // Over 10s timeout
          allText: ['Test'],
        );
        final imageData = Uint8List.fromList([1, 2, 3]);

        // Act
        final detection = ocrService.detectFailure(result, imageData);

        // Assert
        expect(detection.isFailure, isTrue);
        expect(detection.reason, equals(FailureReason.processingTimeout));
        expect(detection.diagnostics['duration_ms'], equals(15000));
      });

      test('should detect failure when no receipt content is found', () {
        // Arrange - result with no meaningful content
        final result = ProcessingResult(
          overallConfidence: 50.0,
          processingDurationMs: 3000,
          allText: ['Random', 'Text'], // No receipt-like content
        );
        final imageData = Uint8List.fromList([1, 2, 3]);

        // Act
        final detection = ocrService.detectFailure(result, imageData);

        // Assert
        expect(detection.isFailure, isTrue);
        expect(detection.reason, equals(FailureReason.noReceiptDetected));
        expect(detection.qualityScore, equals(15.0)); // 50% * 0.3
      });

      test('should return success when all conditions are met', () {
        // Arrange - good quality result
        final result = ProcessingResult(
          merchant: FieldData(value: 'Costco', confidence: 85.0, originalText: 'Costco'),
          date: FieldData(value: '2024-01-01', confidence: 90.0, originalText: '2024-01-01'),
          total: FieldData(value: 25.47, confidence: 95.0, originalText: '\$25.47'),
          tax: FieldData(value: 2.04, confidence: 88.0, originalText: '\$2.04'),
          overallConfidence: 89.5,
          processingDurationMs: 3000,
          allText: ['Costco', '2024-01-01', 'Total: \$25.47', 'Tax: \$2.04'],
        );
        final imageData = Uint8List.fromList([1, 2, 3]);

        // Act
        final detection = ocrService.detectFailure(result, imageData);

        // Assert
        expect(detection.isFailure, isFalse);
        expect(detection.reason, isNull);
        expect(detection.qualityScore, greaterThan(80.0));
      });
    });

    group('Image Quality Assessment', () {
      test('should assess image quality metrics', () {
        // Arrange
        final result = ProcessingResult(
          overallConfidence: 89.5,
          processingDurationMs: 3000,
          allText: ['Costco', 'Total: \$25.47'],
        );
        
        // Create a simple test image - minimal valid JPEG structure
        final imageData = Uint8List.fromList([
          0xFF, 0xD8, // JPEG SOI
          0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01, // JFIF header
          0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, // Resolution
          0xFF, 0xD9, // JPEG EOI
        ]);

        // Act
        final detection = ocrService.detectFailure(result, imageData);

        // Assert - Should not crash and return reasonable result
        expect(detection.isFailure, isFalse);
        expect(detection.diagnostics, isA<Map<String, dynamic>>());
      });
    });

    group('Receipt Content Detection', () {
      test('should detect receipt content with amounts and merchant', () {
        // Arrange
        final result = ProcessingResult(
          merchant: FieldData(value: 'Walmart', confidence: 85.0, originalText: 'Walmart'),
          total: FieldData(value: 15.99, confidence: 90.0, originalText: '\$15.99'),
          overallConfidence: 87.5,
          processingDurationMs: 2000,
          allText: ['Walmart', 'Item 1', '\$15.99', 'Thank you'],
        );
        final imageData = Uint8List.fromList([1, 2, 3]);

        // Act
        final detection = ocrService.detectFailure(result, imageData);

        // Assert
        expect(detection.isFailure, isFalse);
      });

      test('should detect lack of receipt content', () {
        // Arrange - no receipt-like indicators
        final result = ProcessingResult(
          overallConfidence: 60.0,
          processingDurationMs: 2000,
          allText: ['Random text', 'Not a receipt'], // No amounts, dates, or merchant
        );
        final imageData = Uint8List.fromList([1, 2, 3]);

        // Act
        final detection = ocrService.detectFailure(result, imageData);

        // Assert
        expect(detection.isFailure, isTrue);
        expect(detection.reason, equals(FailureReason.noReceiptDetected));
      });
    });

    group('FailureReason Extensions', () {
      test('should provide user-friendly messages', () {
        expect(FailureReason.blurryImage.userMessage, 
               equals('Image is too blurry - try taking a clearer photo'));
        expect(FailureReason.lowConfidence.userMessage, 
               equals('Unable to read receipt clearly'));
        expect(FailureReason.noReceiptDetected.userMessage, 
               equals('No receipt detected - make sure the receipt is in the frame'));
      });

      test('should provide technical reasons', () {
        expect(FailureReason.processingTimeout.technicalReason, 
               equals('OCR processing exceeded 10s timeout'));
        expect(FailureReason.poorLighting.technicalReason, 
               equals('Image contrast below minimum threshold'));
      });
    });

    group('FailureDetectionResult', () {
      test('should create success result', () {
        // Act
        final result = FailureDetectionResult.success(85.5);

        // Assert
        expect(result.isFailure, isFalse);
        expect(result.reason, isNull);
        expect(result.qualityScore, equals(85.5));
        expect(result.diagnostics, isEmpty);
      });

      test('should create failure result with diagnostics', () {
        // Arrange
        final diagnostics = {'error': 'test error', 'confidence': 25.0};

        // Act
        final result = FailureDetectionResult.failure(
          FailureReason.lowConfidence,
          25.0,
          diagnostics: diagnostics,
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.reason, equals(FailureReason.lowConfidence));
        expect(result.qualityScore, equals(25.0));
        expect(result.diagnostics, equals(diagnostics));
      });
    });
  });
}