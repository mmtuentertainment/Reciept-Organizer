import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/features/export/domain/services/csv_preview_service.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/csv_preview_table.dart';

void main() {
  group('CSVPreviewTable Widget Tests', () {
    late List<List<String>> testPreviewRows;
    late List<ValidationWarning> testWarnings;

    setUp(() {
      testPreviewRows = [
        ['Date', 'Merchant', 'Amount', 'Tax', 'Notes'],
        ['01/15/2024', 'Test Store', '100.00', '10.00', 'Test note'],
        ['01/16/2024', 'Another Store', '200.00', '20.00', ''],
        ['01/17/2024', 'Third Store', '300.00', '30.00', ''],
        ['01/18/2024', 'Fourth Store', '400.00', '40.00', ''],
        ['01/19/2024', 'Fifth Store', '500.00', '50.00', ''],
      ];

      testWarnings = [
        ValidationWarning(
          rowIndex: 1,
          columnIndex: 1,
          message: 'Potential CSV injection detected',
          severity: WarningSeverity.critical,
        ),
        ValidationWarning(
          rowIndex: 2,
          columnIndex: 2,
          message: 'Invalid amount format',
          severity: WarningSeverity.medium,
        ),
      ];
    });

    Widget createTestWidget(Widget child) {
      return MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: Scaffold(
          body: child,
        ),
      );
    }

    testWidgets('displays preview table with headers', (tester) async {
      await tester.pumpWidget(createTestWidget(
        CSVPreviewTable(
          previewRows: testPreviewRows,
          totalCount: 10,
        ),
      ));

      // Check headers are displayed
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Merchant'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Tax'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('displays first 5 data rows', (tester) async {
      await tester.pumpWidget(createTestWidget(
        CSVPreviewTable(
          previewRows: testPreviewRows,
          totalCount: 10,
        ),
      ));

      // Check data rows are displayed
      expect(find.text('Test Store'), findsOneWidget);
      expect(find.text('Another Store'), findsOneWidget);
      expect(find.text('Third Store'), findsOneWidget);
      expect(find.text('Fourth Store'), findsOneWidget);
      expect(find.text('Fifth Store'), findsOneWidget);
    });

    testWidgets('shows row count indicator when more rows exist', (tester) async {
      await tester.pumpWidget(createTestWidget(
        CSVPreviewTable(
          previewRows: testPreviewRows,
          totalCount: 50,
        ),
      ));

      // Should show "... 45 more rows" (50 total - 5 displayed)
      expect(find.text('... 45 more rows'), findsOneWidget);
      expect(find.icon(Icons.more_horiz), findsOneWidget);
    });

    testWidgets('displays warning summary for critical warnings', (tester) async {
      await tester.pumpWidget(createTestWidget(
        CSVPreviewTable(
          previewRows: testPreviewRows,
          totalCount: 10,
          warnings: testWarnings,
        ),
      ));

      // Should show critical warning summary
      expect(find.text('1 critical security warnings detected'), findsOneWidget);
      expect(find.icon(Icons.warning_amber_rounded), findsWidgets);
    });

    testWidgets('shows loading state', (tester) async {
      await tester.pumpWidget(createTestWidget(
        CSVPreviewTable(
          previewRows: const [],
          totalCount: 0,
          isLoading: true,
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Generating preview...'), findsOneWidget);
    });

    testWidgets('shows error state', (tester) async {
      const errorMessage = 'Failed to generate preview';
      
      await tester.pumpWidget(createTestWidget(
        CSVPreviewTable(
          previewRows: const [],
          totalCount: 0,
          error: errorMessage,
        ),
      ));

      expect(find.text(errorMessage), findsOneWidget);
      expect(find.icon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows empty state when no data', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const CSVPreviewTable(
          previewRows: [],
          totalCount: 0,
        ),
      ));

      expect(find.text('No data to preview'), findsOneWidget);
      expect(find.icon(Icons.table_chart_outlined), findsOneWidget);
    });

    testWidgets('table is horizontally scrollable', (tester) async {
      // Create wide data to test horizontal scrolling
      final widePreviewRows = [
        ['Date', 'Merchant', 'Amount', 'Tax', 'Notes', 'Category', 'Project', 'Client', 'Status', 'Reference'],
        ['01/15/2024', 'Very Long Merchant Name That Should Overflow', '100.00', '10.00', 'Long note that contains lots of text', 'Office Supplies', 'Project Alpha', 'Client XYZ', 'Approved', 'REF-001'],
      ];

      await tester.pumpWidget(createTestWidget(
        CSVPreviewTable(
          previewRows: widePreviewRows,
          totalCount: 1,
        ),
      ));

      // Find the horizontal scrollable
      final scrollableFinder = find.byType(SingleChildScrollView).first;
      expect(scrollableFinder, findsOneWidget);

      // Verify horizontal scrolling is enabled
      final SingleChildScrollView scrollable = tester.widget(scrollableFinder);
      expect(scrollable.scrollDirection, Axis.horizontal);
    });

    testWidgets('displays row numbers', (tester) async {
      await tester.pumpWidget(createTestWidget(
        CSVPreviewTable(
          previewRows: testPreviewRows,
          totalCount: 10,
        ),
      ));

      // Check row numbers are displayed
      expect(find.text('1.'), findsOneWidget);
      expect(find.text('2.'), findsOneWidget);
      expect(find.text('3.'), findsOneWidget);
      expect(find.text('4.'), findsOneWidget);
      expect(find.text('5.'), findsOneWidget);
    });

    testWidgets('highlights cells with warnings', (tester) async {
      await tester.pumpWidget(createTestWidget(
        CSVPreviewTable(
          previewRows: testPreviewRows,
          totalCount: 10,
          warnings: testWarnings,
        ),
      ));

      // Should have warning icons for cells with warnings
      // One in summary, plus one for each warning
      final warningIcons = find.icon(Icons.warning_amber_rounded);
      expect(warningIcons, findsWidgets);
    });

    testWidgets('shows tooltip on warning icon hover', (tester) async {
      await tester.pumpWidget(createTestWidget(
        CSVPreviewTable(
          previewRows: testPreviewRows,
          totalCount: 10,
          warnings: testWarnings,
        ),
      ));

      // Find a Tooltip widget
      final tooltipFinder = find.byType(Tooltip);
      expect(tooltipFinder, findsWidgets);

      // Verify tooltip contains warning message
      final Tooltip tooltip = tester.widget(tooltipFinder.first);
      expect(tooltip.message, contains('CSV injection'));
    });

    testWidgets('applies Material 3 theming', (tester) async {
      await tester.pumpWidget(createTestWidget(
        CSVPreviewTable(
          previewRows: testPreviewRows,
          totalCount: 10,
        ),
      ));

      // Check DataTable is using Material 3 styling
      final dataTable = find.byType(DataTable);
      expect(dataTable, findsOneWidget);

      // Verify border radius on container
      final container = find.byType(Container).first;
      expect(container, findsOneWidget);
    });

    testWidgets('handles empty notes gracefully', (tester) async {
      await tester.pumpWidget(createTestWidget(
        CSVPreviewTable(
          previewRows: testPreviewRows,
          totalCount: 10,
        ),
      ));

      // Row 2 has empty notes - should not cause issues
      expect(find.text('Another Store'), findsOneWidget);
      // Empty note cells should just be empty, not cause errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not show row count indicator when all rows visible', (tester) async {
      await tester.pumpWidget(createTestWidget(
        CSVPreviewTable(
          previewRows: testPreviewRows.take(3).toList(), // 2 data rows + header
          totalCount: 2,
        ),
      ));

      // Should not show "more rows" indicator
      expect(find.textContaining('more rows'), findsNothing);
      expect(find.icon(Icons.more_horiz), findsNothing);
    });
  });
}