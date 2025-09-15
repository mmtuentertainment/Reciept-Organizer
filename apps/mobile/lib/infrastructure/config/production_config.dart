/// Production Supabase Configuration
///
/// This file contains the production Supabase configuration
/// for the Receipt Organizer mobile app.
class ProductionConfig {
  ProductionConfig._();

  /// Production Supabase URL - MUST be provided via --dart-define
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Production Supabase Anon Key - MUST be provided via --dart-define
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Production API URL (if using separate API)
  static const String apiUrl = 'https://receipt-organizer-api.vercel.app';

  /// Check if we should use production config
  static bool get useProduction {
    // Use production if explicitly set or not in development mode
    const bool isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: true);
    const bool isDevelopment = bool.fromEnvironment('DEVELOPMENT', defaultValue: false);
    return isProduction && !isDevelopment;
  }
}