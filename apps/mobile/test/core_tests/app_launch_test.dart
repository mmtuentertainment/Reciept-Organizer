/// Minimal App Launch Test
/// Verifies the app starts without crashing

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/main.dart';
import '../test_utils.dart';

void main() {
  group('App Launch - Smoke Test', () {
    testWidgets('app should launch without crashing', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        const ProviderScope(
          child: ReceiptOrganizerApp(),
        ),
      );
      await tester.pump();
      
      // Then - App loaded
      expect(find.text('Receipt Organizer'), findsOneWidget);
    });

    testWidgets('bottom navigation should be visible', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        const ProviderScope(
          child: ReceiptOrganizerApp(),
        ),
      );
      await tester.pumpAndSettle();
      
      // Then - Navigation items exist
      expect(find.text('Receipts'), findsOneWidget);
      expect(find.text('Capture'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);
    });
  });
}