import 'package:flutter/material.dart';
import '../../data/models/edge_detection_result.dart';

/// Visual overlay that displays detected edges and corner handles on camera preview
class EdgeOverlayWidget extends StatelessWidget {
  const EdgeOverlayWidget({
    super.key,
    required this.result,
    required this.viewSize,
    this.onCornerDrag,
    this.showCornerHandles = true,
    this.overlayColor = Colors.green,
    this.lowConfidenceColor = Colors.orange,
    this.strokeWidth = 2.0,
  });

  final EdgeDetectionResult result;
  final Size viewSize;
  final Function(int cornerIndex, Offset newPosition)? onCornerDrag;
  final bool showCornerHandles;
  final Color overlayColor;
  final Color lowConfidenceColor;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    if (!result.success || result.corners.length < 4) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: viewSize.width,
      height: viewSize.height,
      child: CustomPaint(
        size: viewSize,
        painter: EdgeOverlayPainter(
          result: result,
          overlayColor: result.confidence >= 0.8 ? overlayColor : lowConfidenceColor,
          strokeWidth: strokeWidth,
        ),
        child: showCornerHandles ? _buildCornerHandles() : null,
      ),
    );
  }

  Widget _buildCornerHandles() {
    return Stack(
      children: result.corners.asMap().entries.map((entry) {
        final index = entry.key;
        final corner = entry.value;
        final position = Offset(
          corner.x * viewSize.width,
          corner.y * viewSize.height,
        );

        return Positioned(
          left: position.dx - 12,
          top: position.dy - 12,
          child: GestureDetector(
            onPanUpdate: (details) {
              if (onCornerDrag != null) {
                final newPosition = Offset(
                  (position.dx + details.delta.dx) / viewSize.width,
                  (position.dy + details.delta.dy) / viewSize.height,
                );
                onCornerDrag!(index, newPosition);
              }
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: overlayColor, width: 2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                Icons.drag_indicator,
                size: 16,
                color: overlayColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Custom painter for drawing edge detection overlay
class EdgeOverlayPainter extends CustomPainter {
  const EdgeOverlayPainter({
    required this.result,
    required this.overlayColor,
    required this.strokeWidth,
  });

  final EdgeDetectionResult result;
  final Color overlayColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (!result.success || result.corners.length < 4) return;

    final paint = Paint()
      ..color = overlayColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = overlayColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Convert normalized corners to screen coordinates
    final screenCorners = result.corners.map((corner) => Offset(
      corner.x * size.width,
      corner.y * size.height,
    )).toList();

    // Draw filled overlay area
    final path = Path();
    path.moveTo(screenCorners[0].dx, screenCorners[0].dy);
    for (int i = 1; i < screenCorners.length; i++) {
      path.lineTo(screenCorners[i].dx, screenCorners[i].dy);
    }
    path.close();
    canvas.drawPath(path, fillPaint);

    // Draw edge lines
    for (int i = 0; i < screenCorners.length; i++) {
      final start = screenCorners[i];
      final end = screenCorners[(i + 1) % screenCorners.length];
      canvas.drawLine(start, end, paint);
    }

    // Draw corner points
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final cornerBorderPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final corner in screenCorners) {
      canvas.drawCircle(corner, 6, cornerPaint);
      canvas.drawCircle(corner, 6, cornerBorderPaint);
    }

    // Draw confidence indicator
    _drawConfidenceIndicator(canvas, size);
  }

  void _drawConfidenceIndicator(Canvas canvas, Size size) {
    final confidence = result.confidence;
    final indicatorPaint = Paint()
      ..color = _getConfidenceColor(confidence)
      ..style = PaintingStyle.fill;

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(confidence * 100).round()}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    const padding = 8.0;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width - textPainter.width - padding * 2 - 16,
        16,
        textPainter.width + padding * 2,
        textPainter.height + padding,
      ),
      const Radius.circular(4),
    );

    canvas.drawRRect(rect, backgroundPaint);
    
    // Draw confidence bar
    final barWidth = textPainter.width;
    final barHeight = 3.0;
    final barRect = Rect.fromLTWH(
      rect.left + padding,
      rect.bottom - padding / 2 - barHeight,
      barWidth * confidence,
      barHeight,
    );
    canvas.drawRect(barRect, indicatorPaint);

    textPainter.paint(
      canvas,
      Offset(rect.left + padding, rect.top + padding / 2),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  @override
  bool shouldRepaint(EdgeOverlayPainter oldDelegate) {
    return oldDelegate.result != result ||
           oldDelegate.overlayColor != overlayColor ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}

