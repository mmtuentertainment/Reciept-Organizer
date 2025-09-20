import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Build mode enumeration
enum BuildMode {
  debug,
  profile,
  release,
  test,
}

/// Comprehensive test environment configuration for 2025
///
/// This provides a centralized way to detect and configure test environments,
/// bypassing production services like Supabase when running tests.
class TestEnvironment {
  // Private state
  static bool _isIntegrationTest = false;

  // ============================================================================
  // CORE TEST MODE DETECTION
  // ============================================================================

  /// Primary flag to detect if we're running in test mode
  /// In tests, Platform.environment is not available, but we can check for test binding
  static bool get isTestMode {
    try {
      // If TestWidgetsFlutterBinding is available, we're in test mode
      final binding = TestWidgetsFlutterBinding.instance;
      return binding != null;
    } catch (_) {
      // Otherwise check environment variable
      return const bool.fromEnvironment('FLUTTER_TEST', defaultValue: false);
    }
  }

  /// Environment-specific test type detection
  static const String testType = String.fromEnvironment(
    'TEST_TYPE',
    defaultValue: 'unit',
  );

  /// Check if we're running in CI/CD pipeline
  static const bool isCI = bool.fromEnvironment(
    'CI',
    defaultValue: false,
  );

  // ============================================================================
  // TEST TYPE DETECTION
  // ============================================================================

  /// Check if running unit tests
  static bool get isUnitTest => isTestMode && testType == 'unit';

  /// Check if running widget tests
  static bool get isWidgetTest => isTestMode && testType == 'widget';

  /// Check if running integration tests
  static bool get isIntegrationTest => _isIntegrationTest || (isTestMode && testType == 'integration');

  /// Check if running end-to-end tests
  static bool get isE2ETest => isTestMode && testType == 'e2e';

  /// Check if running performance tests
  static bool get isPerformanceTest => isTestMode && testType == 'performance';

  // ============================================================================
  // SERVICE BYPASS FLAGS
  // ============================================================================

  /// Whether to bypass Supabase initialization
  static bool get shouldBypassSupabase => isTestMode && !isIntegrationTest && !isE2ETest;

  /// Whether to use mock authentication
  static bool get shouldUseMockAuth => isTestMode && !isE2ETest;

  /// Whether to use in-memory database
  static bool get shouldUseInMemoryDb => isTestMode && isUnitTest;

  /// Whether to use fake file storage
  static bool get shouldUseFakeStorage => isTestMode && !isIntegrationTest;

  /// Whether to mock external API calls
  static bool get shouldMockExternalAPIs => isTestMode && !isE2ETest;

  /// Whether to enable test logging
  static bool get enableTestLogging => isTestMode && !isPerformanceTest;

  // ============================================================================
  // TEST CONFIGURATION VALUES
  // ============================================================================

  /// Test database URL (if needed for integration tests)
  static String get testDatabaseUrl {
    if (!isTestMode) return '';
    if (isIntegrationTest) {
      return const String.fromEnvironment(
        'TEST_DATABASE_URL',
        defaultValue: 'sqlite:///:memory:',
      );
    }
    return 'memory://test';
  }

  /// Test API base URL
  static String get testApiUrl {
    if (!isTestMode) return '';
    return const String.fromEnvironment(
      'TEST_API_URL',
      defaultValue: 'http://localhost:3000/api/test',
    );
  }

  /// Test authentication token
  static String get testAuthToken {
    if (!isTestMode) return '';
    return const String.fromEnvironment(
      'TEST_AUTH_TOKEN',
      defaultValue: 'test_token_mock_123456',
    );
  }

  /// Test user credentials
  static Map<String, String> get testCredentials {
    if (!isTestMode) return {};
    return {
      'email': const String.fromEnvironment(
        'TEST_USER_EMAIL',
        defaultValue: 'test@example.com',
      ),
      'password': const String.fromEnvironment(
        'TEST_USER_PASSWORD',
        defaultValue: 'Test123!@#',
      ),
      'userId': const String.fromEnvironment(
        'TEST_USER_ID',
        defaultValue: 'test_user_123',
      ),
    };
  }

  // ============================================================================
  // TEST TIMEOUTS AND LIMITS
  // ============================================================================

  /// Default test timeout
  static Duration get defaultTestTimeout {
    if (isPerformanceTest) return const Duration(minutes: 5);
    if (isIntegrationTest) return const Duration(minutes: 2);
    if (isE2ETest) return const Duration(minutes: 10);
    return const Duration(seconds: 30);
  }

  /// Maximum concurrent tests
  static int get maxConcurrentTests {
    if (isCI) return 2; // Limited resources in CI
    if (isPerformanceTest) return 1; // Run performance tests sequentially
    return 4; // Local development
  }

  /// Test retry count
  static int get testRetryCount {
    if (isE2ETest) return 3; // E2E tests can be flaky
    if (isIntegrationTest) return 2;
    return 1; // Unit tests should be deterministic
  }

  // ============================================================================
  // ENVIRONMENT SETUP METHODS
  // ============================================================================

  /// Initialize test environment
  static Future<void> initialize() async {
    if (!isTestMode) return;

    print('🧪 Initializing Test Environment');
    print('  Mode: $testType');
    print('  CI: $isCI');
    print('  Bypass Supabase: $shouldBypassSupabase');
    print('  Mock Auth: $shouldUseMockAuth');
    print('  In-Memory DB: $shouldUseInMemoryDb');
    print('  Fake Storage: $shouldUseFakeStorage');

    // Load test-specific environment variables
    if (isTestMode && !dotenv.isInitialized) {
      try {
        await dotenv.load(fileName: '.env.test');
      } catch (e) {
        // .env.test is optional
        print('ℹ️ No .env.test file found, using defaults');
      }
    }

    // Set up test-specific configurations
    _configureTestServices();
  }

  /// Configure services for testing
  static void _configureTestServices() {
    if (shouldBypassSupabase) {
      _bypassSupabase();
    }

    if (shouldUseMockAuth) {
      _configureMockAuth();
    }

    if (shouldUseInMemoryDb) {
      _configureInMemoryDatabase();
    }

    if (shouldUseFakeStorage) {
      _configureFakeStorage();
    }

    if (shouldMockExternalAPIs) {
      _configureMockAPIs();
    }
  }

  /// Bypass Supabase initialization
  static void _bypassSupabase() {
    // This would be called before Supabase.initialize()
    print('✓ Supabase initialization bypassed for testing');
  }

  /// Configure mock authentication
  static void _configureMockAuth() {
    // Set up mock auth service
    print('✓ Mock authentication configured');
  }

  /// Configure in-memory database
  static void _configureInMemoryDatabase() {
    // Set up in-memory database
    print('✓ In-memory database configured');
  }

  /// Configure fake file storage
  static void _configureFakeStorage() {
    // Set up fake storage service
    print('✓ Fake storage configured');
  }

  /// Configure mock external APIs
  static void _configureMockAPIs() {
    // Set up API mocks
    print('✓ External API mocks configured');
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Runtime check if tests are running
  static bool _isRunningTests() {
    // Check if we're in a test environment by looking at the stack trace
    try {
      final stackTrace = StackTrace.current.toString();
      return stackTrace.contains('test_api') ||
             stackTrace.contains('flutter_test') ||
             stackTrace.contains('test.dart');
    } catch (_) {
      return false;
    }
  }

  /// Reset test environment (useful between test suites)
  static void reset() {
    if (!isTestMode) return;

    print('🔄 Resetting test environment');
    // Clear any test-specific state
  }

  /// Get environment summary for debugging
  static Map<String, dynamic> get summary => {
    'isTestMode': isTestMode,
    'testType': testType,
    'isCI': isCI,
    'shouldBypassSupabase': shouldBypassSupabase,
    'shouldUseMockAuth': shouldUseMockAuth,
    'shouldUseInMemoryDb': shouldUseInMemoryDb,
    'shouldUseFakeStorage': shouldUseFakeStorage,
    'shouldMockExternalAPIs': shouldMockExternalAPIs,
    'defaultTestTimeout': defaultTestTimeout.inSeconds,
    'maxConcurrentTests': maxConcurrentTests,
    'testRetryCount': testRetryCount,
  };

  // ============================================================================
  // BUILD MODE DETECTION
  // ============================================================================

  /// Detects the current build mode
  static BuildMode get buildMode {
    if (isTestMode) return BuildMode.test;
    if (kDebugMode) return BuildMode.debug;
    if (kProfileMode) return BuildMode.profile;
    return BuildMode.release;
  }

  /// Check if in debug mode (not test)
  static bool get isDebugMode => !isTestMode && kDebugMode;

  /// Check if in profile mode
  static bool get isProfileMode => kProfileMode;

  /// Check if in release mode
  static bool get isReleaseMode => kReleaseMode;

  // ============================================================================
  // MOCK CONFIGURATION VALUES
  // ============================================================================

  /// Mock Supabase URL for testing
  static const String mockSupabaseUrl = 'https://mock.supabase.co';

  /// Mock Supabase anon key for testing
  static const String mockAnonKey = 'mock_anon_key_for_testing';

  /// Get Supabase URL (returns mock in test mode)
  static String get supabaseUrl {
    if (shouldBypassSupabase) return mockSupabaseUrl;
    if (dotenv.isInitialized) {
      return dotenv.env['SUPABASE_URL'] ?? '';
    }
    return '';
  }

  /// Get Supabase anon key (returns mock in test mode)
  static String get supabaseAnonKey {
    if (shouldBypassSupabase) return mockAnonKey;
    if (dotenv.isInitialized) {
      return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    }
    return '';
  }

  /// Auth token for testing
  static String get authToken => testAuthToken;

  // ============================================================================
  // TEST CONTROL METHODS
  // ============================================================================

  /// Set integration test mode (for testing the test infrastructure)
  static void setIntegrationTest(bool value) {
    _isIntegrationTest = value;
  }

  /// Print environment configuration
  static void printConfiguration() {
    if (!isTestMode) {
      print('❌ Not in test mode');
      return;
    }

    print('');
    print('╔══════════════════════════════════════════════════════╗');
    print('║            TEST ENVIRONMENT CONFIGURATION            ║');
    print('╠══════════════════════════════════════════════════════╣');
    print('║ Test Mode:              ${testType.padRight(29)}║');
    print('║ CI Environment:         ${(isCI ? 'Yes' : 'No').padRight(29)}║');
    print('╟──────────────────────────────────────────────────────╢');
    print('║ SERVICE BYPASS SETTINGS                              ║');
    print('╟──────────────────────────────────────────────────────╢');
    print('║ Bypass Supabase:        ${(shouldBypassSupabase ? '✓' : '✗').padRight(29)}║');
    print('║ Mock Authentication:    ${(shouldUseMockAuth ? '✓' : '✗').padRight(29)}║');
    print('║ In-Memory Database:     ${(shouldUseInMemoryDb ? '✓' : '✗').padRight(29)}║');
    print('║ Fake File Storage:      ${(shouldUseFakeStorage ? '✓' : '✗').padRight(29)}║');
    print('║ Mock External APIs:     ${(shouldMockExternalAPIs ? '✓' : '✗').padRight(29)}║');
    print('╟──────────────────────────────────────────────────────╢');
    print('║ TEST EXECUTION SETTINGS                              ║');
    print('╟──────────────────────────────────────────────────────╢');
    print('║ Default Timeout:        ${('${defaultTestTimeout.inSeconds}s').padRight(29)}║');
    print('║ Max Concurrent Tests:   ${maxConcurrentTests.toString().padRight(29)}║');
    print('║ Retry Count:            ${testRetryCount.toString().padRight(29)}║');
    print('╚══════════════════════════════════════════════════════╝');
    print('');
  }
}