import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enhanced secure storage with encryption and key rotation
class EnhancedSecureStorageService {
  late final FlutterSecureStorage _storage;
  late final Encrypter _encrypter;
  late final IV _iv;
  static const String _keyPrefix = 'secure_';
  static const String _masterKeyName = 'master_encryption_key';
  static const String _keyRotationDate = 'key_rotation_date';
  static const int _keyRotationDays = 30;

  // Sensitive data categories
  static const String categoryAuth = 'auth';
  static const String categoryPayment = 'payment';
  static const String categoryPersonal = 'personal';
  static const String categoryApi = 'api';

  EnhancedSecureStorageService() {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        sharedPreferencesName: 'secure_prefs',
        preferencesKeyPrefix: 'secure_',
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.unlocked_this_device_only,
        accountName: 'receipt_organizer_secure',
        groupId: 'com.example.receiptorganizer',
        synchronizable: false,
      ),
    );
    _initializeEncryption();
  }

  /// Initialize encryption with master key
  void _initializeEncryption() async {
    String? masterKey = await _storage.read(key: _masterKeyName);

    if (masterKey == null) {
      // Generate new master key
      masterKey = _generateSecureKey();
      await _storage.write(key: _masterKeyName, value: masterKey);
      await _storage.write(
        key: _keyRotationDate,
        value: DateTime.now().toIso8601String(),
      );
    }

    final key = Key.fromBase64(masterKey);
    _iv = IV.fromSecureRandom(16);
    _encrypter = Encrypter(AES(key));

    // Check if key rotation is needed
    await _checkKeyRotation();
  }

  /// Generate secure random key
  String _generateSecureKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64.encode(bytes);
  }

  /// Check and perform key rotation if needed
  Future<void> _checkKeyRotation() async {
    final rotationDateStr = await _storage.read(key: _keyRotationDate);
    if (rotationDateStr != null) {
      final rotationDate = DateTime.parse(rotationDateStr);
      final daysSinceRotation = DateTime.now().difference(rotationDate).inDays;

      if (daysSinceRotation >= _keyRotationDays) {
        await _rotateKeys();
      }
    }
  }

  /// Rotate encryption keys
  Future<void> _rotateKeys() async {
    // Generate new master key
    final newMasterKey = _generateSecureKey();
    final newKey = Key.fromBase64(newMasterKey);
    final newEncrypter = Encrypter(AES(newKey));

    // Re-encrypt all existing data with new key
    final allKeys = await _storage.readAll();
    final dataToReEncrypt = <String, String>{};

    for (final entry in allKeys.entries) {
      if (entry.key.startsWith(_keyPrefix) &&
          entry.key != _masterKeyName &&
          entry.key != _keyRotationDate) {
        try {
          // Decrypt with old key
          final decrypted = _decrypt(entry.value);
          // Encrypt with new key
          final encrypted = newEncrypter.encrypt(decrypted, iv: _iv);
          dataToReEncrypt[entry.key] = encrypted.base64;
        } catch (e) {
          print('Error rotating key for ${entry.key}: $e');
        }
      }
    }

    // Update all encrypted data
    for (final entry in dataToReEncrypt.entries) {
      await _storage.write(key: entry.key, value: entry.value);
    }

    // Update master key and rotation date
    await _storage.write(key: _masterKeyName, value: newMasterKey);
    await _storage.write(
      key: _keyRotationDate,
      value: DateTime.now().toIso8601String(),
    );

    // Update encrypter
    _encrypter = newEncrypter;
  }

  /// Encrypt sensitive data
  String _encrypt(String plainText) {
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypt sensitive data
  String _decrypt(String encryptedText) {
    final encrypted = Encrypted.fromBase64(encryptedText);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }

  /// Store sensitive data with encryption
  Future<void> storeSecure({
    required String key,
    required String value,
    required String category,
    Map<String, String>? metadata,
  }) async {
    // Validate category
    if (![categoryAuth, categoryPayment, categoryPersonal, categoryApi]
        .contains(category)) {
      throw ArgumentError('Invalid category: $category');
    }

    // Create data package
    final dataPackage = {
      'value': value,
      'category': category,
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': metadata ?? {},
    };

    // Encrypt and store
    final encrypted = _encrypt(jsonEncode(dataPackage));
    await _storage.write(key: '$_keyPrefix$category\_$key', value: encrypted);

    // Log access (without sensitive data)
    await _logAccess('store', category, key);
  }

  /// Retrieve and decrypt sensitive data
  Future<String?> retrieveSecure({
    required String key,
    required String category,
  }) async {
    final storageKey = '$_keyPrefix$category\_$key';
    final encryptedData = await _storage.read(key: storageKey);

    if (encryptedData == null) return null;

    try {
      final decrypted = _decrypt(encryptedData);
      final dataPackage = jsonDecode(decrypted) as Map<String, dynamic>;

      // Log access
      await _logAccess('retrieve', category, key);

      return dataPackage['value'] as String;
    } catch (e) {
      print('Error retrieving secure data: $e');
      return null;
    }
  }

  /// Delete sensitive data
  Future<void> deleteSecure({
    required String key,
    required String category,
  }) async {
    final storageKey = '$_keyPrefix$category\_$key';
    await _storage.delete(key: storageKey);
    await _logAccess('delete', category, key);
  }

  /// Clear all data in a category
  Future<void> clearCategory(String category) async {
    final allKeys = await _storage.readAll();
    final prefix = '$_keyPrefix$category\_';

    for (final key in allKeys.keys) {
      if (key.startsWith(prefix)) {
        await _storage.delete(key: key);
      }
    }

    await _logAccess('clear', category, 'all');
  }

  /// Clear all secure storage
  Future<void> clearAll() async {
    await _storage.deleteAll();
    await _initializeEncryption();
  }

  /// Log access for audit trail
  Future<void> _logAccess(
    String action,
    String category,
    String key,
  ) async {
    final log = {
      'action': action,
      'category': category,
      'key': key,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Store in audit log (circular buffer of last 100 entries)
    final auditKey = 'audit_log';
    final existingLog = await _storage.read(key: auditKey);

    List<dynamic> auditLog = [];
    if (existingLog != null) {
      try {
        auditLog = jsonDecode(existingLog) as List<dynamic>;
      } catch (_) {}
    }

    auditLog.add(log);

    // Keep only last 100 entries
    if (auditLog.length > 100) {
      auditLog = auditLog.sublist(auditLog.length - 100);
    }

    await _storage.write(key: auditKey, value: jsonEncode(auditLog));
  }

  /// Get audit log
  Future<List<Map<String, dynamic>>> getAuditLog() async {
    final auditKey = 'audit_log';
    final existingLog = await _storage.read(key: auditKey);

    if (existingLog == null) return [];

    try {
      final log = jsonDecode(existingLog) as List<dynamic>;
      return log.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// Check if secure storage is available
  Future<bool> isAvailable() async {
    try {
      await _storage.write(key: '_test', value: 'test');
      await _storage.delete(key: '_test');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Export encrypted backup
  Future<String> exportBackup(String password) async {
    final allData = await _storage.readAll();

    // Filter sensitive data
    final dataToExport = <String, String>{};
    for (final entry in allData.entries) {
      if (entry.key.startsWith(_keyPrefix)) {
        dataToExport[entry.key] = entry.value;
      }
    }

    // Create backup package
    final backup = {
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'data': dataToExport,
    };

    // Encrypt backup with password
    final passwordKey = Key.fromBase64(
      base64.encode(sha256.convert(utf8.encode(password)).bytes),
    );
    final backupEncrypter = Encrypter(AES(passwordKey));
    final encrypted = backupEncrypter.encrypt(
      jsonEncode(backup),
      iv: _iv,
    );

    return encrypted.base64;
  }

  /// Import encrypted backup
  Future<void> importBackup(String encryptedBackup, String password) async {
    try {
      // Decrypt backup with password
      final passwordKey = Key.fromBase64(
        base64.encode(sha256.convert(utf8.encode(password)).bytes),
      );
      final backupEncrypter = Encrypter(AES(passwordKey));
      final encrypted = Encrypted.fromBase64(encryptedBackup);
      final decrypted = backupEncrypter.decrypt(encrypted, iv: _iv);

      // Parse backup
      final backup = jsonDecode(decrypted) as Map<String, dynamic>;
      final data = backup['data'] as Map<String, dynamic>;

      // Restore data
      for (final entry in data.entries) {
        await _storage.write(key: entry.key, value: entry.value as String);
      }

      // Re-initialize encryption
      await _initializeEncryption();
    } catch (e) {
      throw Exception('Failed to import backup: $e');
    }
  }
}

/// Provider for enhanced secure storage
final enhancedSecureStorageProvider = Provider<EnhancedSecureStorageService>(
  (ref) => EnhancedSecureStorageService(),
);

/// Secure credentials manager using enhanced storage
class SecureCredentialsManager {
  final EnhancedSecureStorageService _storage;

  SecureCredentialsManager(this._storage);

  /// Store API credentials
  Future<void> storeApiCredentials({
    required String service,
    required String apiKey,
    String? apiSecret,
  }) async {
    await _storage.storeSecure(
      key: '${service}_key',
      value: apiKey,
      category: EnhancedSecureStorageService.categoryApi,
      metadata: {'service': service},
    );

    if (apiSecret != null) {
      await _storage.storeSecure(
        key: '${service}_secret',
        value: apiSecret,
        category: EnhancedSecureStorageService.categoryApi,
        metadata: {'service': service},
      );
    }
  }

  /// Retrieve API credentials
  Future<ApiCredentials?> getApiCredentials(String service) async {
    final apiKey = await _storage.retrieveSecure(
      key: '${service}_key',
      category: EnhancedSecureStorageService.categoryApi,
    );

    if (apiKey == null) return null;

    final apiSecret = await _storage.retrieveSecure(
      key: '${service}_secret',
      category: EnhancedSecureStorageService.categoryApi,
    );

    return ApiCredentials(
      service: service,
      apiKey: apiKey,
      apiSecret: apiSecret,
    );
  }

  /// Store authentication token
  Future<void> storeAuthToken(String token, {String? refreshToken}) async {
    await _storage.storeSecure(
      key: 'auth_token',
      value: token,
      category: EnhancedSecureStorageService.categoryAuth,
      metadata: {'type': 'bearer'},
    );

    if (refreshToken != null) {
      await _storage.storeSecure(
        key: 'refresh_token',
        value: refreshToken,
        category: EnhancedSecureStorageService.categoryAuth,
        metadata: {'type': 'refresh'},
      );
    }
  }

  /// Get authentication token
  Future<AuthTokens?> getAuthTokens() async {
    final token = await _storage.retrieveSecure(
      key: 'auth_token',
      category: EnhancedSecureStorageService.categoryAuth,
    );

    if (token == null) return null;

    final refreshToken = await _storage.retrieveSecure(
      key: 'refresh_token',
      category: EnhancedSecureStorageService.categoryAuth,
    );

    return AuthTokens(
      accessToken: token,
      refreshToken: refreshToken,
    );
  }

  /// Clear all credentials
  Future<void> clearAllCredentials() async {
    await _storage.clearCategory(EnhancedSecureStorageService.categoryApi);
    await _storage.clearCategory(EnhancedSecureStorageService.categoryAuth);
  }
}

/// API credentials model
class ApiCredentials {
  final String service;
  final String apiKey;
  final String? apiSecret;

  ApiCredentials({
    required this.service,
    required this.apiKey,
    this.apiSecret,
  });
}

/// Auth tokens model
class AuthTokens {
  final String accessToken;
  final String? refreshToken;

  AuthTokens({
    required this.accessToken,
    this.refreshToken,
  });
}