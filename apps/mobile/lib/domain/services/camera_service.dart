import 'package:receipt_organizer/data/models/camera_frame.dart';
import 'package:receipt_organizer/data/models/capture_result.dart';
import 'package:receipt_organizer/data/models/edge_detection_result.dart';

abstract class ICameraService {
  Future<CaptureResult> captureReceipt({bool batchMode = false});
  Stream<CameraFrame> getPreviewStream();
  Future<EdgeDetectionResult> detectEdges(CameraFrame frame);
  Future<void> initialize();
  Future<void> dispose();
}

class CameraService implements ICameraService {
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
  }

  @override
  Future<CaptureResult> captureReceipt({bool batchMode = false}) async {
    if (!_isInitialized) {
      return CaptureResult.error('Camera not initialized', code: 'CAMERA_3001');
    }
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageUri = '/storage/receipts/receipt_$timestamp.jpg';
      
      return CaptureResult.success(imageUri);
    } catch (e) {
      return CaptureResult.error(
        'Failed to capture image: $e', 
        code: 'CAMERA_3002'
      );
    }
  }

  @override
  Future<EdgeDetectionResult> detectEdges(CameraFrame frame) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    return EdgeDetectionResult(
      success: true,
      confidence: 0.85,
      corners: const [
        Point(10, 10),
        Point(200, 10),
        Point(200, 300),
        Point(10, 300),
      ],
    );
  }

  @override
  Stream<CameraFrame> getPreviewStream() async* {
    while (_isInitialized) {
      await Future.delayed(const Duration(milliseconds: 33));
      yield CameraFrame(
        image: _createDummyCameraImage(),
        timestamp: DateTime.now(),
      );
    }
  }

  dynamic _createDummyCameraImage() {
    return null;
  }
}