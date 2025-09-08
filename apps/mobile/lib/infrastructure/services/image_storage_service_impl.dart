import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:receipt_organizer/domain/services/image_storage_service.dart';

/// Implementation of image storage service using file system
class ImageStorageServiceImpl implements IImageStorageService {
  static const _uuid = Uuid();
  
  @override
  Future<String> saveTemporary(Uint8List imageData, {String? fileName}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final name = fileName ?? 'receipt_${_uuid.v4()}.jpg';
      final tempFile = File('${tempDir.path}/$name');
      
      await tempFile.writeAsBytes(imageData);
      return tempFile.path;
    } catch (e) {
      throw ImageStorageException('Failed to save image: $e');
    }
  }
  
  @override
  Future<void> deleteTemporary(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Log error but don't throw - deletion failures are non-critical
      debugPrint('Failed to delete temporary file: $e');
    }
  }
  
  @override
  Future<bool> exists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}

/// Exception thrown when image storage operations fail
class ImageStorageException implements Exception {
  final String message;
  
  ImageStorageException(this.message);
  
  @override
  String toString() => 'ImageStorageException: $message';
}