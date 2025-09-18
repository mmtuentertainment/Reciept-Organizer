#!/usr/bin/env dart

import 'dart:io';
import '../lib/utils/supabase_query_tool.dart';
import '../lib/core/config/supabase_config.dart';

/// Script to list all categories from the Supabase categories table
/// Usage: dart run scripts/list_categories.dart
///
/// Requires environment variables:
/// - SUPABASE_URL: Your Supabase project URL
/// - SUPABASE_ANON_KEY: Your Supabase anon/public key
///
/// Run with:
/// dart run scripts/list_categories.dart --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key

Future<void> main() async {
  print('🔍 Receipt Organizer - Categories Listing Tool');
  print('============================================');
  print('');

  try {
    // Initialize Supabase
    print('📡 Initializing Supabase connection...');
    await SupabaseConfig.initialize();
    print('✅ Supabase initialized successfully');
    print('');

    // List all categories
    print('📋 Fetching all categories from database...');
    await SupabaseQueryTool.printAllCategories();

    // Get current user info if authenticated
    final client = SupabaseConfig.client;
    final currentUser = client.auth.currentUser;

    if (currentUser != null) {
      print('=== CURRENT USER CATEGORIES ===');
      print('User ID: ${currentUser.id}');
      print('Email: ${currentUser.email}');
      print('');

      final userCategories = await SupabaseQueryTool.fetchCategoriesForUser(currentUser.id);
      print('Categories for current user: ${userCategories.length}');

      for (final category in userCategories) {
        final cat = Category.fromJson(category);
        print('  ${cat.toString()}');
      }
    } else {
      print('=== NO AUTHENTICATED USER ===');
      print('Note: Run with authentication to see user-specific categories');
    }

  } catch (e) {
    print('❌ Error occurred: $e');
    exit(1);
  }

  print('');
  print('✅ Categories listing complete!');
}