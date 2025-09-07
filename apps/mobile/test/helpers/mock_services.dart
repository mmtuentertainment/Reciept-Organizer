import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:receipt_organizer/domain/services/image_storage_service.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:receipt_organizer/domain/services/camera_service.dart';
import 'package:receipt_organizer/domain/services/merchant_normalization_service.dart';
import 'package:receipt_organizer/features/capture/services/retry_session_manager.dart';
import 'package:receipt_organizer/data/models/capture_session.dart' hide RetrySession;
import 'package:receipt_organizer/data/models/edge_detection_result.dart';
import 'package:receipt_organizer/data/models/camera_frame.dart';
import 'package:receipt_organizer/data/models/capture_result.dart';

/// Mock implementation of ImageStorageService for testing
class MockImageStorageService implements IImageStorageService {
  final Map<String, Uint8List> _storage = {};
  
  @override
  Future<String> saveTemporary(Uint8List imageData, {String? fileName}) async {
    final path = '/test/temp/${fileName ?? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg'}';
    _storage[path] = imageData;
    return path;
  }
  
  @override
  Future<void> deleteTemporary(String filePath) async {
    _storage.remove(filePath);
  }
  
  @override
  Future<bool> exists(String filePath) async {
    return _storage.containsKey(filePath);
  }
  
  @override
  Future<int> getFileSize(String filePath) async {
    return _storage[filePath]?.length ?? 0;
  }
}

/// Mock implementation of OCRService for testing
class MockOCRService implements OCRService {
  final bool enableMerchantNormalization;
  final MerchantNormalizationService? merchantNormalizationService;
  
  MockOCRService({
    this.enableMerchantNormalization = false,
    this.merchantNormalizationService,
  });
  
  @override
  Future<void> initialize() async {
    // No-op for mock
  }
  
  @override
  Future<void> dispose() async {
    // No-op for mock
  }
  
  @override
  Future<ProcessingResult> processReceipt(Uint8List imageData) async {
    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    return ProcessingResult(
      merchant: FieldData(
        value: 'Mock Store',
        confidence: 95.0,
        originalText: 'Mock Store',
      ),
      date: FieldData(
        value: '01/15/2024',
        confidence: 98.0,
        originalText: '01/15/2024',
      ),
      total: FieldData(
        value: 49.99,
        confidence: 96.0,
        originalText: '\$49.99',
      ),
      tax: FieldData(
        value: 4.00,
        confidence: 92.0,
        originalText: '\$4.00',
      ),
      overallConfidence: 95.0,
      processingDurationMs: 100,
    );
  }
  
  @override
  FailureDetectionResult detectFailure(ProcessingResult result, Uint8List imageData) {
    // Mock implementation - no failures by default
    return const FailureDetectionResult(
      isFailure: false,
      qualityScore: 95.0,
    );
  }
  
  @override
  String? detectAndNormalizeMerchant(String? rawMerchant) {
    if (!enableMerchantNormalization || merchantNormalizationService == null) {
      return rawMerchant;
    }
    return merchantNormalizationService!.normalize(rawMerchant ?? '');
  }
}

/// Factory function to create configured mock OCR service
OCRService createMockOCRService({
  bool enableMerchantNormalization = false,
}) {
  return MockOCRService(
    enableMerchantNormalization: enableMerchantNormalization,
    merchantNormalizationService: enableMerchantNormalization 
      ? MockMerchantNormalizationService() 
      : null,
  );
}

/// Mock implementation of CameraService for testing
class MockCameraService implements ICameraService {
  @override
  Future<void> initialize() async {
    // No-op for tests
  }
  
  @override
  Future<void> dispose() async {
    // No-op for tests
  }
  
  @override
  Future<Uint8List?> takePicture() async {
    // Return mock image data
    return Uint8List.fromList([1, 2, 3, 4, 5]);
  }
  
  @override
  bool get isInitialized => true;
  
  @override
  Stream<CameraState> get cameraStateStream => Stream.value(CameraState.ready);
  
  @override
  Future<CaptureResult> captureReceipt({bool batchMode = false}) async {
    // Return mock capture result
    return CaptureResult.success(
      '/test/image.jpg',
      thumbnailUri: '/test/thumb.jpg',
    );
  }
  
  @override
  Future<EdgeDetectionResult> detectEdges(CameraFrame frame) async {
    // Return mock edge detection
    return const EdgeDetectionResult(
      success: true,
      corners: [
        Point(0, 0),
        Point(1, 0),
        Point(0, 1),
        Point(1, 1),
      ],
      confidence: 0.9,
    );
  }
  
  @override
  Stream<CameraFrame> getPreviewStream() {
    // Return empty stream for tests
    return Stream.empty();
  }
  
  @override
  Future<CameraController?> getCameraController() async {
    // Return null for tests
    return null;
  }
}

/// Mock implementation of MerchantNormalizationService for testing
class MockMerchantNormalizationService implements MerchantNormalizationService {
  final Map<String, String> _normalizations = {
    'WALMART': 'Walmart',
    'TARGET': 'Target',
    'AMZN': 'Amazon',
  };
  
  @override
  String normalize(String? merchantName) {
    if (merchantName == null || merchantName.isEmpty) return '';
    final upper = merchantName.toUpperCase();
    for (final entry in _normalizations.entries) {
      if (upper.contains(entry.key)) {
        return entry.value;
      }
    }
    return merchantName;
  }
  
  @override
  double getConfidence(String originalName, String normalizedName) {
    return originalName != normalizedName ? 0.85 : 1.0;
  }
  
  @override
  List<String> getSuggestions(String merchantName) {
    return _normalizations.values
        .where((name) => name.toLowerCase().contains(merchantName.toLowerCase()))
        .toList();
  }
  
  @override
  bool isKnownMerchant(String merchantName) {
    return _normalizations.values.contains(merchantName);
  }
  
  @override
  void addCustomMapping(String original, String normalized) {
    _normalizations[original.toUpperCase()] = normalized;
  }
  
  @override
  int get cacheSize => _normalizations.length;
  
  @override
  void clearCache() {
    // In real implementation would clear cache, here we keep normalizations
  }
}

/// Mock implementation of RetrySessionManager for testing
class MockRetrySessionManager implements RetrySessionManager {
  final Map<String, RetrySession> _sessions = {};
  
  @override
  Future<bool> saveSession(RetrySession session) async {
    _sessions[session.sessionId] = session;
    return true;
  }
  
  
  @override
  Future<int> cleanupExpiredSessions() async {
    final now = DateTime.now();
    final expiredKeys = _sessions.entries
        .where((e) => now.difference(e.value.timestamp).inHours > 24)
        .map((e) => e.key)
        .toList();
    
    for (final key in expiredKeys) {
      _sessions.remove(key);
    }
    
    return expiredKeys.length;
  }
  
  @override
  Future<int> getStorageUsage() async {
    // Mock storage usage calculation
    return _sessions.length * 1024; // 1KB per session
  }
  
  @override
  Future<RetrySession?> loadSession(String sessionId) async {
    return _sessions[sessionId];
  }
  
  @override
  Future<bool> cleanupSession(String sessionId) async {
    _sessions.remove(sessionId);
    return true;
  }
  
  @override
  Future<List<String>> getActiveSessions() async {
    return _sessions.keys.toList();
  }
}

/// Enum for camera states
enum CameraState {
  uninitialized,
  initializing,
  ready,
  error,
}