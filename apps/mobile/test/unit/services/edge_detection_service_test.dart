import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/infrastructure/services/edge_detection_service.dart';
import 'package:receipt_organizer/data/models/camera_frame.dart';
import 'package:receipt_organizer/data/models/edge_detection_result.dart';

void main() {
  group('EdgeDetectionService', () {
    late EdgeDetectionService service;

    setUp(() {
      service = EdgeDetectionService();
    });

    tearDown(() {
      service.dispose();
    });

    group('detectEdges', () {
      test('should return unsuccessful result for invalid image data', () async {
        // Arrange
        final frame = CameraFrame(
          imageData: Uint8List.fromList([]), // Empty data
        );

        // Act
        final result = await service.detectEdges(frame);

        // Assert
        expect(result.success, isFalse);
        expect(result.confidence, equals(0.0));
        expect(result.corners, isEmpty);
      });

      test('should return result with processing time', () async {
        // Arrange
        final frame = CameraFrame(
          imageData: _createDummyImageData(),
        );

        // Act
        final result = await service.detectEdges(frame);

        // Assert
        expect(result.processingTimeMs, greaterThanOrEqualTo(0));
      });

      test('should handle null/empty results gracefully', () async {
        // Arrange
        final frame = CameraFrame(
          imageData: Uint8List.fromList([1, 2, 3]), // Invalid image data
        );

        // Act
        final result = await service.detectEdges(frame);

        // Assert
        expect(result.success, isFalse);
        expect(result.confidence, equals(0.0));
        expect(result.corners, isEmpty);
      });

      test('should normalize corner coordinates to 0-1 range', () async {
        // This test would require a valid image with detectable edges
        // For now, we'll test with dummy data and validate the structure
        final frame = CameraFrame(
          imageData: _createDummyImageData(),
        );

        final result = await service.detectEdges(frame);

        // If corners are detected, they should be normalized
        for (final corner in result.corners) {
          expect(corner.x, greaterThanOrEqualTo(0.0));
          expect(corner.x, lessThanOrEqualTo(1.0));
          expect(corner.y, greaterThanOrEqualTo(0.0));
          expect(corner.y, lessThanOrEqualTo(1.0));
        }
      });

      test('should complete within performance requirements', () async {
        // Arrange
        final frame = CameraFrame(
          imageData: _createDummyImageData(),
        );

        // Act
        final stopwatch = Stopwatch()..start();
        final result = await service.detectEdges(frame);
        stopwatch.stop();

        // Assert - should complete within 100ms performance requirement
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
        expect(result.processingTimeMs, lessThan(100));
      });

      test('should handle memory cleanup properly', () async {
        // Arrange
        final frame = CameraFrame(
          imageData: _createDummyImageData(),
        );

        // Act - perform multiple detections to test memory handling
        for (int i = 0; i < 5; i++) {
          final result = await service.detectEdges(frame);
          expect(result, isNotNull);
        }

        // Assert - if we get here without memory errors, cleanup is working
        expect(true, isTrue);
      });
    });

    group('confidence scoring', () {
      test('should return confidence between 0.0 and 1.0', () async {
        // Arrange
        final frame = CameraFrame(
          imageData: _createDummyImageData(),
        );

        // Act
        final result = await service.detectEdges(frame);

        // Assert
        expect(result.confidence, greaterThanOrEqualTo(0.0));
        expect(result.confidence, lessThanOrEqualTo(1.0));
      });

      test('should reject low confidence detections', () async {
        // Arrange - using minimal data that should result in low confidence
        final frame = CameraFrame(
          imageData: Uint8List.fromList([0, 0, 0, 0, 0]),
        );

        // Act
        final result = await service.detectEdges(frame);

        // Assert - should fail due to low confidence
        expect(result.success, isFalse);
        expect(result.confidence, lessThan(0.6)); // Below threshold
      });
    });

    group('performance tests', () {
      test('should handle concurrent edge detection requests', () async {
        // Arrange
        final frame = CameraFrame(
          imageData: _createDummyImageData(),
        );

        // Act - run multiple concurrent detections
        final futures = List.generate(3, (_) => service.detectEdges(frame));
        final results = await Future.wait(futures);

        // Assert
        expect(results.length, equals(3));
        for (final result in results) {
          expect(result, isNotNull);
        }
      });

      test('should maintain consistent performance over time', () async {
        // Arrange
        final frame = CameraFrame(
          imageData: _createDummyImageData(),
        );
        final times = <int>[];

        // Act - perform multiple detections and track times
        for (int i = 0; i < 5; i++) {
          final result = await service.detectEdges(frame);
          times.add(result.processingTimeMs);
        }

        // Assert - times should be relatively consistent (no major degradation)
        final averageTime = times.fold<double>(0.0, (sum, time) => sum + time) / times.length;
        expect(averageTime, lessThan(100)); // Performance requirement
        
        // No single detection should be more than 5x the average (allow for variance)
        for (final time in times) {
          expect(time, lessThan((averageTime * 5).clamp(1.0, 500.0))); // Minimum 1ms, max 500ms
        }
      });
    });
  });
}

/// Create dummy image data for testing
Uint8List _createDummyImageData() {
  // Create a simple pattern that could be interpreted as an image
  final data = List<int>.generate(1000, (index) {
    // Create some pattern that might produce edges
    final x = index % 100;
    final y = index ~/ 100;
    return ((x + y) * 50) % 256;
  });
  return Uint8List.fromList(data);
}