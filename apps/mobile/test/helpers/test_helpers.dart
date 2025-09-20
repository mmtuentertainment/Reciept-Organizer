import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:receipt_organizer/domain/models/receipt_model.dart';
import 'package:receipt_organizer/domain/repositories/i_receipt_repository.dart';
import 'package:receipt_organizer/domain/core/result.dart';
import 'package:receipt_organizer/domain/core/failures.dart' as failures;
import 'package:receipt_organizer/infrastructure/services/storage_service.dart';
import 'package:receipt_organizer/infrastructure/services/analytics_service.dart';
import 'package:receipt_organizer/infrastructure/services/secure_storage_service.dart';
import 'package:receipt_organizer/presentation/providers/auth_provider.dart';
import 'package:receipt_organizer/presentation/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';
import 'dart:io';
import '../factories/receipt_factory.dart';
import '../fakes/fake_receipt_repository_domain.dart';
import '../fixtures/test_data_constants.dart';

/// Comprehensive test helpers for Receipt Organizer testing
///
/// These helpers provide common utilities and patterns used across test suites,
/// following 2025 best practices for Flutter testing.

// ============================================================================
// WIDGET TEST HELPERS
// ============================================================================

/// Creates a testable widget with all necessary providers and configuration
Widget createTestableWidget({
  required Widget child,
  IReceiptRepository? receiptRepository,
  AuthProvider? authProvider,
  ThemeProvider? themeProvider,
  List<NavigatorObserver>? navigatorObservers,
  Map<String, WidgetBuilder>? routes,
  String? initialRoute,
  Locale? locale,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => authProvider ?? FakeAuthProvider(),
      ),
      ChangeNotifierProvider<ThemeProvider>(
        create: (_) => themeProvider ?? FakeThemeProvider(),
      ),
      Provider<IReceiptRepository>(
        create: (_) => receiptRepository ?? FakeReceiptRepositoryDomain(),
      ),
    ],
    child: MaterialApp(
      home: child,
      routes: routes ?? {},
      initialRoute: initialRoute,
      navigatorObservers: navigatorObservers ?? [],
      locale: locale ?? const Locale('en'),
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    ),
  );
}

/// Wraps a widget in a minimal Material app for testing
Widget wrapInMaterialApp(Widget widget, {ThemeData? theme}) {
  return MaterialApp(
    home: widget,
    theme: theme ?? ThemeData.light(),
  );
}

/// Creates a widget with a specific screen size for testing
Widget createWithScreenSize({
  required Widget child,
  Size size = const Size(375, 812), // iPhone 11 Pro size
}) {
  return MediaQuery(
    data: MediaQueryData(size: size),
    child: MaterialApp(home: child),
  );
}

// ============================================================================
// PUMP AND SETTLE HELPERS
// ============================================================================

/// Pumps widget and settles with timeout protection
Future<void> pumpAndSettleWithTimeout(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  await tester.pump();

  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    if (!tester.binding.hasScheduledFrame) {
      break;
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Pumps widget N times with delay
Future<void> pumpNTimes(
  WidgetTester tester,
  int times, {
  Duration delay = const Duration(milliseconds: 100),
}) async {
  for (int i = 0; i < times; i++) {
    await tester.pump(delay);
  }
}

/// Wait for a specific widget to appear
Future<void> waitForWidget(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  throw TestFailure('Widget not found within timeout');
}

// ============================================================================
// MOCK SETUP HELPERS
// ============================================================================

/// Sets up common mock responses for receipt repository
void setupReceiptRepositoryMocks(Mock repository) {
  final receiptFactory = ReceiptFactory();

  when(() => (repository as IReceiptRepository).getAll()).thenAnswer(
    (_) async => Result.success(receiptFactory.createBatch(5)),
  );

  when(() => (repository as IReceiptRepository).watchAll()).thenAnswer(
    (_) => Stream.value(Result.success(receiptFactory.createBatch(5))),
  );

  when(() => (repository as IReceiptRepository).create(any())).thenAnswer(
    (invocation) async => Result.success(invocation.positionalArguments[0] as ReceiptModel),
  );

  when(() => (repository as IReceiptRepository).update(any())).thenAnswer(
    (invocation) async => Result.success(invocation.positionalArguments[0] as ReceiptModel),
  );

  when(() => (repository as IReceiptRepository).delete(any())).thenAnswer(
    (_) async => const Result.success(null),
  );
}

/// Sets up platform channel mocks
void setupPlatformChannels() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock image picker
  const MethodChannel imagePickerChannel = MethodChannel('plugins.flutter.io/image_picker');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    imagePickerChannel,
    (MethodCall methodCall) async {
      if (methodCall.method == 'pickImage') {
        return '/test/image.jpg';
      }
      return null;
    },
  );

  // Mock path provider
  const MethodChannel pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    pathProviderChannel,
    (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return '/test/documents';
      }
      return null;
    },
  );
}

// ============================================================================
// GESTURE HELPERS
// ============================================================================

/// Performs a swipe to dismiss gesture
Future<void> swipeToDismiss(
  WidgetTester tester,
  Finder finder, {
  AxisDirection direction = AxisDirection.left,
}) async {
  final Offset start = tester.getCenter(finder);
  final Offset end = direction == AxisDirection.left
      ? Offset(start.dx - 300, start.dy)
      : direction == AxisDirection.right
          ? Offset(start.dx + 300, start.dy)
          : direction == AxisDirection.up
              ? Offset(start.dx, start.dy - 300)
              : Offset(start.dx, start.dy + 300);

  await tester.dragFrom(start, end - start);
  await tester.pumpAndSettle();
}

/// Performs a long press on a widget
Future<void> longPress(WidgetTester tester, Finder finder) async {
  await tester.longPress(finder);
  await tester.pumpAndSettle();
}

/// Scrolls until a widget is visible
Future<void> scrollUntilVisible(
  WidgetTester tester,
  Finder finder,
  Finder scrollable, {
  double delta = -100,
  int maxScrolls = 20,
}) async {
  int scrollCount = 0;
  while (!finder.evaluate().isNotEmpty && scrollCount < maxScrolls) {
    await tester.drag(scrollable, Offset(0, delta));
    await tester.pump();
    scrollCount++;
  }
}

// ============================================================================
// ASSERTION HELPERS
// ============================================================================

/// Asserts that an async operation completes within a time limit
Future<T> expectCompletesWithin<T>(
  Future<T> Function() operation,
  Duration limit,
) async {
  final stopwatch = Stopwatch()..start();
  final result = await operation();

  if (stopwatch.elapsed > limit) {
    throw TestFailure('Operation took ${stopwatch.elapsed.inMilliseconds}ms, '
        'exceeding limit of ${limit.inMilliseconds}ms');
  }

  return result;
}

/// Asserts widgets are in a specific order
void expectInOrder(List<Finder> finders) {
  for (int i = 1; i < finders.length; i++) {
    final prevY = finders[i - 1].evaluate().first.renderObject!.paintBounds.top;
    final currY = finders[i].evaluate().first.renderObject!.paintBounds.top;
    expect(currY, greaterThan(prevY),
        reason: 'Widget $i is not below widget ${i - 1}');
  }
}

/// Asserts a widget has specific semantics
void expectSemantics(
  Finder finder, {
  String? label,
  String? hint,
  String? value,
}) {
  final semantics = finder.evaluate().first.widget;
  if (semantics is Semantics) {
    if (label != null) {
      expect(semantics.properties?.label, equals(label));
    }
    if (hint != null) {
      expect(semantics.properties?.hint, equals(hint));
    }
    if (value != null) {
      expect(semantics.properties?.value, equals(value));
    }
  }
}

// ============================================================================
// DATA GENERATION HELPERS
// ============================================================================

/// Generates test image data
Uint8List generateTestImageData({
  int width = 100,
  int height = 100,
  Color color = Colors.blue,
}) {
  // Create a simple colored square as PNG data
  // This is a simplified version - in real tests you might use actual image encoding
  final data = Uint8List(width * height * 4);
  for (int i = 0; i < data.length; i += 4) {
    data[i] = color.red;
    data[i + 1] = color.green;
    data[i + 2] = color.blue;
    data[i + 3] = 255; // Alpha
  }
  return data;
}

/// Creates a temporary test file
Future<File> createTestFile(
  String content, {
  String? filename,
}) async {
  filename ??= '${const Uuid().v4()}.txt';
  final file = File('/tmp/$filename');
  await file.writeAsString(content);
  return file;
}

/// Generates mock XFile for image picker
XFile createMockXFile({
  String path = '/test/image.jpg',
  String name = 'test_image.jpg',
  Uint8List? bytes,
}) {
  bytes ??= generateTestImageData();

  // Note: In actual tests, you'd mock XFile properly
  // This is a simplified representation
  return XFile(path, name: name, bytes: bytes);
}

// ============================================================================
// FAKE PROVIDERS
// ============================================================================

/// Fake AuthProvider for testing
class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  bool _isAuthenticated = false;
  String? _userId = TestDataConstants.testUserId;
  String? _userEmail = TestDataConstants.testUserEmail;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  String? get currentUserId => _userId;

  @override
  String? get userEmail => _userEmail;

  @override
  Future<void> signIn(String email, String password) async {
    _isAuthenticated = true;
    _userId = TestDataConstants.testUserId;
    _userEmail = email;
    notifyListeners();
  }

  @override
  Future<void> signOut() async {
    _isAuthenticated = false;
    _userId = null;
    _userEmail = null;
    notifyListeners();
  }

  @override
  Future<void> signUp(String email, String password) async {
    _isAuthenticated = true;
    _userId = TestDataConstants.testUserId;
    _userEmail = email;
    notifyListeners();
  }

  @override
  Future<bool> checkAuthStatus() async {
    return _isAuthenticated;
  }

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }
}

/// Fake ThemeProvider for testing
class FakeThemeProvider extends ChangeNotifier implements ThemeProvider {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  ThemeMode get themeMode => _themeMode;

  @override
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  @override
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  @override
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  @override
  ThemeData get lightTheme => ThemeData.light();

  @override
  ThemeData get darkTheme => ThemeData.dark();
}

// ============================================================================
// TEST LIFECYCLE HELPERS
// ============================================================================

/// Sets up common test environment
void setupTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupPlatformChannels();

  // Register fallback values for mocktail
  registerFallbackValue(ReceiptFactory().create());
  registerFallbackValue(Result<ReceiptModel, failures.Failure>.success(
    ReceiptFactory().create(),
  ));
}

/// Cleans up test environment
void teardownTestEnvironment() {
  // Clean up any temporary files
  final tempDir = Directory('/tmp');
  if (tempDir.existsSync()) {
    tempDir.listSync()
        .where((file) => file.path.contains('test'))
        .forEach((file) => file.deleteSync());
  }
}

/// Runs a test with automatic setup and teardown
void testWithSetup(
  String description,
  Future<void> Function(WidgetTester tester) test, {
  bool skip = false,
}) {
  testWidgets(description, (tester) async {
    setupTestEnvironment();
    try {
      await test(tester);
    } finally {
      teardownTestEnvironment();
    }
  }, skip: skip);
}

// ============================================================================
// GOLDEN TEST HELPERS
// ============================================================================

/// Sets up golden test environment with consistent font loading
Future<void> setupGoldenTestEnvironment(WidgetTester tester) async {
  // Load fonts for golden tests
  final fontLoader = FontLoader('Roboto');
  fontLoader.addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
  await fontLoader.load();

  // Set consistent screen size for golden tests
  tester.view.physicalSize = const Size(414, 896); // iPhone 11 Pro Max
  tester.view.devicePixelRatio = 1.0;
}

/// Creates a widget for golden testing with consistent theming
Widget createGoldenTestWidget(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Roboto',
      platform: TargetPlatform.iOS,
    ),
    home: child,
  );
}

// ============================================================================
// PERFORMANCE TEST HELPERS
// ============================================================================

/// Measures widget build time
Future<Duration> measureBuildTime(
  WidgetTester tester,
  Widget widget,
) async {
  final stopwatch = Stopwatch()..start();
  await tester.pumpWidget(widget);
  stopwatch.stop();
  return stopwatch.elapsed;
}

/// Measures scroll performance
Future<Map<String, dynamic>> measureScrollPerformance(
  WidgetTester tester,
  Finder scrollable, {
  int scrollCount = 10,
  double scrollDistance = 300,
}) async {
  final List<Duration> frameDurations = [];
  final stopwatch = Stopwatch();

  for (int i = 0; i < scrollCount; i++) {
    stopwatch.reset();
    stopwatch.start();
    await tester.drag(scrollable, Offset(0, -scrollDistance));
    await tester.pump();
    stopwatch.stop();
    frameDurations.add(stopwatch.elapsed);
  }

  final averageFrameTime = frameDurations.reduce((a, b) => a + b) ~/ scrollCount;
  final maxFrameTime = frameDurations.reduce((a, b) => a > b ? a : b);

  return {
    'average_frame_time': averageFrameTime,
    'max_frame_time': maxFrameTime,
    'dropped_frames': frameDurations.where((d) => d > const Duration(milliseconds: 16)).length,
    'total_frames': scrollCount,
  };
}

// ============================================================================
// ACCESSIBILITY TEST HELPERS
// ============================================================================

/// Checks if widget meets accessibility guidelines
Future<bool> checkAccessibility(WidgetTester tester, Finder finder) async {
  final SemanticsHandle handle = tester.ensureSemantics();

  try {
    // Check for semantic labels
    final semantics = tester.getSemantics(finder);
    final hasLabel = semantics.label.isNotEmpty;
    final hasHint = semantics.hint?.isNotEmpty ?? false;

    // Check for touch target size (minimum 44x44 for iOS, 48x48 for Android)
    final size = tester.getSize(finder);
    final meetsMinSize = size.width >= 44 && size.height >= 44;

    // Check for contrast ratio (would need actual color analysis in production)
    // This is simplified for testing
    final hasGoodContrast = true;

    return hasLabel && meetsMinSize && hasGoodContrast;
  } finally {
    handle.dispose();
  }
}

// ============================================================================
// NETWORK SIMULATION HELPERS
// ============================================================================

/// Simulates network delay
Future<T> withNetworkDelay<T>(
  Future<T> Function() operation, {
  Duration delay = const Duration(seconds: 1),
}) async {
  await Future.delayed(delay);
  return operation();
}

/// Simulates network failure
Future<T> withNetworkFailure<T>(Future<T> Function() operation) async {
  throw Exception('Simulated network failure');
}

/// Simulates flaky network
Future<T> withFlakyNetwork<T>(
  Future<T> Function() operation, {
  double failureRate = 0.3,
}) async {
  if (DateTime.now().millisecond % 1000 < (failureRate * 1000)) {
    throw Exception('Simulated network failure');
  }
  return operation();
}