# Story 1.3: Mobile (Flutter) Authentication Implementation

## Story Overview
**ID**: STORY-1.3
**Epic**: Phase 2 - Authentication & User Management
**Priority**: P1 - High
**Risk Level**: Medium (Platform-specific challenges)
**Estimated Points**: 8

**As a** mobile user,
**I want** to authenticate in the Flutter app,
**so that** I can securely access my receipts on mobile web.

## Business Value
- Extends authentication to mobile web platform
- Enables secure mobile receipt management
- Provides consistent UX across platforms
- Supports offline-first architecture

## Acceptance Criteria

### 1. Login/Signup Screens
- [ ] Create Material Design 3 auth screens
- [ ] Implement responsive layout for various screen sizes
- [ ] Add form validation with error messages
- [ ] Include loading indicators
- [ ] Support keyboard navigation

### 2. Supabase Flutter Integration
- [ ] Install and configure supabase_flutter package
- [ ] Initialize Supabase client with proper config
- [ ] Implement auth state listener
- [ ] Handle deep links for email confirmation
- [ ] Configure proper URL scheme

### 3. Secure Token Storage
- [ ] Implement flutter_secure_storage
- [ ] Store tokens encrypted on device
- [ ] Handle token rotation
- [ ] Clear tokens on logout
- [ ] Implement biometric protection (future story)

### 4. Session Management
- [ ] Auto-refresh tokens 5 minutes before expiry
- [ ] Handle network connectivity changes
- [ ] Queue auth requests when offline
- [ ] Sync state when coming online
- [ ] Implement 2-hour inactivity timeout

### 5. Offline Authentication
- [ ] Cache last valid credentials securely
- [ ] Allow offline mode with cached data
- [ ] Queue sync operations for online
- [ ] Show offline indicator in UI
- [ ] Handle expired sessions gracefully

## Technical Implementation

### Dependencies Setup
```yaml
# pubspec.yaml
dependencies:
  supabase_flutter: ^2.0.0
  flutter_secure_storage: ^9.0.0
  connectivity_plus: ^5.0.0
  flutter_riverpod: ^2.4.0
```

### Supabase Initialization
```dart
// lib/core/config/supabase_config.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        localStorage: SecureLocalStorage(),
      ),
    );
  }
}

// Secure storage implementation
class SecureLocalStorage extends LocalStorage {
  final _storage = const FlutterSecureStorage();

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() async {
    return await _storage.read(key: 'supabase_access_token');
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _storage.write(
      key: 'supabase_session',
      value: persistSessionString,
    );
  }
}
```

### Auth Provider with Riverpod
```dart
// lib/features/auth/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map((data) {
    final session = data.session;
    if (session != null) {
      // Start inactivity timer (2 hours for mobile)
      ref.read(inactivityTimerProvider.notifier).startTimer(
        Duration(hours: 2),
      );
      return AuthState.authenticated(session);
    }
    return const AuthState.unauthenticated();
  });
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(Supabase.instance.client);
});

class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Store for offline access
      await _cacheCredentials(email, password);

      return AuthResponse.success(response.session!);
    } catch (e) {
      if (e is AuthException) {
        return AuthResponse.error(e.message);
      }
      // Try offline authentication
      return await _offlineAuth(email, password);
    }
  }

  Future<AuthResponse> _offlineAuth(String email, String password) async {
    final cached = await _getCachedCredentials();
    if (cached != null &&
        cached.email == email &&
        cached.passwordHash == _hashPassword(password)) {
      // Return cached session for offline mode
      final session = await _getCachedSession();
      if (session != null && !_isExpired(session)) {
        return AuthResponse.offline(session);
      }
    }
    return AuthResponse.error('Invalid credentials');
  }
}
```

### Login Screen UI
```dart
// lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 48),

                  // Title
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to manage your receipts',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  FilledButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign In'),
                  ),
                  const SizedBox(height: 16),

                  // Sign up link
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/auth/signup');
                    },
                    child: const Text("Don't have an account? Sign up"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await ref.read(authServiceProvider).signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (response.isSuccess) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? 'Login failed'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
```

### Inactivity Monitor
```dart
// lib/features/auth/services/inactivity_monitor.dart
class InactivityMonitor {
  Timer? _timer;
  final Duration timeout;
  final VoidCallback onTimeout;

  InactivityMonitor({
    required this.timeout,
    required this.onTimeout,
  });

  void startTimer() {
    _timer?.cancel();
    _timer = Timer(timeout, () {
      onTimeout();
    });
  }

  void resetTimer() {
    startTimer();
  }

  void stopTimer() {
    _timer?.cancel();
  }
}

// Hook into app lifecycle
class AppLifecycleObserver extends WidgetsBindingObserver {
  final InactivityMonitor monitor;

  AppLifecycleObserver(this.monitor);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        monitor.resetTimer();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        monitor.startTimer();
        break;
      default:
        break;
    }
  }
}
```

## Integration Verification

### IV1: Receipt Features Continue Working
```dart
// Test receipt functionality with auth
testWidgets('Receipt capture works with auth', (tester) async {
  await tester.pumpWidget(authenticatedApp);
  await tester.tap(find.byIcon(Icons.camera));
  await tester.pumpAndSettle();
  expect(find.byType(CameraScreen), findsOneWidget);
});
```

### IV2: Offline-First Preserved
```dart
// Test offline mode
test('Offline mode allows cached data access', () async {
  await networkService.goOffline();
  final receipts = await receiptService.getReceipts();
  expect(receipts, isNotEmpty);
  expect(receipts.first.syncStatus, SyncStatus.pending);
});
```

### IV3: Chrome Web Runtime
```bash
# Test on Chrome
flutter run -d chrome --web-renderer html

# Verify features work
# - Login/logout
# - Receipt management
# - Offline mode
```

## Definition of Done
- [ ] Auth screens implemented with Material Design 3
- [ ] Supabase Flutter fully integrated
- [ ] Secure token storage working
- [ ] Session management with 2-hour timeout
- [ ] Offline authentication functional
- [ ] All existing features still working
- [ ] Unit tests written (>80% coverage)
- [ ] Integration tests passing

## Dependencies
- Stories 1.0, 1.1, 1.2 complete
- Flutter 3.16+ installed
- Supabase Flutter SDK available
- Material Design 3 theme configured

## Risks & Mitigation
| Risk | Impact | Mitigation |
|------|--------|------------|
| Secure storage issues | High | Use platform-specific implementations |
| Deep link conflicts | Medium | Proper URL scheme configuration |
| Offline sync complexity | Medium | Queue-based sync strategy |

## Follow-up Stories
- Story 1.4: React Native Authentication
- Story 1.7: Biometric Authentication
- Story 1.5: Google OAuth Integration

## Notes
- Consider implementing PIN fallback for biometrics
- Monitor token refresh failures via logging
- Plan for migration of existing local data