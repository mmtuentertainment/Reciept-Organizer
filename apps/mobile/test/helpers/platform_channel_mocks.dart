import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void setupPlatformChannelMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // FlutterSecureStorage mock
  const secureStorageChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final Map<String, String> _secureStorage = {};

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(secureStorageChannel, (MethodCall call) async {
    switch (call.method) {
      case 'read':
        final args = call.arguments as Map;
        return _secureStorage[args['key']];
      case 'write':
        final args = call.arguments as Map;
        _secureStorage[args['key']] = args['value'];
        return null;
      case 'delete':
        final args = call.arguments as Map;
        _secureStorage.remove(args['key']);
        return null;
      case 'containsKey':
        final args = call.arguments as Map;
        return _secureStorage.containsKey(args['key']);
      case 'readAll':
        return Map<String, String>.from(_secureStorage);
      case 'deleteAll':
        _secureStorage.clear();
        return null;
      default:
        return null;
    }
  });

  // Camera mock - prevent initialization crashes
  const cameraChannel = MethodChannel('plugins.flutter.io/camera');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(cameraChannel, (MethodCall call) async {
    switch (call.method) {
      case 'availableCameras':
        return [
          {
            'name': 'Test Camera',
            'lensFacing': 'back',
            'sensorOrientation': 0,
          }
        ];
      case 'initialize':
        return null;
      case 'dispose':
        return null;
      default:
        return null;
    }
  });

  // ImagePicker mock
  const imagePickerChannel = MethodChannel('plugins.flutter.io/image_picker');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(imagePickerChannel, (MethodCall call) async {
    return null; // Return null for all image picker calls in tests
  });

  // Connectivity Plus mock
  const connectivityChannel = MethodChannel('dev.fluttercommunity.plus/connectivity');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(connectivityChannel, (MethodCall call) async {
    switch (call.method) {
      case 'getConnectivityState':
        return 'wifi';
      case 'check':
        return 'wifi';
      default:
        return null;
    }
  });

  // Path Provider mock
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(pathProviderChannel, (MethodCall call) async {
    switch (call.method) {
      case 'getTemporaryDirectory':
        return '/tmp';
      case 'getApplicationDocumentsDirectory':
        return '/tmp/documents';
      case 'getApplicationSupportDirectory':
        return '/tmp/support';
      default:
        return null;
    }
  });
}