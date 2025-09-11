import 'dart:typed_data';
import 'dart:math';
import 'package:receipt_organizer/domain/interfaces/i_image_storage_service.dart';
import 'package:receipt_organizer/core/models/result.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Mock implementation of IImageStorageService for testing.
/// 
/// Stores images in memory as Uint8List and provides full functionality
/// without requiring file system access. Simulates realistic image operations
/// including compression, thumbnail generation, and metadata.
class MockImageStorageService implements IImageStorageService {
  final Map<String, Uint8List> _images = {};
  final Map<String, ImageMetadata> _metadata = {};
  final _uuid = const Uuid();
  final _random = Random();
  
  // Configuration for testing scenarios
  bool shouldFailNextOperation = false;
  Duration? simulatedDelay;
  int? maxStorageBytes;
  bool simulateCompressionErrors = false;
  
  // Statistics tracking for test assertions
  int saveCallCount = 0;
  int getCallCount = 0;
  int deleteCallCount = 0;
  int thumbnailCallCount = 0;
  
  MockImageStorageService({
    this.simulatedDelay,
    this.maxStorageBytes,
  });
  
  @override
  Future<Result<String>> saveImage(
    Uint8List imageData, {
    String? fileName,
    bool compress = true,
  }) async {
    saveCallCount++;
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    // Check storage limit
    if (maxStorageBytes != null) {
      final currentSize = _calculateTotalSize();
      if (currentSize + imageData.length > maxStorageBytes!) {
        return const Result.failure(
          AppError.storage(
            message: 'Storage limit exceeded',
            code: 'STORAGE_FULL',
          ),
        );
      }
    }
    
    // Simulate compression
    Uint8List dataToStore = imageData;
    if (compress && imageData.length > 1024 * 1024) { // > 1MB
      if (simulateCompressionErrors) {
        return const Result.failure(
          AppError.storage(
            message: 'Compression failed',
            code: 'COMPRESSION_ERROR',
          ),
        );
      }
      // Simulate compression by reducing size (in real implementation, would actually compress)
      dataToStore = _simulateCompression(imageData);
    }
    
    // Generate path
    final path = fileName ?? 'images/${_uuid.v4()}.jpg';
    
    // Store image
    _images[path] = dataToStore;
    
    // Generate and store metadata
    _metadata[path] = ImageMetadata(
      path: path,
      sizeInBytes: dataToStore.length,
      width: 1920 + _random.nextInt(2160), // Random between 1920-4080
      height: 1080 + _random.nextInt(1920), // Random between 1080-3000
      format: path.endsWith('.png') ? 'png' : 'jpeg',
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      mimeType: path.endsWith('.png') ? 'image/png' : 'image/jpeg',
      checksum: _calculateChecksum(dataToStore),
    );
    
    return Result.success(path);
  }
  
  @override
  Future<Result<Uint8List>> getImage(String path) async {
    getCallCount++;
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    final imageData = _images[path];
    if (imageData == null) {
      return Result.failure(
        AppError.notFound(
          message: 'Image not found',
          code: 'NOT_FOUND',
          metadata: {'path': path},
        ),
      );
    }
    
    return Result.success(imageData);
  }
  
  @override
  Future<Result<String>> getImageUrl(String path, {Duration? expiry}) async {
    getCallCount++;
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    if (!_images.containsKey(path)) {
      return Result.failure(
        AppError.notFound(
          message: 'Image not found',
          code: 'NOT_FOUND',
          metadata: {'path': path},
        ),
      );
    }
    
    // Generate mock URL
    final baseUrl = 'mock://storage/';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    if (expiry != null) {
      final expiryTime = DateTime.now().add(expiry).millisecondsSinceEpoch;
      return Result.success('$baseUrl$path?t=$timestamp&expires=$expiryTime');
    }
    
    return Result.success('$baseUrl$path?t=$timestamp');
  }
  
  @override
  Future<Result<void>> deleteImage(String path) async {
    deleteCallCount++;
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    // Remove image and metadata
    _images.remove(path);
    _metadata.remove(path);
    
    // Also remove any thumbnails
    final thumbnailPath = _getThumbnailPath(path);
    _images.remove(thumbnailPath);
    _metadata.remove(thumbnailPath);
    
    return const Result.success(null);
  }
  
  @override
  Future<Result<bool>> exists(String path) async {
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    return Result.success(_images.containsKey(path));
  }
  
  @override
  Future<Result<ImageMetadata>> getMetadata(String path) async {
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    final metadata = _metadata[path];
    if (metadata == null) {
      return Result.failure(
        AppError.notFound(
          message: 'Image metadata not found',
          code: 'NOT_FOUND',
          metadata: {'path': path},
        ),
      );
    }
    
    return Result.success(metadata);
  }
  
  @override
  Future<Result<List<String>>> deleteMultiple(List<String> paths) async {
    deleteCallCount += paths.length;
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    final failedPaths = <String>[];
    
    for (final path in paths) {
      if (_images.containsKey(path)) {
        _images.remove(path);
        _metadata.remove(path);
        
        // Also remove thumbnail
        final thumbnailPath = _getThumbnailPath(path);
        _images.remove(thumbnailPath);
        _metadata.remove(thumbnailPath);
      } else {
        failedPaths.add(path);
      }
    }
    
    return Result.success(failedPaths);
  }
  
  @override
  Future<Result<String>> generateThumbnail(
    String path, {
    int maxWidth = 200,
    int maxHeight = 200,
    int quality = 85,
  }) async {
    thumbnailCallCount++;
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    final imageData = _images[path];
    if (imageData == null) {
      return Result.failure(
        AppError.notFound(
          message: 'Image not found',
          code: 'NOT_FOUND',
          metadata: {'path': path},
        ),
      );
    }
    
    // Generate thumbnail path
    final thumbnailPath = _getThumbnailPath(path);
    
    // Simulate thumbnail generation (just use smaller data for mock)
    final thumbnailSize = (imageData.length * 0.1).round(); // 10% of original
    final thumbnailData = Uint8List(thumbnailSize);
    
    // Fill with some data (in real implementation, would actually resize)
    for (int i = 0; i < thumbnailSize; i++) {
      thumbnailData[i] = imageData[i % imageData.length];
    }
    
    // Store thumbnail
    _images[thumbnailPath] = thumbnailData;
    
    // Store metadata
    _metadata[thumbnailPath] = ImageMetadata(
      path: thumbnailPath,
      sizeInBytes: thumbnailData.length,
      width: maxWidth,
      height: maxHeight,
      format: 'jpeg',
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      mimeType: 'image/jpeg',
      checksum: _calculateChecksum(thumbnailData),
    );
    
    return Result.success(thumbnailPath);
  }
  
  @override
  Future<Result<void>> moveImage(String fromPath, String toPath) async {
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    final imageData = _images[fromPath];
    final metadata = _metadata[fromPath];
    
    if (imageData == null || metadata == null) {
      return Result.failure(
        AppError.notFound(
          message: 'Source image not found',
          code: 'NOT_FOUND',
          metadata: {'path': fromPath},
        ),
      );
    }
    
    if (_images.containsKey(toPath)) {
      return Result.failure(
        AppError.duplicate(
          message: 'Destination already exists',
          code: 'ALREADY_EXISTS',
          metadata: {'path': toPath},
        ),
      );
    }
    
    // Move image and metadata
    _images[toPath] = imageData;
    _metadata[toPath] = ImageMetadata(
      path: toPath,
      sizeInBytes: metadata.sizeInBytes,
      width: metadata.width,
      height: metadata.height,
      format: metadata.format,
      createdAt: metadata.createdAt,
      modifiedAt: DateTime.now(),
      exifData: metadata.exifData,
      mimeType: metadata.mimeType,
      checksum: metadata.checksum,
    );
    
    // Remove old entries
    _images.remove(fromPath);
    _metadata.remove(fromPath);
    
    return const Result.success(null);
  }
  
  @override
  Future<Result<String>> copyImage(String fromPath, String toPath) async {
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    final imageData = _images[fromPath];
    final metadata = _metadata[fromPath];
    
    if (imageData == null || metadata == null) {
      return Result.failure(
        AppError.notFound(
          message: 'Source image not found',
          code: 'NOT_FOUND',
          metadata: {'path': fromPath},
        ),
      );
    }
    
    if (_images.containsKey(toPath)) {
      return Result.failure(
        AppError.duplicate(
          message: 'Destination already exists',
          code: 'ALREADY_EXISTS',
          metadata: {'path': toPath},
        ),
      );
    }
    
    // Copy image and metadata
    _images[toPath] = Uint8List.fromList(imageData);
    _metadata[toPath] = ImageMetadata(
      path: toPath,
      sizeInBytes: metadata.sizeInBytes,
      width: metadata.width,
      height: metadata.height,
      format: metadata.format,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      exifData: metadata.exifData,
      mimeType: metadata.mimeType,
      checksum: metadata.checksum,
    );
    
    return Result.success(toPath);
  }
  
  @override
  Future<Result<int>> getTotalStorageSize() async {
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    return Result.success(_calculateTotalSize());
  }
  
  @override
  Future<Result<List<String>>> cleanupOrphanedImages({bool dryRun = false}) async {
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    // For mock, simulate finding some orphaned images
    final orphaned = <String>[];
    
    _images.keys.forEach((path) {
      // Simulate orphan detection (e.g., images older than 30 days with no references)
      final metadata = _metadata[path];
      if (metadata != null) {
        final age = DateTime.now().difference(metadata.createdAt ?? DateTime.now());
        if (age.inDays > 30 && _random.nextBool()) {
          orphaned.add(path);
        }
      }
    });
    
    if (!dryRun) {
      for (final path in orphaned) {
        _images.remove(path);
        _metadata.remove(path);
      }
    }
    
    return Result.success(orphaned);
  }
  
  // Helper methods for testing
  
  /// Clear all data (useful for test setup/teardown)
  void clear() {
    _images.clear();
    _metadata.clear();
    saveCallCount = 0;
    getCallCount = 0;
    deleteCallCount = 0;
    thumbnailCallCount = 0;
  }
  
  /// Get all stored images (for test assertions)
  Map<String, Uint8List> getAllImages() => Map.from(_images);
  
  /// Get storage statistics (for test assertions)
  Map<String, dynamic> getStats() {
    return {
      'totalImages': _images.length,
      'totalBytes': _calculateTotalSize(),
      'saveCount': saveCallCount,
      'getCount': getCallCount,
      'deleteCount': deleteCallCount,
      'thumbnailCount': thumbnailCallCount,
    };
  }
  
  /// Inject specific image (for test setup)
  void injectImage(String path, Uint8List data, {ImageMetadata? metadata}) {
    _images[path] = data;
    _metadata[path] = metadata ?? ImageMetadata(
      path: path,
      sizeInBytes: data.length,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
    );
  }
  
  // Private helper methods
  
  Future<void> _simulateDelay() async {
    if (simulatedDelay != null) {
      await Future.delayed(simulatedDelay!);
    }
  }
  
  int _calculateTotalSize() {
    return _images.values.fold(0, (sum, data) => sum + data.length);
  }
  
  Uint8List _simulateCompression(Uint8List original) {
    // Simulate 50% compression
    final compressedSize = (original.length * 0.5).round();
    return Uint8List(compressedSize);
  }
  
  String _calculateChecksum(Uint8List data) {
    final digest = md5.convert(data);
    return digest.toString();
  }
  
  String _getThumbnailPath(String originalPath) {
    final parts = originalPath.split('/');
    final fileName = parts.last;
    final dir = parts.sublist(0, parts.length - 1).join('/');
    return '$dir/thumbnails/thumb_$fileName';
  }
}