import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/domain/services/camera_service.dart';
import 'package:receipt_organizer/data/models/camera_frame.dart';
import 'package:receipt_organizer/data/models/edge_detection_result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('CameraService Edge Detection Integration', () {
    late CameraService service;

    setUp(() async {
      service = CameraService();
      await service.initialize();
    });

    tearDown(() async {
      await service.dispose();
    });

    test('should integrate with edge detection service', () async {
      // Arrange
      final frame = CameraFrame(
        imageData: _createDummyImageData(),
      );

      // Act
      final result = await service.detectEdges(frame);

      // Assert
      expect(result, isA<EdgeDetectionResult>());
      expect(result.confidence, greaterThanOrEqualTo(0.0));
      expect(result.confidence, lessThanOrEqualTo(1.0));
    });

    test('should return failure when not initialized', () async {
      // Arrange
      final uninitializedService = CameraService();
      final frame = CameraFrame(
        imageData: _createDummyImageData(),
      );

      // Act
      final result = await uninitializedService.detectEdges(frame);

      // Assert
      expect(result.success, isFalse);
      expect(result.confidence, equals(0.0));
    });

    test('should handle edge detection in preview stream context', () async {
      // Arrange
      final previewStream = service.getPreviewStream();
      
      // Act - get a frame from preview stream and detect edges
      final frame = await previewStream.first;
      final result = await service.detectEdges(frame);

      // Assert
      expect(result, isNotNull);
      expect(frame.imageData, isNotEmpty);
    });

    test('should maintain performance during continuous edge detection', () async {
      // Arrange
      final frames = <CameraFrame>[];
      final previewStream = service.getPreviewStream();
      
      // Collect some frames
      await for (final frame in previewStream.take(3)) {
        frames.add(frame);
      }

      // Act - detect edges on all frames
      final stopwatch = Stopwatch()..start();
      final results = await Future.wait(
        frames.map((frame) => service.detectEdges(frame)),
      );
      stopwatch.stop();

      // Assert
      expect(results.length, equals(3));
      // Average processing time should meet requirements
      final avgTimePerFrame = stopwatch.elapsedMilliseconds / frames.length;
      expect(avgTimePerFrame, lessThan(100)); // 100ms requirement
    });

    test('should handle concurrent preview and edge detection', () async {
      // Arrange
      final previewStream = service.getPreviewStream();
      
      // Act - start preview stream and perform edge detection concurrently
      final previewFuture = previewStream.take(2).toList();
      final frame = CameraFrame(imageData: _createDummyImageData());
      final edgeDetectionFuture = service.detectEdges(frame);
      
      final results = await Future.wait([previewFuture, edgeDetectionFuture]);

      // Assert
      final previewFrames = results[0] as List<CameraFrame>;
      final edgeResult = results[1] as EdgeDetectionResult;
      
      expect(previewFrames.length, equals(2));
      expect(edgeResult, isNotNull);
    });

    group('real-time processing simulation', () {
      test('should simulate 10fps edge detection processing', () async {
        // Arrange - simulate processing every 3rd frame (10fps from 30fps camera)
        final frames = <CameraFrame>[];
        int frameCount = 0;
        
        // Collect frames from preview stream
        await for (final frame in service.getPreviewStream().take(9)) {
          frames.add(frame);
        }

        // Act - process every 3rd frame (simulating 10fps processing)
        final results = <EdgeDetectionResult>[];
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < frames.length; i += 3) {
          final result = await service.detectEdges(frames[i]);
          results.add(result);
        }
        
        stopwatch.stop();

        // Assert
        expect(results.length, equals(3)); // 3 processed frames from 9 total
        
        // Average processing time should meet real-time requirements
        final avgProcessingTime = stopwatch.elapsedMilliseconds / results.length;
        expect(avgProcessingTime, lessThan(100)); // 100ms per frame requirement
      });

      test('should handle frame dropping under load', () async {
        // Arrange
        final frames = List.generate(10, (_) => CameraFrame(
          imageData: _createDummyImageData(),
        ));

        // Act - process frames with simulated processing delay
        final results = <EdgeDetectionResult>[];
        final stopwatch = Stopwatch()..start();
        
        for (final frame in frames) {
          // Only process if we can maintain 10fps (100ms budget)
          if (stopwatch.elapsedMilliseconds < results.length * 100) {
            final result = await service.detectEdges(frame);
            results.add(result);
          }
        }
        
        stopwatch.stop();

        // Assert - should have processed some frames within time budget
        expect(results.isNotEmpty, isTrue);
        
        // Verify we maintained timing constraints
        final totalTimeMs = stopwatch.elapsedMilliseconds;
        final expectedMaxTime = results.length * 100; // 100ms per processed frame
        expect(totalTimeMs, lessThanOrEqualTo(expectedMaxTime * 1.1)); // 10% tolerance
      });
    });
  });
}

/// Create dummy image data for testing
Uint8List _createDummyImageData() {
  final data = List<int>.generate(1000, (index) {
    final x = index % 100;
    final y = index ~/ 100;
    return ((x + y) * 50) % 256;
  });
  return Uint8List.fromList(data);
}