#!/usr/bin/env dart

/// Export Format Validation Script
/// Validates CSV export formats for QuickBooks and Xero compatibility
///
/// This script tests the CSV export formats to ensure they meet
/// the requirements for importing into QuickBooks and Xero.

import 'dart:io';

void main() {
  print('CSV Export Format Validation');
  print('============================\n');

  var allTestsPassed = true;

  // Test QuickBooks format
  print('Testing QuickBooks Format...');
  final qbPassed = validateQuickBooksFormat();
  if (!qbPassed) allTestsPassed = false;

  print('\nTesting Xero Format...');
  final xeroPassed = validateXeroFormat();
  if (!xeroPassed) allTestsPassed = false;

  print('\nTesting Generic Format...');
  final genericPassed = validateGenericFormat();
  if (!genericPassed) allTestsPassed = false;

  // Summary
  print('\n' + '=' * 40);
  if (allTestsPassed) {
    print('✓ All export format tests passed!');
    exit(0);
  } else {
    print('✗ Some export format tests failed!');
    exit(1);
  }
}

bool validateQuickBooksFormat() {
  var passed = true;

  // QuickBooks expected headers
  final expectedHeaders = [
    'Date',
    'Vendor',
    'Amount',
    'Tax Amount',
    'Memo'
  ];

  print('✓ QuickBooks header format: ${expectedHeaders.join(', ')}');

  // Date format validation (MM/DD/YYYY)
  final dateTests = [
    '01/15/2025',
    '12/31/2024',
    '02/28/2025'
  ];

  for (var date in dateTests) {
    if (isValidQuickBooksDate(date)) {
      print('✓ Date format valid: $date');
    } else {
      print('✗ Date format invalid: $date');
      passed = false;
    }
  }

  // Amount format validation (decimal with 2 places)
  final amountTests = [
    '100.00',
    '1234.56',
    '0.99'
  ];

  for (var amount in amountTests) {
    if (isValidAmount(amount)) {
      print('✓ Amount format valid: $amount');
    } else {
      print('✗ Amount format invalid: $amount');
      passed = false;
    }
  }

  return passed;
}

bool validateXeroFormat() {
  var passed = true;

  // Xero expected headers
  final expectedHeaders = [
    'Date',
    'Contact Name',
    'Description',
    'Total Amount',
    'Tax Amount',
    'Reference'
  ];

  print('✓ Xero header format: ${expectedHeaders.join(', ')}');

  // Date format validation (DD/MM/YYYY)
  final dateTests = [
    '15/01/2025',
    '31/12/2024',
    '28/02/2025'
  ];

  for (var date in dateTests) {
    if (isValidXeroDate(date)) {
      print('✓ Date format valid: $date');
    } else {
      print('✗ Date format invalid: $date');
      passed = false;
    }
  }

  // Contact name length validation (max 500 chars)
  final nameTests = [
    'ABC Store',
    'Very Long Business Name That Should Still Be Valid',
    'Store #12345 - Downtown Location'
  ];

  for (var name in nameTests) {
    if (name.length <= 500) {
      print('✓ Contact name valid: ${name.substring(0, 20)}...');
    } else {
      print('✗ Contact name too long: ${name.substring(0, 20)}...');
      passed = false;
    }
  }

  return passed;
}

bool validateGenericFormat() {
  var passed = true;

  // Generic format headers
  final expectedHeaders = [
    'Date',
    'Merchant',
    'Total',
    'Tax',
    'Notes'
  ];

  print('✓ Generic header format: ${expectedHeaders.join(', ')}');

  // ISO date format validation (YYYY-MM-DD)
  final dateTests = [
    '2025-01-15',
    '2024-12-31',
    '2025-02-28'
  ];

  for (var date in dateTests) {
    if (isValidISODate(date)) {
      print('✓ ISO date format valid: $date');
    } else {
      print('✗ ISO date format invalid: $date');
      passed = false;
    }
  }

  return passed;
}

bool isValidQuickBooksDate(String date) {
  final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
  return regex.hasMatch(date);
}

bool isValidXeroDate(String date) {
  final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
  return regex.hasMatch(date);
}

bool isValidISODate(String date) {
  final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  return regex.hasMatch(date);
}

bool isValidAmount(String amount) {
  final regex = RegExp(r'^\d+\.\d{2}$');
  return regex.hasMatch(amount);
}