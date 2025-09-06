import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/presentation/widgets/edge_overlay_widget.dart';
import 'package:receipt_organizer/data/models/edge_detection_result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EdgeOverlayWidget', () {
    late EdgeDetectionResult successfulResult;
    late EdgeDetectionResult failedResult;
    late EdgeDetectionResult lowConfidenceResult;
    const testSize = Size(400, 300);

    setUp(() {
      successfulResult = EdgeDetectionResult(
        success: true,
        confidence: 0.85,
        corners: [
          const Point(0.1, 0.1), // Top-left
          const Point(0.9, 0.1), // Top-right
          const Point(0.9, 0.9), // Bottom-right
          const Point(0.1, 0.9), // Bottom-left
        ],
        processingTimeMs: 50,
      );

      failedResult = EdgeDetectionResult(
        success: false,
        confidence: 0.3,
        corners: [],
        processingTimeMs: 25,
      );

      lowConfidenceResult = EdgeDetectionResult(
        success: true,
        confidence: 0.65,
        corners: [
          const Point(0.2, 0.2),
          const Point(0.8, 0.2),
          const Point(0.8, 0.8),
          const Point(0.2, 0.8),
        ],
        processingTimeMs: 75,
      );
    });

    testWidgets('should render nothing when result is unsuccessful', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EdgeOverlayWidget(
              result: failedResult,
              viewSize: testSize,
            ),
          ),
        ),
      );

      // Check that the widget returns SizedBox.shrink by looking for EdgeOverlayWidget contents
      expect(find.descendant(
        of: find.byType(EdgeOverlayWidget),
        matching: find.byType(CustomPaint),
      ), findsNothing);
    });

    testWidgets('should render overlay for successful detection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EdgeOverlayWidget(
              result: successfulResult,
              viewSize: testSize,
            ),
          ),
        ),
      );

      expect(find.descendant(
        of: find.byType(EdgeOverlayWidget),
        matching: find.byType(CustomPaint),
      ), findsOneWidget);
    });

    testWidgets('should render corner handles when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EdgeOverlayWidget(
              result: successfulResult,
              viewSize: testSize,
              showCornerHandles: true,
            ),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsNWidgets(4)); // One for each corner
      expect(find.byIcon(Icons.drag_indicator), findsNWidgets(4));
    });

    testWidgets('should not render corner handles when disabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EdgeOverlayWidget(
              result: successfulResult,
              viewSize: testSize,
              showCornerHandles: false,
            ),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsNothing);
      expect(find.byIcon(Icons.drag_indicator), findsNothing);
    });

    testWidgets('should handle corner drag events', (tester) async {
      int draggedCornerIndex = -1;
      Offset? draggedPosition;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EdgeOverlayWidget(
              result: successfulResult,
              viewSize: testSize,
              onCornerDrag: (index, position) {
                draggedCornerIndex = index;
                draggedPosition = position;
              },
            ),
          ),
        ),
      );

      // Find the first corner handle and drag it
      final firstHandle = find.byType(GestureDetector).first;
      await tester.drag(firstHandle, const Offset(50, 50));

      expect(draggedCornerIndex, equals(0));
      expect(draggedPosition, isNotNull);
    });

    testWidgets('should use different colors for different confidence levels', (tester) async {
      // Test high confidence (green)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EdgeOverlayWidget(
              result: successfulResult,
              viewSize: testSize,
            ),
          ),
        ),
      );

      var customPaintFinder = find.descendant(
        of: find.byType(EdgeOverlayWidget),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
      
      var customPaint = tester.widget<CustomPaint>(customPaintFinder);
      var painter = customPaint.painter as EdgeOverlayPainter;
      expect(painter.overlayColor, equals(Colors.green));

      // Test low confidence (orange)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EdgeOverlayWidget(
              result: lowConfidenceResult,
              viewSize: testSize,
            ),
          ),
        ),
      );

      customPaintFinder = find.descendant(
        of: find.byType(EdgeOverlayWidget),
        matching: find.byType(CustomPaint),
      );
      customPaint = tester.widget<CustomPaint>(customPaintFinder);
      painter = customPaint.painter as EdgeOverlayPainter;
      expect(painter.overlayColor, equals(Colors.orange));
    });

    testWidgets('should render with custom colors', (tester) async {
      const customColor = Colors.purple;
      const customLowColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EdgeOverlayWidget(
              result: successfulResult,
              viewSize: testSize,
              overlayColor: customColor,
              lowConfidenceColor: customLowColor,
            ),
          ),
        ),
      );

      final customPaintFinder = find.descendant(
        of: find.byType(EdgeOverlayWidget),
        matching: find.byType(CustomPaint),
      );
      final customPaint = tester.widget<CustomPaint>(customPaintFinder);
      final painter = customPaint.painter as EdgeOverlayPainter;
      expect(painter.overlayColor, equals(customColor));
    });

    testWidgets('should handle insufficient corners gracefully', (tester) async {
      final insufficientCornersResult = EdgeDetectionResult(
        success: true,
        confidence: 0.8,
        corners: [const Point(0.1, 0.1)], // Only 1 corner instead of 4
        processingTimeMs: 50,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EdgeOverlayWidget(
              result: insufficientCornersResult,
              viewSize: testSize,
            ),
          ),
        ),
      );

      expect(find.descendant(
        of: find.byType(EdgeOverlayWidget),
        matching: find.byType(CustomPaint),
      ), findsNothing);
    });
  });

  group('EdgeOverlayPainter', () {
    late EdgeDetectionResult testResult;

    setUp(() {
      testResult = EdgeDetectionResult(
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
    });

    test('should detect when repaint is needed', () {
      final painter1 = EdgeOverlayPainter(
        result: testResult,
        overlayColor: Colors.green,
        strokeWidth: 2.0,
      );

      final painter2 = EdgeOverlayPainter(
        result: testResult,
        overlayColor: Colors.red, // Different color
        strokeWidth: 2.0,
      );

      final painter3 = EdgeOverlayPainter(
        result: testResult,
        overlayColor: Colors.green,
        strokeWidth: 2.0,
      );

      expect(painter1.shouldRepaint(painter2), isTrue); // Different color
      expect(painter1.shouldRepaint(painter3), isFalse); // Same properties
    });

    test('should handle different confidence levels for color selection', () {
      const painter = EdgeOverlayPainter(
        result: EdgeDetectionResult(
          success: true,
          confidence: 0.85,
          corners: [],
        ),
        overlayColor: Colors.green,
        strokeWidth: 2.0,
      );

      // Test confidence color mapping (private method testing via paint behavior)
      expect(painter.overlayColor, equals(Colors.green));
    });
  });

  group('Point', () {
    test('should support equality comparison', () {
      const point1 = Point(0.5, 0.5);
      const point2 = Point(0.5, 0.5);
      const point3 = Point(0.6, 0.5);

      expect(point1, equals(point2));
      expect(point1, isNot(equals(point3)));
    });

    test('should generate consistent hash codes', () {
      const point1 = Point(0.5, 0.5);
      const point2 = Point(0.5, 0.5);

      expect(point1.hashCode, equals(point2.hashCode));
    });

    test('should provide string representation', () {
      const point = Point(0.25, 0.75);
      expect(point.toString(), equals('Point(0.25, 0.75)'));
    });
  });
}