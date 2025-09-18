import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';

/// Platform-agnostic image capture interface
abstract class ImageCaptureService {
  /// Check if camera is available on this platform
  Future<bool> isCameraAvailable();

  /// Initialize the capture service
  Future<void> initialize();

  /// Capture a single image
  Future<CapturedImage?> captureImage();

  /// Capture multiple images (batch mode)
  Future<List<CapturedImage>> captureBatch({int? maxImages});

  /// Pick image from gallery/file system
  Future<CapturedImage?> pickImage();

  /// Pick multiple images from gallery
  Future<List<CapturedImage>> pickMultipleImages({int? maxImages});

  /// Get camera preview widget (returns Container on web)
  Widget getCameraPreview({
    required Function(CapturedImage) onImageCaptured,
    VoidCallback? onError,
  });

  /// Dispose resources
  Future<void> dispose();

  /// Platform identifier
  String get platform;
}

/// Cross-platform image data model
class CapturedImage {
  final String id;
  final Uint8List bytes;
  final String? path;
  final String mimeType;
  final DateTime capturedAt;
  final Map<String, dynamic>? metadata;

  CapturedImage({
    String? id,
    required this.bytes,
    this.path,
    this.mimeType = 'image/jpeg',
    DateTime? capturedAt,
    this.metadata,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        capturedAt = capturedAt ?? DateTime.now();

  /// File size in bytes
  int get sizeInBytes => bytes.length;

  /// File size in MB
  double get sizeInMB => sizeInBytes / (1024 * 1024);

  /// Check if image is from camera
  bool get isFromCamera => metadata?['source'] == 'camera';

  /// Convert to base64 for web storage
  String toBase64() {
    return base64Encode(bytes);
  }

  /// Create from base64 (for web storage)
  factory CapturedImage.fromBase64(String base64String, {String? id}) {
    return CapturedImage(
      id: id,
      bytes: base64Decode(base64String),
    );
  }
}

/// Camera configuration
class CameraConfig {
  final ResolutionPreset resolution;
  final bool enableAudio;
  final bool enableFlash;
  final CameraLensDirection? preferredLensDirection;

  const CameraConfig({
    this.resolution = ResolutionPreset.high,
    this.enableAudio = false,
    this.enableFlash = false,
    this.preferredLensDirection,
  });
}

/// Resolution presets (matching camera package for compatibility)
enum ResolutionPreset {
  low,
  medium,
  high,
  veryHigh,
  ultraHigh,
  max,
}

/// Camera lens direction
enum CameraLensDirection {
  front,
  back,
  external,
}