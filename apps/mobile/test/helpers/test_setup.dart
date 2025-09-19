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

/// Initialize Supabase for testing with EmptyLocalStorage
/// This prevents SharedPreferences access issues in tests
Future<void> initializeSupabaseForTesting() async {
  try {
    // Check if already initialized
    Supabase.instance;
    return; // Already initialized
  } catch (_) {
    // Not initialized, continue
  }

  // Initialize Supabase for testing
  await Supabase.initialize(
    url: 'http://localhost:54321',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: false, // Disable auto-refresh in tests
    ),
  );
}