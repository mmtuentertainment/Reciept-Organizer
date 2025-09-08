#!/usr/bin/env dart

import 'dart:io';

/// Test script to verify CSV injection prevention
/// Run with: dart scripts/test_csv_injection_prevention.dart

void main() {
  print('CSV Injection Prevention Test');
  print('=============================\n');

  // Test cases for CSV injection attacks
  final testCases = [
    // Formula injection attempts
    TestCase('=1+1', "'=1+1", 'Formula with equals'),
    TestCase('+1+1', "'+1+1", 'Formula with plus'),
    TestCase('-1+1', "'-1+1", 'Formula with minus'),
    TestCase('@SUM(A1:A10)', "'@SUM(A1:A10)", 'Formula with at sign'),
    TestCase('=cmd|"/c calc"!A1', "'=cmd|\"/c calc\"!A1", 'Command injection'),
    TestCase('=HYPERLINK("http://malicious.com","Click")', "'=HYPERLINK(\"http://malicious.com\",\"Click\")", 'Hyperlink injection'),
    
    // Tab, CR, LF handling
    TestCase('Normal\ttext', 'Normal text', 'Tab character'),
    TestCase('Normal\rtext', 'Normal text', 'Carriage return'),
    TestCase('Normal\ntext', 'Normal text', 'Line feed'),
    TestCase('Mixed\t\r\ntext', 'Mixed   text', 'Multiple special chars'),
    
    // Normal text (should not be modified)
    TestCase('Normal merchant name', 'Normal merchant name', 'Normal text'),
    TestCase('Store #123', 'Store #123', 'Text with hash'),
    TestCase('Price: \$10.99', 'Price: \$10.99', 'Text with dollar sign'),
    TestCase('', '', 'Empty string'),
    TestCase('123.45', '123.45', 'Numeric string'),
    
    // Edge cases
    TestCase('====HEADER====', "'====HEADER====", 'Multiple equals at start'),
    TestCase(' =Formula', ' =Formula', 'Space before equals'),
    TestCase('Text = Value', 'Text = Value', 'Equals in middle'),
  ];

  int passed = 0;
  int failed = 0;

  for (final test in testCases) {
    final result = sanitizeForCSV(test.input);
    if (result == test.expected) {
      print('✓ ${test.description}');
      print('  Input:    "${test.input}"');
      print('  Output:   "$result"');
      passed++;
    } else {
      print('✗ ${test.description}');
      print('  Input:    "${test.input}"');
      print('  Expected: "${test.expected}"');
      print('  Actual:   "$result"');
      failed++;
    }
    print('');
  }

  print('\nSummary:');
  print('========');
  print('Passed: $passed');
  print('Failed: $failed');
  print('Total:  ${testCases.length}');
  
  if (failed > 0) {
    print('\n⚠️  CSV injection prevention needs improvement!');
    exit(1);
  } else {
    print('\n✅ All CSV injection tests passed!');
  }
}

/// Copy of the sanitization function from CSVExportService
String sanitizeForCSV(String? value) {
  if (value == null || value.isEmpty) return '';
  
  // Check if value starts with dangerous characters
  final firstChar = value.isEmpty ? '' : value[0];
  final dangerousChars = ['=', '+', '-', '@'];
  
  String sanitized = value;
  
  // If starts with dangerous character, prefix with single quote
  if (dangerousChars.contains(firstChar)) {
    sanitized = "'$value";
  }
  
  // Replace tabs, carriage returns, and line feeds
  sanitized = sanitized
      .replaceAll('\t', ' ')  // Replace tab with space
      .replaceAll('\r', ' ')  // Replace carriage return with space
      .replaceAll('\n', ' '); // Replace line feed with space
  
  return sanitized;
}

class TestCase {
  final String input;
  final String expected;
  final String description;

  TestCase(this.input, this.expected, this.description);
}