import 'dart:typed_data';
import 'package:receipt_organizer/domain/services/image_storage_service.dart';

/// Mock implementation of IImageStorageService for testing
/// 
/// This avoids file system dependencies that break tests
class MockImageStorageService implements IImageStorageService {
  final Map<String, Uint8List> _storage = {};
  int _counter = 0;

  @override
  Future<String> saveTemporary(Uint8List imageData, {String? fileName}) async {
    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 10));
    
    // Generate a fake path without actually accessing file system
    final name = fileName ?? 'mock_receipt_${_counter++}.jpg';
    final fakePath = '/mock/temp/$name';
    
    // Store in memory for testing
    _storage[fakePath] = imageData;
    
    return fakePath;
  }

  @override
  Future<void> deleteTemporary(String filePath) async {
    await Future.delayed(const Duration(milliseconds: 5));
    _storage.remove(filePath);
  }

  @override
  Future<bool> exists(String filePath) async {
    await Future.delayed(const Duration(milliseconds: 5));
    return _storage.containsKey(filePath);
  }

  @override
  Future<int> getFileSize(String filePath) async {
    await Future.delayed(const Duration(milliseconds: 5));
    final data = _storage[filePath];
    return data?.length ?? 0;
  }

  @override
  Future<Uint8List?> loadImage(String filePath) async {
    await Future.delayed(const Duration(milliseconds: 5));
    return _storage[filePath];
  }

  /// Test helper to clear all stored data
  void clear() {
    _storage.clear();
    _counter = 0;
  }

  /// Test helper to check if a path was saved
  bool hasPath(String path) {
    return _storage.containsKey(path);
  }
}