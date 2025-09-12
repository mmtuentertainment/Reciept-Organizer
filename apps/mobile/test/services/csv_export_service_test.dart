import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/domain/services/csv_export_service.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import '../test_config/test_setup.dart';

void main() {
  testWithSetup('CSVExportService', () {
    late ICSVExportService csvService;
    late List<Receipt> testReceipts;

    setUp(() async {
      // Test setup already configures path provider mock
      csvService = CSVExportService();
      
      // Create test receipts with OCR data
      testReceipts = [
        Receipt(
          id: 'receipt_1',
          imageUri: '/path/to/image1.jpg',
          capturedAt: DateTime(2024, 12, 6, 14, 30),
          batchId: 'batch_1',
          ocrResults: ProcessingResult(
            merchant: FieldData(value: 'Test Store 1', confidence: 90.0, originalText: 'Test Store 1'),
            date: FieldData(value: '12/06/2024', confidence: 85.0, originalText: '12/06/2024'),
            total: FieldData(value: 25.47, confidence: 95.0, originalText: '\$25.47'),
            tax: FieldData(value: 2.04, confidence: 88.0, originalText: '\$2.04'),
            overallConfidence: 89.5,
            processingDurationMs: 1200,
            allText: ['Test Store 1', '12/06/2024', 'Total: \$25.47'],
          ),
        ),
        Receipt(
          id: 'receipt_2',
          imageUri: '/path/to/image2.jpg',
          capturedAt: DateTime(2024, 12, 6, 15, 45),
          batchId: 'batch_1',
          ocrResults: ProcessingResult(
            merchant: FieldData(value: 'Coffee Shop', confidence: 87.0, originalText: 'Coffee Shop'),
            date: FieldData(value: '12/06/2024', confidence: 92.0, originalText: '12/06/2024'),
            total: FieldData(value: 8.75, confidence: 93.0, originalText: '\$8.75'),
            tax: FieldData(value: 0.70, confidence: 85.0, originalText: '\$0.70'),
            overallConfidence: 89.25,
            processingDurationMs: 980,
            allText: ['Coffee Shop', '12/06/2024', 'Total: \$8.75'],
          ),
        ),
      ];

      // Create test directory
      final testDir = Directory('/tmp/test_documents');
      if (!await testDir.exists()) {
        await testDir.create(recursive: true);
      }
    });

    tearDown(() async {
      // Clean up test files
      try {
        final testDir = Directory('/tmp/test_documents');
        if (await testDir.exists()) {
          await testDir.delete(recursive: true);
        }
      } catch (e) {
        // Ignore cleanup errors
      }
    });

    group('Validation', () {
      test('should validate receipts successfully for QuickBooks', () async {
        final validation = await csvService.validateForExport(testReceipts, ExportFormat.quickbooks);
        
        expect(validation.isValid, isTrue);
        expect(validation.errors, isEmpty);
        expect(validation.validCount, equals(2));
        expect(validation.totalCount, equals(2));
      });

      test('should validate receipts successfully for Xero', () async {
        final validation = await csvService.validateForExport(testReceipts, ExportFormat.xero);
        
        expect(validation.isValid, isTrue);
        expect(validation.errors, isEmpty);
        expect(validation.validCount, equals(2));
        expect(validation.totalCount, equals(2));
      });

      test('should validate receipts successfully for Generic', () async {
        final validation = await csvService.validateForExport(testReceipts, ExportFormat.generic);
        
        expect(validation.isValid, isTrue);
        expect(validation.errors, isEmpty);
        expect(validation.validCount, equals(2));
        expect(validation.totalCount, equals(2));
      });

      test('should detect missing merchant name', () async {
        final invalidReceipts = [
          Receipt(
            id: 'receipt_invalid',
            imageUri: '/path/to/image.jpg',
            ocrResults: ProcessingResult(
              merchant: null, // Missing merchant
              date: FieldData(value: '12/06/2024', confidence: 85.0, originalText: '12/06/2024'),
              total: FieldData(value: 25.47, confidence: 95.0, originalText: '\$25.47'),
              tax: FieldData(value: 2.04, confidence: 88.0, originalText: '\$2.04'),
              overallConfidence: 70.0,
              processingDurationMs: 1200,
              allText: ['12/06/2024', 'Total: \$25.47'],
            ),
          ),
        ];

        final validation = await csvService.validateForExport(invalidReceipts, ExportFormat.quickbooks);
        
        expect(validation.isValid, isFalse);
        expect(validation.errors, isNotEmpty);
        expect(validation.errors.first, contains('Missing merchant name'));
        expect(validation.validCount, equals(0));
      });

      test('should detect missing amounts', () async {
        final invalidReceipts = [
          Receipt(
            id: 'receipt_invalid',
            imageUri: '/path/to/image.jpg',
            ocrResults: ProcessingResult(
              merchant: FieldData(value: 'Test Store', confidence: 90.0, originalText: 'Test Store'),
              date: FieldData(value: '12/06/2024', confidence: 85.0, originalText: '12/06/2024'),
              total: null, // Missing total
              tax: null,
              overallConfidence: 60.0,
              processingDurationMs: 1200,
              allText: ['Test Store', '12/06/2024'],
            ),
          ),
        ];

        final validation = await csvService.validateForExport(invalidReceipts, ExportFormat.xero);
        
        expect(validation.isValid, isFalse);
        expect(validation.errors, isNotEmpty);
        expect(validation.errors.first, contains('Missing or invalid total amount'));
      });

      test('should generate warnings for low confidence', () async {
        final lowConfidenceReceipts = [
          Receipt(
            id: 'receipt_low_conf',
            imageUri: '/path/to/image.jpg',
            ocrResults: ProcessingResult(
              merchant: FieldData(value: 'Test Store', confidence: 60.0, originalText: 'Test Store'),
              date: FieldData(value: '12/06/2024', confidence: 65.0, originalText: '12/06/2024'),
              total: FieldData(value: 25.47, confidence: 65.0, originalText: '\$25.47'),
              tax: FieldData(value: 2.04, confidence: 60.0, originalText: '\$2.04'),
              overallConfidence: 62.5, // Low overall confidence
              processingDurationMs: 1200,
              allText: ['Test Store', '12/06/2024', 'Total: \$25.47'],
            ),
          ),
        ];

        final validation = await csvService.validateForExport(lowConfidenceReceipts, ExportFormat.quickbooks);
        
        expect(validation.isValid, isTrue);
        expect(validation.warnings, isNotEmpty);
        expect(validation.warnings.first, contains('Low OCR confidence'));
      });
    });

    group('CSV Generation', () {
      test('should generate QuickBooks CSV format', () {
        final csvContent = csvService.generateCSVContent(testReceipts, ExportFormat.quickbooks);
        
        expect(csvContent, contains('Date,Amount,Payee,Category,Memo,Tax'));
        expect(csvContent, contains('12/06/2024,25.47,Test Store 1,Business Expenses'));
        expect(csvContent, contains('12/06/2024,8.75,Coffee Shop,Business Expenses'));
      });

      test('should generate Xero CSV format', () {
        final csvContent = csvService.generateCSVContent(testReceipts, ExportFormat.xero);
        
        expect(csvContent, contains('Date,Amount,Payee,Description,Account Code,Tax Amount'));
        expect(csvContent, contains('12/06/2024,25.47,Test Store 1'));
        expect(csvContent, contains('400')); // Default account code
        expect(csvContent, contains('2.04')); // Tax amount
      });

      test('should generate Generic CSV format', () {
        final csvContent = csvService.generateCSVContent(testReceipts, ExportFormat.generic);
        
        expect(csvContent, contains('Receipt ID,Date,Merchant,Total Amount,Tax Amount'));
        expect(csvContent, contains('receipt_1,12/06/2024,Test Store 1,25.47,2.04'));
        expect(csvContent, contains('receipt_2,12/06/2024,Coffee Shop,8.75,0.70'));
        expect(csvContent, contains('89.5')); // Overall confidence
        expect(csvContent, contains('batch_1')); // Batch ID
      });

      test('should handle missing OCR data gracefully', () {
        final receiptsWithoutOCR = [
          Receipt(
            id: 'receipt_no_ocr',
            imageUri: '/path/to/image.jpg',
            capturedAt: DateTime(2024, 12, 6),
          ),
        ];

        final csvContent = csvService.generateCSVContent(receiptsWithoutOCR, ExportFormat.generic);
        
        expect(csvContent, contains('receipt_no_ocr'));
        expect(csvContent, contains(',,,')); // Empty fields for missing data
      });
    });

    group('File Export', () {
      test('should export receipts to CSV file successfully', () async {
        final result = await csvService.exportToCSV(
          testReceipts, 
          ExportFormat.quickbooks,
          customFileName: 'test_export.csv',
        );
        
        expect(result.success, isTrue);
        expect(result.error, isNull);
        expect(result.fileName, equals('test_export.csv'));
        expect(result.recordCount, equals(2));
        expect(result.filePath, isNotNull);
        
        // Verify file was created
        final file = File(result.filePath!);
        expect(await file.exists(), isTrue);
        
        // Verify file content
        final content = await file.readAsString();
        expect(content, contains('Test Store 1'));
        expect(content, contains('Coffee Shop'));
      });

      test('should generate automatic filename when none provided', () async {
        final result = await csvService.exportToCSV(testReceipts, ExportFormat.xero);
        
        expect(result.success, isTrue);
        expect(result.fileName, isNotNull);
        expect(result.fileName!.startsWith('receipts_xero_'), isTrue);
        expect(result.fileName!.endsWith('.csv'), isTrue);
      });

      test('should fail export with validation errors', () async {
        final invalidReceipts = [
          Receipt(
            id: 'invalid',
            imageUri: '/path/to/image.jpg',
            // No OCR results
          ),
        ];

        final result = await csvService.exportToCSV(invalidReceipts, ExportFormat.quickbooks);
        
        expect(result.success, isFalse);
        expect(result.error, isNotNull);
        expect(result.error, contains('Validation failed'));
      });
    });

    group('Required Fields', () {
      test('should return correct required fields for QuickBooks', () {
        final fields = csvService.getRequiredFields(ExportFormat.quickbooks);
        
        expect(fields, contains('Date'));
        expect(fields, contains('Amount'));
        expect(fields, contains('Payee'));
        expect(fields, contains('Category'));
      });

      test('should return correct required fields for Xero', () {
        final fields = csvService.getRequiredFields(ExportFormat.xero);
        
        expect(fields, contains('Date'));
        expect(fields, contains('Amount'));
        expect(fields, contains('Payee'));
        expect(fields, contains('Account Code'));
      });

      test('should return correct required fields for Generic', () {
        final fields = csvService.getRequiredFields(ExportFormat.generic);
        
        expect(fields, contains('Date'));
        expect(fields, contains('Amount'));
        expect(fields, contains('Merchant'));
      });
    });
  });

  group('ValidationResult', () {
    test('should create validation result with all properties', () {
      final result = ValidationResult(
        isValid: false,
        errors: ['Error 1', 'Error 2'],
        warnings: ['Warning 1'],
        validCount: 3,
        totalCount: 5,
      );
      
      expect(result.isValid, isFalse);
      expect(result.errors.length, equals(2));
      expect(result.warnings.length, equals(1));
      expect(result.validCount, equals(3));
      expect(result.totalCount, equals(5));
    });
  });

  group('ExportResult', () {
    test('should create success result', () {
      final result = ExportResult.success('/path/to/file.csv', 'file.csv', 10);
      
      expect(result.success, isTrue);
      expect(result.filePath, equals('/path/to/file.csv'));
      expect(result.fileName, equals('file.csv'));
      expect(result.recordCount, equals(10));
      expect(result.error, isNull);
    });

    test('should create error result', () {
      final result = ExportResult.error('Export failed');
      
      expect(result.success, isFalse);
      expect(result.error, equals('Export failed'));
      expect(result.filePath, isNull);
      expect(result.recordCount, equals(0));
    });
  });
}