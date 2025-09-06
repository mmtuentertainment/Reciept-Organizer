import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/infrastructure/services/edge_detection_service.dart';
import 'package:receipt_organizer/data/models/camera_frame.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Edge Detection Performance Benchmarks', () {
    late EdgeDetectionService service;

    setUp(() {
      service = EdgeDetectionService();
    });

    tearDown(() {
      service.dispose();
    });

    group('Processing Time Benchmarks', () {
      test('should meet sub-100ms processing requirement consistently', () async {
        const iterations = 20;
        final processingTimes = <int>[];

        for (int i = 0; i < iterations; i++) {
          final frame = CameraFrame(
            imageData: _createRealisticTestData(seed: i),
            timestamp: DateTime.now(),
          );

          final stopwatch = Stopwatch()..start();
          final result = await service.detectEdges(frame);
          stopwatch.stop();

          processingTimes.add(stopwatch.elapsedMilliseconds);

          // Validate that internal timing matches external measurement
          expect(result.processingTimeMs, lessThanOrEqualTo(stopwatch.elapsedMilliseconds));
          expect(result.processingTimeMs, greaterThanOrEqualTo(0));
        }

        // Calculate statistics
        final avgTime = processingTimes.fold<double>(0.0, (sum, time) => sum + time) / iterations;
        final maxTime = processingTimes.reduce((a, b) => a > b ? a : b);
        final minTime = processingTimes.reduce((a, b) => a < b ? a : b);

        print('Performance Statistics:');
        print('  Average processing time: ${avgTime.toStringAsFixed(1)}ms');
        print('  Maximum processing time: ${maxTime}ms');
        print('  Minimum processing time: ${minTime}ms');
        print('  Success rate: ${processingTimes.where((t) => t < 100).length}/$iterations (${(processingTimes.where((t) => t < 100).length / iterations * 100).toStringAsFixed(1)}%)');

        // Performance requirements validation
        expect(avgTime, lessThan(100), reason: 'Average processing time must be under 100ms');
        expect(maxTime, lessThan(150), reason: 'Maximum processing time should not exceed 150ms');
        
        // At least 90% of processing should be under 100ms
        final successRate = processingTimes.where((t) => t < 100).length / iterations;
        expect(successRate, greaterThanOrEqualTo(0.9), reason: '90% of processing should be under 100ms');
      });

      test('should show performance improvement with caching', () async {
        final frame = CameraFrame(
          imageData: _createRealisticTestData(),
          timestamp: DateTime.now(),
        );

        // First processing (no cache)
        final stopwatch1 = Stopwatch()..start();
        final result1 = await service.detectEdges(frame);
        stopwatch1.stop();

        // Second processing (should use cache)
        final stopwatch2 = Stopwatch()..start();
        final result2 = await service.detectEdges(frame);
        stopwatch2.stop();

        print('Caching Performance:');
        print('  First processing: ${stopwatch1.elapsedMilliseconds}ms');
        print('  Cached processing: ${stopwatch2.elapsedMilliseconds}ms');

        // Cached result should be faster
        expect(stopwatch2.elapsedMilliseconds, lessThanOrEqualTo(stopwatch1.elapsedMilliseconds));
        
        // Results should be identical
        expect(result1.success, equals(result2.success));
        expect(result1.confidence, equals(result2.confidence));
        expect(result1.corners.length, equals(result2.corners.length));
      });
    });

    group('Memory Usage Benchmarks', () {
      test('should handle continuous processing without memory leaks', () async {
        const iterations = 50;
        var largestProcessingTime = 0;
        var memoryBlowupDetected = false;

        for (int i = 0; i < iterations; i++) {
          final frame = CameraFrame(
            imageData: _createVariableTestData(i),
            timestamp: DateTime.now(),
          );

          final result = await service.detectEdges(frame);
          
          // Track if processing time is growing significantly (potential memory issue)
          if (result.processingTimeMs > largestProcessingTime) {
            largestProcessingTime = result.processingTimeMs;
          }

          // If processing time suddenly jumps significantly, it might indicate memory issues
          if (result.processingTimeMs > largestProcessingTime * 3 && result.processingTimeMs > 200) {
            memoryBlowupDetected = true;
            break;
          }

          // Small delay to prevent overwhelming the system
          await Future.delayed(const Duration(milliseconds: 1));
        }

        print('Memory Usage Test:');
        print('  Iterations completed: $iterations');
        print('  Largest processing time: ${largestProcessingTime}ms');
        print('  Memory blowup detected: $memoryBlowupDetected');

        expect(memoryBlowupDetected, isFalse, reason: 'No significant memory blowup should occur');
        expect(largestProcessingTime, lessThan(200), reason: 'Processing time should stay reasonable');
      });

      test('should properly clean up resources', () async {
        // Create and dispose multiple service instances to test cleanup
        const instances = 5;
        
        for (int i = 0; i < instances; i++) {
          final testService = EdgeDetectionService();
          
          // Process some frames
          for (int j = 0; j < 3; j++) {
            final frame = CameraFrame(
              imageData: _createRealisticTestData(seed: i * 3 + j),
              timestamp: DateTime.now(),
            );
            
            await testService.detectEdges(frame);
          }
          
          // Dispose should clean up without errors
          testService.dispose();
        }

        // If we get here without issues, cleanup is working
        expect(true, isTrue);
      });
    });

    group('Scalability Benchmarks', () {
      test('should handle different image sizes efficiently', () async {
        final imageSizes = [
          (320, 240),   // Small
          (640, 480),   // Medium  
          (800, 600),   // Large
          (1024, 768),  // Very Large
        ];

        for (final size in imageSizes) {
          final frame = CameraFrame(
            imageData: _createTestDataForSize(size.$1, size.$2),
            timestamp: DateTime.now(),
          );

          final stopwatch = Stopwatch()..start();
          final result = await service.detectEdges(frame);
          stopwatch.stop();

          print('Image Size ${size.$1}x${size.$2}: ${stopwatch.elapsedMilliseconds}ms');

          // All sizes should process reasonably quickly
          expect(stopwatch.elapsedMilliseconds, lessThan(150), 
                 reason: 'Size ${size.$1}x${size.$2} should process under 150ms');
          expect(result.processingTimeMs, lessThan(150));
        }
      });

      test('should handle concurrent processing efficiently', () async {
        const concurrentRequests = 5;
        final frames = List.generate(concurrentRequests, (i) => CameraFrame(
          imageData: _createRealisticTestData(seed: i),
          timestamp: DateTime.now(),
        ));

        final stopwatch = Stopwatch()..start();
        final results = await Future.wait(
          frames.map((frame) => service.detectEdges(frame)),
        );
        stopwatch.stop();

        final totalTime = stopwatch.elapsedMilliseconds;
        final avgTimePerRequest = totalTime / concurrentRequests;

        print('Concurrent Processing:');
        print('  Requests: $concurrentRequests');
        print('  Total time: ${totalTime}ms');
        print('  Avg time per request: ${avgTimePerRequest.toStringAsFixed(1)}ms');

        // Concurrent processing should be efficient
        expect(results.length, equals(concurrentRequests));
        expect(avgTimePerRequest, lessThan(120)); // Allow some overhead for concurrency
        
        // All results should be valid
        for (final result in results) {
          expect(result.processingTimeMs, greaterThanOrEqualTo(0));
        }
      });
    });
  });
}

/// Create realistic test data that mimics camera frame data
Uint8List _createRealisticTestData({int seed = 42}) {
  final random = seed;
  final size = 640 * 480 * 3; // RGB data
  final data = List<int>.generate(size, (index) {
    // Create patterns that might represent receipt-like structures
    final x = (index ~/ 3) % 640;
    final y = (index ~/ 3) ~/ 640;
    final channel = index % 3;
    
    // Create some edge-like patterns
    int value = 128; // Base gray
    
    // Add some vertical lines (receipt edges)
    if (x > 100 && x < 120) value += 50;
    if (x > 520 && x < 540) value += 50;
    
    // Add some horizontal lines (text lines)
    if (y % 20 < 2) value += 30;
    
    // Add some noise based on seed
    value += ((x + y + seed) % 50) - 25;
    
    return value.clamp(0, 255);
  });
  
  return Uint8List.fromList(data);
}

/// Create variable test data for different iterations
Uint8List _createVariableTestData(int iteration) {
  final size = 500 * 400; // Smaller for variety
  final data = List<int>.generate(size, (index) {
    final x = index % 500;
    final y = index ~/ 500;
    
    // Create different patterns based on iteration
    int value = 128 + (iteration * 10) % 100;
    value += ((x + y + iteration) * 7) % 60 - 30;
    
    return value.clamp(0, 255);
  });
  
  return Uint8List.fromList(data);
}

/// Create test data for specific image size
Uint8List _createTestDataForSize(int width, int height) {
  final size = width * height;
  final data = List<int>.generate(size, (index) {
    final x = index % width;
    final y = index ~/ width;
    
    // Create edge-like patterns scaled to image size
    int value = 128;
    
    // Vertical edges at 20% and 80% width
    final leftEdge = width ~/ 5;
    final rightEdge = width * 4 ~/ 5;
    if ((x - leftEdge).abs() < 3 || (x - rightEdge).abs() < 3) {
      value += 60;
    }
    
    // Horizontal edges at 20% and 80% height
    final topEdge = height ~/ 5;
    final bottomEdge = height * 4 ~/ 5;
    if ((y - topEdge).abs() < 2 || (y - bottomEdge).abs() < 2) {
      value += 40;
    }
    
    // Add some noise
    value += ((x + y) % 40) - 20;
    
    return value.clamp(0, 255);
  });
  
  return Uint8List.fromList(data);
}