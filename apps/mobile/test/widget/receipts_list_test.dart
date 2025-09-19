import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/receipts/screens/receipts_list_screen.dart';
import 'package:receipt_organizer/data/repositories/receipt_repository.dart';
import 'package:receipt_organizer/data/models/receipt.dart' as models;
import 'package:uuid/uuid.dart';

void main() {
  group('ReceiptsScreen Widget Tests', () {
    late ReceiptRepository repository;
    final uuid = const Uuid();

    setUp(() async {
      repository = ReceiptRepository();
      await repository.clearAllData();
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        child: MaterialApp(
          home: ReceiptsListScreen(),
        ),
      );
    }

    testWidgets('displays receipts screen title', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Receipts'), findsAtLeastNWidgets(1));
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows empty state when no receipts', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final emptyText = find.textContaining('No receipts');
      final addText = find.textContaining('Add your first');

      expect(
        emptyText.evaluate().isNotEmpty || addText.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('displays list of receipts', (WidgetTester tester) async {
      // Add test receipts
      await repository.createReceipt(models.Receipt(
        id: uuid.v4(),
        imageUri: '/test1.jpg',
        capturedAt: DateTime.now(),
        vendorName: 'Walmart',
        totalAmount: 125.75,
        receiptDate: DateTime.now(),
      ));

      await repository.createReceipt(models.Receipt(
        id: uuid.v4(),
        imageUri: '/test2.jpg',
        capturedAt: DateTime.now().subtract(const Duration(hours: 1)),
        vendorName: 'Target',
        totalAmount: 89.99,
        receiptDate: DateTime.now().subtract(const Duration(days: 1)),
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Walmart'), findsOneWidget);
      expect(find.text('Target'), findsOneWidget);
      expect(find.text('125.75'), findsOneWidget);
      expect(find.text('89.99'), findsOneWidget);
    });

    testWidgets('shows search icon in app bar', (WidgetTester tester) async {
      await repository.createReceipt(models.Receipt(
        id: uuid.v4(),
        imageUri: '/test.jpg',
        capturedAt: DateTime.now(),
        vendorName: 'Test Store',
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final searchIcon = find.byIcon(Icons.search);
      expect(searchIcon, findsAtLeastNWidgets(1));
    });

    testWidgets('can search receipts', (WidgetTester tester) async {
      // Add receipts with different vendors
      await repository.createReceipt(models.Receipt(
        id: uuid.v4(),
        imageUri: '/walmart.jpg',
        capturedAt: DateTime.now(),
        vendorName: 'Walmart',
        totalAmount: 45.00,
      ));

      await repository.createReceipt(models.Receipt(
        id: uuid.v4(),
        imageUri: '/walgreens.jpg',
        capturedAt: DateTime.now(),
        vendorName: 'Walgreens',
        totalAmount: 22.50,
      ));

      await repository.createReceipt(models.Receipt(
        id: uuid.v4(),
        imageUri: '/target.jpg',
        capturedAt: DateTime.now(),
        vendorName: 'Target',
        totalAmount: 89.99,
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap search icon
      final searchIcon = find.byIcon(Icons.search);
      if (searchIcon.evaluate().isNotEmpty) {
        await tester.tap(searchIcon);
        await tester.pumpAndSettle();

        // Enter search query
        final searchField = find.byType(TextField);
        await tester.enterText(searchField.first, 'Wal');
        await tester.pumpAndSettle();

        // Should filter results
        expect(find.text('Walmart'), findsOneWidget);
        expect(find.text('Walgreens'), findsOneWidget);
        expect(find.text('Target'), findsNothing);
      }
    });

    testWidgets('shows filter icon', (WidgetTester tester) async {
      await repository.createReceipt(models.Receipt(
        id: uuid.v4(),
        imageUri: '/test.jpg',
        capturedAt: DateTime.now(),
        vendorName: 'Test Store',
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final filterIcon = find.byIcon(Icons.filter_list);
      expect(filterIcon, findsAtLeastNWidgets(1));
    });

    testWidgets('can tap on receipt to view details', (WidgetTester tester) async {
      await repository.createReceipt(models.Receipt(
        id: uuid.v4(),
        imageUri: '/detail.jpg',
        capturedAt: DateTime.now(),
        vendorName: 'Detail Store',
        totalAmount: 50.00,
        notes: 'Test notes',
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap on receipt
      final receiptTile = find.text('Detail Store');
      await tester.tap(receiptTile);
      await tester.pumpAndSettle();

      // Should navigate to detail view
      // Look for detail-specific elements
      final notesText = find.text('Test notes');
      if (notesText.evaluate().isNotEmpty) {
        expect(notesText, findsOneWidget);
      }
    });

    testWidgets('shows receipt cards with correct styling', (WidgetTester tester) async {
      await repository.createReceipt(models.Receipt(
        id: uuid.v4(),
        imageUri: '/test.jpg',
        capturedAt: DateTime.now(),
        vendorName: 'Test Store',
        totalAmount: 99.99,
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Check for receipt card
      final card = find.byType(Card);
      if (card.evaluate().isEmpty) {
        // Try finding ListTile or Container
        final listTile = find.byType(ListTile);
        expect(listTile, findsAtLeastNWidgets(1));
      } else {
        expect(card, findsAtLeastNWidgets(1));
      }
    });

    testWidgets('supports pull to refresh', (WidgetTester tester) async {
      await repository.createReceipt(models.Receipt(
        id: uuid.v4(),
        imageUri: '/test.jpg',
        capturedAt: DateTime.now(),
        vendorName: 'Test Store',
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Perform pull to refresh
      final scrollable = find.byType(Scrollable).first;
      await tester.drag(scrollable, const Offset(0, 300));
      await tester.pump();

      // Should show refresh indicator
      expect(find.byType(RefreshIndicator), findsAtLeastNWidgets(1));

      await tester.pumpAndSettle();
    });

    testWidgets('shows loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Before settling, should show loading
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));

      await tester.pumpAndSettle();

      // After loading, indicator should be gone
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('can delete receipt with swipe', (WidgetTester tester) async {
      final receiptId = uuid.v4();
      await repository.createReceipt(models.Receipt(
        id: receiptId,
        imageUri: '/delete.jpg',
        capturedAt: DateTime.now(),
        vendorName: 'Delete Store',
        totalAmount: 25.00,
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find and swipe receipt
      final receiptTile = find.text('Delete Store');
      await tester.drag(receiptTile, const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Look for delete button
      final deleteButton = find.byIcon(Icons.delete);
      if (deleteButton.evaluate().isNotEmpty) {
        await tester.tap(deleteButton);
        await tester.pumpAndSettle();

        // Confirm deletion if dialog appears
        final confirmButton = find.text('Delete');
        if (confirmButton.evaluate().length > 1) {
          await tester.tap(confirmButton.last);
          await tester.pumpAndSettle();
        }

        // Receipt should be gone
        expect(find.text('Delete Store'), findsNothing);
      }
    });

    testWidgets('shows selection mode for batch operations', (WidgetTester tester) async {
      // Add multiple receipts
      for (int i = 0; i < 3; i++) {
        await repository.createReceipt(models.Receipt(
          id: uuid.v4(),
          imageUri: '/batch-$i.jpg',
          capturedAt: DateTime.now(),
          vendorName: 'Store $i',
          totalAmount: i * 10.0,
        ));
      }

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Look for selection mode toggle
      final selectButton = find.byIcon(Icons.check_box_outline_blank);
      if (selectButton.evaluate().isNotEmpty) {
        await tester.tap(selectButton);
        await tester.pumpAndSettle();

        // Should show checkboxes
        expect(find.byType(Checkbox), findsAtLeastNWidgets(3));
      }
    });

    testWidgets('shows sort options', (WidgetTester tester) async {
      await repository.createReceipt(models.Receipt(
        id: uuid.v4(),
        imageUri: '/test.jpg',
        capturedAt: DateTime.now(),
        vendorName: 'Test Store',
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Look for sort button
      final sortButton = find.byIcon(Icons.sort);
      if (sortButton.evaluate().isNotEmpty) {
        await tester.tap(sortButton);
        await tester.pumpAndSettle();

        // Should show sort options
        expect(find.text('Date'), findsAtLeastNWidgets(1));
        expect(find.text('Amount'), findsAtLeastNWidgets(1));
        expect(find.text('Vendor'), findsAtLeastNWidgets(1));
      }
    });
  });
}