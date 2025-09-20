import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/core/repositories/interfaces/i_receipt_repository.dart';
import 'package:receipt_organizer/core/providers/repository_providers.dart';
import 'package:receipt_organizer/features/auth/providers/auth_provider.dart';
import 'package:receipt_organizer/ui/theme/shadcn_theme_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../fakes/fake_receipt_repository.dart';
import 'widget_test_helper.dart';

export '../fakes/fake_receipt_repository.dart';
export 'package:receipt_organizer/data/models/receipt.dart';

/// Test environment configuration
enum TestEnvironment {
  /// Unit test environment with all mocked dependencies
  unit,

  /// Widget test environment with UI components
  widget,

  /// Integration test environment with some real services
  integration,

  /// End-to-end test environment with real services
  e2e,
}

/// Centralized test application configuration
///
/// Provides a fluent builder API for configuring test environments
/// and dependency injection for different test scenarios.
class TestableApp {
  final TestEnvironment _environment;
  final Widget _child;

  // Repositories
  IReceiptRepository? _receiptRepository;

  // Services
  SharedPreferences? _sharedPreferences;
  User? _currentUser;
  Session? _currentSession;

  // Configuration
  bool _wrapWithApp = true;
  ThemeMode _themeMode = ThemeMode.light;
  Duration? _asyncDelay;
  bool _throwErrors = false;
  String? _errorMessage;

  // Provider overrides
  final List<Override> _customOverrides = [];

  TestableApp._({
    required TestEnvironment environment,
    required Widget child,
  }) : _environment = environment,
       _child = child;

  /// Create a new TestableApp builder
  static TestableApp create({
    required Widget child,
    TestEnvironment environment = TestEnvironment.widget,
  }) {
    return TestableApp._(
      environment: environment,
      child: child,
    );
  }

  /// Configure the receipt repository
  TestableApp withReceiptRepository(IReceiptRepository repository) {
    _receiptRepository = repository;
    return this;
  }

  /// Use a fake receipt repository with optional initial data
  TestableApp withFakeReceipts([List<Receipt>? initialReceipts]) {
    _receiptRepository = FakeReceiptRepository(
      initialReceipts: initialReceipts,
    );
    return this;
  }

  /// Configure async delay for fake repositories
  TestableApp withAsyncDelay(Duration delay) {
    _asyncDelay = delay;
    if (_receiptRepository is FakeReceiptRepository) {
      (_receiptRepository as FakeReceiptRepository).setDelay(delay);
    }
    return this;
  }

  /// Configure error simulation
  TestableApp withErrorSimulation({
    bool enabled = true,
    String message = 'Simulated error',
  }) {
    _throwErrors = enabled;
    _errorMessage = message;

    if (_receiptRepository is FakeReceiptRepository) {
      (_receiptRepository as FakeReceiptRepository)
          .setErrorMode(enabled, message);
    }
    return this;
  }

  /// Configure authentication state
  TestableApp withAuth({
    User? user,
    Session? session,
  }) {
    _currentUser = user ?? WidgetTestHelper.mockUser;
    _currentSession = session ?? WidgetTestHelper.mockSession;
    return this;
  }

  /// Configure without authentication
  TestableApp withoutAuth() {
    _currentUser = null;
    _currentSession = null;
    return this;
  }

  /// Configure SharedPreferences
  TestableApp withSharedPreferences(SharedPreferences prefs) {
    _sharedPreferences = prefs;
    return this;
  }

  /// Configure theme mode
  TestableApp withTheme(ThemeMode mode) {
    _themeMode = mode;
    return this;
  }

  /// Add custom provider overrides
  TestableApp withOverride(Override override) {
    _customOverrides.add(override);
    return this;
  }

  /// Add multiple custom provider overrides
  TestableApp withOverrides(List<Override> overrides) {
    _customOverrides.addAll(overrides);
    return this;
  }

  /// Configure whether to wrap with app shell
  TestableApp withoutAppShell() {
    _wrapWithApp = false;
    return this;
  }

  /// Build the configured test widget
  Widget build() {
    final overrides = _buildOverrides();

    Widget widget = ProviderScope(
      overrides: overrides,
      child: _wrapWithApp ? _buildApp() : _child,
    );

    return widget;
  }

  /// Build app wrapper based on environment
  Widget _buildApp() {
    switch (_environment) {
      case TestEnvironment.unit:
        // Minimal wrapper for unit tests
        return MaterialApp(
          home: Scaffold(body: _child),
          theme: ThemeData.light(),
        );

      case TestEnvironment.widget:
      case TestEnvironment.integration:
        // Full ShadcnUI app for widget/integration tests
        return ShadApp(
          home: _child,
          themeMode: _themeMode,
          theme: ShadThemeData(
            brightness: Brightness.light,
            colorScheme: const ShadSlateColorScheme.light(),
          ),
          darkTheme: ShadThemeData(
            brightness: Brightness.dark,
            colorScheme: const ShadSlateColorScheme.dark(),
          ),
        );

      case TestEnvironment.e2e:
        // Use real app configuration for e2e tests
        return MaterialApp(
          home: _child,
          themeMode: _themeMode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
        );
    }
  }

  /// Build provider overrides based on configuration
  List<Override> _buildOverrides() {
    final overrides = <Override>[];

    // Repository overrides
    if (_receiptRepository != null) {
      overrides.add(
        receiptRepositoryProvider.overrideWith((ref) async {
          return _receiptRepository!;
        }),
      );
    }

    // Auth overrides
    if (_currentSession != null) {
      overrides.add(
        authStateProvider.overrideWith((ref) {
          return Stream.value(
            AuthState(AuthChangeEvent.signedIn, _currentSession!)
          ).asBroadcastStream();
        }),
      );

      overrides.add(
        currentUserProvider.overrideWith((ref) => _currentUser),
      );
    } else if (_environment != TestEnvironment.e2e) {
      // Override with no auth for non-e2e tests
      overrides.add(
        authStateProvider.overrideWith((ref) {
          return Stream.value(
            AuthState(AuthChangeEvent.signedOut, null)
          ).asBroadcastStream();
        }),
      );

      overrides.add(
        currentUserProvider.overrideWith((ref) => null),
      );
    }

    // Theme overrides
    overrides.add(
      themeModeProvider.overrideWith((ref) => _themeMode),
    );

    // SharedPreferences override
    if (_sharedPreferences != null) {
      overrides.add(
        sharedPreferencesProvider.overrideWithValue(_sharedPreferences!),
      );
    }

    // Add custom overrides
    overrides.addAll(_customOverrides);

    return overrides;
  }

  // Static helper methods for common test scenarios

  /// Create a simple test app with fake receipts
  static Widget simple({
    required Widget child,
    List<Receipt>? receipts,
  }) {
    return TestableApp.create(child: child)
        .withFakeReceipts(receipts)
        .build();
  }

  /// Create an authenticated test app
  static Widget authenticated({
    required Widget child,
    List<Receipt>? receipts,
  }) {
    return TestableApp.create(child: child)
        .withFakeReceipts(receipts)
        .withAuth()
        .build();
  }

  /// Create an unauthenticated test app
  static Widget unauthenticated({
    required Widget child,
  }) {
    return TestableApp.create(child: child)
        .withoutAuth()
        .build();
  }

  /// Create a test app with error simulation
  static Widget withError({
    required Widget child,
    String errorMessage = 'Test error',
  }) {
    return TestableApp.create(child: child)
        .withErrorSimulation(message: errorMessage)
        .build();
  }

  /// Create a test app with async delay
  static Widget withDelay({
    required Widget child,
    Duration delay = const Duration(milliseconds: 100),
    List<Receipt>? receipts,
  }) {
    return TestableApp.create(child: child)
        .withFakeReceipts(receipts)
        .withAsyncDelay(delay)
        .build();
  }
}

/// Provider for SharedPreferences in tests
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not provided in test');
});

