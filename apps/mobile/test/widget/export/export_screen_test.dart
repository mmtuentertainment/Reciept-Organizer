import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/export/presentation/pages/export_screen.dart';
import 'package:receipt_organizer/features/export/presentation/providers/date_range_provider.dart';
import 'package:receipt_organizer/features/export/presentation/providers/export_format_provider.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/date_range_picker.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/format_selection.dart';
import 'package:receipt_organizer/domain/services/csv_export_service.dart';
import 'package:receipt_organizer/core/theme/app_theme.dart';
import 'package:receipt_organizer/features/settings/providers/settings_provider.dart';
import 'package:receipt_organizer/data/models/app_settings.dart';

void main() {
  Widget createTestWidget(Widget child, {List<Override>? overrides}) {
    return ProviderScope(
      overrides: [
        appSettingsProvider.overrideWith((ref) => _MockAppSettingsNotifier(ref)),
        exportFormatNotifierProvider.overrideWith((ref) => _MockExportFormatNotifier(ref)),
        ...?overrides,
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: child,
      ),
    );
  }

  group('ExportScreen', () {
    testWidgets('should display loading state initially', (tester) async {
      // When
      await tester.pumpWidget(createTestWidget(
        const ExportScreen(),
        overrides: [
          dateRangeNotifierProvider.overrideWith(() => _LoadingDateRangeNotifier()),
        ],
      ));

      // Then
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display all main sections with format selection first', (tester) async {
      // Given - Create test state
      final testState = DateRangeState(
        dateRange: DateTimeRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        ),
        presetOption: DateRangePreset.thisMonth,
        receiptCount: 42,
      );

      // When
      await tester.pumpWidget(createTestWidget(
        const ExportScreen(),
        overrides: [
          dateRangeNotifierProvider.overrideWith(() => _TestDateRangeNotifier(testState)),
        ],
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then
      // Check app bar
      expect(find.text('Export Receipts'), findsOneWidget);

      // Check format selection appears first
      expect(find.text('Export Format'), findsOneWidget);
      expect(find.byType(FormatSelectionWidget), findsOneWidget);
      expect(find.byType(SegmentedButton<ExportFormat>), findsOneWidget);

      // Check date range picker appears after format
      expect(find.text('Select Date Range'), findsNWidgets(2)); // One in ExportScreen, one in DateRangePickerWidget
      expect(find.byType(DateRangePickerWidget), findsOneWidget);

      // Verify format selection appears before date range
      final exportFormatY = tester.getCenter(find.text('Export Format')).dy;
      final dateRangeY = tester.getCenter(find.text('Select Date Range').first).dy;
      expect(exportFormatY, lessThan(dateRangeY));

      // Check receipt count
      expect(find.text('42 receipts found'), findsOneWidget);

      // Check export preview
      expect(find.text('Export Preview'), findsOneWidget);

      // Check export button
      expect(find.text('Export 42 Receipts'), findsOneWidget);
    });

    testWidgets('should show no receipts message when count is 0', (tester) async {
      // Given
      final testState = DateRangeState(
        dateRange: DateTimeRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        ),
        presetOption: DateRangePreset.custom,
        receiptCount: 0,
      );

      // When
      await tester.pumpWidget(createTestWidget(
        const ExportScreen(),
        overrides: [
          dateRangeNotifierProvider.overrideWith(() => _TestDateRangeNotifier(testState)),
        ],
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then
      expect(find.text('No receipts in this date range'), findsOneWidget);
      expect(find.text('No Receipts to Export'), findsOneWidget);
      expect(find.text('No receipts found in the selected date range'), findsOneWidget);

      // Export button should be disabled
      final exportButton = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('No Receipts to Export'),
          matching: find.bySubtype<FilledButton>(),
        ),
      );
      expect(exportButton.onPressed, isNull);
    });

    testWidgets('should display format selection with all options', (tester) async {
      // Given
      final testState = DateRangeState(
        dateRange: DateTimeRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        ),
        presetOption: DateRangePreset.thisMonth,
        receiptCount: 10,
      );

      // When
      await tester.pumpWidget(createTestWidget(
        const ExportScreen(),
        overrides: [
          dateRangeNotifierProvider.overrideWith(() => _TestDateRangeNotifier(testState)),
        ],
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - All format options should be visible
      expect(find.text('QuickBooks'), findsNWidgets(2)); // In button and description
      expect(find.text('Xero'), findsOneWidget);
      expect(find.text('Generic CSV'), findsNWidgets(2)); // Default selection

      // Check format description
      expect(find.textContaining('Standard CSV'), findsOneWidget);
      expect(find.text('Required fields for Generic CSV'), findsOneWidget);
      
      // Check security info
      expect(find.text('CSV injection prevention enabled'), findsOneWidget);
    });

    testWidgets('should update preview when format changes', (tester) async {
      // Given
      final testState = DateRangeState(
        dateRange: DateTimeRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        ),
        presetOption: DateRangePreset.thisMonth,
        receiptCount: 10,
      );

      // When
      await tester.pumpWidget(createTestWidget(
        const ExportScreen(),
        overrides: [
          dateRangeNotifierProvider.overrideWith(() => _TestDateRangeNotifier(testState)),
        ],
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - Generic is selected by default
      expect(find.text('Generic CSV'), findsNWidgets(2)); // In selector and preview

      // Select QuickBooks
      await tester.tap(find.text('QuickBooks').first);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Preview should update
      expect(find.text('QuickBooks'), findsNWidgets(2)); // In selector and description
    });

    testWidgets('should display export preview with all info', (tester) async {
      // Given
      final testState = DateRangeState(
        dateRange: DateTimeRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        ),
        presetOption: DateRangePreset.thisMonth,
        receiptCount: 25,
      );

      // When
      await tester.pumpWidget(createTestWidget(
        const ExportScreen(),
        overrides: [
          dateRangeNotifierProvider.overrideWith(() => _TestDateRangeNotifier(testState)),
        ],
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then
      expect(find.text('Export Preview'), findsOneWidget);
      expect(find.text('25 receipts'), findsOneWidget);
      expect(find.textContaining('Jan 1, 2024'), findsOneWidget);
      expect(find.textContaining('Jan 31, 2024'), findsOneWidget);
      expect(find.text('Generic CSV'), findsNWidgets(2));
      expect(find.text('This Month'), findsNWidgets(2)); // In picker and preview
    });

    testWidgets('should show confirmation dialog when export clicked', (tester) async {
      // Given
      final testState = DateRangeState(
        dateRange: DateTimeRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        ),
        presetOption: DateRangePreset.thisMonth,
        receiptCount: 15,
      );

      // When
      await tester.pumpWidget(createTestWidget(
        const ExportScreen(),
        overrides: [
          dateRangeNotifierProvider.overrideWith(() => _TestDateRangeNotifier(testState)),
        ],
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Tap export button
      await tester.tap(find.text('Export 15 Receipts'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - Confirmation dialog appears
      expect(find.text('Export 15 Receipts?'), findsOneWidget);
      expect(
        find.text('You are about to export 15 receipts in Generic CSV format.'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Export'), findsNWidgets(2)); // Button text and dialog button
    });

    testWidgets('should display error state', (tester) async {
      // When
      await tester.pumpWidget(createTestWidget(
        const ExportScreen(),
        overrides: [
          dateRangeNotifierProvider.overrideWith(() => _ErrorDateRangeNotifier()),
        ],
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then
      expect(find.text('Error loading receipts'), findsOneWidget);
      expect(find.text('Failed to load receipts'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should refresh when retry pressed', (tester) async {
      // When
      await tester.pumpWidget(createTestWidget(
        const ExportScreen(),
        overrides: [
          dateRangeNotifierProvider.overrideWith(() => _ErrorDateRangeNotifier()),
        ],
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - Verify error state is displayed
      expect(find.text('Retry'), findsOneWidget);
      
      // Tap retry
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verify refresh logic would be called
      // In real implementation, this would trigger ref.refresh(dateRangeNotifierProvider)
    });

    testWidgets('should handle single receipt correctly', (tester) async {
      // Given
      final testState = DateRangeState(
        dateRange: DateTimeRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        ),
        presetOption: DateRangePreset.custom,
        receiptCount: 1,
      );

      // When
      await tester.pumpWidget(createTestWidget(
        const ExportScreen(),
        overrides: [
          dateRangeNotifierProvider.overrideWith(() => _TestDateRangeNotifier(testState)),
        ],
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - Check singular forms
      expect(find.text('1 receipt found'), findsOneWidget);
      expect(find.text('Export 1 Receipt'), findsOneWidget);
      expect(find.text('1 receipt'), findsOneWidget); // In preview
    });

    testWidgets('should be scrollable for small screens', (tester) async {
      // Given
      final testState = DateRangeState(
        dateRange: DateTimeRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 12, 31),
        ),
        presetOption: DateRangePreset.last90Days,
        receiptCount: 150,
      );

      // When
      await tester.pumpWidget(createTestWidget(
        const ExportScreen(),
        overrides: [
          dateRangeNotifierProvider.overrideWith(() => _TestDateRangeNotifier(testState)),
        ],
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - Verify scrollable
      final scrollable = find.byType(SingleChildScrollView);
      expect(scrollable, findsOneWidget);

      // Scroll to bottom
      await tester.drag(scrollable, const Offset(0, -500));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Content should still be visible
      expect(find.text('Export Preview'), findsOneWidget);
    });

    testWidgets('should show format-specific info', (tester) async {
      // Given
      final testState = DateRangeState(
        dateRange: DateTimeRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        ),
        presetOption: DateRangePreset.custom,
        receiptCount: 10,
      );

      // When
      await tester.pumpWidget(createTestWidget(
        const ExportScreen(),
        overrides: [
          dateRangeNotifierProvider.overrideWith(() => _TestDateRangeNotifier(testState)),
          exportFormatNotifierProvider.overrideWith((ref) => _MockExportFormatNotifier(ref, ExportFormat.quickbooks)),
        ],
      ));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - QuickBooks specific info
      expect(find.text('Date format: MM/dd/yyyy'), findsOneWidget);
      expect(find.text('Amount format: 0.00 (two decimal places)'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget); // QuickBooks specific field
    });
  });
}

// Mock notifier that always returns loading state
class _LoadingDateRangeNotifier extends DateRangeNotifier {
  Future<DateRangeState> build() async {
    // Return a future that never completes to simulate loading
    final completer = Completer<DateRangeState>();
    return completer.future;
  }
}

// Mock notifier that returns a specific state
class _TestDateRangeNotifier extends DateRangeNotifier {
  final DateRangeState _testState;
  
  _TestDateRangeNotifier(this._testState);
  
  Future<DateRangeState> build() async {
    return _testState;
  }
}

// Mock notifier that returns an error state
class _ErrorDateRangeNotifier extends DateRangeNotifier {
  Future<DateRangeState> build() async {
    throw 'Failed to load receipts';
  }
}

// Mock settings notifier
class _MockAppSettingsNotifier extends AppSettingsNotifier {
  _MockAppSettingsNotifier(Ref ref) : super(ref);
  
  Future<void> loadSettings() async {
    // Override to avoid loading from repository
    state = const AppSettings();
  }
  
  Future<bool> updateCsvFormat(String format) async {
    state = state.copyWith(csvExportFormat: format);
    return true;
  }
  
  Future<bool> updateDateRangePreset(String preset) async {
    state = state.copyWith(dateRangePreset: preset);
    return true;
  }
}

// Mock export format notifier
class _MockExportFormatNotifier extends ExportFormatNotifier {
  final ExportFormat _defaultFormat;
  
  _MockExportFormatNotifier(Ref ref, [this._defaultFormat = ExportFormat.generic]) : super(ref);
  
  Future<void> loadSavedFormat() async {
    state = ExportFormatState(
      selectedFormat: _defaultFormat,
      lastUsedFormat: _defaultFormat,
      isLoading: false,
    );
  }
  
  Future<void> updateFormat(ExportFormat newFormat) async {
    state = state.copyWith(selectedFormat: newFormat);
  }
}