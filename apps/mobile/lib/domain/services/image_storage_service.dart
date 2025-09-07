import 'dart:typed_data';

/// Abstract interface for image storage operations
abstract class IImageStorageService {
  /// Save image data to a temporary file and return the file path
  Future<String> saveTemporary(Uint8List imageData, {String? fileName});
  
  /// Delete a temporary image file
  Future<void> deleteTemporary(String filePath);
  
  /// Check if a file exists at the given path
  Future<bool> exists(String filePath);
  
  /// Get the size of a file in bytes
  Future<int> getFileSize(String filePath);
}