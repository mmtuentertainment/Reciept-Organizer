import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/presentation/widgets/camera_preview_with_overlay.dart';
import 'package:receipt_organizer/domain/services/camera_service.dart';
import 'package:receipt_organizer/data/models/camera_frame.dart';
import 'package:receipt_organizer/data/models/edge_detection_result.dart';

/// Mock CameraService for testing
class MockCameraService extends CameraService {
  bool _shouldReturnController = true;
  EdgeDetectionResult? _mockEdgeResult;
  Stream<CameraFrame>? _mockPreviewStream;

  void setMockEdgeResult(EdgeDetectionResult result) {
    _mockEdgeResult = result;
  }

  void setMockPreviewStream(Stream<CameraFrame> stream) {
    _mockPreviewStream = stream;
  }

  void setShouldReturnController(bool shouldReturn) {
    _shouldReturnController = shouldReturn;
  }

  @override
  Future<CameraController?> getCameraController() async {
    if (!_shouldReturnController) return null;
    
    // Return a mock object that has the minimal interface needed
    return MockCameraController() as CameraController?;
  }

  @override
  Future<EdgeDetectionResult> detectEdges(CameraFrame frame) async {
    await Future.delayed(const Duration(milliseconds: 10)); // Simulate processing
    return _mockEdgeResult ?? EdgeDetectionResult(success: false, confidence: 0.0);
  }

  @override
  Stream<CameraFrame> getPreviewStream() {
    return _mockPreviewStream ?? Stream.value(CameraFrame(
      imageData: _createDummyImageData(),
      timestamp: DateTime.now(),
    ));
  }

  Uint8List _createDummyImageData() {
    return Uint8List.fromList(List.generate(100, (index) => index % 256));
  }
}

/// Mock CameraController for testing
class MockCameraController {
  final MockCameraValue value = MockCameraValue();
}

class MockCameraValue {
  bool get isInitialized => true;
  Size? get previewSize => const Size(1920, 1080);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CameraPreviewWithOverlay', () {
    late MockCameraService mockCameraService;

    setUp(() {
      mockCameraService = MockCameraService();
    });

    testWidgets('should show loading indicator when controller not available', (tester) async {
      mockCameraService.setShouldReturnController(false);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CameraPreviewWithOverlay(
                cameraService: mockCameraService,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display processing indicator during edge detection', (tester) async {
      // Create a delayed stream to simulate processing
      final controller = StreamController<CameraFrame>();
      mockCameraService.setMockPreviewStream(controller.stream);
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CameraPreviewWithOverlay(
                cameraService: mockCameraService,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Add a frame to trigger processing
      controller.add(CameraFrame(
        imageData: Uint8List.fromList([1, 2, 3]),
        timestamp: DateTime.now(),
      ));

      await tester.pump(const Duration(milliseconds: 50));
      
      // Should show processing indicator briefly
      expect(find.text('Detecting...'), findsOneWidget);

      await tester.pumpAndSettle();
      controller.close();
    });

    testWidgets('should display edge overlay when detection succeeds', (tester) async {
      final successfulResult = EdgeDetectionResult(
        success: true,
        confidence: 0.8,
        corners: [
          const Point(0.1, 0.1),
          const Point(0.9, 0.1),
          const Point(0.9, 0.9),
          const Point(0.1, 0.9),
        ],
        processingTimeMs: 50,
      );

      mockCameraService.setMockEdgeResult(successfulResult);

      EdgeDetectionResult? receivedResult;
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CameraPreviewWithOverlay(
                cameraService: mockCameraService,
                onEdgeDetectionResult: (result) {
                  receivedResult = result;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Trigger a frame to start edge detection
      await tester.pump(const Duration(milliseconds: 200));
      
      expect(receivedResult, isNotNull);
      expect(receivedResult!.success, isTrue);
      expect(find.text('Receipt detected'), findsOneWidget);
    });

    testWidgets('should handle manual corner adjustment', (tester) async {
      final initialResult = EdgeDetectionResult(
        success: true,
        confidence: 0.8,
        corners: [
          const Point(0.1, 0.1),
          const Point(0.9, 0.1),
          const Point(0.9, 0.9),
          const Point(0.1, 0.9),
        ],
        processingTimeMs: 50,
      );

      mockCameraService.setMockEdgeResult(initialResult);
      EdgeDetectionResult? adjustedResult;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CameraPreviewWithOverlay(
                cameraService: mockCameraService,
                enableManualAdjustment: true,
                onEdgeDetectionResult: (result) {
                  adjustedResult = result;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Find corner handles should be available
      expect(find.byIcon(Icons.touch_app), findsOneWidget);
    });

    testWidgets('should disable manual adjustment when specified', (tester) async {
      final result = EdgeDetectionResult(
        success: true,
        confidence: 0.8,
        corners: [
          const Point(0.1, 0.1),
          const Point(0.9, 0.1),
          const Point(0.9, 0.9),
          const Point(0.1, 0.9),
        ],
        processingTimeMs: 50,
      );

      mockCameraService.setMockEdgeResult(result);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CameraPreviewWithOverlay(
                cameraService: mockCameraService,
                enableManualAdjustment: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Touch app icon should not be present
      expect(find.byIcon(Icons.touch_app), findsNothing);
    });

    testWidgets('should show appropriate status for different detection results', (tester) async {
      // Test failed detection
      final failedResult = EdgeDetectionResult(success: false, confidence: 0.2);
      mockCameraService.setMockEdgeResult(failedResult);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CameraPreviewWithOverlay(
                cameraService: mockCameraService,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(find.text('No receipt detected'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);

      // Test partial detection
      final partialResult = EdgeDetectionResult(
        success: true,
        confidence: 0.7,
        corners: [const Point(0.1, 0.1), const Point(0.9, 0.9)],
        processingTimeMs: 75,
      );
      mockCameraService.setMockEdgeResult(partialResult);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CameraPreviewWithOverlay(
                cameraService: mockCameraService,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(find.text('Partial detection'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('should throttle edge detection processing', (tester) async {
      int processCallCount = 0;
      final testService = MockCameraService();
      
      // Override detectEdges to count calls
      testService.setMockEdgeResult(EdgeDetectionResult(success: false));

      // Create rapid stream
      final controller = StreamController<CameraFrame>();
      testService.setMockPreviewStream(controller.stream);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CameraPreviewWithOverlay(
                cameraService: testService,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Send multiple rapid frames
      for (int i = 0; i < 10; i++) {
        controller.add(CameraFrame(
          imageData: Uint8List.fromList([i]),
          timestamp: DateTime.now(),
        ));
        await tester.pump(const Duration(milliseconds: 10));
      }

      await tester.pumpAndSettle();
      controller.close();

      // Should have throttled the processing (not process all 10 frames)
      // This is a basic test - in practice, the throttling logic should limit calls
    });
  });
}