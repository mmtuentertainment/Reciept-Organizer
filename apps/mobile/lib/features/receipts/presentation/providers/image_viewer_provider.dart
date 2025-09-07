import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State class for image viewer
@immutable
class ImageViewerState {
  final double zoomLevel;
  final Offset panPosition;
  final bool isImageOnly;
  final bool showBoundingBoxes;
  final String? selectedField;
  final double minZoom;
  final double maxZoom;
  final bool isAnimating;

  const ImageViewerState({
    this.zoomLevel = 1.0,
    this.panPosition = Offset.zero,
    this.isImageOnly = false,
    this.showBoundingBoxes = true,
    this.selectedField,
    this.minZoom = 0.5,
    this.maxZoom = 5.0,
    this.isAnimating = false,
  });

  ImageViewerState copyWith({
    double? zoomLevel,
    Offset? panPosition,
    bool? isImageOnly,
    bool? showBoundingBoxes,
    String? selectedField,
    double? minZoom,
    double? maxZoom,
    bool? isAnimating,
  }) {
    return ImageViewerState(
      zoomLevel: zoomLevel ?? this.zoomLevel,
      panPosition: panPosition ?? this.panPosition,
      isImageOnly: isImageOnly ?? this.isImageOnly,
      showBoundingBoxes: showBoundingBoxes ?? this.showBoundingBoxes,
      selectedField: selectedField ?? this.selectedField,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }

  /// Check if zoom is at default (1.0)
  bool get isDefaultZoom => (zoomLevel - 1.0).abs() < 0.01;

  /// Check if pan is at center
  bool get isCentered => panPosition.distance < 1.0;
}

/// StateNotifier for managing image viewer state with AutoDispose
class ImageViewerNotifier extends StateNotifier<ImageViewerState> {
  final SharedPreferences _prefs;
  Timer? _animationTimer;
  StreamSubscription? _transformSubscription;
  TransformationController? _currentController;
  VoidCallback? _controllerListener;
  
  // Preference keys
  static const String _prefKeyDefaultZoom = 'imageViewer.defaultZoom';
  static const String _prefKeyShowBoundingBoxes = 'imageViewer.showBoundingBoxes';
  static const String _prefKeyViewMode = 'imageViewer.viewMode';

  ImageViewerNotifier(this._prefs) : super(const ImageViewerState()) {
    _loadPreferences();
  }

  @override
  void dispose() {
    // Clean up all resources to prevent memory leaks
    _animationTimer?.cancel();
    _transformSubscription?.cancel();
    disconnectFromController();
    super.dispose();
  }

  /// Load saved preferences
  void _loadPreferences() {
    final defaultZoom = _prefs.getDouble(_prefKeyDefaultZoom) ?? 1.0;
    final showBoundingBoxes = _prefs.getBool(_prefKeyShowBoundingBoxes) ?? true;
    final isImageOnly = _prefs.getBool(_prefKeyViewMode) ?? false;

    state = state.copyWith(
      zoomLevel: defaultZoom,
      showBoundingBoxes: showBoundingBoxes,
      isImageOnly: isImageOnly,
    );
  }

  /// Save preferences
  Future<void> _savePreferences() async {
    await _prefs.setDouble(_prefKeyDefaultZoom, state.zoomLevel);
    await _prefs.setBool(_prefKeyShowBoundingBoxes, state.showBoundingBoxes);
    await _prefs.setBool(_prefKeyViewMode, state.isImageOnly);
  }

  /// Set zoom level with constraints
  void setZoom(double zoom) {
    final clampedZoom = zoom.clamp(state.minZoom, state.maxZoom);
    if (clampedZoom != state.zoomLevel) {
      state = state.copyWith(zoomLevel: clampedZoom);
    }
  }

  /// Set pan position with boundary checking
  void setPan(Offset position, {Size? imageSize, Size? viewportSize}) {
    // Calculate boundaries based on zoom level
    Offset clampedPosition = position;
    
    if (imageSize != null && viewportSize != null) {
      final scaledImageSize = imageSize * state.zoomLevel;
      final maxX = (scaledImageSize.width - viewportSize.width) / 2;
      final maxY = (scaledImageSize.height - viewportSize.height) / 2;
      
      // Only allow panning if image is larger than viewport
      if (scaledImageSize.width > viewportSize.width) {
        clampedPosition = Offset(
          clampedPosition.dx.clamp(-maxX, maxX),
          clampedPosition.dy,
        );
      } else {
        clampedPosition = Offset(0, clampedPosition.dy);
      }
      
      if (scaledImageSize.height > viewportSize.height) {
        clampedPosition = Offset(
          clampedPosition.dx,
          clampedPosition.dy.clamp(-maxY, maxY),
        );
      } else {
        clampedPosition = Offset(clampedPosition.dx, 0);
      }
    }
    
    if (clampedPosition != state.panPosition) {
      state = state.copyWith(panPosition: clampedPosition);
    }
  }

  /// Toggle image-only mode
  void toggleImageOnlyMode() {
    state = state.copyWith(isImageOnly: !state.isImageOnly);
    _savePreferences();
  }

  /// Toggle bounding boxes visibility
  void toggleBoundingBoxes() {
    state = state.copyWith(showBoundingBoxes: !state.showBoundingBoxes);
    _savePreferences();
  }

  /// Select a field by name
  void selectField(String? fieldName) {
    state = state.copyWith(selectedField: fieldName);
  }

  /// Reset to default view
  void resetView() {
    _animateToTarget(
      targetZoom: 1.0,
      targetPan: Offset.zero,
      duration: const Duration(milliseconds: 300),
    );
  }

  /// Animate double-tap zoom
  void handleDoubleTap(Offset tapPosition, {
    required Size imageSize,
    required Size viewportSize,
  }) {
    final currentZoom = state.zoomLevel;
    final targetZoom = currentZoom > 1.5 ? 1.0 : 2.5;
    
    Offset targetPan = Offset.zero;
    
    // Calculate pan to center on tap position when zooming in
    if (targetZoom > 1.0) {
      final imageCenter = Offset(imageSize.width / 2, imageSize.height / 2);
      final tapOffset = tapPosition - imageCenter;
      targetPan = -tapOffset * (targetZoom - 1.0);
    }
    
    _animateToTarget(
      targetZoom: targetZoom,
      targetPan: targetPan,
      duration: const Duration(milliseconds: 200),
    );
  }

  /// Animate to target zoom and pan with easing
  void _animateToTarget({
    required double targetZoom,
    required Offset targetPan,
    required Duration duration,
  }) {
    _animationTimer?.cancel();
    
    final startZoom = state.zoomLevel;
    final startPan = state.panPosition;
    final startTime = DateTime.now();
    
    state = state.copyWith(isAnimating: true);
    
    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final elapsed = DateTime.now().difference(startTime);
      final progress = (elapsed.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
      
      // Use ease-out curve
      final eased = Curves.easeOut.transform(progress);
      
      final currentZoom = startZoom + (targetZoom - startZoom) * eased;
      final currentPan = Offset(
        startPan.dx + (targetPan.dx - startPan.dx) * eased,
        startPan.dy + (targetPan.dy - startPan.dy) * eased,
      );
      
      state = state.copyWith(
        zoomLevel: currentZoom,
        panPosition: currentPan,
      );
      
      if (progress >= 1.0) {
        timer.cancel();
        state = state.copyWith(isAnimating: false);
      }
    });
  }

  /// Update from transformation matrix
  void updateFromMatrix(Matrix4 matrix) {
    final scale = matrix.getMaxScaleOnAxis();
    final translation = matrix.getTranslation();
    
    state = state.copyWith(
      zoomLevel: scale,
      panPosition: Offset(translation.x, translation.y),
    );
  }

  /// Get transformation matrix from current state
  Matrix4 getTransformationMatrix() {
    return Matrix4.identity()
      ..translate(state.panPosition.dx, state.panPosition.dy)
      ..scale(state.zoomLevel);
  }

  /// Connect to a TransformationController
  void connectToController(TransformationController controller) {
    // Update controller with current state
    controller.value = getTransformationMatrix();
    
    // Listen to controller changes
    disconnectFromController();
    
    _currentController = controller;
    _controllerListener = () {
      updateFromMatrix(controller.value);
    };
    controller.addListener(_controllerListener!);
  }

  /// Disconnect from controller
  void disconnectFromController() {
    if (_currentController != null && _controllerListener != null) {
      _currentController!.removeListener(_controllerListener!);
    }
    _currentController = null;
    _controllerListener = null;
  }
}

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

/// Main provider for image viewer state
final imageViewerProvider = StateNotifierProvider.autoDispose<ImageViewerNotifier, ImageViewerState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ImageViewerNotifier(prefs);
});

/// Provider for current zoom level
final imageViewerZoomProvider = Provider.autoDispose<double>((ref) {
  return ref.watch(imageViewerProvider.select((state) => state.zoomLevel));
});

/// Provider for whether bounding boxes should be shown
final showBoundingBoxesProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(imageViewerProvider.select((state) => state.showBoundingBoxes));
});

/// Provider for selected field name
final selectedFieldProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(imageViewerProvider.select((state) => state.selectedField));
});