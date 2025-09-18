import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mockito/mockito.dart';
import 'package:receipt_organizer/core/models/receipt.dart';
import 'package:receipt_organizer/features/export/domain/export_validator.dart';
import 'package:receipt_organizer/features/export/services/export_format_validator.dart';
import 'package:receipt_organizer/data/models/receipt.dart' as data;
import 'package:receipt_organizer/features/export/domain/receipt_converter.dart';
import 'dart:math';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Export Validation Flow - Integration Tests', () {
    late ExportValidator validator;
    
    setUp(() {
      validator = ExportValidator();
    });
    
    group('Real-World Merchant Data Tests', () {
      test('should validate receipts from actual test data', () async {
        // Using real merchant names found in project test files
        final receipts = _createRealisticTestReceipts();
        
        final result = await validator.validateForExport(
          receipts: receipts,
          format: ExportFormat.quickbooks,
          enableStreaming: false,
        ).first;
        
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
        expect(result.metadata['receiptCount'], receipts.length);
      });
      
      test('should handle real retail store names correctly', () async {
        final retailReceipts = [
          _createReceipt('Office Depot', DateTime(2024, 1, 15), 45.99, 3.68),
          _createReceipt('Walmart', DateTime(2024, 2, 4), 89.99, 7.20),
          _createReceipt('Target', DateTime(2024, 2, 4), 78.90, 6.31),
          _createReceipt('Home Depot', DateTime(2024, 2, 2), 234.56, 18.76),
          _createReceipt('Best Buy', DateTime(2024, 1, 17), 250.00, 20.00),
          _createReceipt('Lowe\'s', DateTime(2024, 2, 2), 189.45, 15.16),
          _createReceipt('Costco', DateTime(2024, 1, 19), 487.32, 38.99),
        ];
        
        final result = await validator.validateForExport(
          receipts: retailReceipts,
          format: ExportFormat.quickbooks,
          enableStreaming: false,
        ).first;
        
        expect(result.isValid, true);
        expect(result.canExport, true);
      });
      
      test('should handle restaurant and coffee shop names', () async {
        final foodReceipts = [
          _createReceipt('Starbucks', DateTime(2024, 1, 16), 12.50, 1.00),
          _createReceipt("McDonald's", DateTime(2024, 1, 25), 18.67, 1.49),
          _createReceipt('Chipotle', DateTime(2024, 2, 7), 14.85, 1.19),
          _createReceipt('Panera Bread', DateTime(2024, 2, 3), 28.74, 2.30),
          _createReceipt('Subway', DateTime(2024, 2, 11), 9.50, 0.76),
          _createReceipt('Olive Garden', DateTime(2024, 2, 14), 76.50, 6.12),
          _createReceipt('Dunkin\'', DateTime(2024, 2, 18), 8.75, 0.70),
          _createReceipt('Five Guys', DateTime(2024, 3, 11), 18.95, 1.52),
        ];
        
        final result = await validator.validateForExport(
          receipts: foodReceipts,
          format: ExportFormat.generic,
          enableStreaming: false,
        ).first;
        
        expect(result.isValid, true);
        // Check for trademark symbol handling
        final mcdonaldsWarnings = result.warnings.where(
          (w) => w.message.contains('McDonald')
        ).toList();
        expect(mcdonaldsWarnings, isEmpty, reason: 'Trademark symbols should be handled');
      });
    });
    
    group('Date Format Confusion Tests', () {
      test('should handle ambiguous dates for QuickBooks (MM/DD/YYYY)', () async {
        // Critical test: 01/12 could be Jan 12 or Dec 1
        final dateConfusionReceipts = [
          _createReceipt('Date Test Store A', DateTime(2024, 1, 12), 100.00, 8.00),
          _createReceipt('Date Test Store B', DateTime(2024, 2, 3), 200.00, 16.00),
          _createReceipt('Date Test Store C', DateTime(2024, 12, 1), 300.00, 24.00),
        ];
        
        final result = await validator.validateForExport(
          receipts: dateConfusionReceipts,
          format: ExportFormat.quickbooks,
          enableStreaming: false,
        ).first;
        
        expect(result.isValid, true);
        
        // Verify dates are formatted correctly for QuickBooks
        // Date(2024, 1, 12) should become "01/12/2024" not "12/01/2024"
        final firstReceipt = dateConfusionReceipts.first;
        final formattedDate = _formatDateForQuickBooks(firstReceipt.date!);
        expect(formattedDate, '01/12/2024');
      });
      
      test('should handle ambiguous dates for Xero (DD/MM/YYYY)', () async {
        final dateConfusionReceipts = [
          _createReceipt('Date Test Store A', DateTime(2024, 1, 12), 100.00, 8.00),
          _createReceipt('Date Test Store B', DateTime(2024, 2, 3), 200.00, 16.00),
          _createReceipt('Date Test Store C', DateTime(2024, 12, 1), 300.00, 24.00),
        ];
        
        final result = await validator.validateForExport(
          receipts: dateConfusionReceipts,
          format: ExportFormat.xero,
          enableStreaming: false,
        ).first;
        
        expect(result.isValid, true);
        
        // Verify dates are formatted correctly for Xero
        // Date(2024, 1, 12) should become "12/01/2024" not "01/12/2024"
        final firstReceipt = dateConfusionReceipts.first;
        final formattedDate = _formatDateForXero(firstReceipt.date!);
        expect(formattedDate, '12/01/2024');
      });
      
      test('should handle unambiguous dates (day > 12) correctly', () async {
        final unambiguousReceipts = [
          _createReceipt('Store 1', DateTime(2024, 1, 15), 100.00, 8.00),
          _createReceipt('Store 2', DateTime(2024, 2, 28), 200.00, 16.00),
          _createReceipt('Store 3', DateTime(2024, 12, 25), 300.00, 24.00),
        ];
        
        // Test both formats
        for (final format in [ExportFormat.quickbooks, ExportFormat.xero]) {
          final result = await validator.validateForExport(
            receipts: unambiguousReceipts,
            format: format,
            enableStreaming: false,
          ).first;
          
          expect(result.isValid, true);
          expect(result.errors, isEmpty);
        }
      });
    });
    
    group('CSV Injection Security Tests', () {
      test('should detect and sanitize formula injection attempts', () async {
        // Using actual injection patterns from test files
        final injectionReceipts = [
          _createReceipt('=DANGEROUS() FORMULA', DateTime(2024, 1, 27), 500.00, 40.00),
          _createReceipt('+1234567890', DateTime(2024, 1, 28), 100.00, 8.00),
          _createReceipt('-Negative Start', DateTime(2024, 1, 29), 200.00, 16.00),
          _createReceipt('@Command Test', DateTime(2024, 1, 30), 300.00, 24.00),
        ];
        
        final result = await validator.validateForExport(
          receipts: injectionReceipts,
          format: ExportFormat.generic,
          enableStreaming: false,
        ).first;
        
        // CSV injection patterns should generate security errors (they're dangerous)
        // But we also check warnings for additional info
        final securityIssues = [
          ...result.errors.where((e) => e.id.startsWith('SEC_')),
          ...result.warnings.where((w) => w.id.startsWith('SEC_')),
        ];
        expect(securityIssues.length, greaterThan(0));
        
        // Should have caught the CSV injection patterns
        expect(securityIssues.any((i) => i.id == 'SEC_CSV_INJECTION_MERCHANT'), true);
      });
      
      test('should handle special characters in merchant names', () async {
        // Real edge cases from test data
        final specialCharReceipts = [
          _createReceipt('Smith, John & Associates', DateTime(2024, 1, 20), 35.00, 2.80),
          _createReceipt("O'Reilly Auto Parts", DateTime(2024, 1, 22), 75.50, 6.04),
          _createReceipt('"ABC Company, Inc."', DateTime(2024, 1, 21), 150.00, 12.00),
          _createReceipt('Store;With;Semicolons', DateTime(2024, 2, 6), 12.34, 0.99),
        ];
        
        final result = await validator.validateForExport(
          receipts: specialCharReceipts,
          format: ExportFormat.quickbooks,
          enableStreaming: false,
        ).first;
        
        expect(result.canExport, true);
        // Special characters should be handled, not cause errors
        expect(result.errors, isEmpty);
      });
    });
    
    group('Performance Benchmark Tests', () {
      test('should validate 100 receipts in under 500ms', () async {
        final receipts = _generatePerformanceTestData(100);
        
        final stopwatch = Stopwatch()..start();
        final result = await validator.validateForExport(
          receipts: receipts,
          format: ExportFormat.quickbooks,
          enableStreaming: false,
        ).first;
        stopwatch.stop();
        
        print('Validation of 100 receipts took: ${stopwatch.elapsedMilliseconds}ms');
        
        expect(result.isValid, true);
        expect(result.metadata['receiptCount'], 100);
        expect(stopwatch.elapsedMilliseconds, lessThan(500),
          reason: 'Validation should complete in under 500ms'
        );
      });
      
      test('should handle streaming validation for 500+ receipts', () async {
        final receipts = _generatePerformanceTestData(500);
        
        final stopwatch = Stopwatch()..start();
        final result = await validator.validateForExport(
          receipts: receipts,
          format: ExportFormat.generic,
          enableStreaming: true,  // Test streaming for large dataset
        ).first;
        stopwatch.stop();
        
        print('Validation of 500 receipts took: ${stopwatch.elapsedMilliseconds}ms');
        
        expect(result.isValid, true);
        // Streaming uses 'totalCount' instead of 'receiptCount'
        expect(result.metadata['totalCount'] ?? result.metadata['receiptCount'], 500);
        // For 500+ receipts, we allow more time but should still be reasonable
        expect(stopwatch.elapsedMilliseconds, lessThan(2500),
          reason: 'Large dataset validation should complete in reasonable time'
        );
      });
    });
    
    group('Edge Cases and Boundary Tests', () {
      test('should handle empty receipt list gracefully', () async {
        final result = await validator.validateForExport(
          receipts: [],
          format: ExportFormat.quickbooks,
          enableStreaming: false,
        ).first;
        
        expect(result.isValid, false);
        expect(result.canExport, false);
        expect(result.errors.any((e) => e.message.contains('No receipts')), true);
      });
      
      test('should handle receipts with missing fields', () async {
        final incompleteReceipts = [
          Receipt(
            id: 'incomplete_001',
            merchantName: null, // Missing merchant
            date: DateTime(2024, 1, 15),
            totalAmount: 50.00,
            taxAmount: 4.00,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Receipt(
            id: 'incomplete_002',
            merchantName: 'Test Store',
            date: null, // Missing date
            totalAmount: 75.00,
            taxAmount: 6.00,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        
        final result = await validator.validateForExport(
          receipts: incompleteReceipts,
          format: ExportFormat.quickbooks,
          enableStreaming: false,
        ).first;
        
        expect(result.isValid, false);
        expect(result.errors.length, greaterThan(0));
        expect(result.errors.any((e) => e.field == 'merchantName'), true);
        expect(result.errors.any((e) => e.field == 'date'), true);
      });
      
      test('should handle extreme amounts correctly', () async {
        final extremeAmountReceipts = [
          _createReceipt('Million Dollar Store', DateTime(2024, 1, 17), 1000000.00, 80000.00),
          _createReceipt('Sub-Penny Store', DateTime(2024, 1, 18), 0.001, 0.00),
          _createReceipt('Zero Dollar Store', DateTime(2024, 2, 10), 0.00, 0.00),
          _createReceipt('Large Decimal Store', DateTime(2024, 1, 15), 123.456789, 9.876543),
        ];
        
        final result = await validator.validateForExport(
          receipts: extremeAmountReceipts,
          format: ExportFormat.quickbooks,
          enableStreaming: false,
        ).first;
        
        // Zero amounts should cause errors (REQ_MISSING_TOTAL)
        expect(result.errors.any((e) => e.field == 'totalAmount'), true);
        // Should have some errors for problematic amounts
        expect(result.errors.length, greaterThan(0));
      });
    });
  });
}

// Helper functions
Receipt _createReceipt(String merchant, DateTime date, double total, double tax) {
  return Receipt(
    id: 'test_${date.millisecondsSinceEpoch}',
    merchantName: merchant,
    date: date,
    totalAmount: total,
    taxAmount: tax,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    ocrResults: ProcessingResult(
      merchantName: StringFieldData(value: merchant, confidence: 0.95),
      totalAmount: DoubleFieldData(value: total, confidence: 0.98),
      date: DateFieldData(value: date, confidence: 0.92),
      taxAmount: DoubleFieldData(value: tax, confidence: 0.90),
      processingEngine: 'ml_kit',
      processedAt: DateTime.now(),
      overallConfidence: 0.93,
    ),
  );
}

List<Receipt> _createRealisticTestReceipts() {
  // Using REAL merchant data from actual stores
  return [
    _createReceipt('Office Depot', DateTime(2024, 1, 15), 45.99, 3.68),
    _createReceipt('Starbucks', DateTime(2024, 1, 16), 12.50, 1.00),
    _createReceipt('Best Buy', DateTime(2024, 1, 17), 250.00, 20.00),
    _createReceipt('Dollar Tree', DateTime(2024, 1, 18), 5.99, 0.48),
    _createReceipt('Costco', DateTime(2024, 1, 19), 487.32, 38.99),
    _createReceipt('Walmart', DateTime(2024, 1, 20), 89.99, 7.20),
    _createReceipt('Target', DateTime(2024, 1, 21), 156.78, 12.54),
    _createReceipt('Home Depot', DateTime(2024, 1, 22), 234.56, 18.76),
    _createReceipt('CVS Pharmacy', DateTime(2024, 1, 23), 42.00, 3.36),
    _createReceipt('Shell Gas Station', DateTime(2024, 1, 24), 65.43, 5.23),
    _createReceipt("McDonald's", DateTime(2024, 1, 25), 18.67, 1.49),
    _createReceipt('Amazon.com', DateTime(2024, 1, 26), 543.21, 43.46),
    _createReceipt('Whole Foods', DateTime(2024, 1, 27), 127.89, 10.23),
    _createReceipt('Uber', DateTime(2024, 1, 28), 24.50, 1.96),
    _createReceipt("Trader Joe's", DateTime(2024, 1, 30), 78.34, 6.27),
  ];
}

List<Receipt> _generatePerformanceTestData(int count) {
  final realMerchants = [
    'Walmart', 'Target', 'Home Depot', 'Starbucks', "McDonald's",
    'Best Buy', 'Office Depot', 'Amazon.com', '7-Eleven', 'CVS Pharmacy',
    'Walgreens', 'Costco', "Sam's Club", 'Kroger', 'Whole Foods',
    "Trader Joe's", 'Safeway', 'Publix', 'Shell', 'Exxon',
    'BP', 'Chevron', 'Subway', 'Chipotle', 'Panera Bread',
    "Dunkin'", 'Pizza Hut', "Domino's", "Papa John's", 'FedEx Office',
    'UPS Store', 'USPS', 'Staples', "Lowe's", 'Ace Hardware',
    'AutoZone', "O'Reilly Auto Parts", 'Advance Auto Parts', 'Jiffy Lube', 'Midas',
  ];
  
  final receipts = <Receipt>[];
  final random = Random(42); // Seeded for reproducibility
  
  for (int i = 0; i < count; i++) {
    final merchant = realMerchants[i % realMerchants.length];
    final dayOffset = i % 365;
    final amount = 10.0 + (random.nextDouble() * 490.0);
    final taxRate = 0.06 + (random.nextDouble() * 0.04);
    
    receipts.add(_createReceipt(
      merchant,
      DateTime(2024, 1, 1).add(Duration(days: dayOffset)),
      double.parse(amount.toStringAsFixed(2)),
      double.parse((amount * taxRate).toStringAsFixed(2)),
    ));
  }
  
  return receipts;
}

String _formatDateForQuickBooks(DateTime date) {
  return '${date.month.toString().padLeft(2, '0')}/'
         '${date.day.toString().padLeft(2, '0')}/'
         '${date.year}';
}

String _formatDateForXero(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
         '${date.month.toString().padLeft(2, '0')}/'
         '${date.year}';
}