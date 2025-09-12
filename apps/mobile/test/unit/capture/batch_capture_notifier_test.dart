import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:receipt_organizer/data/models/capture_result.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/domain/services/camera_service.dart';
import 'package:receipt_organizer/features/capture/providers/batch_capture_provider.dart';

import 'batch_capture_notifier_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ICameraService>()])
void main() {
  group('BatchCaptureNotifier', () {
    late BatchCaptureNotifier notifier;
    late MockICameraService mockCameraService;

    setUp(() {
      mockCameraService = MockICameraService();
      notifier = BatchCaptureNotifier(mockCameraService);
    });

    test('initial state should be empty', () {
      expect(notifier.state.receipts, isEmpty);
      expect(notifier.state.isBatchMode, false);
      expect(notifier.state.currentBatchId, null);
      expect(notifier.state.batchSize, 0);
      expect(notifier.state.isCapturing, false);
    });

    test('startBatchMode should set batch mode and create batch ID', () {
      notifier.startBatchMode();

      expect(notifier.state.isBatchMode, true);
      expect(notifier.state.currentBatchId, isNotNull);
      expect(notifier.state.receipts, isEmpty);
    });

    test('stopBatchMode should reset batch mode', () {
      notifier.startBatchMode();
      notifier.stopBatchMode();

      expect(notifier.state.isBatchMode, false);
      expect(notifier.state.currentBatchId, null);
    });

    test('captureReceipt should add receipt on successful capture', () async {
      when(mockCameraService.captureReceipt(batchMode: true))
          .thenAnswer((_) async => CaptureResult.success('/path/to/image.jpg'));

      notifier.startBatchMode();
      final result = await notifier.captureReceipt();

      expect(result, true);
      expect(notifier.state.receipts.length, 1);
      expect(notifier.state.batchSize, 1);
      expect(notifier.state.receipts.first.imageUri, '/path/to/image.jpg');
      expect(notifier.state.receipts.first.batchId, notifier.state.currentBatchId);
    });

    test('captureReceipt should return false on camera failure', () async {
      when(mockCameraService.captureReceipt(batchMode: true))
          .thenAnswer((_) async => CaptureResult.error('Camera error'));

      notifier.startBatchMode();
      final result = await notifier.captureReceipt();

      expect(result, false);
      expect(notifier.state.receipts, isEmpty);
    });

    test('captureReceipt should prevent concurrent captures', () async {
      when(mockCameraService.captureReceipt(batchMode: true))
          .thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return CaptureResult.success('/path/to/image.jpg');
          });

      notifier.startBatchMode();
      
      final future1 = notifier.captureReceipt();
      final future2 = notifier.captureReceipt();

      final results = await Future.wait([future1, future2]);

      expect(results.where((r) => r == true).length, 1);
      expect(results.where((r) => r == false).length, 1);
      expect(notifier.state.receipts.length, 1);
    });

    test('removeReceipt should remove receipt from list', () async {
      when(mockCameraService.captureReceipt(batchMode: true))
          .thenAnswer((_) async => CaptureResult.success('/path/to/image.jpg'));

      notifier.startBatchMode();
      await notifier.captureReceipt();
      
      final receiptId = notifier.state.receipts.first.id;
      notifier.removeReceipt(receiptId);

      expect(notifier.state.receipts, isEmpty);
      expect(notifier.state.batchSize, 0);
    });

    test('reorderReceipts should change receipt order', () async {
      int callCount = 0;
      when(mockCameraService.captureReceipt(batchMode: true))
          .thenAnswer((_) async {
            callCount++;
            return CaptureResult.success('/path/to/image$callCount.jpg');
          });

      notifier.startBatchMode();
      await notifier.captureReceipt();
      await notifier.captureReceipt();

      final firstReceiptId = notifier.state.receipts.first.id;
      final secondReceiptId = notifier.state.receipts.last.id;

      // ReorderableListView semantics: to move item from index 0 to after index 1, use newIndex=2
      notifier.reorderReceipts(0, 2);

      expect(notifier.state.receipts.first.id, secondReceiptId);
      expect(notifier.state.receipts.last.id, firstReceiptId);
    });

    test('clearBatch should reset all batch state', () async {
      when(mockCameraService.captureReceipt(batchMode: true))
          .thenAnswer((_) async => CaptureResult.success('/path/to/image.jpg'));

      notifier.startBatchMode();
      await notifier.captureReceipt();
      
      notifier.clearBatch();

      expect(notifier.state.receipts, isEmpty);
      expect(notifier.state.isBatchMode, false);
      expect(notifier.state.currentBatchId, null);
      expect(notifier.state.batchSize, 0);
    });

    test('batch capture should handle multiple receipts correctly', () async {
      const int numberOfReceipts = 5;
      
      for (int i = 0; i < numberOfReceipts; i++) {
        when(mockCameraService.captureReceipt(batchMode: true))
            .thenAnswer((_) async => CaptureResult.success('/path/to/image$i.jpg'));
      }

      notifier.startBatchMode();
      final batchId = notifier.state.currentBatchId;

      for (int i = 0; i < numberOfReceipts; i++) {
        final result = await notifier.captureReceipt();
        expect(result, true);
      }

      expect(notifier.state.batchSize, numberOfReceipts);
      expect(notifier.state.receipts.length, numberOfReceipts);
      
      for (final receipt in notifier.state.receipts) {
        expect(receipt.batchId, batchId);
        expect(receipt.status, ReceiptStatus.captured);
      }
    });
  });
}