import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import '../helpers/platform_test_helpers.dart';

void main() {
  test('Debug path resolution', () {
    // Setup platform paths
    setupPathProviderForTests(
      temporaryPath: '/tmp',
      applicationDocumentsPath: '/app/docs',
      applicationSupportPath: '/app/support',
    );
    
    // Test path resolution
    final testPath = '/tmp/test_file.jpg';
    final normalizedPath = path.normalize(testPath);
    final absolutePath = path.absolute(normalizedPath);
    
    print('Original path: $testPath');
    print('Normalized path: $normalizedPath');
    print('Absolute path: $absolutePath');
    print('Current directory: ${path.current}');
    
    // Test if path starts with /tmp
    print('Starts with /tmp: ${absolutePath.startsWith('/tmp')}');
    
    // Test custom directory
    final customPath = '/custom/dir/file.jpg';
    final customNormalized = path.normalize(customPath);
    final customAbsolute = path.absolute(customNormalized);
    
    print('\nCustom path: $customPath');
    print('Custom normalized: $customNormalized');
    print('Custom absolute: $customAbsolute');
  });
}