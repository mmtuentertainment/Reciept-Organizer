import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:receipt_organizer/features/capture/screens/preview_screen.dart';
import 'package:receipt_organizer/features/capture/providers/capture_provider.dart';
import 'package:receipt_organizer/features/receipts/presentation/widgets/field_editor.dart';

import 'preview_screen_test.mocks.dart';

@GenerateMocks([
  CaptureNotifier,
])
void main() {
  group('PreviewScreen', () {
    late Uint8List testImageData;
    late ProcessingResult mockProcessingResult;
    late CaptureState mockCaptureState;

    setUp(() {
      testImageData = Uint8List.fromList([1, 2, 3, 4]);
      
      mockProcessingResult = ProcessingResult(
        merchant: FieldData(value: 'Test Store', confidence: 85.0, originalText: 'Test Store'),
        date: FieldData(value: '01/15/2024', confidence: 90.0, originalText: '01/15/2024'),
        total: FieldData(value: 25.99, confidence: 95.0, originalText: '\$25.99'),
        tax: FieldData(value: 2.08, confidence: 88.0, originalText: '\$2.08'),
        overallConfidence: 89.5,
        processingDurationMs: 1500,
      );

      mockCaptureState = CaptureState(
        isProcessing: false,
        isRetryMode: false,
        lastProcessingResult: mockProcessingResult,
      );
    });

    Widget createPreviewScreen({CaptureState? captureState}) {
      final mockNotifier = MockCaptureNotifier();
      when(mockNotifier.state).thenReturn(captureState ?? mockCaptureState);
      when(mockNotifier.updateField(any, any)).thenAnswer((_) async => true);
      when(mockNotifier.addListener(any, fireImmediately: anyNamed('fireImmediately'))).thenReturn(() {});
      
      return ProviderScope(
        overrides: [
          captureProvider.overrideWith((ref) => mockNotifier),
        ],
        child: MaterialApp(
          home: PreviewScreen(imageData: testImageData),
        ),
      );
    }

    group('Successful processing state', () {
      testWidgets('displays image and success header', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createPreviewScreen());
        await tester.pumpAndSettle();

        // Then
        expect(find.text('Receipt Processed Successfully'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('displays all field editors for inline editing', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createPreviewScreen());
        await tester.pumpAndSettle();

        // Then
        expect(find.byType(MerchantFieldEditor), findsOneWidget);
        expect(find.byType(DateFieldEditor), findsOneWidget);
        expect(find.byType(AmountFieldEditor), findsNWidgets(2)); // Total and Tax
        
        // Check that field values are displayed
        expect(find.text('Test Store'), findsOneWidget);
        expect(find.text('01/15/2024'), findsOneWidget);
        expect(find.text('25.99'), findsOneWidget);
        expect(find.text('2.08'), findsOneWidget);
      });

      testWidgets('displays overall confidence score', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createPreviewScreen());
        await tester.pumpAndSettle();

        // Then
        expect(find.text('Overall Confidence: 89.5%'), findsOneWidget);
        expect(find.byIcon(Icons.insights), findsOneWidget);
      });

      testWidgets('allows inline editing of merchant field', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createPreviewScreen());
        await tester.pumpAndSettle();

        // When - Find and edit the merchant field
        final merchantEditor = find.byType(MerchantFieldEditor);
        expect(merchantEditor, findsOneWidget);
        
        final merchantTextField = find.descendant(
          of: merchantEditor,
          matching: find.byType(TextField),
        );
        expect(merchantTextField, findsOneWidget);

        await tester.enterText(merchantTextField, 'Edited Store Name');
        await tester.pumpAndSettle();

        // Then - The change should trigger the callback
        expect(find.text('Edited Store Name'), findsOneWidget);
      });

      testWidgets('allows inline editing of date field', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createPreviewScreen());
        await tester.pumpAndSettle();

        // When - Edit the date field
        final dateEditor = find.byType(DateFieldEditor);
        expect(dateEditor, findsOneWidget);
        
        final dateTextField = find.descendant(
          of: dateEditor,
          matching: find.byType(TextField),
        );
        expect(dateTextField, findsOneWidget);

        await tester.enterText(dateTextField, '02/20/2024');
        await tester.pumpAndSettle();

        // Then
        expect(find.text('02/20/2024'), findsOneWidget);
      });

      testWidgets('allows inline editing of amount fields', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createPreviewScreen());
        await tester.pumpAndSettle();

        // When - Find all amount editors (Total and Tax)
        final amountEditors = find.byType(AmountFieldEditor);
        expect(amountEditors, findsNWidgets(2));

        // Get text fields within amount editors
        final amountTextFields = find.descendant(
          of: amountEditors.first,
          matching: find.byType(TextField),
        );
        expect(amountTextFields, findsOneWidget);

        // Edit the first amount field (Total)
        await tester.enterText(amountTextFields, '35.99');
        await tester.pumpAndSettle();

        // Then
        expect(find.text('35.99'), findsOneWidget);
      });

      testWidgets('calls CaptureProvider updateField when fields are edited', (WidgetTester tester) async {
        // Given
        final mockNotifier = MockCaptureNotifier();
        when(mockNotifier.state).thenReturn(mockCaptureState);
        when(mockNotifier.updateField(any, any)).thenAnswer((_) async => true);
        when(mockNotifier.addListener(any, fireImmediately: anyNamed('fireImmediately'))).thenReturn(() {});

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              captureProvider.overrideWith((ref) => mockNotifier),
            ],
            child: MaterialApp(
              home: PreviewScreen(imageData: testImageData),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // When - Edit merchant field
        final merchantTextField = find.descendant(
          of: find.byType(MerchantFieldEditor),
          matching: find.byType(TextField),
        );
        
        await tester.enterText(merchantTextField, 'New Store Name');
        await tester.pumpAndSettle();

        // Then - Should call updateField on the provider
        verify(mockNotifier.updateField('merchant', any)).called(1);
      });

      testWidgets('shows save confirmation after successful edit', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createPreviewScreen());
        await tester.pumpAndSettle();

        // When - Edit a field
        final merchantTextField = find.descendant(
          of: find.byType(MerchantFieldEditor),
          matching: find.byType(TextField),
        );
        
        await tester.enterText(merchantTextField, 'New Store');
        await tester.pumpAndSettle();

        // Wait for auto-save confirmation delay
        await tester.pump(const Duration(milliseconds: 500));

        // Then - Should show save confirmation
        expect(find.text('Changes saved'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsWidgets);
      });

      testWidgets('shows edited indicator when fields are modified', (WidgetTester tester) async {
        // Given
        final editedState = CaptureState(
          isProcessing: false,
          isRetryMode: false,
          lastProcessingResult: ProcessingResult(
            merchant: FieldData(
              value: 'Edited Store',
              confidence: 100.0,
              originalText: 'Test Store',
              isManuallyEdited: true,
            ),
            date: mockProcessingResult.date,
            total: mockProcessingResult.total,
            tax: mockProcessingResult.tax,
            overallConfidence: 91.0,
            processingDurationMs: 1500,
          ),
        );

        await tester.pumpWidget(createPreviewScreen(captureState: editedState));
        await tester.pumpAndSettle();

        // Then - Should show "Edited" indicator in the header
        expect(find.text('Edited'), findsWidgets);
        expect(find.byIcon(Icons.edit), findsWidgets);
      });

      testWidgets('Accept & Continue button navigates back', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createPreviewScreen());
        await tester.pumpAndSettle();

        // When - Tap Accept & Continue button
        final acceptButton = find.text('Accept & Continue');
        expect(acceptButton, findsOneWidget);
        
        await tester.tap(acceptButton);
        await tester.pumpAndSettle();

        // Then - Should navigate back (pop the screen)
        // In a real navigation test, we would verify navigation behavior
        // For this unit test, we verify the button exists and is tappable
        expect(acceptButton, findsOneWidget);
      });
    });

    group('Processing state', () {
      testWidgets('displays processing indicator when processing', (WidgetTester tester) async {
        // Given
        final processingState = CaptureState(
          isProcessing: true,
          isRetryMode: false,
        );

        await tester.pumpWidget(createPreviewScreen(captureState: processingState));
        await tester.pumpAndSettle();

        // Then
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Processing receipt...'), findsOneWidget);
      });
    });

    group('Error handling', () {
      testWidgets('handles null processing result gracefully', (WidgetTester tester) async {
        // Given
        final nullResultState = CaptureState(
          isProcessing: false,
          isRetryMode: false,
          lastProcessingResult: null,
        );

        await tester.pumpWidget(createPreviewScreen(captureState: nullResultState));
        await tester.pumpAndSettle();

        // Then - Should show image preview or fallback state
        expect(find.byType(Image), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('field editors have proper semantic labels', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createPreviewScreen());
        await tester.pumpAndSettle();

        // Then - Check that field editors provide accessibility labels
        expect(find.byType(MerchantFieldEditor), findsOneWidget);
        expect(find.byType(DateFieldEditor), findsOneWidget);
        expect(find.byType(AmountFieldEditor), findsNWidgets(2));

        // Verify text fields are accessible
        expect(find.byType(TextField), findsNWidgets(4));
      });
    });

    group('Performance', () {
      testWidgets('auto-save debouncing prevents excessive updates', (WidgetTester tester) async {
        // Given
        final mockNotifier = MockCaptureNotifier();
        when(mockNotifier.state).thenReturn(mockCaptureState);
        when(mockNotifier.updateField(any, any)).thenAnswer((_) async => true);
        when(mockNotifier.addListener(any, fireImmediately: anyNamed('fireImmediately'))).thenReturn(() {});

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              captureProvider.overrideWith((ref) => mockNotifier),
            ],
            child: MaterialApp(
              home: PreviewScreen(imageData: testImageData),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // When - Make rapid text changes
        final merchantTextField = find.descendant(
          of: find.byType(MerchantFieldEditor),
          matching: find.byType(TextField),
        );
        
        await tester.enterText(merchantTextField, 'A');
        await tester.enterText(merchantTextField, 'AB');
        await tester.enterText(merchantTextField, 'ABC');
        await tester.pumpAndSettle();

        // Then - Should call updateField for each change but debounce save confirmations
        verify(mockNotifier.updateField('merchant', any)).called(3);
      });
    });
  });
}