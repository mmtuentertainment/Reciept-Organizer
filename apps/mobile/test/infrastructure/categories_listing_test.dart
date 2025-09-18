import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/core/providers/service_providers.dart';
import 'package:receipt_organizer/infrastructure/config/supabase_config.dart';
import 'package:receipt_organizer/infrastructure/services/supabase_auth_service.dart';
import 'package:receipt_organizer/utils/supabase_query_tool.dart';
import '../helpers/test_setup.dart';

/// Test specifically for listing and examining categories from Supabase
/// This test serves as both a test and a utility to examine category data
void main() {
  group('Categories Listing Tests', () {
    late ProviderContainer container;

    setUpAll(() async {
      await setupTestEnvironment();

      // Skip if Supabase is not configured
      if (!_isSupabaseConfigured()) {
        print('⚠️ Skipping Categories tests - Supabase not configured');
        print('Run with: flutter test --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key');
        return;
      }

      // Initialize Supabase for testing
      try {
        await initializeSupabaseForTesting();
        print('✅ Supabase initialized for categories testing');
      } catch (e) {
        print('❌ Failed to initialize Supabase: $e');
      }
    });

    setUp(() {
      container = ProviderContainer(
        overrides: [
          environmentProvider.overrideWithValue(AppEnvironment.staging),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Categories Data Analysis', () {
      test('should fetch and display all categories from database', skip: !_isSupabaseConfigured(), () async {
        if (!SupabaseConfig.isInitialized) {
          print('Supabase not initialized, skipping test');
          return;
        }

        print('\n🔍 FETCHING ALL CATEGORIES FROM SUPABASE');
        print('==========================================');

        try {
          // Fetch all categories using our utility
          final categories = await SupabaseQueryTool.fetchAllCategories();

          print('📊 Total categories found: ${categories.length}');
          print('');

          if (categories.isEmpty) {
            print('⚠️ No categories found in database');
            print('This might indicate:');
            print('  1. Database is empty');
            print('  2. RLS policies are blocking access');
            print('  3. Table does not exist');
            return;
          }

          // Analyze category distribution by user
          final userGroups = <String, List<Map<String, dynamic>>>{};
          for (final category in categories) {
            final userId = category['user_id'] as String;
            userGroups[userId] ??= [];
            userGroups[userId]!.add(category);
          }

          print('👥 Categories by User:');
          userGroups.forEach((userId, userCategories) {
            print('  User: ${userId.substring(0, 8)}... (${userCategories.length} categories)');
          });
          print('');

          // Display detailed category information
          print('📝 Category Details:');
          print('┌─────┬────────────────────────────────────┬─────────┬──────────────┬───────┐');
          print('│ #   │ Name                               │ Color   │ Icon         │ Order │');
          print('├─────┼────────────────────────────────────┼─────────┼──────────────┼───────┤');

          for (int i = 0; i < categories.length; i++) {
            final cat = categories[i];
            final name = (cat['name'] as String).padRight(34);
            final color = (cat['color'] as String? ?? '').padRight(7);
            final icon = (cat['icon'] as String? ?? '').padRight(12);
            final order = (cat['display_order']?.toString() ?? 'NULL').padLeft(5);
            print('│ ${(i + 1).toString().padLeft(3)} │ $name │ $color │ $icon │ $order │');
          }
          print('└─────┴────────────────────────────────────┴─────────┴──────────────┴───────┘');
          print('');

          // Verify category model mapping
          print('🧪 Testing Category Model Mapping:');
          final firstCategory = categories.first;
          try {
            final categoryModel = Category.fromJson(firstCategory);
            print('✅ Category model mapping successful');
            print('   Sample: ${categoryModel.toString()}');
          } catch (e) {
            print('❌ Category model mapping failed: $e');
          }
          print('');

          // Test assertions for data integrity
          expect(categories, isNotEmpty);

          // Verify all categories have required fields
          for (final category in categories) {
            expect(category['id'], isNotNull);
            expect(category['user_id'], isNotNull);
            expect(category['name'], isNotNull);
            expect(category['name'], isA<String>());
            expect((category['name'] as String).isNotEmpty, true);

            // Color should be hex format if present
            if (category['color'] != null) {
              final color = category['color'] as String;
              expect(color.startsWith('#'), true, reason: 'Color should start with #');
              expect(color.length, 7, reason: 'Color should be 7 characters (#RRGGBB)');
            }
          }

          print('✅ All categories have valid required fields');

        } catch (e) {
          print('❌ Error fetching categories: $e');
          print('This might indicate:');
          print('  1. Authentication required');
          print('  2. Network connectivity issues');
          print('  3. RLS policies blocking access');
          print('  4. Table permissions issues');
          rethrow;
        }
      });

      test('should fetch categories for authenticated user', skip: !_isSupabaseConfigured(), () async {
        if (!SupabaseConfig.isInitialized) return;

        print('\n👤 TESTING USER-SPECIFIC CATEGORIES');
        print('==================================');

        try {
          // First authenticate
          final authService = container.read(authServiceProvider) as SupabaseAuthService;
          final authResult = await authService.signInAnonymously();

          if (!authResult.success) {
            print('⚠️ Authentication failed, skipping user-specific test');
            return;
          }

          final userId = authService.currentUser?.id;
          expect(userId, isNotNull);

          print('🔐 Authenticated as user: ${userId!.substring(0, 8)}...');

          // Fetch categories for this user
          final userCategories = await SupabaseQueryTool.fetchCategoriesForUser(userId);

          print('📊 Categories for current user: ${userCategories.length}');

          if (userCategories.isNotEmpty) {
            print('📝 User Categories:');
            for (int i = 0; i < userCategories.length; i++) {
              final cat = userCategories[i];
              print('  ${i + 1}. ${cat['name']} (${cat['color']}, ${cat['icon']})');
            }

            // Convert to models for Flutter usage
            final categoryModels = SupabaseQueryTool.categoriesToModels(userCategories);
            print('🔄 Converted ${categoryModels.length} categories to Flutter models');

            // Verify model conversion
            expect(categoryModels.length, userCategories.length);
            for (final model in categoryModels) {
              expect(model.userId, userId);
            }
          } else {
            print('⚠️ No categories found for this user');
            print('This might be expected if categories are auto-created on signup');
          }

          // Clean up
          await authService.signOut();
          print('🚪 Signed out successfully');

        } catch (e) {
          print('❌ Error in user-specific categories test: $e');
          rethrow;
        }
      });

      test('should analyze category data structure and business logic', skip: !_isSupabaseConfigured(), () async {
        if (!SupabaseConfig.isInitialized) return;

        print('\n📊 CATEGORY DATA ANALYSIS');
        print('========================');

        try {
          final categories = await SupabaseQueryTool.fetchAllCategories();

          if (categories.isEmpty) {
            print('⚠️ No categories to analyze');
            return;
          }

          // Analyze category names and business purposes
          final categoryNames = categories.map((c) => c['name'] as String).toSet();
          print('🏷️ Unique category names: ${categoryNames.length}');

          final businessCategories = [
            'Meals & Entertainment',
            'Travel',
            'Transportation',
            'Office Supplies',
            'Software & Subscriptions',
            'Marketing',
            'Professional Services',
            'Equipment',
            'Utilities',
            'Insurance',
            'Rent & Lease',
            'Other'
          ];

          print('🎯 Expected business categories coverage:');
          for (final expectedCat in businessCategories) {
            final found = categoryNames.contains(expectedCat);
            print('  ${found ? '✅' : '❌'} $expectedCat');
          }

          // Analyze color distribution
          final colors = categories.map((c) => c['color'] as String?).where((c) => c != null).toSet();
          print('\n🎨 Color palette (${colors.length} unique colors):');
          colors.forEach((color) {
            print('  $color');
          });

          // Analyze icon distribution
          final icons = categories.map((c) => c['icon'] as String?).where((i) => i != null).toSet();
          print('\n🔍 Icon set (${icons.length} unique icons):');
          icons.forEach((icon) {
            print('  $icon');
          });

          // Check display order logic
          final orderedCategories = categories.where((c) => c['display_order'] != null).toList();
          orderedCategories.sort((a, b) => (a['display_order'] as int).compareTo(b['display_order'] as int));

          print('\n📋 Display order analysis:');
          print('  Categories with order: ${orderedCategories.length}');
          print('  Categories without order: ${categories.length - orderedCategories.length}');

          if (orderedCategories.isNotEmpty) {
            print('  Order range: ${orderedCategories.first['display_order']} to ${orderedCategories.last['display_order']}');
          }

          expect(categories.length, greaterThan(0));
          print('\n✅ Category data analysis complete');

        } catch (e) {
          print('❌ Error in category analysis: $e');
          rethrow;
        }
      });
    });
  });
}

bool _isSupabaseConfigured() {
  // Check if we're in CI or have Supabase configured
  const ciEnv = String.fromEnvironment('CI');
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  return ciEnv == 'true' || supabaseUrl.isNotEmpty;
}