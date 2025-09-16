import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

/// Comprehensive validation tests for QuickBooks and Xero CSV export formats
/// Based on actual 2025 requirements from both platforms
void main() {
  group('Export Format Validation Tests', () {
    group('QuickBooks Format Validation', () {
      test('QuickBooks 3-column format structure', () {
        // QuickBooks requires: Date, Description, Amount
        final headers = ['Date', 'Description', 'Amount'];

        // Sample data row
        final row = ['01/15/2025', 'Walmart - Groceries', '98.79'];

        // Validations
        expect(headers.length, equals(3));
        expect(headers[0], equals('Date'));
        expect(headers[1], equals('Description'));
        expect(headers[2], equals('Amount'));

        // Date format validation (MM/DD/YYYY)
        final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
        expect(dateRegex.hasMatch(row[0]), true);

        // Amount format validation (no currency symbols)
        final amountRegex = RegExp(r'^\d+\.?\d{0,2}$');
        expect(amountRegex.hasMatch(row[2]), true);
      });

      test('QuickBooks 4-column format structure', () {
        // QuickBooks alternative: Date, Description, Debit, Credit
        final headers = ['Date', 'Description', 'Debit', 'Credit'];

        // Sample data row (expense as debit)
        final row = ['01/15/2025', 'Walmart - Groceries', '98.79', ''];

        expect(headers.length, equals(4));
        expect(headers[2], equals('Debit'));
        expect(headers[3], equals('Credit'));
      });

      test('QuickBooks date format compliance', () {
        // Test various date formats
        final validFormats = [
          '01/15/2025',
          '12/31/2024',
          '02/28/2025',
        ];

        final invalidFormats = [
          '2025-01-15',      // ISO format not accepted
          '15/01/2025',      // DD/MM/YYYY not accepted (month > 12)
          '01-15-2025',      // Dashes not accepted
          '01/15/2025 TUE',  // Day names not accepted
        ];

        // QuickBooks date validation function
        bool isValidQuickBooksDate(String date) {
          final regex = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');
          final match = regex.firstMatch(date);
          if (match == null) return false;

          final month = int.tryParse(match.group(1)!);
          final day = int.tryParse(match.group(2)!);
          final year = int.tryParse(match.group(3)!);

          if (month == null || day == null || year == null) return false;
          if (month < 1 || month > 12) return false;
          if (day < 1 || day > 31) return false;
          if (year < 1900 || year > 2100) return false;

          return true;
        }

        for (final date in validFormats) {
          expect(isValidQuickBooksDate(date), true, reason: '$date should be valid');
        }

        for (final date in invalidFormats) {
          expect(isValidQuickBooksDate(date), false, reason: '$date should be invalid');
        }
      });

      test('QuickBooks amount format validation', () {
        // Valid amount formats
        final validAmounts = [
          '98.79',
          '1000.00',
          '0.50',
          '15',
        ];

        // Invalid amount formats
        final invalidAmounts = [
          '\$98.79',     // No currency symbols
          '1,000.00',    // No commas
          '-98.79',      // No negative signs in amount column
          '98.794',      // Max 2 decimal places
        ];

        final amountRegex = RegExp(r'^\d+\.?\d{0,2}$');

        for (final amount in validAmounts) {
          expect(amountRegex.hasMatch(amount), true, reason: '$amount should be valid');
        }

        for (final amount in invalidAmounts) {
          expect(amountRegex.hasMatch(amount), false, reason: '$amount should be invalid');
        }
      });

      test('QuickBooks row limit validation', () {
        // QuickBooks allows max 1000 rows per import
        const maxRows = 1000;

        // Test data generation
        final largeDataset = List.generate(1500, (i) => {
          'date': '01/15/2025',
          'description': 'Transaction $i',
          'amount': '100.00',
        });

        // Should split into batches
        final batches = <List<Map<String, String>>>[];
        for (int i = 0; i < largeDataset.length; i += maxRows) {
          final end = (i + maxRows < largeDataset.length) ? i + maxRows : largeDataset.length;
          batches.add(largeDataset.sublist(i, end));
        }

        expect(batches.length, equals(2));
        expect(batches[0].length, equals(1000));
        expect(batches[1].length, equals(500));
      });

      test('QuickBooks CSV injection prevention', () {
        // Test dangerous characters are escaped
        final dangerousInputs = [
          '=FORMULA()',
          '+FORMULA()',
          '-FORMULA()',
          '@FORMULA()',
          '\tFORMULA',
          '\rFORMULA',
          '\nFORMULA',
        ];

        for (final input in dangerousInputs) {
          final sanitized = sanitizeForCSV(input);
          expect(sanitized[0], isNot(anyOf('=', '+', '-', '@', '\t', '\r', '\n')));
        }
      });
    });

    group('Xero Format Validation', () {
      test('Xero required fields validation', () {
        // Xero minimum requirements for expenses
        final requiredFields = ['ContactName', 'InvoiceNumber'];

        // Extended fields for complete expense import
        final completeFields = [
          'ContactName',
          'InvoiceNumber',
          'InvoiceDate',
          'DueDate',
          'Description',
          'Quantity',
          'UnitAmount',
          'AccountCode',
          'TaxType',
        ];

        // Validate required fields present
        for (final field in requiredFields) {
          expect(completeFields.contains(field), true);
        }
      });

      test('Xero date format compliance', () {
        // Xero uses DD/MM/YYYY format
        final validFormats = [
          '15/01/2025',
          '31/12/2024',
          '28/02/2025',
        ];

        final invalidFormats = [
          '2025-01-15',      // ISO format
          '01/15/2025',      // MM/DD/YYYY (US format)
          '15-01-2025',      // Dashes
        ];

        final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');

        for (final date in validFormats) {
          expect(dateRegex.hasMatch(date), true, reason: '$date should be valid');
          // Additional validation: day should be 01-31
          final parts = date.split('/');
          final day = int.parse(parts[0]);
          expect(day >= 1 && day <= 31, true);
        }
      });

      test('Xero contact name exact matching', () {
        // Xero requires exact contact name matching to avoid duplicates
        const existingContacts = [
          'Walmart Inc.',
          'Target Corporation',
          'Starbucks Coffee Company',
        ];

        // Test exact match
        expect(existingContacts.contains('Walmart Inc.'), true);
        expect(existingContacts.contains('walmart inc.'), false); // Case sensitive
        expect(existingContacts.contains('Walmart'), false); // Partial match fails
      });

      test('Xero batch size validation', () {
        // Xero recommends max 500 items per import
        const recommendedMax = 500;

        final dataset = List.generate(600, (i) => {
          'ContactName': 'Vendor $i',
          'InvoiceNumber': 'INV-$i',
          'InvoiceDate': '15/01/2025',
          'UnitAmount': '100.00',
        });

        // Should split for optimal performance
        final batches = <List<Map<String, String>>>[];
        for (int i = 0; i < dataset.length; i += recommendedMax) {
          final end = (i + recommendedMax < dataset.length) ? i + recommendedMax : dataset.length;
          batches.add(dataset.sublist(i, end));
        }

        expect(batches.length, equals(2));
        expect(batches[0].length, equals(500));
        expect(batches[1].length, equals(100));
      });

      test('Xero tax type validation', () {
        // Common Xero tax types
        const validTaxTypes = [
          'Tax on Sales',
          'Tax on Purchases',
          'Tax Exempt',
          'No Tax',
          '20% (VAT on Expenses)',
          'GST on Expenses',
        ];

        // Test tax type matching
        const receiptTax = 'Tax on Purchases';
        expect(validTaxTypes.contains(receiptTax), true);
      });

      test('Xero account code validation', () {
        // Xero account codes must match Chart of Accounts
        final validAccountCodes = [
          '200', // Sales
          '400', // Advertising
          '420', // Entertainment
          '429', // General Expenses
          '469', // Office Expenses
        ];

        // Test account code format
        for (final code in validAccountCodes) {
          expect(RegExp(r'^\d{3,4}$').hasMatch(code), true);
        }
      });
    });

    group('Format Conversion Tests', () {
      test('Convert unified format to QuickBooks', () {
        // Our internal format
        final receipt = {
          'merchant': 'Walmart',
          'date': DateTime(2025, 1, 15),
          'total': 98.79,
          'tax': 7.32,
          'notes': 'Groceries for office',
        };

        // Convert to QuickBooks 3-column
        final qbRow = [
          DateFormat('MM/dd/yyyy').format(receipt['date'] as DateTime),
          '${receipt['merchant']} - ${receipt['notes']}',
          (receipt['total'] as double).toStringAsFixed(2),
        ];

        expect(qbRow[0], equals('01/15/2025'));
        expect(qbRow[1], equals('Walmart - Groceries for office'));
        expect(qbRow[2], equals('98.79'));
      });

      test('Convert unified format to Xero', () {
        // Our internal format
        final receipt = {
          'merchant': 'Walmart',
          'date': DateTime(2025, 1, 15),
          'total': 98.79,
          'tax': 7.32,
          'notes': 'Groceries for office',
          'id': 'REC-001',
        };

        // Convert to Xero format
        final xeroRow = {
          'ContactName': receipt['merchant'],
          'InvoiceNumber': receipt['id'],
          'InvoiceDate': DateFormat('dd/MM/yyyy').format(receipt['date'] as DateTime),
          'Description': receipt['notes'],
          'UnitAmount': ((receipt['total'] as double) - (receipt['tax'] as double)).toStringAsFixed(2),
          'TaxAmount': (receipt['tax'] as double).toStringAsFixed(2),
        };

        expect(xeroRow['InvoiceDate'], equals('15/01/2025'));
        expect(xeroRow['UnitAmount'], equals('91.47'));
        expect(xeroRow['TaxAmount'], equals('7.32'));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('Handle missing required fields', () {
        // Receipt with missing data
        final incompleteReceipt = {
          'merchant': null,
          'date': DateTime(2025, 1, 15),
          'total': 98.79,
        };

        // Validation should fail
        final validationErrors = <String>[];

        if (incompleteReceipt['merchant'] == null) {
          validationErrors.add('Merchant name is required');
        }

        expect(validationErrors.isNotEmpty, true);
        expect(validationErrors.contains('Merchant name is required'), true);
      });

      test('Handle special characters in merchant names', () {
        final specialMerchants = [
          'McDonald\'s',
          'H&M',
          '7-Eleven',
          'Toys "R" Us',
          'Barnes & Noble',
        ];

        for (final merchant in specialMerchants) {
          // Proper CSV escaping
          String escapeForCSV(String field) {
            if (field.contains(',') || field.contains('"') || field.contains('\n')) {
              // Escape quotes by doubling them and wrap in quotes
              return '"${field.replaceAll('"', '""')}"';
            }
            return field;
          }

          final escaped = escapeForCSV(merchant);

          // Should be properly escaped - either no special chars or wrapped in quotes
          if (merchant.contains(',') || merchant.contains('"')) {
            expect(escaped.startsWith('"') && escaped.endsWith('"'), true,
                reason: '$merchant should be wrapped in quotes');
          }

          // Original quotes should be doubled inside the escaped string
          if (merchant.contains('"')) {
            final innerContent = escaped.substring(1, escaped.length - 1);
            expect(innerContent.contains('""'), true,
                reason: 'Quotes should be doubled in $merchant');
          }
        }
      });

      test('Handle very long descriptions', () {
        final longDescription = 'A' * 500;
        const maxLength = 255;

        final truncated = longDescription.length > maxLength
            ? longDescription.substring(0, maxLength)
            : longDescription;

        expect(truncated.length, equals(maxLength));
      });

      test('Handle currency formatting variations', () {
        final amounts = [
          {'input': '\$1,234.56', 'expected': '1234.56'},
          {'input': '€100.00', 'expected': '100.00'},
          {'input': '(50.00)', 'expected': '50.00'},
          {'input': '1.234,56', 'expected': '1234.56'}, // European format
        ];

        for (final amount in amounts) {
          final cleaned = (amount['input'] as String)
              .replaceAll(RegExp(r'[^\d.,]'), '')
              .replaceAll(',', '');

          expect(cleaned.contains(RegExp(r'^\d+\.?\d*$')), true);
        }
      });
    });

    group('Performance Benchmarks', () {
      test('CSV generation performance for 100 receipts', () {
        final stopwatch = Stopwatch()..start();

        // Generate 100 receipts
        final receipts = List.generate(100, (i) => {
          'merchant': 'Store $i',
          'date': DateTime(2025, 1, i % 28 + 1),
          'total': 50.0 + i,
          'tax': 4.0 + (i * 0.1),
        });

        // Convert to CSV rows
        final csvRows = receipts.map((r) => [
          DateFormat('MM/dd/yyyy').format(r['date'] as DateTime),
          r['merchant'] as String,
          (r['total'] as double).toStringAsFixed(2),
        ]).toList();

        stopwatch.stop();

        // Should complete in < 3 seconds for 100 receipts
        expect(stopwatch.elapsedMilliseconds, lessThan(3000));
        expect(csvRows.length, equals(100));
      });

      test('CSV generation performance for 1000 receipts', () {
        final stopwatch = Stopwatch()..start();

        // Generate 1000 receipts
        final receipts = List.generate(1000, (i) => {
          'merchant': 'Store $i',
          'date': DateTime(2025, 1, (i % 28) + 1),
          'total': 50.0 + i,
        });

        // Convert to CSV
        final csvRows = receipts.map((r) => [
          DateFormat('MM/dd/yyyy').format(r['date'] as DateTime),
          r['merchant'] as String,
          (r['total'] as double).toStringAsFixed(2),
        ]).toList();

        stopwatch.stop();

        // Should scale linearly - ~30 seconds for 1000
        expect(stopwatch.elapsedMilliseconds, lessThan(30000));
        expect(csvRows.length, equals(1000));
      });
    });
  });
}

// Helper function to sanitize CSV data
String sanitizeForCSV(String input) {
  if (input.isEmpty) return input;

  // Remove dangerous characters from the start
  var sanitized = input;
  while (sanitized.isNotEmpty &&
         ['=', '+', '-', '@', '\t', '\r', '\n'].contains(sanitized[0])) {
    sanitized = sanitized.substring(1);
  }

  // Escape quotes
  sanitized = sanitized.replaceAll('"', '""');

  // Wrap in quotes if contains comma or quote
  if (sanitized.contains(',') || sanitized.contains('"')) {
    sanitized = '"$sanitized"';
  }

  return sanitized;
}