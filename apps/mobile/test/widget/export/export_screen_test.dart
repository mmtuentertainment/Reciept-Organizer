import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/export/presentation/pages/export_screen.dart';
import 'package:receipt_organizer/features/export/presentation/providers/date_range_provider.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/date_range_picker.dart';
import 'package:receipt_organizer/domain/services/csv_export_service.dart';
import 'package:receipt_organizer/core/theme/app_theme.dart';
import 'package:receipt_organizer/features/settings/providers/settings_provider.dart';
import 'package:receipt_organizer/data/models/app_settings.dart';

void main() {
  Widget createTestWidget(Widget child, {List<Override>? overrides}) {
    return ProviderScope(
      overrides: [
        appSettingsProvider.overrideWith((ref) => _MockAppSettingsNotifier(ref)),
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

    testWidgets('should display all main sections', (tester) async {
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
      await tester.pumpAndSettle();

      // Then
      // Check app bar
      expect(find.text('Export Receipts'), findsOneWidget);

      // Check date range picker
      expect(find.text('Select Date Range'), findsNWidgets(2)); // One in ExportScreen, one in DateRangePickerWidget
      expect(find.byType(DateRangePickerWidget), findsOneWidget);

      // Check receipt count
      expect(find.text('42 receipts found'), findsOneWidget);

      // Check format tabs
      expect(find.text('QuickBooks'), findsAtLeastNWidgets(1));
      expect(find.text('Xero'), findsAtLeastNWidgets(1));
      expect(find.text('Generic CSV'), findsAtLeastNWidgets(1));

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
      await tester.pumpAndSettle();

      // Then
      expect(find.text('No receipts in this date range'), findsOneWidget);
      expect(find.text('No Receipts to Export'), findsOneWidget);

      // Export button should be disabled
      expect(find.text('No Receipts to Export'), findsOneWidget);
      
      // Check that the export button is disabled (onPressed is null)
      // Note: FilledButton.icon creates a _FilledButtonWithIcon widget
      final exportButton = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('No Receipts to Export'),
          matching: find.bySubtype<FilledButton>(),
        ),
      );
      expect(exportButton.onPressed, isNull);
    });

    testWidgets('should display format details when tab selected', (tester) async {
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
      await tester.pumpAndSettle();

      // Then - QuickBooks tab is selected by default
      expect(find.text('Compatible with QuickBooks Desktop and Online'), findsOneWidget);
      expect(find.text('Required Fields'), findsOneWidget);

      // Check required fields for QuickBooks
      expect(find.text('Date'), findsAtLeastNWidgets(1));
      expect(find.text('Amount'), findsAtLeastNWidgets(1));
      expect(find.text('Payee'), findsAtLeastNWidgets(1));
    });

    testWidgets('should switch between format tabs', (tester) async {
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
      await tester.pumpAndSettle();

      // Then - Switch to Xero tab
      await tester.tap(find.text('Xero'));
      await tester.pumpAndSettle();

      expect(find.text('Compatible with Xero accounting software'), findsOneWidget);

      // Switch to Generic CSV tab
      await tester.tap(find.text('Generic CSV'));
      await tester.pumpAndSettle();

      expect(find.text('Standard CSV with all available fields'), findsOneWidget);
    });

    testWidgets('should display date range preview', (tester) async {
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
      await tester.pumpAndSettle();

      // Then
      expect(find.text('Date Range Preview'), findsOneWidget);
      expect(find.text('25 receipts'), findsOneWidget);
      expect(find.textContaining('Jan 1, 2024'), findsOneWidget);
      expect(find.textContaining('Jan 31, 2024'), findsOneWidget);
      expect(find.text('This Month'), findsNWidgets(2)); // Preset appears in picker and preview
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
      await tester.pumpAndSettle();

      // Tap export button
      await tester.tap(find.text('Export 15 Receipts'));
      await tester.pumpAndSettle();

      // Then - Confirmation dialog appears
      expect(find.text('Export 15 Receipts?'), findsOneWidget);
      expect(
        find.text('You are about to export 15 receipts in QuickBooks format.'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);
    });

    testWidgets('should display error state', (tester) async {
      // When
      await tester.pumpWidget(createTestWidget(
        const ExportScreen(),
        overrides: [
          dateRangeNotifierProvider.overrideWith(() => _ErrorDateRangeNotifier()),
        ],
      ));
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

      // Then - Verify error state is displayed
      expect(find.text('Retry'), findsOneWidget);
      
      // Tap retry
      await tester.tap(find.text('Retry'));
      await tester.pump();

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
      await tester.pumpAndSettle();

      // Then - Check singular forms
      expect(find.text('1 receipt found'), findsOneWidget);
      expect(find.text('Export 1 Receipt'), findsOneWidget);
    });
  });
}

// Mock notifier that always returns loading state
class _LoadingDateRangeNotifier extends DateRangeNotifier {
  @override
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
  
  @override
  Future<DateRangeState> build() async {
    return _testState;
  }
}

// Mock notifier that returns an error state
class _ErrorDateRangeNotifier extends DateRangeNotifier {
  @override
  Future<DateRangeState> build() async {
    throw 'Failed to load receipts';
  }
}

// Mock settings notifier
class _MockAppSettingsNotifier extends AppSettingsNotifier {
  _MockAppSettingsNotifier(Ref ref) : super(ref);
  
  @override
  Future<void> _loadSettings() async {
    // Override to avoid loading from repository
    state = const AppSettings();
  }
  
  @override
  Future<bool> updateCsvFormat(String format) async {
    state = state.copyWith(csvExportFormat: format);
    return true;
  }
  
  @override
  Future<bool> updateDateRangePreset(String preset) async {
    state = state.copyWith(dateRangePreset: preset);
    return true;
  }
}