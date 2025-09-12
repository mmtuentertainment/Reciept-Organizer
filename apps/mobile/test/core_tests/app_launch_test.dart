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
      
      // Then - App loaded with title
      expect(find.text('Receipt Organizer'), findsOneWidget);
      expect(find.text('Receipt Organizer MVP'), findsOneWidget);
    });

    testWidgets('main buttons should be visible', (WidgetTester tester) async {
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
      
      // Then - Main action buttons exist
      expect(find.text('Batch Capture'), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
    });
  });
}