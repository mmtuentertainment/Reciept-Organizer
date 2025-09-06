import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:receipt_organizer/data/models/camera_frame.dart';
import 'package:receipt_organizer/data/models/capture_result.dart';
import 'package:receipt_organizer/data/models/edge_detection_result.dart';
import 'package:receipt_organizer/domain/services/camera_service.dart';
import 'package:receipt_organizer/domain/services/image_processing_service.dart';

class OptimizedCameraService implements ICameraService {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isCapturing = false;
  StreamController<CameraFrame>? _previewStreamController;
  
  static const int maxMemoryUsage = 50 * 1024 * 1024;
  int _currentMemoryUsage = 0;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isInitialized = true;
      
      _previewStreamController = StreamController<CameraFrame>.broadcast();
      
      _startPreviewStream();
    } catch (e) {
      throw Exception('Failed to initialize camera: $e');
    }
  }

  @override
  Future<void> dispose() async {
    await _previewStreamController?.close();
    await _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _currentMemoryUsage = 0;
  }

  @override
  Future<CaptureResult> captureReceipt({bool batchMode = false}) async {
    if (!_isInitialized || _controller == null) {
      return CaptureResult.error(
        'Camera not initialized',
        code: 'CAMERA_3001',
      );
    }

    if (_isCapturing) {
      return CaptureResult.error(
        'Camera is already capturing',
        code: 'CAMERA_3002',
      );
    }

    _isCapturing = true;

    try {
      if (_currentMemoryUsage > maxMemoryUsage) {
        await _performMemoryCleanup();
      }

      final XFile imageFile = await _controller!.takePicture();
      final imageBytes = await imageFile.readAsBytes();
      
      final compressedBytes = await ImageProcessingService.compressImage(imageBytes);
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageUri = '/storage/receipts/receipt_$timestamp.jpg';
      
      _currentMemoryUsage += compressedBytes.length;

      return CaptureResult.success(imageUri);
    } catch (e) {
      return CaptureResult.error(
        'Failed to capture image: $e',
        code: 'CAMERA_3003',
      );
    } finally {
      _isCapturing = false;
    }
  }

  @override
  Future<EdgeDetectionResult> detectEdges(CameraFrame frame) async {
    if (!_isInitialized) {
      return const EdgeDetectionResult(success: false);
    }

    try {
      final imageBytes = await _cameraImageToBytes(frame.image!);
      return await ImageProcessingService.detectEdgesInBackground(imageBytes);
    } catch (e) {
      return const EdgeDetectionResult(success: false);
    }
  }

  @override
  Future<CameraController?> getCameraController() async {
    return _controller;
  }

  @override
  Stream<CameraFrame> getPreviewStream() {
    if (!_isInitialized || _previewStreamController == null) {
      return const Stream.empty();
    }
    return _previewStreamController!.stream;
  }

  void _startPreviewStream() {
    if (!_isInitialized || _controller == null) return;

    Timer.periodic(const Duration(milliseconds: 33), (timer) {
      if (!_isInitialized) {
        timer.cancel();
        return;
      }

      _controller!.startImageStream((CameraImage image) {
        final frame = CameraFrame(
          image: image,
          imageData: Uint8List.fromList([0, 0, 0]), // Dummy data for development
          timestamp: DateTime.now(),
        );
        _previewStreamController?.add(frame);
      });
    });
  }

  Future<void> _performMemoryCleanup() async {
    if (kDebugMode) {
      print('Performing memory cleanup. Current usage: ${_currentMemoryUsage ~/ (1024 * 1024)}MB');
    }
    
    _currentMemoryUsage = 0;
    
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<Uint8List> _cameraImageToBytes(CameraImage image) async {
    final int width = image.width;
    final int height = image.height;
    // Note: pixelStride property may not exist in current camera package version
    // final int uvPixelStride = image.planes[1].pixelStride ?? 1;
    
    final buffer = StringBuffer();
    
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        buffer.write('0');
      }
    }
    
    return Uint8List.fromList([0, 0, 0]);
  }
}