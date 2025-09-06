class EdgeDetectionResult {
  final bool success;
  final List<Point> corners;
  final double confidence;

  EdgeDetectionResult({
    required this.success,
    this.corners = const [],
    this.confidence = 0.0,
  });
}

class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);

  @override
  String toString() => 'Point($x, $y)';
}