import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receipt_organizer/shared/widgets/zoomable_image_viewer.dart';
import 'package:receipt_organizer/shared/utils/performance_monitor.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Image Viewer Performance Tests', () {
    final performanceMonitor = PerformanceMonitor();
    
    // Generate test images of various sizes
    Future<String> generateTestImage(int sizeInMb) async {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/test_${sizeInMb}mb.png');
      
      // Generate a simple PNG of approximate size
      // final width = 1000 * math.sqrt(sizeInMb).toInt();
      // final height = 1000 * math.sqrt(sizeInMb).toInt();
      
      // Create a simple image data (this is a placeholder)
      // In a real test, you'd generate actual image data
      final data = Uint8List(sizeInMb * 1024 * 1024);
      await file.writeAsBytes(data);
      
      return file.path;
    }
    
    Widget createTestApp(String imagePath) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ZoomableImageViewer(
              imagePath: imagePath,
              showFpsOverlay: true,
            ),
          ),
        ),
      );
    }
    
    testWidgets('1MB image maintains 60 FPS during zoom/pan', (tester) async {
      // Arrange
      final imagePath = await generateTestImage(1);
      performanceMonitor.startMonitoring();
      
      // Act
      await tester.pumpWidget(createTestApp(imagePath));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Start gesture monitoring
      performanceMonitor.recordGestureStart('zoom_1mb');
      
      // Perform pinch zoom
      final center = tester.getCenter(find.byType(ZoomableImageViewer));
      final pointer1 = await tester.startGesture(center - const Offset(50, 0));
      final pointer2 = await tester.startGesture(center + const Offset(50, 0));
      
      // Zoom in
      await pointer1.moveBy(const Offset(-50, 0));
      await pointer2.moveBy(const Offset(50, 0));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Pan around
      await pointer1.moveBy(const Offset(100, 100));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      await pointer1.up();
      await pointer2.up();
      
      performanceMonitor.recordGestureEnd('zoom_1mb');
      
      // Wait for metrics
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Assert
      final metrics = performanceMonitor.getMetrics();
      expect(metrics.currentFps, greaterThanOrEqualTo(55.0));
      expect(metrics.averageGestureResponseMs, lessThan(16.0));
      
      // Cleanup
      performanceMonitor.stopMonitoring();
      File(imagePath).deleteSync();
    });
    
    testWidgets('5MB image maintains acceptable FPS', (tester) async {
      // Arrange
      final imagePath = await generateTestImage(5);
      performanceMonitor.startMonitoring();
      
      // Act
      await tester.pumpWidget(createTestApp(imagePath));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      performanceMonitor.recordGestureStart('zoom_5mb');
      
      // Perform double tap zoom
      // final center = tester.getCenter(find.byType(ZoomableImageViewer));
      await tester.tap(find.byType(ZoomableImageViewer));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      await tester.tap(find.byType(ZoomableImageViewer));
      
      performanceMonitor.recordGestureEnd('zoom_5mb');
      
      // Wait for animation and metrics
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Assert
      final metrics = performanceMonitor.getMetrics();
      expect(metrics.averageFps, greaterThanOrEqualTo(50.0));
      
      // Cleanup
      performanceMonitor.stopMonitoring();
      File(imagePath).deleteSync();
    });
    
    testWidgets('10MB image with progressive loading', (tester) async {
      // Arrange
      final imagePath = await generateTestImage(10);
      performanceMonitor.startMonitoring();
      
      // Act
      await tester.pumpWidget(createTestApp(imagePath));
      
      // Initial load should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for progressive loading
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Should show low quality version first
      expect(find.byType(Image), findsOneWidget);
      
      // Wait for full quality
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Test gesture performance
      performanceMonitor.recordGestureStart('pan_10mb');
      
      final gesture = await tester.startGesture(tester.getCenter(find.byType(ZoomableImageViewer)));
      await gesture.moveBy(const Offset(100, 0));
      await gesture.up();
      
      performanceMonitor.recordGestureEnd('pan_10mb');
      
      // Assert
      final metrics = performanceMonitor.getMetrics();
      expect(metrics.isPerformant, isTrue);
      
      // Cleanup
      performanceMonitor.stopMonitoring();
      File(imagePath).deleteSync();
    });
    
    testWidgets('Memory is properly released on disposal', (tester) async {
      // Arrange
      final imagePath = await generateTestImage(5);
      performanceMonitor.startMonitoring();
      
      // Act - Load image
      await tester.pumpWidget(createTestApp(imagePath));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Record initial memory
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      final initialMetrics = performanceMonitor.getMetrics();
      final initialMemory = initialMetrics.currentMemoryMb;
      
      // Navigate away to dispose widget
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Force garbage collection (in real app)
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Check memory after disposal
      final finalMetrics = performanceMonitor.getMetrics();
      final memoryDiff = finalMetrics.currentMemoryMb - initialMemory;
      
      // Assert - Memory should be released (allow some variance)
      expect(memoryDiff, lessThan(1.0)); // Less than 1MB increase
      
      // Cleanup
      performanceMonitor.stopMonitoring();
      File(imagePath).deleteSync();
    });
    
    testWidgets('Rapid zoom gestures maintain responsiveness', (tester) async {
      // Arrange
      final imagePath = await generateTestImage(2);
      performanceMonitor.startMonitoring();
      
      await tester.pumpWidget(createTestApp(imagePath));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Act - Perform rapid zoom in/out
      for (int i = 0; i < 5; i++) {
        performanceMonitor.recordGestureStart('rapid_zoom_$i');
        
        // Double tap to zoom in
        await tester.tap(find.byType(ZoomableImageViewer));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        await tester.tap(find.byType(ZoomableImageViewer));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        // Double tap to zoom out
        await tester.tap(find.byType(ZoomableImageViewer));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        await tester.tap(find.byType(ZoomableImageViewer));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        performanceMonitor.recordGestureEnd('rapid_zoom_$i');
      }
      
      // Assert
      final metrics = performanceMonitor.getMetrics();
      expect(metrics.maxGestureResponseMs, lessThan(20.0));
      expect(metrics.minFps, greaterThanOrEqualTo(45.0));
      
      // Cleanup
      performanceMonitor.stopMonitoring();
      File(imagePath).deleteSync();
    });
  });
}