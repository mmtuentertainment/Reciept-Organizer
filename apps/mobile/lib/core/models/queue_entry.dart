import 'package:freezed_annotation/freezed_annotation.dart';

part 'queue_entry.freezed.dart';
part 'queue_entry.g.dart';

/// Model for queued API requests
/// 
/// EXPERIMENT: Phase 3 - Minimal queue persistence
/// Stores failed requests for retry when connectivity restored
@freezed
class QueueEntry with _$QueueEntry {
  const factory QueueEntry({
    required String id,
    required String endpoint,
    required String method, // GET, POST, PUT, DELETE
    required Map<String, dynamic> headers,
    Map<String, dynamic>? body,
    required DateTime createdAt,
    DateTime? lastAttemptAt,
    required int retryCount,
    required int maxRetries,
    String? errorMessage,
    required QueueEntryStatus status,
    
    // Optional metadata for tracking
    String? feature, // e.g., "quickbooks_validation", "xero_export"
    String? userId,
  }) = _QueueEntry;

  factory QueueEntry.fromJson(Map<String, dynamic> json) => _$QueueEntryFromJson(json);
}

/// Status of a queue entry
enum QueueEntryStatus {
  pending,    // Waiting to be processed
  processing, // Currently being processed
  failed,     // Failed after max retries
  completed,  // Successfully processed
}