import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:receipt_organizer/features/receipts/presentation/providers/image_viewer_provider.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('ImageViewerProvider Tests', () {
    late ProviderContainer container;
    late MockSharedPreferences mockPrefs;
    
    setUp(() {
      mockPrefs = MockSharedPreferences();
      
      // Set up default mock behavior
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
    
    group('Given initial state', () {
      test('When provider is created Then default values are set', () {
        // Act
        final state = container.read(imageViewerProvider);
        
        // Assert
        expect(state.zoomLevel, equals(1.0));
        expect(state.panPosition, equals(Offset.zero));
        expect(state.isImageOnly, isFalse);
        expect(state.showBoundingBoxes, isTrue);
        expect(state.selectedField, isNull);
        expect(state.minZoom, equals(0.5));
        expect(state.maxZoom, equals(5.0));
        expect(state.isAnimating, isFalse);
      });
      
      test('When preferences exist Then they are loaded', () {
        // Arrange
        when(mockPrefs.getDouble('imageViewer.defaultZoom')).thenReturn(2.0);
        when(mockPrefs.getBool('imageViewer.showBoundingBoxes')).thenReturn(false);
        when(mockPrefs.getBool('imageViewer.viewMode')).thenReturn(true);
        
        // Act
        final newContainer = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
          ],
        );
        final state = newContainer.read(imageViewerProvider);
        
        // Assert
        expect(state.zoomLevel, equals(2.0));
        expect(state.showBoundingBoxes, isFalse);
        expect(state.isImageOnly, isTrue);
        
        // Cleanup
        newContainer.dispose();
      });
    });
    
    group('Given zoom operations', () {
      test('When setting zoom within bounds Then zoom is updated', () {
        // Arrange
        final notifier = container.read(imageViewerProvider.notifier);
        
        // Act
        notifier.setZoom(2.5);
        
        // Assert
        expect(container.read(imageViewerProvider).zoomLevel, equals(2.5));
      });
      
      test('When setting zoom below minimum Then zoom is clamped', () {
        // Arrange
        final notifier = container.read(imageViewerProvider.notifier);
        
        // Act
        notifier.setZoom(0.1);
        
        // Assert
        expect(container.read(imageViewerProvider).zoomLevel, equals(0.5));
      });
      
      test('When setting zoom above maximum Then zoom is clamped', () {
        // Arrange
        final notifier = container.read(imageViewerProvider.notifier);
        
        // Act
        notifier.setZoom(10.0);
        
        // Assert
        expect(container.read(imageViewerProvider).zoomLevel, equals(5.0));
      });
    });
    
    group('Given pan operations', () {
      test('When panning without size constraints Then position is updated', () {
        // Arrange
        final notifier = container.read(imageViewerProvider.notifier);
        
        // Act
        notifier.setPan(const Offset(50, 100));
        
        // Assert
        expect(container.read(imageViewerProvider).panPosition, equals(const Offset(50, 100)));
      });
      
      test('When panning with size constraints Then position is clamped', () {
        // Arrange
        final notifier = container.read(imageViewerProvider.notifier);
        notifier.setZoom(2.0); // Zoom in first
        
        // Act
        notifier.setPan(
          const Offset(500, 500),
          imageSize: const Size(1000, 1000),
          viewportSize: const Size(400, 600),
        );
        
        // Assert
        final state = container.read(imageViewerProvider);
        // With 2x zoom, image is 2000x2000, viewport is 400x600
        // Max pan X = (2000 - 400) / 2 = 800
        // Max pan Y = (2000 - 600) / 2 = 700
        expect(state.panPosition.dx, lessThanOrEqualTo(800));
        expect(state.panPosition.dy, lessThanOrEqualTo(700));
      });
    });
    
    group('Given toggle operations', () {
      test('When toggling image only mode Then state is updated and saved', () async {
        // Arrange
        final notifier = container.read(imageViewerProvider.notifier);
        
        // Act
        notifier.toggleImageOnlyMode();
        
        // Assert
        expect(container.read(imageViewerProvider).isImageOnly, isTrue);
        verify(mockPrefs.setBool('imageViewer.viewMode', true)).called(1);
      });
      
      test('When toggling bounding boxes Then state is updated and saved', () async {
        // Arrange
        final notifier = container.read(imageViewerProvider.notifier);
        
        // Act
        notifier.toggleBoundingBoxes();
        
        // Assert
        expect(container.read(imageViewerProvider).showBoundingBoxes, isFalse);
        verify(mockPrefs.setBool('imageViewer.showBoundingBoxes', false)).called(1);
      });
    });
    
    group('Given field selection', () {
      test('When selecting a field Then selectedField is updated', () {
        // Arrange
        final notifier = container.read(imageViewerProvider.notifier);
        
        // Act
        notifier.selectField('merchant');
        
        // Assert
        expect(container.read(imageViewerProvider).selectedField, equals('merchant'));
      });
      
      test('When deselecting a field Then selectedField is null', () {
        // Arrange
        final notifier = container.read(imageViewerProvider.notifier);
        notifier.selectField('merchant');
        
        // Act
        notifier.selectField(null);
        
        // Assert
        expect(container.read(imageViewerProvider).selectedField, isNull);
      });
    });
    
    group('Given double tap handling', () {
      test('When double tapping at zoom 1.0 Then zooms in to 2.5x', () {
        // Arrange
        final notifier = container.read(imageViewerProvider.notifier);
        
        // Act
        notifier.handleDoubleTap(
          const Offset(200, 300),
          imageSize: const Size(1000, 1000),
          viewportSize: const Size(400, 600),
        );
        
        // Wait for animation to start
        final state = container.read(imageViewerProvider);
        
        // Assert
        expect(state.isAnimating, isTrue);
        // Animation will gradually increase zoom to 2.5
      });
      
      test('When double tapping at zoom > 1.5 Then resets to 1.0x', () {
        // Arrange
        final notifier = container.read(imageViewerProvider.notifier);
        notifier.setZoom(2.0);
        
        // Act
        notifier.handleDoubleTap(
          const Offset(200, 300),
          imageSize: const Size(1000, 1000),
          viewportSize: const Size(400, 600),
        );
        
        // Assert
        expect(container.read(imageViewerProvider).isAnimating, isTrue);
        // Animation will gradually decrease zoom to 1.0
      });
    });
    
    group('Given matrix operations', () {
      test('When updating from matrix Then state reflects transformation', () {
        // Arrange
        final notifier = container.read(imageViewerProvider.notifier);
        final matrix = Matrix4.identity()
          ..translateByDouble(100.0, 50.0)
          ..scaleByDouble(2.0);
        
        // Act
        notifier.updateFromMatrix(matrix);
        
        // Assert
        final state = container.read(imageViewerProvider);
        expect(state.zoomLevel, equals(2.0));
        expect(state.panPosition, equals(const Offset(100.0, 50.0)));
      });
      
      test('When getting transformation matrix Then reflects current state', () {
        // Arrange
        final notifier = container.read(imageViewerProvider.notifier);
        notifier.setZoom(2.0);
        notifier.setPan(const Offset(100, 50));
        
        // Act
        final matrix = notifier.getTransformationMatrix();
        
        // Assert
        expect(matrix.getMaxScaleOnAxis(), equals(2.0));
        final translation = matrix.getTranslation();
        expect(translation.x, equals(100.0));
        expect(translation.y, equals(50.0));
      });
    });
    
    group('Given controller connection', () {
      test('When connecting to controller Then controller is updated', () {
        // Arrange
        final controller = TransformationController();
        final notifier = container.read(imageViewerProvider.notifier);
        notifier.setZoom(2.0);
        notifier.setPan(const Offset(100, 50));
        
        // Act
        notifier.connectToController(controller);
        
        // Assert
        expect(controller.value.getMaxScaleOnAxis(), equals(2.0));
        
        // Cleanup
        controller.dispose();
      });
    });
    
    group('Given memory management', () {
      test('When provider is disposed Then resources are cleaned up', () {
        // Arrange
        final testContainer = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
          ],
        );
        final notifier = testContainer.read(imageViewerProvider.notifier);
        
        // Connect to a controller to create a subscription
        final controller = TransformationController();
        notifier.connectToController(controller);
        
        // Act
        testContainer.dispose();
        
        // Assert - No exceptions should be thrown
        expect(() => controller.dispose(), returnsNormally);
      });
    });
    
    group('Given state helpers', () {
      test('When zoom is 1.0 Then isDefaultZoom is true', () {
        // Arrange
        const state = ImageViewerState(zoomLevel: 1.0);
        
        // Assert
        expect(state.isDefaultZoom, isTrue);
      });
      
      test('When zoom is not 1.0 Then isDefaultZoom is false', () {
        // Arrange
        const state = ImageViewerState(zoomLevel: 2.0);
        
        // Assert
        expect(state.isDefaultZoom, isFalse);
      });
      
      test('When pan is at origin Then isCentered is true', () {
        // Arrange
        const state = ImageViewerState(panPosition: Offset.zero);
        
        // Assert
        expect(state.isCentered, isTrue);
      });
    });
  });
}