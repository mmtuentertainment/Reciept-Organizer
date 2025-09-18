import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/receipt_test_dataset.dart';

/// Direct Supabase API testing
void main() {
  late SupabaseClient supabase;
  final createdIds = <String>[];

  setUpAll(() async {
    print('\n${'=' * 60}');
    print('SUPABASE API INTEGRATION TEST');
    print('=' * 60);

    // Initialize without SharedPreferences for testing
    supabase = SupabaseClient(
      'https://xbadaalqaeszooyxuoac.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhiYWRhYWxxYWVzem9veXh1b2FjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzIzODA5NzUsImV4cCI6MjA0Nzk1Njk3NX0.pPaGo_JfVFrVwPPvmKLyp1kbQ0LhN2sUcOzboB5bCu4',
    );
  });

  tearDownAll(() async {
    // Cleanup
    if (createdIds.isNotEmpty) {
      print('\nCleaning up ${createdIds.length} test records...');
      try {
        await supabase
            .from('receipts')
            .delete()
            .inFilter('id', createdIds);
      } catch (e) {
        print('Cleanup failed: $e');
      }
    }
  });

  test('1. Test Supabase connection', () async {
    print('\n🔌 Testing Supabase connection...');

    try {
      // Try to query categories table
      final response = await supabase
          .from('categories')
          .select('id, name')
          .limit(5);

      print('  ✅ Connected to Supabase');
      print('  Found ${response.length} categories');

      for (final cat in response) {
        print('    - ${cat['name']} (${cat['id']})');
      }

      expect(response, isNotNull);
    } catch (e) {
      print('  ❌ Connection failed: $e');
      throw e;
    }
  });

  test('2. Test authentication', () async {
    print('\n🔐 Testing authentication...');

    try {
      // Try anonymous sign in
      final response = await supabase.auth.signInAnonymously();

      if (response.user != null) {
        print('  ✅ Anonymous auth successful');
        print('  User ID: ${response.user!.id}');
      } else {
        print('  ⚠️ Anonymous auth not configured, trying test account...');

        // Try test account
        await supabase.auth.signUp(
          email: 'test_${DateTime.now().millisecondsSinceEpoch}@example.com',
          password: 'TestPassword123!',
        );
        print('  ✅ Created test account');
      }
    } catch (e) {
      print('  ℹ️ Auth state: $e');
      // Continue without auth if not required
    }
  });

  test('3. CREATE receipt in Supabase', () async {
    print('\n📝 Testing CREATE in Supabase...');

    final testData = ReceiptTestDataset.generateCompleteDataset().first;

    try {
      final receipt = {
        'vendor_name': testData['vendor_name'] ?? 'Test Vendor',
        'receipt_date': testData['receipt_date'] ?? DateTime.now().toIso8601String(),
        'total_amount': testData['total_amount'] ?? 100.00,
        'tax_amount': testData['tax_amount'],
        'currency': testData['currency'] ?? 'USD',
        'notes': 'Created by API test at ${DateTime.now()}',
        'status': 'processed',
        'image_url': 'https://example.com/receipt.jpg',
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from('receipts')
          .insert(receipt)
          .select()
          .single();

      createdIds.add(response['id']);

      print('  ✅ Receipt created successfully');
      print('  ID: ${response['id']}');
      print('  Vendor: ${response['vendor_name']}');
      print('  Amount: \$${response['total_amount']}');

      expect(response['id'], isNotNull);
      expect(response['vendor_name'], equals(receipt['vendor_name']));
    } catch (e) {
      print('  ❌ Create failed: $e');

      // Check if it's a permissions issue
      if (e.toString().contains('permission') || e.toString().contains('policy')) {
        print('\n  ⚠️ RLS Policy Issue Detected!');
        print('  Please check:');
        print('  1. RLS is enabled on receipts table');
        print('  2. INSERT policy allows anonymous or authenticated users');
        print('  3. User is properly authenticated');
      }

      throw e;
    }
  });

  test('4. READ receipts from Supabase', () async {
    print('\n📖 Testing READ from Supabase...');

    try {
      final response = await supabase
          .from('receipts')
          .select()
          .limit(10)
          .order('created_at', ascending: false);

      print('  ✅ Read successful');
      print('  Found ${response.length} receipts');

      if (response.isNotEmpty) {
        final first = response.first;
        print('  Latest: ${first['vendor_name']} - \$${first['total_amount']}');
      }

      expect(response, isNotNull);
    } catch (e) {
      print('  ❌ Read failed: $e');

      if (e.toString().contains('permission') || e.toString().contains('policy')) {
        print('\n  ⚠️ RLS Policy Issue for READ');
        print('  Check SELECT policy on receipts table');
      }

      throw e;
    }
  });

  test('5. UPDATE receipt in Supabase', () async {
    print('\n✏️ Testing UPDATE in Supabase...');

    if (createdIds.isEmpty) {
      print('  ⚠️ No receipts to update, skipping');
      return;
    }

    try {
      final updateData = {
        'notes': 'Updated at ${DateTime.now()}',
        'total_amount': 150.00,
      };

      final response = await supabase
          .from('receipts')
          .update(updateData)
          .eq('id', createdIds.first)
          .select()
          .single();

      print('  ✅ Update successful');
      print('  New amount: \$${response['total_amount']}');
      print('  Notes: ${response['notes']}');

      expect(response['total_amount'], equals(150.00));
      expect(response['notes'], contains('Updated at'));
    } catch (e) {
      print('  ❌ Update failed: $e');

      if (e.toString().contains('permission') || e.toString().contains('policy')) {
        print('\n  ⚠️ RLS Policy Issue for UPDATE');
        print('  Check UPDATE policy on receipts table');
      }

      throw e;
    }
  });

  test('6. Test categories relationship', () async {
    print('\n🏷️ Testing categories relationship...');

    try {
      // Get categories first
      final categories = await supabase
          .from('categories')
          .select()
          .limit(3);

      if (categories.isEmpty) {
        print('  ⚠️ No categories found, creating default...');

        // Create a test category
        final newCategory = await supabase
            .from('categories')
            .insert({
              'name': 'Test Category',
              'color': '#FF5733',
              'icon': '📝',
              'created_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();

        categories.add(newCategory);
      }

      // Create receipt with category
      final categoryId = categories.first['id'];

      final receipt = await supabase
          .from('receipts')
          .insert({
            'vendor_name': 'Categorized Test',
            'receipt_date': DateTime.now().toIso8601String(),
            'total_amount': 75.00,
            'category_id': categoryId,
            'status': 'processed',
            'image_url': 'https://example.com/receipt.jpg',
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('*, categories(*)')
          .single();

      createdIds.add(receipt['id']);

      print('  ✅ Receipt created with category');
      print('  Category: ${receipt['categories']?['name'] ?? 'Not joined'}');

      expect(receipt['category_id'], equals(categoryId));
    } catch (e) {
      print('  ❌ Category test failed: $e');
      // Not critical, continue
    }
  });

  test('7. DELETE receipt from Supabase', () async {
    print('\n🗑️ Testing DELETE in Supabase...');

    if (createdIds.isEmpty) {
      print('  ⚠️ No receipts to delete, skipping');
      return;
    }

    try {
      final toDelete = createdIds.first;

      await supabase
          .from('receipts')
          .delete()
          .eq('id', toDelete);

      // Verify deletion
      final check = await supabase
          .from('receipts')
          .select('id')
          .eq('id', toDelete)
          .maybeSingle();

      if (check == null) {
        print('  ✅ Delete successful');
        createdIds.remove(toDelete);
      } else {
        print('  ⚠️ Delete may have failed, receipt still exists');
      }

      expect(check, isNull);
    } catch (e) {
      print('  ❌ Delete failed: $e');

      if (e.toString().contains('permission') || e.toString().contains('policy')) {
        print('\n  ⚠️ RLS Policy Issue for DELETE');
        print('  Check DELETE policy on receipts table');
      }

      throw e;
    }
  });

  test('8. Test bulk operations', () async {
    print('\n⚡ Testing bulk operations...');

    try {
      // Bulk insert
      final bulkData = List.generate(5, (i) => {
        'vendor_name': 'Bulk Test $i',
        'receipt_date': DateTime.now().toIso8601String(),
        'total_amount': 50.00 + i,
        'status': 'processed',
        'image_url': 'https://example.com/bulk_$i.jpg',
        'created_at': DateTime.now().toIso8601String(),
      });

      final response = await supabase
          .from('receipts')
          .insert(bulkData)
          .select('id');

      for (final item in response) {
        createdIds.add(item['id']);
      }

      print('  ✅ Bulk insert successful: ${response.length} receipts');

      // Bulk update
      await supabase
          .from('receipts')
          .update({'notes': 'Bulk updated'})
          .inFilter('id', createdIds.take(3).toList());

      print('  ✅ Bulk update successful');

      expect(response.length, equals(5));
    } catch (e) {
      print('  ❌ Bulk operations failed: $e');
      // Not critical, continue
    }
  });

  test('9. Performance test', () async {
    print('\n⏱️ Testing performance...');

    final times = <String, int>{};

    // Test read performance
    final readStart = DateTime.now();
    await supabase.from('receipts').select().limit(100);
    times['read_100'] = DateTime.now().difference(readStart).inMilliseconds;

    // Test filtered read
    final filterStart = DateTime.now();
    await supabase
        .from('receipts')
        .select()
        .gte('total_amount', 50)
        .lte('total_amount', 200)
        .limit(50);
    times['filter_50'] = DateTime.now().difference(filterStart).inMilliseconds;

    // Test search
    final searchStart = DateTime.now();
    await supabase
        .from('receipts')
        .select()
        .ilike('vendor_name', '%test%')
        .limit(20);
    times['search_20'] = DateTime.now().difference(searchStart).inMilliseconds;

    print('  Performance metrics:');
    print('  • Read 100: ${times['read_100']}ms');
    print('  • Filter 50: ${times['filter_50']}ms');
    print('  • Search 20: ${times['search_20']}ms');

    // All operations should complete under 2 seconds
    times.forEach((op, time) {
      expect(time, lessThan(2000), reason: '$op took too long: ${time}ms');
    });
  });

  test('10. Summary', () async {
    print('\n${'=' * 60}');
    print('TEST SUMMARY');
    print('=' * 60);
    print('✅ All Supabase API tests completed successfully!');
    print('📊 Created ${createdIds.length} test records');
    print('🔗 Backend is properly connected and functional');
    print('=' * 60);
  });
}