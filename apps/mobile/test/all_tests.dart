import 'package:flutter_test/flutter_test.dart';
import 'test_config/test_setup.dart';

// Import all test files
import 'mocks/simple_mock_test.dart' as mock_tests;
import 'contracts/i_receipt_repository_contract_test.dart' as contract_tests;

// Import other test suites (add as needed)
// import 'unit/...' as unit_tests;
// import 'widget/...' as widget_tests;
// import 'integration/...' as integration_tests;

void main() async {
  // Initialize test environment once for all tests
  setUpAll(() async {
    await TestSetup.initializeTestEnvironment();
  });
  
  // Clean up after all tests
  tearDownAll(() async {
    await TestSetup.tearDownTestEnvironment();
  });
  
  // Run all test suites
  group('All Tests', () {
    group('Mock Tests', () {
      mock_tests.main();
    });
    
    // Add other test groups as needed
    // group('Unit Tests', unit_tests.main);
    // group('Widget Tests', widget_tests.main);
    // group('Integration Tests', integration_tests.main);
  });
}