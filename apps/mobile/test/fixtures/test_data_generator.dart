import 'dart:math';
import 'package:intl/intl.dart';

/// Generates comprehensive test data for export format validation
class TestDataGenerator {
  final Random _random = Random(42); // Seed for reproducibility

  // Real merchant names for realistic testing
  static const List<String> merchants = [
    'Walmart',
    'Target Corporation',
    'Starbucks Coffee Company',
    'McDonald\'s',
    'Home Depot',
    'Amazon.com',
    'CVS Pharmacy',
    'Walgreens',
    '7-Eleven',
    'Best Buy',
    'Costco Wholesale',
    'Kroger',
    'Safeway',
    'Whole Foods Market',
    'Trader Joe\'s',
    'Office Depot',
    'Staples',
    'FedEx Office',
    'UPS Store',
    'Shell Gas Station',
    'Chevron',
    'ExxonMobil',
    'BP',
    'Subway',
    'Chipotle Mexican Grill',
    'Panera Bread',
    'Dunkin\'',
    'Pizza Hut',
    'Domino\'s Pizza',
    'Papa John\'s',
  ];

  // Edge case merchants with special characters
  static List<String> get edgeCaseMerchants {
    final longName = 'Very Long Store Name ' + ('X' * 200);
    return [
      'McDonald\'s',
      'H&M',
      'Barnes & Noble',
      'Toys "R" Us',
      'AT&T Store',
      'T.J. Maxx',
      'P.F. Chang\'s',
      'Ruth\'s Chris Steak House',
      'Trader Joe\'s #123',
      'CVS/pharmacy',
      '99¢ Only Stores',
      'café@home',
      '=FORMULA() Malicious Store', // CSV injection test
      '+cmd.exe Store', // CSV injection test
      '-@SUM(A1:A10) Shop', // CSV injection test
      '\tTabbed Store Name',
      'Store\nWith\nNewlines',
      longName, // Length test
    ];
  }

  // Generate a dataset of receipts
  List<Map<String, dynamic>> generateReceipts({
    required int count,
    bool includeEdgeCases = false,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    startDate ??= DateTime.now().subtract(const Duration(days: 365));
    endDate ??= DateTime.now();

    final receipts = <Map<String, dynamic>>[];
    final merchantList = includeEdgeCases
        ? [...merchants, ...edgeCaseMerchants]
        : merchants;

    for (int i = 0; i < count; i++) {
      receipts.add(_generateReceipt(
        id: 'REC-${i.toString().padLeft(6, '0')}',
        merchantList: merchantList,
        startDate: startDate,
        endDate: endDate,
        index: i,
      ));
    }

    return receipts;
  }

  // Generate edge case receipts for testing
  List<Map<String, dynamic>> generateEdgeCaseReceipts() {
    return [
      // Missing required fields
      {
        'id': 'EDGE-001',
        'merchant': null,
        'date': DateTime.now(),
        'total': 100.00,
        'notes': 'Missing merchant name',
      },
      {
        'id': 'EDGE-002',
        'merchant': 'Store',
        'date': null,
        'total': 50.00,
        'notes': 'Missing date',
      },
      {
        'id': 'EDGE-003',
        'merchant': 'Store',
        'date': DateTime.now(),
        'total': null,
        'notes': 'Missing total amount',
      },

      // Invalid date formats
      {
        'id': 'EDGE-004',
        'merchant': 'Store',
        'date': DateTime(1900, 1, 1), // Very old date
        'total': 100.00,
        'notes': 'Date too old',
      },
      {
        'id': 'EDGE-005',
        'merchant': 'Store',
        'date': DateTime.now().add(const Duration(days: 30)), // Future date
        'total': 100.00,
        'notes': 'Future date',
      },

      // Extreme amounts
      {
        'id': 'EDGE-006',
        'merchant': 'Luxury Store',
        'date': DateTime.now(),
        'total': 999999.99, // Maximum reasonable amount
        'tax': 99999.99,
        'notes': 'Very large amount',
      },
      {
        'id': 'EDGE-007',
        'merchant': 'Penny Store',
        'date': DateTime.now(),
        'total': 0.01, // Minimum amount
        'tax': 0.00,
        'notes': 'Minimum amount',
      },
      {
        'id': 'EDGE-008',
        'merchant': 'Zero Store',
        'date': DateTime.now(),
        'total': 0.00, // Zero amount
        'tax': 0.00,
        'notes': 'Zero amount',
      },

      // Currency formatting variations
      {
        'id': 'EDGE-009',
        'merchant': 'International Store',
        'date': DateTime.now(),
        'total': 1234.567, // More than 2 decimal places
        'tax': 123.456,
        'notes': 'Extra decimal places',
      },
      {
        'id': 'EDGE-010',
        'merchant': 'Negative Store',
        'date': DateTime.now(),
        'total': -50.00, // Negative amount (refund)
        'tax': -5.00,
        'notes': 'Refund transaction',
      },

      // Special characters in descriptions
      {
        'id': 'EDGE-011',
        'merchant': 'Store "with quotes"',
        'date': DateTime.now(),
        'total': 100.00,
        'notes': 'Description with "quotes" and commas, semicolons; etc.',
      },
      {
        'id': 'EDGE-012',
        'merchant': 'Store,with,commas',
        'date': DateTime.now(),
        'total': 100.00,
        'notes': 'Commas,everywhere,in,the,text',
      },
      {
        'id': 'EDGE-013',
        'merchant': 'Store\twith\ttabs',
        'date': DateTime.now(),
        'total': 100.00,
        'notes': 'Tabs\tin\tthe\ttext',
      },

      // Unicode and international characters
      {
        'id': 'EDGE-014',
        'merchant': 'Café Français',
        'date': DateTime.now(),
        'total': 100.00,
        'notes': 'Accented characters: café, naïve, résumé',
      },
      {
        'id': 'EDGE-015',
        'merchant': '東京ストア',
        'date': DateTime.now(),
        'total': 100.00,
        'notes': 'Japanese characters: ありがとう',
      },
      {
        'id': 'EDGE-016',
        'merchant': '🏪 Emoji Store 🛍️',
        'date': DateTime.now(),
        'total': 100.00,
        'notes': 'Emojis in text 😀💰📱',
      },

      // Very long descriptions
      {
        'id': 'EDGE-017',
        'merchant': 'A' * 255, // Max length test
        'date': DateTime.now(),
        'total': 100.00,
        'notes': 'B' * 500, // Very long notes
      },

      // CSV injection attempts
      {
        'id': 'EDGE-018',
        'merchant': '=1+1',
        'date': DateTime.now(),
        'total': 100.00,
        'notes': '=SUM(A1:A10)',
      },
      {
        'id': 'EDGE-019',
        'merchant': '+cmd.exe',
        'date': DateTime.now(),
        'total': 100.00,
        'notes': '-@SUM(A:A)',
      },
      {
        'id': 'EDGE-020',
        'merchant': '@IMPORT',
        'date': DateTime.now(),
        'total': 100.00,
        'notes': '\r\n=HYPERLINK("http://evil.com")',
      },
    ];
  }

  // Generate receipts for specific accounting software formats
  Map<String, List<Map<String, dynamic>>> generateFormatSpecificData() {
    return {
      'quickbooks_3col': _generateQuickBooksData(useDebitCredit: false),
      'quickbooks_4col': _generateQuickBooksData(useDebitCredit: true),
      'xero': _generateXeroData(),
      'generic': _generateGenericData(),
    };
  }

  // Private helper methods
  Map<String, dynamic> _generateReceipt({
    required String id,
    required List<String> merchantList,
    required DateTime startDate,
    required DateTime endDate,
    required int index,
  }) {
    final daysDiff = endDate.difference(startDate).inDays;
    final randomDays = _random.nextInt(daysDiff + 1);
    final date = startDate.add(Duration(days: randomDays));

    final merchant = merchantList[_random.nextInt(merchantList.length)];
    final subtotal = _random.nextDouble() * 500 + 10; // $10-$510
    final taxRate = _random.nextDouble() * 0.15; // 0-15% tax
    final tax = subtotal * taxRate;
    final total = subtotal + tax;

    final categories = ['Food', 'Office', 'Travel', 'Supplies', 'Entertainment'];
    final category = categories[_random.nextInt(categories.length)];

    return {
      'id': id,
      'merchant': merchant,
      'date': date,
      'subtotal': double.parse(subtotal.toStringAsFixed(2)),
      'tax': double.parse(tax.toStringAsFixed(2)),
      'total': double.parse(total.toStringAsFixed(2)),
      'category': category,
      'notes': 'Receipt #$index - $category purchase',
      'confidence': 0.85 + _random.nextDouble() * 0.15, // 85-100%
      'ocrText': 'Raw OCR text for $merchant on ${DateFormat('MM/dd/yyyy').format(date)}',
    };
  }

  List<Map<String, dynamic>> _generateQuickBooksData({required bool useDebitCredit}) {
    final receipts = generateReceipts(count: 100);

    return receipts.map((r) {
      if (useDebitCredit) {
        // 4-column format: Date, Description, Debit, Credit
        return {
          'Date': DateFormat('MM/dd/yyyy').format(r['date'] as DateTime),
          'Description': '${r['merchant']} - ${r['notes']}',
          'Debit': (r['total'] as double).toStringAsFixed(2),
          'Credit': '', // Expenses go in debit column
        };
      } else {
        // 3-column format: Date, Description, Amount
        return {
          'Date': DateFormat('MM/dd/yyyy').format(r['date'] as DateTime),
          'Description': '${r['merchant']} - ${r['notes']}',
          'Amount': (r['total'] as double).toStringAsFixed(2),
        };
      }
    }).toList();
  }

  List<Map<String, dynamic>> _generateXeroData() {
    final receipts = generateReceipts(count: 100);

    return receipts.map((r) {
      return {
        'ContactName': r['merchant'],
        'InvoiceNumber': r['id'],
        'InvoiceDate': DateFormat('dd/MM/yyyy').format(r['date'] as DateTime),
        'DueDate': DateFormat('dd/MM/yyyy').format(r['date'] as DateTime),
        'Description': r['notes'],
        'Quantity': '1',
        'UnitAmount': ((r['total'] as double) - (r['tax'] as double)).toStringAsFixed(2),
        'AccountCode': _getAccountCode(r['category'] as String),
        'TaxType': 'Tax on Purchases',
        'TaxAmount': (r['tax'] as double).toStringAsFixed(2),
      };
    }).toList();
  }

  List<Map<String, dynamic>> _generateGenericData() {
    final receipts = generateReceipts(count: 100);

    return receipts.map((r) {
      return {
        'Date': DateFormat('yyyy-MM-dd').format(r['date'] as DateTime),
        'Merchant': r['merchant'],
        'Total': (r['total'] as double).toStringAsFixed(2),
        'Tax': (r['tax'] as double).toStringAsFixed(2),
        'Category': r['category'],
        'Notes': r['notes'],
      };
    }).toList();
  }

  String _getAccountCode(String category) {
    final codes = {
      'Food': '429', // General Expenses
      'Office': '469', // Office Expenses
      'Travel': '493', // Travel Expenses
      'Supplies': '473', // Office Supplies
      'Entertainment': '420', // Entertainment
    };
    return codes[category] ?? '429';
  }

  // Generate performance test datasets
  List<Map<String, dynamic>> generatePerformanceDataset(int size) {
    final sizes = {
      'small': 10,
      'medium': 100,
      'large': 1000,
      'xlarge': 5000,
      'huge': 10000,
    };

    return generateReceipts(
      count: size,
      includeEdgeCases: size <= 100, // Only include edge cases for smaller sets
    );
  }

  // Validate generated data
  Map<String, dynamic> validateDataset(List<Map<String, dynamic>> dataset) {
    final validation = {
      'totalRecords': dataset.length,
      'validRecords': 0,
      'invalidRecords': 0,
      'missingFields': <String, int>{},
      'invalidAmounts': 0,
      'invalidDates': 0,
      'suspiciousContent': 0,
    };

    for (final record in dataset) {
      bool isValid = true;

      // Check required fields
      if (record['merchant'] == null || record['merchant'].toString().isEmpty) {
        final missingFields = validation['missingFields'] as Map<String, int>;
        missingFields['merchant'] = (missingFields['merchant'] ?? 0) + 1;
        isValid = false;
      }

      if (record['date'] == null) {
        final missingFields = validation['missingFields'] as Map<String, int>;
        missingFields['date'] = (missingFields['date'] ?? 0) + 1;
        isValid = false;
      }

      if (record['total'] == null) {
        final missingFields = validation['missingFields'] as Map<String, int>;
        missingFields['total'] = (missingFields['total'] ?? 0) + 1;
        isValid = false;
      }

      // Validate amounts
      if (record['total'] != null) {
        final total = record['total'];
        if (total is num && (total < 0 || total > 999999.99)) {
          validation['invalidAmounts'] = (validation['invalidAmounts'] as int) + 1;
          isValid = false;
        }
      }

      // Validate dates
      if (record['date'] != null && record['date'] is DateTime) {
        final date = record['date'] as DateTime;
        final now = DateTime.now();
        final twoYearsAgo = now.subtract(const Duration(days: 730));

        if (date.isBefore(twoYearsAgo) || date.isAfter(now)) {
          validation['invalidDates'] = (validation['invalidDates'] as int) + 1;
          isValid = false;
        }
      }

      // Check for CSV injection
      final textFields = [
        record['merchant']?.toString() ?? '',
        record['notes']?.toString() ?? '',
      ];

      for (final text in textFields) {
        if (text.isNotEmpty && ['=', '+', '-', '@'].contains(text[0])) {
          validation['suspiciousContent'] = (validation['suspiciousContent'] as int) + 1;
          isValid = false;
          break;
        }
      }

      if (isValid) {
        validation['validRecords'] = (validation['validRecords'] as int) + 1;
      } else {
        validation['invalidRecords'] = (validation['invalidRecords'] as int) + 1;
      }
    }

    validation['validationRate'] =
        (validation['validRecords'] as int) / dataset.length * 100;

    return validation;
  }
}