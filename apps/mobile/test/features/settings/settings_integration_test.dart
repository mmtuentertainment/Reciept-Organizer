import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/data/models/app_settings.dart';
import 'package:receipt_organizer/data/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../test_config/test_setup.dart';

void main() {
  testWithSetup('Settings Integration Test', () {
    late SettingsRepository repository;

    setUp(() async {
      // Test setup already initializes SharedPreferences mock
      final prefs = await SharedPreferences.getInstance();
      repository = SettingsRepository(prefs);
    });

    test('should load default settings when no saved settings exist', () async {
      // Act
      final settings = await repository.loadSettings();

      // Assert
      expect(settings.merchantNormalization, isTrue);
      expect(settings.enableAudioFeedback, isTrue);
      expect(settings.enableBatchCapture, isFalse);
      expect(settings.maxRetryAttempts, equals(3));
      expect(settings.csvExportFormat, equals('quickbooks'));
      expect(settings.dateFormat, equals('MM/dd/yyyy'));
    });

    test('should save and load settings correctly', () async {
      // Arrange
      const modifiedSettings = AppSettings(
        merchantNormalization: false,
        enableAudioFeedback: false,
        enableBatchCapture: true,
        maxRetryAttempts: 5,
        csvExportFormat: 'xero',
        dateFormat: 'yyyy-MM-dd',
      );

      // Act
      final saved = await repository.saveSettings(modifiedSettings);
      final loaded = await repository.loadSettings();

      // Assert
      expect(saved, isTrue);
      expect(loaded.merchantNormalization, isFalse);
      expect(loaded.enableAudioFeedback, isFalse);
      expect(loaded.enableBatchCapture, isTrue);
      expect(loaded.maxRetryAttempts, equals(5));
      expect(loaded.csvExportFormat, equals('xero'));
      expect(loaded.dateFormat, equals('yyyy-MM-dd'));
    });

    test('should update individual settings correctly', () async {
      // Arrange - Save initial settings
      const initialSettings = AppSettings();
      await repository.saveSettings(initialSettings);

      // Act - Update merchant normalization
      await repository.updateSetting('merchantNormalization', false);
      final afterFirstUpdate = await repository.loadSettings();

      // Assert
      expect(afterFirstUpdate.merchantNormalization, isFalse);
      expect(afterFirstUpdate.enableAudioFeedback, isTrue); // Unchanged

      // Act - Update audio feedback
      await repository.updateSetting('enableAudioFeedback', false);
      final afterSecondUpdate = await repository.loadSettings();

      // Assert
      expect(afterSecondUpdate.merchantNormalization, isFalse); // Still false
      expect(afterSecondUpdate.enableAudioFeedback, isFalse);
    });

    test('should clear settings and return to defaults', () async {
      // Arrange
      const customSettings = AppSettings(
        merchantNormalization: false,
        maxRetryAttempts: 5,
      );
      await repository.saveSettings(customSettings);

      // Act
      final cleared = await repository.clearSettings();
      final settings = await repository.loadSettings();

      // Assert
      expect(cleared, isTrue);
      expect(settings.merchantNormalization, isTrue); // Back to default
      expect(settings.maxRetryAttempts, equals(3)); // Back to default
    });

    test('should handle invalid setting keys gracefully', () async {
      // Act
      final result = await repository.updateSetting('invalidKey', 'value');

      // Assert
      expect(result, isFalse);
    });

    test('should preserve settings across multiple operations', () async {
      // Act - Perform multiple updates
      await repository.updateSetting('merchantNormalization', false);
      await repository.updateSetting('maxRetryAttempts', 5);
      await repository.updateSetting('csvExportFormat', 'generic');

      // Load and verify
      final settings = await repository.loadSettings();

      // Assert
      expect(settings.merchantNormalization, isFalse);
      expect(settings.maxRetryAttempts, equals(5));
      expect(settings.csvExportFormat, equals('generic'));
      expect(settings.enableAudioFeedback, isTrue); // Unchanged
      expect(settings.dateFormat, equals('MM/dd/yyyy')); // Unchanged
    });
  });

  testWithSetup('AppSettings Model', () {
    test('should create with default values', () {
      // Act
      const settings = AppSettings();

      // Assert
      expect(settings.merchantNormalization, isTrue);
      expect(settings.enableAudioFeedback, isTrue);
      expect(settings.enableBatchCapture, isFalse);
      expect(settings.maxRetryAttempts, equals(3));
      expect(settings.csvExportFormat, equals('quickbooks'));
      expect(settings.dateFormat, equals('MM/dd/yyyy'));
    });

    test('should copy with new values correctly', () {
      // Arrange
      const original = AppSettings();

      // Act
      final modified = original.copyWith(
        merchantNormalization: false,
        maxRetryAttempts: 5,
      );

      // Assert
      expect(modified.merchantNormalization, isFalse);
      expect(modified.maxRetryAttempts, equals(5));
      expect(modified.enableAudioFeedback, isTrue); // Unchanged
    });

    test('should serialize and deserialize correctly', () {
      // Arrange
      const settings = AppSettings(
        merchantNormalization: false,
        enableAudioFeedback: false,
        enableBatchCapture: true,
        maxRetryAttempts: 4,
        csvExportFormat: 'xero',
        dateFormat: 'dd/MM/yyyy',
      );

      // Act
      final json = settings.toJson();
      final deserialized = AppSettings.fromJson(json);

      // Assert
      expect(deserialized, equals(settings));
      expect(deserialized.merchantNormalization, isFalse);
      expect(deserialized.enableAudioFeedback, isFalse);
      expect(deserialized.enableBatchCapture, isTrue);
      expect(deserialized.maxRetryAttempts, equals(4));
      expect(deserialized.csvExportFormat, equals('xero'));
      expect(deserialized.dateFormat, equals('dd/MM/yyyy'));
    });

    test('should handle missing json fields with defaults', () {
      // Arrange
      final partialJson = {
        'merchantNormalization': false,
        // Other fields missing
      };

      // Act
      final settings = AppSettings.fromJson(partialJson);

      // Assert
      expect(settings.merchantNormalization, isFalse);
      expect(settings.enableAudioFeedback, isTrue); // Default
      expect(settings.enableBatchCapture, isFalse); // Default
      expect(settings.maxRetryAttempts, equals(3)); // Default
    });

    test('should implement equality correctly', () {
      // Arrange
      const settings1 = AppSettings(merchantNormalization: false);
      const settings2 = AppSettings(merchantNormalization: false);
      const settings3 = AppSettings(merchantNormalization: true);

      // Assert
      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
    });
  });
}