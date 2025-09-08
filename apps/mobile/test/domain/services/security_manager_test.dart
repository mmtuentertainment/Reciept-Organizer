import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:receipt_organizer/domain/services/security_manager.dart';

@GenerateMocks([Directory])
import '../../helpers/platform_test_helpers.dart';

void main() {
  group('SecurityManager Tests', () {
    late SecurityManager securityManager;
    
    setUp(() {
      // Use the test helper to setup path provider
      setupPathProviderForTests(
        temporaryPath: '/tmp',
        applicationDocumentsPath: '/app/docs',
        applicationSupportPath: '/app/support',
        externalStoragePath: null,
      );
      
      securityManager = SecurityManager();
    });
    
    group('Given path validation', () {
      test('When path is within allowed directory Then returns true', () async {
        // Initialize the security manager to populate allowed directories
        await securityManager.initialize();
        
        // Debug: Print allowed directories
        final dirs = securityManager.getAllowedDirectories();
        debugPrint('Allowed directories: $dirs');
        
        // Act
        final result = await securityManager.isValidPath('/tmp/test_file.jpg');
        debugPrint('Validation result for /tmp/test_file.jpg: $result');
        
        // Assert
        expect(result, isTrue);
      });
      
      test('When path contains directory traversal Then returns false', () async {
        // Arrange
        final maliciousPaths = [
          '/tmp/../etc/passwd',
          '/tmp/./../../etc/passwd',
          '/app/docs/../../../etc/passwd',
          '../../../etc/passwd',
          './../etc/passwd',
        ];
        
        // Act & Assert
        for (final path in maliciousPaths) {
          final result = await securityManager.isValidPath(path);
          expect(result, isFalse, reason: 'Path $path should be rejected');
        }
      });
      
      test('When path is absolute outside allowed dirs Then returns false', () async {
        // Arrange
        final outsidePaths = [
          '/etc/passwd',
          '/usr/bin/bash',
          '/home/user/documents/file.txt',
          'C:\\Windows\\System32\\cmd.exe',
        ];
        
        // Act & Assert
        for (final path in outsidePaths) {
          final result = await securityManager.isValidPath(path);
          expect(result, isFalse, reason: 'Path $path should be rejected');
        }
      });
      
      test('When path contains control characters Then returns false', () async {
        // Arrange
        final invalidPaths = [
          '/tmp/file\x00.txt', // Null byte
          '/tmp/file\x1f.txt', // Control character
          '/tmp/file\n.txt', // Newline
        ];
        
        // Act & Assert
        for (final path in invalidPaths) {
          final result = await securityManager.isValidPath(path);
          expect(result, isFalse, reason: 'Path $path should be rejected');
        }
      });
      
      test('When path contains invalid Windows characters Then returns false', () async {
        // Arrange
        final invalidPaths = [
          '/tmp/file<test>.txt',
          '/tmp/file:test.txt',
          '/tmp/file"test".txt',
          '/tmp/file|test.txt',
          '/tmp/file?test.txt',
          '/tmp/file*test.txt',
        ];
        
        // Act & Assert
        for (final path in invalidPaths) {
          final result = await securityManager.isValidPath(path);
          expect(result, isFalse, reason: 'Path $path should be rejected');
        }
      });
      
      test('When adding custom allowed directory Then paths within it are valid', () async {
        // Arrange
        await securityManager.initialize();
        securityManager.addAllowedDirectory('/custom/dir');
        
        // Act
        final result = await securityManager.isValidPath('/custom/dir/file.jpg');
        
        // Assert
        expect(result, isTrue);
      });
    });
    
    group('Given initialization', () {
      test('When getting allowed directories Then returns expected list', () async {
        // Arrange
        await securityManager.initialize();
        
        // Act
        final dirs = securityManager.getAllowedDirectories();
        
        // Assert
        expect(dirs, contains('/tmp'));
        expect(dirs, contains('/app/docs'));
        expect(dirs, contains('/app/support'));
      });
      
      test('When initialized multiple times Then only initializes once', () async {
        // Arrange & Act
        await securityManager.initialize();
        final firstDirCount = securityManager.getAllowedDirectories().length;
        
        await securityManager.initialize();
        final secondDirCount = securityManager.getAllowedDirectories().length;
        
        // Assert
        expect(secondDirCount, equals(firstDirCount));
      });
    });
    
    group('Given edge cases', () {
      test('When path validation throws exception Then returns false', () async {
        // This tests the catch block in isValidPath
        // We can't easily mock File operations, so this serves as documentation
        
        // Arrange - Use a path that might cause issues
        final problematicPath = String.fromCharCodes(List.generate(1000, (i) => 0));
        
        // Act
        final result = await securityManager.isValidPath(problematicPath);
        
        // Assert
        expect(result, isFalse);
      });
    });
  });
}