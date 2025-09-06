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

  /// Serializes EdgeDetectionResult to JSON for session persistence
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'corners': corners.map((point) => point.toJson()).toList(),
      'confidence': confidence,
      'processingTimeMs': processingTimeMs,
    };
  }

  /// Creates EdgeDetectionResult from JSON for session restoration
  factory EdgeDetectionResult.fromJson(Map<String, dynamic> json) {
    return EdgeDetectionResult(
      success: json['success'] as bool,
      corners: (json['corners'] as List<dynamic>?)
          ?.map((pointJson) => Point.fromJson(pointJson as Map<String, dynamic>))
          .toList() ?? [],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      processingTimeMs: json['processingTimeMs'] as int? ?? 0,
    );
  }

  @override
  String toString() => 'EdgeDetectionResult(success: $success, confidence: $confidence, corners: ${corners.length}, time: ${processingTimeMs}ms)';
}

class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);

  /// Serializes Point to JSON for session persistence
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }

  /// Creates Point from JSON for session restoration
  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
    );
  }

  @override
  String toString() => 'Point($x, $y)';
}