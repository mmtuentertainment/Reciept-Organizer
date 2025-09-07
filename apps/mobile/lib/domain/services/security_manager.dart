import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Security manager for validating file paths and preventing directory traversal attacks
class SecurityManager {
  static final SecurityManager _instance = SecurityManager._internal();
  
  factory SecurityManager() => _instance;
  
  SecurityManager._internal();
  
  // Cache for allowed directories
  final Set<String> _allowedDirectories = {};
  bool _initialized = false;
  
  /// Initialize the security manager with allowed directories
  Future<void> initialize() async {
    if (_initialized) return;
    
    // Get app-specific directories
    final tempDir = await getTemporaryDirectory();
    final appDocsDir = await getApplicationDocumentsDirectory();
    final appSupportDir = await getApplicationSupportDirectory();
    
    // Add allowed directories
    _allowedDirectories.addAll([
      tempDir.path,
      appDocsDir.path,
      appSupportDir.path,
    ]);
    
    // Platform-specific directories
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          _allowedDirectories.add(externalDir.path);
        }
      } catch (_) {
        // External storage might not be available
      }
    }
    
    _initialized = true;
  }
  
  /// Check if a file path is valid and safe to access
  /// 
  /// This method checks for:
  /// - Directory traversal attempts (.., ./, etc.)
  /// - Absolute paths outside allowed directories
  /// - Symbolic link attacks
  /// - Invalid characters in path
  Future<bool> isValidPath(String filePath) async {
    if (!_initialized) {
      await initialize();
    }
    
    try {
      // Normalize the path to remove any .., ., or redundant separators
      final normalizedPath = path.normalize(filePath);
      
      // Check for directory traversal attempts
      if (normalizedPath.contains('..') || 
          normalizedPath.contains('./') ||
          normalizedPath.contains('.\\')) {
        return false;
      }
      
      // Get absolute path
      final absolutePath = path.absolute(normalizedPath);
      
      // Check if path is within allowed directories
      bool isInAllowedDir = false;
      for (final allowedDir in _allowedDirectories) {
        if (absolutePath.startsWith(allowedDir)) {
          isInAllowedDir = true;
          break;
        }
      }
      
      if (!isInAllowedDir) {
        return false;
      }
      
      // Check if file exists and is not a symbolic link
      final file = File(absolutePath);
      if (await file.exists()) {
        final stat = await file.stat();
        // FileSystemEntityType.link indicates a symbolic link
        if (stat.type == FileSystemEntityType.link) {
          return false;
        }
      }
      
      // Additional checks for suspicious patterns
      final suspiciousPatterns = [
        RegExp(r'\.\.[\\/]'), // Parent directory access
        RegExp(r'^[A-Za-z]:[\\/]'), // Drive root access on Windows
        RegExp(r'[\x00-\x1f]'), // Control characters
        RegExp(r'[<>:"|?*]'), // Invalid Windows filename characters
      ];
      
      for (final pattern in suspiciousPatterns) {
        if (pattern.hasMatch(normalizedPath)) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      // Any error in path validation should be treated as invalid
      return false;
    }
  }
  
  /// Add a custom allowed directory
  void addAllowedDirectory(String directory) {
    _allowedDirectories.add(path.normalize(directory));
  }
  
  /// Get list of allowed directories (for debugging)
  List<String> getAllowedDirectories() {
    return List.unmodifiable(_allowedDirectories);
  }
}