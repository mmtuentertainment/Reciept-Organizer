import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/shared/widgets/confidence_score_widget.dart';

void main() {
  group('ConfidenceScoreWidget', () {
    testWidgets('displays high confidence with green color', (WidgetTester tester) async {
      // Given
      const double highConfidence = 90.0;

      // When
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceScoreWidget(
              confidence: highConfidence,
              variant: ConfidenceDisplayVariant.compact,
            ),
          ),
        ),
      );

      // Then
      expect(find.text('90%'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      
      // Verify green color scheme
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border?.top.color, const Color(0xFF388E3C));
    });

    testWidgets('displays medium confidence with orange color', (WidgetTester tester) async {
      // Given
      const double mediumConfidence = 80.0;

      // When
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceScoreWidget(
              confidence: mediumConfidence,
              variant: ConfidenceDisplayVariant.compact,
            ),
          ),
        ),
      );

      // Then
      expect(find.text('80%'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      
      // Verify orange color scheme
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border?.top.color, const Color(0xFFF57C00));
    });

    testWidgets('displays low confidence with red color', (WidgetTester tester) async {
      // Given
      const double lowConfidence = 65.0;

      // When
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceScoreWidget(
              confidence: lowConfidence,
              variant: ConfidenceDisplayVariant.compact,
            ),
          ),
        ),
      );

      // Then
      expect(find.text('65%'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
      
      // Verify red color scheme
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border?.top.color, const Color(0xFFD32F2F));
    });

    testWidgets('displays processing state when confidence is null', (WidgetTester tester) async {
      // Given
      const ConfidenceScoreWidget? nullConfidenceWidget = ConfidenceScoreWidget(
        confidence: null,
        variant: ConfidenceDisplayVariant.compact,
      );

      // When
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: nullConfidenceWidget!,
          ),
        ),
      );

      // Then
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('90%'), findsNothing);
      expect(find.text('80%'), findsNothing);
      expect(find.text('65%'), findsNothing);
    });

    testWidgets('detailed variant shows progress bar and label', (WidgetTester tester) async {
      // Given
      const double confidence = 85.0;

      // When
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceScoreWidget(
              confidence: confidence,
              variant: ConfidenceDisplayVariant.detailed,
            ),
          ),
        ),
      );

      // Then
      expect(find.text('Confidence: 85%'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      
      // Check for progress bar (FractionallySizedBox is used for the progress bar)
      expect(find.byType(FractionallySizedBox), findsOneWidget);
      
      final fractionallySizedBox = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox)
      );
      expect(fractionallySizedBox.widthFactor, closeTo(0.85, 0.01));
    });

    testWidgets('inline variant shows minimal display', (WidgetTester tester) async {
      // Given
      const double confidence = 75.0;

      // When
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceScoreWidget(
              confidence: confidence,
              variant: ConfidenceDisplayVariant.inline,
              showIcon: false,
            ),
          ),
        ),
      );

      // Then
      expect(find.text('75%'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsNothing);
      
      // Verify text style for inline variant
      final text = tester.widget<Text>(find.text('75%'));
      expect(text.style?.fontSize, 12);
    });

    testWidgets('handles edge case confidence values correctly', (WidgetTester tester) async {
      // Given - Test boundary values
      const List<double> testConfidences = [0.0, 74.9, 75.0, 84.9, 85.0, 100.0];
      const List<Color> expectedColors = [
        Color(0xFFD32F2F), // Red for 0%
        Color(0xFFD32F2F), // Red for 74.9%
        Color(0xFFF57C00), // Orange for 75%
        Color(0xFFF57C00), // Orange for 84.9%
        Color(0xFF388E3C), // Green for 85%
        Color(0xFF388E3C), // Green for 100%
      ];

      for (int i = 0; i < testConfidences.length; i++) {
        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ConfidenceScoreWidget(
                confidence: testConfidences[i],
                variant: ConfidenceDisplayVariant.compact,
              ),
            ),
          ),
        );

        // Then
        final container = tester.widget<Container>(find.byType(Container).first);
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.border?.top.color, expectedColors[i], 
            reason: 'Wrong color for confidence ${testConfidences[i]}%');

        // Clean up for next test
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('respects showIcon parameter', (WidgetTester tester) async {
      // Given
      const double confidence = 90.0;

      // When - with icon
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceScoreWidget(
              confidence: confidence,
              showIcon: true,
            ),
          ),
        ),
      );

      // Then
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

      // When - without icon
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceScoreWidget(
              confidence: confidence,
              showIcon: false,
            ),
          ),
        ),
      );

      // Then
      expect(find.byIcon(Icons.check_circle_outline), findsNothing);
      expect(find.text('90%'), findsOneWidget);
    });

    testWidgets('applies custom size correctly', (WidgetTester tester) async {
      // Given
      const double confidence = 85.0;
      const double customSize = 48.0;

      // When
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceScoreWidget(
              confidence: confidence,
              size: customSize,
              variant: ConfidenceDisplayVariant.compact,
            ),
          ),
        ),
      );

      // Then
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.minWidth, customSize);
      expect(container.constraints?.minHeight, customSize);
    });

    group('ConfidenceLevel extension', () {
      test('correctly categorizes confidence levels', () {
        // Given & When & Then
        expect(65.0.confidenceLevel, ConfidenceLevel.low);
        expect(74.9.confidenceLevel, ConfidenceLevel.low);
        expect(75.0.confidenceLevel, ConfidenceLevel.medium);
        expect(84.9.confidenceLevel, ConfidenceLevel.medium);
        expect(85.0.confidenceLevel, ConfidenceLevel.high);
        expect(95.0.confidenceLevel, ConfidenceLevel.high);
      });
    });
  });
}