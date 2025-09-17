/// Simple secure storage for API keys
/// Only loaded when explicitly needed
class ApiKeys {
  // Google Vision API key - only set via --dart-define
  static const String googleVisionApiKey = String.fromEnvironment(
    'GOOGLE_VISION_API_KEY',
    defaultValue: '',
  );

  /// Check if Google Vision API is available
  static bool get hasGoogleVisionApi => googleVisionApiKey.isNotEmpty;
}