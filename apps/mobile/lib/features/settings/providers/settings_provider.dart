import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/repositories/settings_repository.dart';

/// Provider for settings repository
final settingsRepositoryProvider = FutureProvider<SettingsRepository>((ref) async {
  return await SettingsRepository.create();
});

/// Provider for current app settings
final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier(ref);
});

/// State notifier for app settings
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final Ref _ref;
  SettingsRepository? _repository;

  AppSettingsNotifier(this._ref) : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final repository = await _ref.read(settingsRepositoryProvider.future);
      _repository = repository;
      final settings = await repository.loadSettings();
      state = settings;
    } catch (e) {
      print('Failed to load settings: $e');
    }
  }

  Future<bool> updateMerchantNormalization(bool enabled) async {
    if (_repository == null) return false;

    final success = await _repository!.updateSetting('merchantNormalization', enabled);
    if (success) {
      state = state.copyWith(merchantNormalization: enabled);
    }
    return success;
  }

  Future<bool> updateAudioFeedback(bool enabled) async {
    if (_repository == null) return false;

    final success = await _repository!.updateSetting('enableAudioFeedback', enabled);
    if (success) {
      state = state.copyWith(enableAudioFeedback: enabled);
    }
    return success;
  }

  Future<bool> updateBatchCapture(bool enabled) async {
    if (_repository == null) return false;

    final success = await _repository!.updateSetting('enableBatchCapture', enabled);
    if (success) {
      state = state.copyWith(enableBatchCapture: enabled);
    }
    return success;
  }

  Future<bool> updateMaxRetryAttempts(int attempts) async {
    if (_repository == null) return false;

    final success = await _repository!.updateSetting('maxRetryAttempts', attempts);
    if (success) {
      state = state.copyWith(maxRetryAttempts: attempts);
    }
    return success;
  }

  Future<bool> updateCsvFormat(String format) async {
    if (_repository == null) return false;

    final success = await _repository!.updateSetting('csvExportFormat', format);
    if (success) {
      state = state.copyWith(csvExportFormat: format);
    }
    return success;
  }

  Future<bool> updateDateFormat(String format) async {
    if (_repository == null) return false;

    final success = await _repository!.updateSetting('dateFormat', format);
    if (success) {
      state = state.copyWith(dateFormat: format);
    }
    return success;
  }

  Future<bool> updateDateRangePreset(String preset) async {
    if (_repository == null) return false;

    final success = await _repository!.updateSetting('dateRangePreset', preset);
    if (success) {
      state = state.copyWith(dateRangePreset: preset);
    }
    return success;
  }

  Future<bool> resetSettings() async {
    if (_repository == null) return false;

    final success = await _repository!.clearSettings();
    if (success) {
      state = const AppSettings();
    }
    return success;
  }
}

/// Provider for merchant normalization setting
final merchantNormalizationEnabledProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).merchantNormalization;
});