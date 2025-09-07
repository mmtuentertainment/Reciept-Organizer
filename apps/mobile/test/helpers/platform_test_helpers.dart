import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Test implementation of PathProviderPlatform that extends the actual platform
/// interface to satisfy the token verification requirement
class TestPathProviderPlatform extends PathProviderPlatform {
  TestPathProviderPlatform() : super();

  // Storage for mock return values
  String? temporaryPath = '/tmp';
  String? applicationDocumentsPath = '/tmp/docs';
  String? applicationSupportPath = '/tmp/support';
  String? applicationCachePath = '/tmp/cache';
  String? externalStoragePath;
  String? downloadsPath = '/tmp/downloads';
  List<String>? externalCachePaths;
  List<String>? externalStoragePaths;

  @override
  Future<String?> getTemporaryPath() async => temporaryPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => applicationDocumentsPath;

  @override
  Future<String?> getApplicationSupportPath() async => applicationSupportPath;

  @override
  Future<String?> getApplicationCachePath() async => applicationCachePath;

  @override
  Future<String?> getExternalStoragePath() async => externalStoragePath;

  @override
  Future<String?> getDownloadsPath() async => downloadsPath;

  @override
  Future<List<String>?> getExternalCachePaths() async => externalCachePaths;

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async => externalStoragePaths;
}

/// Helper function to setup path provider for tests
void setupPathProviderForTests({
  String? temporaryPath = '/tmp',
  String? applicationDocumentsPath = '/tmp/docs',
  String? applicationSupportPath = '/tmp/support',
  String? applicationCachePath = '/tmp/cache',
  String? externalStoragePath,
}) {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  final testPlatform = TestPathProviderPlatform()
    ..temporaryPath = temporaryPath
    ..applicationDocumentsPath = applicationDocumentsPath
    ..applicationSupportPath = applicationSupportPath
    ..applicationCachePath = applicationCachePath
    ..externalStoragePath = externalStoragePath;
  
  PathProviderPlatform.instance = testPlatform;
}