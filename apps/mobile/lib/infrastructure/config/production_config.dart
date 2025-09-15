/// Production Supabase Configuration
///
/// This file contains the production Supabase configuration
/// for the Receipt Organizer mobile app.
class ProductionConfig {
  ProductionConfig._();

  /// Production Supabase URL
  static const String supabaseUrl = 'https://xbadaalqaeszooyxuoac.supabase.co';

  /// Production Supabase Anon Key (safe to expose - RLS protected)
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhiYWRhYWxxYWVzem9veXh1b2FjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc3ODE1MzAsImV4cCI6MjA3MzM1NzUzMH0.PY-aQ6bjYUPaTL2o2twviFf5AJTSYR0gyKUkQb08OGc';

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