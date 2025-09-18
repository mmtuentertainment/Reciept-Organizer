import 'dart:async';

/// Platform-agnostic background processing interface
abstract class BackgroundProcessor {
  /// Initialize background processing
  Future<void> initialize();

  /// Schedule a periodic task
  Future<void> schedulePeriodic({
    required String taskId,
    required Duration interval,
    required Future<void> Function() task,
  });

  /// Schedule a one-time task
  Future<void> scheduleOneTime({
    required String taskId,
    required DateTime when,
    required Future<void> Function() task,
  });

  /// Cancel a scheduled task
  Future<void> cancelTask(String taskId);

  /// Cancel all tasks
  Future<void> cancelAllTasks();

  /// Check if background processing is available
  Future<bool> isAvailable();

  /// Platform identifier
  String get platform;
}

/// Background task result
class BackgroundTaskResult {
  final String taskId;
  final bool success;
  final dynamic data;
  final String? error;
  final DateTime completedAt;

  BackgroundTaskResult({
    required this.taskId,
    required this.success,
    this.data,
    this.error,
    DateTime? completedAt,
  }) : completedAt = completedAt ?? DateTime.now();
}