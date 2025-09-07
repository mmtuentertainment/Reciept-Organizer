import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/shared/utils/performance_monitor.dart';
import 'package:receipt_organizer/domain/services/image_cache_service.dart';
import 'package:receipt_organizer/domain/services/security_manager.dart';

/// A high-performance zoomable image viewer widget with progressive loading
/// and memory optimization for large images up to 10MB.
/// 
/// Features:
/// - Pinch-to-zoom with 0.5x to 5x limits
/// - Pan with boundary constraints
/// - Progressive loading for images > 2MB
/// - Automatic downsampling for performance
/// - FPS monitoring in debug mode
/// - Memory-efficient disposal
class ZoomableImageViewer extends ConsumerStatefulWidget {
  /// The file path of the image to display
  final String imagePath;
  
  /// Optional callback when image is tapped
  final VoidCallback? onTap;
  
  /// Minimum zoom scale (default: 0.5x)
  final double minScale;
  
  /// Maximum zoom scale (default: 5.0x)
  final double maxScale;
  
  /// Whether to show FPS overlay in debug mode
  final bool showFpsOverlay;
  
  /// Loading indicator widget
  final Widget? loadingWidget;
  
  /// Error widget builder
  final Widget Function(String error)? errorBuilder;
  
  /// Image quality for downsampling (1-100)
  final int imageQuality;
  
  /// Progressive loading threshold in bytes (default: 2MB)
  final int progressiveLoadingThreshold;
  
  /// Optional overlay widget to display on top of the image
  final Widget Function(Size imageSize, Matrix4 transform)? overlayBuilder;

  const ZoomableImageViewer({
    Key? key,
    required this.imagePath,
    this.onTap,
    this.minScale = 0.5,
    this.maxScale = 5.0,
    this.showFpsOverlay = true,
    this.loadingWidget,
    this.errorBuilder,
    this.imageQuality = 85,
    this.progressiveLoadingThreshold = 2 * 1024 * 1024, // 2MB
    this.overlayBuilder,
  }) : super(key: key);

  @override
  ConsumerState<ZoomableImageViewer> createState() => _ZoomableImageViewerState();
}

class _ZoomableImageViewerState extends ConsumerState<ZoomableImageViewer>
    with TickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();
  ImageProvider? _imageProvider;
  bool _isLoading = true;
  String? _errorMessage;
  
  // FPS monitoring
  int _frameCount = 0;
  double _currentFps = 0;
  Timer? _fpsTimer;
  
  // Progressive loading
  Uint8List? _thumbnailBytes;
  Uint8List? _fullImageBytes;
  bool _isLoadingFullImage = false;
  
  // Double tap animation
  AnimationController? _doubleTapAnimationController;
  Animation<Matrix4>? _doubleTapAnimation;
  
  // Image size for overlay calculations
  Size? _imageSize;
  
  // Performance monitoring
  final PerformanceMonitor _performanceMonitor = PerformanceMonitor();
  
  // Image caching
  final ImageCacheService _cacheService = ImageCacheService();
  
  // Security
  final SecurityManager _securityManager = SecurityManager();

  @override
  void initState() {
    super.initState();
    _loadImage();
    
    if (widget.showFpsOverlay && !kReleaseMode) {
      _performanceMonitor.startMonitoring();
      _performanceMonitor.addListener(_onPerformanceUpdate);
    }
    
    // Initialize double-tap zoom animation
    _doubleTapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    // Track transformation changes for performance monitoring
    _transformationController.addListener(_onTransformationChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    
    if (widget.showFpsOverlay && !kReleaseMode) {
      _performanceMonitor.removeListener(_onPerformanceUpdate);
      _performanceMonitor.stopMonitoring();
    }
    
    _fpsTimer?.cancel();
    _doubleTapAnimationController?.dispose();
    
    // Clear image cache to prevent memory leaks
    if (_imageProvider != null) {
      _imageProvider!.evict();
    }
    super.dispose();
  }
  
  void _onPerformanceUpdate(PerformanceMetrics metrics) {
    if (mounted) {
      setState(() {
        _currentFps = metrics.currentFps;
      });
    }
  }
  
  void _onTransformationChanged() {
    // Track gesture performance when transformation changes
    if (_transformationController.value != Matrix4.identity()) {
      _performanceMonitor.recordGestureStart('transform_change');
      // Schedule end recording for next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performanceMonitor.recordGestureEnd('transform_change');
      });
    }
  }

  Future<void> _loadImage() async {
    try {
      final file = File(widget.imagePath);
      
      // Validate path security
      if (!await _securityManager.isValidPath(widget.imagePath)) {
        throw Exception('Invalid or insecure file path');
      }
      
      if (!await file.exists()) {
        throw Exception('Image file not found');
      }
      
      final fileSize = await file.length();
      
      // Check file size limit (10MB)
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('Image file too large (max 10MB)');
      }
      
      // Implement progressive loading for large files
      if (fileSize > widget.progressiveLoadingThreshold) {
        await _loadProgressively(file);
      } else {
        await _loadDirectly(file);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _loadProgressively(File file) async {
    // Get original image dimensions
    await _getImageDimensions(file);
    
    // First, load a low-quality thumbnail from cache
    final thumbnailBytes = await _cacheService.getThumbnail(
      file.absolute.path,
      size: 400,
      quality: 20,
    );
    
    if (mounted && thumbnailBytes != null) {
      setState(() {
        _thumbnailBytes = thumbnailBytes;
        _imageProvider = MemoryImage(thumbnailBytes);
        _isLoading = false;
        _isLoadingFullImage = true;
      });
    }
    
    // Then load the full quality image from cache
    final fullBytes = await _cacheService.getCachedImage(
      file.absolute.path,
      quality: widget.imageQuality,
      targetWidth: 1920,
      targetHeight: 1920,
    );
    
    if (mounted && fullBytes != null) {
      setState(() {
        _fullImageBytes = fullBytes;
        _imageProvider = MemoryImage(fullBytes);
        _isLoadingFullImage = false;
      });
    }
  }

  Future<void> _loadDirectly(File file) async {
    // Get original image dimensions
    await _getImageDimensions(file);
    
    // Load from cache
    final bytes = await _cacheService.getCachedImage(
      file.absolute.path,
      quality: widget.imageQuality,
      targetWidth: 1920,
      targetHeight: 1920,
    );
    
    if (mounted && bytes != null) {
      setState(() {
        _fullImageBytes = bytes;
        _imageProvider = MemoryImage(bytes);
        _isLoading = false;
      });
    }
  }
  
  Future<void> _getImageDimensions(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      
      if (mounted) {
        setState(() {
          _imageSize = Size(
            frame.image.width.toDouble(),
            frame.image.height.toDouble(),
          );
        });
      }
      
      frame.image.dispose();
    } catch (e) {
      debugPrint('Error getting image dimensions: $e');
    }
  }

  void _handleDoubleTap(TapDownDetails details) {
    _performanceMonitor.recordGestureStart('double_tap_zoom');
    
    final position = details.localPosition;
    final double scale = _transformationController.value.getMaxScaleOnAxis();
    
    final targetScale = scale > 1.5 ? 1.0 : 2.5;
    final targetMatrix = Matrix4.identity();
    
    if (targetScale != 1.0) {
      // Calculate the position to zoom to
      final renderBox = context.findRenderObject() as RenderBox;
      final size = renderBox.size;
      
      // Calculate relative position (0-1 range)
      final relativePosition = Offset(
        position.dx / size.width,
        position.dy / size.height,
      );
      
      // Calculate translation to keep the tapped point in place
      final translateX = (0.5 - relativePosition.dx) * size.width * (targetScale - 1);
      final translateY = (0.5 - relativePosition.dy) * size.height * (targetScale - 1);
      
      targetMatrix
        ..translate(translateX, translateY)
        ..scale(targetScale);
    }
    
    _doubleTapAnimation = Matrix4Tween(
      begin: _transformationController.value,
      end: targetMatrix,
    ).animate(CurveTween(curve: Curves.easeOut).animate(_doubleTapAnimationController!));
    
    _doubleTapAnimationController!.forward(from: 0.0);
    
    _doubleTapAnimation!.addListener(() {
      _transformationController.value = _doubleTapAnimation!.value;
    });
    
    // Record gesture end after animation starts
    _performanceMonitor.recordGestureEnd('double_tap_zoom');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _imageProvider == null) {
      return Center(
        child: widget.loadingWidget ?? const CircularProgressIndicator(),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: widget.errorBuilder?.call(_errorMessage!) ??
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
      );
    }
    
    return Stack(
      children: [
        // Main image viewer with RepaintBoundary for performance
        RepaintBoundary(
          child: GestureDetector(
            onTap: widget.onTap,
            onDoubleTapDown: _handleDoubleTap,
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: widget.minScale,
              maxScale: widget.maxScale,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              child: Image(
                image: _imageProvider!,
                fit: BoxFit.contain,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) {
                    return child;
                  }
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
              ),
            ),
          ),
        ),
        
        // Overlay widget (e.g., bounding boxes)
        if (widget.overlayBuilder != null && _imageSize != null)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: false, // Allow interaction with overlay
              child: AnimatedBuilder(
                animation: _transformationController,
                builder: (context, child) {
                  return widget.overlayBuilder!(_imageSize!, _transformationController.value);
                },
              ),
            ),
          ),
        
        // Progressive loading indicator
        if (_isLoadingFullImage)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Loading HD',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        
        // FPS overlay for debug mode
        if (widget.showFpsOverlay && !kReleaseMode)
          StreamBuilder<PerformanceMetrics>(
            stream: Stream.periodic(const Duration(seconds: 1)).map((_) => 
                _performanceMonitor.getMetrics()),
            builder: (context, snapshot) {
              final metrics = snapshot.data;
              if (metrics == null) return const SizedBox();
              
              return Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: metrics.isPerformant ? Colors.green : Colors.orange,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            metrics.currentFps >= 55 ? Icons.speed : Icons.warning,
                            size: 16,
                            color: metrics.currentFps >= 55 ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'FPS: ${metrics.currentFps.toStringAsFixed(1)} (avg: ${metrics.averageFps.toStringAsFixed(1)})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Gesture: ${metrics.averageGestureResponseMs.toStringAsFixed(1)}ms',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                      if (_imageSize != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Image: ${(_imageSize!.width).toInt()}x${(_imageSize!.height).toInt()}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Image viewer configuration provider
final imageViewerConfigProvider = Provider<ImageViewerConfig>((ref) {
  return const ImageViewerConfig();
});

/// Configuration for the image viewer
class ImageViewerConfig {
  final double minScale;
  final double maxScale;
  final int imageQuality;
  final int progressiveLoadingThreshold;
  final bool showFpsOverlay;

  const ImageViewerConfig({
    this.minScale = 0.5,
    this.maxScale = 5.0,
    this.imageQuality = 85,
    this.progressiveLoadingThreshold = 2 * 1024 * 1024,
    this.showFpsOverlay = true,
  });
}