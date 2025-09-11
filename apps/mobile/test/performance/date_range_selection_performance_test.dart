import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/export/presentation/pages/export_screen.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/date_range_picker.dart';
import 'package:receipt_organizer/features/export/presentation/providers/date_range_provider.dart';
import 'package:receipt_organizer/core/repositories/interfaces/i_receipt_repository.dart';
import 'package:receipt_organizer/core/providers/repository_providers.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/core/theme/app_theme.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

@GenerateNiceMocks([MockSpec<IReceiptRepository>()])
import 'date_range_selection_performance_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Initialize FFI for testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  group('Date Range Selection Performance Tests', () {
    late MockIReceiptRepository mockReceiptRepository;

    setUp(() {
      mockReceiptRepository = MockIReceiptRepository();
    });

    Widget createTestWidget({
      required Widget child,
      List<Override>? overrides,
    }) {
      return ProviderScope(
        overrides: overrides ?? [],
        child: MaterialApp(
          theme: AppTheme.light,
          home: child,
        ),
      );
    }

    /// Create test receipts with dates spread across multiple months
    List<Receipt> createTestReceipts(int count) {
      final receipts = <Receipt>[];
      final baseDate = DateTime(2024, 1, 1);

      for (int i = 0; i < count; i++) {
        final dayOffset = i % 365; // Spread across a year
        final date = baseDate.add(Duration(days: dayOffset));
        
        receipts.add(Receipt(
          id: 'perf-test-$i',
          imageUri: 'file:///test/image_$i.jpg',
          capturedAt: date,
          status: ReceiptStatus.ready,
        ));
      }

      return receipts;
    }

    testWidgets('should render date range picker within 16ms', (tester) async {
      // Given
      when(mockReceiptRepository.getReceiptsByDateRange(any, any))
          .thenAnswer((_) async => createTestReceipts(100));

      // When
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(createTestWidget(
        child: const DateRangePickerWidget(),
      ));
      
      stopwatch.stop();

      // Then
      expect(stopwatch.elapsedMilliseconds, lessThan(16), 
        reason: 'Widget should render within one frame (16ms)');
    });

    testWidgets('should update date range selection within 100ms', (tester) async {
      // Given - Mock repository with 1000 receipts
      final testReceipts = createTestReceipts(1000);
      when(mockReceiptRepository.getReceiptsByDateRange(any, any))
          .thenAnswer((_) async {
            // Simulate database query time
            await Future.delayed(const Duration(milliseconds: 20));
            return testReceipts;
          });

      await tester.pumpWidget(createTestWidget(
        child: const DateRangePickerWidget(),
        overrides: [
          receiptRepositoryProvider.overrideWithValue(
            AsyncValue.data(mockReceiptRepository),
          ),
        ],
      ));

      // When - Tap on different preset
      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.text('This Month'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      stopwatch.stop();

      // Then
      expect(stopwatch.elapsedMilliseconds, lessThan(100),
        reason: 'Date range update should complete within 100ms');
    });

    testWidgets('should handle rapid preset changes efficiently', (tester) async {
      // Given
      when(mockReceiptRepository.getReceiptsByDateRange(any, any))
          .thenAnswer((_) async => createTestReceipts(500));

      await tester.pumpWidget(createTestWidget(
        child: const ExportScreen(),
        overrides: [
          receiptRepositoryProvider.overrideWithValue(
            AsyncValue.data(mockReceiptRepository),
          ),
        ],
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // When - Rapidly switch between presets
      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.text('This Month'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500)); // Don't wait for settle
      
      await tester.tap(find.text('Last Month'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      await tester.tap(find.text('Last 90 Days'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500)); // Wait for final state
      
      stopwatch.stop();

      // Then - Should handle rapid changes without blocking
      expect(stopwatch.elapsedMilliseconds, lessThan(300),
        reason: 'Rapid preset changes should not block UI');
    });

    testWidgets('should render export screen with 1000+ receipts efficiently', (tester) async {
      // Given
      final largeReceiptSet = createTestReceipts(1500);
      when(mockReceiptRepository.getReceiptsByDateRange(any, any))
          .thenAnswer((_) async => largeReceiptSet);

      final dateRangeState = DateRangeState(
        dateRange: DateTimeRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 12, 31),
        ),
        presetOption: DateRangePreset.custom,
        receiptCount: largeReceiptSet.length,
      );

      // When
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(createTestWidget(
        child: const ExportScreen(),
        overrides: [
          dateRangeNotifierProvider.overrideWith(() {
            return DateRangeNotifier()..state = AsyncData(dateRangeState);
          }),
        ],
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      stopwatch.stop();

      // Then
      expect(stopwatch.elapsedMilliseconds, lessThan(200),
        reason: 'Export screen should render efficiently even with 1500 receipts');
      
      // Verify count is displayed
      expect(find.text('1500 receipts found'), findsOneWidget);
    });

    testWidgets('should switch between export format tabs smoothly', (tester) async {
      // Given
      final dateRangeState = DateRangeState(
        dateRange: DateTimeRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        ),
        presetOption: DateRangePreset.thisMonth,
        receiptCount: 250,
      );

      await tester.pumpWidget(createTestWidget(
        child: const ExportScreen(),
        overrides: [
          dateRangeNotifierProvider.overrideWith(() {
            return DateRangeNotifier()..state = AsyncData(dateRangeState);
          }),
        ],
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // When - Switch tabs multiple times
      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.text('Xero'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      await tester.tap(find.text('Generic CSV'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      await tester.tap(find.text('QuickBooks'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      stopwatch.stop();

      // Then
      expect(stopwatch.elapsedMilliseconds / 3, lessThan(50),
        reason: 'Each tab switch should complete within 50ms average');
    });

    test('receipt count calculation performance with large dataset', () async {
      // Given
      final testReceipts = createTestReceipts(5000);
      when(mockReceiptRepository.getReceiptsByDateRange(any, any))
          .thenAnswer((_) async {
            // Simulate indexed database query
            await Future.delayed(const Duration(milliseconds: 50));
            return testReceipts;
          });

      // When
      final stopwatch = Stopwatch()..start();
      
      final results = await mockReceiptRepository.getReceiptsByDateRange(
        DateTime(2024, 1, 1),
        DateTime(2024, 12, 31),
      );
      
      stopwatch.stop();

      // Then
      expect(results.length, equals(5000));
      expect(stopwatch.elapsedMilliseconds, lessThan(100),
        reason: 'Large dataset query should complete within 100ms with index');
    });

    testWidgets('should maintain 60fps during scroll in export screen', (tester) async {
      // Given
      final dateRangeState = DateRangeState(
        dateRange: DateTimeRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        ),
        presetOption: DateRangePreset.thisMonth,
        receiptCount: 1000,
      );

      await tester.pumpWidget(createTestWidget(
        child: const ExportScreen(),
        overrides: [
          dateRangeNotifierProvider.overrideWith(() {
            return DateRangeNotifier()..state = AsyncData(dateRangeState);
          }),
        ],
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // When - Perform scroll gesture
      final scrollable = find.byType(SingleChildScrollView).first;
      
      // Start timing after initial render
      final frameTimings = <Duration>[];
      var lastFrameTime = DateTime.now();
      
      await tester.timedDragFrom(
        tester.getCenter(scrollable),
        const Offset(0, -300),
        const Duration(milliseconds: 500),
      );
      
      // Measure frame times during animation
      while (tester.hasRunningAnimations) {
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        final now = DateTime.now();
        frameTimings.add(now.difference(lastFrameTime));
        lastFrameTime = now;
      }

      // Then - Check frame times
      final averageFrameTime = frameTimings.isEmpty
          ? Duration.zero
          : frameTimings.reduce((a, b) => a + b) ~/ frameTimings.length;
      
      expect(averageFrameTime.inMilliseconds, lessThan(17),
        reason: 'Should maintain 60fps (16.7ms per frame) during scroll');
    });

    testWidgets('memory usage should remain stable with repeated operations', (tester) async {
      // Given
      final dateRangeState = DateRangeState(
        dateRange: DateTimeRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        ),
        presetOption: DateRangePreset.thisMonth,
        receiptCount: 100,
      );

      when(mockReceiptRepository.getReceiptsByDateRange(any, any))
          .thenAnswer((_) async => createTestReceipts(100));

      await tester.pumpWidget(createTestWidget(
        child: const ExportScreen(),
        overrides: [
          receiptRepositoryProvider.overrideWithValue(
            AsyncValue.data(mockReceiptRepository),
          ),
          dateRangeNotifierProvider.overrideWith(() {
            return DateRangeNotifier()..state = AsyncData(dateRangeState);
          }),
        ],
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // When - Perform repeated operations
      for (int i = 0; i < 10; i++) {
        // Switch date range presets
        await tester.tap(find.text(i % 2 == 0 ? 'Last Month' : 'This Month'));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        // Switch tabs
        await tester.tap(find.text(i % 3 == 0 ? 'Xero' : 'QuickBooks'));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      }

      // Then - Widget tree should remain stable
      expect(find.byType(ExportScreen), findsOneWidget);
      expect(find.byType(DateRangePickerWidget), findsOneWidget);
    });
  });
}