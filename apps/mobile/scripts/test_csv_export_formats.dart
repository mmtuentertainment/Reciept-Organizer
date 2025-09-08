#!/usr/bin/env dart

import 'dart:io';
import 'package:csv/csv.dart';

/// Test script to generate sample CSV exports for QuickBooks/Xero validation
/// Run with: dart scripts/test_csv_export_formats.dart

void main() {
  print('CSV Export Format Test');
  print('=====================\n');

  // Create test data
  final testReceipts = [
    {
      'id': 'test-001',
      'date': '01/08/2025',
      'merchant': 'Office Supplies Store',
      'total': 45.99,
      'tax': 3.68,
      'notes': 'Printer paper and pens',
    },
    {
      'id': 'test-002',
      'date': '01/09/2025',
      'merchant': "Joe's Coffee Shop",
      'total': 12.50,
      'tax': 1.00,
      'notes': 'Client meeting',
    },
    {
      'id': 'test-003',
      'date': '01/10/2025',
      'merchant': 'Gas Station #42',
      'total': 65.00,
      'tax': 5.20,
      'notes': 'Business travel',
    },
    // Edge case with special characters
    {
      'id': 'test-004',
      'date': '01/11/2025',
      'merchant': '=Dangerous Shop',
      'total': 100.00,
      'tax': 8.00,
      'notes': 'Testing CSV injection prevention',
    },
  ];

  // Generate QuickBooks format
  print('1. QuickBooks Format CSV');
  print('------------------------');
  final quickBooksCSV = generateQuickBooksCSV(testReceipts);
  print(quickBooksCSV);
  
  // Save QuickBooks sample
  File('exports/sample_quickbooks.csv').writeAsStringSync(quickBooksCSV);
  print('\nSaved to: exports/sample_quickbooks.csv');
  
  print('\n2. Xero Format CSV');
  print('------------------');
  final xeroCSV = generateXeroCSV(testReceipts);
  print(xeroCSV);
  
  // Save Xero sample
  File('exports/sample_xero.csv').writeAsStringSync(xeroCSV);
  print('\nSaved to: exports/sample_xero.csv');
  
  print('\n3. Generic Format CSV');
  print('---------------------');
  final genericCSV = generateGenericCSV(testReceipts);
  print(genericCSV);
  
  // Save generic sample
  File('exports/sample_generic.csv').writeAsStringSync(genericCSV);
  print('\nSaved to: exports/sample_generic.csv');
  
  print('\n✅ Sample CSV files generated!');
  print('\nNext steps:');
  print('1. Import sample_quickbooks.csv into QuickBooks Online');
  print('2. Import sample_xero.csv into Xero');
  print('3. Verify all fields import correctly');
  print('4. Check that CSV injection prevention worked (merchant "=Dangerous Shop")');
}

String generateQuickBooksCSV(List<Map<String, dynamic>> receipts) {
  // QuickBooks format: Date, Amount, Payee, Category, Memo, Tax, Notes
  final headers = ['Date', 'Amount', 'Payee', 'Category', 'Memo', 'Tax', 'Notes'];
  final rows = <List<String>>[headers];
  
  for (final receipt in receipts) {
    rows.add([
      receipt['date'] as String,
      (receipt['total'] as double).toStringAsFixed(2),
      sanitizeForCSV(receipt['merchant'] as String),
      'Business Expenses',
      'Receipt #${receipt['id']}',
      (receipt['tax'] as double).toStringAsFixed(2),
      sanitizeForCSV(receipt['notes'] as String),
    ]);
  }
  
  // Add UTF-8 BOM for Excel compatibility
  const bom = '\uFEFF';
  return bom + const ListToCsvConverter().convert(rows);
}

String generateXeroCSV(List<Map<String, dynamic>> receipts) {
  // Xero format: Date, Amount, Payee, Description, Account Code, Tax Amount, Notes
  final headers = ['Date', 'Amount', 'Payee', 'Description', 'Account Code', 'Tax Amount', 'Notes'];
  final rows = <List<String>>[headers];
  
  for (final receipt in receipts) {
    rows.add([
      receipt['date'] as String,
      (receipt['total'] as double).toStringAsFixed(2),
      sanitizeForCSV(receipt['merchant'] as String),
      'Business expense - Receipt #${receipt['id']}',
      '400', // Default expense account code
      (receipt['tax'] as double).toStringAsFixed(2),
      sanitizeForCSV(receipt['notes'] as String),
    ]);
  }
  
  // Add UTF-8 BOM for Excel compatibility
  const bom = '\uFEFF';
  return bom + const ListToCsvConverter().convert(rows);
}

String generateGenericCSV(List<Map<String, dynamic>> receipts) {
  // Generic format: All available fields
  final headers = [
    'Receipt ID',
    'Date',
    'Merchant',
    'Total Amount',
    'Tax Amount',
    'Notes'
  ];
  final rows = <List<String>>[headers];
  
  for (final receipt in receipts) {
    rows.add([
      receipt['id'] as String,
      receipt['date'] as String,
      sanitizeForCSV(receipt['merchant'] as String),
      (receipt['total'] as double).toStringAsFixed(2),
      (receipt['tax'] as double).toStringAsFixed(2),
      sanitizeForCSV(receipt['notes'] as String),
    ]);
  }
  
  // Add UTF-8 BOM for Excel compatibility
  const bom = '\uFEFF';
  return bom + const ListToCsvConverter().convert(rows);
}

String sanitizeForCSV(String? value) {
  if (value == null || value.isEmpty) return '';
  
  final firstChar = value.isEmpty ? '' : value[0];
  final dangerousChars = ['=', '+', '-', '@'];
  
  String sanitized = value;
  
  if (dangerousChars.contains(firstChar)) {
    sanitized = "'$value";
  }
  
  sanitized = sanitized
      .replaceAll('\t', ' ')
      .replaceAll('\r', ' ')
      .replaceAll('\n', ' ');
  
  return sanitized;
}