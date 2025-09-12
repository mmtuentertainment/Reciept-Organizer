import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:receipt_organizer/domain/services/csv_export_service.dart';
import 'package:receipt_organizer/features/export/presentation/providers/export_format_provider.dart';
import 'package:receipt_organizer/features/settings/providers/settings_provider.dart';
import 'package:receipt_organizer/data/models/app_settings.dart';

// Mock classes
class MockAppSettingsNotifier extends StateNotifier<AppSettings>
    with Mock
    implements AppSettingsNotifier {
  MockAppSettingsNotifier() : super(AppSettings());
}

void main() {
  group('ExportFormatProvider', () {
    late ProviderContainer container;
    late MockAppSettingsNotifier mockSettingsNotifier;

    setUp(() {
      mockSettingsNotifier = MockAppSettingsNotifier();
      
      container = ProviderContainer(
        overrides: [
          appSettingsProvider.overrideWith((ref) => mockSettingsNotifier),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with quickbooks format from default settings', () {
      // Given - Default settings (which defaults to quickbooks)
      mockSettingsNotifier.state = AppSettings();

      // When
      final state = container.read(exportFormatNotifierProvider);

      // Then
      expect(state.selectedFormat, ExportFormat.quickbooks);
      expect(state.lastUsedFormat, ExportFormat.quickbooks);
      expect(state.isLoading, isFalse);
      expect(state.hasChanges, isFalse);
    });

    test('should load saved format from settings', () async {
      // Given - Settings with saved QuickBooks format
      mockSettingsNotifier.state = AppSettings(
        csvExportFormat: ExportFormat.quickbooks.name,
      );

      // When
      container = ProviderContainer(
        overrides: [
          appSettingsProvider.overrideWith((ref) => mockSettingsNotifier),
        ],
      );
      
      // Allow time for async initialization
      await Future.delayed(const Duration(milliseconds: 100));
      
      final state = container.read(exportFormatNotifierProvider);

      // Then
      expect(state.selectedFormat, ExportFormat.quickbooks);
      expect(state.lastUsedFormat, ExportFormat.quickbooks);
    });

    test('should update format and persist to settings', () async {
      // Given
      mockSettingsNotifier.state = AppSettings();
      final notifier = container.read(exportFormatNotifierProvider.notifier);

      // When
      when(() => mockSettingsNotifier.updateCsvFormat(any()))
          .thenAnswer((_) async => true);
      
      await notifier.updateFormat(ExportFormat.xero);

      // Then
      final state = container.read(exportFormatNotifierProvider);
      expect(state.selectedFormat, ExportFormat.xero);
      expect(state.lastUsedFormat, ExportFormat.xero);
      expect(state.hasChanges, isFalse);
    });

    test('should not update if same format selected', () async {
      // Given
      mockSettingsNotifier.state = AppSettings(
        csvExportFormat: ExportFormat.quickbooks.name,
      );
      
      container = ProviderContainer(
        overrides: [
          appSettingsProvider.overrideWith((ref) => mockSettingsNotifier),
        ],
      );
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      final notifier = container.read(exportFormatNotifierProvider.notifier);
      final initialState = container.read(exportFormatNotifierProvider);

      // When
      await notifier.updateFormat(ExportFormat.quickbooks);

      // Then
      final newState = container.read(exportFormatNotifierProvider);
      expect(newState, equals(initialState));
    });

    test('should rollback on settings update error', () async {
      // Given
      mockSettingsNotifier.state = AppSettings(
        csvExportFormat: ExportFormat.generic.name,
      );
      
      container = ProviderContainer(
        overrides: [
          appSettingsProvider.overrideWith((ref) => mockSettingsNotifier),
        ],
      );
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      final notifier = container.read(exportFormatNotifierProvider.notifier);

      // When - Settings update fails
      when(() => mockSettingsNotifier.updateCsvFormat(any()))
          .thenThrow(Exception('Settings update failed'));

      // Then
      await expectLater(
        notifier.updateFormat(ExportFormat.xero),
        throwsException,
      );

      // Verify rollback
      final state = container.read(exportFormatNotifierProvider);
      expect(state.selectedFormat, ExportFormat.generic);
      expect(state.hasChanges, isFalse);
    });

    test('should reset to last used format', () async {
      // Given
      mockSettingsNotifier.state = AppSettings(
        csvExportFormat: ExportFormat.quickbooks.name,
      );
      
      container = ProviderContainer(
        overrides: [
          appSettingsProvider.overrideWith((ref) => mockSettingsNotifier),
        ],
      );
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      final notifier = container.read(exportFormatNotifierProvider.notifier);

      // When - Change format but don't save
      notifier.state = notifier.state.copyWith(
        selectedFormat: ExportFormat.xero,
        hasChanges: true,
      );

      // Then - Reset
      notifier.resetToLastUsed();

      final state = container.read(exportFormatNotifierProvider);
      expect(state.selectedFormat, ExportFormat.quickbooks);
      expect(state.hasChanges, isFalse);
    });

    test('should handle invalid saved format gracefully', () async {
      // Given - Invalid format name in settings
      mockSettingsNotifier.state = AppSettings(
        csvExportFormat: 'invalid_format',
      );

      // When
      container = ProviderContainer(
        overrides: [
          appSettingsProvider.overrideWith((ref) => mockSettingsNotifier),
        ],
      );
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      final state = container.read(exportFormatNotifierProvider);

      // Then - Should fall back to generic
      expect(state.selectedFormat, ExportFormat.generic);
    });

    group('selectedExportFormatProvider', () {
      test('should provide current selected format', () {
        // Given
        mockSettingsNotifier.state = AppSettings(
          csvExportFormat: ExportFormat.xero.name,
        );
        
        container = ProviderContainer(
          overrides: [
            appSettingsProvider.overrideWith((ref) => mockSettingsNotifier),
          ],
        );

        // When
        final format = container.read(selectedExportFormatProvider);

        // Then
        expect(format, ExportFormat.xero);
      });

      test('should update when format changes', () async {
        // Given
        mockSettingsNotifier.state = AppSettings();
        final notifier = container.read(exportFormatNotifierProvider.notifier);
        
        // Listen to format changes
        final formats = <ExportFormat>[];
        container.listen(
          selectedExportFormatProvider,
          (previous, next) => formats.add(next),
        );

        // When
        when(() => mockSettingsNotifier.updateCsvFormat(any()))
            .thenAnswer((_) async => true);
        
        await notifier.updateFormat(ExportFormat.quickbooks);
        await notifier.updateFormat(ExportFormat.xero);

        // Then
        expect(formats, contains(ExportFormat.quickbooks));
        expect(formats, contains(ExportFormat.xero));
      });
    });

    group('hasUnsavedFormatChangesProvider', () {
      test('should indicate unsaved changes', () {
        // Given
        final notifier = container.read(exportFormatNotifierProvider.notifier);

        // When - Make unsaved change
        notifier.state = notifier.state.copyWith(
          selectedFormat: ExportFormat.xero,
          hasChanges: true,
        );

        // Then
        final hasChanges = container.read(hasUnsavedFormatChangesProvider);
        expect(hasChanges, isTrue);
      });
    });

    group('Format Display Names', () {
      test('should provide correct display names', () {
        // Given
        final notifier = container.read(exportFormatNotifierProvider.notifier);

        // Then
        expect(notifier.getFormatDisplayName(ExportFormat.quickbooks), 'QuickBooks');
        expect(notifier.getFormatDisplayName(ExportFormat.xero), 'Xero');
        expect(notifier.getFormatDisplayName(ExportFormat.generic), 'Generic CSV');
      });
    });
  });
}