import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Base class for all domain failures
@freezed
class Failure with _$Failure {
  const Failure._();

  /// Network-related failure
  const factory Failure.network({
    required String message,
    int? statusCode,
    String? code,
  }) = NetworkFailure;

  /// Database/cache failure
  const factory Failure.database({
    required String message,
    String? query,
    String? stackTrace,
  }) = DatabaseFailure;

  /// Validation failure
  const factory Failure.validation({
    required String message,
    required Map<String, List<String>> errors,
  }) = ValidationFailure;

  /// Resource not found
  const factory Failure.notFound({
    required String message,
    required String resourceId,
    String? resourceType,
  }) = NotFoundFailure;

  /// Permission/auth failure
  const factory Failure.permission({
    required String message,
    String? requiredPermission,
  }) = PermissionFailure;

  /// Business logic failure
  const factory Failure.business({
    required String message,
    String? code,
    Map<String, dynamic>? metadata,
  }) = BusinessFailure;

  /// Storage failure (file system)
  const factory Failure.storage({
    required String message,
    String? path,
    String? operation,
  }) = StorageFailure;

  /// OCR/processing failure
  const factory Failure.processing({
    required String message,
    double? confidence,
    String? stage,
  }) = ProcessingFailure;

  /// Generic unexpected failure
  const factory Failure.unexpected({
    required String message,
    String? stackTrace,
  }) = UnexpectedFailure;

  /// Get user-friendly message
  String get userMessage {
    return when(
      network: (msg, code, _) => 'Network error: $msg',
      database: (msg, _, __) => 'Database error: $msg',
      validation: (msg, errors) => msg,
      notFound: (msg, id, type) => 'Not found: $msg',
      permission: (msg, _) => 'Permission denied: $msg',
      business: (msg, _, __) => msg,
      storage: (msg, _, __) => 'Storage error: $msg',
      processing: (msg, _, __) => 'Processing error: $msg',
      unexpected: (msg, _) => 'Unexpected error: $msg',
    );
  }

  /// Get technical details for logging
  String get technicalDetails {
    return when(
      network: (msg, code, errorCode) =>
        'Network: $msg (status: $code, code: $errorCode)',
      database: (msg, query, stack) =>
        'Database: $msg\nQuery: $query\nStack: $stack',
      validation: (msg, errors) =>
        'Validation: $msg\nErrors: $errors',
      notFound: (msg, id, type) =>
        'NotFound: $msg (id: $id, type: $type)',
      permission: (msg, perm) =>
        'Permission: $msg (required: $perm)',
      business: (msg, code, meta) =>
        'Business: $msg (code: $code, meta: $meta)',
      storage: (msg, path, op) =>
        'Storage: $msg (path: $path, operation: $op)',
      processing: (msg, conf, stage) =>
        'Processing: $msg (confidence: $conf, stage: $stage)',
      unexpected: (msg, stack) =>
        'Unexpected: $msg\nStack: $stack',
    );
  }

  /// Check if this is a recoverable error
  bool get isRecoverable {
    return when(
      network: (_, __, ___) => true,  // Can retry
      database: (_, __, ___) => true,  // Can retry
      validation: (_, __) => false,    // User must fix
      notFound: (_, __, ___) => false, // Resource gone
      permission: (_, __) => false,    // User needs auth
      business: (_, __, ___) => false, // Logic error
      storage: (_, __, ___) => true,   // Can retry
      processing: (_, __, ___) => true, // Can retry
      unexpected: (_, __) => false,    // Unknown state
    );
  }
}