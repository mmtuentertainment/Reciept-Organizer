import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/features/receipts/presentation/widgets/merchant_field_editor_with_normalization.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';

void main() {
  group('MerchantFieldEditorWithNormalization', () {
    testWidgets('should display normalization indicator when merchant name is normalized',
        (WidgetTester tester) async {
      // Arrange
      final normalizedField = FieldData(
        value: 'McDonalds',
        originalText: 'MCDONALDS #4521',
        confidence: 85.0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MerchantFieldEditorWithNormalization(
              fieldData: normalizedField,
              showNormalizationIndicator: true,
            ),
          ),
        ),
      );

      // Assert - Find normalization indicator
      expect(find.byIcon(Icons.auto_fix_high), findsOneWidget);
      
      // Verify tooltip
      final tooltipFinder = find.byType(Tooltip);
      expect(tooltipFinder, findsOneWidget);
      
      final tooltip = tester.widget<Tooltip>(tooltipFinder);
      expect(tooltip.message, contains('MCDONALDS #4521'));
    });

    testWidgets('should not display indicator when merchant name is not normalized',
        (WidgetTester tester) async {
      // Arrange
      final nonNormalizedField = FieldData(
        value: 'Target',
        originalText: 'Target',
        confidence: 90.0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MerchantFieldEditorWithNormalization(
              fieldData: nonNormalizedField,
              showNormalizationIndicator: true,
            ),
          ),
        ),
      );

      // Assert - Should not find normalization indicator
      expect(find.byIcon(Icons.auto_fix_high), findsNothing);
    });

    testWidgets('should show normalization details dialog when indicator is tapped',
        (WidgetTester tester) async {
      // Arrange
      final normalizedField = FieldData(
        value: 'CVS Pharmacy',
        originalText: 'CVS/PHARMACY #567',
        confidence: 88.0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MerchantFieldEditorWithNormalization(
              fieldData: normalizedField,
              showNormalizationIndicator: true,
            ),
          ),
        ),
      );

      // Tap the normalization indicator
      await tester.tap(find.byIcon(Icons.auto_fix_high));
      await tester.pumpAndSettle();

      // Assert - Dialog should be shown
      expect(find.text('Merchant Name Normalized'), findsOneWidget);
      expect(find.text('Original:'), findsOneWidget);
      expect(find.text('CVS/PHARMACY #567'), findsOneWidget);
      expect(find.text('Normalized:'), findsOneWidget);
      expect(find.text('CVS Pharmacy').last, findsOneWidget);
      
      // Close dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Merchant Name Normalized'), findsNothing);
    });

    testWidgets('should hide indicator when showNormalizationIndicator is false',
        (WidgetTester tester) async {
      // Arrange
      final normalizedField = FieldData(
        value: 'Walmart',
        originalText: 'WALMART STORE #1234',
        confidence: 92.0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MerchantFieldEditorWithNormalization(
              fieldData: normalizedField,
              showNormalizationIndicator: false,
            ),
          ),
        ),
      );

      // Assert - Should not show indicator even though field is normalized
      expect(find.byIcon(Icons.auto_fix_high), findsNothing);
    });

    testWidgets('should handle field data changes correctly',
        (WidgetTester tester) async {
      // Arrange
      final initialField = FieldData(
        value: '7-Eleven',
        originalText: '7-ELEVEN #890',
        confidence: 85.0,
      );
      
      FieldData? updatedField;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MerchantFieldEditorWithNormalization(
              fieldData: initialField,
              onChanged: (field) => updatedField = field,
              showNormalizationIndicator: true,
            ),
          ),
        ),
      );

      // Find text field and enter new text
      await tester.enterText(find.byType(TextField), 'New Store Name');
      await tester.pump();

      // Assert
      expect(updatedField, isNotNull);
      expect(updatedField!.value, equals('New Store Name'));
      expect(updatedField!.originalText, equals('7-ELEVEN #890')); // Original preserved
      expect(updatedField!.isManuallyEdited, isTrue);
    });

    testWidgets('should position indicator correctly with confidence display',
        (WidgetTester tester) async {
      // Arrange
      final normalizedField = FieldData(
        value: 'Starbucks',
        originalText: 'STARBUCKS #12345',
        confidence: 75.0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MerchantFieldEditorWithNormalization(
              fieldData: normalizedField,
              showConfidence: true,
              showNormalizationIndicator: true,
            ),
          ),
        ),
      );

      // Assert - Both confidence indicator and normalization icon should be visible
      expect(find.byIcon(Icons.auto_fix_high), findsOneWidget);
      // The Stack widget positions the indicator to avoid overlapping with confidence
      final stacks = find.byType(Stack);
      expect(stacks, findsWidgets);
      // Verify at least one Stack has multiple children for positioning
      bool hasMultiChildStack = false;
      for (int i = 0; i < tester.widgetList(stacks).length; i++) {
        final stack = tester.widget<Stack>(stacks.at(i));
        if (stack.children.length > 1) {
          hasMultiChildStack = true;
          break;
        }
      }
      expect(hasMultiChildStack, isTrue);
    });
  });
}