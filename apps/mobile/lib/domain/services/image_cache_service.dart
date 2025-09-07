import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Service for caching and managing receipt images with memory optimization
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  
  factory ImageCacheService() => _instance;
  
  ImageCacheService._internal();
  
  // In-memory cache with LRU eviction
  final Map<String, CachedImage> _memoryCache = {};
  final List<String> _accessOrder = [];
  
  // Cache configuration
  static const int _maxMemoryCacheSize = 10; // Max items in memory
  static const int _maxCacheSizeMb = 50; // Max total cache size in MB
  static const Duration _cacheExpiration = Duration(hours: 24);
  
  // Performance tracking
  int _cacheHits = 0;
  int _cacheMisses = 0;
  
  /// Get cached image or load and cache it
  Future<Uint8List?> getCachedImage(String imagePath, {
    int? targetWidth,
    int? targetHeight,
    int quality = 85,
  }) async {
    final cacheKey = _generateCacheKey(imagePath, targetWidth, targetHeight, quality);
    
    // Check memory cache first
    final cached = _memoryCache[cacheKey];
    if (cached != null && !cached.isExpired) {
      _cacheHits++;
      _updateAccessOrder(cacheKey);
      return cached.data;
    }
    
    // Remove expired entry
    if (cached != null && cached.isExpired) {
      _memoryCache.remove(cacheKey);
      _accessOrder.remove(cacheKey);
    }
    
    _cacheMisses++;
    
    // Load and compress image
    final imageData = await _loadAndCompressImage(
      imagePath,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
      quality: quality,
    );
    
    if (imageData != null) {
      _cacheImage(cacheKey, imageData);
    }
    
    return imageData;
  }
  
  /// Load thumbnail version of image
  Future<Uint8List?> getThumbnail(String imagePath, {
    int size = 200,
    int quality = 70,
  }) async {
    return getCachedImage(
      imagePath,
      targetWidth: size,
      targetHeight: size,
      quality: quality,
    );
  }
  
  /// Preload image into cache
  Future<void> preloadImage(String imagePath) async {
    await getCachedImage(imagePath);
  }
  
  /// Clear specific image from cache
  void evictImage(String imagePath) {
    final keysToRemove = _memoryCache.keys
        .where((key) => key.startsWith(imagePath))
        .toList();
    
    for (final key in keysToRemove) {
      _memoryCache.remove(key);
      _accessOrder.remove(key);
    }
  }
  
  /// Clear all cached images
  void clearCache() {
    _memoryCache.clear();
    _accessOrder.clear();
    _cacheHits = 0;
    _cacheMisses = 0;
  }
  
  /// Get cache statistics
  CacheStatistics getStatistics() {
    final totalSize = _memoryCache.values
        .fold(0, (sum, image) => sum + image.data.length);
    
    return CacheStatistics(
      itemCount: _memoryCache.length,
      totalSizeMb: totalSize / 1024 / 1024,
      hitRate: _cacheHits + _cacheMisses == 0 ? 0 : 
          _cacheHits / (_cacheHits + _cacheMisses),
      hits: _cacheHits,
      misses: _cacheMisses,
    );
  }
  
  /// Generate cache key
  String _generateCacheKey(String path, int? width, int? height, int quality) {
    return '$path-${width ?? 'full'}-${height ?? 'full'}-$quality';
  }
  
  /// Load and compress image
  Future<Uint8List?> _loadAndCompressImage(String imagePath, {
    int? targetWidth,
    int? targetHeight,
    int quality = 85,
  }) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return null;
      }
      
      // Check file size
      final fileSize = await file.length();
      
      // For small files, just read directly
      if (fileSize < 500 * 1024 && targetWidth == null && targetHeight == null) {
        return await file.readAsBytes();
      }
      
      // Compress larger files or when dimensions specified
      final compressedData = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: quality,
        minWidth: targetWidth ?? 1920,
        minHeight: targetHeight ?? 1920,
        keepExif: false, // Remove EXIF to save space
      );
      
      return compressedData;
    } catch (e) {
      debugPrint('Error loading image: $e');
      return null;
    }
  }
  
  /// Cache image with LRU eviction
  void _cacheImage(String key, Uint8List data) {
    // Check cache size limit
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      _evictLeastRecentlyUsed();
    }
    
    // Check total size limit
    final totalSize = _memoryCache.values
        .fold(0, (sum, image) => sum + image.data.length);
    
    if (totalSize + data.length > _maxCacheSizeMb * 1024 * 1024) {
      // Evict until we have space
      while (_memoryCache.isNotEmpty && 
             totalSize + data.length > _maxCacheSizeMb * 1024 * 1024) {
        _evictLeastRecentlyUsed();
      }
    }
    
    _memoryCache[key] = CachedImage(
      data: data,
      cachedAt: DateTime.now(),
    );
    _updateAccessOrder(key);
  }
  
  /// Update access order for LRU
  void _updateAccessOrder(String key) {
    _accessOrder.remove(key);
    _accessOrder.add(key);
  }
  
  /// Evict least recently used item
  void _evictLeastRecentlyUsed() {
    if (_accessOrder.isNotEmpty) {
      final keyToEvict = _accessOrder.removeAt(0);
      _memoryCache.remove(keyToEvict);
    }
  }
}

/// Cached image data
class CachedImage {
  final Uint8List data;
  final DateTime cachedAt;
  
  const CachedImage({
    required this.data,
    required this.cachedAt,
  });
  
  bool get isExpired => 
      DateTime.now().difference(cachedAt) > ImageCacheService._cacheExpiration;
}

/// Cache statistics
class CacheStatistics {
  final int itemCount;
  final double totalSizeMb;
  final double hitRate;
  final int hits;
  final int misses;
  
  const CacheStatistics({
    required this.itemCount,
    required this.totalSizeMb,
    required this.hitRate,
    required this.hits,
    required this.misses,
  });
  
  @override
  String toString() {
    return '''
Cache Statistics:
- Items: $itemCount
- Size: ${totalSizeMb.toStringAsFixed(2)} MB
- Hit Rate: ${(hitRate * 100).toStringAsFixed(1)}%
- Hits/Misses: $hits/$misses
''';
  }
}