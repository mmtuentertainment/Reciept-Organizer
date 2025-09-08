import 'dart:typed_data';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import '../../data/models/edge_detection_result.dart';
import '../../data/models/camera_frame.dart';

class EdgeDetectionService {
  static const double _confidenceThreshold = 0.6;
  static const double _minRectangleArea = 0.1; // 10% of image area
  static const double _maxRectangleArea = 0.9; // 90% of image area
  
  // Performance optimization constants
  static const int _maxImageWidth = 640;
  static const int _maxImageHeight = 480;
  static const int _minImageWidth = 320;
  static const int _minImageHeight = 240;
  
  // Memory management
  img.Image? _lastProcessedImage;
  EdgeDetectionResult? _cachedResult;
  int _lastImageHash = 0;

  /// Detect edges in a camera frame with receipt-optimized parameters
  Future<EdgeDetectionResult> detectEdges(CameraFrame frame) async {
    try {
      final stopwatch = Stopwatch()..start();
      
      // Quick hash check for caching
      final imageHash = _calculateImageHash(frame.imageData);
      if (imageHash == _lastImageHash && _cachedResult != null) {
        return _cachedResult!;
      }
      
      // Decode and process image using image package
      final decodedImage = img.decodeImage(frame.imageData);
      if (decodedImage == null) {
        return const EdgeDetectionResult(success: false, confidence: 0.0);
      }

      // Optimize image size for performance
      final optimizedImage = _optimizeImageSize(decodedImage);
      
      // Basic edge detection using image package
      final result = await _performOptimizedEdgeDetection(optimizedImage);
      
      stopwatch.stop();
      
      final finalResult = EdgeDetectionResult(
        success: result.success,
        corners: result.corners,
        confidence: result.confidence,
        processingTimeMs: stopwatch.elapsedMilliseconds,
      );
      
      // Cache result for potential reuse
      _lastImageHash = imageHash;
      _cachedResult = finalResult;
      
      return finalResult;
      
    } catch (e) {
      return const EdgeDetectionResult(success: false, confidence: 0.0);
    }
  }

  /// Calculate a simple hash for image data caching
  int _calculateImageHash(Uint8List imageData) {
    if (imageData.length < 100) return imageData.length;
    
    // Sample every 10th byte for a quick hash
    int hash = 0;
    for (int i = 0; i < imageData.length; i += 10) {
      hash = hash * 31 + imageData[i];
    }
    return hash;
  }

  /// Optimize image size for performance while maintaining quality
  img.Image _optimizeImageSize(img.Image image) {
    final width = image.width;
    final height = image.height;
    
    // If image is already optimal size, return as-is
    if (width <= _maxImageWidth && height <= _maxImageHeight &&
        width >= _minImageWidth && height >= _minImageHeight) {
      return image;
    }
    
    // Calculate optimal dimensions maintaining aspect ratio
    double targetWidth = _maxImageWidth.toDouble();
    double targetHeight = _maxImageHeight.toDouble();
    
    final aspectRatio = width / height;
    
    if (aspectRatio > 1) {
      // Landscape
      targetHeight = targetWidth / aspectRatio;
      if (targetHeight < _minImageHeight) {
        targetHeight = _minImageHeight.toDouble();
        targetWidth = targetHeight * aspectRatio;
      }
    } else {
      // Portrait
      targetWidth = targetHeight * aspectRatio;
      if (targetWidth < _minImageWidth) {
        targetWidth = _minImageWidth.toDouble();
        targetHeight = targetWidth / aspectRatio;
      }
    }
    
    return img.copyResize(
      image,
      width: targetWidth.round(),
      height: targetHeight.round(),
      interpolation: img.Interpolation.linear, // Fast interpolation
    );
  }

  /// Perform optimized edge detection using image processing algorithms
  Future<EdgeDetectionResult> _performOptimizedEdgeDetection(img.Image image) async {
    try {
      // Fast grayscale conversion
      final grayscale = _fastGrayscale(image);
      
      // Skip expensive blur for performance - use simple noise reduction
      final denoised = _fastDenoise(grayscale);
      
      // Fast edge detection using optimized gradient
      final edges = _fastEdgeDetection(denoised);
      
      // Optimized rectangular region finding
      final result = _findRectangularRegionsOptimized(edges);
      
      return result;
    } catch (e) {
      return const EdgeDetectionResult(success: false, confidence: 0.0);
    }
  }

  /// Fast grayscale conversion without library overhead
  img.Image _fastGrayscale(img.Image image) {
    final width = image.width;
    final height = image.height;
    final grayscale = img.Image(width: width, height: height);
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = image.getPixel(x, y);
        final luminance = img.getLuminance(pixel);
        final gray = img.ColorRgb8(luminance.round(), luminance.round(), luminance.round());
        grayscale.setPixel(x, y, gray);
      }
    }
    
    return grayscale;
  }

  /// Fast denoising without expensive blur
  img.Image _fastDenoise(img.Image image) {
    final width = image.width;
    final height = image.height;
    final denoised = img.Image(width: width, height: height);
    
    // Simple 3x3 average filter for noise reduction
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        int sum = 0;
        int count = 0;
        
        for (int dy = -1; dy <= 1; dy++) {
          for (int dx = -1; dx <= 1; dx++) {
            final pixel = image.getPixel(x + dx, y + dy);
            sum += img.getLuminance(pixel).round();
            count++;
          }
        }
        
        final avg = sum ~/ count;
        denoised.setPixel(x, y, img.ColorRgb8(avg, avg, avg));
      }
    }
    
    // Copy borders directly
    for (int x = 0; x < width; x++) {
      denoised.setPixel(x, 0, image.getPixel(x, 0));
      denoised.setPixel(x, height - 1, image.getPixel(x, height - 1));
    }
    for (int y = 0; y < height; y++) {
      denoised.setPixel(0, y, image.getPixel(0, y));
      denoised.setPixel(width - 1, y, image.getPixel(width - 1, y));
    }
    
    return denoised;
  }

  /// Fast edge detection optimized for performance
  img.Image _fastEdgeDetection(img.Image image) {
    final width = image.width;
    final height = image.height;
    final edges = img.Image(width: width, height: height);
    
    // Simplified Sobel operator for speed
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        // Horizontal gradient (simplified)
        final gx = img.getLuminance(image.getPixel(x + 1, y)) - 
                   img.getLuminance(image.getPixel(x - 1, y));
        
        // Vertical gradient (simplified)
        final gy = img.getLuminance(image.getPixel(x, y + 1)) - 
                   img.getLuminance(image.getPixel(x, y - 1));
        
        // Fast magnitude calculation
        final magnitude = (gx.abs() + gy.abs()).clamp(0, 255).round();
        
        edges.setPixel(x, y, img.ColorRgb8(magnitude, magnitude, magnitude));
      }
    }
    
    return edges;
  }

  /// Detect edges using gradient-based approach
  Future<img.Image> _detectEdgesWithGradient(img.Image image) async {
    final width = image.width;
    final height = image.height;
    final edges = img.Image(width: width, height: height);
    
    // Sobel kernels
    final sobelX = [
      [-1, 0, 1],
      [-2, 0, 2],
      [-1, 0, 1],
    ];
    final sobelY = [
      [-1, -2, -1],
      [0, 0, 0],
      [1, 2, 1],
    ];
    
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        double gx = 0;
        double gy = 0;
        
        // Apply Sobel kernels
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            final pixel = image.getPixel(x + kx, y + ky);
            final intensity = img.getLuminance(pixel) / 255.0;
            
            gx += intensity * sobelX[ky + 1][kx + 1];
            gy += intensity * sobelY[ky + 1][kx + 1];
          }
        }
        
        // Calculate gradient magnitude
        final magnitude = math.sqrt(gx * gx + gy * gy);
        final edgeStrength = (magnitude * 255).clamp(0, 255).round();
        
        edges.setPixel(x, y, img.ColorRgb8(edgeStrength, edgeStrength, edgeStrength));
      }
    }
    
    return edges;
  }

  /// Optimized rectangular region finding for performance
  EdgeDetectionResult _findRectangularRegionsOptimized(img.Image edges) {
    final width = edges.width;
    final height = edges.height;
    
    // Use sampling for performance - check fewer potential edges
    final topEdges = _findHorizontalEdgesOptimized(edges, isTop: true);
    final bottomEdges = _findHorizontalEdgesOptimized(edges, isTop: false);
    final leftEdges = _findVerticalEdgesOptimized(edges, isLeft: true);
    final rightEdges = _findVerticalEdgesOptimized(edges, isLeft: false);
    
    // Limit rectangle candidate evaluation for performance
    double bestConfidence = 0.0;
    List<Point> bestCorners = [];
    int evaluatedCandidates = 0;
    const maxCandidates = 20; // Limit for performance
    
    // Sort edges by strength and take top candidates only
    topEdges.sort((a, b) => b.compareTo(a));
    bottomEdges.sort((a, b) => a.compareTo(b));
    leftEdges.sort((a, b) => b.compareTo(a));
    rightEdges.sort((a, b) => b.compareTo(a));
    
    final topCandidates = topEdges.take(3).toList();
    final bottomCandidates = bottomEdges.take(3).toList();
    final leftCandidates = leftEdges.take(3).toList();
    final rightCandidates = rightEdges.take(3).toList();
    
    for (final top in topCandidates) {
      for (final bottom in bottomCandidates) {
        for (final left in leftCandidates) {
          for (final right in rightCandidates) {
            if (evaluatedCandidates >= maxCandidates) break;
            evaluatedCandidates++;
            
            if (_isValidRectangle(top, bottom, left, right, width, height)) {
              final corners = [
                Point(left / width, top / height),
                Point(right / width, top / height),
                Point(right / width, bottom / height),
                Point(left / width, bottom / height),
              ];
              
              final confidence = _calculateRectangleConfidence(
                top, bottom, left, right, width, height
              );
              
              if (confidence > bestConfidence) {
                bestConfidence = confidence;
                bestCorners = corners;
              }
            }
          }
        }
      }
    }
    
    return EdgeDetectionResult(
      success: bestConfidence >= _confidenceThreshold,
      corners: bestCorners,
      confidence: bestConfidence,
    );
  }

  /// Optimized horizontal edge detection with sampling
  List<double> _findHorizontalEdgesOptimized(img.Image edges, {required bool isTop}) {
    final width = edges.width;
    final height = edges.height;
    final edgePositions = <double>[];
    
    final scanStart = isTop ? 0 : height * 2 ~/ 3;
    final scanEnd = isTop ? height ~/ 3 : height;
    const scanStep = 3; // Sample every 3rd line for performance
    
    for (int y = scanStart; y < scanEnd; y += scanStep) {
      int edgePixels = 0;
      const sampleStep = 5; // Sample every 5th pixel horizontally
      
      for (int x = 0; x < width; x += sampleStep) {
        final pixel = edges.getPixel(x, y);
        if (img.getLuminance(pixel) > 128) {
          edgePixels++;
        }
      }
      
      // Adjust threshold based on sampling
      final threshold = (width / sampleStep) * 0.25;
      if (edgePixels > threshold) {
        edgePositions.add(y.toDouble());
      }
    }
    
    return edgePositions;
  }

  /// Optimized vertical edge detection with sampling
  List<double> _findVerticalEdgesOptimized(img.Image edges, {required bool isLeft}) {
    final width = edges.width;
    final height = edges.height;
    final edgePositions = <double>[];
    
    final scanStart = isLeft ? 0 : width * 2 ~/ 3;
    final scanEnd = isLeft ? width ~/ 3 : width;
    const scanStep = 3; // Sample every 3rd column for performance
    
    for (int x = scanStart; x < scanEnd; x += scanStep) {
      int edgePixels = 0;
      const sampleStep = 5; // Sample every 5th pixel vertically
      
      for (int y = 0; y < height; y += sampleStep) {
        final pixel = edges.getPixel(x, y);
        if (img.getLuminance(pixel) > 128) {
          edgePixels++;
        }
      }
      
      // Adjust threshold based on sampling
      final threshold = (height / sampleStep) * 0.25;
      if (edgePixels > threshold) {
        edgePositions.add(x.toDouble());
      }
    }
    
    return edgePositions;
  }

  /// Find horizontal edges (top or bottom)
  List<double> _findHorizontalEdges(img.Image edges, {required bool isTop}) {
    final width = edges.width;
    final height = edges.height;
    final edgePositions = <double>[];
    
    final scanLines = isTop 
        ? [for (int i = 0; i < height ~/ 3; i++) i] 
        : [for (int i = height * 2 ~/ 3; i < height; i++) i];
    
    for (final y in scanLines) {
      int edgePixels = 0;
      for (int x = 0; x < width; x++) {
        final pixel = edges.getPixel(x, y);
        if (img.getLuminance(pixel) > 128) {
          edgePixels++;
        }
      }
      
      // If this line has significant edge content, consider it
      if (edgePixels > width * 0.3) {
        edgePositions.add(y.toDouble());
      }
    }
    
    return edgePositions;
  }

  /// Find vertical edges (left or right)
  List<double> _findVerticalEdges(img.Image edges, {required bool isLeft}) {
    final width = edges.width;
    final height = edges.height;
    final edgePositions = <double>[];
    
    final scanLines = isLeft
        ? [for (int i = 0; i < width ~/ 3; i++) i]
        : [for (int i = width * 2 ~/ 3; i < width; i++) i];
    
    for (final x in scanLines) {
      int edgePixels = 0;
      for (int y = 0; y < height; y++) {
        final pixel = edges.getPixel(x, y);
        if (img.getLuminance(pixel) > 128) {
          edgePixels++;
        }
      }
      
      // If this line has significant edge content, consider it
      if (edgePixels > height * 0.3) {
        edgePositions.add(x.toDouble());
      }
    }
    
    return edgePositions;
  }

  /// Check if the rectangle coordinates form a valid receipt rectangle
  bool _isValidRectangle(double top, double bottom, double left, double right, 
                        int width, int height) {
    if (top >= bottom || left >= right) return false;
    
    final rectWidth = right - left;
    final rectHeight = bottom - top;
    final area = rectWidth * rectHeight;
    final imageArea = width * height;
    
    // Area constraints
    if (area < _minRectangleArea * imageArea || area > _maxRectangleArea * imageArea) {
      return false;
    }
    
    // Aspect ratio constraints (receipts are typically vertical)
    final aspectRatio = rectHeight / rectWidth;
    return aspectRatio >= 1.2 && aspectRatio <= 4.0;
  }

  /// Calculate confidence score for a rectangle
  double _calculateRectangleConfidence(double top, double bottom, double left, double right,
                                     int width, int height) {
    final rectWidth = right - left;
    final rectHeight = bottom - top;
    final area = rectWidth * rectHeight;
    final imageArea = width * height;
    
    // Area score (prefer medium-sized rectangles)
    final areaRatio = area / imageArea;
    final areaScore = _calculateAreaScore(areaRatio);
    
    // Aspect ratio score (receipts are vertical)
    final aspectRatio = rectHeight / rectWidth;
    final aspectScore = _calculateAspectScore(aspectRatio);
    
    // Position score (prefer centered rectangles)
    final centerX = (left + right) / 2;
    final centerY = (top + bottom) / 2;
    final imageCenterX = width / 2;
    final imageCenterY = height / 2;
    
    final centerDistanceX = (centerX - imageCenterX).abs() / (width / 2);
    final centerDistanceY = (centerY - imageCenterY).abs() / (height / 2);
    final centerDistance = math.sqrt(centerDistanceX * centerDistanceX + centerDistanceY * centerDistanceY);
    final positionScore = (1.0 - centerDistance).clamp(0.0, 1.0);
    
    // Combined score
    return (areaScore * 0.4 + aspectScore * 0.4 + positionScore * 0.2).clamp(0.0, 1.0);
  }

  /// Calculate area score
  double _calculateAreaScore(double areaRatio) {
    // Prefer rectangles that are 20-70% of the image
    const double idealMin = 0.2;
    const double idealMax = 0.7;
    
    if (areaRatio >= idealMin && areaRatio <= idealMax) {
      return 1.0;
    } else if (areaRatio < idealMin) {
      return (areaRatio / idealMin).clamp(0.0, 1.0);
    } else {
      return (idealMax / areaRatio).clamp(0.0, 1.0);
    }
  }

  /// Calculate aspect ratio score (receipts prefer vertical orientation)
  double _calculateAspectScore(double aspectRatio) {
    // Ideal receipt aspect ratio is between 1.2 and 3.0 (height/width)
    const double idealMin = 1.2;
    const double idealMax = 3.0;
    
    if (aspectRatio >= idealMin && aspectRatio <= idealMax) {
      return 1.0;
    } else if (aspectRatio < idealMin) {
      return (aspectRatio / idealMin).clamp(0.0, 1.0);
    } else {
      return (idealMax / aspectRatio).clamp(0.0, 1.0);
    }
  }

  /// Dispose of service resources and clear memory
  void dispose() {
    // Clear cached data to free memory
    _cachedResult = null;
    _lastImageHash = 0;
  }
}