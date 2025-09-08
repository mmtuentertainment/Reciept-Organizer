import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:receipt_organizer/data/models/edge_detection_result.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';

/// Manages retry session persistence and cleanup
class RetrySessionManager {
  static const String _sessionDir = 'retry_sessions';
  static const String _sessionFile = 'session.json';
  static const String _imageFile = 'capture.jpg';
  static const Duration _sessionTimeout = Duration(hours: 24);

  /// Saves current retry session to persistent storage
  Future<bool> saveSession(RetrySession session) async {
    try {
      final sessionDir = await _getSessionDirectory(session.sessionId);
      await sessionDir.create(recursive: true);

      // Save session metadata
      final sessionFile = File('${sessionDir.path}/$_sessionFile');
      final sessionData = {
        'sessionId': session.sessionId,
        'retryCount': session.retryCount,
        'maxRetryAttempts': session.maxRetryAttempts,
        'lastFailureReason': session.lastFailureReason?.name,
        'lastFailureMessage': session.lastFailureMessage,
        'timestamp': session.timestamp.toIso8601String(),
        'preservedEdgeDetection': session.preservedEdgeDetection?.toJson(),
        'lastProcessingResult': session.lastProcessingResult?.toJson(),
      };

      await sessionFile.writeAsString(jsonEncode(sessionData));

      // Save image data if present
      if (session.imageData != null) {
        final imageFile = File('${sessionDir.path}/$_imageFile');
        await imageFile.writeAsBytes(session.imageData!);
      }

      debugPrint('RetrySession saved: ${session.sessionId}');
      return true;

    } catch (e) {
      debugPrint('Failed to save retry session: $e');
      return false;
    }
  }

  /// Loads retry session from persistent storage
  Future<RetrySession?> loadSession(String sessionId) async {
    try {
      final sessionDir = await _getSessionDirectory(sessionId);
      final sessionFile = File('${sessionDir.path}/$_sessionFile');

      if (!await sessionFile.exists()) {
        return null;
      }

      // Check if session has expired
      final sessionData = jsonDecode(await sessionFile.readAsString());
      final timestamp = DateTime.parse(sessionData['timestamp']);
      if (DateTime.now().difference(timestamp) > _sessionTimeout) {
        // Clean up expired session
        await cleanupSession(sessionId);
        return null;
      }

      // Load image data
      Uint8List? imageData;
      final imageFile = File('${sessionDir.path}/$_imageFile');
      if (await imageFile.exists()) {
        imageData = await imageFile.readAsBytes();
      }

      // Parse failure reason
      FailureReason? failureReason;
      if (sessionData['lastFailureReason'] != null) {
        failureReason = FailureReason.values.firstWhere(
          (reason) => reason.name == sessionData['lastFailureReason'],
        );
      }

      // Parse edge detection result
      EdgeDetectionResult? edgeDetection;
      if (sessionData['preservedEdgeDetection'] != null) {
        edgeDetection = EdgeDetectionResult.fromJson(
          sessionData['preservedEdgeDetection'],
        );
      }

      // Parse processing result
      ProcessingResult? processingResult;
      if (sessionData['lastProcessingResult'] != null) {
        processingResult = ProcessingResult.fromJson(
          sessionData['lastProcessingResult'],
        );
      }

      return RetrySession(
        sessionId: sessionData['sessionId'],
        retryCount: sessionData['retryCount'],
        maxRetryAttempts: sessionData['maxRetryAttempts'] ?? 5,
        lastFailureReason: failureReason,
        lastFailureMessage: sessionData['lastFailureMessage'],
        timestamp: timestamp,
        imageData: imageData,
        preservedEdgeDetection: edgeDetection,
        lastProcessingResult: processingResult,
      );

    } catch (e) {
      debugPrint('Failed to load retry session: $e');
      return null;
    }
  }

  /// Cleans up session data and temporary files
  Future<bool> cleanupSession(String sessionId) async {
    try {
      final sessionDir = await _getSessionDirectory(sessionId);
      
      if (await sessionDir.exists()) {
        await sessionDir.delete(recursive: true);
        debugPrint('RetrySession cleaned up: $sessionId');
      }
      
      return true;
      
    } catch (e) {
      debugPrint('Failed to cleanup retry session: $e');
      return false;
    }
  }

  /// Cleans up all expired sessions
  Future<int> cleanupExpiredSessions() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final retryDir = Directory('${appDir.path}/$_sessionDir');
      
      if (!await retryDir.exists()) {
        return 0;
      }

      int cleanedCount = 0;
      final sessionDirs = retryDir.listSync().whereType<Directory>();
      
      for (final sessionDir in sessionDirs) {
        final sessionFile = File('${sessionDir.path}/$_sessionFile');
        
        if (await sessionFile.exists()) {
          try {
            final sessionData = jsonDecode(await sessionFile.readAsString());
            final timestamp = DateTime.parse(sessionData['timestamp']);
            
            if (DateTime.now().difference(timestamp) > _sessionTimeout) {
              await sessionDir.delete(recursive: true);
              cleanedCount++;
            }
          } catch (e) {
            // If we can't parse the session, clean it up anyway
            await sessionDir.delete(recursive: true);
            cleanedCount++;
          }
        } else {
          // Session directory without session file - cleanup
          await sessionDir.delete(recursive: true);
          cleanedCount++;
        }
      }

      if (cleanedCount > 0) {
        debugPrint('Cleaned up $cleanedCount expired retry sessions');
      }
      
      return cleanedCount;
      
    } catch (e) {
      debugPrint('Failed to cleanup expired sessions: $e');
      return 0;
    }
  }

  /// Lists all active sessions
  Future<List<String>> getActiveSessions() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final retryDir = Directory('${appDir.path}/$_sessionDir');
      
      if (!await retryDir.exists()) {
        return [];
      }

      final sessionIds = <String>[];
      final sessionDirs = retryDir.listSync().whereType<Directory>();
      
      for (final sessionDir in sessionDirs) {
        final sessionFile = File('${sessionDir.path}/$_sessionFile');
        
        if (await sessionFile.exists()) {
          try {
            final sessionData = jsonDecode(await sessionFile.readAsString());
            final timestamp = DateTime.parse(sessionData['timestamp']);
            
            // Only include non-expired sessions
            if (DateTime.now().difference(timestamp) <= _sessionTimeout) {
              sessionIds.add(sessionData['sessionId']);
            }
          } catch (e) {
            // Skip invalid sessions
            continue;
          }
        }
      }
      
      return sessionIds;
      
    } catch (e) {
      debugPrint('Failed to get active sessions: $e');
      return [];
    }
  }

  /// Gets the storage size used by retry sessions
  Future<int> getStorageUsage() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final retryDir = Directory('${appDir.path}/$_sessionDir');
      
      if (!await retryDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      
      final allFiles = retryDir.listSync(recursive: true).whereType<File>();
      for (final file in allFiles) {
        totalSize += await file.length();
      }
      
      return totalSize;
      
    } catch (e) {
      debugPrint('Failed to calculate storage usage: $e');
      return 0;
    }
  }

  Future<Directory> _getSessionDirectory(String sessionId) async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/$_sessionDir/$sessionId');
  }
}

/// Represents a persisted retry session
class RetrySession {
  final String sessionId;
  final int retryCount;
  final int maxRetryAttempts;
  final FailureReason? lastFailureReason;
  final String? lastFailureMessage;
  final DateTime timestamp;
  final Uint8List? imageData;
  final EdgeDetectionResult? preservedEdgeDetection;
  final ProcessingResult? lastProcessingResult;

  RetrySession({
    required this.sessionId,
    required this.retryCount,
    this.maxRetryAttempts = 5,
    this.lastFailureReason,
    this.lastFailureMessage,
    required this.timestamp,
    this.imageData,
    this.preservedEdgeDetection,
    this.lastProcessingResult,
  });

  bool get hasReachedMaxRetries => retryCount >= maxRetryAttempts;
  bool get canRetry => !hasReachedMaxRetries && lastFailureReason != null;
  int get attemptsRemaining => (maxRetryAttempts - retryCount).clamp(0, maxRetryAttempts);
  bool get isExpired => DateTime.now().difference(timestamp) > const Duration(hours: 24);
}

// Extension methods for serialization
extension ProcessingResultSerialization on ProcessingResult {
  Map<String, dynamic> toJson() {
    return {
      'merchant': merchant?.toJson(),
      'date': date?.toJson(),
      'total': total?.toJson(),
      'tax': tax?.toJson(),
      'overallConfidence': overallConfidence,
      'processingEngine': processingEngine,
      'processingDurationMs': processingDurationMs,
      'allText': allText,
    };
  }

  static ProcessingResult fromJson(Map<String, dynamic> json) {
    return ProcessingResult(
      merchant: json['merchant'] != null ? FieldData.fromJson(json['merchant']) : null,
      date: json['date'] != null ? FieldData.fromJson(json['date']) : null,
      total: json['total'] != null ? FieldData.fromJson(json['total']) : null,
      tax: json['tax'] != null ? FieldData.fromJson(json['tax']) : null,
      overallConfidence: json['overallConfidence'],
      processingEngine: json['processingEngine'],
      processingDurationMs: json['processingDurationMs'],
      allText: List<String>.from(json['allText'] ?? []),
    );
  }
}

extension FieldDataSerialization on FieldData {
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'confidence': confidence,
      'originalText': originalText,
      'isManuallyEdited': isManuallyEdited,
      'validationStatus': validationStatus,
    };
  }

  static FieldData fromJson(Map<String, dynamic> json) {
    return FieldData(
      value: json['value'],
      confidence: json['confidence'],
      originalText: json['originalText'],
      isManuallyEdited: json['isManuallyEdited'] ?? false,
      validationStatus: json['validationStatus'] ?? 'valid',
    );
  }
}

extension EdgeDetectionResultSerialization on EdgeDetectionResult {
  Map<String, dynamic> toJson() {
    // Implementation would depend on the actual EdgeDetectionResult structure
    // Placeholder implementation
    return {
      'corners': [], // Would serialize corner points
      'confidence': 1.0, // Would serialize detection confidence
    };
  }

  static EdgeDetectionResult fromJson(Map<String, dynamic> json) {
    // Implementation would depend on the actual EdgeDetectionResult structure
    // Placeholder implementation - should be replaced with actual deserialization
    throw UnimplementedError('EdgeDetectionResult deserialization not implemented');
  }
}