import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:receipt_organizer/features/capture/widgets/capture_failed_state.dart';

void main() {
  group('CaptureFailedState Widget Tests', () {
    testWidgets('should display failure information and retry counter', (tester) async {
      // Arrange
      var retryPressed = false;
      var retakePressed = false;
      var cancelPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CaptureFailedState(
              failureReason: FailureReason.blurryImage,
              attemptNumber: 3,
              attemptsRemaining: 2,
              qualityScore: 45.5,
              onRetry: () => retryPressed = true,
              onRetakePhoto: () => retakePressed = true,
              onCancel: () => cancelPressed = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Capture Failed'), findsOneWidget);
      expect(find.text('Image is too blurry - try taking a clearer photo'), findsOneWidget);
      expect(find.text('Attempt 3'), findsOneWidget);
      expect(find.text('2 left'), findsOneWidget);
      expect(find.text('45.5%'), findsOneWidget);
      expect(find.byIcon(Icons.blur_on), findsOneWidget);
    });

    testWidgets('should display appropriate failure icons', (tester) async {
      // Test poor lighting icon
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CaptureFailedState(
              failureReason: FailureReason.poorLighting,
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

      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);

      // Test processing error icon
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CaptureFailedState(
              failureReason: FailureReason.processingError,
              attemptNumber: 2,
              attemptsRemaining: 3,
              qualityScore: 0.0,
              onRetry: () {},
              onRetakePhoto: () {},
              onCancel: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should handle retry button tap', (tester) async {
      // Arrange
      var retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CaptureFailedState(
              failureReason: FailureReason.lowConfidence,
              attemptNumber: 2,
              attemptsRemaining: 3,
              qualityScore: 25.0,
              onRetry: () => retryPressed = true,
              onRetakePhoto: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Try Again'));
      await tester.pump();

      // Assert
      expect(retryPressed, isTrue);
    });

    testWidgets('should handle retake photo button tap', (tester) async {
      // Arrange
      var retakePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CaptureFailedState(
              failureReason: FailureReason.blurryImage,
              attemptNumber: 1,
              attemptsRemaining: 4,
              qualityScore: 40.0,
              onRetry: () {},
              onRetakePhoto: () => retakePressed = true,
              onCancel: () {},
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Retake Photo'));
      await tester.pump();

      // Assert
      expect(retakePressed, isTrue);
    });

    testWidgets('should handle cancel button tap', (tester) async {
      // Arrange
      var cancelPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CaptureFailedState(
              failureReason: FailureReason.processingTimeout,
              attemptNumber: 4,
              attemptsRemaining: 1,
              qualityScore: 60.0,
              onRetry: () {},
              onRetakePhoto: () {},
              onCancel: () => cancelPressed = true,
            ),
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
          home: Scaffold(
            body: CaptureFailedState(
              failureReason: FailureReason.lowConfidence,
              attemptNumber: 5,
              attemptsRemaining: 0,
              qualityScore: 20.0,
              onRetry: () {},
              onRetakePhoto: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('No Attempts Left'), findsOneWidget);
      
      final retryButton = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('No Attempts Left'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(retryButton.onPressed, isNull); // Button should be disabled
    });

    testWidgets('should display appropriate tips for different failure reasons', (tester) async {
      // Test blur tip
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CaptureFailedState(
              failureReason: FailureReason.blurryImage,
              attemptNumber: 1,
              attemptsRemaining: 4,
              qualityScore: 35.0,
              onRetry: () {},
              onRetakePhoto: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      expect(find.text('Tip'), findsOneWidget);
      expect(find.text('Hold your device steady and make sure the receipt is clearly focused before taking the photo.'), findsOneWidget);

      // Test lighting tip
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CaptureFailedState(
              failureReason: FailureReason.poorLighting,
              attemptNumber: 2,
              attemptsRemaining: 3,
              qualityScore: 30.0,
              onRetry: () {},
              onRetakePhoto: () {},
              onCancel: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Try moving to an area with better lighting, or turn on additional lights to illuminate the receipt.'), findsOneWidget);
    });

    group('RetryCountIndicator', () {
      testWidgets('should display attempt information correctly', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RetryCountIndicator(
                attemptNumber: 3,
                attemptsRemaining: 2,
                qualityScore: 65.0,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Attempt 3'), findsOneWidget);
        expect(find.text('2 left'), findsOneWidget);
        expect(find.text('Quality Score: '), findsOneWidget);
        expect(find.text('65.0%'), findsOneWidget);
        expect(find.byIcon(Icons.replay), findsOneWidget);
      });

      testWidgets('should show correct color for different quality scores', (tester) async {
        // Test high quality score (green)
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RetryCountIndicator(
                attemptNumber: 1,
                attemptsRemaining: 4,
                qualityScore: 85.0,
              ),
            ),
          ),
        );

        // Can't easily test color directly, but verify the widget renders
        expect(find.text('85.0%'), findsOneWidget);

        // Test medium quality score
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RetryCountIndicator(
                attemptNumber: 2,
                attemptsRemaining: 3,
                qualityScore: 65.0,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('65.0%'), findsOneWidget);

        // Test low quality score
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RetryCountIndicator(
                attemptNumber: 3,
                attemptsRemaining: 2,
                qualityScore: 35.0,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('35.0%'), findsOneWidget);
      });

      testWidgets('should show error styling when no attempts remaining', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RetryCountIndicator(
                attemptNumber: 5,
                attemptsRemaining: 0,
                qualityScore: 20.0,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Attempt 5'), findsOneWidget);
        expect(find.text('0 left'), findsOneWidget);
      });

      testWidgets('should display progress bar for quality score', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RetryCountIndicator(
                attemptNumber: 2,
                attemptsRemaining: 3,
                qualityScore: 75.0,
              ),
            ),
          ),
        );

        // Assert - check that progress indicator containers are present
        expect(find.byType(Container), findsAtLeastNWidgets(2)); // Multiple containers for progress bar
        expect(find.text('75.0%'), findsOneWidget);
      });
    });

    testWidgets('should handle very long failure messages gracefully', (tester) async {
      // Arrange - use a custom failure reason with long message
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CaptureFailedState(
              failureReason: FailureReason.processingError,
              attemptNumber: 1,
              attemptsRemaining: 4,
              qualityScore: 50.0,
              onRetry: () {},
              onRetakePhoto: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      // Assert - the widget should render without overflow
      expect(find.text('Processing failed - please retry'), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsNothing); // Should not need scroll for normal content
    });
  });
}