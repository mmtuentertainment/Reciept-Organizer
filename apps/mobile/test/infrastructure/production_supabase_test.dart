import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/infrastructure/config/supabase_config.dart';
import 'package:receipt_organizer/infrastructure/config/production_config.dart';
import '../helpers/test_setup.dart';

void main() {
  group('Production Supabase Configuration', () {
    setUpAll(() async {
      await setupTestEnvironment();
    });
    test('should use production URL and key', () {
      // Verify production config is loaded
      expect(ProductionConfig.supabaseUrl, 'https://xbadaalqaeszooyxuoac.supabase.co');
      expect(ProductionConfig.supabaseAnonKey, startsWith('eyJhbGciOiJIUzI1NiI'));
      // The JWT contains the project ref in its payload
      expect(ProductionConfig.supabaseAnonKey.contains('xbadaalqaeszooyxuoac'), isTrue);
    });

    test('should return production config when not in development', () {
      // When not in development mode, should use production
      final url = SupabaseConfig.supabaseUrl;
      final key = SupabaseConfig.supabaseAnonKey;

      // Should be production values
      expect(url, equals(ProductionConfig.supabaseUrl));
      expect(key, equals(ProductionConfig.supabaseAnonKey));
    });

    test('production config should be valid', () {
      // Check URL format
      expect(ProductionConfig.supabaseUrl, matches(r'^https://[a-z]+\.supabase\.co$'));

      // Check key format (JWT)
      final keyParts = ProductionConfig.supabaseAnonKey.split('.');
      expect(keyParts.length, 3, reason: 'JWT should have 3 parts');
    });

    test('should be able to initialize Supabase', () async {
      // This tests that the configuration is valid
      try {
        await initializeSupabaseForTesting();
        expect(SupabaseConfig.isInitialized, true);

        // Verify client exists
        final client = SupabaseConfig.client;
        expect(client, isNotNull);

        // Verify we're using production credentials
        expect(SupabaseConfig.supabaseUrl, equals(ProductionConfig.supabaseUrl));
        expect(SupabaseConfig.supabaseAnonKey, equals(ProductionConfig.supabaseAnonKey));
      } catch (e) {
        // If already initialized, that's fine
        if (e.toString().contains('already initialized')) {
          expect(SupabaseConfig.isInitialized, true);
        } else {
          // Re-throw if it's a different error
          rethrow;
        }
      }
    });
  });
}