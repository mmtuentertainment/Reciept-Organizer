import 'package:camera/camera.dart';

class CameraFrame {
  final CameraImage image;
  final DateTime timestamp;

  CameraFrame({
    required this.image,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}