import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/data/models/edge_detection_result.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:receipt_organizer/domain/services/camera_service.dart';
import 'package:receipt_organizer/features/capture/services/retry_session_manager.dart';

/// Current state of the capture process including retry tracking
class CaptureState {
  final bool isProcessing;
  final bool isRetryMode;
  final int retryCount;
  final int maxRetryAttempts;
  final FailureReason? lastFailureReason;
  final String? lastFailureMessage;
  final EdgeDetectionResult? preservedEdgeDetection;
  final Uint8List? currentImageData;
  final ProcessingResult? lastProcessingResult;
  final FailureDetectionResult? lastFailureDetection;
  final String? sessionId;

  const CaptureState({
    this.isProcessing = false,
    this.isRetryMode = false,
    this.retryCount = 0,
    this.maxRetryAttempts = 5,
    this.lastFailureReason,
    this.lastFailureMessage,
    this.preservedEdgeDetection,
    this.currentImageData,
    this.lastProcessingResult,
    this.lastFailureDetection,
    this.sessionId,
  });

  CaptureState copyWith({
    bool? isProcessing,
    bool? isRetryMode,
    int? retryCount,
    int? maxRetryAttempts,
    FailureReason? lastFailureReason,
    String? lastFailureMessage,
    EdgeDetectionResult? preservedEdgeDetection,
    Uint8List? currentImageData,
    ProcessingResult? lastProcessingResult,
    FailureDetectionResult? lastFailureDetection,
    String? sessionId,
    bool clearFailure = false,
    bool clearImageData = false,
    bool clearEdgeDetection = false,
  }) {
    return CaptureState(
      isProcessing: isProcessing ?? this.isProcessing,
      isRetryMode: isRetryMode ?? this.isRetryMode,
      retryCount: retryCount ?? this.retryCount,
      maxRetryAttempts: maxRetryAttempts ?? this.maxRetryAttempts,
      lastFailureReason: clearFailure ? null : (lastFailureReason ?? this.lastFailureReason),
      lastFailureMessage: clearFailure ? null : (lastFailureMessage ?? this.lastFailureMessage),
      preservedEdgeDetection: clearEdgeDetection ? null : (preservedEdgeDetection ?? this.preservedEdgeDetection),
      currentImageData: clearImageData ? null : (currentImageData ?? this.currentImageData),
      lastProcessingResult: lastProcessingResult ?? this.lastProcessingResult,
      lastFailureDetection: lastFailureDetection ?? this.lastFailureDetection,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  bool get hasReachedMaxRetries => retryCount >= maxRetryAttempts;
  bool get canRetry => !hasReachedMaxRetries && lastFailureReason != null;
  int get attemptsRemaining => (maxRetryAttempts - retryCount).clamp(0, maxRetryAttempts);
}

class CaptureNotifier extends StateNotifier<CaptureState> {
  final OCRService _ocrService;
  final ICameraService _cameraService;
  final RetrySessionManager _sessionManager;

  CaptureNotifier({
    required OCRService ocrService,
    required ICameraService cameraService,
    required RetrySessionManager sessionManager,
  }) : _ocrService = ocrService, 
       _cameraService = cameraService,
       _sessionManager = sessionManager,
       super(const CaptureState()) {
    // Clean up expired sessions on initialization
    _cleanupExpiredSessions();
  }

  /// Starts a new capture session
  void startCaptureSession({String? sessionId}) {
    state = CaptureState(
      sessionId: sessionId ?? DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  /// Processes captured image data and detects failures
  Future<bool> processCapture(
    Uint8List imageData, {
    EdgeDetectionResult? edgeDetection,
    bool isRetryAttempt = false,
  }) async {
    if (state.isProcessing) return false;

    state = state.copyWith(
      isProcessing: true,
      currentImageData: imageData,
      preservedEdgeDetection: edgeDetection,
    );

    try {
      // Process with OCR
      final processingResult = await _ocrService.processReceipt(imageData);
      
      // Detect if this capture failed
      final failureDetection = _ocrService.detectFailure(processingResult, imageData);

      if (failureDetection.isFailure && failureDetection.reason != null) {
        // Capture failed - prepare for retry
        final newRetryCount = isRetryAttempt ? state.retryCount + 1 : 1;
        
        state = state.copyWith(
          isProcessing: false,
          isRetryMode: true,
          retryCount: newRetryCount,
          lastFailureReason: failureDetection.reason,
          lastFailureMessage: failureDetection.reason!.userMessage,
          lastProcessingResult: processingResult,
          lastFailureDetection: failureDetection,
        );

        // Save session for retry persistence
        await saveSession();

        return false; // Indicate failure to caller
      } else {
        // Success - clear retry state
        state = state.copyWith(
          isProcessing: false,
          isRetryMode: false,
          lastProcessingResult: processingResult,
          lastFailureDetection: failureDetection,
          clearFailure: true,
        );

        return true; // Indicate success to caller
      }

    } catch (e) {
      // Processing error
      final newRetryCount = isRetryAttempt ? state.retryCount + 1 : 1;
      
      state = state.copyWith(
        isProcessing: false,
        isRetryMode: true,
        retryCount: newRetryCount,
        lastFailureReason: FailureReason.processingError,
        lastFailureMessage: 'Processing failed - please retry',
        lastProcessingResult: null,
        lastFailureDetection: FailureDetectionResult.failure(
          FailureReason.processingError,
          0.0,
          diagnostics: {'error': e.toString()},
        ),
      );

      // Save session for retry persistence
      await saveSession();

      return false;
    }
  }

  /// Initiates a retry attempt
  Future<bool> retryCapture() async {
    if (!state.canRetry || state.currentImageData == null) {
      return false;
    }

    // Reprocess the same image data
    return await processCapture(
      state.currentImageData!,
      edgeDetection: state.preservedEdgeDetection,
      isRetryAttempt: true,
    );
  }

  /// Initiates a fresh capture (retake photo)
  void retakePhoto() {
    state = state.copyWith(
      isRetryMode: false,
      clearImageData: true,
      clearFailure: true,
      // Preserve retry count and edge detection from session
    );
  }

  /// Cancels the retry flow and resets session
  void cancelRetry() {
    state = state.copyWith(
      isRetryMode: false,
      retryCount: 0,
      clearFailure: true,
      clearImageData: true,
      clearEdgeDetection: true,
    );
  }

  /// Saves current session to persistent storage
  Future<void> saveSession() async {
    if (state.sessionId == null || !state.isRetryMode) return;

    final session = RetrySession(
      sessionId: state.sessionId!,
      retryCount: state.retryCount,
      maxRetryAttempts: state.maxRetryAttempts,
      lastFailureReason: state.lastFailureReason,
      lastFailureMessage: state.lastFailureMessage,
      timestamp: DateTime.now(),
      imageData: state.currentImageData,
      preservedEdgeDetection: state.preservedEdgeDetection,
      lastProcessingResult: state.lastProcessingResult,
    );

    await _sessionManager.saveSession(session);
  }

  /// Restores session from persistent storage
  Future<bool> restoreSession(String sessionId) async {
    final session = await _sessionManager.loadSession(sessionId);
    if (session == null || session.isExpired) {
      return false;
    }

    state = CaptureState(
      sessionId: session.sessionId,
      retryCount: session.retryCount,
      maxRetryAttempts: session.maxRetryAttempts,
      isRetryMode: session.lastFailureReason != null,
      lastFailureReason: session.lastFailureReason,
      lastFailureMessage: session.lastFailureMessage,
      currentImageData: session.imageData,
      preservedEdgeDetection: session.preservedEdgeDetection,
      lastProcessingResult: session.lastProcessingResult,
      lastFailureDetection: session.lastProcessingResult != null && session.imageData != null
          ? _ocrService.detectFailure(session.lastProcessingResult!, session.imageData!)
          : null,
    );

    return true;
  }

  /// Clears current capture session and cleanup persistent data
  Future<void> clearSession() async {
    if (state.sessionId != null) {
      await _sessionManager.cleanupSession(state.sessionId!);
    }
    state = const CaptureState();
  }

  /// Updates preserved edge detection result and saves session
  Future<void> updateEdgeDetection(EdgeDetectionResult edgeDetection) async {
    state = state.copyWith(preservedEdgeDetection: edgeDetection);
    await saveSession();
  }

  /// Gets list of active retry sessions
  Future<List<String>> getActiveSessions() async {
    return await _sessionManager.getActiveSessions();
  }

  /// Gets storage usage by retry sessions
  Future<int> getStorageUsage() async {
    return await _sessionManager.getStorageUsage();
  }

  /// Internal method to clean up expired sessions
  Future<void> _cleanupExpiredSessions() async {
    await _sessionManager.cleanupExpiredSessions();
  }
}

// Provider definitions
final ocrServiceProvider = Provider<OCRService>((ref) {
  return OCRService();
});

final cameraServiceProvider = Provider<ICameraService>((ref) {
  return CameraService();
});

final retrySessionManagerProvider = Provider<RetrySessionManager>((ref) {
  return RetrySessionManager();
});

final captureProvider = StateNotifierProvider<CaptureNotifier, CaptureState>((ref) {
  final ocrService = ref.read(ocrServiceProvider);
  final cameraService = ref.read(cameraServiceProvider);
  final sessionManager = ref.read(retrySessionManagerProvider);
  
  return CaptureNotifier(
    ocrService: ocrService,
    cameraService: cameraService,
    sessionManager: sessionManager,
  );
});