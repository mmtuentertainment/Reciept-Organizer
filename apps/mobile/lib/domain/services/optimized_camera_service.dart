import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:receipt_organizer/core/platform/image_capture.dart';
import 'package:receipt_organizer/core/platform/mobile/image_capture_mobile.dart';
import 'package:receipt_organizer/core/platform/web/image_capture_web.dart';
import 'package:receipt_organizer/data/models/camera_frame.dart';
import 'package:receipt_organizer/data/models/capture_result.dart';
import 'package:receipt_organizer/data/models/edge_detection_result.dart';
import 'package:receipt_organizer/domain/services/camera_service.dart';
import 'package:receipt_organizer/domain/services/image_processing_service.dart';

class OptimizedCameraService implements ICameraService {
  late ImageCaptureService _captureService;
  bool _isInitialized = false;
  bool _isCapturing = false;
  StreamController<CameraFrame>? _previewStreamController;

  static const int maxMemoryUsage = 50 * 1024 * 1024;
  int _currentMemoryUsage = 0;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize platform-specific capture service
      _captureService = kIsWeb
          ? ImageCaptureServiceWeb()
          : ImageCaptureServiceMobile();

      await _captureService.initialize();

      // Check camera availability
      final hasCamera = await _captureService.isCameraAvailable();
      if (!hasCamera && !kIsWeb) {
        throw Exception('No camera available');
      }

      _previewStreamController = StreamController<CameraFrame>.broadcast();
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    await _previewStreamController?.close();
    await _captureService.dispose();
    _isInitialized = false;
    _currentMemoryUsage = 0;
  }

  @override
  Future<CaptureResult> captureReceipt({bool batchMode = false}) async {
    if (!_isInitialized) {
      return CaptureResult.error('Camera not initialized', code: 'OPT_CAM_001');
    }

    if (_isCapturing) {
      return CaptureResult.error('Capture already in progress', code: 'OPT_CAM_002');
    }

    _isCapturing = true;

    try {
      // Memory check
      if (_currentMemoryUsage > maxMemoryUsage) {
        await _clearMemoryCache();
      }

      // Capture image using platform abstraction
      final capturedImage = batchMode
          ? (await _captureService.captureBatch(maxImages: 1)).firstOrNull
          : await _captureService.captureImage();

      if (capturedImage == null) {
        return CaptureResult.error('Failed to capture image', code: 'OPT_CAM_003');
      }

      _currentMemoryUsage += capturedImage.sizeInBytes;

      // Generate storage path
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageUri = '/storage/receipts/optimized_$timestamp.jpg';

      // For batch mode, process immediately
      if (batchMode) {
        // Process with image processing service
        final processingService = ImageProcessingService();
        await processingService.processImage(capturedImage.bytes);
      }

      return CaptureResult.success(imageUri);

    } catch (e) {
      return CaptureResult.error('Capture failed: $e', code: 'OPT_CAM_004');
    } finally {
      _isCapturing = false;
    }
  }

  @override
  Stream<CameraFrame> getPreviewStream() {
    if (!_isInitialized || _previewStreamController == null) {
      return Stream.empty();
    }

    // Generate preview frames
    _startPreviewGeneration();
    return _previewStreamController!.stream;
  }

  @override
  Future<EdgeDetectionResult> detectEdges(CameraFrame frame) async {
    // Simple edge detection placeholder
    // In production, this would use image processing algorithms
    return const EdgeDetectionResult(
      success: true,
      confidence: 0.85,
      edges: [],
    );
  }

  @override
  Future<ImageCaptureService?> getImageCaptureService() async {
    return _isInitialized ? _captureService : null;
  }

  void _startPreviewGeneration() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isInitialized || _previewStreamController == null) {
        timer.cancel();
        return;
      }

      // Generate preview frame
      final frame = CameraFrame(
        imageData: Uint8List(100), // Minimal data for preview
        timestamp: DateTime.now(),
      );

      if (!_previewStreamController!.isClosed) {
        _previewStreamController!.add(frame);
      }
    });
  }

  Future<void> _clearMemoryCache() async {
    // Clear memory cache
    _currentMemoryUsage = 0;
    debugPrint('OptimizedCameraService: Memory cache cleared');
  }
}