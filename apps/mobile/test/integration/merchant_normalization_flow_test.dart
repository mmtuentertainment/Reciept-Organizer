import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/domain/services/merchant_normalization_service.dart';

void main() {
  group('Merchant Normalization Integration Flow', () {
    late MerchantNormalizationService service;

    setUp(() {
      service = MerchantNormalizationService();
    });

    tearDown(() {
      service.clearCache();
    });

    test('should complete normalization flow within performance targets', () {
      // Story requirement: <50ms per merchant normalization
      final testMerchants = [
        'MCDONALDS #4521',
        'STARBUCKS #12345',
        'CVS/PHARMACY #567',
        'WALMART STORE #1234',
        '7-ELEVEN #890',
        'TARGET - PLAZA NORTH',
        'T.J.MAXX',
        'AMAZON.COM',
        'SUBWAY - INSIDE WALMART',
        'MCD #1234',
      ];

      final stopwatch = Stopwatch()..start();
      final results = <String, String>{};

      for (final merchant in testMerchants) {
        final normalized = service.normalize(merchant);
        results[merchant] = normalized;
      }

      stopwatch.stop();

      // Assert performance
      final avgTime = stopwatch.elapsedMilliseconds / testMerchants.length;
      expect(avgTime, lessThan(50), 
        reason: 'Average normalization time ${avgTime}ms exceeds 50ms target');

      // Assert correct normalization
      expect(results['MCDONALDS #4521'], equals('McDonalds'));
      expect(results['STARBUCKS #12345'], equals('Starbucks'));
      expect(results['CVS/PHARMACY #567'], equals('CVS Pharmacy'));
      expect(results['WALMART STORE #1234'], equals('Walmart'));
      expect(results['7-ELEVEN #890'], equals('7-Eleven'));
      expect(results['TARGET - PLAZA NORTH'], equals('Target'));
      expect(results['T.J.MAXX'], equals('T.J.Maxx'));
      expect(results['AMAZON.COM'], equals('Amazon.com'));
      expect(results['SUBWAY - INSIDE WALMART'], equals('Subway'));
      expect(results['MCD #1234'], equals('McDonalds'));
    });

    test('should handle edge cases in normalization flow', () {
      final edgeCases = {
        null: '',
        '': '',
        '   ': '',
        'ALREADY_CLEAN': 'ALREADY_CLEAN',
        '####': '####',
        'A' * 200: 'A' * 200, // Very long name
      };

      for (final entry in edgeCases.entries) {
        final result = service.normalize(entry.key);
        expect(result, equals(entry.value),
          reason: 'Failed edge case for input "${entry.key}"');
      }
    });

    test('should handle concurrent normalization requests', () {
      // Simulate concurrent access
      final futures = <Future<String>>[];
      
      for (int i = 0; i < 100; i++) {
        futures.add(
          Future(() => service.normalize('MCDONALDS #$i'))
        );
      }

      // All should complete successfully
      expect(
        Future.wait(futures),
        completion(everyElement(equals('McDonalds'))),
      );
    });

    test('should maintain cache effectiveness', () {
      const testMerchant = 'STARBUCKS #9999';
      
      // First call - not cached
      final result1 = service.normalize(testMerchant);
      expect(result1, equals('Starbucks'));
      expect(service.cacheSize, equals(1));
      
      // Second call - should be cached
      final stopwatch = Stopwatch()..start();
      final result2 = service.normalize(testMerchant);
      stopwatch.stop();
      
      expect(result2, equals('Starbucks'));
      expect(service.cacheSize, equals(1)); // Still 1, used from cache
      expect(stopwatch.elapsedMicroseconds, lessThan(1000), // Should be very fast
        reason: 'Cached lookup took ${stopwatch.elapsedMicroseconds}μs');
    });

    test('should integrate with field data model correctly', () {
      // Simulate OCR field data
      final merchantField = FieldData(
        value: 'WALMART STORE #5678',
        confidence: 85.0,
        originalText: 'WALMART STORE #5678',
      );

      // Normalize the merchant value
      final normalizedValue = service.normalize(merchantField.value as String);

      // Create updated field data preserving original
      final updatedField = FieldData(
        value: normalizedValue,
        confidence: merchantField.confidence,
        originalText: merchantField.originalText,
        isManuallyEdited: false,
        validationStatus: 'valid',
      );

      expect(updatedField.value, equals('Walmart'));
      expect(updatedField.originalText, equals('WALMART STORE #5678'));
      expect(updatedField.confidence, equals(85.0));
    });
  });
}

// Simple FieldData class for testing
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
}