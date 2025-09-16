import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/domain/services/csv_export_service.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:receipt_organizer/features/export/services/export_format_validator.dart';
import '../fixtures/test_data_generator.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  group('CSV Export Integration Tests', () {
    late CSVExportService exportService;
    late TestDataGenerator dataGenerator;

    setUpAll(() {
      exportService = CSVExportService();
      dataGenerator = TestDataGenerator();

      // Setup test environment
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('Complete export workflow for QuickBooks format', () async {
      // Generate test receipts
      final testData = dataGenerator.generateReceipts(count: 50);
      final receipts = testData.map(_createTestReceipt).toList();

      // Step 1: Validate receipts
      final validation = await exportService.validateForExport(
        receipts,
        ExportFormat.quickbooks,
      );

      expect(validation.isValid, true);
      expect(validation.errors, isEmpty);
      expect(validation.validCount, equals(receipts.length));

      // Step 2: Generate CSV content
      final csvContent = exportService.generateCSVContent(
        receipts,
        ExportFormat.quickbooks,
      );

      expect(csvContent, isNotEmpty);
      expect(csvContent, contains('Date,Description,Amount'));
      expect(csvContent, contains('\uFEFF')); // BOM for Excel compatibility

      // Step 3: Validate format compliance
      final formatValidation = ExportFormatValidator.validateFormat(
        csvContent,
        ExportFormat.quickbooks,
      );

      expect(formatValidation.isValid, true);
      expect(formatValidation.errors, isEmpty);

      // Step 4: Check batch processing
      final batches = exportService.createBatches(
        receipts,
        ExportFormat.quickbooks,
      );

      expect(batches.length, equals(1)); // 50 receipts should fit in one batch
      expect(batches.first.length, equals(50));

      // Step 5: Test progress tracking
      final progressValues = <double>[];
      await for (final progress in exportService.exportWithProgress(
        receipts,
        ExportFormat.quickbooks,
        customFileName: 'test_export_quickbooks.csv',
      )) {
        progressValues.add(progress);

        // Break if complete
        if (progress >= 1.0) break;
      }

      expect(progressValues, isNotEmpty);
      expect(progressValues.first, equals(0.0));
      expect(progressValues.last, equals(1.0));
    });

    test('Complete export workflow for Xero format', () async {
      // Generate test receipts
      final testData = dataGenerator.generateReceipts(count: 30);
      final receipts = testData.map((data) => Receipt(
        id: data['id'] ?? 'test-id',
        vendorName: data['merchant'],
        receiptDate: data['date'] as DateTime,
        totalAmount: (data['total'] as num).toDouble(),
        taxAmount: (data['tax'] as num?)?.toDouble(),
        notes: data['notes'],
        capturedAt: DateTime.now(),
        imagePath: 'test/image.jpg',
        status: ReceiptStatus.ready,
        overallConfidence: 85.0,
      )).toList();

      // Step 1: Validate receipts
      final validation = await exportService.validateForExport(
        receipts,
        ExportFormat.xero,
      );

      expect(validation.isValid, true);
      expect(validation.validCount, equals(receipts.length));

      // Step 2: Generate CSV content
      final csvContent = exportService.generateCSVContent(
        receipts,
        ExportFormat.xero,
      );

      expect(csvContent, isNotEmpty);
      expect(csvContent, contains('ContactName'));
      expect(csvContent, contains('InvoiceNumber'));
      expect(csvContent, contains('InvoiceDate'));

      // Step 3: Validate Xero-specific requirements
      final lines = csvContent.split('\n');
      for (int i = 1; i < lines.length && i <= 5; i++) {
        if (lines[i].trim().isEmpty) continue;

        // Check for required Xero fields
        expect(lines[i], contains('REC-'));
        expect(lines[i], contains('400')); // Account code
        expect(lines[i], contains('Tax on Purchases'));
      }

      // Step 4: Check batch processing for Xero
      final batches = exportService.createBatches(
        receipts,
        ExportFormat.xero,
      );

      expect(batches.length, equals(1)); // 30 receipts should fit in one Xero batch (limit 500)
    });

    test('Handle edge cases in export', () async {
      // Generate edge case receipts
      final edgeCases = dataGenerator.generateEdgeCaseReceipts();

      // Convert to Receipt objects, filtering invalid ones
      final receipts = <Receipt>[];
      for (final data in edgeCases) {
        if (data['merchant'] != null &&
            data['date'] != null &&
            data['total'] != null &&
            (data['total'] as num) > 0) {

          receipts.add(Receipt(
            id: data['id'] ?? 'edge-${receipts.length}',
            vendorName: data['merchant'],
            receiptDate: data['date'] as DateTime,
            totalAmount: (data['total'] as num).toDouble(),
            taxAmount: (data['tax'] as num?)?.toDouble(),
            notes: data['notes'],
            capturedAt: DateTime.now(),
            imagePath: 'test/edge.jpg',
            status: ReceiptStatus.ready,
            overallConfidence: 75.0,
          ));
        }
      }

      // Validate edge cases
      final validation = await exportService.validateForExport(
        receipts,
        ExportFormat.quickbooks,
      );

      // Even with edge cases, valid receipts should export
      if (receipts.isNotEmpty) {
        expect(validation.validCount, greaterThan(0));
      }

      // Generate CSV with sanitization
      final csvContent = exportService.generateCSVContent(
        receipts,
        ExportFormat.quickbooks,
      );

      // Verify CSV injection prevention
      expect(csvContent, isNot(contains('=FORMULA')));
      expect(csvContent, isNot(contains('+cmd.exe')));
      expect(csvContent, isNot(contains('-@SUM')));

      // Check that dangerous characters are sanitized
      final lines = csvContent.split('\n');
      for (final line in lines) {
        if (line.trim().isEmpty) continue;

        // Line should not start with dangerous characters
        expect(line[0], isNot(equals('=')));
        expect(line[0], isNot(equals('+')));
        expect(line[0], isNot(equals('-')));
        expect(line[0], isNot(equals('@')));
      }
    });

    test('Batch processing for large datasets', () async {
      // Generate large dataset
      final testData = dataGenerator.generateReceipts(count: 2500);
      final receipts = testData.map((data) => Receipt(
        id: data['id'] ?? 'bulk-id',
        vendorName: data['merchant'],
        receiptDate: data['date'] as DateTime,
        totalAmount: (data['total'] as num).toDouble(),
        taxAmount: (data['tax'] as num?)?.toDouble(),
        notes: data['notes'],
        capturedAt: DateTime.now(),
        imagePath: 'test/bulk.jpg',
        status: ReceiptStatus.ready,
        overallConfidence: 90.0,
      )).toList();

      // Test QuickBooks batching (1000 per batch)
      final qbBatches = exportService.createBatches(
        receipts,
        ExportFormat.quickbooks,
      );

      expect(qbBatches.length, equals(3)); // 2500 / 1000 = 3 batches
      expect(qbBatches[0].length, equals(1000));
      expect(qbBatches[1].length, equals(1000));
      expect(qbBatches[2].length, equals(500));

      // Test Xero batching (500 per batch)
      final xeroBatches = exportService.createBatches(
        receipts,
        ExportFormat.xero,
      );

      expect(xeroBatches.length, equals(5)); // 2500 / 500 = 5 batches
      for (int i = 0; i < 5; i++) {
        expect(xeroBatches[i].length, equals(500));
      }
    });

    test('Date format conversion accuracy', () async {
      // Test dates with different input formats
      final testDates = [
        '01/15/2024',  // MM/DD/YYYY
        '2024-03-20',  // YYYY-MM-DD
        '12/31/2023',  // MM/DD/YYYY
        '2025-01-01',  // YYYY-MM-DD
      ];

      final receipts = testDates.map((date) => Receipt(
        id: 'date-test',
        vendorName: 'Test Store',
        receiptDate: date,
        totalAmount: 100.00,
        capturedAt: DateTime.now(),
        imagePath: 'test/date.jpg',
        status: ReceiptStatus.ready,
        overallConfidence: 95.0,
      )).toList();

      // Test QuickBooks format (MM/DD/YYYY expected)
      final qbContent = exportService.generateCSVContent(
        receipts,
        ExportFormat.quickbooks,
      );

      expect(qbContent, contains('01/15/2024'));
      expect(qbContent, contains('03/20/2024'));
      expect(qbContent, contains('12/31/2023'));
      expect(qbContent, contains('01/01/2025'));

      // Test Xero format (DD/MM/YYYY expected)
      final xeroContent = exportService.generateCSVContent(
        receipts,
        ExportFormat.xero,
      );

      expect(xeroContent, contains('15/01/2024'));
      expect(xeroContent, contains('20/03/2024'));
      expect(xeroContent, contains('31/12/2023'));
      expect(xeroContent, contains('01/01/2025'));
    });

    test('Performance benchmark for export operations', () async {
      // Generate test data
      final sizes = [100, 500, 1000];

      for (final size in sizes) {
        final testData = dataGenerator.generateReceipts(count: size);
        final receipts = testData.map((data) => Receipt(
          id: data['id'] ?? 'perf-id',
          vendorName: data['merchant'],
          receiptDate: data['date'] as DateTime,
          totalAmount: (data['total'] as num).toDouble(),
          taxAmount: (data['tax'] as num?)?.toDouble(),
          notes: data['notes'],
          capturedAt: DateTime.now(),
          imagePath: 'test/perf.jpg',
          status: ReceiptStatus.ready,
          overallConfidence: 95.0,
        )).toList();

        // Measure validation time
        final validationStart = DateTime.now();
        await exportService.validateForExport(receipts, ExportFormat.quickbooks);
        final validationTime = DateTime.now().difference(validationStart);

        // Measure CSV generation time
        final generationStart = DateTime.now();
        exportService.generateCSVContent(receipts, ExportFormat.quickbooks);
        final generationTime = DateTime.now().difference(generationStart);

        // Performance assertions
        print('Size: $size receipts');
        print('  Validation: ${validationTime.inMilliseconds}ms');
        print('  Generation: ${generationTime.inMilliseconds}ms');

        // Check performance targets
        if (size == 100) {
          expect(generationTime.inMilliseconds, lessThan(100));
        } else if (size == 1000) {
          expect(generationTime.inMilliseconds, lessThan(500));
        }
      }
    });

    test('Export file creation and cleanup', () async {
      // Generate minimal test data
      final testData = dataGenerator.generateReceipts(count: 5);
      final receipts = testData.map((data) => Receipt(
        id: data['id'] ?? 'file-test',
        vendorName: data['merchant'],
        receiptDate: data['date'] as DateTime,
        totalAmount: (data['total'] as num).toDouble(),
        taxAmount: (data['tax'] as num?)?.toDouble(),
        notes: data['notes'],
        capturedAt: DateTime.now(),
        imagePath: 'test/file.jpg',
        status: ReceiptStatus.ready,
        overallConfidence: 95.0,
      )).toList();

      // Export to file
      final result = await exportService.exportToCSV(
        receipts,
        ExportFormat.quickbooks,
        customFileName: 'test_file_creation.csv',
      );

      expect(result.success, true);
      expect(result.filePath, isNotNull);
      expect(result.fileName, equals('test_file_creation.csv'));
      expect(result.recordCount, equals(5));

      // Verify file exists
      if (result.filePath != null) {
        final file = File(result.filePath!);
        expect(await file.exists(), true);

        // Read and verify content
        final content = await file.readAsString();
        expect(content, contains('Date,Description,Amount'));
        expect(content, contains('\uFEFF')); // BOM

        // Clean up test file
        await file.delete();
      }
    });
  });
}

// Helper function removed - now using DateTime directly

// Helper function to create Receipt with OCR data
Receipt _createTestReceipt(Map<String, dynamic> data) {
  final ocrResult = ProcessingResult(
    merchant: ExtractedField(
      value: data['merchant'],
      confidence: 95.0,
      boundingBox: null,
    ),
    date: ExtractedField(
      value: data['date'] is DateTime
        ? '${(data['date'] as DateTime).month.toString().padLeft(2, '0')}/${(data['date'] as DateTime).day.toString().padLeft(2, '0')}/${(data['date'] as DateTime).year}'
        : data['date'],
      confidence: 95.0,
      boundingBox: null,
    ),
    total: ExtractedField(
      value: data['total'] is num ? (data['total'] as num).toDouble() : data['total'],
      confidence: 95.0,
      boundingBox: null,
    ),
    tax: data['tax'] != null ? ExtractedField(
      value: data['tax'] is num ? (data['tax'] as num).toDouble() : data['tax'],
      confidence: 90.0,
      boundingBox: null,
    ) : null,
    rawText: 'Test OCR text',
    processedAt: DateTime.now(),
    overallConfidence: (data['confidence'] as num?)?.toDouble() ?? 95.0,
  );

  return Receipt(
    id: data['id'] ?? 'test-${DateTime.now().millisecondsSinceEpoch}',
    imageUri: 'test/image.jpg',
    capturedAt: DateTime.now(),
    status: ReceiptStatus.ready,
    ocrResults: ocrResult,
    notes: data['notes'],
  );
}