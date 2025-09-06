import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:receipt_organizer/data/models/capture_result.dart';
import 'package:receipt_organizer/domain/services/camera_service.dart';
import 'package:receipt_organizer/features/capture/providers/batch_capture_provider.dart';
import 'package:receipt_organizer/main.dart';

import 'batch_capture_flow_test.mocks.dart';

@GenerateMocks([ICameraService])
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Batch Capture Integration Tests', () {
    late MockICameraService mockCameraService;

    setUp(() {
      mockCameraService = MockICameraService();
    });

    Widget createTestApp() {
      return ProviderScope(
        overrides: [
          cameraServiceProvider.overrideWithValue(mockCameraService),
        ],
        child: const ReceiptOrganizerApp(),
      );
    }

    testWidgets('Complete batch capture flow - capture 10 receipts in under 3 minutes', 
        (WidgetTester tester) async {
      when(mockCameraService.captureReceipt(batchMode: true))
          .thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 300));
            return CaptureResult.success('/path/to/image.jpg');
          });

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Receipt Organizer MVP'), findsOneWidget);
      expect(find.text('Start Batch Capture'), findsOneWidget);

      final batchCaptureButton = find.text('Start Batch Capture');
      await tester.tap(batchCaptureButton);
      await tester.pumpAndSettle();

      expect(find.text('Batch Capture'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);

      final startTime = DateTime.now();
      const targetCaptureCount = 10;

      for (int i = 1; i <= targetCaptureCount; i++) {
        final captureButton = find.byIcon(Icons.camera_alt);
        await tester.tap(captureButton);
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('$i'), findsOneWidget);
        
        if (i < targetCaptureCount) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      expect(duration.inMinutes, lessThan(3), 
        reason: 'Batch capture should complete in under 3 minutes');

      expect(find.text('$targetCaptureCount'), findsOneWidget);
      expect(find.text('Finish Batch ($targetCaptureCount)'), findsOneWidget);

      final finishButton = find.text('Finish Batch ($targetCaptureCount)');
      await tester.tap(finishButton);
      await tester.pumpAndSettle();

      expect(find.text('Review Batch ($targetCaptureCount)'), findsOneWidget);

      for (int i = 1; i <= targetCaptureCount; i++) {
        expect(find.text('Receipt $i'), findsOneWidget);
      }

      final processAllButton = find.text('Process All');
      expect(processAllButton, findsOneWidget);
      
      await tester.tap(processAllButton);
      await tester.pumpAndSettle();

      expect(find.text('Processing $targetCaptureCount receipts...'), findsOneWidget);
    });

    testWidgets('Batch review and delete functionality', (WidgetTester tester) async {
      when(mockCameraService.captureReceipt(batchMode: true))
          .thenAnswer((_) async => CaptureResult.success('/path/to/image.jpg'));

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final batchCaptureButton = find.text('Start Batch Capture');
      await tester.tap(batchCaptureButton);
      await tester.pumpAndSettle();

      for (int i = 1; i <= 3; i++) {
        final captureButton = find.byIcon(Icons.camera_alt);
        await tester.tap(captureButton);
        await tester.pump(const Duration(milliseconds: 400));
      }

      final finishButton = find.text('Finish Batch (3)');
      await tester.tap(finishButton);
      await tester.pumpAndSettle();

      expect(find.text('Review Batch (3)'), findsOneWidget);

      final firstReceiptTile = find.text('Receipt 1');
      expect(firstReceiptTile, findsOneWidget);

      await tester.drag(firstReceiptTile, const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Receipt deleted'), findsOneWidget);
      expect(find.text('UNDO'), findsOneWidget);

      final undoButton = find.text('UNDO');
      await tester.tap(undoButton);
      await tester.pumpAndSettle();

      expect(find.text('Receipt 1'), findsOneWidget);
    });

    testWidgets('Memory performance test - rapid captures', (WidgetTester tester) async {
      when(mockCameraService.captureReceipt(batchMode: true))
          .thenAnswer((_) async => CaptureResult.success('/path/to/image.jpg'));

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final batchCaptureButton = find.text('Start Batch Capture');
      await tester.tap(batchCaptureButton);
      await tester.pumpAndSettle();

      const rapidCaptureCount = 15;

      for (int i = 1; i <= rapidCaptureCount; i++) {
        final captureButton = find.byIcon(Icons.camera_alt);
        await tester.tap(captureButton);
        
        await tester.pump(const Duration(milliseconds: 50));
        
        if (i % 5 == 0) {
          await tester.pump(const Duration(milliseconds: 200));
          expect(find.text('$i'), findsOneWidget);
        }
      }

      expect(find.text('$rapidCaptureCount'), findsOneWidget);
      expect(find.text('Finish Batch ($rapidCaptureCount)'), findsOneWidget);

      final finishButton = find.text('Finish Batch ($rapidCaptureCount)');
      await tester.tap(finishButton);
      await tester.pumpAndSettle();

      expect(find.text('Review Batch ($rapidCaptureCount)'), findsOneWidget);

      for (int i = 1; i <= rapidCaptureCount; i++) {
        expect(find.text('Receipt $i'), findsOneWidget);
      }
    });

    testWidgets('Error handling during batch capture', (WidgetTester tester) async {
      int captureAttempts = 0;
      when(mockCameraService.captureReceipt(batchMode: true))
          .thenAnswer((_) async {
            captureAttempts++;
            if (captureAttempts == 2) {
              return CaptureResult.error('Camera error');
            }
            return CaptureResult.success('/path/to/image.jpg');
          });

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final batchCaptureButton = find.text('Start Batch Capture');
      await tester.tap(batchCaptureButton);
      await tester.pumpAndSettle();

      final captureButton = find.byIcon(Icons.camera_alt);
      await tester.tap(captureButton);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('1'), findsOneWidget);

      await tester.tap(captureButton);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('1'), findsOneWidget);

      await tester.tap(captureButton);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('2'), findsOneWidget);
    });
  });
}