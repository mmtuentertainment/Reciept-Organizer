import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

/// Service for handling offline authentication and secure credential storage
class OfflineAuthService {
  static const _secureStorage = FlutterSecureStorage();
  static const String _cachedCredentialsKey = 'offline_auth_credentials';
  static const String _cachedSessionKey = 'offline_auth_session';
  static const String _lastSyncKey = 'offline_auth_last_sync';

  /// Cache user credentials securely for offline authentication
  static Future<void> cacheCredentials({
    required String email,
    required String password,
  }) async {
    final passwordHash = _hashPassword(password);
    final credentials = json.encode({
      'email': email,
      'passwordHash': passwordHash,
      'cachedAt': DateTime.now().toIso8601String(),
    });

    await _secureStorage.write(
      key: _cachedCredentialsKey,
      value: credentials,
    );
  }

  /// Cache session for offline access
  static Future<void> cacheSession(Session session) async {
    final sessionData = json.encode({
      'access_token': session.accessToken,
      'refresh_token': session.refreshToken,
      'expires_at': session.expiresAt,
      'user': session.user.toJson(),
      'cachedAt': DateTime.now().toIso8601String(),
    });

    await _secureStorage.write(
      key: _cachedSessionKey,
      value: sessionData,
    );
  }

  /// Verify offline credentials
  static Future<bool> verifyOfflineCredentials({
    required String email,
    required String password,
  }) async {
    try {
      final cachedData = await _secureStorage.read(key: _cachedCredentialsKey);
      if (cachedData == null) return false;

      final credentials = json.decode(cachedData);
      final passwordHash = _hashPassword(password);

      return credentials['email'] == email &&
             credentials['passwordHash'] == passwordHash;
    } catch (e) {
      print('Error verifying offline credentials: $e');
      return false;
    }
  }

  /// Get cached session for offline mode
  static Future<Session?> getCachedSession() async {
    try {
      final sessionData = await _secureStorage.read(key: _cachedSessionKey);
      if (sessionData == null) return null;

      final data = json.decode(sessionData);

      // Check if session is expired
      if (_isSessionExpired(data['expires_at'])) {
        return null;
      }

      // Reconstruct session from cached data
      return Session(
        accessToken: data['access_token'],
        refreshToken: data['refresh_token'],
        expiresAt: data['expires_at'],
        tokenType: 'bearer',
        user: User.fromJson(data['user']),
      );
    } catch (e) {
      print('Error getting cached session: $e');
      return null;
    }
  }

  /// Clear all cached authentication data
  static Future<void> clearCache() async {
    await _secureStorage.delete(key: _cachedCredentialsKey);
    await _secureStorage.delete(key: _cachedSessionKey);
    await _secureStorage.delete(key: _lastSyncKey);
  }

  /// Check if offline mode is available
  static Future<bool> isOfflineModeAvailable() async {
    final credentials = await _secureStorage.read(key: _cachedCredentialsKey);
    final session = await _secureStorage.read(key: _cachedSessionKey);
    return credentials != null && session != null;
  }

  /// Check network connectivity
  static Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Update last sync timestamp
  static Future<void> updateLastSync() async {
    await _secureStorage.write(
      key: _lastSyncKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Get last sync timestamp
  static Future<DateTime?> getLastSync() async {
    final timestamp = await _secureStorage.read(key: _lastSyncKey);
    if (timestamp != null) {
      return DateTime.parse(timestamp);
    }
    return null;
  }

  /// Check if data needs sync (older than 24 hours)
  static Future<bool> needsSync() async {
    final lastSync = await getLastSync();
    if (lastSync == null) return true;

    final hoursSinceSync = DateTime.now().difference(lastSync).inHours;
    return hoursSinceSync > 24;
  }

  /// Hash password using SHA256
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Check if session is expired
  static bool _isSessionExpired(int? expiresAt) {
    if (expiresAt == null) return true;

    final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    // Add 5 minute buffer before actual expiry
    final bufferTime = DateTime.now().add(const Duration(minutes: 5));
    return bufferTime.isAfter(expiryTime);
  }

  /// Migrate from old storage format if needed
  static Future<void> migrateStorageIfNeeded() async {
    // Check for old storage keys and migrate if found
    const oldCredentialsKey = 'supabase_credentials';
    const oldSessionKey = 'supabase_session';

    try {
      final oldCreds = await _secureStorage.read(key: oldCredentialsKey);
      final oldSession = await _secureStorage.read(key: oldSessionKey);

      if (oldCreds != null) {
        await _secureStorage.write(key: _cachedCredentialsKey, value: oldCreds);
        await _secureStorage.delete(key: oldCredentialsKey);
      }

      if (oldSession != null) {
        await _secureStorage.write(key: _cachedSessionKey, value: oldSession);
        await _secureStorage.delete(key: oldSessionKey);
      }
    } catch (e) {
      print('Migration error (non-critical): $e');
    }
  }
}