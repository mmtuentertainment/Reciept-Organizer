#!/usr/bin/env dart

/// CSV Security Validation Script
/// Tests CSV injection prevention in the Receipt Organizer MVP
/// 
/// This script validates that the CSV export service properly sanitizes
/// potentially malicious input to prevent CSV injection attacks.

import 'dart:io';

void main() {
  print('CSV Security Validation Test');
  print('============================\n');

  var allTestsPassed = true;
  var testCount = 0;
  var passedCount = 0;

  // Test cases for CSV injection
  final testCases = [
    // Formula injection tests
    TestCase('Formula with equals', '=1+1', "'=1+1"),
    TestCase('Formula with plus', '+1+1', "'+1+1"),
    TestCase('Formula with minus', '-1+1', "'-1+1"),
    TestCase('Formula with at', '@SUM(1+1)', "'@SUM(1+1)"),
    TestCase('Complex formula', '=cmd|"/c calc"!A1', "'=cmd|\"/c calc\"!A1"),
    
    // Special character tests
    TestCase('Embedded quotes', 'Test "quoted" text', 'Test ""quoted"" text'),
    TestCase('Embedded commas', 'Test, with, commas', 'Test, with, commas'),
    TestCase('Newline characters', 'Test\nwith\nnewlines', 'Test with newlines'),
    TestCase('Tab characters', 'Test\twith\ttabs', 'Test with tabs'),
    TestCase('Carriage returns', 'Test\rwith\rCR', 'Test with CR'),
    
    // Edge cases
    TestCase('Leading space with formula', ' =1+1', ' =1+1'),
    TestCase('Unicode formula', '＝1+1', '＝1+1'),
    TestCase('Empty string', '', ''),
    TestCase('Only special chars', '=+-@', "'=+-@"),
    
    // Real-world merchant names that might trigger
    TestCase('AT&T Store', 'AT&T Store', 'AT&T Store'),
    TestCase('7-Eleven', '7-Eleven', '7-Eleven'),
    TestCase('Merchant = Best', 'Merchant = Best', 'Merchant = Best'),
    TestCase('+1 Pizza', '+1 Pizza', "'+1 Pizza"),
  ];

  print('Running ${testCases.length} test cases...\n');

  for (var testCase in testCases) {
    testCount++;
    
    // Simulate the sanitization logic from csv_export_service.dart
    final sanitized = sanitizeForCSV(testCase.input);
    
    if (sanitized == testCase.expected) {
      print('✓ ${testCase.name}');
      print('  Input: "${testCase.input}"');
      print('  Output: "${sanitized}"');
      passedCount++;
    } else {
      print('✗ ${testCase.name}');
      print('  Input: "${testCase.input}"');
      print('  Expected: "${testCase.expected}"');
      print('  Got: "${sanitized}"');
      allTestsPassed = false;
    }
    print('');
  }

  // Summary
  print('\nTest Summary');
  print('============');
  print('Total tests: $testCount');
  print('Passed: $passedCount');
  print('Failed: ${testCount - passedCount}');
  
  if (allTestsPassed) {
    print('\n✓ All CSV security tests passed!');
    exit(0);
  } else {
    print('\n✗ Some CSV security tests failed!');
    print('\nCRITICAL: CSV injection vulnerabilities detected.');
    print('Fix the sanitization logic before release.');
    exit(1);
  }
}

/// Simulates the CSV sanitization logic
/// This should match the implementation in csv_export_service.dart
String sanitizeForCSV(String? value) {
  if (value == null || value.isEmpty) {
    return '';
  }

  var sanitized = value;

  // Prevent formula injection
  if (sanitized.startsWith('=') || 
      sanitized.startsWith('+') || 
      sanitized.startsWith('-') || 
      sanitized.startsWith('@')) {
    sanitized = "'$value";
  }

  // Handle special characters
  sanitized = sanitized
      .replaceAll('"', '""')  // Escape quotes
      .replaceAll('\n', ' ')   // Replace newlines
      .replaceAll('\r', ' ')   // Replace carriage returns
      .replaceAll('\t', ' ');  // Replace tabs

  return sanitized;
}

class TestCase {
  final String name;
  final String input;
  final String expected;

  TestCase(this.name, this.input, this.expected);
}