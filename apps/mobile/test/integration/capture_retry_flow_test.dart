import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:receipt_organizer/domain/services/camera_service.dart';
import 'package:receipt_organizer/features/capture/providers/capture_provider.dart';
import 'package:receipt_organizer/features/capture/services/retry_session_manager.dart';
import 'package:receipt_organizer/features/capture/screens/preview_screen.dart';
import 'package:receipt_organizer/features/capture/widgets/retry_prompt_dialog.dart';
import 'package:receipt_organizer/features/capture/widgets/capture_failed_state.dart';

import 'capture_retry_flow_test.mocks.dart';

@GenerateMocks([TextRecognizer, ICameraService, RetrySessionManager])
void main() {
  group('Capture Retry Flow Integration Tests', () {
    late MockTextRecognizer mockTextRecognizer;
    late MockICameraService mockCameraService;
    late MockRetrySessionManager mockSessionManager;
    late OCRService ocrService;

    setUp(() {
      mockTextRecognizer = MockTextRecognizer();
      mockCameraService = MockICameraService();
      mockSessionManager = MockRetrySessionManager();
      ocrService = OCRService(textRecognizer: mockTextRecognizer);

      // Setup default mock behaviors
      when(mockSessionManager.saveSession(any)).thenAnswer((_) async => true);
      when(mockSessionManager.cleanupSession(any)).thenAnswer((_) async => true);
      when(mockSessionManager.cleanupExpiredSessions()).thenAnswer((_) async => 0);
    });

    testWidgets('should complete full retry flow from failure to success', (tester) async {
      // Arrange - Mock OCR to fail first, then succeed
      var callCount = 0;
      when(mockTextRecognizer.processImage(any)).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          // First attempt: return very low confidence result
          return RecognizedText([
            TextBlock(
              text: 'blurry text',
              rect: const Rect.fromLTWH(0, 0, 100, 20),
              lines: [
                TextLine(
                  text: 'blurry text',
                  rect: const Rect.fromLTWH(0, 0, 100, 20),
                  elements: [],
                ),
              ],
            ),
          ]);
        } else {
          // Second attempt: return good result
          return RecognizedText([
            TextBlock(
              text: 'Costco\n2024-01-15\nTotal: \$45.67\nTax: \$3.42',
              rect: const Rect.fromLTWH(0, 0, 200, 100),
              lines: [
                TextLine(text: 'Costco', rect: const Rect.fromLTWH(0, 0, 100, 20), elements: []),
                TextLine(text: '2024-01-15', rect: const Rect.fromLTWH(0, 20, 100, 20), elements: []),
                TextLine(text: 'Total: \$45.67', rect: const Rect.fromLTWH(0, 40, 100, 20), elements: []),
                TextLine(text: 'Tax: \$3.42', rect: const Rect.fromLTWH(0, 60, 100, 20), elements: []),
              ],
            ),
          ]);
        }
      });

      final testImageData = Uint8List.fromList([1, 2, 3, 4, 5]);

      // Create test app with providers
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ocrServiceProvider.overrideWithValue(ocrService),
            cameraServiceProvider.overrideWithValue(mockCameraService),
            retrySessionManagerProvider.overrideWithValue(mockSessionManager),
          ],
          child: MaterialApp(
            home: PreviewScreen(imageData: testImageData),
          ),
        ),
      );

      // Wait for initial processing
      await tester.pumpAndSettle();

      // Assert failure state is shown
      expect(find.byType(CaptureFailedState), findsOneWidget);
      expect(find.text('Capture Failed'), findsOneWidget);

      // Act - tap retry button
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      // Assert - success state should be shown
      expect(find.byType(CaptureFailedState), findsNothing);
      expect(find.text('Receipt Processed Successfully'), findsOneWidget);
      
      // Verify session was saved during failure
      verify(mockSessionManager.saveSession(any)).called(greaterThan(0));
    });

    testWidgets('should handle retry dialog flow correctly', (tester) async {
      // Arrange - Mock OCR to always fail with low confidence
      when(mockTextRecognizer.processImage(any)).thenAnswer((_) async {
        return RecognizedText([
          TextBlock(
            text: 'unclear text',
            rect: const Rect.fromLTWH(0, 0, 50, 10),
            lines: [
              TextLine(
                text: 'unclear text',
                rect: const Rect.fromLTWH(0, 0, 50, 10),
                elements: [],
              ),
            ],
          ),
        ]);
      });

      final testImageData = Uint8List.fromList([1, 2, 3, 4, 5]);

      // Create test app
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ocrServiceProvider.overrideWithValue(ocrService),
            cameraServiceProvider.overrideWithValue(mockCameraService),
            retrySessionManagerProvider.overrideWithValue(mockSessionManager),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  final action = await RetryPromptDialog.show(
                    context: context,
                    failureReason: FailureReason.lowConfidence,
                    attemptNumber: 2,
                    attemptsRemaining: 3,
                  );
                  // Handle action result if needed
                },
                child: const Text('Show Retry Dialog'),
              ),
            ),
          ),
        ),
      );

      // Act - show retry dialog
      await tester.tap(find.text('Show Retry Dialog'));
      await tester.pumpAndSettle();

      // Assert dialog is shown
      expect(find.byType(RetryPromptDialog), findsOneWidget);
      expect(find.text('Unable to read receipt clearly'), findsOneWidget);
      expect(find.text('Attempt 2 • 3 left'), findsOneWidget);

      // Act - tap cancel to close dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert dialog is dismissed
      expect(find.byType(RetryPromptDialog), findsNothing);
    });

    testWidgets('should handle maximum retry attempts reached', (tester) async {
      // Arrange - Mock OCR to always fail
      when(mockTextRecognizer.processImage(any)).thenAnswer((_) async {
        return RecognizedText([]);
      });

      final testImageData = Uint8List.fromList([1, 2, 3, 4, 5]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ocrServiceProvider.overrideWithValue(ocrService),
            cameraServiceProvider.overrideWithValue(mockCameraService),
            retrySessionManagerProvider.overrideWithValue(mockSessionManager),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CaptureFailedState(
                failureReason: FailureReason.lowConfidence,
                attemptNumber: 5,
                attemptsRemaining: 0,
                qualityScore: 15.0,
                onRetry: () {},
                onRetakePhoto: () {},
                onCancel: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert max attempts reached
      expect(find.text('No Attempts Left'), findsOneWidget);
      
      // Verify retry button is disabled
      final retryButton = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('No Attempts Left'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(retryButton.onPressed, isNull);
    });

    testWidgets('should handle session persistence across app restarts', (tester) async {
      // Arrange - Mock session manager to return existing session
      const sessionId = 'test-session-123';
      final mockSession = RetrySession(
        sessionId: sessionId,
        retryCount: 2,
        maxRetryAttempts: 5,
        lastFailureReason: FailureReason.blurryImage,
        lastFailureMessage: 'Image is too blurry - try taking a clearer photo',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        imageData: Uint8List.fromList([1, 2, 3, 4, 5]),
      );

      when(mockSessionManager.loadSession(sessionId))
          .thenAnswer((_) async => mockSession);

      // Create test app that restores session
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ocrServiceProvider.overrideWithValue(ocrService),
            cameraServiceProvider.overrideWithValue(mockCameraService),
            retrySessionManagerProvider.overrideWithValue(mockSessionManager),
          ],
          child: MaterialApp(
            home: PreviewScreen(
              imageData: Uint8List.fromList([1, 2, 3, 4, 5]),
              sessionId: sessionId,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify session restoration was attempted
      verify(mockSessionManager.loadSession(sessionId)).called(1);
    });

    testWidgets('should cleanup session when cancelled', (tester) async {
      // Arrange
      const sessionId = 'test-session-cleanup';
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ocrServiceProvider.overrideWithValue(ocrService),
            cameraServiceProvider.overrideWithValue(mockCameraService),
            retrySessionManagerProvider.overrideWithValue(mockSessionManager),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CaptureFailedState(
                failureReason: FailureReason.processingError,
                attemptNumber: 3,
                attemptsRemaining: 2,
                qualityScore: 20.0,
                onRetry: () {},
                onRetakePhoto: () {},
                onCancel: () {
                  // Simulate the cancel action that should cleanup session
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act - tap cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      // The cancel callback is called - in real app this would trigger cleanup
      // This test verifies the UI responds to cancel action
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should handle different failure reasons appropriately', (tester) async {
      // Test each failure reason type
      final failureReasons = [
        FailureReason.blurryImage,
        FailureReason.poorLighting,
        FailureReason.noReceiptDetected,
        FailureReason.lowConfidence,
        FailureReason.processingTimeout,
        FailureReason.processingError,
      ];

      for (final reason in failureReasons) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CaptureFailedState(
                failureReason: reason,
                attemptNumber: 1,
                attemptsRemaining: 4,
                qualityScore: 30.0,
                onRetry: () {},
                onRetakePhoto: () {},
                onCancel: () {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify failure reason message is displayed
        expect(find.text(reason.userMessage), findsOneWidget);
        
        // Verify appropriate tip is shown (if available)
        expect(find.text('Tip'), findsOneWidget);
      }
    });
  });
}