import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:receipt_organizer/features/capture/providers/batch_capture_provider.dart';
import 'package:receipt_organizer/domain/services/camera_service.dart';
import 'package:receipt_organizer/data/models/capture_result.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';

// Generate mocks
@GenerateNiceMocks([MockSpec<ICameraService>()])
import 'batch_capture_provider_test.mocks.dart';

void main() {
  group('BatchCaptureProvider', () {
    late ProviderContainer container;
    late MockICameraService mockCameraService;

    setUp(() {
      mockCameraService = MockICameraService();
      
      container = ProviderContainer(
        overrides: [
          cameraServiceProvider.overrideWithValue(mockCameraService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State', () {
      test('should have correct initial state', () {
        final state = container.read(batchCaptureProvider);
        
        expect(state.receipts, isEmpty);
        expect(state.currentBatchId, isNull);
        expect(state.isBatchMode, isFalse);
        expect(state.isCapturing, isFalse);
        expect(state.batchSize, equals(0));
      });
    });

    group('Batch Mode Management', () {
      test('should start batch mode correctly', () {
        final notifier = container.read(batchCaptureProvider.notifier);
        
        notifier.startBatchMode();
        
        final state = container.read(batchCaptureProvider);
        expect(state.isBatchMode, isTrue);
        expect(state.currentBatchId, isNotNull);
        expect(state.receipts, isEmpty);
      });

      test('should stop batch mode correctly', () {
        final notifier = container.read(batchCaptureProvider.notifier);
        
        // Start then stop batch mode
        notifier.startBatchMode();
        notifier.stopBatchMode();
        
        final state = container.read(batchCaptureProvider);
        expect(state.isBatchMode, isFalse);
        expect(state.currentBatchId, isNull);
      });

      test('should clear batch correctly', () {
        final notifier = container.read(batchCaptureProvider.notifier);
        
        // Start batch mode and add some receipts
        notifier.startBatchMode();
        
        // Mock a successful capture
        when(mockCameraService.captureReceipt(batchMode: true))
            .thenAnswer((_) async => CaptureResult.success('/path/to/image.jpg'));
        
        // Clear batch
        notifier.clearBatch();
        
        final state = container.read(batchCaptureProvider);
        expect(state.receipts, isEmpty);
        expect(state.isBatchMode, isFalse);
        expect(state.currentBatchId, isNull);
      });
    });

    group('Receipt Capture', () {
      test('should capture receipt successfully', () async {
        final notifier = container.read(batchCaptureProvider.notifier);
        
        // Set up mock
        final mockOCRResult = ProcessingResult(
          merchant: FieldData(value: 'Test Store', confidence: 90.0, originalText: 'Test Store'),
          date: FieldData(value: '12/06/2024', confidence: 85.0, originalText: '12/06/2024'),
          total: FieldData(value: 25.47, confidence: 95.0, originalText: '\$25.47'),
          tax: FieldData(value: 2.04, confidence: 88.0, originalText: '\$2.04'),
          overallConfidence: 89.5,
          processingDurationMs: 1200,
          allText: ['Test Store', '12/06/2024'],
        );
        
        when(mockCameraService.captureReceipt(batchMode: true))
            .thenAnswer((_) async => CaptureResult.success(
              '/path/to/image.jpg',
              thumbnailUri: '/path/to/thumb.jpg',
              ocrResults: mockOCRResult,
            ));
        
        // Start batch mode and capture receipt
        notifier.startBatchMode();
        final success = await notifier.captureReceipt();
        
        expect(success, isTrue);
        
        final state = container.read(batchCaptureProvider);
        expect(state.receipts.length, equals(1));
        expect(state.batchSize, equals(1));
        
        final receipt = state.receipts.first;
        expect(receipt.imageUri, equals('/path/to/image.jpg'));
        expect(receipt.thumbnailUri, equals('/path/to/thumb.jpg'));
        expect(receipt.status, equals(ReceiptStatus.ready)); // Has OCR results
        expect(receipt.merchantName, equals('Test Store'));
        expect(receipt.totalAmount, equals(25.47));
      });

      test('should handle capture failure', () async {
        final notifier = container.read(batchCaptureProvider.notifier);
        
        // Set up mock to return failure
        when(mockCameraService.captureReceipt(batchMode: true))
            .thenAnswer((_) async => CaptureResult.error('Camera error'));
        
        notifier.startBatchMode();
        final success = await notifier.captureReceipt();
        
        expect(success, isFalse);
        
        final state = container.read(batchCaptureProvider);
        expect(state.receipts, isEmpty);
        expect(state.batchSize, equals(0));
      });

      test('should prevent multiple simultaneous captures', () async {
        final notifier = container.read(batchCaptureProvider.notifier);
        
        // Set up mock with delay
        when(mockCameraService.captureReceipt(batchMode: true))
            .thenAnswer((_) async {
              await Future.delayed(const Duration(milliseconds: 100));
              return CaptureResult.success('/path/to/image.jpg');
            });
        
        notifier.startBatchMode();
        
        // Start two captures simultaneously
        final future1 = notifier.captureReceipt();
        final future2 = notifier.captureReceipt();
        
        final results = await Future.wait([future1, future2]);
        
        // One should succeed, one should fail (already capturing)
        expect(results.where((r) => r).length, equals(1));
        expect(results.where((r) => !r).length, equals(1));
      });

      test('should create receipt without OCR results when none provided', () async {
        final notifier = container.read(batchCaptureProvider.notifier);
        
        // Mock capture without OCR results
        when(mockCameraService.captureReceipt(batchMode: true))
            .thenAnswer((_) async => CaptureResult.success('/path/to/image.jpg'));
        
        notifier.startBatchMode();
        final success = await notifier.captureReceipt();
        
        expect(success, isTrue);
        
        final state = container.read(batchCaptureProvider);
        final receipt = state.receipts.first;
        expect(receipt.status, equals(ReceiptStatus.captured)); // No OCR results
        expect(receipt.hasOCRResults, isFalse);
        expect(receipt.merchantName, isNull);
      });
    });

    group('Receipt Management', () {
      test('should remove receipt by ID', () async {
        final notifier = container.read(batchCaptureProvider.notifier);
        
        // Set up mock and capture receipt
        when(mockCameraService.captureReceipt(batchMode: true))
            .thenAnswer((_) async => CaptureResult.success('/path/to/image.jpg'));
        
        notifier.startBatchMode();
        await notifier.captureReceipt();
        
        final stateBefore = container.read(batchCaptureProvider);
        expect(stateBefore.receipts.length, equals(1));
        
        final receiptId = stateBefore.receipts.first.id;
        
        // Remove the receipt
        notifier.removeReceipt(receiptId);
        
        final stateAfter = container.read(batchCaptureProvider);
        expect(stateAfter.receipts, isEmpty);
      });

      test('should reorder receipts correctly', () async {
        final notifier = container.read(batchCaptureProvider.notifier);
        
        // Set up mock and capture multiple receipts
        when(mockCameraService.captureReceipt(batchMode: true))
            .thenAnswer((_) async => CaptureResult.success('/path/to/image.jpg'));
        
        notifier.startBatchMode();
        await notifier.captureReceipt();
        await notifier.captureReceipt();
        await notifier.captureReceipt();
        
        final stateBefore = container.read(batchCaptureProvider);
        expect(stateBefore.receipts.length, equals(3));
        
        final originalOrder = stateBefore.receipts.map((r) => r.id).toList();
        
        // Reorder: move first receipt to last position
        notifier.reorderReceipts(0, 2);
        
        final stateAfter = container.read(batchCaptureProvider);
        final newOrder = stateAfter.receipts.map((r) => r.id).toList();
        
        expect(newOrder[0], equals(originalOrder[1]));
        expect(newOrder[1], equals(originalOrder[2]));
        expect(newOrder[2], equals(originalOrder[0]));
      });

      test('should handle invalid receipt removal gracefully', () {
        final notifier = container.read(batchCaptureProvider.notifier);
        
        notifier.startBatchMode();
        
        // Try to remove non-existent receipt
        notifier.removeReceipt('non-existent-id');
        
        final state = container.read(batchCaptureProvider);
        expect(state.receipts, isEmpty); // Should not crash
      });
    });

    group('State Updates', () {
      test('should update isCapturing state during capture', () async {
        final notifier = container.read(batchCaptureProvider.notifier);
        
        // Set up mock with delay to observe isCapturing state
        when(mockCameraService.captureReceipt(batchMode: true))
            .thenAnswer((_) async {
              await Future.delayed(const Duration(milliseconds: 50));
              return CaptureResult.success('/path/to/image.jpg');
            });
        
        notifier.startBatchMode();
        
        // Start capture
        final captureFeature = notifier.captureReceipt();
        
        // Check that isCapturing is true during capture
        await Future.delayed(const Duration(milliseconds: 10));
        final stateDuringCapture = container.read(batchCaptureProvider);
        expect(stateDuringCapture.isCapturing, isTrue);
        
        // Wait for capture to complete
        await captureFeature;
        
        // Check that isCapturing is false after capture
        final stateAfterCapture = container.read(batchCaptureProvider);
        expect(stateAfterCapture.isCapturing, isFalse);
      });

      test('should maintain batch ID throughout session', () async {
        final notifier = container.read(batchCaptureProvider.notifier);
        
        when(mockCameraService.captureReceipt(batchMode: true))
            .thenAnswer((_) async => CaptureResult.success('/path/to/image.jpg'));
        
        notifier.startBatchMode();
        final batchId = container.read(batchCaptureProvider).currentBatchId;
        
        // Capture multiple receipts
        await notifier.captureReceipt();
        await notifier.captureReceipt();
        
        final state = container.read(batchCaptureProvider);
        
        // All receipts should have the same batch ID
        for (final receipt in state.receipts) {
          expect(receipt.batchId, equals(batchId));
        }
        
        // State should maintain the same batch ID
        expect(state.currentBatchId, equals(batchId));
      });
    });
  });

  group('BatchCaptureState', () {
    test('should create state with default values', () {
      final state = BatchCaptureState();
      
      expect(state.receipts, isEmpty);
      expect(state.currentBatchId, isNull);
      expect(state.isBatchMode, isFalse);
      expect(state.isCapturing, isFalse);
      expect(state.batchSize, equals(0));
    });

    test('should create state with custom values', () {
      final receipts = [
        Receipt(imageUri: '/path/1.jpg'),
        Receipt(imageUri: '/path/2.jpg'),
      ];
      
      final state = BatchCaptureState(
        receipts: receipts,
        currentBatchId: 'batch_123',
        isBatchMode: true,
        isCapturing: true,
      );
      
      expect(state.receipts.length, equals(2));
      expect(state.currentBatchId, equals('batch_123'));
      expect(state.isBatchMode, isTrue);
      expect(state.isCapturing, isTrue);
      expect(state.batchSize, equals(2));
    });

    test('should create copy with updated values', () {
      final originalState = BatchCaptureState(
        isBatchMode: false,
        isCapturing: false,
      );
      
      final updatedState = originalState.copyWith(
        isBatchMode: true,
        currentBatchId: 'new_batch',
      );
      
      expect(updatedState.isBatchMode, isTrue);
      expect(updatedState.currentBatchId, equals('new_batch'));
      expect(updatedState.isCapturing, isFalse); // Unchanged
      expect(updatedState.receipts, isEmpty); // Unchanged
    });

    test('should calculate batch size correctly', () {
      final receipts = List.generate(5, (index) => 
          Receipt(imageUri: '/path/$index.jpg')
      );
      
      final state = BatchCaptureState(receipts: receipts);
      
      expect(state.batchSize, equals(5));
    });
  });
}