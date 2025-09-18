import 'dart:typed_data';

/// Platform-agnostic camera frame representation
class CameraFrame {
  final Uint8List imageData;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  CameraFrame({
    required this.imageData,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create a CameraFrame from raw image bytes
  static Future<CameraFrame> fromBytes(
    Uint8List bytes, {
    Map<String, dynamic>? metadata,
  }) async {
    return CameraFrame(
      imageData: bytes,
      metadata: metadata,
    );
  }

  /// Check if frame contains valid image data
  bool get hasValidData => imageData.isNotEmpty;

  /// Get size in bytes
  int get sizeInBytes => imageData.length;
}