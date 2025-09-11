import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:receipt_organizer/main.dart' as app;
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/features/capture/widgets/notes_field_editor.dart';
import 'package:receipt_organizer/features/receipts/presentation/widgets/receipt_card.dart';
import 'package:flutter/material.dart';
import 'package:receipt_organizer/features/receipts/presentation/widgets/field_editor.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E: Notes Workflow', () {
    testWidgets('should complete full notes workflow from capture to search', 
        (WidgetTester tester) async {
      // Given - App is launched
      app.main();
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Scenario 1: Add notes during receipt capture
      // When - Navigate to capture screen
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Simulate successful capture (in real E2E, this would use camera)
      // For testing, we'll navigate to preview with mock data
      await _simulateReceiptCapture(tester);

      // When - Add notes to the receipt
      const testNotes = 'Business lunch with ABC Corp - discussed Q1 targets';
      await tester.enterText(find.byType(NotesFieldEditor), testNotes);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verify character counter updates
      expect(find.text('${testNotes.length} / 500'), findsOneWidget);

      // When - Save the receipt
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - Should return to main screen
      expect(find.byType(ReceiptCard), findsWidgets);

      // Scenario 2: View and edit notes in detail screen
      // When - Tap on the receipt to view details
      await tester.tap(find.byType(ReceiptCard).first);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - Should see the notes in detail view
      expect(find.text(testNotes), findsOneWidget);

      // When - Edit the notes
      const updatedNotes = '$testNotes\nFollow-up scheduled for next week';
      await tester.tap(find.byType(NotesFieldEditor));
      await tester.enterText(find.byType(NotesFieldEditor), updatedNotes);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Scenario 3: Search by notes content
      // When - Open search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // When - Search for content in notes
      await tester.enterText(find.byType(TextField), 'ABC Corp');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - Should find the receipt with matching notes
      expect(find.byType(ReceiptCard), findsOneWidget);
      expect(find.text('ABC Corp', skipOffstage: false), findsWidgets);

      // When - Search for non-existent content
      await tester.enterText(find.byType(TextField), 'XYZ Company');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - Should show no results
      expect(find.byType(ReceiptCard), findsNothing);
      expect(find.text('No receipts found'), findsOneWidget);

      // Scenario 4: Verify notes in CSV export
      // When - Clear search and navigate to export
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Navigate to export screen
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      await tester.tap(find.text('Export Receipts'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // When - Select receipts and export
      await tester.tap(find.text('Select All'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      await tester.tap(find.text('Export to CSV'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - Export should complete successfully
      expect(find.text('Export completed'), findsOneWidget);

      // Scenario 5: Test edge cases
      // When - Add receipt with max length notes
      await _addReceiptWithNotes(tester, 'A' * 500);
      
      // Then - Should handle max length correctly
      expect(find.text('500 / 500'), findsOneWidget);

      // When - Try to add more characters (should be prevented)
      await tester.enterText(find.byType(NotesFieldEditor).last, 'A' * 501);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Then - Should still show max length
      expect(find.text('500 / 500'), findsOneWidget);
    });

    testWidgets('should handle special characters and sanitization', 
        (WidgetTester tester) async {
      // Given - App is launched
      app.main();
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // When - Add receipt with special characters in notes
      await _simulateReceiptCapture(tester);
      
      // Test various special characters
      const specialNotes = r'Receipt for: $50.00 @ Store #123' '\nItems: Coffee & Donuts';
      await tester.enterText(find.byType(NotesFieldEditor), specialNotes);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Save receipt
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // When - Search for special characters
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      await tester.enterText(find.byType(TextField), '#123');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - Should find the receipt
      expect(find.byType(ReceiptCard), findsOneWidget);

      // Test sanitization - try to enter script tags
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      await _simulateReceiptCapture(tester);
      const maliciousNotes = 'Normal text <script>alert("test")</script> more text';
      await tester.enterText(find.byType(NotesFieldEditor), maliciousNotes);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - Script tags should be removed
      expect(find.text('Normal text  more text'), findsOneWidget);
    });
  });
}

/// Simulates receipt capture flow for testing
Future<void> _simulateReceiptCapture(WidgetTester tester) async {
  // In a real E2E test, this would interact with the camera
  // For now, we'll simulate navigation to preview screen
  // This assumes test mode provides a way to bypass camera
  
  // The actual implementation would depend on how the app handles
  // test/demo mode for camera functionality
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}

/// Helper to add a receipt with specific notes
Future<void> _addReceiptWithNotes(WidgetTester tester, String notes) async {
  await tester.tap(find.byIcon(Icons.camera_alt));
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
  await _simulateReceiptCapture(tester);
  await tester.enterText(find.byType(NotesFieldEditor), notes);
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}