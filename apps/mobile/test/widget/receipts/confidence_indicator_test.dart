import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/features/receipts/presentation/widgets/confidence_indicator.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';

void main() {
  group('ConfidenceIndicator', () {
    testWidgets('displays field data with confidence information', (WidgetTester tester) async {
      // Given
      final fieldData = FieldData(
        value: 'Sample Store',
        confidence: 85.0,
        originalText: 'Sample Store',
        isManuallyEdited: false,
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfidenceIndicator(
              fieldData: fieldData,
              fieldName: 'Merchant',
            ),
          ),
        ),
      );

      // Then
      expect(find.text('Merchant'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.text('High confidence'), findsOneWidget);
    });

    testWidgets('shows warning for low confidence fields', (WidgetTester tester) async {
      // Given
      final fieldData = FieldData(
        value: '12.34',
        confidence: 60.0,
        originalText: '12.34',
        isManuallyEdited: false,
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfidenceIndicator(
              fieldData: fieldData,
              fieldName: 'Total',
            ),
          ),
        ),
      );

      // Then
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
      expect(find.text('Please verify this field'), findsOneWidget);
      
      // Verify red color scheme
      final containers = tester.widgetList<Container>(find.byType(Container));
      final mainContainer = containers.firstWhere((container) {
        final decoration = container.decoration;
        return decoration is BoxDecoration && decoration.color != null;
      });
      final decoration = mainContainer.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFFFFEBEE)); // Red background
    });

    testWidgets('shows medium confidence with orange styling', (WidgetTester tester) async {
      // Given
      final fieldData = FieldData(
        value: '01/15/2024',
        confidence: 78.0,
        originalText: '01/15/2024',
        isManuallyEdited: false,
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfidenceIndicator(
              fieldData: fieldData,
              fieldName: 'Date',
            ),
          ),
        ),
      );

      // Then
      expect(find.text('78%'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.text('May need verification'), findsOneWidget);
    });

    testWidgets('shows edit indicator for manually edited fields', (WidgetTester tester) async {
      // Given
      final fieldData = FieldData(
        value: 'Edited Store Name',
        confidence: 85.0,
        originalText: 'Original Store',
        isManuallyEdited: true,
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfidenceIndicator(
              fieldData: fieldData,
              fieldName: 'Merchant',
            ),
          ),
        ),
      );

      // Then
      expect(find.byIcon(Icons.edit), findsOneWidget);
      
      // Verify thicker border for edited fields
      final containers = tester.widgetList<Container>(find.byType(Container));
      final mainContainer = containers.firstWhere((container) {
        final decoration = container.decoration;
        return decoration is BoxDecoration && 
               decoration.border != null && 
               decoration.border!.top.width == 2;
      });
      final decoration = mainContainer.decoration as BoxDecoration;
      expect(decoration.border?.top.width, 2);
    });

    testWidgets('displays progress bar when showProgressBar is true', (WidgetTester tester) async {
      // Given
      final fieldData = FieldData(
        value: 'Test Value',
        confidence: 72.0,
        originalText: 'Test Value',
        isManuallyEdited: false,
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfidenceIndicator(
              fieldData: fieldData,
              fieldName: 'Test Field',
              showProgressBar: true,
            ),
          ),
        ),
      );

      // Then
      expect(find.byType(FractionallySizedBox), findsOneWidget);
      
      final fractionallySizedBox = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox)
      );
      expect(fractionallySizedBox.widthFactor, closeTo(0.72, 0.01));
    });

    testWidgets('shows processing indicator when fieldData is null', (WidgetTester tester) async {
      // Given
      const ConfidenceIndicator indicator = ConfidenceIndicator(
        fieldData: null,
        fieldName: 'Processing Field',
      );

      // When
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: indicator,
          ),
        ),
      );

      // Then
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Processing Processing Field...'), findsOneWidget);
    });

    testWidgets('hides label when showLabel is false', (WidgetTester tester) async {
      // Given
      final fieldData = FieldData(
        value: 'Test',
        confidence: 85.0,
        originalText: 'Test',
        isManuallyEdited: false,
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfidenceIndicator(
              fieldData: fieldData,
              fieldName: 'Hidden Label',
              showLabel: false,
            ),
          ),
        ),
      );

      // Then
      expect(find.text('Hidden Label'), findsNothing);
      expect(find.text('85%'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('applies custom padding', (WidgetTester tester) async {
      // Given
      final fieldData = FieldData(
        value: 'Test',
        confidence: 85.0,
        originalText: 'Test',
        isManuallyEdited: false,
      );
      const customPadding = EdgeInsets.all(16.0);

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfidenceIndicator(
              fieldData: fieldData,
              fieldName: 'Test',
              padding: customPadding,
            ),
          ),
        ),
      );

      // Then
      final containers = tester.widgetList<Container>(find.byType(Container));
      final paddedContainer = containers.firstWhere((container) {
        return container.padding == customPadding;
      });
      expect(paddedContainer.padding, customPadding);
    });

    testWidgets('handles confidence boundary values correctly', (WidgetTester tester) async {
      // Test boundary at 75% (low to medium transition)
      final fieldData75 = FieldData(
        value: 'Test',
        confidence: 75.0,
        originalText: 'Test',
        isManuallyEdited: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfidenceIndicator(
              fieldData: fieldData75,
              fieldName: 'Test',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.info_outline), findsOneWidget); // Medium confidence icon
      expect(find.text('75%'), findsOneWidget);

      // Test boundary at 85% (medium to high transition)
      final fieldData85 = FieldData(
        value: 'Test',
        confidence: 85.0,
        originalText: 'Test',
        isManuallyEdited: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfidenceIndicator(
              fieldData: fieldData85,
              fieldName: 'Test',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget); // High confidence icon
      expect(find.text('85%'), findsOneWidget);
    });

    group('Animation behavior', () {
      testWidgets('triggers animation when confidence changes', (WidgetTester tester) async {
        // Given
        final initialFieldData = FieldData(
          value: 'Test',
          confidence: 70.0,
          originalText: 'Test',
          isManuallyEdited: false,
        );

        // When - Initial render
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ConfidenceIndicator(
                fieldData: initialFieldData,
                fieldName: 'Test',
                animate: true,
              ),
            ),
          ),
        );

        // Let animation complete
        await tester.pumpAndSettle();

        // When - Update confidence
        final updatedFieldData = FieldData(
          value: 'Test',
          confidence: 90.0,
          originalText: 'Test',
          isManuallyEdited: false,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ConfidenceIndicator(
                fieldData: updatedFieldData,
                fieldName: 'Test',
                animate: true,
              ),
            ),
          ),
        );

        // Then
        expect(find.text('90%'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      });

      testWidgets('disables animation when animate is false', (WidgetTester tester) async {
        // Given
        final fieldData = FieldData(
          value: 'Test',
          confidence: 85.0,
          originalText: 'Test',
          isManuallyEdited: false,
        );

        // When
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ConfidenceIndicator(
                fieldData: fieldData,
                fieldName: 'Test',
                animate: false,
              ),
            ),
          ),
        );

        // Then - Animation should be disabled
        final transform = tester.widget<Transform>(find.byType(Transform));
        expect(transform.transform.getMaxScaleOnAxis(), 1.0);
      });
    });
  });
}