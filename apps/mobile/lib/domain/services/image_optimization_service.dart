import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageOptimizationService {
  static const int maxImageWidth = 1200;
  static const int maxImageHeight = 1600;
  static const int thumbnailSize = 200;
  static const int jpegQuality = 85;
  static const int thumbnailQuality = 70;

  // LRU Cache for thumbnails
  final Map<String, Uint8List> _thumbnailCache = {};
  final List<String> _cacheOrder = [];
  static const int maxCacheSize = 50;

  Future<ImageOptimizationResult> optimizeReceiptImage(
    Uint8List originalImage,
    String receiptId,
  ) async {
    try {
      // Decode image
      img.Image? image = img.decodeImage(originalImage);
      if (image == null) {
        return ImageOptimizationResult.error('Failed to decode image');
      }

      // Apply receipt-specific optimizations
      image = _optimizeForOCR(image);

      // Resize if too large
      if (image.width > maxImageWidth || image.height > maxImageHeight) {
        image = img.copyResize(
          image,
          width: image.width > maxImageWidth ? maxImageWidth : null,
          height: image.height > maxImageHeight ? maxImageHeight : null,
          interpolation: img.Interpolation.linear,
        );
      }

      // Generate optimized image
      final optimizedBytes = Uint8List.fromList(
        img.encodeJpg(image, quality: jpegQuality),
      );

      // Generate thumbnail
      final thumbnailBytes = await _generateThumbnail(image, receiptId);

      // Save to storage
      final imagePath = await _saveOptimizedImage(optimizedBytes, receiptId);
      final thumbnailPath = await _saveThumbnail(thumbnailBytes, receiptId);

      return ImageOptimizationResult.success(
        originalSize: originalImage.length,
        optimizedSize: optimizedBytes.length,
        imagePath: imagePath,
        thumbnailPath: thumbnailPath,
        compressionRatio: (1 - (optimizedBytes.length / originalImage.length)) * 100,
      );
    } catch (e) {
      return ImageOptimizationResult.error('Optimization failed: $e');
    }
  }

  img.Image _optimizeForOCR(img.Image image) {
    // Apply filters to improve OCR accuracy
    img.Image optimized = image;

    // Enhance contrast for better text recognition
    optimized = img.contrast(optimized, contrast: 1.1);

    // Adjust brightness if too dark
    final brightness = _calculateBrightness(optimized);
    if (brightness < 120) {
      optimized = img.adjustColor(optimized, brightness: 0.1);
    }

    // Apply sharpening for text clarity
    optimized = img.convolution(
      optimized,
      filter: [
        -0.5, -1.0, -0.5,
        -1.0,  6.0, -1.0,
        -0.5, -1.0, -0.5,
      ],
      div: 1.0,
    );

    return optimized;
  }

  double _calculateBrightness(img.Image image) {
    int totalBrightness = 0;
    int pixelCount = 0;

    // Sample pixels for performance
    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        
        // Calculate perceived brightness
        totalBrightness += ((r * 299) + (g * 587) + (b * 114)) ~/ 1000;
        pixelCount++;
      }
    }

    return pixelCount > 0 ? totalBrightness / pixelCount : 128;
  }

  Future<Uint8List> _generateThumbnail(img.Image image, String receiptId) async {
    // Create thumbnail
    final thumbnail = img.copyResize(
      image,
      width: thumbnailSize,
      height: thumbnailSize,
      maintainAspect: true,
      interpolation: img.Interpolation.linear,
    );

    final thumbnailBytes = Uint8List.fromList(
      img.encodeJpg(thumbnail, quality: thumbnailQuality),
    );

    // Cache thumbnail
    _cacheThumbnail(receiptId, thumbnailBytes);

    return thumbnailBytes;
  }

  void _cacheThumbnail(String receiptId, Uint8List thumbnailBytes) {
    // Remove oldest if cache is full
    if (_thumbnailCache.length >= maxCacheSize) {
      final oldest = _cacheOrder.removeAt(0);
      _thumbnailCache.remove(oldest);
    }

    // Add to cache
    _thumbnailCache[receiptId] = thumbnailBytes;
    _cacheOrder.add(receiptId);
  }

  Uint8List? getCachedThumbnail(String receiptId) {
    final thumbnail = _thumbnailCache[receiptId];
    if (thumbnail != null) {
      // Move to end (most recently used)
      _cacheOrder.remove(receiptId);
      _cacheOrder.add(receiptId);
    }
    return thumbnail;
  }

  Future<String> _saveOptimizedImage(Uint8List imageBytes, String receiptId) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${directory.path}/images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final file = File('${imagesDir.path}/receipt_$receiptId.jpg');
    await file.writeAsBytes(imageBytes);
    return file.path;
  }

  Future<String> _saveThumbnail(Uint8List thumbnailBytes, String receiptId) async {
    final directory = await getApplicationDocumentsDirectory();
    final thumbnailsDir = Directory('${directory.path}/thumbnails');
    if (!await thumbnailsDir.exists()) {
      await thumbnailsDir.create(recursive: true);
    }

    final file = File('${thumbnailsDir.path}/thumb_$receiptId.jpg');
    await file.writeAsBytes(thumbnailBytes);
    return file.path;
  }

  Future<StorageStats> getStorageStats() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      
      final imagesDir = Directory('${directory.path}/images');
      final thumbnailsDir = Directory('${directory.path}/thumbnails');
      final exportsDir = Directory('${directory.path}/exports');

      int imagesSize = 0;
      int imagesCount = 0;
      if (await imagesDir.exists()) {
        await for (final file in imagesDir.list()) {
          if (file is File) {
            imagesSize += await file.length();
            imagesCount++;
          }
        }
      }

      int thumbnailsSize = 0;
      int thumbnailsCount = 0;
      if (await thumbnailsDir.exists()) {
        await for (final file in thumbnailsDir.list()) {
          if (file is File) {
            thumbnailsSize += await file.length();
            thumbnailsCount++;
          }
        }
      }

      int exportsSize = 0;
      int exportsCount = 0;
      if (await exportsDir.exists()) {
        await for (final file in exportsDir.list()) {
          if (file is File) {
            exportsSize += await file.length();
            exportsCount++;
          }
        }
      }

      return StorageStats(
        imagesSize: imagesSize,
        imagesCount: imagesCount,
        thumbnailsSize: thumbnailsSize,
        thumbnailsCount: thumbnailsCount,
        exportsSize: exportsSize,
        exportsCount: exportsCount,
        totalSize: imagesSize + thumbnailsSize + exportsSize,
        cacheSize: _thumbnailCache.length,
      );
    } catch (e) {
      return StorageStats.empty();
    }
  }

  Future<void> cleanup({bool keepRecent = true, int keepLastN = 100}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      
      // Clean up old images
      final imagesDir = Directory('${directory.path}/images');
      if (await imagesDir.exists()) {
        await _cleanupDirectory(imagesDir, keepRecent: keepRecent, keepLastN: keepLastN);
      }

      // Clean up old thumbnails
      final thumbnailsDir = Directory('${directory.path}/thumbnails');
      if (await thumbnailsDir.exists()) {
        await _cleanupDirectory(thumbnailsDir, keepRecent: keepRecent, keepLastN: keepLastN);
      }

      // Clear memory cache
      _thumbnailCache.clear();
      _cacheOrder.clear();
    } catch (e) {
      debugPrint('Cleanup failed: $e');
    }
  }

  Future<void> _cleanupDirectory(Directory dir, {bool keepRecent = true, int keepLastN = 100}) async {
    final files = <File>[];
    
    await for (final entity in dir.list()) {
      if (entity is File) {
        files.add(entity);
      }
    }

    if (files.length <= keepLastN) return;

    // Sort by modification date (newest first)
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    // Keep only the most recent N files
    final filesToDelete = files.skip(keepLastN);
    
    for (final file in filesToDelete) {
      try {
        await file.delete();
      } catch (e) {
        debugPrint('Failed to delete file ${file.path}: $e');
      }
    }
  }

  void clearCache() {
    _thumbnailCache.clear();
    _cacheOrder.clear();
  }
}

class ImageOptimizationResult {
  final bool success;
  final String? error;
  final int originalSize;
  final int optimizedSize;
  final String? imagePath;
  final String? thumbnailPath;
  final double compressionRatio;

  ImageOptimizationResult._({
    required this.success,
    this.error,
    this.originalSize = 0,
    this.optimizedSize = 0,
    this.imagePath,
    this.thumbnailPath,
    this.compressionRatio = 0.0,
  });

  factory ImageOptimizationResult.success({
    required int originalSize,
    required int optimizedSize,
    required String imagePath,
    required String thumbnailPath,
    required double compressionRatio,
  }) {
    return ImageOptimizationResult._(
      success: true,
      originalSize: originalSize,
      optimizedSize: optimizedSize,
      imagePath: imagePath,
      thumbnailPath: thumbnailPath,
      compressionRatio: compressionRatio,
    );
  }

  factory ImageOptimizationResult.error(String error) {
    return ImageOptimizationResult._(
      success: false,
      error: error,
    );
  }
}

class StorageStats {
  final int imagesSize;
  final int imagesCount;
  final int thumbnailsSize;
  final int thumbnailsCount;
  final int exportsSize;
  final int exportsCount;
  final int totalSize;
  final int cacheSize;

  StorageStats({
    required this.imagesSize,
    required this.imagesCount,
    required this.thumbnailsSize,
    required this.thumbnailsCount,
    required this.exportsSize,
    required this.exportsCount,
    required this.totalSize,
    required this.cacheSize,
  });

  factory StorageStats.empty() {
    return StorageStats(
      imagesSize: 0,
      imagesCount: 0,
      thumbnailsSize: 0,
      thumbnailsCount: 0,
      exportsSize: 0,
      exportsCount: 0,
      totalSize: 0,
      cacheSize: 0,
    );
  }

  String get formattedTotalSize => _formatBytes(totalSize);
  String get formattedImagesSize => _formatBytes(imagesSize);
  String get formattedThumbnailsSize => _formatBytes(thumbnailsSize);
  String get formattedExportsSize => _formatBytes(exportsSize);

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}