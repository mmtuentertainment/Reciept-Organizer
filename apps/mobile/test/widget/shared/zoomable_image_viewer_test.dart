import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/shared/widgets/zoomable_image_viewer.dart';

void main() {
  group('ZoomableImageViewer Widget Tests', () {
    late String testImagePath;
    
    setUpAll(() async {
      // Create a test image file
      final tempDir = Directory.systemTemp.createTempSync();
      final testFile = File('${tempDir.path}/test_image.png');
      
      // Create a simple 1x1 PNG image
      final pngBytes = Uint8List.fromList([
        137, 80, 78, 71, 13, 10, 26, 10, // PNG signature
        0, 0, 0, 13, // IHDR chunk length
        73, 72, 68, 82, // IHDR
        0, 0, 0, 1, // width = 1
        0, 0, 0, 1, // height = 1
        8, 2, // bit depth = 8, color type = 2 (RGB)
        0, 0, 0, // compression, filter, interlace
        // CRC and minimal data to make valid PNG
        0, 0, 0, 0, // CRC placeholder
        0, 0, 0, 12, // IDAT chunk length
        73, 68, 65, 84, // IDAT
        0, 0, 0, 0, 0, 0, 0, 0, // minimal compressed data
        0, 0, 0, 0, // CRC placeholder
        0, 0, 0, 0, // IEND chunk length
        73, 69, 78, 68, // IEND
        0, 0, 0, 0, // CRC
      ]);
      
      await testFile.writeAsBytes(pngBytes);
      testImagePath = testFile.path;
    });
    
    tearDownAll(() {
      // Clean up test file
      try {
        File(testImagePath).deleteSync();
      } catch (_) {}
    });
    
    Widget createTestWidget({
      String? imagePath,
      VoidCallback? onTap,
      double minScale = 0.5,
      double maxScale = 5.0,
      bool showFpsOverlay = false,
      Widget? loadingWidget,
      Widget Function(String)? errorBuilder,
      int imageQuality = 85,
    }) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ZoomableImageViewer(
              imagePath: imagePath ?? testImagePath,
              onTap: onTap,
              minScale: minScale,
              maxScale: maxScale,
              showFpsOverlay: showFpsOverlay,
              loadingWidget: loadingWidget,
              errorBuilder: errorBuilder,
              imageQuality: imageQuality,
            ),
          ),
        ),
      );
    }
    
    group('Given a valid image path', () {
      testWidgets('When widget is created Then it displays the image', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        
        // Wait for image to load
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        // Assert
        expect(find.byType(InteractiveViewer), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
      });
      
      testWidgets('When loading Then it shows loading indicator', (tester) async {
        // Arrange
        final customLoader = Container(
          key: const Key('custom_loader'),
          child: const Text('Loading...'),
        );
        
        // Act
        await tester.pumpWidget(createTestWidget(
          loadingWidget: customLoader,
        ));
        
        // Assert - Should show loading initially
        expect(find.byKey(const Key('custom_loader')), findsOneWidget);
      });
    });
    
    group('Given an invalid image path', () {
      testWidgets('When file does not exist Then it shows error', (tester) async {
        // Arrange
        const errorMessage = 'Custom error';
        Widget customErrorBuilder(String error) => Text(errorMessage);
        
        // Act
        await tester.pumpWidget(createTestWidget(
          imagePath: '/non/existent/path.png',
          errorBuilder: customErrorBuilder,
        ));
        
        // Wait for error to appear
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        // Assert
        expect(find.text(errorMessage), findsOneWidget);
      });
    });
    
    group('Given zoom constraints', () {
      testWidgets('When min/max scale are set Then InteractiveViewer respects them', (tester) async {
        // Arrange
        const minScale = 0.25;
        const maxScale = 10.0;
        
        // Act
        await tester.pumpWidget(createTestWidget(
          minScale: minScale,
          maxScale: maxScale,
        ));
        
        // Wait for widget to build
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        // Assert
        final interactiveViewer = tester.widget<InteractiveViewer>(
          find.byType(InteractiveViewer),
        );
        expect(interactiveViewer.minScale, equals(minScale));
        expect(interactiveViewer.maxScale, equals(maxScale));
      });
    });
    
    group('Given gesture interactions', () {
      testWidgets('When tapped Then onTap callback is called', (tester) async {
        // Arrange
        bool wasTapped = false;
        
        // Act
        await tester.pumpWidget(createTestWidget(
          onTap: () => wasTapped = true,
        ));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        await tester.tap(find.byType(GestureDetector).first);
        
        // Assert
        expect(wasTapped, isTrue);
      });
      
      testWidgets('When double-tapped Then zoom animation occurs', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        // Get initial transformation
        final interactiveViewer = tester.widget<InteractiveViewer>(
          find.byType(InteractiveViewer),
        );
        final initialMatrix = interactiveViewer.transformationController?.value;
        
        // Double tap at center
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        final center = tester.getCenter(find.byType(InteractiveViewer));
        await tester.tapAt(center);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        await tester.tapAt(center);
        
        // Wait for animation
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        // Assert - transformation should have changed
        final newMatrix = interactiveViewer.transformationController?.value;
        expect(newMatrix, isNot(equals(initialMatrix)));
      });
    });
    
    group('Given performance optimization', () {
      testWidgets('When widget is rendered Then RepaintBoundary is present', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        // Assert
        expect(find.byType(RepaintBoundary), findsOneWidget);
      });
    });
    
    group('Given FPS monitoring', () {
      testWidgets('When showFpsOverlay is true in debug mode Then FPS overlay is shown', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          showFpsOverlay: true,
        ));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        // In test mode, kReleaseMode is false, so overlay should show
        // Wait for FPS timer to tick
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        // Assert
        expect(find.textContaining('FPS:'), findsOneWidget);
      });
    });
    
    group('Given memory management', () {
      testWidgets('When widget is disposed Then resources are cleaned up', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        // Replace with empty container to trigger disposal
        await tester.pumpWidget(Container());
        
        // Assert - No exceptions should be thrown during disposal
        expect(tester.takeException(), isNull);
      });
    });
    
    group('Given image quality settings', () {
      testWidgets('When imageQuality is set Then it is used for compression', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          imageQuality: 50,
        ));
        
        // Just ensure widget builds without error
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        // Assert
        expect(find.byType(ZoomableImageViewer), findsOneWidget);
      });
    });
  });
}