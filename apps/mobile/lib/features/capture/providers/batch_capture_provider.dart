import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/domain/services/camera_service.dart';
import 'package:uuid/uuid.dart';

class BatchCaptureState {
  final List<Receipt> receipts;
  final String? currentBatchId;
  final bool isBatchMode;
  final bool isCapturing;

  BatchCaptureState({
    this.receipts = const [],
    this.currentBatchId,
    this.isBatchMode = false,
    this.isCapturing = false,
  });

  BatchCaptureState copyWith({
    List<Receipt>? receipts,
    String? currentBatchId,
    bool? isBatchMode,
    bool? isCapturing,
  }) {
    return BatchCaptureState(
      receipts: receipts ?? this.receipts,
      currentBatchId: currentBatchId ?? this.currentBatchId,
      isBatchMode: isBatchMode ?? this.isBatchMode,
      isCapturing: isCapturing ?? this.isCapturing,
    );
  }

  int get batchSize => receipts.length;
}

class BatchCaptureNotifier extends StateNotifier<BatchCaptureState> {
  final ICameraService _cameraService;

  BatchCaptureNotifier(this._cameraService) : super(BatchCaptureState());

  void startBatchMode() {
    final batchId = const Uuid().v4();
    state = state.copyWith(
      isBatchMode: true,
      currentBatchId: batchId,
      receipts: [],
    );
  }

  void stopBatchMode() {
    state = state.copyWith(
      isBatchMode: false,
      currentBatchId: null,
    );
  }

  Future<bool> captureReceipt() async {
    if (state.isCapturing) return false;

    state = state.copyWith(isCapturing: true);

    try {
      final result = await _cameraService.captureReceipt(
        batchMode: state.isBatchMode,
      );

      if (result.success && result.imageUri != null) {
        final receipt = Receipt(
          imageUri: result.imageUri!,
          thumbnailUri: result.thumbnailUri,
          batchId: state.currentBatchId,
          status: result.ocrResults != null ? ReceiptStatus.ready : ReceiptStatus.captured,
          ocrResults: result.ocrResults,
        );

        final updatedReceipts = [...state.receipts, receipt];
        state = state.copyWith(
          receipts: updatedReceipts,
          isCapturing: false,
        );
        return true;
      } else {
        state = state.copyWith(isCapturing: false);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isCapturing: false);
      return false;
    }
  }

  void removeReceipt(String receiptId) {
    final updatedReceipts = state.receipts
        .where((receipt) => receipt.id != receiptId)
        .toList();
    
    state = state.copyWith(receipts: updatedReceipts);
  }

  void restoreReceipt(Receipt receipt) {
    final updatedReceipts = [...state.receipts, receipt];
    state = state.copyWith(receipts: updatedReceipts);
  }

  void reorderReceipts(int oldIndex, int newIndex) {
    final receipts = List<Receipt>.from(state.receipts);
    if (newIndex > oldIndex) {
      newIndex--;
    }
    final item = receipts.removeAt(oldIndex);
    receipts.insert(newIndex, item);
    
    state = state.copyWith(receipts: receipts);
  }

  void clearBatch() {
    state = state.copyWith(
      receipts: [],
      isBatchMode: false,
      currentBatchId: null,
    );
  }
}

final cameraServiceProvider = Provider<ICameraService>((ref) {
  return CameraService();
});

final batchCaptureProvider = StateNotifierProvider<BatchCaptureNotifier, BatchCaptureState>((ref) {
  final cameraService = ref.read(cameraServiceProvider);
  return BatchCaptureNotifier(cameraService);
});