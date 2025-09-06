import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:receipt_organizer/data/models/capture_result.dart';
import 'package:receipt_organizer/domain/services/camera_service.dart';
import 'package:receipt_organizer/features/capture/providers/batch_capture_provider.dart';
import 'package:receipt_organizer/features/capture/screens/batch_capture_screen.dart';

import 'batch_capture_screen_test.mocks.dart';

@GenerateMocks([ICameraService])
void main() {
  group('BatchCaptureScreen Widget Tests', () {
    late MockICameraService mockCameraService;

    setUp(() {
      mockCameraService = MockICameraService();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          cameraServiceProvider.overrideWithValue(mockCameraService),
        ],
        child: const MaterialApp(
          home: BatchCaptureScreen(),
        ),
      );
    }

    testWidgets('should display batch capture screen with initial elements', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Batch Capture'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Position receipt within the frame'), findsOneWidget);
    });

    testWidgets('should show capture button and allow tapping', (WidgetTester tester) async {
      when(mockCameraService.captureReceipt(batchMode: true))
          .thenAnswer((_) async => CaptureResult.success('/path/to/image.jpg'));

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final captureButton = find.byIcon(Icons.camera_alt);
      expect(captureButton, findsOneWidget);

      await tester.tap(captureButton);
      await tester.pump();

      verify(mockCameraService.captureReceipt(batchMode: true)).called(1);
    });

    testWidgets('should update counter after successful capture', (WidgetTester tester) async {
      when(mockCameraService.captureReceipt(batchMode: true))
          .thenAnswer((_) async => CaptureResult.success('/path/to/image.jpg'));

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('0'), findsOneWidget);

      final captureButton = find.byIcon(Icons.camera_alt);
      await tester.tap(captureButton);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('should show finish batch button after capturing receipts', (WidgetTester tester) async {
      when(mockCameraService.captureReceipt(batchMode: true))
          .thenAnswer((_) async => CaptureResult.success('/path/to/image.jpg'));

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Finish Batch (1)'), findsNothing);

      final captureButton = find.byIcon(Icons.camera_alt);
      await tester.tap(captureButton);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Finish Batch (1)'), findsOneWidget);
    });

    testWidgets('should show review button in app bar after capturing', (WidgetTester tester) async {
      when(mockCameraService.captureReceipt(batchMode: true))
          .thenAnswer((_) async => CaptureResult.success('/path/to/image.jpg'));

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Review'), findsNothing);

      final captureButton = find.byIcon(Icons.camera_alt);
      await tester.tap(captureButton);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Review'), findsOneWidget);
    });

    testWidgets('should show loading indicator during capture', (WidgetTester tester) async {
      when(mockCameraService.captureReceipt(batchMode: true))
          .thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 200));
            return CaptureResult.success('/path/to/image.jpg');
          });

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final captureButton = find.byIcon(Icons.camera_alt);
      await tester.tap(captureButton);
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsNothing);
    });

    testWidgets('should show success snackbar after successful capture', (WidgetTester tester) async {
      when(mockCameraService.captureReceipt(batchMode: true))
          .thenAnswer((_) async => CaptureResult.success('/path/to/image.jpg'));

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final captureButton = find.byIcon(Icons.camera_alt);
      await tester.tap(captureButton);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Receipt captured! (1 total)'), findsOneWidget);
    });

    testWidgets('should handle multiple rapid captures', (WidgetTester tester) async {
      when(mockCameraService.captureReceipt(batchMode: true))
          .thenAnswer((_) async => CaptureResult.success('/path/to/image.jpg'));

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final captureButton = find.byIcon(Icons.camera_alt);
      
      await tester.tap(captureButton);
      await tester.tap(captureButton);
      await tester.tap(captureButton);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('3'), findsOneWidget);
      expect(find.text('Finish Batch (3)'), findsOneWidget);
    });

    testWidgets('should handle camera error gracefully', (WidgetTester tester) async {
      when(mockCameraService.captureReceipt(batchMode: true))
          .thenAnswer((_) async => CaptureResult.error('Camera failed'));

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final captureButton = find.byIcon(Icons.camera_alt);
      await tester.tap(captureButton);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('0'), findsOneWidget);
      expect(find.text('Finish Batch (0)'), findsNothing);
    });

    testWidgets('should navigate to batch review screen when finish button tapped', (WidgetTester tester) async {
      when(mockCameraService.captureReceipt(batchMode: true))
          .thenAnswer((_) async => CaptureResult.success('/path/to/image.jpg'));

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final captureButton = find.byIcon(Icons.camera_alt);
      await tester.tap(captureButton);
      await tester.pump(const Duration(milliseconds: 100));

      final finishButton = find.text('Finish Batch (1)');
      expect(finishButton, findsOneWidget);

      await tester.tap(finishButton);
      await tester.pumpAndSettle();

      expect(find.text('Review Batch (1)'), findsOneWidget);
    });
  });
}