import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

/// Repository for managing application settings
/// 
/// Handles persistence of user preferences using SharedPreferences
class SettingsRepository {
  static const String _settingsKey = 'app_settings';
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  /// Factory constructor to create repository with SharedPreferences
  static Future<SettingsRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsRepository(prefs);
  }

  /// Load settings from storage
  Future<AppSettings> loadSettings() async {
    try {
      final settingsJson = _prefs.getString(_settingsKey);
      if (settingsJson != null) {
        final settingsMap = jsonDecode(settingsJson);
        return AppSettings.fromJson(settingsMap);
      }
    } catch (e) {
      // If loading fails, return default settings
      print('Failed to load settings: $e');
    }
    return const AppSettings();
  }

  /// Save settings to storage
  Future<bool> saveSettings(AppSettings settings) async {
    try {
      final settingsJson = jsonEncode(settings.toJson());
      return await _prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      print('Failed to save settings: $e');
      return false;
    }
  }

  /// Update a specific setting
  Future<bool> updateSetting<T>(String key, T value) async {
    final currentSettings = await loadSettings();
    late AppSettings updatedSettings;

    switch (key) {
      case 'merchantNormalization':
        updatedSettings = currentSettings.copyWith(
          merchantNormalization: value as bool,
        );
        break;
      case 'enableAudioFeedback':
        updatedSettings = currentSettings.copyWith(
          enableAudioFeedback: value as bool,
        );
        break;
      case 'enableBatchCapture':
        updatedSettings = currentSettings.copyWith(
          enableBatchCapture: value as bool,
        );
        break;
      case 'maxRetryAttempts':
        updatedSettings = currentSettings.copyWith(
          maxRetryAttempts: value as int,
        );
        break;
      case 'csvExportFormat':
        updatedSettings = currentSettings.copyWith(
          csvExportFormat: value as String,
        );
        break;
      case 'dateFormat':
        updatedSettings = currentSettings.copyWith(
          dateFormat: value as String,
        );
        break;
      case 'dateRangePreset':
        updatedSettings = currentSettings.copyWith(
          dateRangePreset: value as String,
        );
        break;
      default:
        return false;
    }

    return await saveSettings(updatedSettings);
  }

  /// Clear all settings (reset to defaults)
  Future<bool> clearSettings() async {
    return await _prefs.remove(_settingsKey);
  }
}