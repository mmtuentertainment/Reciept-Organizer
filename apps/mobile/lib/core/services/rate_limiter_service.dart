import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rate limiter configuration
class RateLimiterConfig {
  final int maxRequests;
  final Duration window;
  final Duration burstWindow;
  final int burstLimit;

  const RateLimiterConfig({
    this.maxRequests = 60, // 60 requests per window
    this.window = const Duration(minutes: 1),
    this.burstWindow = const Duration(seconds: 1),
    this.burstLimit = 5, // Max 5 requests per second
  });
}

/// Rate limiter for API endpoints
class RateLimiterService {
  final RateLimiterConfig config;
  final Map<String, List<DateTime>> _requestHistory = {};
  final Map<String, int> _blockedUntil = {};
  final Map<String, int> _violationCount = {};

  RateLimiterService({RateLimiterConfig? config})
      : config = config ?? const RateLimiterConfig();

  /// Check if request is allowed
  Future<RateLimitResult> checkLimit(String key, {String? endpoint}) async {
    final now = DateTime.now();
    final fullKey = endpoint != null ? '$key:$endpoint' : key;

    // Check if currently blocked
    if (_blockedUntil.containsKey(fullKey)) {
      final blockEndTime = _blockedUntil[fullKey]!;
      if (now.millisecondsSinceEpoch < blockEndTime) {
        final remainingMs = blockEndTime - now.millisecondsSinceEpoch;
        return RateLimitResult(
          allowed: false,
          remainingRequests: 0,
          resetTime: DateTime.fromMillisecondsSinceEpoch(blockEndTime),
          retryAfter: Duration(milliseconds: remainingMs),
          reason: 'Rate limit exceeded. Too many violations.',
        );
      } else {
        // Block expired, remove it
        _blockedUntil.remove(fullKey);
        _violationCount.remove(fullKey);
      }
    }

    // Initialize history if needed
    _requestHistory[fullKey] ??= [];

    // Clean old requests outside window
    final windowStart = now.subtract(config.window);
    _requestHistory[fullKey]!.removeWhere(
      (time) => time.isBefore(windowStart),
    );

    // Check burst limit
    final burstStart = now.subtract(config.burstWindow);
    final recentBurstRequests = _requestHistory[fullKey]!
        .where((time) => time.isAfter(burstStart))
        .length;

    if (recentBurstRequests >= config.burstLimit) {
      _handleViolation(fullKey, now);
      return RateLimitResult(
        allowed: false,
        remainingRequests: 0,
        resetTime: now.add(config.burstWindow),
        retryAfter: config.burstWindow,
        reason: 'Burst limit exceeded. Please slow down.',
      );
    }

    // Check window limit
    if (_requestHistory[fullKey]!.length >= config.maxRequests) {
      _handleViolation(fullKey, now);
      final oldestRequest = _requestHistory[fullKey]!.first;
      final resetTime = oldestRequest.add(config.window);
      return RateLimitResult(
        allowed: false,
        remainingRequests: 0,
        resetTime: resetTime,
        retryAfter: resetTime.difference(now),
        reason: 'Rate limit exceeded. Please wait before retrying.',
      );
    }

    // Request allowed
    _requestHistory[fullKey]!.add(now);
    final remainingRequests = config.maxRequests - _requestHistory[fullKey]!.length;

    return RateLimitResult(
      allowed: true,
      remainingRequests: remainingRequests,
      resetTime: now.add(config.window),
      retryAfter: Duration.zero,
    );
  }

  /// Handle rate limit violation
  void _handleViolation(String key, DateTime now) {
    _violationCount[key] = (_violationCount[key] ?? 0) + 1;

    // Exponential backoff for repeated violations
    if (_violationCount[key]! >= 3) {
      final blockDuration = Duration(
        minutes: 5 * _violationCount[key]!, // 5, 10, 15 minutes...
      );
      _blockedUntil[key] = now.add(blockDuration).millisecondsSinceEpoch;
    }
  }

  /// Reset limits for a specific key
  void reset(String key) {
    _requestHistory.remove(key);
    _blockedUntil.remove(key);
    _violationCount.remove(key);
  }

  /// Get current usage statistics
  Map<String, dynamic> getStats(String key) {
    final history = _requestHistory[key] ?? [];
    final now = DateTime.now();
    final windowStart = now.subtract(config.window);
    final validRequests = history.where((t) => t.isAfter(windowStart)).toList();

    return {
      'currentRequests': validRequests.length,
      'maxRequests': config.maxRequests,
      'remainingRequests': config.maxRequests - validRequests.length,
      'violations': _violationCount[key] ?? 0,
      'isBlocked': _blockedUntil.containsKey(key),
      'windowSize': config.window.inSeconds,
    };
  }

  /// Clear all rate limit data
  void clearAll() {
    _requestHistory.clear();
    _blockedUntil.clear();
    _violationCount.clear();
  }
}

/// Result of rate limit check
class RateLimitResult {
  final bool allowed;
  final int remainingRequests;
  final DateTime resetTime;
  final Duration retryAfter;
  final String? reason;

  const RateLimitResult({
    required this.allowed,
    required this.remainingRequests,
    required this.resetTime,
    required this.retryAfter,
    this.reason,
  });

  Map<String, dynamic> toHeaders() {
    return {
      'X-RateLimit-Limit': '60',
      'X-RateLimit-Remaining': remainingRequests.toString(),
      'X-RateLimit-Reset': resetTime.millisecondsSinceEpoch.toString(),
      if (!allowed) 'Retry-After': retryAfter.inSeconds.toString(),
    };
  }
}

/// API-specific rate limiters
class ApiRateLimiter {
  static final Map<String, RateLimiterService> _limiters = {};

  static RateLimiterService getForEndpoint(String endpoint) {
    if (!_limiters.containsKey(endpoint)) {
      // Different limits for different endpoints
      final config = _getConfigForEndpoint(endpoint);
      _limiters[endpoint] = RateLimiterService(config: config);
    }
    return _limiters[endpoint]!;
  }

  static RateLimiterConfig _getConfigForEndpoint(String endpoint) {
    // Stricter limits for sensitive endpoints
    if (endpoint.contains('/auth') || endpoint.contains('/login')) {
      return const RateLimiterConfig(
        maxRequests: 5,
        window: Duration(minutes: 5),
        burstLimit: 2,
        burstWindow: Duration(seconds: 1),
      );
    }

    // OCR endpoints - expensive operations
    if (endpoint.contains('/ocr') || endpoint.contains('/process')) {
      return const RateLimiterConfig(
        maxRequests: 10,
        window: Duration(minutes: 1),
        burstLimit: 1,
        burstWindow: Duration(seconds: 2),
      );
    }

    // Export endpoints
    if (endpoint.contains('/export')) {
      return const RateLimiterConfig(
        maxRequests: 20,
        window: Duration(minutes: 5),
        burstLimit: 3,
        burstWindow: Duration(seconds: 1),
      );
    }

    // Default limits
    return const RateLimiterConfig();
  }

  static void resetAll() {
    _limiters.clear();
  }
}

/// Provider for rate limiter service
final rateLimiterProvider = Provider<RateLimiterService>((ref) {
  return RateLimiterService();
});

/// Provider for API-specific rate limiting
final apiRateLimiterProvider = Provider.family<RateLimiterService, String>(
  (ref, endpoint) => ApiRateLimiter.getForEndpoint(endpoint),
);

/// Middleware for HTTP requests with rate limiting
class RateLimitedApiClient {
  final RateLimiterService _rateLimiter;
  final String userId;

  RateLimitedApiClient({
    required this.userId,
    RateLimiterService? rateLimiter,
  }) : _rateLimiter = rateLimiter ?? RateLimiterService();

  /// Execute API request with rate limiting
  Future<T> execute<T>({
    required String endpoint,
    required Future<T> Function() request,
    Function(RateLimitResult)? onRateLimitExceeded,
  }) async {
    final result = await _rateLimiter.checkLimit(userId, endpoint: endpoint);

    if (!result.allowed) {
      onRateLimitExceeded?.call(result);
      throw RateLimitException(
        message: result.reason ?? 'Rate limit exceeded',
        retryAfter: result.retryAfter,
        resetTime: result.resetTime,
      );
    }

    try {
      return await request();
    } catch (e) {
      // Don't count failed requests against rate limit
      if (e is! RateLimitException) {
        final history = _rateLimiter._requestHistory['$userId:$endpoint'];
        if (history != null && history.isNotEmpty) {
          history.removeLast();
        }
      }
      rethrow;
    }
  }

  /// Get current rate limit status
  Map<String, dynamic> getStatus(String endpoint) {
    return _rateLimiter.getStats('$userId:$endpoint');
  }
}

/// Exception thrown when rate limit is exceeded
class RateLimitException implements Exception {
  final String message;
  final Duration retryAfter;
  final DateTime resetTime;

  RateLimitException({
    required this.message,
    required this.retryAfter,
    required this.resetTime,
  });

  @override
  String toString() => 'RateLimitException: $message. Retry after ${retryAfter.inSeconds} seconds.';
}