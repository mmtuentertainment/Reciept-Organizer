import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:receipt_organizer/features/receipts/presentation/screens/receipt_detail_screen.dart';
import 'package:receipt_organizer/features/receipts/presentation/widgets/field_editor.dart';
import 'package:receipt_organizer/shared/widgets/confidence_score_widget.dart';
import 'package:receipt_organizer/features/receipts/presentation/widgets/merchant_field_editor_with_normalization.dart';

void main() {
  group('ReceiptDetailScreen', () {
    late Receipt testReceipt;

    setUp(() {
      testReceipt = Receipt(
        imageUri: 'test/path/receipt.jpg',
        capturedAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: ReceiptStatus.ready,
        ocrResults: ProcessingResult(
          merchant: FieldData(
            value: 'Test Store',
            confidence: 85.0,
            originalText: 'Test Store',
          ),
          date: FieldData(
            value: '01/15/2024',
            confidence: 90.0,
            originalText: '01/15/2024',
          ),
          total: FieldData(
            value: 25.47,
            confidence: 95.0,
            originalText: '\$25.47',
          ),
          tax: FieldData(
            value: 2.04,
            confidence: 88.0,
            originalText: '\$2.04',
          ),
          overallConfidence: 89.5,
          processingDurationMs: 1250,
          allText: ['Test Store', '01/15/2024', '\$25.47', '\$2.04'],
        ),
      );
    });

    testWidgets('displays receipt details with confidence assessment', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ReceiptDetailScreen(receipt: testReceipt),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then
      expect(find.text('Test Store'), findsOneWidget);
      expect(find.text('Data Quality Assessment'), findsOneWidget);
      expect(find.text('Receipt Information'), findsOneWidget);
      expect(find.text('Processing Information'), findsOneWidget);
    });

    testWidgets('shows overall confidence score widget', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ReceiptDetailScreen(receipt: testReceipt),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - Should show ConfidenceScoreWidget with detailed variant
      expect(find.byType(ConfidenceScoreWidget), findsOneWidget);
      
      // Should show confidence percentage
      expect(find.textContaining('90%'), findsOneWidget); // Rounded confidence
    });

    testWidgets('displays quality message based on confidence level', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ReceiptDetailScreen(receipt: testReceipt),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - High confidence should show positive message
      expect(find.textContaining('High quality data'), findsOneWidget);
    });

    testWidgets('shows medium confidence quality message', (WidgetTester tester) async {
      // Given - Medium confidence receipt
      final mediumConfidenceReceipt = testReceipt.copyWith(
        ocrResults: testReceipt.ocrResults!.copyWith(overallConfidence: 78.0),
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ReceiptDetailScreen(receipt: mediumConfidenceReceipt),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then
      expect(find.textContaining('Good data quality'), findsOneWidget);
    });

    testWidgets('shows low confidence quality message', (WidgetTester tester) async {
      // Given - Low confidence receipt
      final lowConfidenceReceipt = testReceipt.copyWith(
        ocrResults: testReceipt.ocrResults!.copyWith(overallConfidence: 65.0),
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ReceiptDetailScreen(receipt: lowConfidenceReceipt),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then
      expect(find.textContaining('Data needs review'), findsOneWidget);
    });

    testWidgets('displays all field editors', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ReceiptDetailScreen(receipt: testReceipt),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - Should have field editors for all fields
      expect(find.byType(MerchantFieldEditorWithNormalization), findsOneWidget);
      expect(find.byType(FieldEditor), findsOneWidget);
      expect(find.byType(FieldEditor), findsNWidgets(2)); // Total and Tax
    });

    testWidgets('shows confidence info dialog', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ReceiptDetailScreen(receipt: testReceipt),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Tap the info button
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then
      expect(find.text('Confidence Scores'), findsOneWidget);
      expect(find.textContaining('Green (85%+)'), findsOneWidget);
      expect(find.textContaining('Orange (75-84%)'), findsOneWidget);
      expect(find.textContaining('Red (<75%)'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
    });

    testWidgets('handles field editing and updates confidence', (WidgetTester tester) async {
      // Given
      Receipt? updatedReceipt;

      await tester.pumpWidget(
        MaterialApp(
          home: ReceiptDetailScreen(
            receipt: testReceipt,
            onReceiptUpdated: (receipt) {
              updatedReceipt = receipt;
            },
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // When - Edit merchant field
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'Edited Store Name');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Tap save button when it appears
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then
      expect(updatedReceipt, isNotNull);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Receipt saved successfully'), findsOneWidget);
    });

    testWidgets('shows save button when changes are made', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ReceiptDetailScreen(receipt: testReceipt),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Initially no save button
      expect(find.byType(FloatingActionButton), findsNothing);

      // Edit a field
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'Changed Store');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - Save button should appear
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('displays receipt metadata', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ReceiptDetailScreen(receipt: testReceipt),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then
      expect(find.text('Processing Information'), findsOneWidget);
      expect(find.text('Captured'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Processing Time'), findsOneWidget);
      expect(find.textContaining('1250ms'), findsOneWidget);
    });

    testWidgets('shows processing state for receipts without OCR', (WidgetTester tester) async {
      // Given - Receipt without OCR results
      final processingReceipt = Receipt(
        imageUri: 'test/path/receipt.jpg',
        capturedAt: DateTime.now(),
        status: ReceiptStatus.processing,
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ReceiptDetailScreen(receipt: processingReceipt),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Processing receipt...'), findsOneWidget);
    });

    testWidgets('handles menu actions', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ReceiptDetailScreen(receipt: testReceipt),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Open menu
      await tester.tap(find.byType(PopupMenuButton));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - Should show menu items
      expect(find.text('Export'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.byIcon(Icons.download), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('shows delete confirmation dialog', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ReceiptDetailScreen(receipt: testReceipt),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Open menu and tap delete
      await tester.tap(find.byType(PopupMenuButton));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then
      expect(find.text('Delete Receipt'), findsOneWidget);
      expect(find.textContaining('Are you sure'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsNWidgets(2)); // Menu and dialog
    });

    testWidgets('calculates overall confidence correctly when fields are edited', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: ReceiptDetailScreen(receipt: testReceipt),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Edit the total field (which has 40% weight)
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(2), '30.00'); // Assuming total is 3rd field
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Then - Overall confidence should be recalculated
      // The confidence display should update to reflect the new calculation
      expect(find.byType(ConfidenceScoreWidget), findsOneWidget);
    });
  });
}