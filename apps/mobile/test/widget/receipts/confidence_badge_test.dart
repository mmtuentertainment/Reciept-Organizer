import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/features/receipts/presentation/widgets/confidence_badge.dart';

void main() {
  group('ConfidenceBadge', () {
    testWidgets('displays high confidence badge with green background', (WidgetTester tester) async {
      // Given
      const double highConfidence = 92.0;

      // When
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceBadge(confidence: highConfidence),
          ),
        ),
      );

      // Then
      expect(find.text('92'), findsOneWidget);
      
      // Verify circular container with green background
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.color, const Color(0xFF388E3C)); // Green
    });

    testWidgets('displays medium confidence badge with orange background', (WidgetTester tester) async {
      // Given
      const double mediumConfidence = 78.0;

      // When
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceBadge(confidence: mediumConfidence),
          ),
        ),
      );

      // Then
      expect(find.text('78'), findsOneWidget);
      
      // Verify orange background
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFFF57C00)); // Orange
    });

    testWidgets('displays low confidence badge with red background', (WidgetTester tester) async {
      // Given
      const double lowConfidence = 60.0;

      // When
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceBadge(confidence: lowConfidence),
          ),
        ),
      );

      // Then
      expect(find.text('60'), findsOneWidget);
      
      // Verify red background
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFFD32F2F)); // Red
    });

    testWidgets('displays processing state when confidence is null', (WidgetTester tester) async {
      // Given
      const ConfidenceBadge nullConfidenceBadge = ConfidenceBadge(confidence: null);

      // When
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: nullConfidenceBadge,
          ),
        ),
      );

      // Then
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('60'), findsNothing);
    });

    testWidgets('respects custom size parameter', (WidgetTester tester) async {
      // Given
      const double confidence = 85.0;
      const double customSize = 32.0;

      // When
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceBadge(
              confidence: confidence,
              size: customSize,
            ),
          ),
        ),
      );

      // Then
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.minWidth, customSize);
      expect(container.constraints?.minHeight, customSize);
    });

    testWidgets('shows icon instead of percentage when showPercentage is false', (WidgetTester tester) async {
      // Given
      const double confidence = 90.0;

      // When
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceBadge(
              confidence: confidence,
              showPercentage: false,
            ),
          ),
        ),
      );

      // Then
      expect(find.text('90'), findsNothing);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('has proper drop shadow', (WidgetTester tester) async {
      // Given
      const double confidence = 85.0;

      // When
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceBadge(confidence: confidence),
          ),
        ),
      );

      // Then
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotEmpty);
      expect(decoration.boxShadow?.first.color, Colors.black.withAlpha((0.2 * 255).round()));
    });
  });

  group('PositionedConfidenceBadge', () {
    testWidgets('positions badge in top-right corner', (WidgetTester tester) async {
      // Given
      const double confidence = 88.0;
      const testChild = SizedBox(width: 100, height: 100, child: Placeholder());

      // When
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PositionedConfidenceBadge(
              confidence: confidence,
              child: testChild,
            ),
          ),
        ),
      );

      // Then
      expect(find.byType(Stack), findsOneWidget);
      expect(find.byType(Positioned), findsOneWidget);
      expect(find.byType(ConfidenceBadge), findsOneWidget);
      expect(find.byType(Placeholder), findsOneWidget);
      
      // Verify positioning
      final positioned = tester.widget<Positioned>(find.byType(Positioned));
      expect(positioned.top, 4.0); // Default margin
      expect(positioned.right, 4.0); // Default margin
    });

    testWidgets('respects custom margin', (WidgetTester tester) async {
      // Given
      const double confidence = 88.0;
      const customMargin = EdgeInsets.all(8.0);
      const testChild = SizedBox(width: 100, height: 100, child: Placeholder());

      // When
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PositionedConfidenceBadge(
              confidence: confidence,
              margin: customMargin,
              child: testChild,
            ),
          ),
        ),
      );

      // Then
      final positioned = tester.widget<Positioned>(find.byType(Positioned));
      expect(positioned.top, customMargin.top);
      expect(positioned.right, customMargin.right);
    });

    testWidgets('passes confidence and size to ConfidenceBadge', (WidgetTester tester) async {
      // Given
      const double confidence = 75.0;
      const double customSize = 28.0;
      const testChild = SizedBox(width: 100, height: 100, child: Placeholder());

      // When
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PositionedConfidenceBadge(
              confidence: confidence,
              size: customSize,
              child: testChild,
            ),
          ),
        ),
      );

      // Then
      final confidenceBadge = tester.widget<ConfidenceBadge>(
        find.byType(ConfidenceBadge)
      );
      expect(confidenceBadge.confidence, confidence);
      expect(confidenceBadge.size, customSize);
    });
  });
}