import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/core/theme/app_theme.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:receipt_organizer/domain/services/merchant_normalization_service.dart';
import 'package:receipt_organizer/features/capture/providers/capture_provider.dart';
import 'package:receipt_organizer/features/capture/providers/image_storage_provider.dart';
import 'package:receipt_organizer/features/capture/providers/preview_initialization_provider.dart';
import 'package:receipt_organizer/features/receipts/presentation/providers/image_viewer_provider.dart' as image_viewer;
import 'package:receipt_organizer/features/settings/providers/settings_provider.dart';
import 'package:receipt_organizer/data/models/app_settings.dart';
import 'package:receipt_organizer/data/models/edge_detection_result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:state_notifier/state_notifier.dart';

import 'mock_services.dart';
import 'shared_preferences_test_helper.dart';

/// Test widget wrapper that provides all necessary providers with test-friendly overrides
class TestProviderScope extends StatelessWidget {
  final Widget child;
  final List<Override>? overrides;
  final CaptureState? captureState;
  final PreviewInitState? previewInitState;
  final SharedPreferences? sharedPreferences;
  
  const TestProviderScope({super.key,
    Key? key,
    required this.child,
    this.overrides,
    this.captureState,
    this.previewInitState,
    this.sharedPreferences,
  }) ;
  
  @override
  Widget build(BuildContext context) {
    // Create default test overrides
    final defaultOverrides = <Override>[
      // Mock services
      imageStorageServiceProvider.overrideWithValue(MockImageStorageService()),
      ocrServiceProvider.overrideWithValue(createMockOCRService()),
      cameraServiceProvider.overrideWithValue(MockCameraService()),
      merchantNormalizationServiceProvider.overrideWithValue(MockMerchantNormalizationService()),
      retrySessionManagerProvider.overrideWithValue(MockRetrySessionManager()),
      
      // Mock settings
      image_viewer.sharedPreferencesProvider.overrideWithValue(
        sharedPreferences ?? TestSharedPreferences(),
      ),
      appSettingsProvider.overrideWith((ref) => TestAppSettingsNotifier() as AppSettingsNotifier),
      
      // Mock capture provider
      captureProvider.overrideWith((ref) => TestCaptureNotifier(
        captureState ?? const CaptureState(),
      )),
      
      // Additional overrides passed in
      ...?overrides,
    ];
    
    return ProviderScope(
      overrides: defaultOverrides,
      child: MaterialApp(
        theme: AppTheme.light,
        home: child,
      ),
    );
  }
}

/// Test implementation of CaptureNotifier that doesn't have side effects
class TestCaptureNotifier extends CaptureNotifier {
  TestCaptureNotifier(CaptureState initialState) : super(
    ocrService: createMockOCRService(),
    cameraService: MockCameraService(),
    sessionManager: MockRetrySessionManager(),
  ) {
    state = initialState;
  }
  
  @override
  Future<void> initialize() async {
    // No-op for tests
  }
  
  @override
  void startCaptureSession({String? sessionId}) {
    state = CaptureState(
      sessionId: sessionId ?? 'test-session-${DateTime.now().millisecondsSinceEpoch}',
    );
  }
  
  @override
  Future<bool> processCapture(
    Uint8List imageData, {
    EdgeDetectionResult? edgeDetection,
    bool isRetryAttempt = false,
  }) async {
    state = state.copyWith(isProcessing: true);
    
    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    state = state.copyWith(
      isProcessing: false,
      lastProcessingResult: createMockProcessingResult(),
    );
    
    return true;
  }
  
  @override
  Future<bool> updateField(String fieldName, FieldData value) async {
    // Simulate successful update
    return true;
  }
  
  @override
  Future<bool> restoreSession(String sessionId) async {
    state = CaptureState(sessionId: sessionId);
    return true;
  }
}

/// Test implementation of AppSettingsNotifier
class TestAppSettingsNotifier extends StateNotifier<AppSettings> {
  TestAppSettingsNotifier() : super(const AppSettings());
  
  @override
  Future<bool> updateCsvFormat(String format) async {
    state = state.copyWith(csvExportFormat: format);
    return true;
  }
  
  @override
  Future<bool> updateDateRangePreset(String preset) async {
    state = state.copyWith(dateRangePreset: preset);
    return true;
  }
  
  @override
  Future<bool> updateMerchantNormalization(bool enabled) async {
    state = state.copyWith(merchantNormalization: enabled);
    return true;
  }
}

/// Helper to create a mock ProcessingResult
ProcessingResult createMockProcessingResult({
  String merchant = 'Test Store',
  String date = '01/15/2024',
  double total = 25.99,
  double tax = 2.08,
  double confidence = 89.5,
}) {
  return ProcessingResult(
    merchant: FieldData(
      value: merchant,
      confidence: confidence,
      originalText: merchant,
      boundingBox: const Rect.fromLTWH(100, 100, 100, 20),
    ),
    date: FieldData(
      value: date,
      confidence: confidence + 1,
      originalText: date,
      boundingBox: const Rect.fromLTWH(100, 150, 100, 20),
    ),
    total: FieldData(
      value: total,
      confidence: confidence + 2,
      originalText: '\$$total',
      boundingBox: const Rect.fromLTWH(100, 200, 100, 20),
    ),
    tax: FieldData(
      value: tax,
      confidence: confidence - 1,
      originalText: '\$$tax',
      boundingBox: const Rect.fromLTWH(100, 250, 100, 20),
    ),
    overallConfidence: confidence,
    processingDurationMs: 1500,
  );
}

/// Helper to create test image data
Uint8List createTestImageData([int size = 100]) {
  return Uint8List.fromList(List.generate(size, (i) => i % 256));
}

/// Helper to create a PreviewInitState for testing
PreviewInitState createTestPreviewInitState({
  String? imagePath,
  String? sessionId,
  bool isReady = true,
  bool isProcessing = false,
  String? error,
}) {
  return PreviewInitState(
    imagePath: imagePath ?? '/test/image.jpg',
    sessionId: sessionId ?? 'test-session-123',
    isReady: isReady,
    isProcessing: isProcessing,
    error: error,
  );
}