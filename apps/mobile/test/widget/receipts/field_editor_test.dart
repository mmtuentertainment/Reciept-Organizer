import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:receipt_organizer/features/receipts/presentation/widgets/field_editor.dart';

void main() {
  group('FieldEditor', () {
    late FieldData testFieldData;

    setUp(() {
      testFieldData = FieldData(
        value: 'Test Store',
        confidence: 85.0,
        originalText: 'Test Store',
      );
    });

    testWidgets('displays field value and confidence correctly', (WidgetTester tester) async {
      // Given
      bool changedCalled = false;
      FieldData? updatedFieldData;

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FieldEditor(
              fieldName: 'Merchant',
              fieldData: testFieldData,
              label: 'Merchant Name',
              onFieldDataChanged: (data) {
                changedCalled = true;
                updatedFieldData = data;
              },
            ),
          ),
        ),
      );

      // Then
      expect(find.text('Merchant Name'), findsOneWidget);
      expect(find.text('Test Store'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows success indicator for high confidence fields', (WidgetTester tester) async {
      // Given - high confidence field
      final highConfidenceData = FieldData(
        value: 'High Confidence Store',
        confidence: 95.0,
        originalText: 'High Confidence Store',
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FieldEditor(
              fieldName: 'Merchant',
              fieldData: highConfidenceData,
              label: 'Merchant Name',
            ),
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Then - Should show success icon for high confidence
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('shows warning indicator for low confidence fields', (WidgetTester tester) async {
      // Given - low confidence field
      final lowConfidenceData = FieldData(
        value: 'Low Confidence Store',
        confidence: 60.0,
        originalText: 'Low Confidence Store',
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FieldEditor(
              fieldName: 'Merchant',
              fieldData: lowConfidenceData,
              label: 'Merchant Name',
            ),
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Then - Should show warning icon for low confidence
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });

    testWidgets('handles text changes and marks as manually edited', (WidgetTester tester) async {
      // Given
      FieldData? updatedFieldData;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FieldEditor(
              fieldName: 'Merchant',
              fieldData: testFieldData,
              onFieldDataChanged: (data) {
                updatedFieldData = data;
              },
            ),
          ),
        ),
      );

      // When - User edits the field
      await tester.enterText(find.byType(TextField), 'Edited Store Name');
      await tester.pumpAndSettle();

      // Then
      expect(updatedFieldData, isNotNull);
      expect(updatedFieldData!.value, 'Edited Store Name');
      expect(updatedFieldData!.isManuallyEdited, true);
      expect(find.text('Edited'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('validates date format correctly', (WidgetTester tester) async {
      // Given
      FieldData? updatedFieldData;
      final dateFieldData = FieldData(
        value: '01/15/2024',
        confidence: 80.0,
        originalText: '01/15/2024',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateFieldEditor(
              fieldData: dateFieldData,
              onChanged: (data) {
                updatedFieldData = data;
              },
            ),
          ),
        ),
      );

      // When - Enter invalid date format
      await tester.enterText(find.byType(TextField), '13/32/2024');
      await tester.pumpAndSettle();

      // Then - Should show error validation status
      expect(updatedFieldData, isNotNull);
      expect(updatedFieldData!.validationStatus, 'error');
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('validates amount format correctly', (WidgetTester tester) async {
      // Given
      FieldData? updatedFieldData;
      final amountFieldData = FieldData(
        value: 25.99,
        confidence: 90.0,
        originalText: '\$25.99',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmountFieldEditor(
              fieldName: 'Total',
              label: 'Total Amount',
              fieldData: amountFieldData,
              onChanged: (data) {
                updatedFieldData = data;
              },
            ),
          ),
        ),
      );

      // When - Enter negative amount
      await tester.enterText(find.byType(TextField), '-10.50');
      await tester.pumpAndSettle();

      // Then - Should show warning validation status
      expect(updatedFieldData, isNotNull);
      expect(updatedFieldData!.validationStatus, 'warning');
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    });

    testWidgets('triggers confidence change animation', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FieldEditor(
              fieldName: 'Merchant',
              fieldData: testFieldData,
            ),
          ),
        ),
      );

      // When - Edit field to trigger animation
      await tester.enterText(find.byType(TextField), 'New Store Name');
      
      // Pump multiple frames to test animation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Then - Animation should complete without errors
      expect(find.byType(Transform), findsWidgets);
    });

    testWidgets('handles empty field validation', (WidgetTester tester) async {
      // Given
      FieldData? updatedFieldData;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FieldEditor(
              fieldName: 'Merchant',
              fieldData: testFieldData,
              onFieldDataChanged: (data) {
                updatedFieldData = data;
              },
            ),
          ),
        ),
      );

      // When - Clear the field
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // Then - Should show error status for empty field
      expect(updatedFieldData, isNotNull);
      expect(updatedFieldData!.validationStatus, 'error');
    });

    testWidgets('preserves original confidence after editing', (WidgetTester tester) async {
      // Given
      FieldData? updatedFieldData;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FieldEditor(
              fieldName: 'Merchant',
              fieldData: testFieldData,
              onFieldDataChanged: (data) {
                updatedFieldData = data;
              },
            ),
          ),
        ),
      );

      // When - Edit the field
      await tester.enterText(find.byType(TextField), 'Edited Store');
      await tester.pumpAndSettle();

      // Then - Should preserve original text
      expect(updatedFieldData, isNotNull);
      expect(updatedFieldData!.originalText, 'Test Store'); // Original preserved
      expect(updatedFieldData!.isManuallyEdited, true);
    });
  });

  group('MerchantFieldEditor', () {
    testWidgets('capitalizes merchant names correctly', (WidgetTester tester) async {
      // Given
      FieldData? updatedFieldData;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MerchantFieldEditor(
              onChanged: (data) {
                updatedFieldData = data;
              },
            ),
          ),
        ),
      );

      // When - Enter lowercase merchant name
      await tester.enterText(find.byType(TextField), 'walmart store');
      await tester.pumpAndSettle();

      // Then - Should capitalize words
      expect(updatedFieldData, isNotNull);
      expect(updatedFieldData!.value, 'Walmart Store');
    });
  });

  group('DateFieldEditor', () {
    testWidgets('formats date input correctly', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateFieldEditor(),
          ),
        ),
      );

      // Then
      expect(find.text('MM/DD/YYYY'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('AmountFieldEditor', () {
    testWidgets('formats amount input correctly', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmountFieldEditor(
              fieldName: 'Total',
              label: 'Total Amount',
            ),
          ),
        ),
      );

      // Then
      expect(find.text('Total Amount'), findsOneWidget);
      expect(find.text('\$0.00'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('prevents multiple decimal points', (WidgetTester tester) async {
      // Given
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmountFieldEditor(
              fieldName: 'Total',
              label: 'Total Amount',
            ),
          ),
        ),
      );

      // When - Try to enter multiple decimal points
      await tester.enterText(find.byType(TextField), '25.99.00');
      await tester.pumpAndSettle();

      // Then - Should prevent multiple decimal points
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, isNot(contains('25.99.00')));
    });
  });
}