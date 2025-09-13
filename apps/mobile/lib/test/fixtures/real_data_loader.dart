import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:csv/csv.dart';
import '../../core/models/receipt.dart';

/// Loads real transaction data from CSV files for testing
class RealDataLoader {
  static const String _defaultDataPath = 'test/fixtures/real_transaction_data.csv';
  
  /// Load real receipts from CSV file
  static Future<List<Receipt>> loadRealReceipts({
    String? csvPath,
    int? limit,
  }) async {
    final path = csvPath ?? _defaultDataPath;
    final file = File(path);
    
    if (!await file.exists()) {
      throw Exception('Data file not found: $path');
    }
    
    final csvString = await file.readAsString();
    final List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);
    
    if (rows.isEmpty) {
      return [];
    }
    
    // Skip header row
    final dataRows = rows.skip(1).take(limit ?? rows.length - 1);
    final receipts = <Receipt>[];
    
    for (final row in dataRows) {
      if (row.length >= 4) {
        receipts.add(_parseReceiptFromRow(row));
      }
    }
    
    return receipts;
  }
  
  /// Parse a CSV row into a Receipt object
  static Receipt _parseReceiptFromRow(List<dynamic> row) {
    // Expected format: Date,Merchant,Total,Tax,Category,Notes
    final dateStr = row[0].toString();
    final merchantName = row[1].toString();
    final totalAmount = _parseAmount(row[2]);
    final taxAmount = _parseAmount(row[3]);
    final category = row.length > 4 ? row[4].toString() : null;
    final notes = row.length > 5 ? row[5].toString() : null;
    
    return Receipt(
      id: 'real_${DateTime.now().millisecondsSinceEpoch}_${receipts.length}',
      merchantName: merchantName,
      date: _parseDate(dateStr),
      totalAmount: totalAmount,
      taxAmount: taxAmount,
      // category and notes are stored in ocrResults or metadata
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ocrResults: ProcessingResult(
        merchantName: StringFieldData(
          value: merchantName,
          confidence: 0.95 + (0.04 * _random.nextDouble()),
        ),
        totalAmount: DoubleFieldData(
          value: totalAmount,
          confidence: 0.96 + (0.03 * _random.nextDouble()),
        ),
        date: DateFieldData(
          value: _parseDate(dateStr),
          confidence: 0.94 + (0.05 * _random.nextDouble()),
        ),
        taxAmount: DoubleFieldData(
          value: taxAmount,
          confidence: 0.92 + (0.07 * _random.nextDouble()),
        ),
        processingEngine: 'ml_kit',
        processedAt: DateTime.now(),
        overallConfidence: 0.93 + (0.06 * _random.nextDouble()),
      ),
    );
  }
  
  /// Parse date from MM/DD/YYYY format
  static DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('/');
    if (parts.length != 3) {
      return DateTime.now();
    }
    
    try {
      final month = int.parse(parts[0]);
      final day = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (e) {
      return DateTime.now();
    }
  }
  
  /// Parse amount from string
  static double _parseAmount(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    
    final str = value.toString().replaceAll(RegExp(r'[^\d.-]'), '');
    return double.tryParse(str) ?? 0.0;
  }
  
  static final _random = Random(DateTime.now().millisecondsSinceEpoch);
  static final receipts = <Receipt>[];
  
  /// Get sample of real merchant names
  static List<String> getRealMerchantNames() {
    return [
      'Walmart', 'Target', 'Costco', 'Home Depot', 'Lowe\'s',
      'CVS Pharmacy', 'Walgreens', 'Rite Aid', 
      'Starbucks', 'McDonald\'s', 'Chipotle', 'Subway', 'Panera Bread',
      'Shell', 'Chevron', 'Exxon', 'BP', 'Speedway',
      'Amazon.com', 'Best Buy', 'Apple Store', 'GameStop',
      'Kroger', 'Safeway', 'Publix', 'Whole Foods', 'Trader Joe\'s',
      '7-Eleven', 'Circle K', 'Wawa',
      'Office Depot', 'Staples', 'FedEx Office', 'UPS Store',
      'AT&T', 'Verizon', 'T-Mobile',
      'Dollar Tree', 'Dollar General', 'Five Below',
    ];
  }
  
  /// Get sample of real categories
  static List<String> getRealCategories() {
    return [
      'Groceries', 'Food & Beverage', 'Transportation', 'Healthcare',
      'Office Supplies', 'Electronics', 'Clothing', 'Hardware',
      'Entertainment', 'Utilities', 'General Merchandise', 'Pet Supplies',
      'Personal Care', 'Automotive', 'Wholesale', 'Online Shopping',
    ];
  }
  
  /// Generate realistic receipt with random real merchant
  static Receipt generateRealisticReceipt({
    DateTime? date,
    String? merchantOverride,
  }) {
    final merchants = getRealMerchantNames();
    final categories = getRealCategories();
    final randomIndex = _random.nextInt(merchants.length);
    
    final merchant = merchantOverride ?? merchants[randomIndex];
    final category = categories[randomIndex % categories.length];
    final baseAmount = 10.0 + (_random.nextDouble() * 490.0);
    final taxRate = 0.06 + (_random.nextInt(4) * 0.01); // 6-10% tax
    final taxAmount = baseAmount * taxRate;
    final totalAmount = baseAmount + taxAmount;
    
    return Receipt(
      id: 'gen_${DateTime.now().millisecondsSinceEpoch}',
      merchantName: merchant,
      date: date ?? DateTime.now().subtract(Duration(days: _random.nextInt(90))),
      totalAmount: double.parse(totalAmount.toStringAsFixed(2)),
      taxAmount: double.parse(taxAmount.toStringAsFixed(2)),
      // category stored separately in app
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ocrResults: ProcessingResult(
        merchantName: StringFieldData(value: merchant, confidence: 0.95),
        totalAmount: DoubleFieldData(value: totalAmount, confidence: 0.98),
        date: DateFieldData(value: date ?? DateTime.now(), confidence: 0.94),
        taxAmount: DoubleFieldData(value: taxAmount, confidence: 0.91),
        processingEngine: 'ml_kit',
        processedAt: DateTime.now(),
        overallConfidence: 0.94,
      ),
    );
  }
}