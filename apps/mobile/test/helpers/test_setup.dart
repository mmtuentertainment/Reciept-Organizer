import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'platform_channel_mocks.dart';

/// Set up test environment with proper mocking
/// This should be called at the beginning of each test file or in setUpAll
Future<void> setupTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Setup all platform channel mocks
  setupPlatformChannelMocks();

  // Mock SharedPreferences for tests
  SharedPreferences.setMockInitialValues({});
}

/// Initialize Supabase for testing - NO LONGER NEEDED!
/// We use mock providers instead to prevent any real network calls
@deprecated
Future<void> initializeSupabaseForTesting() async {
  // This function is deprecated - we don't initialize Supabase in tests
  // All Supabase functionality is mocked via provider overrides
  // See mock_supabase_providers.dart for the mock implementation
}