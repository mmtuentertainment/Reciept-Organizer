import '../../../core/services/secure_storage_service.dart';

/// API credentials manager for QuickBooks and Xero integration
/// Uses SecureStorageService for safe token storage
class APICredentials {
  // QuickBooks OAuth 2.0 endpoints
  static const String quickbooksAuthUrl = 'https://appcenter.intuit.com/connect/oauth2';
  static const String quickbooksTokenUrl = 'https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer';
  static const String quickbooksApiBaseUrl = 'https://sandbox-quickbooks.api.intuit.com/v3';

  // Xero OAuth 2.0 endpoints
  static const String xeroAuthUrl = 'https://login.xero.com/identity/connect/authorize';
  static const String xeroTokenUrl = 'https://identity.xero.com/connect/token';
  static const String xeroApiBaseUrl = 'https://api.xero.com/api.xro/2.0';

  // Client IDs (these should be loaded from environment config)
  static const String quickbooksClientId = 'QUICKBOOKS_CLIENT_ID';
  static const String xeroClientId = 'XERO_CLIENT_ID';

  // Secure storage instance
  static final _secureStorage = SecureStorageService();

  // Token storage implementation with secure storage
  static Future<String?> getQuickbooksAccessToken() async {
    return await _secureStorage.getQuickbooksAccessToken();
  }

  static Future<String?> getQuickbooksRefreshToken() async {
    return await _secureStorage.getQuickbooksRefreshToken();
  }

  static Future<String?> getQuickbooksCompanyId() async {
    return await _secureStorage.getQuickbooksCompanyId();
  }

  static Future<String?> getXeroAccessToken() async {
    return await _secureStorage.getXeroAccessToken();
  }

  static Future<String?> getXeroRefreshToken() async {
    return await _secureStorage.getXeroRefreshToken();
  }

  static Future<String?> getXeroTenantId() async {
    return await _secureStorage.getXeroTenantId();
  }

  static Future<void> storeQuickbooksTokens({
    required String accessToken,
    required String refreshToken,
    String? companyId,
    int? expiresIn,
  }) async {
    await _secureStorage.storeQuickbooksTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      companyId: companyId,
      expiresIn: expiresIn,
    );
  }

  static Future<void> storeXeroTokens({
    required String accessToken,
    required String refreshToken,
    String? tenantId,
    int? expiresIn,
  }) async {
    await _secureStorage.storeXeroTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tenantId: tenantId,
      expiresIn: expiresIn,
    );
  }

  // Additional security utilities

  /// Check if QuickBooks credentials exist
  static Future<bool> hasQuickbooksCredentials() async {
    return await _secureStorage.hasQuickbooksCredentials();
  }

  /// Check if Xero credentials exist
  static Future<bool> hasXeroCredentials() async {
    return await _secureStorage.hasXeroCredentials();
  }

  /// Clear QuickBooks credentials
  static Future<void> clearQuickbooksCredentials() async {
    await _secureStorage.clearQuickbooksTokens();
  }

  /// Clear Xero credentials
  static Future<void> clearXeroCredentials() async {
    await _secureStorage.clearXeroTokens();
  }

  /// Clear all stored credentials
  static Future<void> clearAllCredentials() async {
    await _secureStorage.clearAllTokens();
  }

  /// Check if QuickBooks token needs refresh
  static Future<bool> needsQuickbooksTokenRefresh() async {
    return await _secureStorage.isQuickbooksTokenExpired();
  }

  /// Check if Xero token needs refresh
  static Future<bool> needsXeroTokenRefresh() async {
    return await _secureStorage.isXeroTokenExpired();
  }
}

/// Validation result for API services
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  
  ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });
}