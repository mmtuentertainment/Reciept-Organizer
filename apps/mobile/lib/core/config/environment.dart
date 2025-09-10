/// Minimal environment configuration for API endpoints
/// 
/// This class provides a single source of truth for environment-specific
/// configuration. It reads from compile-time environment variables with
/// sensible defaults for production use.
class Environment {
  Environment._(); // Private constructor to prevent instantiation
  
  /// The base URL for the API backend
  /// 
  /// Can be overridden at compile time using:
  /// flutter build apk --dart-define=API_URL=http://localhost:3001
  static String get apiUrl {
    return const String.fromEnvironment(
      'API_URL',
      defaultValue: 'https://receipt-organizer-api.vercel.app',
    );
  }
  
  /// Whether we're running in development mode
  /// 
  /// Useful for enabling debug features or different behavior
  static bool get isDevelopment {
    return const bool.fromEnvironment(
      'DEVELOPMENT',
      defaultValue: false,
    );
  }
  
  /// Simple method to log current configuration (for debugging)
  static void logConfiguration() {
    print('Environment Configuration:');
    print('  API URL: $apiUrl');
    print('  Development Mode: $isDevelopment');
  }
}