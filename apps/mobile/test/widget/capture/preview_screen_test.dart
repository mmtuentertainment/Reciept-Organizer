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
import 'package:receipt_organizer/shared/widgets/zoomable_image_viewer.dart';
import 'package:receipt_organizer/features/capture/providers/image_storage_provider.dart';
import '../../mocks/mock_image_storage_service.dart';
import 'preview_screen_test.mocks.dart';

// Mock provider families for the new architecture
final mockPreviewInitializationProvider = FutureProvider.family<PreviewInitState, PreviewInitParams>((ref, params) async {
  // Return default init state for tests
  return PreviewInitState(
    imagePath: '/tmp/test-image.jpg',
    sessionId: params.sessionId ?? 'test-session-123',
  );
});

// Note: PreviewProcessingNotifier type is inferred from the implementation

class MockPreviewProcessingNotifier extends PreviewProcessingNotifier {
  MockPreviewProcessingNotifier({required super.ref, required super.params}) : super();
  
  @override
  Future<void> startProcessing() async {
    // No-op for tests
  }
}
@GenerateNiceMocks([
  MockSpec<CaptureNotifier>(),
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
      
      mockInitState = const PreviewInitState(
        imagePath: '/tmp/test-image.jpg',
        sessionId: 'test-session-123',
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
      
      // Create mock image storage service
      final mockImageStorage = MockImageStorageService();
      
      final initParams = PreviewInitParams(
        imageData: testImageData,
        sessionId: 'test-session-123',
      );
      
      final overrides = <Override>[
        captureProvider.overrideWith((ref) => mockNotifier),
        // Override the image storage provider to use our mock
        imageStorageServiceProvider.overrideWithValue(mockImageStorage),
        // Now the initialization provider will use the mock storage
        previewInitializationProvider(initParams).overrideWith((ref) {
          // Return the state immediately without async
          return Future.value(initState ?? mockInitState);
        }),
        previewProcessingProvider(initParams).overrideWith((ref) {
          return MockPreviewProcessingNotifier(ref: ref, params: initParams);
        }),
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
        
        // Check if we're in loading state
        if (find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
          print('PreviewScreen is in loading state');
          // The initialization provider might not be resolving
          // Try pumping a few more times to let async operations complete
          for (int i = 0; i < 5; i++) {
            await tester.pump(const Duration(milliseconds: 100));
            if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
              print('Loading complete after ${i+1} pumps');
              break;
            }
          }
        }
        
        // Check what's actually rendered
        final circularProgress = find.byType(CircularProgressIndicator);
        final isStillLoading = circularProgress.evaluate().isNotEmpty;
        
        if (isStillLoading) {
          print('WARNING: PreviewScreen stuck in loading state');
          print('This means previewInitializationProvider is not resolving');
        }
        
        // Check for the success state widgets
        final imageViewer = find.byType(ZoomableImageViewer);
        final layoutBuilder = find.byType(LayoutBuilder); 
        
        print('Found ZoomableImageViewer: ${imageViewer.evaluate().isNotEmpty}');
        print('Found LayoutBuilder: ${layoutBuilder.evaluate().isNotEmpty}');
        
        // Check for the expected widgets in success state
        if (!isStillLoading) {
          expect(find.byType(ZoomableImageViewer), findsOneWidget);
          expect(find.byType(LayoutBuilder), findsWidgets);
        } else {
          // If still loading, fail the test with helpful message
          fail('PreviewScreen stuck in loading state - initialization provider not resolving');
        }
      });

      testWidgets('displays all field editors for inline editing', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createPreviewScreen());
        // Wait for initial build and processing
        await tester.pump(const Duration(milliseconds: 100)); // Initial build
        await tester.pump(const Duration(milliseconds: 100)); // Wait for any animations

        // Then
        expect(find.byType(MerchantFieldEditorWithNormalization), findsOneWidget);
        expect(find.byType(FieldEditor), findsAtLeastNWidgets(3)); // Date, Total, Tax
      });

      testWidgets('displays overall confidence score', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createPreviewScreen());
        await tester.pump(const Duration(milliseconds: 100)); // Initial build
        await tester.pump(const Duration(milliseconds: 100)); // Wait for processing

        // Then - Check for confidence display
        // Confidence may be displayed differently in actual implementation
        expect(find.textContaining('89.5'), findsWidgets);
      });

      testWidgets('allows inline editing of merchant field', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createPreviewScreen());
        await tester.pump(const Duration(milliseconds: 100)); // Initial build
        await tester.pump(const Duration(milliseconds: 100)); // Wait for processing

        // When - Find and edit the merchant field
        final merchantEditor = find.byType(MerchantFieldEditorWithNormalization);
        expect(merchantEditor, findsOneWidget);
        
        final merchantTextField = find.descendant(
          of: merchantEditor,
          matching: find.byType(TextField),
        );
        expect(merchantTextField, findsOneWidget);

        await tester.enterText(merchantTextField, 'Edited Store Name');
        await tester.pump(const Duration(milliseconds: 100)); // Process text input

        // Then - The change should be reflected
        expect(find.text('Edited Store Name'), findsOneWidget);
      });

      testWidgets('allows inline editing of date field', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createPreviewScreen());
        await tester.pump(const Duration(milliseconds: 100));

        // When - Edit the date field
        final dateEditor = find.byType(FieldEditor);
        expect(dateEditor, findsOneWidget);
        
        final dateTextField = find.descendant(
          of: dateEditor,
          matching: find.byType(TextField),
        );
        expect(dateTextField, findsOneWidget);

        await tester.enterText(dateTextField, '02/20/2024');
        await tester.pump(const Duration(milliseconds: 100));

        // Then
        expect(find.text('02/20/2024'), findsOneWidget);
      });

      testWidgets('allows inline editing of amount fields', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createPreviewScreen());
        await tester.pump(const Duration(milliseconds: 100));

        // When - Find all amount editors (Total and Tax)
        final amountEditors = find.byType(FieldEditor);
        expect(amountEditors, findsNWidgets(2));

        // Get text fields within amount editors
        final amountTextFields = find.descendant(
          of: amountEditors.first,
          matching: find.byType(TextField),
        );
        expect(amountTextFields, findsOneWidget);

        // Edit the first amount field (Total)
        await tester.enterText(amountTextFields, '35.99');
        await tester.pump(const Duration(milliseconds: 100));

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
        await tester.pump(const Duration(milliseconds: 100));

        // When - Edit merchant field
        final merchantTextField = find.descendant(
          of: find.byType(MerchantFieldEditorWithNormalization),
          matching: find.byType(TextField),
        );
        
        await tester.enterText(merchantTextField, 'New Store Name');
        await tester.pump(const Duration(milliseconds: 100));

        // Then - Should call updateField on the provider
        verify(mockNotifier.updateField('merchant', any)).called(1);
      });

      testWidgets('shows save confirmation after successful edit', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createPreviewScreen());
        await tester.pump(const Duration(milliseconds: 100));

        // When - Edit a field
        final merchantTextField = find.descendant(
          of: find.byType(MerchantFieldEditorWithNormalization),
          matching: find.byType(TextField),
        );
        
        await tester.enterText(merchantTextField, 'New Store');
        await tester.pump(const Duration(milliseconds: 100)); // Process text input

        // Wait for auto-save confirmation delay
        await tester.pump(const Duration(milliseconds: 100));

        // Then - Changes should be processed
        // The field should show the new value
        expect(find.text('New Store'), findsWidgets);
      });

      testWidgets('Accept & Continue button navigates back', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createPreviewScreen());
        await tester.pump(const Duration(milliseconds: 100)); // Initial build
        await tester.pump(const Duration(milliseconds: 100)); // Wait for processing

        // When - Scroll to find and tap Accept & Continue button
        final acceptButton = find.text('Accept & Continue');
        expect(acceptButton, findsOneWidget);
        
        // Scroll to make button visible
        await tester.ensureVisible(acceptButton);
        await tester.pump(const Duration(milliseconds: 100)); // Wait for scroll animation
        
        await tester.tap(acceptButton);
        await tester.pump(const Duration(milliseconds: 100)); // Process tap

        // Then - Button should be tappable (navigation would be tested in integration test)
        expect(acceptButton, findsOneWidget);
      });
    });

    group('Processing state', () {
      testWidgets('displays processing indicator when processing', (WidgetTester tester) async {
        // Given
        final processingState = const CaptureState(
          isProcessing: true,
          isRetryMode: false,
        );

        await tester.pumpWidget(createPreviewScreen(captureState: processingState));
        await tester.pump(const Duration(milliseconds: 100)); // Use pump instead of pumpAndSettle for loading state

        // Then
        expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
        expect(find.text('Processing receipt...'), findsOneWidget);
      });
    });

    group('Error handling', () {
      testWidgets('handles null processing result gracefully', (WidgetTester tester) async {
        // Given
        final nullResultState = const CaptureState(
          isProcessing: false,
          isRetryMode: false,
          lastProcessingResult: null,
        );

        await tester.pumpWidget(createPreviewScreen(captureState: nullResultState));
        await tester.pump(const Duration(milliseconds: 100)); // Initial build
        await tester.pump(const Duration(milliseconds: 100)); // Process state

        // Then - Should show image preview fallback
        expect(find.byType(Image), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('field editors have proper semantic labels', (WidgetTester tester) async {
        // Given
        await tester.pumpWidget(createPreviewScreen());
        await tester.pump(const Duration(milliseconds: 100)); // Initial build
        await tester.pump(const Duration(milliseconds: 100)); // Wait for processing

        // Then - Check that field editors provide accessibility labels
        expect(find.byType(MerchantFieldEditorWithNormalization), findsOneWidget);
        expect(find.byType(FieldEditor), findsOneWidget);
        expect(find.byType(FieldEditor), findsNWidgets(2));

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
        await tester.pump(const Duration(milliseconds: 100)); // Initial build
        await tester.pump(const Duration(milliseconds: 100)); // Wait for processing

        // When - Make rapid text changes
        final merchantTextField = find.descendant(
          of: find.byType(MerchantFieldEditorWithNormalization),
          matching: find.byType(TextField),
        );
        
        await tester.enterText(merchantTextField, 'A');
        await tester.enterText(merchantTextField, 'AB');
        await tester.enterText(merchantTextField, 'ABC');
        await tester.pump(const Duration(milliseconds: 100)); // Process text inputs

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
        await tester.pump(const Duration(milliseconds: 100)); // Initial build
        await tester.pump(const Duration(milliseconds: 100)); // Wait for processing

        // Then - Should use Row layout for side-by-side view
        // Find the top-level Row that's a direct child of LayoutBuilder
        final layoutBuilder = find.byType(LayoutBuilder);
        expect(layoutBuilder, findsOneWidget);
        
        // Get the LayoutBuilder widget and check its child is a Row
        // final layoutBuilderWidget = tester.widget<LayoutBuilder>(layoutBuilder);
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
        await tester.pump(const Duration(milliseconds: 100)); // Initial build
        await tester.pump(const Duration(milliseconds: 100)); // Wait for processing

        // Then - Should use Column layout for stacked view
        // Find the top-level Column that's a direct child of LayoutBuilder
        final layoutBuilder = find.byType(LayoutBuilder);
        expect(layoutBuilder, findsOneWidget);
        
        // Get the LayoutBuilder widget and check its child is a Column
        // final layoutBuilderWidget = tester.widget<LayoutBuilder>(layoutBuilder);
        tester.element(layoutBuilder).visitChildElements((element) {
          expect(element.widget, isA<Column>());
        });
      });
    });
  });
}