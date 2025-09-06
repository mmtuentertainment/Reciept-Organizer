import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/domain/services/merchant_normalization_service.dart';

import '../../fixtures/merchant_test_data.dart';

void main() {
  group('MerchantNormalizationService', () {
    late MerchantNormalizationService service;

    setUp(() {
      service = MerchantNormalizationService();
    });

    tearDown(() {
      service.clearCache();
    });

    group('normalize', () {
      test('should handle null and empty inputs', () {
        expect(service.normalize(null), equals(''));
        expect(service.normalize(''), equals(''));
        expect(service.normalize('   '), equals(''));
      });

      test('should normalize common franchise patterns', () {
        MerchantTestData.franchiseTestCases.forEach((input, expected) {
          expect(
            service.normalize(input),
            equals(expected),
            reason: 'Failed to normalize "$input" to "$expected"',
          );
        });
      });

      test('should handle case normalization', () {
        MerchantTestData.caseNormalizationTestCases.forEach((input, expected) {
          expect(
            service.normalize(input),
            equals(expected),
            reason: 'Failed to normalize case for "$input" to "$expected"',
          );
        });
      });

      test('should handle special characters correctly', () {
        MerchantTestData.specialCharacterTestCases.forEach((input, expected) {
          expect(
            service.normalize(input),
            equals(expected),
            reason: 'Failed to handle special characters in "$input"',
          );
        });
      });

      test('should expand abbreviations', () {
        MerchantTestData.abbreviationTestCases.forEach((input, expected) {
          expect(
            service.normalize(input),
            equals(expected),
            reason: 'Failed to expand abbreviation "$input" to "$expected"',
          );
        });
      });

      test('should remove location suffixes', () {
        MerchantTestData.locationSuffixTestCases.forEach((input, expected) {
          expect(
            service.normalize(input),
            equals(expected),
            reason: 'Failed to remove suffix from "$input"',
          );
        });
      });

      test('should not modify already clean names', () {
        for (final clean in MerchantTestData.alreadyCleanTestCases) {
          expect(
            service.normalize(clean),
            equals(clean),
            reason: 'Modified already clean name "$clean"',
          );
        }
      });

      test('should handle edge cases gracefully', () {
        MerchantTestData.edgeCaseTestCases.forEach((input, expected) {
          expect(
            service.normalize(input),
            equals(expected),
            reason: 'Failed edge case for input "$input"',
          );
        });
      });

      test('should handle long merchant names', () {
        MerchantTestData.longNameTestCases.forEach((input, expected) {
          expect(
            service.normalize(input),
            equals(expected),
            reason: 'Failed to handle long name',
          );
        });
      });

      test('should normalize international format stores', () {
        MerchantTestData.internationalTestCases.forEach((input, expected) {
          expect(
            service.normalize(input),
            equals(expected),
            reason: 'Failed international format for "$input"',
          );
        });
      });

      test('should normalize gas station variations', () {
        MerchantTestData.gasStationTestCases.forEach((input, expected) {
          expect(
            service.normalize(input),
            equals(expected),
            reason: 'Failed gas station normalization for "$input"',
          );
        });
      });

      test('should normalize restaurant chains', () {
        MerchantTestData.restaurantTestCases.forEach((input, expected) {
          expect(
            service.normalize(input),
            equals(expected),
            reason: 'Failed restaurant normalization for "$input"',
          );
        });
      });
    });

    group('caching', () {
      test('should cache normalized results', () {
        const testMerchant = 'MCDONALDS #4521';
        
        // First call
        final result1 = service.normalize(testMerchant);
        expect(result1, equals('McDonalds'));
        expect(service.cacheSize, equals(1));
        
        // Second call should use cache
        final result2 = service.normalize(testMerchant);
        expect(result2, equals('McDonalds'));
        expect(service.cacheSize, equals(1));
      });

      test('should handle cache size limit', () {
        // Fill cache to max
        for (int i = 0; i < 1000; i++) {
          service.normalize('TEST MERCHANT $i');
        }
        expect(service.cacheSize, equals(1000));
        
        // Next normalization should clear cache
        service.normalize('TEST MERCHANT 1001');
        expect(service.cacheSize, equals(1));
      });

      test('should clear cache on demand', () {
        service.normalize('TEST MERCHANT');
        expect(service.cacheSize, equals(1));
        
        service.clearCache();
        expect(service.cacheSize, equals(0));
      });
    });

    group('specific pattern tests', () {
      test('should handle McDonald\'s variations', () {
        final mcdonaldsVariations = [
          'MCDONALDS #4521',
          'MCDONALD\'S #123',
          'McDonalds Store #789',
          'MCDONALDS - STORE 456',
          'MCD #1234',
          'MCDONALDS 00123',
        ];
        
        for (final variant in mcdonaldsVariations) {
          expect(
            service.normalize(variant),
            equals('McDonalds'),
            reason: 'Failed to normalize McDonald\'s variant: $variant',
          );
        }
      });

      test('should handle CVS pharmacy variations', () {
        expect(service.normalize('CVS/PHARMACY #12345'), equals('CVS Pharmacy'));
        expect(service.normalize('CVS #1234'), equals('CVS'));
        expect(service.normalize('CVS PHARMACY #567'), equals('CVS Pharmacy'));
        expect(service.normalize('CVS/PHARM #890'), equals('CVS Pharmacy'));
      });

      test('should handle stores with special formatting', () {
        expect(service.normalize('7-ELEVEN #12345'), equals('7-Eleven'));
        expect(service.normalize('T.J.MAXX'), equals('T.J.Maxx'));
        expect(service.normalize('AT&T STORE'), equals('AT&T Store'));
      });

      test('should preserve .com domains', () {
        expect(service.normalize('AMAZON.COM'), equals('Amazon.com'));
        expect(service.normalize('WALMART.COM'), equals('Walmart.com'));
        expect(service.normalize('TARGET.COM'), equals('Target.com'));
      });

      test('should handle complex suffixes', () {
        expect(service.normalize('SUBWAY - INSIDE WALMART'), equals('Subway'));
        expect(service.normalize('SAFEWAY - 24HR'), equals('Safeway'));
        expect(service.normalize('TARGET - PLAZA NORTH'), equals('Target'));
      });
    });

    group('performance', () {
      test('should normalize quickly for typical merchants', () {
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 100; i++) {
          service.normalize('MCDONALDS #4521');
        }
        
        stopwatch.stop();
        final avgTime = stopwatch.elapsedMicroseconds / 100 / 1000; // ms
        
        expect(avgTime, lessThan(5), 
          reason: 'Average normalization time ${avgTime}ms exceeds 5ms');
      });

      test('should handle batch normalization efficiently', () {
        final merchants = MerchantTestData.generatePerformanceTestData(count: 100);
        
        final stopwatch = Stopwatch()..start();
        for (final merchant in merchants) {
          service.normalize(merchant);
        }
        stopwatch.stop();
        
        expect(stopwatch.elapsedMilliseconds, lessThan(500),
          reason: 'Batch normalization took ${stopwatch.elapsedMilliseconds}ms');
      });
    });
  });
}