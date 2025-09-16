import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/receipt.dart';

class BatchCaptureState {
  final List<String> capturedImages;
  final bool isProcessing;
  final int currentIndex;
  final List<Receipt> receipts;
  final int batchSize;
  final bool isCapturing;

  BatchCaptureState({
    required this.capturedImages,
    required this.isProcessing,
    required this.currentIndex,
    required this.receipts,
    required this.batchSize,
    required this.isCapturing,
  });

  BatchCaptureState copyWith({
    List<String>? capturedImages,
    bool? isProcessing,
    int? currentIndex,
    List<Receipt>? receipts,
    int? batchSize,
    bool? isCapturing,
  }) {
    return BatchCaptureState(
      capturedImages: capturedImages ?? this.capturedImages,
      isProcessing: isProcessing ?? this.isProcessing,
      currentIndex: currentIndex ?? this.currentIndex,
      receipts: receipts ?? this.receipts,
      batchSize: batchSize ?? this.batchSize,
      isCapturing: isCapturing ?? this.isCapturing,
    );
  }
}

class BatchCaptureNotifier extends StateNotifier<BatchCaptureState> {
  BatchCaptureNotifier()
      : super(BatchCaptureState(
          capturedImages: [],
          isProcessing: false,
          currentIndex: 0,
          receipts: [],
          batchSize: 10, // Default batch size
          isCapturing: false,
        ));

  void startBatchMode({int size = 10}) {
    state = state.copyWith(
      batchSize: size,
      isCapturing: true,
      receipts: [],
      capturedImages: [],
      currentIndex: 0,
    );
  }

  void captureReceipt(String imagePath) {
    // Create a new receipt from the image
    final receipt = Receipt(
      imageUri: imagePath,
      status: ReceiptStatus.captured,
      batchId: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    state = state.copyWith(
      receipts: [...state.receipts, receipt],
      capturedImages: [...state.capturedImages, imagePath],
      currentIndex: state.currentIndex + 1,
    );

    // Stop capturing if batch size reached
    if (state.receipts.length >= state.batchSize) {
      state = state.copyWith(isCapturing: false);
    }
  }

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

  void removeReceipt(int index) {
    if (index >= 0 && index < state.receipts.length) {
      final updatedReceipts = List<Receipt>.from(state.receipts);
      final updatedImages = List<String>.from(state.capturedImages);

      updatedReceipts.removeAt(index);
      if (index < updatedImages.length) {
        updatedImages.removeAt(index);
      }

      state = state.copyWith(
        receipts: updatedReceipts,
        capturedImages: updatedImages,
      );
    }
  }

  void restoreReceipt(Receipt receipt, int index) {
    final updatedReceipts = List<Receipt>.from(state.receipts);
    if (index >= 0 && index <= updatedReceipts.length) {
      updatedReceipts.insert(index, receipt);

      final updatedImages = List<String>.from(state.capturedImages);
      updatedImages.insert(index, receipt.imageUri);

      state = state.copyWith(
        receipts: updatedReceipts,
        capturedImages: updatedImages,
      );
    }
  }

  void clearBatch() {
    state = state.copyWith(
      receipts: [],
      capturedImages: [],
      currentIndex: 0,
      isCapturing: false,
    );
  }

  void reorderReceipts(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final updatedReceipts = List<Receipt>.from(state.receipts);
    final receipt = updatedReceipts.removeAt(oldIndex);
    updatedReceipts.insert(newIndex, receipt);

    final updatedImages = List<String>.from(state.capturedImages);
    if (oldIndex < updatedImages.length) {
      final image = updatedImages.removeAt(oldIndex);
      updatedImages.insert(newIndex, image);
    }

    state = state.copyWith(
      receipts: updatedReceipts,
      capturedImages: updatedImages,
    );
  }

  void clear() {
    state = state.copyWith(capturedImages: [], receipts: []);
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