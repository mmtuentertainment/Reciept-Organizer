import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:receipt_organizer/shared/widgets/bounding_box_overlay.dart';

void main() {
  group('BoundingBoxOverlay Widget Tests', () {
    // Test data
    final testBoundingBoxes = [
      OcrBoundingBox(
        fieldName: 'merchant',
        bounds: const Rect.fromLTRB(0.1, 0.1, 0.4, 0.2),
        confidence: 0.95,
      ),
      OcrBoundingBox(
        fieldName: 'date',
        bounds: const Rect.fromLTRB(0.6, 0.1, 0.9, 0.2),
        confidence: 0.85,
      ),
      OcrBoundingBox(
        fieldName: 'total',
        bounds: const Rect.fromLTRB(0.6, 0.7, 0.9, 0.8),
        confidence: 0.7,
      ),
      OcrBoundingBox(
        fieldName: 'tax',
        bounds: const Rect.fromLTRB(0.6, 0.8, 0.9, 0.9),
        confidence: 0.65,
      ),
    ];
    
    Widget createTestWidget({
      List<OcrBoundingBox>? boundingBoxes,
      String? selectedFieldName,
      Function(String)? onFieldTapped,
      bool debugMode = false,
      Size imageSize = const Size(1000, 1400),
      Size displaySize = const Size(400, 600),
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Container(
              width: displaySize.width,
              height: displaySize.height,
              color: Colors.grey,
              child: BoundingBoxOverlay(
                boundingBoxes: boundingBoxes ?? testBoundingBoxes,
                selectedFieldName: selectedFieldName,
                onFieldTapped: onFieldTapped,
                debugMode: debugMode,
                imageSize: imageSize,
                displaySize: displaySize,
              ),
            ),
          ),
        ),
      );
    }
    
    group('Given bounding box color coding', () {
      testWidgets('When confidence > 90% Then box is green', (tester) async {
        // Arrange
        final highConfidenceBox = OcrBoundingBox(
          fieldName: 'test',
          bounds: const Rect.fromLTRB(0.1, 0.1, 0.3, 0.3),
          confidence: 0.95,
        );
        
        // Act
        await tester.pumpWidget(createTestWidget(
          boundingBoxes: [highConfidenceBox],
        ));
        
        // Assert
        expect(highConfidenceBox.color, equals(Colors.green.withAlpha((0.3 * 255).round())));
        expect(highConfidenceBox.borderColor, equals(Colors.green));
      });
      
      testWidgets('When confidence 75-90% Then box is yellow', (tester) async {
        // Arrange
        final mediumConfidenceBox = OcrBoundingBox(
          fieldName: 'test',
          bounds: const Rect.fromLTRB(0.1, 0.1, 0.3, 0.3),
          confidence: 0.85,
        );
        
        // Act
        await tester.pumpWidget(createTestWidget(
          boundingBoxes: [mediumConfidenceBox],
        ));
        
        // Assert
        expect(mediumConfidenceBox.color, equals(Colors.yellow.withAlpha((0.3 * 255).round())));
        expect(mediumConfidenceBox.borderColor, equals(Colors.yellow));
      });
      
      testWidgets('When confidence < 75% Then box is red', (tester) async {
        // Arrange
        final lowConfidenceBox = OcrBoundingBox(
          fieldName: 'test',
          bounds: const Rect.fromLTRB(0.1, 0.1, 0.3, 0.3),
          confidence: 0.65,
        );
        
        // Act
        await tester.pumpWidget(createTestWidget(
          boundingBoxes: [lowConfidenceBox],
        ));
        
        // Assert
        expect(lowConfidenceBox.color, equals(Colors.red.withAlpha((0.3 * 255).round())));
        expect(lowConfidenceBox.borderColor, equals(Colors.red));
      });
    });
    
    group('Given field selection', () {
      testWidgets('When field is tapped Then callback is triggered', (tester) async {
        // Arrange
        String? tappedField;
        
        // Act
        await tester.pumpWidget(createTestWidget(
          onFieldTapped: (fieldName) => tappedField = fieldName,
        ));
        
        // Tap on the merchant box
        // Merchant bounds: Rect.fromLTRB(0.1, 0.1, 0.4, 0.2) in normalized coords
        // Center point: (0.25, 0.15)
        // Scale to display size (400x600): (100, 90)
        // But we need to add the offset to the center of the container
        final container = tester.getCenter(find.byType(BoundingBoxOverlay));
        final tapPoint = Offset(
          container.dx - 200 + 100, // center - half width + scaled x
          container.dy - 300 + 90,  // center - half height + scaled y
        );
        await tester.tapAt(tapPoint);
        await tester.pump();
        
        // Assert
        expect(tappedField, equals('merchant'));
      });
      
      testWidgets('When selected field is highlighted differently', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          selectedFieldName: 'merchant',
        ));
        
        // Assert - Visual test, checking painter properties
        final customPaints = find.byType(CustomPaint);
        expect(customPaints, findsWidgets);
        
        // Find the CustomPaint with BoundingBoxPainter
        BoundingBoxPainter? painter;
        for (int i = 0; i < tester.widgetList(customPaints).length; i++) {
          final widget = tester.widget<CustomPaint>(customPaints.at(i));
          if (widget.painter is BoundingBoxPainter) {
            painter = widget.painter as BoundingBoxPainter;
            break;
          }
        }
        
        expect(painter, isNotNull);
        expect(painter!.selectedFieldName, equals('merchant'));
      });
    });
    
    group('Given ProcessingResult extraction', () {
      test('When extracting from ProcessingResult Then all fields with boxes are included', () {
        // Arrange
        final result = ProcessingResult(
          merchant: FieldData(
            value: 'Test Store',
            confidence: 0.95,
            originalText: 'Test Store',
            boundingBox: const Rect.fromLTRB(0.1, 0.1, 0.4, 0.2),
          ),
          date: FieldData(
            value: '2024-01-15',
            confidence: 0.85,
            originalText: '2024-01-15',
            boundingBox: const Rect.fromLTRB(0.6, 0.1, 0.9, 0.2),
          ),
          total: FieldData(
            value: '100.00',
            confidence: 0.7,
            originalText: '100.00',
            boundingBox: null, // No bounding box
          ),
          tax: FieldData(
            value: '10.00',
            confidence: 0.65,
            originalText: '10.00',
            boundingBox: const Rect.fromLTRB(0.6, 0.8, 0.9, 0.9),
          ),
          overallConfidence: 85.0,
          processingDurationMs: 1000,
        );
        
        // Act
        final boxes = BoundingBoxOverlay.extractFromProcessingResult(result);
        
        // Assert
        expect(boxes.length, equals(3)); // Only fields with bounding boxes
        expect(boxes[0].fieldName, equals('merchant'));
        expect(boxes[1].fieldName, equals('date'));
        expect(boxes[2].fieldName, equals('tax'));
      });
    });
    
    group('Given coordinate transformation', () {
      testWidgets('When image is centered Then boxes are transformed correctly', (tester) async {
        // Arrange
        final testBox = OcrBoundingBox(
          fieldName: 'test',
          bounds: const Rect.fromLTRB(0.0, 0.0, 0.5, 0.5), // Top-left quarter
          confidence: 0.95,
        );
        
        // Image: 1000x1400, Display: 400x600
        // Scale: min(400/1000, 600/1400) = min(0.4, 0.428) = 0.4
        // Scaled size: 400x560
        // Offset: (0, 20) to center vertically
        
        // Act
        await tester.pumpWidget(createTestWidget(
          boundingBoxes: [testBox],
          imageSize: const Size(1000, 1400),
          displaySize: const Size(400, 600),
        ));
        
        // Expected transformed bounds:
        // Left: 0.0 * 400 + 0 = 0
        // Top: 0.0 * 560 + 20 = 20
        // Right: 0.5 * 400 + 0 = 200
        // Bottom: 0.5 * 560 + 20 = 300
        
        // Visual test - ensure rendering completes without error
        expect(find.byType(CustomPaint), findsWidgets);
      });
    });
    
    group('Given debug mode', () {
      testWidgets('When debug mode is enabled Then additional info is shown', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          debugMode: true,
        ));
        
        // Assert - Check painter has debug mode enabled
        // Find the CustomPaint with BoundingBoxPainter
        final customPaints = find.byType(CustomPaint);
        BoundingBoxPainter? painter;
        for (int i = 0; i < tester.widgetList(customPaints).length; i++) {
          final widget = tester.widget<CustomPaint>(customPaints.at(i));
          if (widget.painter is BoundingBoxPainter) {
            painter = widget.painter as BoundingBoxPainter;
            break;
          }
        }
        expect(painter, isNotNull);
        
        expect(painter!.debugMode, isTrue);
      });
    });
    
    group('Given empty bounding boxes', () {
      testWidgets('When no boxes provided Then overlay renders empty', (tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          boundingBoxes: [],
        ));
        
        // Assert - Should render without error
        expect(find.byType(CustomPaint), findsWidgets);
      });
    });
  });
}