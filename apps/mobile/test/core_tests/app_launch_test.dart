/// Minimal App Launch Test
/// Verifies the app starts without crashing

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:receipt_organizer/main.dart';
import 'package:receipt_organizer/features/receipts/presentation/providers/image_viewer_provider.dart';

void main() {
  group('App Launch - Smoke Test', () {
    setUp(() async {
      // Initialize SharedPreferences for tests
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      // Override the provider for tests
      addTearDown(() {
        // Clean up after test
      });
    });

    testWidgets('app should launch without crashing', (WidgetTester tester) async {
      // Given
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // When
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const ReceiptOrganizerApp(),
        ),
      );
      await tester.pump();

      // Then - App loaded with login screen (no auth session)
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to your account'), findsOneWidget);
    });

    testWidgets('login screen elements should be visible', (WidgetTester tester) async {
      // Given
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // When
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const ReceiptOrganizerApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Then - Login screen elements exist
      expect(find.text('Sign In'), findsOneWidget); // The Sign In button
      expect(find.byIcon(Icons.receipt_long), findsOneWidget); // App icon
    });
  });
}