import 'dart:typed_data';
import 'package:receipt_organizer/data/models/edge_detection_result.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';

/// Represents a capture session for retry functionality
class CaptureSession {
  final String sessionId;
  final int retryCount;
  final int maxRetryAttempts;
  final FailureReason? lastFailureReason;
  final String? lastFailureMessage;
  final DateTime createdAt;
  final Uint8List? imageData;
  final EdgeDetectionResult? preservedEdgeDetection;
  final ProcessingResult? lastProcessingResult;
  
  const CaptureSession({
    required this.sessionId,
    required this.retryCount,
    required this.maxRetryAttempts,
    this.lastFailureReason,
    this.lastFailureMessage,
    required this.createdAt,
    this.imageData,
    this.preservedEdgeDetection,
    this.lastProcessingResult,
  });
  
  /// Check if session has expired (older than 24 hours)
  bool get isExpired => DateTime.now().difference(createdAt).inHours > 24;
}

/// Wrapper for retry session data
class RetrySession extends CaptureSession {
  final DateTime timestamp;
  
  RetrySession({
    required super.sessionId,
    required super.retryCount,
    required super.maxRetryAttempts,
    super.lastFailureReason,
    super.lastFailureMessage,
    required this.timestamp,
    super.imageData,
    super.preservedEdgeDetection,
    super.lastProcessingResult,
  }) : super(createdAt: timestamp);
}