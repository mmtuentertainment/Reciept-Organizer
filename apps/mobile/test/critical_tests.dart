/// Critical Tests for Receipt Organizer MVP
/// 
/// This file defines the minimal set of tests required for the MVP.
/// Target: 30-50 tests covering critical functionality only.
/// 
/// Based on CleanArchitectureTodoApp approach (12 tests for full app)

import 'package:flutter_test/flutter_test.dart';

// Critical test files to run
const criticalTests = [
  // Core Repository Tests (5)
  'test/unit/core/repositories/receipt_repository_test.dart',
  
  // OCR Service Tests (5) 
  'test/services/ocr_service_test.dart',
  
  // CSV Export Tests (5)
  'test/services/csv_export_service_test.dart',
  
  // Critical Integration Tests (10)
  'test/integration/capture_receipt_flow_test.dart',
  'test/integration/export_receipts_flow_test.dart',
  
  // UI Smoke Tests (5)
  'test/widget/receipts/receipt_list_screen_test.dart',
  'test/widget/capture/capture_screen_test.dart', 
  'test/widget/export/export_screen_test.dart',
];

void main() {
  group('Critical MVP Tests', () {
    test('placeholder - run with flutter test test/critical_tests.dart', () {
      print('Run critical tests with:');
      print('flutter test ${criticalTests.join(' ')}');
      expect(criticalTests.length, lessThanOrEqualTo(30));
    });
  });
}