import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:receipt_organizer/data/models/camera_frame.dart';
import 'package:receipt_organizer/data/models/capture_result.dart';
import 'package:receipt_organizer/data/models/edge_detection_result.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:receipt_organizer/infrastructure/services/edge_detection_service.dart';

abstract class ICameraService {
  Future<CaptureResult> captureReceipt({bool batchMode = false});
  Stream<CameraFrame> getPreviewStream();
  Future<EdgeDetectionResult> detectEdges(CameraFrame frame);
  Future<CameraController?> getCameraController();
  Future<void> initialize();
  Future<void> dispose();
}

class CameraService implements ICameraService {
  bool _isInitialized = false;
  CameraController? _controller;
  final IOCRService _ocrService = OCRService();
  final EdgeDetectionService _edgeDetectionService = EdgeDetectionService();

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }
      
      // Initialize camera controller with back camera (first camera)
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      
      await _controller!.initialize();
      
      // Initialize OCR service
      await _ocrService.initialize();
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
    await _ocrService.dispose();
    _edgeDetectionService.dispose();
    _isInitialized = false;
  }

  @override
  Future<CaptureResult> captureReceipt({bool batchMode = false}) async {
    if (!_isInitialized) {
      return CaptureResult.error('Camera not initialized', code: 'CAMERA_3001');
    }
    
    try {
      // Simulate capture delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageUri = '/storage/receipts/receipt_$timestamp.jpg';
      
      // Process image with OCR (in batch mode, process immediately)
      ProcessingResult? ocrResults;
      if (batchMode) {
        try {
          // Generate dummy image data for OCR processing
          final dummyImageData = _generateDummyImageData();
          ocrResults = await _ocrService.processReceipt(dummyImageData);
        } catch (e) {
          // OCR failed, but capture was successful
          debugPrint('OCR processing failed: $e');
        }
      }
      
      return CaptureResult.success(imageUri, ocrResults: ocrResults);
    } catch (e) {
      return CaptureResult.error(
        'Failed to capture image: $e', 
        code: 'CAMERA_3002'
      );
    }
  }

  Uint8List _generateDummyImageData() {
    // Generate dummy image data for development/testing
    // In a real implementation, this would be the actual captured image
    return Uint8List.fromList(List.generate(1000, (index) => index % 256));
  }

  @override
  Future<EdgeDetectionResult> detectEdges(CameraFrame frame) async {
    if (!_isInitialized) {
      return const EdgeDetectionResult(success: false, confidence: 0.0);
    }
    
    return await _edgeDetectionService.detectEdges(frame);
  }

  @override
  Future<CameraController?> getCameraController() async {
    return _controller;
  }

  @override
  Stream<CameraFrame> getPreviewStream() async* {
    while (_isInitialized) {
      await Future.delayed(const Duration(milliseconds: 33));
      yield CameraFrame(
        imageData: _createDummyImageData(),
        timestamp: DateTime.now(),
      );
    }
  }

  Uint8List _createDummyImageData() {
    // Generate dummy image data for preview
    return Uint8List.fromList(List.generate(1000, (index) => index % 256));
  }
}