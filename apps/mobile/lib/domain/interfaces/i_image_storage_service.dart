import 'dart:typed_data';
import 'package:receipt_organizer/core/models/result.dart';

/// Service interface for image storage operations with cloud-ready abstraction.
/// 
/// This interface provides a complete abstraction over image storage,
/// supporting local file system, cloud storage (Supabase Storage), and hybrid approaches.
/// All methods return Result types for proper error handling.
abstract class IImageStorageService {
  /// Save an image to storage.
  /// 
  /// [imageData] The raw image data as bytes.
  /// [fileName] Optional file name. If not provided, a unique name will be generated.
  /// [compress] Whether to compress the image if it exceeds size limits (default: true).
  /// 
  /// Returns a Result containing the storage path/URL of the saved image,
  /// or an error if the save operation fails.
  /// 
  /// The implementation should:
  /// - Generate a unique path if fileName is not provided
  /// - Compress large images automatically if compress is true
  /// - Handle different image formats (JPEG, PNG)
  /// 
  /// Example:
  /// ```dart
  /// final result = await storage.saveImage(imageBytes, fileName: 'receipt_001.jpg');
  /// result.onSuccess((path) => print('Saved at: $path'))
  ///       .onFailure((error) => print('Failed: ${error.message}'));
  /// ```
  Future<Result<String>> saveImage(
    Uint8List imageData, {
    String? fileName,
    bool compress = true,
  });
  
  /// Retrieve an image from storage.
  /// 
  /// [path] The storage path of the image (as returned by saveImage).
  /// 
  /// Returns a Result containing the image data as bytes,
  /// or an error if the image cannot be retrieved.
  Future<Result<Uint8List>> getImage(String path);
  
  /// Get a URL for accessing an image.
  /// 
  /// [path] The storage path of the image.
  /// [expiry] Optional expiry duration for signed URLs (cloud storage).
  /// 
  /// Returns a Result containing:
  /// - For local storage: A file:// URL or local path
  /// - For cloud storage: A signed URL with optional expiry
  /// 
  /// The URL can be used directly in Image widgets or for sharing.
  Future<Result<String>> getImageUrl(String path, {Duration? expiry});
  
  /// Delete an image from storage.
  /// 
  /// [path] The storage path of the image to delete.
  /// 
  /// Returns a Result indicating success or failure.
  /// Implementations should handle missing files gracefully.
  Future<Result<void>> deleteImage(String path);
  
  /// Check if an image exists in storage.
  /// 
  /// [path] The storage path to check.
  /// 
  /// Returns a Result containing true if the image exists, false otherwise.
  Future<Result<bool>> exists(String path);
  
  /// Get metadata about an image.
  /// 
  /// [path] The storage path of the image.
  /// 
  /// Returns a Result containing metadata including:
  /// - File size
  /// - Dimensions (width, height)
  /// - Format (JPEG, PNG, etc.)
  /// - Creation/modification dates
  /// - EXIF data if available
  Future<Result<ImageMetadata>> getMetadata(String path);
  
  /// Delete multiple images from storage.
  /// 
  /// [paths] List of storage paths to delete.
  /// 
  /// This operation is best-effort - it will attempt to delete all images
  /// and report any failures. Partial success is possible.
  /// 
  /// Returns a Result with a list of paths that failed to delete (empty if all succeeded).
  Future<Result<List<String>>> deleteMultiple(List<String> paths);
  
  /// Generate a thumbnail for an image.
  /// 
  /// [path] The storage path of the original image.
  /// [maxWidth] Maximum width of the thumbnail (default: 200).
  /// [maxHeight] Maximum height of the thumbnail (default: 200).
  /// [quality] JPEG quality for thumbnail (0-100, default: 85).
  /// 
  /// Returns a Result containing the storage path of the generated thumbnail.
  /// The thumbnail maintains aspect ratio within the specified dimensions.
  Future<Result<String>> generateThumbnail(
    String path, {
    int maxWidth = 200,
    int maxHeight = 200,
    int quality = 85,
  });
  
  /// Move an image to a different path.
  /// 
  /// [fromPath] Current storage path.
  /// [toPath] Destination storage path.
  /// 
  /// Returns a Result indicating success or failure.
  /// This is useful for organizing images or changing storage strategies.
  Future<Result<void>> moveImage(String fromPath, String toPath);
  
  /// Copy an image to a different path.
  /// 
  /// [fromPath] Source storage path.
  /// [toPath] Destination storage path.
  /// 
  /// Returns a Result containing the destination path.
  Future<Result<String>> copyImage(String fromPath, String toPath);
  
  /// Get the total storage size used.
  /// 
  /// Returns a Result containing the total size in bytes.
  /// Useful for storage management and quota tracking.
  Future<Result<int>> getTotalStorageSize();
  
  /// Clean up orphaned images not referenced by any receipts.
  /// 
  /// [dryRun] If true, only report what would be deleted without actually deleting.
  /// 
  /// Returns a Result containing the list of cleaned up paths.
  /// This is useful for storage maintenance.
  Future<Result<List<String>>> cleanupOrphanedImages({bool dryRun = false});
}

/// Metadata about a stored image
class ImageMetadata {
  final String path;
  final int sizeInBytes;
  final int? width;
  final int? height;
  final String? format; // 'jpeg', 'png', etc.
  final DateTime? createdAt;
  final DateTime? modifiedAt;
  final Map<String, dynamic>? exifData;
  final String? mimeType;
  final String? checksum; // For integrity verification
  
  const ImageMetadata({
    required this.path,
    required this.sizeInBytes,
    this.width,
    this.height,
    this.format,
    this.createdAt,
    this.modifiedAt,
    this.exifData,
    this.mimeType,
    this.checksum,
  });
  
  /// Get human-readable file size
  String get formattedSize {
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024) return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  
  /// Get aspect ratio if dimensions are available
  double? get aspectRatio {
    if (width != null && height != null && height! > 0) {
      return width! / height!;
    }
    return null;
  }
}