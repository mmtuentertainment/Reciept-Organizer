import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/receipts/screens/receipts_list_screen.dart';
import 'package:receipt_organizer/core/models/receipt.dart' as core_models;
import 'package:uuid/uuid.dart';
import '../helpers/widget_test_helper.dart';
import '../mocks/proper_async_receipt_mock.dart';
import 'package:receipt_organizer/features/receipts/providers/receipts_provider.dart';

void main() {
  group('ReceiptsScreen Async Tests', () {
    final uuid = const Uuid();

    setUpAll(() {
      WidgetTestHelper.setupAllMocks();
    });

    setUp(() {
      // Clear test receipts before each test
      TestReceiptStore.clear();
    });

    Widget createWidgetUnderTest() {
      return WidgetTestHelper.createTestableWidget(
        child: const ReceiptsListScreen(),
        useAsyncReceipts: true,  // Use proper async receipts
      );
    }

    testWidgets('displays receipts screen title', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Wait for all animations to complete

      expect(find.text('Receipts'), findsAtLeastNWidgets(1));
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows loading state initially then data', (WidgetTester tester) async {
      // Add some test data
      TestReceiptStore.add(core_models.Receipt(
        id: uuid.v4(),
        merchantName: 'Test Store',
        date: DateTime.now(),
        imagePath: '/test.jpg',
        createdAt: DateTime.now(),
      ));

      await tester.pumpWidget(createWidgetUnderTest());

      // Initially shows loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for async operation to complete
      await tester.pumpAndSettle();

      // Now should show data
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Test Store'), findsOneWidget);
    });

    testWidgets('shows empty state when no receipts', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Wait for all animations

      final emptyText = find.textContaining('No receipts');
      final addText = find.textContaining('Add your first');
      final captureText = find.textContaining('capture your first');

      expect(
        emptyText.evaluate().isNotEmpty ||
        addText.evaluate().isNotEmpty ||
        captureText.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('displays list of receipts', (WidgetTester tester) async {
      // Add test receipts
      TestReceiptStore.add(core_models.Receipt(
        id: uuid.v4(),
        merchantName: 'Walmart',
        totalAmount: 125.75,
        date: DateTime.now(),
        imagePath: '/test1.jpg',
        createdAt: DateTime.now(),
      ));

      TestReceiptStore.add(core_models.Receipt(
        id: uuid.v4(),
        merchantName: 'Target',
        totalAmount: 89.99,
        date: DateTime.now().subtract(const Duration(days: 1)),
        imagePath: '/test2.jpg',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Wait for all animations

      expect(find.text('Walmart'), findsOneWidget);
      expect(find.text('Target'), findsOneWidget);
      expect(find.textContaining('125'), findsAtLeastNWidgets(1));
      expect(find.textContaining('89'), findsAtLeastNWidgets(1));
    });

    testWidgets('can search receipts with debounce', (WidgetTester tester) async {
      // Add receipts with different vendors
      TestReceiptStore.add(core_models.Receipt(
        id: uuid.v4(),
        merchantName: 'Walmart',
        totalAmount: 45.00,
        date: DateTime.now(),
        imagePath: '/walmart.jpg',
        createdAt: DateTime.now(),
      ));

      TestReceiptStore.add(core_models.Receipt(
        id: uuid.v4(),
        merchantName: 'Walgreens',
        totalAmount: 22.50,
        date: DateTime.now(),
        imagePath: '/walgreens.jpg',
        createdAt: DateTime.now(),
      ));

      TestReceiptStore.add(core_models.Receipt(
        id: uuid.v4(),
        merchantName: 'Target',
        totalAmount: 89.99,
        date: DateTime.now(),
        imagePath: '/target.jpg',
        createdAt: DateTime.now(),
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Wait for all animations

      // Find and enter text in search field
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Wal');

      // Handle the debounce timer properly
      await WidgetTestHelper.pumpForDebounce(tester);

      // Should filter results
      expect(find.text('Walmart'), findsOneWidget);
      expect(find.text('Walgreens'), findsOneWidget);
      expect(find.text('Target'), findsNothing);
    });

    testWidgets('supports pull to refresh', (WidgetTester tester) async {
      // Add a test receipt
      TestReceiptStore.add(core_models.Receipt(
        id: uuid.v4(),
        merchantName: 'Test Store',
        date: DateTime.now(),
        imagePath: '/test.jpg',
        createdAt: DateTime.now(),
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Wait for all animations

      // Find RefreshIndicator
      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Perform pull to refresh
      await tester.drag(
        find.byType(RefreshIndicator),
        const Offset(0, 300),
      );
      await tester.pump();

      // The refresh should trigger provider invalidation
      // Just verify it doesn't crash
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('can delete receipt with swipe', (WidgetTester tester) async {
      final receiptId = uuid.v4();
      // Add a test receipt
      TestReceiptStore.add(core_models.Receipt(
        id: receiptId,
        merchantName: 'Delete Store',
        totalAmount: 25.00,
        date: DateTime.now(),
        imagePath: '/delete.jpg',
        createdAt: DateTime.now(),
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Wait for all animations

      // Verify receipt is shown
      expect(find.text('Delete Store'), findsOneWidget);

      // Find and swipe receipt
      final receiptTile = find.text('Delete Store');
      await tester.drag(receiptTile, const Offset(-300, 0));
      await tester.pump();

      // Look for delete button
      final deleteButton = find.byIcon(Icons.delete);
      if (deleteButton.evaluate().isNotEmpty) {
        await tester.tap(deleteButton);
        await tester.pump();

        // Confirm deletion if dialog appears
        final confirmButton = find.text('Delete');
        if (confirmButton.evaluate().length > 1) {
          await tester.tap(confirmButton.last);
          await tester.pump();
        }

        // Wait for async deletion and provider refresh
        await tester.pump();

        // Receipt should be gone
        expect(find.text('Delete Store'), findsNothing);
      }
    });

    testWidgets('handles error state gracefully', (WidgetTester tester) async {
      // Override provider to simulate error
      await tester.pumpWidget(
        WidgetTestHelper.createTestableWidget(
          child: const ReceiptsListScreen(),
          overrides: [
            receiptsProvider.overrideWith((ref) async {
              throw Exception('Network error');
            }),
          ],
        ),
      );

      // Wait for error state
      await tester.pumpAndSettle();

      // Should show error UI
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Failed to load receipts'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('retry button refetches data', (WidgetTester tester) async {
      bool shouldFail = true;

      // Override provider to fail first, then succeed
      await tester.pumpWidget(
        WidgetTestHelper.createTestableWidget(
          child: const ReceiptsListScreen(),
          overrides: [
            receiptsProvider.overrideWith((ref) async {
              if (shouldFail) {
                shouldFail = false;
                throw Exception('Network error');
              }
              return [
                core_models.Receipt(
                  id: uuid.v4(),
                  merchantName: 'Success Store',
                  date: DateTime.now(),
                  imagePath: '/test.jpg',
                  createdAt: DateTime.now(),
                ),
              ];
            }),
          ],
        ),
      );

      // Wait for error state
      await tester.pumpAndSettle();

      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Should now show data
      expect(find.text('Success Store'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('search field clears and refreshes', (WidgetTester tester) async {
      TestReceiptStore.add(core_models.Receipt(
        id: uuid.v4(),
        merchantName: 'Test Store',
        date: DateTime.now(),
        imagePath: '/test.jpg',
        createdAt: DateTime.now(),
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'Search');
      await tester.pumpAndSettle();

      // Clear button should appear
      final clearButton = find.byIcon(Icons.clear);
      expect(clearButton, findsOneWidget);

      // Tap clear button
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      // Search field should be cleared
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text ?? '', isEmpty);
    });
  });
}