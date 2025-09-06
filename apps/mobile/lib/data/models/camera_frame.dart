import 'dart:typed_data';
import 'package:camera/camera.dart';

class CameraFrame {
  final CameraImage? image;
  final Uint8List imageData;
  final DateTime timestamp;

  CameraFrame({
    this.image,
    required this.imageData,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create a CameraFrame from CameraImage (converts to JPEG bytes)
  static Future<CameraFrame> fromCameraImage(CameraImage image) async {
    // Convert CameraImage to JPEG bytes
    final imageData = await _convertCameraImageToJpeg(image);
    return CameraFrame(
      image: image,
      imageData: imageData,
    );
  }

  /// Convert CameraImage to JPEG bytes
  static Future<Uint8List> _convertCameraImageToJpeg(CameraImage image) async {
    // For development purposes, return dummy data
    // In production, this would convert the YUV420 or NV21 format to JPEG
    return Uint8List.fromList(List.generate(1000, (index) => index % 256));
  }
}