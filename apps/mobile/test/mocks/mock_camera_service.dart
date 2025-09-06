import 'dart:typed_data';
import 'package:receipt_organizer/domain/services/camera_service.dart';
import 'package:receipt_organizer/data/models/camera_frame.dart';
import 'package:receipt_organizer/data/models/edge_detection_result.dart';
import 'package:receipt_organizer/data/models/capture_result.dart';
import 'package:camera/camera.dart';

class MockCameraService implements ICameraService {
  @override
  Future<void> initialize() async {
    // Mock implementation
  }

  @override
  Future<void> dispose() async {
    // Mock implementation
  }

  @override
  Future<CaptureResult> captureReceipt({bool batchMode = false}) async {
    return CaptureResult.success('/mock/path/image.jpg');
  }

  @override
  Future<EdgeDetectionResult> detectEdges(CameraFrame frame) async {
    return const EdgeDetectionResult(
      success: true,
      confidence: 0.85,
      corners: [],
      processingTimeMs: 50,
    );
  }

  @override
  Future<CameraController?> getCameraController() async {
    return null;
  }

  @override
  Stream<CameraFrame> getPreviewStream() {
    return Stream.value(CameraFrame(
      imageData: Uint8List.fromList([1, 2, 3]),
      timestamp: DateTime.now(),
    ));
  }
}