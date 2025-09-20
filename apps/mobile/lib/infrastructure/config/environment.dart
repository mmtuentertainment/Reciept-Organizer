import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Secure environment configuration
class Environment {
  static late String supabaseUrl;
  static late String supabaseAnonKey;

  /// Initialize environment variables
  static Future<void> initialize() async {
    // Load different env files based on build mode
    if (kDebugMode) {
      await dotenv.load(fileName: '.env.local');
    } else {
      await dotenv.load(fileName: '.env.production');
    }

    // Validate required variables
    supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'Missing Supabase credentials. Please configure .env file.\n'
        'See .env.example for required variables.'
      );
    }

    // Security validation
    _validateCredentials();
  }

  /// Validate credentials aren't placeholders
  static void _validateCredentials() {
    if (supabaseUrl.contains('your_project') ||
        supabaseUrl.contains('example') ||
        supabaseAnonKey.contains('your_anon_key') ||
        supabaseAnonKey.length < 100) {
      throw Exception(
        'Invalid Supabase credentials detected. '
        'Please use real credentials from Supabase dashboard.'
      );
    }
  }

  /// Check if we're in development mode
  static bool get isDevelopment => kDebugMode;

  /// Check if we're in production mode
  static bool get isProduction => kReleaseMode;
}