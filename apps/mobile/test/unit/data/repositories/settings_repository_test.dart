import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:receipt_organizer/data/repositories/settings_repository.dart';
import 'package:receipt_organizer/data/models/app_settings.dart';
import '../../../test_config/test_setup.dart';

void main() {
  testWithSetup('SettingsRepository', () {
    late SettingsRepository repository;
    late SharedPreferences prefs;

    setUp(() async {
      // Test setup already initializes SharedPreferences mock
      prefs = await SharedPreferences.getInstance();
      repository = SettingsRepository(prefs);
    });

    group('CSV Export Format Persistence', () {
      test('should save and load export format setting', () async {
        // Given
        const settings = AppSettings(csvExportFormat: 'quickbooks');

        // When
        final saved = await repository.saveSettings(settings);
        final loaded = await repository.loadSettings();

        // Then
        expect(saved, isTrue);
        expect(loaded.csvExportFormat, 'quickbooks');
      });

      test('should update export format using updateSetting', () async {
        // Given - Save initial settings
        const initialSettings = AppSettings(csvExportFormat: 'generic');
        await repository.saveSettings(initialSettings);

        // When - Update format
        final updated = await repository.updateSetting('csvExportFormat', 'xero');
        final loaded = await repository.loadSettings();

        // Then
        expect(updated, isTrue);
        expect(loaded.csvExportFormat, 'xero');
        // Other settings should remain unchanged
        expect(loaded.merchantNormalization, initialSettings.merchantNormalization);
        expect(loaded.enableAudioFeedback, initialSettings.enableAudioFeedback);
      });

      test('should handle migration from null export format to default', () async {
        // Given - Simulate old settings without csvExportFormat
        await prefs.setString('app_settings', '''
        {
          "merchantNormalization": true,
          "enableAudioFeedback": true,
          "enableBatchCapture": false,
          "maxRetryAttempts": 3,
          "dateFormat": "MM/dd/yyyy",
          "dateRangePreset": "last30Days"
        }
        ''');

        // When
        final loaded = await repository.loadSettings();

        // Then - Should default to 'generic'
        expect(loaded.csvExportFormat, 'generic');
        expect(loaded.merchantNormalization, isTrue);
      });

      test('should persist all export format options', () async {
        // Test each format option
        for (final format in ['quickbooks', 'xero', 'generic']) {
          // When
          final updated = await repository.updateSetting('csvExportFormat', format);
          final loaded = await repository.loadSettings();

          // Then
          expect(updated, isTrue);
          expect(loaded.csvExportFormat, format);
        }
      });

      test('should handle corrupt settings gracefully', () async {
        // Given - Corrupt JSON
        await prefs.setString('app_settings', '{invalid json}');

        // When
        final loaded = await repository.loadSettings();

        // Then - Should return default settings
        expect(loaded.csvExportFormat, 'generic');
        expect(loaded, equals(const AppSettings()));
      });

      test('should maintain export format across app restarts', () async {
        // Given
        await repository.updateSetting('csvExportFormat', 'quickbooks');

        // When - Simulate app restart with new repository instance
        final newRepository = SettingsRepository(prefs);
        final loaded = await newRepository.loadSettings();

        // Then
        expect(loaded.csvExportFormat, 'quickbooks');
      });
    });

    group('General Settings Operations', () {
      test('should save and load all settings', () async {
        // Given
        const settings = AppSettings(
          merchantNormalization: false,
          enableAudioFeedback: false,
          enableBatchCapture: true,
          maxRetryAttempts: 5,
          csvExportFormat: 'xero',
          dateFormat: 'dd/MM/yyyy',
          dateRangePreset: 'thisMonth',
        );

        // When
        await repository.saveSettings(settings);
        final loaded = await repository.loadSettings();

        // Then
        expect(loaded, equals(settings));
        expect(loaded.merchantNormalization, isFalse);
        expect(loaded.enableAudioFeedback, isFalse);
        expect(loaded.enableBatchCapture, isTrue);
        expect(loaded.maxRetryAttempts, 5);
        expect(loaded.csvExportFormat, 'xero');
        expect(loaded.dateFormat, 'dd/MM/yyyy');
        expect(loaded.dateRangePreset, 'thisMonth');
      });

      test('should return default settings when none exist', () async {
        // When
        final loaded = await repository.loadSettings();

        // Then
        expect(loaded, equals(const AppSettings()));
        expect(loaded.csvExportFormat, 'generic'); // Default value
      });

      test('should clear settings', () async {
        // Given
        const settings = AppSettings(csvExportFormat: 'quickbooks');
        await repository.saveSettings(settings);

        // When
        final cleared = await repository.clearSettings();
        final loaded = await repository.loadSettings();

        // Then
        expect(cleared, isTrue);
        expect(loaded, equals(const AppSettings()));
        expect(loaded.csvExportFormat, 'generic');
      });

      test('should handle save failure gracefully', () async {
        // Given - Create repository with mock that throws
        final mockPrefs = _MockSharedPreferencesThrows();
        final failingRepository = SettingsRepository(mockPrefs);
        const settings = AppSettings();

        // When
        final saved = await failingRepository.saveSettings(settings);

        // Then
        expect(saved, isFalse);
      });

      test('should return false for unknown setting key', () async {
        // When
        final updated = await repository.updateSetting('unknownKey', 'value');

        // Then
        expect(updated, isFalse);
      });
    });

    group('File System Permissions', () {
      test('should not require file system permissions for settings', () async {
        // Settings are stored in SharedPreferences, not file system
        // This test documents that file system permissions are not needed

        // Given
        const settings = AppSettings(csvExportFormat: 'quickbooks');

        // When
        final saved = await repository.saveSettings(settings);
        final loaded = await repository.loadSettings();

        // Then
        expect(saved, isTrue);
        expect(loaded.csvExportFormat, 'quickbooks');
        // No file system operations required
      });
    });
  });
}

// Mock for testing error handling
class _MockSharedPreferencesThrows implements SharedPreferences {
  @override
  Future<bool> setString(String key, String value) async {
    throw Exception('Mock save failure');
  }

  @override
  String? getString(String key) => null;

  @override
  Future<bool> remove(String key) async => true;

  // Other required methods (not used in tests)
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}