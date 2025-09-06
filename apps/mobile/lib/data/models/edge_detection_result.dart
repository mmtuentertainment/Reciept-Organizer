class EdgeDetectionResult {
  final bool success;
  final List<Point> corners;
  final double confidence;
  final int processingTimeMs;

  const EdgeDetectionResult({
    required this.success,
    this.corners = const [],
    this.confidence = 0.0,
    this.processingTimeMs = 0,
  });

  @override
  String toString() => 'EdgeDetectionResult(success: $success, confidence: $confidence, corners: ${corners.length}, time: ${processingTimeMs}ms)';
}

class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);

  @override
  String toString() => 'Point($x, $y)';
}