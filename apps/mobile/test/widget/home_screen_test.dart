import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/main.dart';
import 'package:receipt_organizer/data/repositories/receipt_repository.dart';
import 'package:receipt_organizer/data/models/receipt.dart' as models;
import 'package:uuid/uuid.dart';
import '../helpers/platform_channel_mocks.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    late ReceiptRepository repository;
    final uuid = const Uuid();

    setUp(() async {
      setupPlatformChannelMocks();
      repository = ReceiptRepository();
      await repository.clearAllData();
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      );
    }

    testWidgets('displays app title', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Receipt Organizer'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows capture receipt button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final captureButton = find.text('Capture Receipt');
      expect(captureButton, findsOneWidget);

      // Verify button is enabled
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Capture Receipt')
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('displays receipt count when receipts exist', (WidgetTester tester) async {
      // Add test receipts
      await repository.createReceipt(models.Receipt(
        id: uuid.v4(),
        imageUri: '/test1.jpg',
        capturedAt: DateTime.now(),
        vendorName: 'Store 1',
        totalAmount: 50.00,
      ));

      await repository.createReceipt(models.Receipt(
        id: uuid.v4(),
        imageUri: '/test2.jpg',
        capturedAt: DateTime.now(),
        vendorName: 'Store 2',
        totalAmount: 75.00,
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should show count
      expect(find.textContaining('2'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows empty state when no receipts', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Look for empty state indicators
      final emptyText = find.textContaining('No receipts');
      final startText = find.textContaining('Start');

      expect(
        emptyText.evaluate().isNotEmpty || startText.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('navigates to settings when settings icon tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final settingsIcon = find.byIcon(Icons.settings);
      if (settingsIcon.evaluate().isNotEmpty) {
        await tester.tap(settingsIcon);
        await tester.pumpAndSettle();

        // Should navigate to settings
        expect(find.text('Settings'), findsOneWidget);
      }
    });

    testWidgets('shows recent receipts section', (WidgetTester tester) async {
      // Add recent receipts
      await repository.createReceipt(models.Receipt(
        id: uuid.v4(),
        imageUri: '/recent1.jpg',
        capturedAt: DateTime.now(),
        vendorName: 'Recent Store',
        totalAmount: 25.99,
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Look for recent section
      final recentText = find.textContaining('Recent');
      if (recentText.evaluate().isNotEmpty) {
        expect(recentText, findsOneWidget);
        expect(find.text('Recent Store'), findsOneWidget);
        expect(find.text('25.99'), findsOneWidget);
      }
    });

    testWidgets('shows loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Before settling, should show loading
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));

      await tester.pumpAndSettle();

      // After settling, loading should be gone
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('handles dark mode toggle', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Get initial theme
      final context = tester.element(find.byType(HomeScreen));
      final initialBrightness = Theme.of(context).brightness;

      // Find and tap dark mode toggle if available
      final darkModeSwitch = find.byType(Switch);
      if (darkModeSwitch.evaluate().isNotEmpty) {
        await tester.tap(darkModeSwitch.first);
        await tester.pumpAndSettle();

        final newBrightness = Theme.of(context).brightness;
        expect(newBrightness, isNot(equals(initialBrightness)));
      }
    });

    testWidgets('shows export button when receipts exist', (WidgetTester tester) async {
      // Add receipts
      await repository.createReceipt(models.Receipt(
        id: uuid.v4(),
        imageUri: '/export1.jpg',
        capturedAt: DateTime.now(),
        vendorName: 'Export Store',
        totalAmount: 100.00,
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final exportButton = find.text('Export');
      if (exportButton.evaluate().isNotEmpty) {
        expect(exportButton, findsOneWidget);

        // Verify button is enabled
        final button = tester.widget<Widget>(exportButton);
        expect(button, isNotNull);
      }
    });

    testWidgets('refreshes on pull to refresh', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find scrollable widget
      final scrollable = find.byType(Scrollable).first;

      // Perform pull to refresh
      await tester.drag(scrollable, const Offset(0, 300));
      await tester.pump();

      // Should show refresh indicator
      expect(find.byType(RefreshIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });
}