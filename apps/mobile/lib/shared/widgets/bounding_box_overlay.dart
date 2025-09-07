import 'package:flutter/material.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';

/// Represents a bounding box for an OCR field
class OcrBoundingBox {
  final String fieldName;
  final Rect bounds;
  final double confidence;

  const OcrBoundingBox({
    required this.fieldName,
    required this.bounds,
    required this.confidence,
  });

  /// Get color based on confidence level
  Color get color {
    if (confidence > 0.9) {
      return Colors.green.withOpacity(0.3);
    } else if (confidence > 0.75) {
      return Colors.yellow.withOpacity(0.3);
    } else {
      return Colors.red.withOpacity(0.3);
    }
  }

  /// Get border color based on confidence level
  Color get borderColor {
    if (confidence > 0.9) {
      return Colors.green;
    } else if (confidence > 0.75) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}

/// Custom painter that overlays OCR bounding boxes on an image
/// 
/// Coordinate System:
/// - OCR coordinates are normalized (0.0 to 1.0) relative to original image dimensions
/// - The painter scales these coordinates to match the current widget size
/// - Transformation matrix accounts for zoom and pan operations
/// 
/// Visual Debugging:
/// - Enable debugMode to show coordinate transformations
/// - Red dots: Original OCR coordinates
/// - Blue dots: Transformed coordinates
/// - Green lines: Transformation vectors
class BoundingBoxPainter extends CustomPainter {
  final List<OcrBoundingBox> boundingBoxes;
  final String? selectedFieldName;
  final bool debugMode;
  final Size imageSize;
  final Size displaySize;

  BoundingBoxPainter({
    required this.boundingBoxes,
    this.selectedFieldName,
    this.debugMode = false,
    required this.imageSize,
    required this.displaySize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (boundingBoxes.isEmpty) return;

    // Calculate scale factors for coordinate transformation
    final scaleX = displaySize.width / imageSize.width;
    final scaleY = displaySize.height / imageSize.height;

    // Use the smaller scale to maintain aspect ratio
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // Calculate offsets to center the image
    final scaledWidth = imageSize.width * scale;
    final scaledHeight = imageSize.height * scale;
    final offsetX = (displaySize.width - scaledWidth) / 2;
    final offsetY = (displaySize.height - scaledHeight) / 2;

    for (final box in boundingBoxes) {
      // Transform normalized coordinates to display coordinates
      final transformedBounds = Rect.fromLTRB(
        box.bounds.left * scaledWidth + offsetX,
        box.bounds.top * scaledHeight + offsetY,
        box.bounds.right * scaledWidth + offsetX,
        box.bounds.bottom * scaledHeight + offsetY,
      );

      // Draw filled rectangle
      final fillPaint = Paint()
        ..color = box.fieldName == selectedFieldName 
            ? box.color.withOpacity(0.5) 
            : box.color
        ..style = PaintingStyle.fill;
      
      canvas.drawRect(transformedBounds, fillPaint);

      // Draw border
      final borderPaint = Paint()
        ..color = box.fieldName == selectedFieldName 
            ? box.borderColor 
            : box.borderColor.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = box.fieldName == selectedFieldName ? 3 : 2;
      
      canvas.drawRect(transformedBounds, borderPaint);

      // Draw field name label
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${box.fieldName} (${(box.confidence * 100).toInt()}%)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: box.fieldName == selectedFieldName 
                ? FontWeight.bold 
                : FontWeight.normal,
            backgroundColor: box.borderColor.withOpacity(0.8),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          transformedBounds.left + 4,
          transformedBounds.top + 4,
        ),
      );

      // Debug mode: show coordinate transformations
      if (debugMode) {
        _drawDebugInfo(canvas, box, transformedBounds, size);
      }
    }
  }

  void _drawDebugInfo(Canvas canvas, OcrBoundingBox box, Rect transformedBounds, Size size) {
    // Draw original coordinates (normalized)
    final originalPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    final originalCenter = Offset(
      box.bounds.center.dx * size.width,
      box.bounds.center.dy * size.height,
    );
    
    canvas.drawCircle(originalCenter, 5, originalPaint);

    // Draw transformed coordinates
    final transformedPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(transformedBounds.center, 5, transformedPaint);

    // Draw transformation vector
    final vectorPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawLine(originalCenter, transformedBounds.center, vectorPaint);

    // Draw debug text
    final debugTextPainter = TextPainter(
      text: TextSpan(
        text: 'Orig: (${box.bounds.left.toStringAsFixed(2)}, ${box.bounds.top.toStringAsFixed(2)})\n'
              'Trans: (${transformedBounds.left.toInt()}, ${transformedBounds.top.toInt()})',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          backgroundColor: Colors.black54,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    debugTextPainter.layout();
    debugTextPainter.paint(
      canvas,
      Offset(transformedBounds.right + 5, transformedBounds.top),
    );
  }

  @override
  bool shouldRepaint(BoundingBoxPainter oldDelegate) {
    return boundingBoxes != oldDelegate.boundingBoxes ||
           selectedFieldName != oldDelegate.selectedFieldName ||
           debugMode != oldDelegate.debugMode ||
           imageSize != oldDelegate.imageSize ||
           displaySize != oldDelegate.displaySize;
  }
}

/// Widget that overlays OCR bounding boxes on top of an image
/// 
/// This widget should be used as a child of a Stack, positioned over the image viewer.
/// It handles tap detection to allow users to select fields by tapping on bounding boxes.
class BoundingBoxOverlay extends StatelessWidget {
  final List<OcrBoundingBox> boundingBoxes;
  final String? selectedFieldName;
  final Function(String fieldName)? onFieldTapped;
  final bool debugMode;
  final Size imageSize;
  final Size displaySize;

  const BoundingBoxOverlay({
    Key? key,
    required this.boundingBoxes,
    this.selectedFieldName,
    this.onFieldTapped,
    this.debugMode = false,
    required this.imageSize,
    required this.displaySize,
  }) : super(key: key);

  /// Extract bounding boxes from ProcessingResult
  static List<OcrBoundingBox> extractFromProcessingResult(ProcessingResult result) {
    final boxes = <OcrBoundingBox>[];
    
    // Extract merchant bounding box
    if (result.merchant != null && result.merchant!.boundingBox != null) {
      boxes.add(OcrBoundingBox(
        fieldName: 'merchant',
        bounds: result.merchant!.boundingBox!,
        confidence: result.merchant!.confidence,
      ));
    }
    
    // Extract date bounding box
    if (result.date != null && result.date!.boundingBox != null) {
      boxes.add(OcrBoundingBox(
        fieldName: 'date',
        bounds: result.date!.boundingBox!,
        confidence: result.date!.confidence,
      ));
    }
    
    // Extract total bounding box
    if (result.total != null && result.total!.boundingBox != null) {
      boxes.add(OcrBoundingBox(
        fieldName: 'total',
        bounds: result.total!.boundingBox!,
        confidence: result.total!.confidence,
      ));
    }
    
    // Extract tax bounding box
    if (result.tax != null && result.tax!.boundingBox != null) {
      boxes.add(OcrBoundingBox(
        fieldName: 'tax',
        bounds: result.tax!.boundingBox!,
        confidence: result.tax!.confidence,
      ));
    }
    
    return boxes;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) => _handleTap(details, constraints.biggest),
          child: CustomPaint(
            size: constraints.biggest,
            painter: BoundingBoxPainter(
              boundingBoxes: boundingBoxes,
              selectedFieldName: selectedFieldName,
              debugMode: debugMode,
              imageSize: imageSize,
              displaySize: displaySize,
            ),
          ),
        );
      },
    );
  }

  void _handleTap(TapDownDetails details, Size size) {
    if (onFieldTapped == null) return;

    // Calculate scale factors
    final scaleX = displaySize.width / imageSize.width;
    final scaleY = displaySize.height / imageSize.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // Calculate offsets
    final scaledWidth = imageSize.width * scale;
    final scaledHeight = imageSize.height * scale;
    final offsetX = (displaySize.width - scaledWidth) / 2;
    final offsetY = (displaySize.height - scaledHeight) / 2;

    // Check each bounding box for tap
    for (final box in boundingBoxes) {
      final transformedBounds = Rect.fromLTRB(
        box.bounds.left * scaledWidth + offsetX,
        box.bounds.top * scaledHeight + offsetY,
        box.bounds.right * scaledWidth + offsetX,
        box.bounds.bottom * scaledHeight + offsetY,
      );

      if (transformedBounds.contains(details.localPosition)) {
        onFieldTapped!(box.fieldName);
        break;
      }
    }
  }
}