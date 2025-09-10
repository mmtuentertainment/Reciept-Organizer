import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/domain/services/csv_export_service.dart';
import 'package:receipt_organizer/features/export/domain/services/csv_preview_service.dart';

void main() {
  group('CSV Preview Performance Tests', () {
    late CSVPreviewService service;
    
    setUp(() {
      service = CSVPreviewService();
    });

    tearDown(() {
      service.dispose();
    });

    test('PERF-001: Preview generation completes in <100ms for 100 receipts', () async {
      // Arrange - Create 100 receipts with varying data
      final receipts = List.generate(100, (index) {
        return Receipt(
          id: 'receipt_$index',
          merchantName: 'Merchant ${index % 20}', // 20 unique merchants
          totalAmount: 10.0 + (index * 1.5),
          taxAmount: 1.0 + (index * 0.15),
          receiptDate: '01/${(index % 28 + 1).toString().padLeft(2, '0')}/2024',
          imagePath: '/path/to/image_$index.jpg',
          status: ReceiptStatus.ready,
          createdAt: DateTime.now().subtract(Duration(days: index)),
          updatedAt: DateTime.now(),
        );
      });

      // Warm up - First run might be slower due to initialization
      await service.generatePreview(receipts.take(10).toList(), ExportFormat.generic);

      // Act - Run performance test 10 times
      final durations = <Duration>[];
      for (int i = 0; i < 10; i++) {
        service.clearCache(); // Clear cache to test real performance
        
        final stopwatch = Stopwatch()..start();
        final result = await service.generatePreview(receipts, ExportFormat.generic);
        stopwatch.stop();
        
        durations.add(stopwatch.elapsed);
        
        // Verify result is valid
        expect(result.totalCount, equals(100));
        expect(result.previewRows.length, lessThanOrEqualTo(6)); // 5 data + 1 header
      }

      // Assert - Calculate p95 (95th percentile)
      durations.sort((a, b) => a.compareTo(b));
      final p95Index = (durations.length * 0.95).floor();
      final p95Duration = durations[p95Index];
      
      print('Performance Results:');
      print('  Min: ${durations.first.inMilliseconds}ms');
      print('  Max: ${durations.last.inMilliseconds}ms');
      print('  P95: ${p95Duration.inMilliseconds}ms');
      print('  Average: ${durations.reduce((a, b) => a + b).inMilliseconds / durations.length}ms');
      
      // CRITICAL: Must meet <100ms target for p95
      expect(
        p95Duration.inMilliseconds,
        lessThan(100),
        reason: 'PERF-001: P95 latency ${p95Duration.inMilliseconds}ms exceeds 100ms target',
      );
    });

    test('Performance scales linearly with receipt count', () async {
      // Test with different sizes to verify linear scaling
      final testSizes = [10, 50, 100, 200];
      final results = <int, Duration>{};
      
      for (final size in testSizes) {
        final receipts = List.generate(size, (index) => Receipt(
          id: 'receipt_$index',
          merchantName: 'Test Merchant',
          totalAmount: 100.0,
          taxAmount: 10.0,
          receiptDate: '01/15/2024',
          imagePath: '/path/to/image.jpg',
          status: ReceiptStatus.ready,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
        
        service.clearCache();
        final stopwatch = Stopwatch()..start();
        await service.generatePreview(receipts, ExportFormat.generic);
        stopwatch.stop();
        
        results[size] = stopwatch.elapsed;
      }
      
      // Verify approximately linear scaling
      // Time for 200 receipts should be < 2.5x time for 100 receipts
      final ratio = results[200]!.inMilliseconds / results[100]!.inMilliseconds;
      expect(
        ratio,
        lessThan(2.5),
        reason: 'Performance does not scale linearly: 200 receipts took ${ratio}x longer than 100',
      );
    });

    test('Cache improves subsequent preview generation', () async {
      // Arrange
      final receipts = List.generate(50, (index) => Receipt(
        id: 'receipt_$index',
        merchantName: 'Cached Merchant',
        totalAmount: 100.0,
        taxAmount: 10.0,
        receiptDate: '01/15/2024',
        imagePath: '/path/to/image.jpg',
        status: ReceiptStatus.ready,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      
      // Act - First generation (no cache)
      service.clearCache();
      final firstStopwatch = Stopwatch()..start();
      final firstResult = await service.generatePreview(receipts, ExportFormat.generic);
      firstStopwatch.stop();
      
      // Second generation (with cache)
      final secondStopwatch = Stopwatch()..start();
      final secondResult = await service.generatePreview(receipts, ExportFormat.generic);
      secondStopwatch.stop();
      
      // Assert
      print('Cache Performance:');
      print('  First run: ${firstStopwatch.elapsed.inMilliseconds}ms');
      print('  Cached run: ${secondStopwatch.elapsed.inMilliseconds}ms');
      print('  Improvement: ${((1 - secondStopwatch.elapsed.inMilliseconds / firstStopwatch.elapsed.inMilliseconds) * 100).toStringAsFixed(1)}%');
      
      // Cache should provide significant improvement
      expect(
        secondStopwatch.elapsed.inMilliseconds,
        lessThan(firstStopwatch.elapsed.inMilliseconds * 0.5),
        reason: 'Cache did not provide expected performance improvement',
      );
      
      // Results should be identical
      expect(secondResult.previewRows, equals(firstResult.previewRows));
      expect(secondResult.totalCount, equals(firstResult.totalCount));
    });

    test('Memory usage remains bounded with large datasets', () async {
      // Test that preview limits prevent memory issues
      final largeDataset = List.generate(10000, (index) => Receipt(
        id: 'receipt_$index',
        merchantName: 'Large Dataset Merchant $index',
        totalAmount: 100.0 + index,
        taxAmount: 10.0 + (index * 0.1),
        receiptDate: '01/15/2024',
        imagePath: '/path/to/image_$index.jpg',
        status: ReceiptStatus.ready,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      
      final stopwatch = Stopwatch()..start();
      final result = await service.generatePreview(largeDataset, ExportFormat.generic);
      stopwatch.stop();
      
      // Should still complete quickly despite large dataset
      expect(stopwatch.elapsed.inMilliseconds, lessThan(500));
      
      // Should only return limited preview rows
      expect(result.previewRows.length, lessThanOrEqualTo(6));
      expect(result.totalCount, equals(10000));
      
      print('Large dataset (10k receipts):');
      print('  Processing time: ${stopwatch.elapsed.inMilliseconds}ms');
      print('  Preview rows: ${result.previewRows.length}');
    });
  });
}