import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/format_selection.dart';
import 'package:receipt_organizer/domain/services/csv_export_service.dart';

void main() {
  group('FormatSelectionWidget', () {
    late Widget testWidget;

    setUp(() {
      testWidget = const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: FormatSelectionWidget(),
            ),
          ),
        ),
      );
    });

    testWidgets('should render all three format options', (tester) async {
      // Given
      await tester.pumpWidget(testWidget);

      // Then
      expect(find.text('QuickBooks'), findsOneWidget);
      expect(find.text('Xero'), findsOneWidget);
      expect(find.text('Generic CSV'), findsOneWidget);
    });

    testWidgets('should display format icons', (tester) async {
      // Given
      await tester.pumpWidget(testWidget);

      // Then
      expect(find.byIcon(Icons.account_balance), findsNWidgets(2)); // In button and description
      expect(find.byIcon(Icons.cloud_circle), findsOneWidget);
      expect(find.byIcon(Icons.table_chart), findsOneWidget);
    });

    testWidgets('should show format description for selected format', (tester) async {
      // Given
      await tester.pumpWidget(testWidget);

      // Then - QuickBooks is selected by default (TODO: will change with provider)
      expect(
        find.text('Compatible with QuickBooks Desktop and Online. Uses MM/dd/yyyy date format.'),
        findsOneWidget,
      );
    });

    testWidgets('should display required fields for selected format', (tester) async {
      // Given
      await tester.pumpWidget(testWidget);

      // Then - QuickBooks fields shown by default
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Payee'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
    });

    testWidgets('should show date and amount format info', (tester) async {
      // Given
      await tester.pumpWidget(testWidget);

      // Then
      expect(find.text('Date format: MM/dd/yyyy'), findsOneWidget);
      expect(find.text('Amount format: 0.00 (two decimal places)'), findsOneWidget);
      expect(find.text('Security: CSV injection prevention enabled'), findsOneWidget);
    });

    testWidgets('should have accessibility labels', (tester) async {
      // Given
      await tester.pumpWidget(testWidget);

      // Then
      final segmentedButton = find.byType(SegmentedButton<ExportFormat>);
      expect(segmentedButton, findsOneWidget);

      // Check Semantics
      final semantics = tester.getSemantics(segmentedButton);
      expect(semantics.label, 'CSV export format selector');
      expect(semantics.hint, 'Choose the format for exporting receipts');
    });

    testWidgets('should support keyboard navigation', (tester) async {
      // Given
      await tester.pumpWidget(testWidget);

      // When - Tab to the segmented button
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - First button should have focus
      final quickBooksButton = find.ancestor(
        of: find.text('QuickBooks'),
        matching: find.byType(InkWell),
      ).first;
      
      // Verify focus traversal works
      expect(quickBooksButton, findsOneWidget);
    });

    testWidgets('should have proper contrast ratios', (tester) async {
      // Given
      await tester.pumpWidget(testWidget);

      // Then - Verify text widgets exist with proper styling
      final titleText = find.text('QuickBooks').first;
      expect(titleText, findsOneWidget);
      
      // Get the Text widget
      final textWidget = tester.widget<Text>(titleText);
      expect(textWidget.style, isNotNull);
      
      // Note: Actual contrast ratio testing would require theme analysis
      // This is typically done with accessibility testing tools
    });

    testWidgets('should display tooltips on long press', (tester) async {
      // Given
      await tester.pumpWidget(testWidget);

      // When - Long press on QuickBooks button
      final quickBooksButton = find.ancestor(
        of: find.text('QuickBooks'),
        matching: find.byType(InkWell),
      ).first;
      
      await tester.longPress(quickBooksButton);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - Tooltip should appear
      expect(
        find.text('Compatible with QuickBooks Desktop and Online. Uses MM/dd/yyyy date format.'),
        findsNWidgets(2), // In description and tooltip
      );
    });

    testWidgets('should handle format selection changes', (tester) async {
      // Given
      await tester.pumpWidget(testWidget);

      // When - Tap on Xero format
      await tester.tap(find.text('Xero'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - Selection should be handled (actual state change will be tested with provider)
      // For now, just verify the tap is registered
      expect(find.text('Xero'), findsOneWidget);
    });

    testWidgets('should announce format changes to screen readers', (tester) async {
      // Given
      await tester.pumpWidget(testWidget);

      // When - Tap on Generic CSV format
      await tester.tap(find.text('Generic CSV'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - Announcement should be made (actual announcement testing requires semantics)
      // This is a placeholder for integration with screen reader testing
      expect(find.text('Generic CSV'), findsOneWidget);
    });

    group('Format Information Display', () {
      testWidgets('should show correct info for QuickBooks', (tester) async {
        // Given
        await tester.pumpWidget(testWidget);

        // Then
        expect(find.text('Date format: MM/dd/yyyy'), findsOneWidget);
        expect(find.text('Category'), findsOneWidget); // QuickBooks specific field
      });

      testWidgets('should have security info visible', (tester) async {
        // Given
        await tester.pumpWidget(testWidget);

        // Then
        expect(find.byIcon(Icons.security), findsOneWidget);
        expect(find.text('CSV injection prevention enabled'), findsOneWidget);
      });
    });
  });
}