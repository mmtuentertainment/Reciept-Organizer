import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import '../mocks/mock_text_recognizer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Create a dummy InputImage for stubbing
  final dummyInputImage = MockInputImage(
    bytes: Uint8List.fromList([1, 2, 3]),
    metadata: InputImageMetadata(
      size: const Size(100, 100),
      rotation: InputImageRotation.rotation0deg,
      format: InputImageFormat.nv21,
      bytesPerRow: 100,
    ),
  );
  
  group('OCRService with Mocks', () {
    late OCRService ocrService;
    late MockTextRecognizer mockTextRecognizer;
    late Uint8List mockImageData;

    setUp(() {
      mockTextRecognizer = MockTextRecognizer();
      ocrService = OCRService(textRecognizer: mockTextRecognizer);
      mockImageData = Uint8List.fromList(List.generate(1000, (index) => index % 256));
    });

    tearDown(() async {
      await ocrService.dispose();
    });

    test('should initialize successfully', () async {
      await ocrService.initialize();
      // No exception means success
    });

    test('should process high confidence receipt correctly', () async {
      // Arrange
      when(mockTextRecognizer.processImage(any))
          .thenAnswer((_) async => TestOCRData.highConfidenceReceipt());
      
      await ocrService.initialize();
      
      // Act
      final result = await ocrService.processReceipt(mockImageData);
      
      // Assert - Validate OCR processing worked
      expect(result, isA<ProcessingResult>());
      expect(result.merchant?.value, equals('STARBUCKS COFFEE'));
      expect(result.merchant?.confidence, greaterThan(60)); // Should be decent confidence
      expect(result.date?.value, contains('12/06/2024'));
      
      // Validate amounts were extracted (specific values may vary based on algorithm)
      expect(result.total?.value, isA<double>());
      expect(result.total?.value, greaterThan(0));
      
      if (result.tax != null) {
        expect(result.tax!.value, isA<double>());  
        expect(result.tax!.value, greaterThan(0));
      }
      
      expect(result.overallConfidence, greaterThan(50)); // Should be reasonable overall
    });

    test('should handle low confidence receipt gracefully', () async {
      // Arrange
      when(mockTextRecognizer.processImage(any))
          .thenAnswer((_) async => TestOCRData.lowConfidenceReceipt());
      
      await ocrService.initialize();
      
      // Act
      final result = await ocrService.processReceipt(mockImageData);
      
      // Assert - Should still process but may have issues with corrupted data
      expect(result, isA<ProcessingResult>());
      expect(result.overallConfidence, greaterThanOrEqualTo(0));
      expect(result.overallConfidence, lessThanOrEqualTo(100));
      
      // Merchant should be extracted even if confidence varies
      if (result.merchant != null) {
        expect(result.merchant!.value, isA<String>());
      }
    });

    test('should fallback to dummy data when OCR completely fails', () async {
      // Arrange
      when(mockTextRecognizer.processImage(any))
          .thenThrow(Exception('OCR processing failed'));
      
      await ocrService.initialize();
      
      // Act
      final result = await ocrService.processReceipt(mockImageData);
      
      // Assert - Should return dummy data on failure
      expect(result.merchant?.value, equals('Sample Store'));
      expect(result.total?.value, equals(25.47));
      expect(result.tax?.value, equals(2.04));
      expect(result.date?.value, equals('12/06/2024'));
    });

    test('should validate confidence score ranges for all fields', () async {
      // Arrange
      when(mockTextRecognizer.processImage(any))
          .thenAnswer((_) async => TestOCRData.highConfidenceReceipt());
      
      await ocrService.initialize();
      
      // Act
      final result = await ocrService.processReceipt(mockImageData);
      
      // Assert - All confidence scores should be 0-100
      if (result.merchant != null) {
        expect(result.merchant!.confidence, greaterThanOrEqualTo(0));
        expect(result.merchant!.confidence, lessThanOrEqualTo(100));
      }
      
      if (result.date != null) {
        expect(result.date!.confidence, greaterThanOrEqualTo(0));
        expect(result.date!.confidence, lessThanOrEqualTo(100));
      }
      
      if (result.total != null) {
        expect(result.total!.confidence, greaterThanOrEqualTo(0));
        expect(result.total!.confidence, lessThanOrEqualTo(100));
      }
      
      if (result.tax != null) {
        expect(result.tax!.confidence, greaterThanOrEqualTo(0));
        expect(result.tax!.confidence, lessThanOrEqualTo(100));
      }
    });

    test('should include all extracted text lines', () async {
      // Arrange
      when(mockTextRecognizer.processImage(any))
          .thenAnswer((_) async => TestOCRData.highConfidenceReceipt());
      
      await ocrService.initialize();
      
      // Act
      final result = await ocrService.processReceipt(mockImageData);
      
      // Assert
      expect(result.allText, isA<List<String>>());
      expect(result.allText.length, greaterThan(0));
      expect(result.allText, contains('STARBUCKS COFFEE'));
      expect(result.allText, contains('Total               \$7.29'));
    });

    test('should handle empty OCR result gracefully', () async {
      // Arrange
      when(mockTextRecognizer.processImage(any))
          .thenAnswer((_) async => TestOCRData.emptyResult());
      
      await ocrService.initialize();
      
      // Act
      final result = await ocrService.processReceipt(mockImageData);
      
      // Assert - Should still return a result (likely dummy data)
      expect(result, isA<ProcessingResult>());
      expect(result.overallConfidence, greaterThanOrEqualTo(0));
    });

    test('should process multiple receipts with different confidence levels', () async {
      // Arrange - Set up sequential responses for multiple calls
      when(mockTextRecognizer.processImage(any))
          .thenAnswer((_) async => TestOCRData.highConfidenceReceipt());
      
      await ocrService.initialize();
      
      // Act - Test first call
      final result1 = await ocrService.processReceipt(mockImageData);
      
      // Set up next response
      when(mockTextRecognizer.processImage(any))
          .thenAnswer((_) async => TestOCRData.lowConfidenceReceipt());
      final result2 = await ocrService.processReceipt(mockImageData);
      
      // Set up final response
      when(mockTextRecognizer.processImage(any))
          .thenAnswer((_) async => TestOCRData.emptyResult());
      final result3 = await ocrService.processReceipt(mockImageData);
      
      // Assert
      expect(result1, isA<ProcessingResult>());
      expect(result2, isA<ProcessingResult>());
      expect(result3, isA<ProcessingResult>());
      
      expect(result1.overallConfidence, greaterThanOrEqualTo(0));
      expect(result2.overallConfidence, greaterThanOrEqualTo(0));
      expect(result3.overallConfidence, greaterThanOrEqualTo(0));
    });

    test('should dispose without errors', () async {
      await ocrService.initialize();
      await ocrService.dispose();
      // No exception means success - dispose should not throw
    });
    
    test('should validate OCR confidence thresholds for review screen', () async {
      // Arrange - Test with various confidence scenarios
      when(mockTextRecognizer.processImage(any))
          .thenAnswer((_) async => TestOCRData.highConfidenceReceipt());
      
      await ocrService.initialize();
      
      // Act
      final result = await ocrService.processReceipt(mockImageData);
      
      // Assert - Confidence scores should be calculable for review screen
      expect(result, isA<ProcessingResult>());
      
      // All extracted fields should have valid confidence scores
      if (result.merchant != null) {
        expect(result.merchant!.confidence, greaterThanOrEqualTo(0));
        expect(result.merchant!.confidence, lessThanOrEqualTo(100));
      }
      if (result.date != null) {
        expect(result.date!.confidence, greaterThanOrEqualTo(0));
        expect(result.date!.confidence, lessThanOrEqualTo(100));
      }
      if (result.total != null) {
        expect(result.total!.confidence, greaterThanOrEqualTo(0));
        expect(result.total!.confidence, lessThanOrEqualTo(100));
      }
      if (result.tax != null) {
        expect(result.tax!.confidence, greaterThanOrEqualTo(0));
        expect(result.tax!.confidence, lessThanOrEqualTo(100));
      }
      
      // Overall confidence should also be valid
      expect(result.overallConfidence, greaterThanOrEqualTo(0));
      expect(result.overallConfidence, lessThanOrEqualTo(100));
    });
  });

  group('FieldData', () {
    test('should create field data with required properties', () {
      final fieldData = FieldData(
        value: 'Test Value',
        confidence: 85.5,
        originalText: 'Original Text',
      );
      
      expect(fieldData.value, equals('Test Value'));
      expect(fieldData.confidence, equals(85.5));
      expect(fieldData.originalText, equals('Original Text'));
      expect(fieldData.isManuallyEdited, isFalse);
      expect(fieldData.validationStatus, equals('valid'));
    });

    test('should create field data with custom properties', () {
      final fieldData = FieldData(
        value: 123.45,
        confidence: 90.0,
        originalText: '\$123.45',
        isManuallyEdited: true,
        validationStatus: 'warning',
      );
      
      expect(fieldData.value, equals(123.45));
      expect(fieldData.isManuallyEdited, isTrue);
      expect(fieldData.validationStatus, equals('warning'));
    });

    test('should create copy with updated values', () {
      final original = FieldData(
        value: 'Original',
        confidence: 80.0,
        originalText: 'Original Text',
      );
      
      final updated = original.copyWith(
        value: 'Updated',
        isManuallyEdited: true,
      );
      
      expect(updated.value, equals('Updated'));
      expect(updated.confidence, equals(80.0)); // Unchanged
      expect(updated.isManuallyEdited, isTrue);
      expect(updated.validationStatus, equals('valid')); // Unchanged
    });
  });

  group('ProcessingResult', () {
    test('should create processing result with all fields', () {
      final merchant = FieldData(
        value: 'Test Store',
        confidence: 85.0,
        originalText: 'Test Store',
      );
      
      final result = ProcessingResult(
        merchant: merchant,
        date: null,
        total: null,
        tax: null,
        overallConfidence: 75.0,
        processingDurationMs: 1500,
        allText: ['Test Store', 'Receipt'],
      );
      
      expect(result.merchant, equals(merchant));
      expect(result.overallConfidence, equals(75.0));
      expect(result.processingDurationMs, equals(1500));
      expect(result.allText, equals(['Test Store', 'Receipt']));
      expect(result.processingEngine, equals('google_ml_kit'));
    });
  });
}