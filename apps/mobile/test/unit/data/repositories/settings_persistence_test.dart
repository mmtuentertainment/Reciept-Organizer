import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:receipt_organizer/data/repositories/settings_repository.dart';
import 'package:receipt_organizer/data/models/app_settings.dart';
import '../../../test_config/test_setup.dart';

void main() {
  testWithSetup('Settings Persistence for Export Features', () {
    late SettingsRepository repository;
    
    setUp(() async {
      // Test setup already initializes SharedPreferences mock
      // Just get the instance and create repository
      final prefs = await SharedPreferences.getInstance();
      repository = SettingsRepository(prefs);
    });

    test('should save and load date range preset preference', () async {
      // Given
      const testPreset = 'thisMonth';
      final settings = const AppSettings().copyWith(
        dateRangePreset: testPreset,
      );

      // When - Save settings
      final saveSuccess = await repository.saveSettings(settings);
      expect(saveSuccess, isTrue);

      // Then - Load and verify
      final loadedSettings = await repository.loadSettings();
      expect(loadedSettings.dateRangePreset, equals(testPreset));
    });

    test('should save and load CSV export format preference', () async {
      // Given
      const testFormat = 'xero';
      final settings = const AppSettings().copyWith(
        csvExportFormat: testFormat,
      );

      // When
      await repository.saveSettings(settings);

      // Then
      final loadedSettings = await repository.loadSettings();
      expect(loadedSettings.csvExportFormat, equals(testFormat));
    });

    test('should update date range preset independently', () async {
      // Given - Initial settings with different values
      final initialSettings = const AppSettings().copyWith(
        csvExportFormat: 'generic',
        merchantNormalization: false,
      );
      await repository.saveSettings(initialSettings);

      // When - Update only date range preset
      final success = await repository.updateSetting('dateRangePreset', 'last90Days');

      // Then
      expect(success, isTrue);
      final loadedSettings = await repository.loadSettings();
      expect(loadedSettings.dateRangePreset, equals('last90Days'));
      // Other settings should remain unchanged
      expect(loadedSettings.csvExportFormat, equals('generic'));
      expect(loadedSettings.merchantNormalization, isFalse);
    });

    test('should handle all date range preset values', () async {
      // Test each preset value
      final presets = ['thisMonth', 'lastMonth', 'last30Days', 'last90Days', 'custom'];

      for (final preset in presets) {
        // When
        await repository.updateSetting('dateRangePreset', preset);

        // Then
        final loadedSettings = await repository.loadSettings();
        expect(loadedSettings.dateRangePreset, equals(preset));
      }
    });

    test('should handle all export format values', () async {
      // Test each format value
      final formats = ['quickbooks', 'xero', 'generic'];

      for (final format in formats) {
        // When
        await repository.updateSetting('csvExportFormat', format);

        // Then
        final loadedSettings = await repository.loadSettings();
        expect(loadedSettings.csvExportFormat, equals(format));
      }
    });

    test('should use default values when no preferences saved', () async {
      // Given - Empty preferences
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final emptyRepo = SettingsRepository(prefs);

      // When
      final settings = await emptyRepo.loadSettings();

      // Then - Should use defaults
      expect(settings.dateRangePreset, equals('last30Days'));
      expect(settings.csvExportFormat, equals('quickbooks'));
    });

    test('should persist settings across repository instances', () async {
      // Given
      const testPreset = 'lastMonth';
      const testFormat = 'xero';
      
      // Save with first repository
      await repository.updateSetting('dateRangePreset', testPreset);
      await repository.updateSetting('csvExportFormat', testFormat);

      // When - Create new repository instance
      final prefs = await SharedPreferences.getInstance();
      final newRepository = SettingsRepository(prefs);
      final loadedSettings = await newRepository.loadSettings();

      // Then
      expect(loadedSettings.dateRangePreset, equals(testPreset));
      expect(loadedSettings.csvExportFormat, equals(testFormat));
    });

    test('should handle corrupted settings gracefully', () async {
      // Given - Corrupt the saved settings
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_settings', 'invalid json');

      // When
      final settings = await repository.loadSettings();

      // Then - Should return defaults
      expect(settings.dateRangePreset, equals('last30Days'));
      expect(settings.csvExportFormat, equals('quickbooks'));
    });

    test('should serialize and deserialize settings correctly', () async {
      // Given
      final settings = const AppSettings().copyWith(
        dateRangePreset: 'custom',
        csvExportFormat: 'generic',
        merchantNormalization: false,
        enableBatchCapture: true,
        maxRetryAttempts: 5,
      );

      // When - Save and load
      await repository.saveSettings(settings);
      final loadedSettings = await repository.loadSettings();

      // Then - All fields should match
      expect(loadedSettings.dateRangePreset, equals(settings.dateRangePreset));
      expect(loadedSettings.csvExportFormat, equals(settings.csvExportFormat));
      expect(loadedSettings.merchantNormalization, equals(settings.merchantNormalization));
      expect(loadedSettings.enableBatchCapture, equals(settings.enableBatchCapture));
      expect(loadedSettings.maxRetryAttempts, equals(settings.maxRetryAttempts));
    });

    test('should return false when updating non-existent setting', () async {
      // When
      final success = await repository.updateSetting('nonExistentSetting', 'value');

      // Then
      expect(success, isFalse);
    });

    test('should clear all settings when reset', () async {
      // Given - Save some settings
      final settings = const AppSettings().copyWith(
        dateRangePreset: 'thisMonth',
        csvExportFormat: 'xero',
      );
      await repository.saveSettings(settings);

      // When - Clear settings
      final success = await repository.clearSettings();

      // Then
      expect(success, isTrue);
      final loadedSettings = await repository.loadSettings();
      // Should return defaults
      expect(loadedSettings.dateRangePreset, equals('last30Days'));
      expect(loadedSettings.csvExportFormat, equals('quickbooks'));
    });
  });
}