import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/domain/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import '../helpers/platform_test_helpers.dart';

/// Global test setup that configures all necessary mocks and services
/// for the entire test suite.
/// 
/// This setup ensures:
/// - ServiceLocator is initialized with mock implementations
/// - SharedPreferences is properly mocked
/// - PathProvider is mocked to avoid file system access
/// - All tests run in a clean, isolated environment
class TestSetup {
  static bool _isInitialized = false;
  
  /// Initialize test environment with all necessary mocks
  static Future<void> initializeTestEnvironment() async {
    if (_isInitialized) {
      return;
    }
    
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Setup path provider mock
    setupPathProviderForTests();
    
    // Setup SharedPreferences mock
    SharedPreferences.setMockInitialValues({});
    
    // Initialize ServiceLocator with mock implementations
    if (ServiceLocator.isInitialized) {
      await ServiceLocator.reset();
    }
    
    await ServiceLocator.initialize(
      environment: ServiceEnvironment.local,
      useMocks: true,
    );
    
    _isInitialized = true;
  }
  
  /// Reset test environment between test groups
  static Future<void> resetTestEnvironment() async {
    // Clear SharedPreferences
    SharedPreferences.setMockInitialValues({});
    
    // Reset ServiceLocator and reinitialize
    if (ServiceLocator.isInitialized) {
      await ServiceLocator.reset();
    }
    
    await ServiceLocator.initialize(
      environment: ServiceEnvironment.local,
      useMocks: true,
    );
  }
  
  /// Clean up after all tests
  static Future<void> tearDownTestEnvironment() async {
    if (ServiceLocator.isInitialized) {
      await ServiceLocator.reset();
    }
    _isInitialized = false;
  }
}

/// Convenience function to wrap test groups with proper setup/teardown
void testWithSetup(
  String description,
  void Function() body, {
  bool skip = false,
}) {
  group(description, () {
    setUpAll(() async {
      await TestSetup.initializeTestEnvironment();
    });
    
    tearDown(() async {
      // Reset between tests for isolation
      await TestSetup.resetTestEnvironment();
    });
    
    tearDownAll(() async {
      await TestSetup.tearDownTestEnvironment();
    });
    
    body();
  }, skip: skip);
}

/// Convenience function for individual tests with setup
void singleTestWithSetup(
  String description,
  Future<void> Function() body, {
  bool skip = false,
  Timeout? timeout,
}) {
  test(description, () async {
    await TestSetup.initializeTestEnvironment();
    
    try {
      await body();
    } finally {
      await TestSetup.resetTestEnvironment();
    }
  }, skip: skip, timeout: timeout);
}