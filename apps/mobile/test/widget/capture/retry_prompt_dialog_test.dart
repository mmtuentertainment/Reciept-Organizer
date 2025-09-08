import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:receipt_organizer/features/capture/widgets/retry_prompt_dialog.dart';

void main() {
  group('RetryPromptDialog Widget Tests', () {
    testWidgets('should display failure reason and attempt information', (tester) async {
      // Arrange
      // var retryPressed = false;
      // var retakePressed = false;
      // var cancelPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: RetryPromptDialog(
            failureReason: FailureReason.blurryImage,
            attemptNumber: 2,
            attemptsRemaining: 3,
            onRetry: () => retryPressed = true,
            onRetakePhoto: () => retakePressed = true,
            onCancel: () => cancelPressed = true,
          ),
        ),
      );

      // Assert
      expect(find.text('Capture Failed'), findsOneWidget);
      expect(find.text('Image is too blurry - try taking a clearer photo'), findsOneWidget);
      expect(find.text('Attempt 2 • 3 left'), findsOneWidget);
      expect(find.text('Tip:'), findsOneWidget);
      expect(find.byIcon(Icons.blur_on), findsOneWidget);
    });

    testWidgets('should display appropriate icon for different failure reasons', (tester) async {
      // Test blurry image icon
      await tester.pumpWidget(
        MaterialApp(
          home: RetryPromptDialog(
            failureReason: FailureReason.blurryImage,
            attemptNumber: 1,
            attemptsRemaining: 4,
            onRetry: () {},
            onRetakePhoto: () {},
            onCancel: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.blur_on), findsOneWidget);

      // Test poor lighting icon
      await tester.pumpWidget(
        MaterialApp(
          home: RetryPromptDialog(
            failureReason: FailureReason.poorLighting,
            attemptNumber: 1,
            attemptsRemaining: 4,
            onRetry: () {},
            onRetakePhoto: () {},
            onCancel: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);

      // Test no receipt detected icon
      await tester.pumpWidget(
        MaterialApp(
          home: RetryPromptDialog(
            failureReason: FailureReason.noReceiptDetected,
            attemptNumber: 1,
            attemptsRemaining: 4,
            onRetry: () {},
            onRetakePhoto: () {},
            onCancel: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
    });

    testWidgets('should handle retry button press', (tester) async {
      // Arrange
      // var retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: RetryPromptDialog(
            failureReason: FailureReason.lowConfidence,
            attemptNumber: 1,
            attemptsRemaining: 4,
            onRetry: () => retryPressed = true,
            onRetakePhoto: () {},
            onCancel: () {},
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Retry'));
      await tester.pump();

      // Assert
      expect(retryPressed, isTrue);
    });

    testWidgets('should handle retake photo button press', (tester) async {
      // Arrange
      // var retakePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: RetryPromptDialog(
            failureReason: FailureReason.blurryImage,
            attemptNumber: 2,
            attemptsRemaining: 3,
            onRetry: () {},
            onRetakePhoto: () => retakePressed = true,
            onCancel: () {},
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Retake Photo'));
      await tester.pump();

      // Assert
      expect(retakePressed, isTrue);
    });

    testWidgets('should handle cancel button press', (tester) async {
      // Arrange
      // var cancelPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: RetryPromptDialog(
            failureReason: FailureReason.processingError,
            attemptNumber: 3,
            attemptsRemaining: 2,
            onRetry: () {},
            onRetakePhoto: () {},
            onCancel: () => cancelPressed = true,
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      // Assert
      expect(cancelPressed, isTrue);
    });

    testWidgets('should disable retry button when no attempts remaining', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: RetryPromptDialog(
            failureReason: FailureReason.lowConfidence,
            attemptNumber: 5,
            attemptsRemaining: 0,
            onRetry: () {},
            onRetakePhoto: () {},
            onCancel: () {},
          ),
        ),
      );

      // Assert
      final retryButton = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('No Attempts Left'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(retryButton.onPressed, isNull); // Button should be disabled
    });

    testWidgets('should show different tips for different failure reasons', (tester) async {
      // Test blur tip
      await tester.pumpWidget(
        MaterialApp(
          home: RetryPromptDialog(
            failureReason: FailureReason.blurryImage,
            attemptNumber: 1,
            attemptsRemaining: 4,
            onRetry: () {},
            onRetakePhoto: () {},
            onCancel: () {},
          ),
        ),
      );

      expect(find.text('Hold the camera steady and ensure the receipt is in focus'), findsOneWidget);

      // Test lighting tip
      await tester.pumpWidget(
        MaterialApp(
          home: RetryPromptDialog(
            failureReason: FailureReason.poorLighting,
            attemptNumber: 1,
            attemptsRemaining: 4,
            onRetry: () {},
            onRetakePhoto: () {},
            onCancel: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Move to better lighting or turn on more lights'), findsOneWidget);
    });

    group('Static show method', () {
      testWidgets('should return RetryAction.retry when retry pressed', (tester) async {
        RetryAction? result;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await RetryPromptDialog.show(
                    context: context,
                    failureReason: FailureReason.blurryImage,
                    attemptNumber: 1,
                    attemptsRemaining: 4,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        );

        // Show dialog
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Tap retry
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        expect(result, equals(RetryAction.retry));
      });

      testWidgets('should return RetryAction.retakePhoto when retake pressed', (tester) async {
        RetryAction? result;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await RetryPromptDialog.show(
                    context: context,
                    failureReason: FailureReason.blurryImage,
                    attemptNumber: 1,
                    attemptsRemaining: 4,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        );

        // Show dialog
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Tap retake photo
        await tester.tap(find.text('Retake Photo'));
        await tester.pumpAndSettle();

        expect(result, equals(RetryAction.retakePhoto));
      });

      testWidgets('should return RetryAction.cancel when cancel pressed', (tester) async {
        RetryAction? result;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await RetryPromptDialog.show(
                    context: context,
                    failureReason: FailureReason.blurryImage,
                    attemptNumber: 1,
                    attemptsRemaining: 4,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        );

        // Show dialog
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Tap cancel
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(result, equals(RetryAction.cancel));
      });
    });
  });
}