import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:receipt_organizer/core/services/supabase_service.dart';

/// Service for monitoring app performance and errors
class MonitoringService {
  static MonitoringService? _instance;
  
  // Performance metrics
  final Map<String, List<double>> _performanceMetrics = {};
  final Map<String, int> _errorCounts = {};
  final Map<String, DateTime> _lastError = {};
  
  // Session info
  DateTime? _sessionStart;
  int _apiCallCount = 0;
  int _dbOperationCount = 0;
  int _syncEventCount = 0;
  
  MonitoringService._() {
    _sessionStart = DateTime.now();
  }
  
  static MonitoringService get instance {
    _instance ??= MonitoringService._();
    return _instance!;
  }
  
  /// Track a performance metric
  void trackPerformance(String operation, double durationMs) {
    _performanceMetrics[operation] ??= [];
    _performanceMetrics[operation]!.add(durationMs);
    
    // Log slow operations
    if (durationMs > 3000) {
      debugPrint('⚠️ Slow operation: $operation took ${durationMs}ms');
    }
    
    // Send to analytics if configured
    _sendToAnalytics('performance', {
      'operation': operation,
      'duration_ms': durationMs,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  /// Track an error
  void trackError(String category, dynamic error, [StackTrace? stackTrace]) {
    _errorCounts[category] = (_errorCounts[category] ?? 0) + 1;
    _lastError[category] = DateTime.now();
    
    debugPrint('❌ Error in $category: $error');
    if (stackTrace != null && kDebugMode) {
      debugPrint('Stack trace: $stackTrace');
    }
    
    // Send to error tracking service
    _sendToErrorTracking(category, error, stackTrace);
  }
  
  /// Track API call
  void trackApiCall(String endpoint, int statusCode, double responseTimeMs) {
    _apiCallCount++;
    
    final metric = 'api_$endpoint';
    trackPerformance(metric, responseTimeMs);
    
    if (statusCode >= 400) {
      trackError('api', 'HTTP $statusCode on $endpoint');
    }
  }
  
  /// Track database operation
  void trackDatabaseOperation(String operation, double durationMs, {bool success = true}) {
    _dbOperationCount++;
    
    final metric = 'db_$operation';
    trackPerformance(metric, durationMs);
    
    if (!success) {
      trackError('database', 'Failed $operation');
    }
  }
  
  /// Track sync event
  void trackSyncEvent(String eventType, Map<String, dynamic> metadata) {
    _syncEventCount++;
    
    _sendToAnalytics('sync', {
      'event_type': eventType,
      'metadata': metadata,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  /// Track user action
  void trackUserAction(String action, [Map<String, dynamic>? properties]) {
    _sendToAnalytics('user_action', {
      'action': action,
      'properties': properties,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  /// Get performance summary for an operation
  Map<String, dynamic> getPerformanceSummary(String operation) {
    final metrics = _performanceMetrics[operation];
    if (metrics == null || metrics.isEmpty) {
      return {'error': 'No metrics for $operation'};
    }
    
    metrics.sort();
    final sum = metrics.reduce((a, b) => a + b);
    final avg = sum / metrics.length;
    final p50 = metrics[metrics.length ~/ 2];
    final p95 = metrics[(metrics.length * 0.95).floor()];
    final p99 = metrics[(metrics.length * 0.99).floor()];
    
    return {
      'count': metrics.length,
      'avg': avg.toStringAsFixed(2),
      'min': metrics.first.toStringAsFixed(2),
      'max': metrics.last.toStringAsFixed(2),
      'p50': p50.toStringAsFixed(2),
      'p95': p95.toStringAsFixed(2),
      'p99': p99.toStringAsFixed(2),
    };
  }
  
  /// Get session statistics
  Map<String, dynamic> getSessionStats() {
    final sessionDuration = _sessionStart != null 
      ? DateTime.now().difference(_sessionStart!).inSeconds 
      : 0;
    
    return {
      'session_duration_seconds': sessionDuration,
      'api_calls': _apiCallCount,
      'db_operations': _dbOperationCount,
      'sync_events': _syncEventCount,
      'error_categories': _errorCounts.keys.toList(),
      'total_errors': _errorCounts.values.fold(0, (a, b) => a + b),
      'performance_metrics': _performanceMetrics.keys.toList(),
    };
  }
  
  /// Get health status
  Map<String, dynamic> getHealthStatus() {
    final recentErrors = _lastError.entries
        .where((e) => DateTime.now().difference(e.value).inMinutes < 5)
        .map((e) => e.key)
        .toList();
    
    final hasRecentErrors = recentErrors.isNotEmpty;
    final errorRate = _apiCallCount > 0 
      ? (_errorCounts['api'] ?? 0) / _apiCallCount 
      : 0.0;
    
    String status = 'healthy';
    if (hasRecentErrors || errorRate > 0.1) {
      status = 'degraded';
    }
    if (errorRate > 0.5) {
      status = 'unhealthy';
    }
    
    return {
      'status': status,
      'recent_errors': recentErrors,
      'error_rate': (errorRate * 100).toStringAsFixed(2) + '%',
      'uptime_seconds': _sessionStart != null 
        ? DateTime.now().difference(_sessionStart!).inSeconds 
        : 0,
    };
  }
  
  /// Send to analytics service (placeholder)
  void _sendToAnalytics(String event, Map<String, dynamic> properties) {
    // In production, send to analytics service like:
    // - Google Analytics
    // - Mixpanel
    // - Amplitude
    // - Custom analytics endpoint
    
    if (kDebugMode) {
      debugPrint('📊 Analytics: $event - $properties');
    }
  }
  
  /// Send to error tracking service (placeholder)
  void _sendToErrorTracking(String category, dynamic error, StackTrace? stackTrace) {
    // In production, send to error tracking service like:
    // - Sentry
    // - Bugsnag
    // - Crashlytics
    // - Custom error tracking
    
    // Log to Supabase for now
    try {
      final supabase = SupabaseService.instance;
      if (supabase.isAuthenticated) {
        supabase.client.from('error_logs').insert({
          'user_id': supabase.currentUser?.id,
          'category': category,
          'error_message': error.toString(),
          'stack_trace': stackTrace?.toString(),
          'app_version': '1.0.0',
          'platform': defaultTargetPlatform.toString(),
          'created_at': DateTime.now().toIso8601String(),
        }).execute().catchError((e) {
          debugPrint('Failed to log error to Supabase: $e');
        });
      }
    } catch (e) {
      debugPrint('Error logging failed: $e');
    }
  }
  
  /// Export monitoring data
  Map<String, dynamic> exportMonitoringData() {
    return {
      'session': getSessionStats(),
      'health': getHealthStatus(),
      'performance': _performanceMetrics.map(
        (key, value) => MapEntry(key, getPerformanceSummary(key))
      ),
      'errors': _errorCounts,
      'last_errors': _lastError.map(
        (key, value) => MapEntry(key, value.toIso8601String())
      ),
    };
  }
  
  /// Clear all monitoring data
  void clearData() {
    _performanceMetrics.clear();
    _errorCounts.clear();
    _lastError.clear();
    _apiCallCount = 0;
    _dbOperationCount = 0;
    _syncEventCount = 0;
    _sessionStart = DateTime.now();
  }
}

/// Extension to add monitoring to async operations
extension MonitoredOperation<T> on Future<T> {
  /// Monitor the performance of this async operation
  Future<T> monitored(String operationName) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await this;
      stopwatch.stop();
      MonitoringService.instance.trackPerformance(
        operationName, 
        stopwatch.elapsedMilliseconds.toDouble()
      );
      return result;
    } catch (error, stackTrace) {
      stopwatch.stop();
      MonitoringService.instance.trackError(operationName, error, stackTrace);
      MonitoringService.instance.trackPerformance(
        operationName, 
        stopwatch.elapsedMilliseconds.toDouble()
      );
      rethrow;
    }
  }
}