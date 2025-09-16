import 'package:flutter_riverpod/flutter_riverpod.dart';

class BatchCaptureState {
  final List<String> capturedImages;
  final bool isProcessing;
  final int currentIndex;

  BatchCaptureState({
    required this.capturedImages,
    required this.isProcessing,
    required this.currentIndex,
  });

  BatchCaptureState copyWith({
    List<String>? capturedImages,
    bool? isProcessing,
    int? currentIndex,
  }) {
    return BatchCaptureState(
      capturedImages: capturedImages ?? this.capturedImages,
      isProcessing: isProcessing ?? this.isProcessing,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class BatchCaptureNotifier extends StateNotifier<BatchCaptureState> {
  BatchCaptureNotifier()
      : super(BatchCaptureState(
          capturedImages: [],
          isProcessing: false,
          currentIndex: 0,
        ));

  void addImage(String imagePath) {
    state = state.copyWith(
      capturedImages: [...state.capturedImages, imagePath],
    );
  }

  void removeImage(int index) {
    final updated = List<String>.from(state.capturedImages);
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
      state = state.copyWith(capturedImages: updated);
    }
  }

  void clear() {
    state = state.copyWith(capturedImages: []);
  }

  void setProcessing(bool processing) {
    state = state.copyWith(isProcessing: processing);
  }

  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  bool get hasCaptured => state.capturedImages.isNotEmpty;
  int get captureCount => state.capturedImages.length;
}

final batchCaptureProvider = StateNotifierProvider<BatchCaptureNotifier, BatchCaptureState>((ref) {
  return BatchCaptureNotifier();
});