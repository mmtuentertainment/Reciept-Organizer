import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../core/config/environment.dart';
import '../../core/exceptions/service_exception.dart';
import '../../core/models/receipt.dart';
import '../../core/services/network_connectivity_service.dart';
import '../../core/services/request_queue_service.dart';
import '../../core/services/rate_limiter_service.dart';

/// Service for interacting with the Receipt Organizer API
///
/// This service bridges the mobile app with the REST API backend,
/// handling receipt uploads, retrieval, and error management according
/// to RFC9457 Problem Details specification.
class ReceiptApiService {
  static final ReceiptApiService _instance = ReceiptApiService._internal();
  factory ReceiptApiService() => _instance;
  ReceiptApiService._internal();

  final _uuid = const Uuid();
  final _connectivity = NetworkConnectivityService();
  final _requestQueue = RequestQueueService();
  final _httpClient = http.Client();
  final _rateLimiter = RateLimiterService();

  // Cache for idempotency keys to prevent duplicate submissions
  final Map<String, String> _idempotencyCache = {};

  /// Base URL for the API
  String get _baseUrl => Environment.apiUrl;

  /// Create a new receipt ingestion job
  ///
  /// Supports both URL and base64 image upload methods.
  /// Returns a job ID for tracking the processing status.
  Future<String> createReceiptJob({
    String? imageUrl,
    Uint8List? imageData,
    String? contentType,
    Map<String, dynamic>? metadata,
  }) async {
    // Validate input
    if (imageUrl == null && imageData == null) {
      throw ServiceException(
        'Either imageUrl or imageData must be provided',
        code: 'INVALID_INPUT',
      );
    }

    if (imageUrl != null && imageData != null) {
      throw ServiceException(
        'Cannot provide both imageUrl and imageData',
        code: 'INVALID_INPUT',
      );
    }

    // Generate idempotency key
    final idempotencyKey = _generateIdempotencyKey(
      imageUrl ?? base64.encode(imageData!),
    );

    // Check if we can make API call directly
    if (!_connectivity.canMakeApiCall()) {
      // Queue the request for later
      return await _queueReceiptUpload(
        imageUrl: imageUrl,
        imageData: imageData,
        contentType: contentType,
        metadata: metadata,
        idempotencyKey: idempotencyKey,
      );
    }

    // Check rate limit
    final rateLimitCheck = await _rateLimiter.checkLimit('user_${DateTime.now().millisecondsSinceEpoch}');
    if (!rateLimitCheck.allowed) {
      throw ServiceException(
        'Rate limit exceeded. Retry after ${rateLimitCheck.retryAfter.inSeconds} seconds',
        code: 'RATE_LIMIT',
      );
    }

    // Prepare request body
    final Map<String, dynamic> requestBody;
    if (imageUrl != null) {
      requestBody = {
        'source': 'url',
        'url': imageUrl,
        if (metadata != null) 'metadata': metadata,
      };
    } else {
      requestBody = {
        'source': 'base64',
        'contentType': contentType ?? 'image/jpeg',
        'data': base64.encode(imageData!),
        if (metadata != null) 'metadata': metadata,
      };
    }

    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/api/receipts'),
        headers: {
          'Content-Type': 'application/json',
          'Idempotency-Key': idempotencyKey,
        },
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw ServiceException(
          'Request timeout',
          code: 'TIMEOUT',
        ),
      );

      return _handleCreateReceiptResponse(response);
    } catch (e) {
      if (e is ServiceException) rethrow;

      // Network error - queue for retry
      return await _queueReceiptUpload(
        imageUrl: imageUrl,
        imageData: imageData,
        contentType: contentType,
        metadata: metadata,
        idempotencyKey: idempotencyKey,
      );
    }
  }

  /// Get receipt by ID
  ///
  /// Note: This endpoint is not yet implemented in the API
  Future<Receipt?> getReceipt(String receiptId) async {
    if (!_connectivity.canMakeApiCall()) {
      throw ServiceException(
        'Cannot fetch receipt while offline',
        code: 'OFFLINE',
      );
    }

    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/api/receipts/$receiptId'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // TODO: Map API response to Receipt model
        // For now, return null as endpoint doesn't exist yet
        return null;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        _handleErrorResponse(response);
        return null;
      }
    } catch (e) {
      if (e is ServiceException) rethrow;
      throw ServiceException(
        'Failed to fetch receipt: ${e.toString()}',
        code: 'NETWORK_ERROR',
      );
    }
  }

  /// Handle response from create receipt endpoint
  String _handleCreateReceiptResponse(http.Response response) {
    final responseData = json.decode(response.body);

    switch (response.statusCode) {
      case 202: // Accepted
        return responseData['jobId'] as String;

      case 409: // Conflict (duplicate request)
        // Still successful - return the existing job ID
        if (responseData['deduped'] == true) {
          return responseData['jobId'] as String;
        }
        _handleErrorResponse(response);
        throw ServiceException('Unexpected response', code: 'UNKNOWN');

      default:
        _handleErrorResponse(response);
        throw ServiceException('Unexpected response', code: 'UNKNOWN');
    }
  }

  /// Handle RFC9457 Problem Details error responses
  void _handleErrorResponse(http.Response response) {
    try {
      final error = json.decode(response.body);

      // Check if it's an RFC9457 Problem Details response
      if (error['type'] != null) {
        final problemType = error['type'] as String;
        final title = error['title'] ?? 'Error';
        final detail = error['detail'] ?? '';

        // Map problem types to error codes
        String errorCode;
        if (problemType.contains('rate-limit')) {
          errorCode = 'RATE_LIMIT';
        } else if (problemType.contains('validation')) {
          errorCode = 'VALIDATION_ERROR';
        } else if (problemType.contains('auth')) {
          errorCode = 'AUTH_ERROR';
        } else {
          errorCode = 'API_ERROR';
        }

        throw ServiceException(
          detail.isNotEmpty ? detail : title,
          code: errorCode,
        );
      }
    } catch (e) {
      if (e is ServiceException) rethrow;
    }

    // Generic error handling
    throw ServiceException(
      'Request failed with status ${response.statusCode}',
      code: 'HTTP_${response.statusCode}',
    );
  }

  /// Generate idempotency key for a request
  ///
  /// Uses content hash to ensure same content gets same key
  String _generateIdempotencyKey(String content) {
    // Check cache first
    if (_idempotencyCache.containsKey(content)) {
      return _idempotencyCache[content]!;
    }

    // Generate new key
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final key = 'mob_${timestamp}_${_uuid.v4().substring(0, 8)}';

    // Cache it (with size limit)
    if (_idempotencyCache.length > 100) {
      _idempotencyCache.clear();
    }
    _idempotencyCache[content] = key;

    return key;
  }

  /// Queue receipt upload for later processing
  Future<String> _queueReceiptUpload({
    String? imageUrl,
    Uint8List? imageData,
    String? contentType,
    Map<String, dynamic>? metadata,
    required String idempotencyKey,
  }) async {
    // Create a placeholder job ID for tracking
    final jobId = 'pending_${_uuid.v4()}';

    // Prepare request data for queuing
    final requestData = {
      'imageUrl': imageUrl,
      'imageData': imageData != null ? base64.encode(imageData) : null,
      'contentType': contentType,
      'metadata': metadata,
      'idempotencyKey': idempotencyKey,
      'jobId': jobId,
    };

    // Queue the request
    await _requestQueue.queueRequest(
      endpoint: '$_baseUrl/api/receipts',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Idempotency-Key': idempotencyKey,
      },
      body: requestData,
      feature: 'receipt_upload',
    );

    return jobId;
  }

  /// Check job status (placeholder for future implementation)
  Future<Map<String, dynamic>?> getJobStatus(String jobId) async {
    // TODO: Implement when API supports job status endpoint
    // For now, return a mock response
    if (jobId.startsWith('pending_')) {
      return {
        'status': 'pending',
        'message': 'Waiting for network connection',
      };
    }

    return {
      'status': 'processing',
      'message': 'Receipt is being processed',
    };
  }

  /// Clean up resources
  void dispose() {
    _httpClient.close();
    _idempotencyCache.clear();
  }
}