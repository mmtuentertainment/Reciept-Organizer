import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/environment.dart';
import 'production_config.dart';

/// Supabase configuration and initialization
class SupabaseConfig {
  // IMPORTANT: These are DEFAULT Supabase local development values
  // They are PUBLIC and safe for local development only
  // See: https://supabase.com/docs/guides/cli/local-development
  static const String _localDevUrl = 'http://127.0.0.1:54321';
  static const String _localDevAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';
  
  // Get Supabase URL based on environment
  static String get supabaseUrl {
    // Check if we should use production config
    if (ProductionConfig.useProduction) {
      return ProductionConfig.supabaseUrl;
    }

    // Check if running in development mode
    if (Environment.isDevelopment) {
      // Use environment variable if available, otherwise use local dev URL
      return const String.fromEnvironment('SUPABASE_URL', defaultValue: _localDevUrl);
    } else {
      // Production/staging - use production config
      return ProductionConfig.supabaseUrl;
    }
  }

  static String get supabaseAnonKey {
    // Check if we should use production config
    if (ProductionConfig.useProduction) {
      return ProductionConfig.supabaseAnonKey;
    }

    // Check if running in development mode
    if (Environment.isDevelopment) {
      // Use environment variable if available, otherwise use local dev key
      return const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: _localDevAnonKey);
    } else {
      // Production/staging - use production config
      return ProductionConfig.supabaseAnonKey;
    }
  }
  
  /// Initialize Supabase client
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        eventsPerSecond: 10,
      ),
      storageOptions: const StorageClientOptions(
        retryAttempts: 3,
      ),
    );
  }
  
  /// Get the Supabase client instance
  static SupabaseClient get client {
    return Supabase.instance.client;
  }
  
  /// Check if Supabase is initialized
  static bool get isInitialized {
    try {
      Supabase.instance.client;
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Configure offline support
  static void configureOfflineSupport() {
    // Configure retry policies for offline scenarios
    client.rest.headers['X-Client-Info'] = 'receipt-organizer-mobile';
    
    // Add offline queue for pending operations
    // This would integrate with the sync service
  }
}