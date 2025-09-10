import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/features/export/domain/export_validator.dart';
import 'package:receipt_organizer/core/models/receipt.dart';

void main() {
  group('ExportValidator', () {
    late ExportValidator validator;

    setUp(() {
      validator = ExportValidator();
    });

    group('validateForExport', () {
      test('should return error for empty receipt list', () async {
        final stream = validator.validateForExport(
          receipts: [],
          format: ExportFormat.generic,
        );

        final result = await stream.first;
        
        expect(result.isValid, false);
        expect(result.errors.length, 1);
        expect(result.errors.first.id, 'EMPTY_LIST');
        expect(result.errors.first.severity, ValidationSeverity.error);
      });

      test('should validate single valid receipt', () async {
        final receipt = Receipt(
          id: '1',
          merchantName: 'Test Store',
          date: DateTime.now().subtract(const Duration(days: 10)),
          totalAmount: 50.99,
          taxAmount: 3.50,
          createdAt: DateTime.now(),
        );

        final stream = validator.validateForExport(
          receipts: [receipt],
          format: ExportFormat.generic,
        );

        final result = await stream.first;
        
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
        expect(result.canExport, true);
      });

      test('should detect missing required fields', () async {
        final receipt = Receipt(
          id: '1',
          merchantName: null, // Missing merchant
          date: null, // Missing date
          totalAmount: null, // Missing total
          createdAt: DateTime.now(),
        );

        final stream = validator.validateForExport(
          receipts: [receipt],
          format: ExportFormat.generic,
        );

        final result = await stream.first;
        
        expect(result.isValid, false);
        expect(result.errors.length, greaterThanOrEqualTo(3));
        expect(
          result.errors.any((e) => e.id == 'REQ_MISSING_DATE'),
          true,
        );
        expect(
          result.errors.any((e) => e.id == 'REQ_MISSING_TOTAL'),
          true,
        );
        expect(
          result.errors.any((e) => e.id == 'REQ_MISSING_MERCHANT'),
          true,
        );
      });

      test('should detect CSV injection in merchant name', () async {
        final receipt = Receipt(
          id: '1',
          merchantName: '=cmd.exe', // CSV injection attempt
          date: DateTime.now(),
          totalAmount: 50.00,
          createdAt: DateTime.now(),
        );

        final stream = validator.validateForExport(
          receipts: [receipt],
          format: ExportFormat.generic,
        );

        final result = await stream.first;
        
        expect(result.isValid, false);
        expect(
          result.errors.any((e) => e.id.contains('CSV_INJECTION')),
          true,
        );
      });

      test('should validate tax not exceeding total', () async {
        final receipt = Receipt(
          id: '1',
          merchantName: 'Test Store',
          date: DateTime.now(),
          totalAmount: 50.00,
          taxAmount: 60.00, // Tax exceeds total
          createdAt: DateTime.now(),
        );

        final stream = validator.validateForExport(
          receipts: [receipt],
          format: ExportFormat.xero,
        );

        final result = await stream.first;
        
        expect(result.isValid, false);
        expect(
          result.errors.any((e) => e.id == 'XERO_TAX_EXCEEDS_TOTAL'),
          true,
        );
      });

      test('should validate negative amounts', () async {
        final receipt = Receipt(
          id: '1',
          merchantName: 'Test Store',
          date: DateTime.now(),
          totalAmount: -50.00, // Negative amount
          createdAt: DateTime.now(),
        );

        final stream = validator.validateForExport(
          receipts: [receipt],
          format: ExportFormat.quickbooks,
        );

        final result = await stream.first;
        
        expect(result.isValid, false);
        expect(
          result.errors.any((e) => e.id == 'QB_NEGATIVE_AMOUNT'),
          true,
        );
      });

      test('should warn about old dates', () async {
        final receipt = Receipt(
          id: '1',
          merchantName: 'Test Store',
          date: DateTime.now().subtract(const Duration(days: 1000)), // Old date
          totalAmount: 50.00,
          createdAt: DateTime.now(),
        );

        final stream = validator.validateForExport(
          receipts: [receipt],
          format: ExportFormat.generic,
        );

        final result = await stream.first;
        
        expect(result.canExport, true); // Can export with warnings
        expect(result.warnings.isNotEmpty, true);
      });

      test('should handle special characters that need escaping', () async {
        final receipt = Receipt(
          id: '1',
          merchantName: 'Store, Inc.', // Contains comma
          date: DateTime.now(),
          totalAmount: 50.00,
          createdAt: DateTime.now(),
        );

        final stream = validator.validateForExport(
          receipts: [receipt],
          format: ExportFormat.generic,
        );

        final result = await stream.first;
        
        expect(result.canExport, true);
        expect(
          result.info.any((i) => i.id == 'SEC_SPECIAL_CHARS'),
          true,
        );
      });

      test('should validate QuickBooks specific requirements', () async {
        final receipt = Receipt(
          id: '1',
          merchantName: 'Test Store',
          date: DateTime(1800, 1, 1), // Date too old for QuickBooks
          totalAmount: 50.00,
          createdAt: DateTime.now(),
        );

        final stream = validator.validateForExport(
          receipts: [receipt],
          format: ExportFormat.quickbooks,
        );

        final result = await stream.first;
        
        expect(result.isValid, false);
        expect(
          result.errors.any((e) => e.id == 'QB_INVALID_DATE_RANGE'),
          true,
        );
      });

      test('should validate Xero specific requirements', () async {
        final receipt = Receipt(
          id: '1',
          merchantName: '', // Empty merchant (required for Xero ContactName)
          date: DateTime.now(),
          totalAmount: 50.00,
          createdAt: DateTime.now(),
        );

        final stream = validator.validateForExport(
          receipts: [receipt],
          format: ExportFormat.xero,
        );

        final result = await stream.first;
        
        expect(result.isValid, false);
        expect(
          result.errors.any((e) => e.id.contains('MISSING_MERCHANT')),
          true,
        );
      });

      test('should stream progress for large datasets', () async {
        final receipts = List.generate(250, (i) => Receipt(
          id: '$i',
          merchantName: 'Store $i',
          date: DateTime.now(),
          totalAmount: 50.00 + i,
          createdAt: DateTime.now(),
        ));

        final stream = validator.validateForExport(
          receipts: receipts,
          format: ExportFormat.generic,
          enableStreaming: true,
        );

        final results = await stream.toList();
        
        expect(results.length, greaterThan(1)); // Multiple progress updates
        expect(results.last.metadata['progress'], 1.0);
        expect(results.last.metadata['totalCount'], 250);
      });

      test('should categorize issues by severity correctly', () async {
        final receipt = Receipt(
          id: '1',
          merchantName: 'Store, Inc.', // Info: special chars
          date: DateTime.now().subtract(const Duration(days: 1000)), // Warning: old
          totalAmount: null, // Error: missing
          createdAt: DateTime.now(),
        );

        final stream = validator.validateForExport(
          receipts: [receipt],
          format: ExportFormat.generic,
        );

        final result = await stream.first;
        
        expect(result.errors.isNotEmpty, true);
        expect(result.warnings.isNotEmpty, true);
        expect(result.info.isNotEmpty, true);
        expect(result.canExport, false); // Blocked by errors
      });

      test('should include metadata in validation result', () async {
        final receipt = Receipt(
          id: '1',
          merchantName: 'Test Store',
          date: DateTime.now(),
          totalAmount: 50.00,
          createdAt: DateTime.now(),
        );

        final stream = validator.validateForExport(
          receipts: [receipt],
          format: ExportFormat.quickbooks,
        );

        final result = await stream.first;
        
        expect(result.metadata['format'], 'ExportFormat.quickbooks');
        expect(result.metadata['receiptCount'], 1);
        expect(result.metadata['validatedAt'], isNotNull);
      });
    });
  });
}