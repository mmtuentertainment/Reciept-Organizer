import 'package:flutter/foundation.dart';
import '../config/environment.dart';

/// OCR Provider Types
enum OcrProvider {
  mlKit,        // Mobile only - free, offline
  tesseractJs,  // Web only - free, client-side
  googleVision, // All platforms - paid, requires API key
  azureVision,  // All platforms - paid, requires API key
  mock,         // Development/testing
}

/// OCR Configuration Service
/// Manages OCR providers and API keys for different platforms
class OcrConfigurationService {
  static final OcrConfigurationService _instance = OcrConfigurationService._internal();
  factory OcrConfigurationService() => _instance;
  OcrConfigurationService._internal();

  /// Get the recommended OCR provider for current platform
  OcrProvider getRecommendedProvider() {
    // Check if we're in development mode
    if (Environment.isDevelopment && !_hasCloudApiKey()) {
      debugPrint('OCR: Using mock provider (no API key configured)');
      return OcrProvider.mock;
    }

    if (kIsWeb) {
      // Web platform
      if (_hasCloudApiKey()) {
        return OcrProvider.googleVision;
      } else {
        // Tesseract.js for free client-side OCR
        return OcrProvider.tesseractJs;
      }
    } else {
      // Mobile platforms
      // ML Kit is free and works offline
      return OcrProvider.mlKit;
    }
  }

  /// Check if cloud API key is available
  bool _hasCloudApiKey() {
    final googleApiKey = getGoogleVisionApiKey();
    final azureApiKey = getAzureVisionApiKey();
    return googleApiKey != null || azureApiKey != null;
  }

  /// Google Vision API Configuration
  String? getGoogleVisionApiKey() {
    // Load from environment or secure storage
    // For production, this should come from secure configuration
    final key = const String.fromEnvironment('GOOGLE_VISION_API_KEY');
    return key.isNotEmpty ? key : null;
  }

  String getGoogleVisionEndpoint() {
    return 'https://vision.googleapis.com/v1/images:annotate';
  }

  /// Azure Computer Vision Configuration
  String? getAzureVisionApiKey() {
    final key = const String.fromEnvironment('AZURE_VISION_API_KEY');
    return key.isNotEmpty ? key : null;
  }

  String? getAzureVisionEndpoint() {
    final endpoint = const String.fromEnvironment('AZURE_VISION_ENDPOINT');
    return endpoint.isNotEmpty ? endpoint : null;
  }

  /// Tesseract.js Configuration for Web
  String getTesseractWorkerUrl() {
    return 'https://unpkg.com/tesseract.js@4.0.0/dist/worker.min.js';
  }

  String getTesseractCoreUrl() {
    return 'https://unpkg.com/tesseract.js-core@4.0.0/tesseract-core.wasm.js';
  }

  String getTesseractLanguage() {
    return 'eng'; // English
  }

  /// ML Kit Configuration for Mobile
  bool isMLKitAvailable() {
    // ML Kit is available on iOS 10+ and Android API 21+
    return !kIsWeb;
  }

  /// OCR Quality Settings
  Map<String, dynamic> getQualitySettings() {
    return {
      'imageQuality': 0.85,          // JPEG compression quality
      'maxImageWidth': 2048,         // Max width for processing
      'maxImageHeight': 2048,        // Max height for processing
      'confidenceThreshold': 0.6,   // Minimum confidence for text
      'preprocessImage': true,       // Apply image preprocessing
      'detectLayout': true,          // Detect document layout
      'extractTables': false,        // Extract table structures
    };
  }

  /// Image Preprocessing Settings
  Map<String, dynamic> getPreprocessingSettings() {
    return {
      'convertToGrayscale': true,
      'enhanceContrast': true,
      'removeNoise': true,
      'deskew': true,
      'removeBackground': false,
      'sharpen': true,
    };
  }

  /// Rate Limiting for Cloud APIs
  Map<String, dynamic> getRateLimits() {
    return {
      'googleVision': {
        'requestsPerSecond': 10,
        'requestsPerMonth': 1000, // Free tier
      },
      'azureVision': {
        'requestsPerSecond': 10,
        'requestsPerMonth': 5000, // Free tier
      },
    };
  }

  /// Cost Tracking
  double getEstimatedCostPerRequest(OcrProvider provider) {
    switch (provider) {
      case OcrProvider.mlKit:
        return 0.0; // Free on device
      case OcrProvider.tesseractJs:
        return 0.0; // Free client-side
      case OcrProvider.googleVision:
        return 0.0015; // $1.50 per 1000 requests after free tier
      case OcrProvider.azureVision:
        return 0.001; // $1 per 1000 requests after free tier
      case OcrProvider.mock:
        return 0.0;
    }
  }

  /// Get provider display name
  String getProviderDisplayName(OcrProvider provider) {
    switch (provider) {
      case OcrProvider.mlKit:
        return 'Google ML Kit (On-Device)';
      case OcrProvider.tesseractJs:
        return 'Tesseract.js (Browser-Based)';
      case OcrProvider.googleVision:
        return 'Google Cloud Vision';
      case OcrProvider.azureVision:
        return 'Azure Computer Vision';
      case OcrProvider.mock:
        return 'Mock Provider (Development)';
    }
  }

  /// Check if provider requires internet
  bool requiresInternet(OcrProvider provider) {
    switch (provider) {
      case OcrProvider.mlKit:
        return false; // Works offline
      case OcrProvider.tesseractJs:
        return false; // After initial download
      case OcrProvider.googleVision:
      case OcrProvider.azureVision:
        return true;
      case OcrProvider.mock:
        return false;
    }
  }
}