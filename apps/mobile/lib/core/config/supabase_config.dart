import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// Supabase configuration and initialization
class SupabaseConfig {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'https://xbadaalqaeszooyxuoac.supabase.co',
      ),
      anonKey: const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhiYWRhYWxxYWVzem9veXh1b2FjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc3ODE1MzAsImV4cCI6MjA3MzM1NzUzMH0.PY-aQ6bjYUPaTL2o2twviFf5AJTSYR0gyKUkQb08OGc',
      ),
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        localStorage: SecureLocalStorage(),
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

/// Secure storage implementation for Supabase auth
class SecureLocalStorage extends LocalStorage {
  static const _storage = FlutterSecureStorage();
  static const _sessionKey = 'supabase_session';

  @override
  Future<void> initialize() async {
    // No initialization needed for flutter_secure_storage
  }

  @override
  Future<String?> accessToken() async {
    final session = await getItem(_sessionKey);
    if (session != null) {
      final data = json.decode(session);
      return data['access_token'];
    }
    return null;
  }

  @override
  Future<bool> hasAccessToken() async {
    final token = await accessToken();
    return token != null;
  }

  @override
  Future<String?> getItem(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      print('Error reading from secure storage: $e');
      return null;
    }
  }

  @override
  Future<void> setItem(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      print('Error writing to secure storage: $e');
    }
  }

  @override
  Future<void> removeItem(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      print('Error removing from secure storage: $e');
    }
  }

  @override
  Future<void> persistSession(String session) async {
    // Store the session string in secure storage
    await setItem(_sessionKey, session);
  }

  @override
  Future<void> removePersistedSession() async {
    // Remove the session from secure storage
    await removeItem(_sessionKey);
  }
}

/// Offline credentials cache for offline-first support
class OfflineCredentialsCache {
  static const _storage = FlutterSecureStorage();
  static const _credentialsKey = 'offline_credentials';
  static const _sessionKey = 'cached_session';

  static Future<void> cacheCredentials(String email, String passwordHash) async {
    final credentials = json.encode({
      'email': email,
      'passwordHash': passwordHash,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _storage.write(key: _credentialsKey, value: credentials);
  }

  static Future<Map<String, dynamic>?> getCachedCredentials() async {
    final data = await _storage.read(key: _credentialsKey);
    if (data != null) {
      return json.decode(data);
    }
    return null;
  }

  static Future<void> cacheSession(Session session) async {
    final sessionData = json.encode({
      'access_token': session.accessToken,
      'refresh_token': session.refreshToken,
      'expires_at': session.expiresAt,
      'user': session.user.toJson(),
    });
    await _storage.write(key: _sessionKey, value: sessionData);
  }

  static Future<Map<String, dynamic>?> getCachedSession() async {
    final data = await _storage.read(key: _sessionKey);
    if (data != null) {
      return json.decode(data);
    }
    return null;
  }

  static Future<void> clearCache() async {
    await _storage.delete(key: _credentialsKey);
    await _storage.delete(key: _sessionKey);
  }

  static bool isSessionExpired(Map<String, dynamic> session) {
    final expiresAt = session['expires_at'];
    if (expiresAt == null) return true;

    final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    return DateTime.now().isAfter(expiryTime);
  }
}