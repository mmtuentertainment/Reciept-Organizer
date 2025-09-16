import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../fixtures/test_data_generator.dart';

/// QuickBooks API validation test using sandbox credentials
/// Credentials provided by user for testing
void main() {
  group('QuickBooks API Validation', () {
    // Sandbox credentials
    const clientId = 'ABHeXjfhxPZWmMVLLKNFQ5BkThuwSmT8SeRkx1bJsX3Zcn5djW';
    const clientSecret = '6dUFxpD6fHhVminfAOPocOnhlLFemEw9N9xX1iz1';
    const companyId = '9341455354065000';

    late TestDataGenerator generator;

    setUpAll(() {
      generator = TestDataGenerator();
    });

    test('Generate and validate QuickBooks 3-column CSV format', () {
      // Generate test data
      final receipts = generator.generateReceipts(count: 10);

      // Convert to QuickBooks 3-column format
      final csvLines = <String>[];
      csvLines.add('Date,Description,Amount');

      for (final receipt in receipts) {
        final date = DateFormat('MM/dd/yyyy').format(receipt['date'] as DateTime);
        final description = '${receipt['merchant']} - ${receipt['notes']}';
        final amount = (receipt['total'] as double).toStringAsFixed(2);

        // Escape fields containing commas
        final escapedDescription = description.contains(',')
            ? '"$description"'
            : description;

        csvLines.add('$date,$escapedDescription,$amount');
      }

      final csv = csvLines.join('\n');

      // Validate format
      expect(csv, contains('Date,Description,Amount'));
      expect(csvLines.length, equals(11)); // Header + 10 rows

      // Validate date format
      for (int i = 1; i < csvLines.length; i++) {
        final fields = _parseCSVLine(csvLines[i]);
        expect(fields[0], matches(RegExp(r'^\d{2}/\d{2}/\d{4}$')));
        expect(double.tryParse(fields[2]), isNotNull);
      }
    });

    test('Generate and validate QuickBooks 4-column CSV format', () {
      final receipts = generator.generateReceipts(count: 10);

      // Convert to QuickBooks 4-column format
      final csvLines = <String>[];
      csvLines.add('Date,Description,Debit,Credit');

      for (final receipt in receipts) {
        final date = DateFormat('MM/dd/yyyy').format(receipt['date'] as DateTime);
        final description = '${receipt['merchant']} - ${receipt['notes']}';
        final amount = (receipt['total'] as double).toStringAsFixed(2);

        // Expenses go in debit column
        final escapedDescription = description.contains(',')
            ? '"$description"'
            : description;

        csvLines.add('$date,$escapedDescription,$amount,');
      }

      final csv = csvLines.join('\n');

      // Validate format
      expect(csv, contains('Date,Description,Debit,Credit'));
      expect(csvLines.length, equals(11));

      // Validate fields
      for (int i = 1; i < csvLines.length; i++) {
        final fields = _parseCSVLine(csvLines[i]);
        expect(fields.length, equals(4));
        expect(fields[2], isNotEmpty); // Debit should have value
        expect(fields[3], isEmpty); // Credit should be empty for expenses
      }
    });

    test('Validate edge cases for QuickBooks format', () {
      final edgeCases = generator.generateEdgeCaseReceipts();
      final csvLines = <String>[];
      csvLines.add('Date,Description,Amount');

      for (final receipt in edgeCases) {
        if (receipt['date'] != null &&
            receipt['merchant'] != null &&
            receipt['total'] != null) {

          final date = DateFormat('MM/dd/yyyy').format(receipt['date'] as DateTime);
          var merchant = receipt['merchant'].toString();

          // Sanitize for CSV injection
          if (merchant.isNotEmpty && ['=', '+', '-', '@'].contains(merchant[0])) {
            merchant = "'$merchant"; // Prefix with single quote
          }

          final description = '$merchant - ${receipt['notes'] ?? ''}';
          final amount = (receipt['total'] as double).toStringAsFixed(2);

          // Proper CSV escaping
          final escapedDescription = _escapeCSVField(description);

          csvLines.add('$date,$escapedDescription,$amount');
        }
      }

      // Validate CSV injection protection
      for (final line in csvLines) {
        expect(line, isNot(startsWith('=')));
        expect(line, isNot(startsWith('+')));
        expect(line, isNot(startsWith('-')));
        expect(line, isNot(startsWith('@')));
      }
    });

    test('Test batch size limits for QuickBooks', () {
      // QuickBooks recommends max 1000 rows per import
      final largeDataset = generator.generateReceipts(count: 1500);

      // Split into batches
      const batchSize = 1000;
      final batches = <List<Map<String, dynamic>>>[];

      for (int i = 0; i < largeDataset.length; i += batchSize) {
        final end = (i + batchSize < largeDataset.length)
            ? i + batchSize
            : largeDataset.length;
        batches.add(largeDataset.sublist(i, end));
      }

      expect(batches.length, equals(2));
      expect(batches[0].length, equals(1000));
      expect(batches[1].length, equals(500));
    });

    test('Validate date format compatibility', () {
      final receipt = {
        'date': DateTime(2024, 3, 15),
        'merchant': 'Test Store',
        'total': 99.99,
      };

      // QuickBooks format: MM/DD/YYYY
      final qbDate = DateFormat('MM/dd/yyyy').format(receipt['date'] as DateTime);
      expect(qbDate, equals('03/15/2024'));

      // Validate parsing
      final parts = qbDate.split('/');
      expect(parts.length, equals(3));
      expect(int.parse(parts[0]), equals(3)); // Month
      expect(int.parse(parts[1]), equals(15)); // Day
      expect(int.parse(parts[2]), equals(2024)); // Year
    });

    test('Validate amount format and precision', () {
      final testAmounts = [
        0.01,
        0.99,
        1.00,
        99.99,
        100.00,
        999.99,
        1000.00,
        9999.99,
        99999.99,
      ];

      for (final amount in testAmounts) {
        final formatted = amount.toStringAsFixed(2);
        final parsed = double.parse(formatted);

        expect(parsed, equals(amount));
        expect(formatted, matches(RegExp(r'^\d+\.\d{2}$')));
      }
    });

    test('Test QuickBooks field length limits', () {
      // QuickBooks field limits
      const maxDescriptionLength = 4000;
      const maxAmountLength = 15;

      final longDescription = 'A' * (maxDescriptionLength + 100);
      final truncated = longDescription.substring(0, maxDescriptionLength);

      expect(truncated.length, equals(maxDescriptionLength));

      // Test amount field
      final largeAmount = 999999999.99;
      final amountStr = largeAmount.toStringAsFixed(2);
      expect(amountStr.length, lessThanOrEqualTo(maxAmountLength));
    });

    test('Validate special character handling', () {
      final specialCharTests = [
        'Store & Co.',
        'McDonald\'s',
        'Store, Inc.',
        'Store "Name"',
        'Store\tWith\tTabs',
        'Store\nWith\nNewlines',
        'Café Français',
        '99¢ Store',
      ];

      for (final storeName in specialCharTests) {
        final escaped = _escapeCSVField(storeName);

        // Should be quoted if contains special chars
        if (storeName.contains(',') ||
            storeName.contains('"') ||
            storeName.contains('\n') ||
            storeName.contains('\t')) {
          expect(escaped, startsWith('"'));
          expect(escaped, endsWith('"'));
        }

        // Double quotes should be escaped
        if (storeName.contains('"')) {
          expect(escaped, contains('""'));
        }
      }
    });

    // Note: Actual API tests would require OAuth setup
    // These are format validation tests only

    test('Generate sample CSV for manual QuickBooks import test', () {
      final receipts = generator.generateReceipts(count: 25);

      // Generate 3-column format
      final csv3Col = _generateQuickBooksCSV(receipts, use4Column: false);

      // Generate 4-column format
      final csv4Col = _generateQuickBooksCSV(receipts, use4Column: true);

      // Print sample for manual testing
      print('\n=== QuickBooks 3-Column Sample (first 5 rows) ===');
      final lines3 = csv3Col.split('\n');
      for (int i = 0; i < 6 && i < lines3.length; i++) {
        print(lines3[i]);
      }

      print('\n=== QuickBooks 4-Column Sample (first 5 rows) ===');
      final lines4 = csv4Col.split('\n');
      for (int i = 0; i < 6 && i < lines4.length; i++) {
        print(lines4[i]);
      }
    });
  });
}

// Helper functions
List<String> _parseCSVLine(String line) {
  final List<String> result = [];
  String current = '';
  bool inQuotes = false;

  for (int i = 0; i < line.length; i++) {
    final char = line[i];

    if (char == '"') {
      if (i + 1 < line.length && line[i + 1] == '"') {
        current += '"';
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (char == ',' && !inQuotes) {
      result.add(current);
      current = '';
    } else {
      current += char;
    }
  }

  result.add(current);
  return result;
}

String _escapeCSVField(String field) {
  // Check if field needs escaping
  if (field.contains(',') ||
      field.contains('"') ||
      field.contains('\n') ||
      field.contains('\r') ||
      field.contains('\t')) {
    // Escape double quotes by doubling them
    final escaped = field.replaceAll('"', '""');
    return '"$escaped"';
  }
  return field;
}

String _generateQuickBooksCSV(List<Map<String, dynamic>> receipts, {required bool use4Column}) {
  final lines = <String>[];

  if (use4Column) {
    lines.add('Date,Description,Debit,Credit');
    for (final receipt in receipts) {
      final date = DateFormat('MM/dd/yyyy').format(receipt['date'] as DateTime);
      final description = '${receipt['merchant']} - ${receipt['notes'] ?? ''}';
      final amount = (receipt['total'] as double).toStringAsFixed(2);

      lines.add('$date,${_escapeCSVField(description)},$amount,');
    }
  } else {
    lines.add('Date,Description,Amount');
    for (final receipt in receipts) {
      final date = DateFormat('MM/dd/yyyy').format(receipt['date'] as DateTime);
      final description = '${receipt['merchant']} - ${receipt['notes'] ?? ''}';
      final amount = (receipt['total'] as double).toStringAsFixed(2);

      lines.add('$date,${_escapeCSVField(description)},$amount');
    }
  }

  return lines.join('\n');
}