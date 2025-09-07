import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test helper for SharedPreferences
class TestSharedPreferences implements SharedPreferences {
  final Map<String, Object> _values = {};

  @override
  Future<bool> setBool(String key, bool value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _values[key] = value;
    return true;
  }

  @override
  bool? getBool(String key) => _values[key] as bool?;

  @override
  double? getDouble(String key) => _values[key] as double?;

  @override
  int? getInt(String key) => _values[key] as int?;

  @override
  String? getString(String key) => _values[key] as String?;

  @override
  List<String>? getStringList(String key) => _values[key] as List<String>?;

  @override
  Set<String> getKeys() => _values.keys.toSet();

  @override
  Object? get(String key) => _values[key];

  @override
  bool containsKey(String key) => _values.containsKey(key);

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _values.clear();
    return true;
  }

  @override
  Future<void> reload() async {
    // No-op for tests
  }

  @override
  Future<bool> commit() async {
    return true;
  }

  // Helper method to set initial values for testing
  void setInitialValues(Map<String, Object> values) {
    _values.addAll(values);
  }
}

/// Override provider for tests
final sharedPreferencesTestProvider = Provider<SharedPreferences>((ref) {
  return TestSharedPreferences();
});

/// Helper to create a provider container with SharedPreferences override
ProviderContainer createTestProviderContainer({
  Map<String, Object>? initialPreferences,
}) {
  final testPrefs = TestSharedPreferences();
  if (initialPreferences != null) {
    testPrefs.setInitialValues(initialPreferences);
  }

  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(testPrefs),
    ],
  );
}

// Re-export the provider from the actual implementation
// This should match the provider defined in your app
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in tests');
});