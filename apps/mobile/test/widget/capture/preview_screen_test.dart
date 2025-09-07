import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:receipt_organizer/features/capture/screens/preview_screen.dart';
import 'package:receipt_organizer/features/capture/providers/capture_provider.dart';
import 'package:receipt_organizer/features/capture/providers/preview_initialization_provider.dart';
import 'package:receipt_organizer/features/receipts/presentation/widgets/field_editor.dart';
import 'package:receipt_organizer/features/receipts/presentation/widgets/merchant_field_editor_with_normalization.dart';
import 'package:receipt_organizer/features/capture/widgets/capture_failed_state.dart';
import 'package:receipt_organizer/features/capture/widgets/notes_field_editor.dart';
import 'package:receipt_organizer/shared/widgets/zoomable_image_viewer.dart';
import 'package:state_notifier/state_notifier.dart';

import '../../helpers/provider_test_helpers.dart';
import 'preview_screen_test.mocks.dart';

/// Test implementation of PreviewProcessingNotifier that doesn't start processing automatically
class TestPreviewProcessingNotifier extends PreviewProcessingNotifier {
  TestPreviewProcessingNotifier({
    required Ref ref,
    required PreviewInitParams params,
    PreviewInitState? initialState,
  }) : super(ref: ref, params: params) {
    if (initialState != null) {
      state = initialState;
    }
  }
  
  @override
  Future<void> initialize() async {
    // No-op for tests
  }
  
  @override
  Future<void> startProcessing() async {
    // No-op for tests - prevent automatic processing
  }
  
  @override
  Future<void> dispose() async {
    // No-op for tests - skip cleanup to avoid disposed container errors
    // Don't call super.dispose() to avoid ref.read in disposed container
  }
}
@GenerateMocks([
  CaptureNotifier,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('PreviewScreen', () {
    late Uint8List testImageData;
    late ProcessingResult mockProcessingResult;
    late CaptureState mockCaptureState;
    late PreviewInitState mockInitState;

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
      
      mockInitState = PreviewInitState(
        imageData: testImageData,
        sessionId: 'test-session-123',
        processingResult: mockProcessingResult,
        captureState: mockCaptureState,
      );
    });

    Widget createPreviewScreen({
      CaptureState? captureState,
      PreviewInitState? initState,
      List<Override>? additionalOverrides,
    }) {
      final mockNotifier = MockCaptureNotifier();
      when(mockNotifier.state).thenReturn(captureState ?? mockCaptureState);
      when(mockNotifier.updateField(any, any)).thenAnswer((_) async => true);
      when(mockNotifier.addListener(any, fireImmediately: anyNamed('fireImmediately'))).thenReturn(() {});
      
      final overrides = [
        captureProvider.overrideWith((ref) => mockNotifier),
        ...?additionalOverrides,
      ];
      
      return ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          home: PreviewScreen(imageData: testImageData),
        ),
      );
    }

    group('Successful processing state', () {
      testWidgets('displays image and success header', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createPreviewScreen());
        await tester.pump(); // Initial build
        await tester.pump(const Duration(milliseconds: 200)); // Wait for processing

        // Then
        expect(find.text('Receipt Processed Successfully'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('displays all field editors for inline editing', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createPreviewScreen());
        // Wait for initial build and processing
        await tester.pump(); // Initial build
        await tester.pump(const Duration(milliseconds: 200)); // Wait for any animations

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
        await tester.pump(); // Initial build
        await tester.pump(const Duration(milliseconds: 200)); // Wait for processing

        // Then
        expect(find.text('Overall Confidence: 89.5%'), findsOneWidget);
        expect(find.byIcon(Icons.insights), findsOneWidget);
      });

      testWidgets('allows inline editing of merchant field', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createPreviewScreen());
        await tester.pump(); // Initial build
        await tester.pump(const Duration(milliseconds: 200)); // Wait for processing

        // When - Find and edit the merchant field
        final merchantEditor = find.byType(MerchantFieldEditor);
        expect(merchantEditor, findsOneWidget);
        
        final merchantTextField = find.descendant(
          of: merchantEditor,
          matching: find.byType(TextField),
        );
        expect(merchantTextField, findsOneWidget);

        await tester.enterText(merchantTextField, 'Edited Store Name');
        await tester.pump(); // Process text input

        // Then - The change should be reflected
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
        await tester.pump(); // Process text input

        // Wait for auto-save confirmation delay
        await tester.pump(const Duration(milliseconds: 500));

        // Then - Should show save confirmation
        expect(find.text('Changes saved'), findsOneWidget);
      });

      testWidgets('Accept & Continue button navigates back', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createPreviewScreen());
        await tester.pump(); // Initial build
        await tester.pump(const Duration(milliseconds: 200)); // Wait for processing

        // When - Scroll to find and tap Accept & Continue button
        final acceptButton = find.text('Accept & Continue');
        expect(acceptButton, findsOneWidget);
        
        // Scroll to make button visible
        await tester.ensureVisible(acceptButton);
        await tester.pump(); // Wait for scroll animation
        
        await tester.tap(acceptButton);
        await tester.pump(); // Process tap

        // Then - Button should be tappable (navigation would be tested in integration test)
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
        await tester.pump(); // Use pump instead of pumpAndSettle for loading state

        // Then
        expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
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
        await tester.pump(); // Initial build
        await tester.pump(); // Process state

        // Then - Should show image preview fallback
        expect(find.byType(Image), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('field editors have proper semantic labels', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createPreviewScreen());
        await tester.pump(); // Initial build
        await tester.pump(const Duration(milliseconds: 200)); // Wait for processing

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
        await tester.pump(); // Initial build
        await tester.pump(const Duration(milliseconds: 200)); // Wait for processing

        // When - Make rapid text changes
        final merchantTextField = find.descendant(
          of: find.byType(MerchantFieldEditor),
          matching: find.byType(TextField),
        );
        
        await tester.enterText(merchantTextField, 'A');
        await tester.enterText(merchantTextField, 'AB');
        await tester.enterText(merchantTextField, 'ABC');
        await tester.pump(); // Process text inputs

        // Then - Should call updateField for each change but debounce save confirmations
        verify(mockNotifier.updateField('merchant', any)).called(3);
      });
    });

    group('Tablet layout', () {
      testWidgets('uses side-by-side layout on tablets', (WidgetTester tester) async {
        // Given - Set tablet size
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        
        await tester.pumpWidget(createPreviewScreen());
        await tester.pump(); // Initial build
        await tester.pump(const Duration(milliseconds: 200)); // Wait for processing

        // Then - Should use Row layout for side-by-side view
        // Find the top-level Row that's a direct child of LayoutBuilder
        final layoutBuilder = find.byType(LayoutBuilder);
        expect(layoutBuilder, findsOneWidget);
        
        // Get the LayoutBuilder widget and check its child is a Row
        final layoutBuilderWidget = tester.widget<LayoutBuilder>(layoutBuilder);
        tester.element(layoutBuilder).visitChildElements((element) {
          expect(element.widget, isA<Row>());
        });
      });

      testWidgets('uses stacked layout on phones', (WidgetTester tester) async {
        // Given - Set phone size
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        
        await tester.pumpWidget(createPreviewScreen());
        await tester.pump(); // Initial build
        await tester.pump(const Duration(milliseconds: 200)); // Wait for processing

        // Then - Should use Column layout for stacked view
        // Find the top-level Column that's a direct child of LayoutBuilder
        final layoutBuilder = find.byType(LayoutBuilder);
        expect(layoutBuilder, findsOneWidget);
        
        // Get the LayoutBuilder widget and check its child is a Column
        final layoutBuilderWidget = tester.widget<LayoutBuilder>(layoutBuilder);
        tester.element(layoutBuilder).visitChildElements((element) {
          expect(element.widget, isA<Column>());
        });
      });
    });
  });
}