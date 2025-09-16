import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/infrastructure/config/supabase_config.dart';
import 'package:receipt_organizer/infrastructure/config/production_config.dart';
import '../helpers/test_setup.dart';

void main() {
  group('Production Auth Flow Test', () {
    setUpAll(() async {
      await setupTestEnvironment();
    });

    test('should connect to production Supabase', () async {
      // Verify production configuration
      expect(ProductionConfig.supabaseUrl, 'https://xbadaalqaeszooyxuoac.supabase.co');
      expect(ProductionConfig.supabaseAnonKey, isNotEmpty);

      // In production mode, should use production config
      expect(SupabaseConfig.supabaseUrl, equals(ProductionConfig.supabaseUrl));
      expect(SupabaseConfig.supabaseAnonKey, equals(ProductionConfig.supabaseAnonKey));

      print('✅ Production Supabase Configuration Verified');
      print('   URL: ${SupabaseConfig.supabaseUrl}');
      print('   Key: ${SupabaseConfig.supabaseAnonKey.substring(0, 20)}...');
    });

    test('should be ready for authentication', () async {
      // Try to initialize Supabase
      try {
        await initializeSupabaseForTesting();
        expect(SupabaseConfig.isInitialized, true);

        final client = SupabaseConfig.client;
        expect(client, isNotNull);

        // Verify auth client is available
        expect(client.auth, isNotNull);

        print('✅ Supabase Auth Client Ready');
        print('   Can accept sign-in/sign-up requests');
      } catch (e) {
        // If already initialized, that's fine
        if (e.toString().contains('already initialized')) {
          expect(SupabaseConfig.isInitialized, true);
          print('✅ Supabase already initialized and ready');
        } else {
          // Unexpected error
          fail('Unexpected error during Supabase initialization: $e');
        }
      }
    });
  });
}