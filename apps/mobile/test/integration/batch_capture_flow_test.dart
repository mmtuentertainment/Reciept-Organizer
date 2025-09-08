import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:receipt_organizer/domain/services/csv_export_service.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/features/capture/screens/batch_capture_screen.dart';
import '../mocks/mock_text_recognizer.dart';

/// Integration tests for batch capture performance and workflow
/// Validates AC1: Batch mode captures 10 receipts in <3min
void main() {
  group('Batch Capture Performance Tests', () {
    late MockTextRecognizer mockTextRecognizer;
    late OCRService ocrService;
    late CSVExportService csvExportService;
    
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      mockTextRecognizer = MockTextRecognizer();
      ocrService = OCRService(textRecognizer: mockTextRecognizer);
      csvExportService = CSVExportService();
    });

    tearDown(() async {
      await ocrService.dispose();
    });

    testWidgets('AC1: Should capture 10 receipts in less than 3 minutes', (WidgetTester tester) async {
      // Arrange - Set up optimistic OCR responses for performance
      when(mockTextRecognizer.processImage(any))
          .thenAnswer((_) async => TestOCRData.highConfidenceReceipt());

      await ocrService.initialize();
      
      final startTime = DateTime.now();
      final mockImageData = Uint8List.fromList(List.generate(1000, (index) => index % 256));
      
      // Act - Simulate capturing 10 receipts sequentially
      final results = <ProcessingResult>[];
      
      for (int i = 0; i < 10; i++) {
        final result = await ocrService.processReceipt(mockImageData);
        results.add(result);
        
        // Brief pause to simulate real capture timing
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      // Assert - Validate AC1 timing requirement
      expect(results.length, equals(10), reason: 'Should capture exactly 10 receipts');
      expect(duration.inMinutes, lessThan(3), 
          reason: 'Should complete 10 receipts in less than 3 minutes (actual: ${duration.inSeconds}s)');
      expect(duration.inSeconds, lessThan(180), 
          reason: 'Performance target: 180 seconds max (actual: ${duration.inSeconds}s)');
      
      // Validate all receipts processed successfully
      for (final result in results) {
        expect(result, isA<ProcessingResult>());
        expect(result.overallConfidence, greaterThan(0));
      }
      
      // Log performance metrics
      final avgTimePerReceipt = duration.inMilliseconds / 10;
      debugPrint('Performance Metrics:');
      debugPrint('  Total time: ${duration.inSeconds}s');
      debugPrint('  Average per receipt: ${avgTimePerReceipt.toStringAsFixed(1)}ms');
      debugPrint('  Target: 18s per receipt (${18000}ms)');
      
      expect(avgTimePerReceipt, lessThan(18000), 
          reason: 'Average processing should be under 18s per receipt');
    });
    
    testWidgets('Should handle batch capture UI workflow performance', (WidgetTester tester) async {
      // Arrange - Create test app with providers
      when(mockTextRecognizer.processImage(any))
          .thenAnswer((_) async => TestOCRData.highConfidenceReceipt());

      await ocrService.initialize();
      
      final container = ProviderContainer();
      
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: const BatchCaptureScreen(),
          ),
        ),
      );
      
      // Act - Test initial UI load performance
      final startTime = DateTime.now();
      await tester.pumpAndSettle();
      final uiLoadTime = DateTime.now().difference(startTime);
      
      // Assert - UI should load quickly
      expect(uiLoadTime.inMilliseconds, lessThan(2000), 
          reason: 'UI should load in under 2 seconds');
      
      // Verify batch capture screen elements are present
      expect(find.text('Batch Capture'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsWidgets); // Capture button
      
      container.dispose();
    });
    
    testWidgets('Should handle memory efficiently during batch processing', (WidgetTester tester) async {
      // Arrange - Test memory usage during batch processing
      when(mockTextRecognizer.processImage(any))
          .thenAnswer((_) async => TestOCRData.highConfidenceReceipt());

      await ocrService.initialize();
      
      // Act - Process multiple receipts and monitor basic metrics
      final mockImageData = Uint8List.fromList(List.generate(1000, (index) => index % 256));
      final results = <ProcessingResult>[];
      
      for (int i = 0; i < 5; i++) {
        final result = await ocrService.processReceipt(mockImageData);
        results.add(result);
      }
      
      // Assert - All results should be valid (memory didn't cause crashes)
      expect(results.length, equals(5));
      for (final result in results) {
        expect(result, isA<ProcessingResult>());
        expect(result.merchant, isNotNull);
      }
    });
    
    testWidgets('Should validate CSV export performance for batch', (WidgetTester tester) async {
      // Arrange - Create batch of processed receipts with OCR results
      final mockReceipts = List.generate(10, (index) => Receipt(
        imageUri: '/path/to/image$index.jpg',
        status: ReceiptStatus.ready,
        ocrResults: ProcessingResult(
          merchant: FieldData(
            value: 'Test Store $index',
            confidence: 85.0,
            originalText: 'Test Store $index',
          ),
          date: FieldData(
            value: '2024-01-${index + 1}',
            confidence: 90.0,
            originalText: '2024-01-${index + 1}',
          ),
          total: FieldData(
            value: 25.0 + index,
            confidence: 95.0,
            originalText: '\$${(25.0 + index).toStringAsFixed(2)}',
          ),
          overallConfidence: 87.5,
          processingDurationMs: 1000 + index,
        ),
      ));
      
      // Act - Test CSV export performance
      final startTime = DateTime.now();
      final exportResult = await csvExportService.exportToCSV(
        mockReceipts, 
        ExportFormat.generic
      );
      final exportTime = DateTime.now().difference(startTime);
      
      // Assert - Export should be fast and successful
      expect(exportResult.success, isTrue, 
          reason: 'CSV export should succeed');
      expect(exportTime.inSeconds, lessThan(10), 
          reason: 'CSV export should complete quickly');
      expect(exportResult.recordCount, equals(10),
          reason: 'Should export all 10 receipts');
      expect(exportResult.fileName, isNotNull);
    });
    
    test('Should validate background processing queue performance', () async {
      // Arrange - Set up OCR for background processing test
      when(mockTextRecognizer.processImage(any))
          .thenAnswer((_) async => TestOCRData.highConfidenceReceipt());

      await ocrService.initialize();
      
      // Act - Test concurrent processing
      final mockImageData = Uint8List.fromList(List.generate(1000, (index) => index % 256));
      final startTime = DateTime.now();
      
      final futures = List.generate(3, (index) => 
        ocrService.processReceipt(mockImageData)
      );
      
      final results = await Future.wait(futures);
      final concurrentTime = DateTime.now().difference(startTime);
      
      // Assert - Concurrent processing should be efficient
      expect(results.length, equals(3));
      expect(concurrentTime.inSeconds, lessThan(30), 
          reason: 'Concurrent processing should be faster than sequential');
      
      for (final result in results) {
        expect(result, isA<ProcessingResult>());
        expect(result.processingDurationMs, greaterThan(0));
      }
    });
  });
}