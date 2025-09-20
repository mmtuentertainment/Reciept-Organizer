import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/core/platform/interfaces/image_capture.dart';
import 'package:receipt_organizer/features/capture/screens/camera_capture_screen.dart';

/// Mock implementation of ImageCaptureService for testing
class MockImageCaptureService implements ImageCaptureService {
  bool _isInitialized = false;
  bool _shouldFailInitialization = false;
  bool _shouldFailCapture = false;
  int _captureCount = 0;

  // Control methods for testing
  void setShouldFailInitialization(bool shouldFail) {
    _shouldFailInitialization = shouldFail;
  }

  void setShouldFailCapture(bool shouldFail) {
    _shouldFailCapture = shouldFail;
  }

  int get captureCount => _captureCount;

  @override
  String get platform => 'test';

  @override
  Future<bool> isCameraAvailable() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return !_shouldFailInitialization;
  }

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_shouldFailInitialization) {
      throw Exception('Mock camera initialization failed');
    }
    _isInitialized = true;
  }

  @override
  Future<CapturedImage?> captureImage() async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (_shouldFailCapture) {
      throw Exception('Mock capture failed');
    }
    if (!_isInitialized) {
      throw Exception('Camera not initialized');
    }

    _captureCount++;

    // Return mock image data
    return CapturedImage(
      id: 'mock_image_$_captureCount',
      bytes: Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7]),
      metadata: {
        'source': 'mock_camera',
        'captureNumber': _captureCount,
      },
    );
  }

  @override
  Future<List<CapturedImage>> captureBatch({int? maxImages}) async {
    final images = <CapturedImage>[];
    final count = maxImages ?? 3;

    for (int i = 0; i < count; i++) {
      final image = await captureImage();
      if (image != null) {
        images.add(image);
      }
    }

    return images;
  }

  @override
  Future<CapturedImage?> pickImage() async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (_shouldFailCapture) {
      return null;
    }

    return CapturedImage(
      id: 'picked_image_${DateTime.now().millisecondsSinceEpoch}',
      bytes: Uint8List.fromList([8, 9, 10, 11]),
      metadata: {
        'source': 'file_picker',
      },
    );
  }

  @override
  Future<List<CapturedImage>> pickMultipleImages({int? maxImages}) async {
    final images = <CapturedImage>[];
    final count = maxImages ?? 3;

    for (int i = 0; i < count; i++) {
      final image = await pickImage();
      if (image != null) {
        images.add(image);
      }
    }

    return images;
  }

  @override
  Widget getCameraPreview({
    required Function(CapturedImage) onImageCaptured,
    VoidCallback? onError,
  }) {
    if (_shouldFailInitialization) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Camera not available',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    // Return a mock camera preview widget
    return Container(
      key: const Key('mock_camera_preview'),
      color: Colors.black,
      child: Stack(
        children: [
          // Mock preview background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey.shade800,
                  Colors.grey.shade900,
                ],
              ),
            ),
          ),
          // Mock viewfinder
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt,
                  size: 100,
                  color: Colors.white30,
                ),
                SizedBox(height: 16),
                Text(
                  'Mock Camera Preview',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          // Mock capture button
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  try {
                    final image = await captureImage();
                    if (image != null) {
                      onImageCaptured(image);
                    }
                  } catch (e) {
                    onError?.call();
                  }
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera,
                    size: 40,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
    _captureCount = 0;
  }
}

/// Provider for mock image capture service in tests
class MockImageCaptureServiceNotifier extends ImageCaptureServiceNotifier {
  final MockImageCaptureService _mockService;

  MockImageCaptureServiceNotifier({MockImageCaptureService? service})
      : _mockService = service ?? MockImageCaptureService(),
        super();

  @override
  Future<void> initialize() async {
    state = const AsyncValue.loading();
    try {
      await _mockService.initialize();
      state = AsyncValue.data(_mockService);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  @override
  Future<CapturedImage?> captureImage() async {
    return await _mockService.captureImage();
  }

  MockImageCaptureService get mockService => _mockService;
}