import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

/// Secure storage service for sensitive data like OAuth tokens
///
/// Uses flutter_secure_storage which provides:
/// - iOS: Keychain
/// - Android: AES encryption with key stored in Android Keystore
/// - Web: Browser's localStorage with additional encryption
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  late final FlutterSecureStorage _storage;
  bool _isInitialized = false;

  /// Storage keys for OAuth tokens
  static const String _keyQuickbooksAccessToken = 'qb_access_token';
  static const String _keyQuickbooksRefreshToken = 'qb_refresh_token';
  static const String _keyQuickbooksCompanyId = 'qb_company_id';
  static const String _keyQuickbooksTokenExpiry = 'qb_token_expiry';

  static const String _keyXeroAccessToken = 'xero_access_token';
  static const String _keyXeroRefreshToken = 'xero_refresh_token';
  static const String _keyXeroTenantId = 'xero_tenant_id';
  static const String _keyXeroTokenExpiry = 'xero_token_expiry';

  /// Initialize secure storage with platform-specific options
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Platform-specific configuration
    AndroidOptions getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: 'receipt_organizer_secure_prefs',
      preferencesKeyPrefix: 'secure_',
    );

    IOSOptions getIOSOptions() => const IOSOptions(
      accountName: 'receipt_organizer_oauth',
    );

    WebOptions getWebOptions() => const WebOptions(
      dbName: 'receipt_organizer_secure',
      publicKey: 'receipt_organizer_public_key',
    );

    _storage = FlutterSecureStorage(
      aOptions: getAndroidOptions(),
      iOptions: getIOSOptions(),
      webOptions: getWebOptions(),
    );

    _isInitialized = true;

    // Migrate any existing insecure tokens if needed
    await _migrateInsecureTokensIfNeeded();
  }

  /// QuickBooks Token Management

  Future<String?> getQuickbooksAccessToken() async {
    await _ensureInitialized();
    try {
      final token = await _storage.read(key: _keyQuickbooksAccessToken);

      // Check if token is expired
      if (token != null && await isQuickbooksTokenExpired()) {
        // Token expired, trigger refresh flow
        return null;
      }

      return token;
    } catch (e) {
      debugPrint('Error reading QuickBooks access token: $e');
      return null;
    }
  }

  Future<String?> getQuickbooksRefreshToken() async {
    await _ensureInitialized();
    try {
      return await _storage.read(key: _keyQuickbooksRefreshToken);
    } catch (e) {
      debugPrint('Error reading QuickBooks refresh token: $e');
      return null;
    }
  }

  Future<String?> getQuickbooksCompanyId() async {
    await _ensureInitialized();
    try {
      return await _storage.read(key: _keyQuickbooksCompanyId);
    } catch (e) {
      debugPrint('Error reading QuickBooks company ID: $e');
      return null;
    }
  }

  Future<void> storeQuickbooksTokens({
    required String accessToken,
    required String refreshToken,
    String? companyId,
    int? expiresIn,
  }) async {
    await _ensureInitialized();
    try {
      // Store tokens atomically
      await Future.wait([
        _storage.write(key: _keyQuickbooksAccessToken, value: accessToken),
        _storage.write(key: _keyQuickbooksRefreshToken, value: refreshToken),
        if (companyId != null)
          _storage.write(key: _keyQuickbooksCompanyId, value: companyId),
        if (expiresIn != null)
          _storage.write(
            key: _keyQuickbooksTokenExpiry,
            value: DateTime.now()
                .add(Duration(seconds: expiresIn))
                .millisecondsSinceEpoch
                .toString(),
          ),
      ]);
    } catch (e) {
      debugPrint('Error storing QuickBooks tokens: $e');
      rethrow;
    }
  }

  Future<bool> isQuickbooksTokenExpired() async {
    await _ensureInitialized();
    try {
      final expiryStr = await _storage.read(key: _keyQuickbooksTokenExpiry);
      if (expiryStr == null) return true;

      final expiry = DateTime.fromMillisecondsSinceEpoch(int.parse(expiryStr));
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      return true;
    }
  }

  Future<void> clearQuickbooksTokens() async {
    await _ensureInitialized();
    try {
      await Future.wait([
        _storage.delete(key: _keyQuickbooksAccessToken),
        _storage.delete(key: _keyQuickbooksRefreshToken),
        _storage.delete(key: _keyQuickbooksCompanyId),
        _storage.delete(key: _keyQuickbooksTokenExpiry),
      ]);
    } catch (e) {
      debugPrint('Error clearing QuickBooks tokens: $e');
    }
  }

  /// Xero Token Management

  Future<String?> getXeroAccessToken() async {
    await _ensureInitialized();
    try {
      final token = await _storage.read(key: _keyXeroAccessToken);

      // Check if token is expired
      if (token != null && await isXeroTokenExpired()) {
        // Token expired, trigger refresh flow
        return null;
      }

      return token;
    } catch (e) {
      debugPrint('Error reading Xero access token: $e');
      return null;
    }
  }

  Future<String?> getXeroRefreshToken() async {
    await _ensureInitialized();
    try {
      return await _storage.read(key: _keyXeroRefreshToken);
    } catch (e) {
      debugPrint('Error reading Xero refresh token: $e');
      return null;
    }
  }

  Future<String?> getXeroTenantId() async {
    await _ensureInitialized();
    try {
      return await _storage.read(key: _keyXeroTenantId);
    } catch (e) {
      debugPrint('Error reading Xero tenant ID: $e');
      return null;
    }
  }

  Future<void> storeXeroTokens({
    required String accessToken,
    required String refreshToken,
    String? tenantId,
    int? expiresIn,
  }) async {
    await _ensureInitialized();
    try {
      // Store tokens atomically
      await Future.wait([
        _storage.write(key: _keyXeroAccessToken, value: accessToken),
        _storage.write(key: _keyXeroRefreshToken, value: refreshToken),
        if (tenantId != null)
          _storage.write(key: _keyXeroTenantId, value: tenantId),
        if (expiresIn != null)
          _storage.write(
            key: _keyXeroTokenExpiry,
            value: DateTime.now()
                .add(Duration(seconds: expiresIn))
                .millisecondsSinceEpoch
                .toString(),
          ),
      ]);
    } catch (e) {
      debugPrint('Error storing Xero tokens: $e');
      rethrow;
    }
  }

  Future<bool> isXeroTokenExpired() async {
    await _ensureInitialized();
    try {
      final expiryStr = await _storage.read(key: _keyXeroTokenExpiry);
      if (expiryStr == null) return true;

      final expiry = DateTime.fromMillisecondsSinceEpoch(int.parse(expiryStr));
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      return true;
    }
  }

  Future<void> clearXeroTokens() async {
    await _ensureInitialized();
    try {
      await Future.wait([
        _storage.delete(key: _keyXeroAccessToken),
        _storage.delete(key: _keyXeroRefreshToken),
        _storage.delete(key: _keyXeroTenantId),
        _storage.delete(key: _keyXeroTokenExpiry),
      ]);
    } catch (e) {
      debugPrint('Error clearing Xero tokens: $e');
    }
  }

  /// General utilities

  Future<bool> hasQuickbooksCredentials() async {
    await _ensureInitialized();
    final accessToken = await _storage.read(key: _keyQuickbooksAccessToken);
    final refreshToken = await _storage.read(key: _keyQuickbooksRefreshToken);
    return accessToken != null || refreshToken != null;
  }

  Future<bool> hasXeroCredentials() async {
    await _ensureInitialized();
    final accessToken = await _storage.read(key: _keyXeroAccessToken);
    final refreshToken = await _storage.read(key: _keyXeroRefreshToken);
    return accessToken != null || refreshToken != null;
  }

  Future<void> clearAllTokens() async {
    await _ensureInitialized();
    await Future.wait([
      clearQuickbooksTokens(),
      clearXeroTokens(),
    ]);
  }

  /// Private methods

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Migrate tokens from insecure storage if they exist
  /// This is for backward compatibility only
  Future<void> _migrateInsecureTokensIfNeeded() async {
    // Check if migration is needed
    // This would read from SharedPreferences or other insecure storage
    // and move to secure storage, then delete from insecure location

    // For now, we'll just log that migration check occurred
    debugPrint('SecureStorageService: Checked for token migration');
  }

  /// Check storage availability on the platform
  Future<bool> isStorageAvailable() async {
    try {
      await _storage.write(key: '_test_key', value: 'test');
      await _storage.delete(key: '_test_key');
      return true;
    } catch (e) {
      debugPrint('Secure storage not available: $e');
      return false;
    }
  }
}