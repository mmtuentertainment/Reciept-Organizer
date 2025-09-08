import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/capture/providers/capture_provider.dart';
import 'package:receipt_organizer/features/capture/providers/image_storage_provider.dart';

/// Parameters for preview screen initialization
@immutable
class PreviewInitParams {
  final Uint8List imageData;
  final String? sessionId;
  
  const PreviewInitParams({
    required this.imageData,
    this.sessionId,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreviewInitParams &&
          runtimeType == other.runtimeType &&
          imageData == other.imageData &&
          sessionId == other.sessionId;
  
  @override
  int get hashCode => imageData.hashCode ^ sessionId.hashCode;
}

/// State representing the initialized preview screen
@immutable
class PreviewInitState {
  final String imagePath;
  final String sessionId;
  final bool isReady;
  final bool isProcessing;
  final String? error;
  
  const PreviewInitState({
    required this.imagePath,
    required this.sessionId,
    this.isReady = true,
    this.isProcessing = false,
    this.error,
  });
  
  factory PreviewInitState.loading() => const PreviewInitState(
    imagePath: '',
    sessionId: '',
    isReady: false,
    isProcessing: true,
  );
  
  factory PreviewInitState.error(String error) => PreviewInitState(
    imagePath: '',
    sessionId: '',
    isReady: false,
    error: error,
  );
  
  PreviewInitState copyWith({
    String? imagePath,
    String? sessionId,
    bool? isReady,
    bool? isProcessing,
    String? error,
  }) {
    return PreviewInitState(
      imagePath: imagePath ?? this.imagePath,
      sessionId: sessionId ?? this.sessionId,
      isReady: isReady ?? this.isReady,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error ?? this.error,
    );
  }
}

/// Provider that handles preview screen initialization without side effects
final previewInitializationProvider = FutureProvider.family<PreviewInitState, PreviewInitParams>((ref, params) async {
  try {
    // Get required services
    final imageStorage = ref.read(imageStorageServiceProvider);
    // final captureNotifier = ref.read(captureProvider.notifier);
    
    // Save image to temporary file
    final imagePath = await imageStorage.saveTemporary(params.imageData);
    
    // Generate session ID if not provided
    final sessionId = params.sessionId ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    // Initialize capture session state without side effects
    // Note: We don't call startCaptureSession here as it modifies state
    // Instead, we return the initialization data for the UI to use
    
    return PreviewInitState(
      imagePath: imagePath,
      sessionId: sessionId,
      isReady: true,
    );
  } catch (e) {
    return PreviewInitState.error(e.toString());
  }
});

/// Provider that manages preview screen processing state
class PreviewProcessingNotifier extends StateNotifier<PreviewInitState> {
  final Ref ref;
  final PreviewInitParams params;
  
  PreviewProcessingNotifier({
    required this.ref,
    required this.params,
  }) : super(PreviewInitState.loading());
  
  /// Initialize the preview screen without side effects
  Future<void> initialize() async {
    try {
      state = PreviewInitState.loading();
      
      final imageStorage = ref.read(imageStorageServiceProvider);
      
      // Save image
      final imagePath = await imageStorage.saveTemporary(params.imageData);
      final sessionId = params.sessionId ?? DateTime.now().millisecondsSinceEpoch.toString();
      
      state = PreviewInitState(
        imagePath: imagePath,
        sessionId: sessionId,
        isReady: true,
      );
    } catch (e) {
      state = PreviewInitState.error(e.toString());
    }
  }
  
  /// Start processing after initialization
  Future<void> startProcessing() async {
    if (!state.isReady || state.isProcessing) return;
    
    state = state.copyWith(isProcessing: true);
    
    final captureNotifier = ref.read(captureProvider.notifier);
    
    // Start or restore session
    if (params.sessionId != null) {
      final restored = await captureNotifier.restoreSession(params.sessionId!);
      if (!restored) {
        captureNotifier.startCaptureSession(sessionId: params.sessionId);
      }
    } else {
      captureNotifier.startCaptureSession(sessionId: state.sessionId);
    }
    
    // Process the capture
    await captureNotifier.processCapture(params.imageData);
    
    state = state.copyWith(isProcessing: false);
  }
  
  /// Clean up resources
  @override
  Future<void> dispose() async {
    final imageStorage = ref.read(imageStorageServiceProvider);
    if (state.imagePath.isNotEmpty) {
      await imageStorage.deleteTemporary(state.imagePath);
    }
    super.dispose();
  }
}

/// Provider for preview processing state
final previewProcessingProvider = StateNotifierProvider.family<PreviewProcessingNotifier, PreviewInitState, PreviewInitParams>((ref, params) {
  return PreviewProcessingNotifier(ref: ref, params: params);
});