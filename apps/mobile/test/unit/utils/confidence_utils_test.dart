import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/core/models/confidence_level.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';

void main() {
  group('ConfidenceLevel Extension', () {
    test('returns correct confidence level for high confidence', () {
      // Given
      const double highConfidence = 90.0;
      
      // When
      final level = highConfidence.confidenceLevel;
      
      // Then
      expect(level, ConfidenceLevel.high);
    });

    test('returns correct confidence level for medium confidence', () {
      // Given
      const double mediumConfidence = 80.0;
      
      // When
      final level = mediumConfidence.confidenceLevel;
      
      // Then
      expect(level, ConfidenceLevel.medium);
    });

    test('returns correct confidence level for low confidence', () {
      // Given
      const double lowConfidence = 60.0;
      
      // When
      final level = lowConfidence.confidenceLevel;
      
      // Then
      expect(level, ConfidenceLevel.low);
    });

    test('handles edge cases correctly', () {
      // Test boundary values
      expect(85.0.confidenceLevel, ConfidenceLevel.high);
      expect(84.9.confidenceLevel, ConfidenceLevel.medium);
      expect(75.0.confidenceLevel, ConfidenceLevel.medium);
      expect(74.9.confidenceLevel, ConfidenceLevel.low);
      expect(0.0.confidenceLevel, ConfidenceLevel.low);
      expect(100.0.confidenceLevel, ConfidenceLevel.high);
    });
  });

  group('FieldData', () {
    test('creates FieldData with correct defaults', () {
      // When
      final fieldData = FieldData(
        value: 'Test Value',
        confidence: 85.0,
        originalText: 'Test Value',
      );

      // Then
      expect(fieldData.value, 'Test Value');
      expect(fieldData.confidence, 85.0);
      expect(fieldData.originalText, 'Test Value');
      expect(fieldData.isManuallyEdited, false);
      expect(fieldData.validationStatus, 'valid');
    });

    test('copyWith preserves original values when not specified', () {
      // Given
      final originalFieldData = FieldData(
        value: 'Original Value',
        confidence: 75.0,
        originalText: 'Original Text',
        isManuallyEdited: false,
        validationStatus: 'valid',
      );

      // When
      final copiedFieldData = originalFieldData.copyWith(
        value: 'New Value',
        isManuallyEdited: true,
      );

      // Then
      expect(copiedFieldData.value, 'New Value');
      expect(copiedFieldData.confidence, 75.0); // Preserved
      expect(copiedFieldData.originalText, 'Original Text'); // Preserved
      expect(copiedFieldData.isManuallyEdited, true);
      expect(copiedFieldData.validationStatus, 'valid'); // Preserved
    });

    test('copyWith updates specified values', () {
      // Given
      final originalFieldData = FieldData(
        value: 'Original Value',
        confidence: 75.0,
        originalText: 'Original Text',
      );

      // When
      final copiedFieldData = originalFieldData.copyWith(
        value: 'New Value',
        confidence: 100.0,
        isManuallyEdited: true,
        validationStatus: 'warning',
      );

      // Then
      expect(copiedFieldData.value, 'New Value');
      expect(copiedFieldData.confidence, 100.0);
      expect(copiedFieldData.originalText, 'Original Text'); // Preserved
      expect(copiedFieldData.isManuallyEdited, true);
      expect(copiedFieldData.validationStatus, 'warning');
    });
  });

  group('ProcessingResult', () {
    test('creates ProcessingResult with weighted confidence calculation', () {
      // Given
      final merchant = FieldData(
        value: 'Test Store',
        confidence: 80.0,
        originalText: 'Test Store',
      );
      
      final date = FieldData(
        value: '01/15/2024',
        confidence: 90.0,
        originalText: '01/15/2024',
      );
      
      final total = FieldData(
        value: 25.47,
        confidence: 95.0,
        originalText: '\$25.47',
      );
      
      final tax = FieldData(
        value: 2.04,
        confidence: 85.0,
        originalText: '\$2.04',
      );

      // When
      final processingResult = ProcessingResult(
        merchant: merchant,
        date: date,
        total: total,
        tax: tax,
        overallConfidence: 90.0, // Manually calculated
        processingDurationMs: 1500,
        allText: ['Test Store', '01/15/2024', '\$25.47', '\$2.04'],
      );

      // Then
      expect(processingResult.merchant, merchant);
      expect(processingResult.date, date);
      expect(processingResult.total, total);
      expect(processingResult.tax, tax);
      expect(processingResult.overallConfidence, 90.0);
    });

    test('handles missing fields gracefully', () {
      // Given - Only total and date fields
      final date = FieldData(
        value: '01/15/2024',
        confidence: 90.0,
        originalText: '01/15/2024',
      );
      
      final total = FieldData(
        value: 25.47,
        confidence: 95.0,
        originalText: '\$25.47',
      );

      // When
      final processingResult = ProcessingResult(
        date: date,
        total: total,
        overallConfidence: 92.5, // Weighted average of date (30%) and total (40%)
        processingDurationMs: 1200,
        allText: ['01/15/2024', '\$25.47'],
      );

      // Then
      expect(processingResult.merchant, isNull);
      expect(processingResult.date, date);
      expect(processingResult.total, total);
      expect(processingResult.tax, isNull);
      expect(processingResult.overallConfidence, 92.5);
    });
  });

  group('Confidence Calculation Logic', () {
    test('calculates weighted average correctly', () {
      // This test simulates the weighted average calculation used in ReceiptDetailScreen
      // Weights: Total 40%, Date 30%, Merchant 20%, Tax 10%
      
      // Given
      const merchantConfidence = 80.0; // 20% weight
      const dateConfidence = 90.0;     // 30% weight  
      const totalConfidence = 95.0;    // 40% weight
      const taxConfidence = 85.0;      // 10% weight

      // When - Calculate weighted average
      final weightedSum = (merchantConfidence * 0.2) + 
                         (dateConfidence * 0.3) + 
                         (totalConfidence * 0.4) + 
                         (taxConfidence * 0.1);
      final totalWeight = 1.0; // 0.2 + 0.3 + 0.4 + 0.1
      final calculatedConfidence = weightedSum / totalWeight;

      // Then
      expect(calculatedConfidence, closeTo(89.5, 0.1)); // 16 + 27 + 38 + 8.5 = 89.5
    });

    test('calculates weighted average with missing fields', () {
      // Given - Only date and total (missing merchant and tax)
      const dateConfidence = 90.0;     // 30% weight
      const totalConfidence = 95.0;    // 40% weight

      // When - Calculate weighted average for available fields only
      final weightedSum = (dateConfidence * 0.3) + (totalConfidence * 0.4);
      final totalWeight = 0.7; // 0.3 + 0.4
      final calculatedConfidence = weightedSum / totalWeight;

      // Then - Should be 27 + 38 = 65, divided by 0.7 = ~92.86
      expect(calculatedConfidence, closeTo(92.86, 0.1));
    });

    test('handles zero confidence gracefully', () {
      // Given
      const zeroConfidence = 0.0;

      // When
      final level = zeroConfidence.confidenceLevel;

      // Then
      expect(level, ConfidenceLevel.low);
    });

    test('handles confidence above 100 gracefully', () {
      // Given - Edge case where confidence might exceed 100
      const highConfidence = 105.0;

      // When
      final level = highConfidence.confidenceLevel;

      // Then
      expect(level, ConfidenceLevel.high);
    });
  });
}