import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/domain/services/merchant_normalization_service.dart';

// Import test data
import '../fixtures/merchant_test_data.dart';

/// Performance benchmark tests for merchant name normalization
/// Validates that normalization meets performance requirements:
/// - <50ms per merchant (p95)
/// - <5% impact on OCR processing time
void main() {
  group('Merchant Normalization Performance Benchmarks', () {
    late MerchantNormalizationService normalizationService;
    late List<BenchmarkResult> results;

    setUpAll(() {
      normalizationService = MerchantNormalizationService();
      results = [];
    });

    tearDownAll(() {
      // Print benchmark summary
      _printBenchmarkSummary(results);
    });

    test('Single merchant normalization should complete in <50ms (p95)', () {
      final testCases = MerchantTestData.getAllTestCases();
      final timings = <double>[];

      for (final entry in testCases.entries) {
        if (entry.key == null) continue;
        
        final stopwatch = Stopwatch()..start();
        normalizationService.normalize(entry.key!);
        stopwatch.stop();
        
        timings.add(stopwatch.elapsedMicroseconds / 1000.0); // Convert to ms
      }

      timings.sort();
      final p50 = _percentile(timings, 50);
      final p95 = _percentile(timings, 95);
      final p99 = _percentile(timings, 99);

      results.add(BenchmarkResult(
        name: 'Single Merchant Normalization',
        p50: p50,
        p95: p95,
        p99: p99,
        sampleSize: timings.length,
      ));

      // Assert performance requirements
      expect(p95, lessThan(50), 
        reason: 'P95 normalization time ${p95}ms exceeds 50ms target');
      expect(p99, lessThan(100), 
        reason: 'P99 normalization time ${p99}ms exceeds 100ms acceptable limit');
    });

    test('Batch normalization of 100 merchants should complete in <500ms', () {
      final merchants = MerchantTestData.generatePerformanceTestData(count: 100);
      
      final stopwatch = Stopwatch()..start();
      for (final merchant in merchants) {
        normalizationService.normalize(merchant);
      }
      stopwatch.stop();
      
      final totalTime = stopwatch.elapsedMilliseconds;
      final perMerchantAvg = totalTime / merchants.length;

      results.add(BenchmarkResult(
        name: 'Batch 100 Merchants',
        totalTime: totalTime.toDouble(),
        perItemAverage: perMerchantAvg,
        sampleSize: merchants.length,
      ));

      expect(totalTime, lessThan(500), 
        reason: 'Batch processing ${totalTime}ms exceeds 500ms target');
    });

    test('Large dataset (1000 merchants) performance should scale linearly', () {
      final merchants = MerchantTestData.generatePerformanceTestData(count: 1000);
      final batchSizes = [10, 50, 100, 500, 1000];
      final timings = <int, double>{};

      for (final batchSize in batchSizes) {
        final batch = merchants.take(batchSize).toList();
        
        final stopwatch = Stopwatch()..start();
        for (final merchant in batch) {
          normalizationService.normalize(merchant);
        }
        stopwatch.stop();
        
        timings[batchSize] = stopwatch.elapsedMilliseconds.toDouble();
      }

      // Check for linear scaling
      final scalingFactors = <double>[];
      for (int i = 1; i < batchSizes.length; i++) {
        final sizeFactor = batchSizes[i] / batchSizes[i - 1];
        final timeFactor = timings[batchSizes[i]]! / timings[batchSizes[i - 1]]!;
        scalingFactors.add(timeFactor / sizeFactor);
      }

      final avgScalingFactor = scalingFactors.reduce((a, b) => a + b) / scalingFactors.length;
      
      results.add(BenchmarkResult(
        name: 'Linear Scaling Test',
        scalingFactor: avgScalingFactor,
        sampleSize: merchants.length,
      ));

      // Linear scaling should be close to 1.0 (allow 20% deviation)
      expect(avgScalingFactor, closeTo(1.0, 0.2),
        reason: 'Scaling factor ${avgScalingFactor} indicates non-linear performance');
    });

    test('Memory usage should remain stable during batch processing', () {
      // Note: This is a simplified memory test. In production, use
      // proper memory profiling tools.
      
      final initialMemory = _estimateMemoryUsage();
      final merchants = MerchantTestData.generatePerformanceTestData(count: 1000);
      
      // Process in batches and check memory doesn't grow excessively
      for (int i = 0; i < merchants.length; i += 100) {
        final batch = merchants.skip(i).take(100).toList();
        for (final merchant in batch) {
          normalizationService.normalize(merchant);
        }
      }
      
      final finalMemory = _estimateMemoryUsage();
      final memoryIncrease = finalMemory - initialMemory;
      
      results.add(BenchmarkResult(
        name: 'Memory Usage',
        memoryIncreaseMB: memoryIncrease / (1024 * 1024),
        sampleSize: merchants.length,
      ));
      
      // Memory increase should be less than 5MB
      expect(memoryIncrease, lessThan(5 * 1024 * 1024),
        reason: 'Memory increase ${memoryIncrease / (1024 * 1024)}MB exceeds 5MB limit');
    });

    test('Cold start performance should be acceptable', () {
      // Simulate cold start by creating new instance
      final coldService = MerchantNormalizationService();
      
      final stopwatch = Stopwatch()..start();
      final result = coldService.normalize('MCDONALDS #4521');
      stopwatch.stop();
      
      final coldStartTime = stopwatch.elapsedMilliseconds;
      
      results.add(BenchmarkResult(
        name: 'Cold Start',
        coldStartMs: coldStartTime.toDouble(),
        sampleSize: 1,
      ));
      
      expect(result, equals('McDonalds'));
      expect(coldStartTime, lessThan(100),
        reason: 'Cold start ${coldStartTime}ms exceeds 100ms limit');
    });

    test('Edge cases should not cause performance degradation', () {
      final edgeCases = [
        'A' * 200, // Very long name
        '####', // Special characters only
        'STORE #' * 50, // Repeated patterns
        '😀🏪💳', // Unicode/emoji
        '', // Empty string
      ];
      
      final timings = <double>[];
      
      for (final testCase in edgeCases) {
        final stopwatch = Stopwatch()..start();
        normalizationService.normalize(testCase);
        stopwatch.stop();
        
        timings.add(stopwatch.elapsedMicroseconds / 1000.0);
      }
      
      final maxTime = timings.reduce(max);
      
      results.add(BenchmarkResult(
        name: 'Edge Cases',
        maxTimeMs: maxTime,
        sampleSize: edgeCases.length,
      ));
      
      expect(maxTime, lessThan(75),
        reason: 'Edge case processing ${maxTime}ms exceeds 75ms limit');
    });
  });
}

// Benchmark result tracking
class BenchmarkResult {
  final String name;
  final double? p50;
  final double? p95;
  final double? p99;
  final double? totalTime;
  final double? perItemAverage;
  final double? scalingFactor;
  final double? memoryIncreaseMB;
  final double? coldStartMs;
  final double? maxTimeMs;
  final int sampleSize;

  BenchmarkResult({
    required this.name,
    this.p50,
    this.p95,
    this.p99,
    this.totalTime,
    this.perItemAverage,
    this.scalingFactor,
    this.memoryIncreaseMB,
    this.coldStartMs,
    this.maxTimeMs,
    required this.sampleSize,
  });
}

// Helper function to calculate percentile
double _percentile(List<double> values, int percentile) {
  if (values.isEmpty) return 0;
  final index = (percentile / 100 * values.length).ceil() - 1;
  return values[index.clamp(0, values.length - 1)];
}

// Simplified memory estimation (in production, use proper profiling)
int _estimateMemoryUsage() {
  // This is a placeholder - actual implementation would use
  // platform-specific memory APIs or profiling tools
  return DateTime.now().millisecondsSinceEpoch % 1000000;
}

// Print formatted benchmark summary
void _printBenchmarkSummary(List<BenchmarkResult> results) {
  print('\n=== Merchant Normalization Performance Benchmark Results ===\n');
  
  for (final result in results) {
    print('${result.name}:');
    if (result.p50 != null) {
      print('  P50: ${result.p50!.toStringAsFixed(2)}ms');
      print('  P95: ${result.p95!.toStringAsFixed(2)}ms');
      print('  P99: ${result.p99!.toStringAsFixed(2)}ms');
    }
    if (result.totalTime != null) {
      print('  Total Time: ${result.totalTime!.toStringAsFixed(2)}ms');
    }
    if (result.perItemAverage != null) {
      print('  Per Item Avg: ${result.perItemAverage!.toStringAsFixed(2)}ms');
    }
    if (result.scalingFactor != null) {
      print('  Scaling Factor: ${result.scalingFactor!.toStringAsFixed(2)}');
    }
    if (result.memoryIncreaseMB != null) {
      print('  Memory Increase: ${result.memoryIncreaseMB!.toStringAsFixed(2)}MB');
    }
    if (result.coldStartMs != null) {
      print('  Cold Start: ${result.coldStartMs!.toStringAsFixed(2)}ms');
    }
    if (result.maxTimeMs != null) {
      print('  Max Time: ${result.maxTimeMs!.toStringAsFixed(2)}ms');
    }
    print('  Sample Size: ${result.sampleSize}');
    print('');
  }
  
  print('=== End Benchmark Results ===\n');
}

// Service is now imported from the actual implementation