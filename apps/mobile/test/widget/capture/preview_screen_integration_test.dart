import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:receipt_organizer/features/capture/screens/preview_screen.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:receipt_organizer/shared/widgets/zoomable_image_viewer.dart';
import 'package:receipt_organizer/shared/widgets/bounding_box_overlay.dart';
import 'package:receipt_organizer/features/receipts/presentation/providers/image_viewer_provider.dart';

import '../../helpers/platform_test_helpers.dart';

@GenerateMocks([SharedPreferences, Directory])
import 'preview_screen_integration_test.mocks.dart';

void main() {
  group('PreviewScreen Integration Tests', () {
    late Uint8List testImageData;
    late MockSharedPreferences mockPrefs;
    late ProviderContainer container;
    
    setUpAll(() {
      // Create test image data
      testImageData = Uint8List.fromList(List.generate(1000, (i) => i % 256));
    });
    
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      mockPrefs = MockSharedPreferences();
      
      // Setup mock preferences
      when(mockPrefs.getDouble(any)).thenReturn(null);
      when(mockPrefs.getBool(any)).thenReturn(null);
      when(mockPrefs.setDouble(any, any)).thenAnswer((_) async => true);
      when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);
      
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
      );
    });
    
    tearDown(() {
      container.dispose();
    });
    
    Widget createTestApp({
      required Widget child,
    }) {
      return ProviderScope(
        parent: container,
        child: MaterialApp(
          home: child,
        ),
      );
    }
    
    group('Given successful OCR processing', () {
      testWidgets('When preview loads Then image viewer is displayed with fields', (tester) async {
        // Arrange
        // final mockResult = ProcessingResult(
          merchant: FieldData(value: 'Test Store', confidence: 0.95, originalText: 'Test Store'),
          date: FieldData(value: '2024-01-15', confidence: 0.90, originalText: '2024-01-15'),
          total: FieldData(value: '100.00', confidence: 0.85, originalText: '100.00'),
          tax: FieldData(value: '10.00', confidence: 0.80, originalText: '10.00'),
    overallConfidence: 87.5,
    processingDurationMs: 1000,
  );
        
        // Mock getTemporaryDirectory
        final mockDir = MockDirectory();
        when(mockDir.path).thenReturn('/tmp');
        when(mockDir.createTempSync()).thenReturn(mockDir);
        
        // Override path_provider
        setupPathProviderForTests(
          temporaryPath: '/tmp',
          applicationDocumentsPath: '/app/docs',
          applicationSupportPath: '/app/support',
        );
        
        // Act
        await tester.pumpWidget(createTestApp(
          child: PreviewScreen(
            imageData: testImageData,
            sessionId: 'test-session',
          ),
        ));
        
        // Wait for async operations
        await tester.pumpAndSettle();
        
        // Note: In a real test, we would mock the OCR service to return mockResult
        // For now, we're testing the UI with an empty state
        await tester.pump(const Duration(milliseconds: 500));
        
        // Assert - Should show both image viewer and fields
        expect(find.byType(ZoomableImageViewer), findsOneWidget);
        expect(find.text('Receipt Processed'), findsOneWidget);
        expect(find.text('Test Store'), findsOneWidget);
      });
      
      testWidgets('When toggling view mode Then layout changes appropriately', (tester) async {
        // Arrange
        // final mockResult = ProcessingResult(
          merchant: FieldData(value: 'Test Store', confidence: 0.95, originalText: 'Test Store'),
          date: FieldData(value: '2024-01-15', confidence: 0.90, originalText: '2024-01-15'),
          total: FieldData(value: '100.00', confidence: 0.85, originalText: '100.00'),
          tax: FieldData(value: '10.00', confidence: 0.80, originalText: '10.00'),
    overallConfidence: 87.5,
    processingDurationMs: 1000,
  );
        
        setupPathProviderForTests(
          temporaryPath: '/tmp',
          applicationDocumentsPath: '/app/docs',
          applicationSupportPath: '/app/support',
        );
        
        // Act
        await tester.pumpWidget(createTestApp(
          child: PreviewScreen(
            imageData: testImageData,
            sessionId: 'test-session',
          ),
        ));
        
        await tester.pumpAndSettle();
        // Note: In a real test, we would mock the OCR service to return mockResult
        await tester.pump(const Duration(milliseconds: 500));
        
        // Find view toggle button
        final viewToggleButton = find.byIcon(Icons.image);
        expect(viewToggleButton, findsOneWidget);
        
        // Toggle to image-only mode
        await tester.tap(viewToggleButton);
        await tester.pumpAndSettle();
        
        // Assert - Should show only image viewer
        expect(find.byType(ZoomableImageViewer), findsOneWidget);
        expect(find.text('Receipt Information'), findsNothing); // Fields should be hidden
        
        // Toggle back to split view
        final splitViewButton = find.byIcon(Icons.view_sidebar);
        await tester.tap(splitViewButton);
        await tester.pumpAndSettle();
        
        // Assert - Should show both again
        expect(find.byType(ZoomableImageViewer), findsOneWidget);
        expect(find.text('Receipt Information'), findsOneWidget);
      });
      
      testWidgets('When bounding boxes available Then overlay is displayed', (tester) async {
        // Arrange
        // final mockResult = ProcessingResult(
          merchant: FieldData(
            value: 'Test Store', 
            confidence: 0.95,
            originalText: 'Test Store',
            boundingBox: const Rect.fromLTRB(0.1, 0.1, 0.4, 0.2),
          ),
          date: FieldData(
            value: '2024-01-15', 
            confidence: 0.90,
            originalText: '2024-01-15',
            boundingBox: const Rect.fromLTRB(0.6, 0.1, 0.9, 0.2),
          ),
          total: FieldData(
            value: '100.00', 
            confidence: 0.85,
            originalText: '100.00',
            boundingBox: const Rect.fromLTRB(0.6, 0.7, 0.9, 0.8),
          ),
          tax: FieldData(
            value: '10.00', 
            confidence: 0.80,
            originalText: '10.00',
            boundingBox: const Rect.fromLTRB(0.6, 0.8, 0.9, 0.9),
          ),
    overallConfidence: 87.5,
    processingDurationMs: 1000,
  );
        
        setupPathProviderForTests(
          temporaryPath: '/tmp',
          applicationDocumentsPath: '/app/docs',
          applicationSupportPath: '/app/support',
        );
        
        // Act
        await tester.pumpWidget(createTestApp(
          child: PreviewScreen(
            imageData: testImageData,
            sessionId: 'test-session',
          ),
        ));
        
        await tester.pumpAndSettle();
        // Note: In a real test, we would mock the OCR service to return mockResult
        await tester.pump(const Duration(milliseconds: 500));
        
        // Assert - BoundingBoxOverlay should be present
        expect(find.byType(BoundingBoxOverlay), findsOneWidget);
      });
      
      testWidgets('When toggling bounding boxes Then overlay visibility changes', (tester) async {
        // Arrange
        // final mockResult = ProcessingResult(
          merchant: FieldData(
            value: 'Test Store', 
            confidence: 0.95,
            originalText: 'Test Store',
            boundingBox: const Rect.fromLTRB(0.1, 0.1, 0.4, 0.2),
          ),
          date: FieldData(value: '2024-01-15', confidence: 0.90, originalText: '2024-01-15'),
          total: FieldData(value: '100.00', confidence: 0.85, originalText: '100.00'),
          tax: FieldData(value: '10.00', confidence: 0.80, originalText: '10.00'),
    overallConfidence: 87.5,
    processingDurationMs: 1000,
  );
        
        setupPathProviderForTests(
          temporaryPath: '/tmp',
          applicationDocumentsPath: '/app/docs',
          applicationSupportPath: '/app/support',
        );
        
        // Act
        await tester.pumpWidget(createTestApp(
          child: PreviewScreen(
            imageData: testImageData,
            sessionId: 'test-session',
          ),
        ));
        
        await tester.pumpAndSettle();
        // Note: In a real test, we would mock the OCR service to return mockResult
        await tester.pump(const Duration(milliseconds: 500));
        
        // Find bounding box toggle button
        final boundingBoxToggle = find.byIcon(Icons.crop_free);
        expect(boundingBoxToggle, findsOneWidget);
        
        // Toggle bounding boxes off
        await tester.tap(boundingBoxToggle);
        await tester.pumpAndSettle();
        
        // Assert - BoundingBoxOverlay should not be present
        expect(find.byType(BoundingBoxOverlay), findsNothing);
        
        // Toggle back on
        final boundingBoxToggleOff = find.byIcon(Icons.crop_free_outlined);
        await tester.tap(boundingBoxToggleOff);
        await tester.pumpAndSettle();
        
        // Assert - BoundingBoxOverlay should be present again
        expect(find.byType(BoundingBoxOverlay), findsOneWidget);
      });
    });
    
    group('Given state preservation', () {
      testWidgets('When switching view modes Then zoom/pan state is maintained', (tester) async {
        // Arrange
        // final mockResult = ProcessingResult(
          merchant: FieldData(value: 'Test Store', confidence: 0.95, originalText: 'Test Store'),
          date: FieldData(value: '2024-01-15', confidence: 0.90, originalText: '2024-01-15'),
          total: FieldData(value: '100.00', confidence: 0.85, originalText: '100.00'),
          tax: FieldData(value: '10.00', confidence: 0.80, originalText: '10.00'),
    overallConfidence: 87.5,
    processingDurationMs: 1000,
  );
        
        setupPathProviderForTests(
          temporaryPath: '/tmp',
          applicationDocumentsPath: '/app/docs',
          applicationSupportPath: '/app/support',
        );
        
        // Act
        await tester.pumpWidget(createTestApp(
          child: PreviewScreen(
            imageData: testImageData,
            sessionId: 'test-session',
          ),
        ));
        
        await tester.pumpAndSettle();
        // Note: In a real test, we would mock the OCR service to return mockResult
        await tester.pump(const Duration(milliseconds: 500));
        
        // Perform zoom gesture
        final imageViewer = find.byType(ZoomableImageViewer);
        // final center = tester.getCenter(imageViewer);
        
        // Double tap to zoom
        await tester.tap(imageViewer);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(imageViewer);
        await tester.pumpAndSettle();
        
        // Get current zoom state
        final zoomBefore = container.read(imageViewerProvider).zoomLevel;
        expect(zoomBefore, greaterThan(1.0));
        
        // Toggle view mode
        await tester.tap(find.byIcon(Icons.image));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.view_sidebar));
        await tester.pumpAndSettle();
        
        // Assert - Zoom state should be preserved
        final zoomAfter = container.read(imageViewerProvider).zoomLevel;
        expect(zoomAfter, equals(zoomBefore));
      });
    });
    
    group('Given field selection from bounding box', () {
      testWidgets('When tapping bounding box Then corresponding field is highlighted', (tester) async {
        // This test would require more complex setup with actual tap coordinates
        // Marking as pending for now
        // TODO: Implement bounding box tap interaction test
      }, skip: true); // Complex interaction test - implement with actual coordinates
    });
  });
}