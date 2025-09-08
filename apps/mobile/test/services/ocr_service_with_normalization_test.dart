import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:receipt_organizer/domain/services/merchant_normalization_service.dart';
import '../mocks/mock_text_recognizer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('OCRService with Merchant Normalization', () {
    late OCRService ocrService;
    late MockTextRecognizer mockTextRecognizer;
    late MerchantNormalizationService merchantNormalizationService;
    late Uint8List mockImageData;

    setUp(() {
      mockTextRecognizer = MockTextRecognizer();
      merchantNormalizationService = MerchantNormalizationService();
      ocrService = OCRService(
        textRecognizer: mockTextRecognizer,
        merchantNormalizationService: merchantNormalizationService,
        enableMerchantNormalization: true,
      );
      mockImageData = Uint8List.fromList(List.generate(1000, (index) => index % 256));
    });

    tearDown(() async {
      await ocrService.dispose();
      merchantNormalizationService.clearCache();
    });

    test('should normalize merchant names from OCR extraction', () async {
      // Arrange
      when(mockTextRecognizer.processImage(any))
          .thenAnswer((_) async => MerchantTestData.receiptWithNormalizableMerchant());
      
      await ocrService.initialize();
      
      // Act
      final result = await ocrService.processReceipt(mockImageData);
      
      // Assert - Verify normalization happened
      expect(result.merchant?.value, equals('McDonalds')); // Normalized from MCDONALDS #4521
      expect(result.merchant?.originalText, equals('MCDONALDS #4521')); // Original preserved
      expect(result.merchant?.confidence, greaterThan(60));
      
      // Verify other fields are extracted correctly
      expect(result.date?.value, contains('12/06/2024'));
      expect(result.total?.value, equals(14.99));
    });

    test('should not normalize when disabled', () async {
      // Arrange - Create service with normalization disabled
      ocrService = OCRService(
        textRecognizer: mockTextRecognizer,
        merchantNormalizationService: merchantNormalizationService,
        enableMerchantNormalization: false,
      );
      
      when(mockTextRecognizer.processImage(any))
          .thenAnswer((_) async => MerchantTestData.receiptWithNormalizableMerchant());
      
      await ocrService.initialize();
      
      // Act
      final result = await ocrService.processReceipt(mockImageData);
      
      // Assert - Verify normalization did not happen
      expect(result.merchant?.value, equals('MCDONALDS #4521')); // Not normalized
      expect(result.merchant?.originalText, equals('MCDONALDS #4521'));
    });

    test('should handle merchant normalization gracefully when service is null', () async {
      // Arrange - Create service without normalization service
      ocrService = OCRService(
        textRecognizer: mockTextRecognizer,
        merchantNormalizationService: null,
        enableMerchantNormalization: true,
      );
      
      when(mockTextRecognizer.processImage(any))
          .thenAnswer((_) async => MerchantTestData.receiptWithNormalizableMerchant());
      
      await ocrService.initialize();
      
      // Act
      final result = await ocrService.processReceipt(mockImageData);
      
      // Assert - Should still work without normalization
      expect(result.merchant?.value, equals('MCDONALDS #4521'));
    });

    test('should preserve original value when normalization returns same value', () async {
      // Arrange
      when(mockTextRecognizer.processImage(any))
          .thenAnswer((_) async => MerchantTestData.receiptWithCleanMerchant());
      
      await ocrService.initialize();
      
      // Act
      final result = await ocrService.processReceipt(mockImageData);
      
      // Assert - Already clean merchant should not change
      expect(result.merchant?.value, equals('Target'));
      expect(result.merchant?.originalText, equals('Target'));
    });

    test('should normalize various merchant patterns correctly', () async {
      // Test multiple merchant patterns
      final testCases = [
        ('STARBUCKS #12345', 'Starbucks'),
        ('CVS/PHARMACY #567', 'CVS Pharmacy'),
        ('WALMART STORE #1234', 'Walmart'),
        ('7-ELEVEN #890', '7-Eleven'),
        ('MCDONALDS - STORE 456', 'McDonalds'),
      ];

      for (final testCase in testCases) {
        // Arrange
        when(mockTextRecognizer.processImage(any))
            .thenAnswer((_) async => MerchantTestData.customMerchantReceipt(testCase.$1));
        
        // Act
        final result = await ocrService.processReceipt(mockImageData);
        
        // Assert
        expect(result.merchant?.value, equals(testCase.$2),
          reason: 'Failed to normalize "${testCase.$1}" to "${testCase.$2}"');
        expect(result.merchant?.originalText, equals(testCase.$1));
      }
    });

    test('should maintain performance with normalization enabled', () async {
      // Arrange
      when(mockTextRecognizer.processImage(any))
          .thenAnswer((_) async => MerchantTestData.receiptWithNormalizableMerchant());
      
      await ocrService.initialize();
      
      // Act - Process multiple times and measure
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 10; i++) {
        await ocrService.processReceipt(mockImageData);
      }
      
      stopwatch.stop();
      final avgProcessingTime = stopwatch.elapsedMilliseconds / 10;
      
      // Assert - Processing should still be fast
      expect(avgProcessingTime, lessThan(1000), // Should process in under 1 second
        reason: 'Average processing time ${avgProcessingTime}ms exceeds 1000ms limit');
    });

    test('should handle processing errors gracefully', () async {
      // Arrange
      when(mockTextRecognizer.processImage(any))
          .thenThrow(Exception('OCR processing failed'));
      
      await ocrService.initialize();
      
      // Act
      final result = await ocrService.processReceipt(mockImageData);
      
      // Assert - Should return dummy data
      expect(result.merchant?.value, equals('Sample Store'));
      expect(result.processingDurationMs, greaterThan(0));
    });
  });
}

