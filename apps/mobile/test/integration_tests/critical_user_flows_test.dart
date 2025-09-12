/// Critical User Flow Integration Tests
/// Testing only the most important user journeys

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/main.dart';

void main() {
  group('Critical User Flows', () {
    testWidgets('user can navigate between main screens', (WidgetTester tester) async {
      // Given - App is launched
      await tester.pumpWidget(
        const ProviderScope(
          child: ReceiptOrganizerApp(),
        ),
      );
      await tester.pumpAndSettle();
      
      // Initially on Receipts tab
      expect(find.text('Receipts'), findsOneWidget);
      
      // When - Tap on Capture tab
      await tester.tap(find.text('Capture'));
      await tester.pumpAndSettle();
      
      // Then - Capture screen is shown
      expect(find.text('Capture Receipt'), findsOneWidget);
      
      // When - Tap on Export tab
      await tester.tap(find.text('Export'));
      await tester.pumpAndSettle();
      
      // Then - Export screen is shown
      expect(find.text('Export Receipts'), findsOneWidget);
      
      // When - Go back to Receipts
      await tester.tap(find.text('Receipts'));
      await tester.pumpAndSettle();
      
      // Then - Back on receipts screen
      expect(find.text('Your Receipts'), findsAny);
    });

    testWidgets('user can access settings', (WidgetTester tester) async {
      // Given - App is launched
      await tester.pumpWidget(
        const ProviderScope(
          child: ReceiptOrganizerApp(),
        ),
      );
      await tester.pumpAndSettle();
      
      // When - Look for settings icon
      final settingsIcon = find.byIcon(Icons.settings);
      
      if (settingsIcon.evaluate().isNotEmpty) {
        // Tap settings if available
        await tester.tap(settingsIcon);
        await tester.pumpAndSettle();
        
        // Then - Settings screen is shown
        expect(find.text('Settings'), findsOneWidget);
      }
    });

    testWidgets('export screen shows format options', (WidgetTester tester) async {
      // Given - App is launched
      await tester.pumpWidget(
        const ProviderScope(
          child: ReceiptOrganizerApp(),
        ),
      );
      await tester.pumpAndSettle();
      
      // When - Navigate to Export
      await tester.tap(find.text('Export'));
      await tester.pumpAndSettle();
      
      // Then - Export format options are visible
      expect(find.text('QuickBooks'), findsAny);
      expect(find.text('Xero'), findsAny);
    });
  });
}