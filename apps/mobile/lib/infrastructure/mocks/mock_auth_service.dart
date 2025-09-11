import 'dart:async';
import 'package:receipt_organizer/domain/interfaces/i_auth_service.dart';
import 'package:receipt_organizer/core/models/result.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Mock implementation of IAuthService for testing.
/// 
/// Provides complete authentication simulation including user sessions,
/// token management, and permission checking without requiring actual
/// authentication infrastructure.
class MockAuthService implements IAuthService {
  final Map<String, User> _users = {};
  final Map<String, String> _passwords = {}; // email -> password hash
  final Map<String, String> _tokens = {}; // token -> userId
  final Map<String, DateTime> _tokenExpiry = {};
  final _authStateController = StreamController<User?>.broadcast();
  final _uuid = const Uuid();
  
  User? _currentUser;
  String? _currentToken;
  
  // Configuration for testing scenarios
  bool shouldFailNextAuth = false;
  bool requireEmailVerification = false;
  Duration? simulatedDelay;
  Duration tokenLifetime = const Duration(hours: 1);
  
  // Statistics tracking for test assertions
  int signInCallCount = 0;
  int signOutCallCount = 0;
  int signUpCallCount = 0;
  int refreshTokenCallCount = 0;
  int permissionCheckCount = 0;
  
  // Pre-configured test users
  MockAuthService({
    this.simulatedDelay,
    bool createTestUsers = true,
  }) {
    if (createTestUsers) {
      _createDefaultTestUsers();
    }
  }
  
  @override
  Future<Result<User>> signIn({
    required String email,
    required String password,
  }) async {
    signInCallCount++;
    await _simulateDelay();
    
    if (shouldFailNextAuth) {
      shouldFailNextAuth = false;
      return const Result.failure(
        AppError.unauthorized(
          message: 'Authentication failed',
          code: 'AUTH_FAILED',
        ),
      );
    }
    
    // Find user by email
    final user = _users.values.firstWhere(
      (u) => u.email == email,
      orElse: () => throw StateError('User not found'),
    );
    
    // Verify password
    final storedHash = _passwords[email];
    final providedHash = _hashPassword(password);
    
    if (storedHash == null || storedHash != providedHash) {
      return const Result.failure(
        AppError.unauthorized(
          message: 'Invalid email or password',
          code: 'INVALID_CREDENTIALS',
        ),
      );
    }
    
    // Check email verification
    if (requireEmailVerification && !user.emailVerified) {
      return const Result.failure(
        AppError.unauthorized(
          message: 'Email not verified',
          code: 'EMAIL_NOT_VERIFIED',
        ),
      );
    }
    
    // Generate token
    final token = _generateToken();
    _tokens[token] = user.id;
    _tokenExpiry[token] = DateTime.now().add(tokenLifetime);
    
    // Update current user
    _currentUser = user;
    _currentToken = token;
    
    // Update last sign in
    final updatedUser = User(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      isAnonymous: false,
      emailVerified: user.emailVerified,
      createdAt: user.createdAt,
      lastSignInAt: DateTime.now(),
      providers: user.providers,
      customClaims: user.customClaims,
      role: user.role,
      permissions: user.permissions,
    );
    
    _users[user.id] = updatedUser;
    _currentUser = updatedUser;
    _authStateController.add(updatedUser);
    
    return Result.success(updatedUser);
  }
  
  @override
  Future<Result<User>> signInWithGoogle() async {
    signInCallCount++;
    await _simulateDelay();
    
    if (shouldFailNextAuth) {
      shouldFailNextAuth = false;
      return const Result.failure(
        AppError.unauthorized(
          message: 'Google sign in failed',
          code: 'GOOGLE_AUTH_FAILED',
        ),
      );
    }
    
    // Simulate OAuth user
    final user = User(
      id: _uuid.v4(),
      email: 'google.user@gmail.com',
      displayName: 'Google User',
      photoUrl: 'https://example.com/photo.jpg',
      isAnonymous: false,
      emailVerified: true,
      createdAt: DateTime.now(),
      lastSignInAt: DateTime.now(),
      providers: ['google'],
      role: UserRole.user,
      permissions: UserRole.user.permissions,
    );
    
    _users[user.id] = user;
    _currentUser = user;
    
    // Generate token
    final token = _generateToken();
    _tokens[token] = user.id;
    _tokenExpiry[token] = DateTime.now().add(tokenLifetime);
    _currentToken = token;
    
    _authStateController.add(user);
    
    return Result.success(user);
  }
  
  @override
  Future<Result<User>> signInWithApple() async {
    signInCallCount++;
    await _simulateDelay();
    
    if (shouldFailNextAuth) {
      shouldFailNextAuth = false;
      return const Result.failure(
        AppError.unauthorized(
          message: 'Apple sign in failed',
          code: 'APPLE_AUTH_FAILED',
        ),
      );
    }
    
    // Simulate Apple OAuth user
    final user = User(
      id: _uuid.v4(),
      email: 'apple.user@icloud.com',
      displayName: 'Apple User',
      isAnonymous: false,
      emailVerified: true,
      createdAt: DateTime.now(),
      lastSignInAt: DateTime.now(),
      providers: ['apple'],
      role: UserRole.user,
      permissions: UserRole.user.permissions,
    );
    
    _users[user.id] = user;
    _currentUser = user;
    
    // Generate token
    final token = _generateToken();
    _tokens[token] = user.id;
    _tokenExpiry[token] = DateTime.now().add(tokenLifetime);
    _currentToken = token;
    
    _authStateController.add(user);
    
    return Result.success(user);
  }
  
  @override
  Future<Result<User>> signInAnonymously() async {
    signInCallCount++;
    await _simulateDelay();
    
    if (shouldFailNextAuth) {
      shouldFailNextAuth = false;
      return const Result.failure(
        AppError.unauthorized(
          message: 'Anonymous sign in failed',
          code: 'ANON_AUTH_FAILED',
        ),
      );
    }
    
    // Create anonymous user
    final user = User(
      id: _uuid.v4(),
      email: null,
      displayName: 'Anonymous User',
      isAnonymous: true,
      emailVerified: false,
      createdAt: DateTime.now(),
      lastSignInAt: DateTime.now(),
      providers: ['anonymous'],
      role: UserRole.viewer,
      permissions: UserRole.viewer.permissions,
    );
    
    _users[user.id] = user;
    _currentUser = user;
    
    // Generate token
    final token = _generateToken();
    _tokens[token] = user.id;
    _tokenExpiry[token] = DateTime.now().add(tokenLifetime);
    _currentToken = token;
    
    _authStateController.add(user);
    
    return Result.success(user);
  }
  
  @override
  Future<Result<User>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    signUpCallCount++;
    await _simulateDelay();
    
    if (shouldFailNextAuth) {
      shouldFailNextAuth = false;
      return const Result.failure(
        AppError.validation(
          message: 'Sign up failed',
          code: 'SIGNUP_FAILED',
        ),
      );
    }
    
    // Check if email already exists
    if (_passwords.containsKey(email)) {
      return const Result.failure(
        AppError.duplicate(
          message: 'Email already registered',
          code: 'EMAIL_EXISTS',
        ),
      );
    }
    
    // Validate email format
    if (!_isValidEmail(email)) {
      return const Result.failure(
        AppError.validation(
          message: 'Invalid email format',
          code: 'INVALID_EMAIL',
        ),
      );
    }
    
    // Validate password strength
    if (password.length < 6) {
      return const Result.failure(
        AppError.validation(
          message: 'Password must be at least 6 characters',
          code: 'WEAK_PASSWORD',
        ),
      );
    }
    
    // Create new user
    final user = User(
      id: _uuid.v4(),
      email: email,
      displayName: displayName ?? email.split('@').first,
      isAnonymous: false,
      emailVerified: !requireEmailVerification,
      createdAt: DateTime.now(),
      lastSignInAt: DateTime.now(),
      providers: ['email'],
      role: UserRole.user,
      permissions: UserRole.user.permissions,
    );
    
    _users[user.id] = user;
    _passwords[email] = _hashPassword(password);
    _currentUser = user;
    
    // Generate token
    final token = _generateToken();
    _tokens[token] = user.id;
    _tokenExpiry[token] = DateTime.now().add(tokenLifetime);
    _currentToken = token;
    
    _authStateController.add(user);
    
    return Result.success(user);
  }
  
  @override
  Future<Result<void>> signOut() async {
    signOutCallCount++;
    await _simulateDelay();
    
    if (_currentToken != null) {
      _tokens.remove(_currentToken);
      _tokenExpiry.remove(_currentToken);
    }
    
    _currentUser = null;
    _currentToken = null;
    _authStateController.add(null);
    
    return const Result.success(null);
  }
  
  @override
  Future<Result<User?>> getCurrentUser() async {
    await _simulateDelay();
    
    if (_currentUser == null) {
      return const Result.success(null);
    }
    
    // Check token validity
    if (_currentToken != null) {
      final expiry = _tokenExpiry[_currentToken];
      if (expiry != null && expiry.isBefore(DateTime.now())) {
        // Token expired
        _currentUser = null;
        _currentToken = null;
        _authStateController.add(null);
        return const Result.success(null);
      }
    }
    
    return Result.success(_currentUser);
  }
  
  @override
  Stream<User?> watchAuthState() {
    // Emit current state immediately
    Timer.run(() {
      _authStateController.add(_currentUser);
    });
    return _authStateController.stream;
  }
  
  @override
  Future<Result<String>> refreshToken({bool forceRefresh = false}) async {
    refreshTokenCallCount++;
    await _simulateDelay();
    
    if (_currentUser == null || _currentToken == null) {
      return const Result.failure(
        AppError.unauthorized(
          message: 'No active session',
          code: 'NO_SESSION',
        ),
      );
    }
    
    final expiry = _tokenExpiry[_currentToken];
    if (!forceRefresh && expiry != null && expiry.isAfter(DateTime.now())) {
      // Token still valid
      return Result.success(_currentToken!);
    }
    
    // Generate new token
    _tokens.remove(_currentToken);
    _tokenExpiry.remove(_currentToken);
    
    final newToken = _generateToken();
    _tokens[newToken] = _currentUser!.id;
    _tokenExpiry[newToken] = DateTime.now().add(tokenLifetime);
    _currentToken = newToken;
    
    return Result.success(newToken);
  }
  
  @override
  Future<Result<bool>> isAuthenticated() async {
    await _simulateDelay();
    
    if (_currentUser == null || _currentToken == null) {
      return const Result.success(false);
    }
    
    final expiry = _tokenExpiry[_currentToken];
    if (expiry != null && expiry.isBefore(DateTime.now())) {
      return const Result.success(false);
    }
    
    return const Result.success(true);
  }
  
  @override
  Future<Result<bool>> hasPermission(String permission) async {
    permissionCheckCount++;
    await _simulateDelay();
    
    if (_currentUser == null) {
      return const Result.success(false);
    }
    
    return Result.success(_currentUser!.hasPermission(permission));
  }
  
  @override
  Future<Result<User>> updateProfile(UserProfile profile) async {
    await _simulateDelay();
    
    if (_currentUser == null) {
      return const Result.failure(
        AppError.unauthorized(
          message: 'No active session',
          code: 'NO_SESSION',
        ),
      );
    }
    
    // Update user
    final updated = User(
      id: _currentUser!.id,
      email: _currentUser!.email,
      displayName: profile.displayName ?? _currentUser!.displayName,
      photoUrl: profile.photoUrl ?? _currentUser!.photoUrl,
      isAnonymous: _currentUser!.isAnonymous,
      emailVerified: _currentUser!.emailVerified,
      createdAt: _currentUser!.createdAt,
      lastSignInAt: _currentUser!.lastSignInAt,
      providers: _currentUser!.providers,
      customClaims: profile.metadata ?? _currentUser!.customClaims,
      role: _currentUser!.role,
      permissions: _currentUser!.permissions,
    );
    
    _users[updated.id] = updated;
    _currentUser = updated;
    _authStateController.add(updated);
    
    return Result.success(updated);
  }
  
  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    await _simulateDelay();
    
    if (!_passwords.containsKey(email)) {
      // Don't reveal if email exists
      return const Result.success(null);
    }
    
    // Simulate sending email
    return const Result.success(null);
  }
  
  @override
  Future<Result<void>> verifyEmail(String code) async {
    await _simulateDelay();
    
    if (_currentUser == null) {
      return const Result.failure(
        AppError.unauthorized(
          message: 'No active session',
          code: 'NO_SESSION',
        ),
      );
    }
    
    // Simulate code verification
    if (code != '123456') {
      return const Result.failure(
        AppError.validation(
          message: 'Invalid verification code',
          code: 'INVALID_CODE',
        ),
      );
    }
    
    // Update user
    final updated = User(
      id: _currentUser!.id,
      email: _currentUser!.email,
      displayName: _currentUser!.displayName,
      photoUrl: _currentUser!.photoUrl,
      isAnonymous: _currentUser!.isAnonymous,
      emailVerified: true,
      createdAt: _currentUser!.createdAt,
      lastSignInAt: _currentUser!.lastSignInAt,
      providers: _currentUser!.providers,
      customClaims: _currentUser!.customClaims,
      role: _currentUser!.role,
      permissions: _currentUser!.permissions,
    );
    
    _users[updated.id] = updated;
    _currentUser = updated;
    _authStateController.add(updated);
    
    return const Result.success(null);
  }
  
  @override
  Future<Result<User>> linkWithCredential(AuthCredential credential) async {
    await _simulateDelay();
    
    if (_currentUser == null) {
      return const Result.failure(
        AppError.unauthorized(
          message: 'No active session',
          code: 'NO_SESSION',
        ),
      );
    }
    
    if (!_currentUser!.isAnonymous) {
      return const Result.failure(
        AppError.validation(
          message: 'User is not anonymous',
          code: 'NOT_ANONYMOUS',
        ),
      );
    }
    
    // Update user to non-anonymous
    final updated = User(
      id: _currentUser!.id,
      email: 'linked@example.com',
      displayName: _currentUser!.displayName,
      photoUrl: _currentUser!.photoUrl,
      isAnonymous: false,
      emailVerified: true,
      createdAt: _currentUser!.createdAt,
      lastSignInAt: DateTime.now(),
      providers: [..._currentUser!.providers, credential.provider.toString()],
      customClaims: _currentUser!.customClaims,
      role: UserRole.user,
      permissions: UserRole.user.permissions,
    );
    
    _users[updated.id] = updated;
    _currentUser = updated;
    _authStateController.add(updated);
    
    return Result.success(updated);
  }
  
  @override
  Future<Result<void>> deleteAccount({required String password}) async {
    await _simulateDelay();
    
    if (_currentUser == null) {
      return const Result.failure(
        AppError.unauthorized(
          message: 'No active session',
          code: 'NO_SESSION',
        ),
      );
    }
    
    // Verify password
    if (_currentUser!.email != null) {
      final storedHash = _passwords[_currentUser!.email!];
      final providedHash = _hashPassword(password);
      
      if (storedHash != providedHash) {
        return const Result.failure(
          AppError.unauthorized(
            message: 'Invalid password',
            code: 'INVALID_PASSWORD',
          ),
        );
      }
    }
    
    // Delete user
    _users.remove(_currentUser!.id);
    if (_currentUser!.email != null) {
      _passwords.remove(_currentUser!.email);
    }
    
    // Sign out
    await signOut();
    
    return const Result.success(null);
  }
  
  @override
  Future<Result<List<AuthProvider>>> getAvailableProviders() async {
    await _simulateDelay();
    
    return const Result.success([
      AuthProvider.email,
      AuthProvider.google,
      AuthProvider.apple,
      AuthProvider.anonymous,
    ]);
  }
  
  @override
  Future<Result<MfaSetup>> enableMfa(MfaMethod method) async {
    await _simulateDelay();
    
    if (_currentUser == null) {
      return const Result.failure(
        AppError.unauthorized(
          message: 'No active session',
          code: 'NO_SESSION',
        ),
      );
    }
    
    // Generate MFA setup
    final setup = MfaSetup(
      method: method,
      secret: method == MfaMethod.totp ? 'JBSWY3DPEHPK3PXP' : null,
      qrCodeUrl: method == MfaMethod.totp 
          ? 'otpauth://totp/MockApp:${_currentUser!.email}?secret=JBSWY3DPEHPK3PXP&issuer=MockApp'
          : null,
      backupCodes: ['12345678', '87654321', '11223344'],
    );
    
    return Result.success(setup);
  }
  
  @override
  Future<Result<void>> verifyMfa(String code) async {
    await _simulateDelay();
    
    if (_currentUser == null) {
      return const Result.failure(
        AppError.unauthorized(
          message: 'No active session',
          code: 'NO_SESSION',
        ),
      );
    }
    
    // Simulate MFA verification
    if (code != '123456') {
      return const Result.failure(
        AppError.validation(
          message: 'Invalid MFA code',
          code: 'INVALID_MFA',
        ),
      );
    }
    
    return const Result.success(null);
  }
  
  // Helper methods for testing
  
  /// Clear all data (useful for test setup/teardown)
  void clear() {
    _users.clear();
    _passwords.clear();
    _tokens.clear();
    _tokenExpiry.clear();
    _currentUser = null;
    _currentToken = null;
    signInCallCount = 0;
    signOutCallCount = 0;
    signUpCallCount = 0;
    refreshTokenCallCount = 0;
    permissionCheckCount = 0;
    
    if (!_authStateController.isClosed) {
      _authStateController.add(null);
    }
  }
  
  /// Get all users (for test assertions)
  Map<String, User> getAllUsers() => Map.from(_users);
  
  /// Get current session info (for test assertions)
  Map<String, dynamic> getSessionInfo() {
    return {
      'currentUser': _currentUser?.id,
      'currentToken': _currentToken,
      'tokenValid': _currentToken != null && 
                    _tokenExpiry[_currentToken]?.isAfter(DateTime.now()) == true,
      'signInCount': signInCallCount,
      'signOutCount': signOutCallCount,
      'refreshCount': refreshTokenCallCount,
    };
  }
  
  /// Inject a user (for test setup)
  void injectUser(User user, {String? password}) {
    _users[user.id] = user;
    if (user.email != null && password != null) {
      _passwords[user.email!] = _hashPassword(password);
    }
  }
  
  /// Set current user (for test setup)
  void setCurrentUser(User? user) {
    _currentUser = user;
    if (user != null) {
      final token = _generateToken();
      _tokens[token] = user.id;
      _tokenExpiry[token] = DateTime.now().add(tokenLifetime);
      _currentToken = token;
    }
    _authStateController.add(user);
  }
  
  // Private helper methods
  
  Future<void> _simulateDelay() async {
    if (simulatedDelay != null) {
      await Future.delayed(simulatedDelay!);
    }
  }
  
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  String _generateToken() {
    return 'mock-token-${_uuid.v4()}';
  }
  
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  void _createDefaultTestUsers() {
    // Admin user
    final admin = User(
      id: 'admin-001',
      email: 'admin@test.com',
      displayName: 'Admin User',
      isAnonymous: false,
      emailVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastSignInAt: DateTime.now().subtract(const Duration(hours: 1)),
      providers: ['email'],
      role: UserRole.admin,
      permissions: UserRole.admin.permissions,
    );
    
    _users[admin.id] = admin;
    _passwords['admin@test.com'] = _hashPassword('admin123');
    
    // Regular user
    final user = User(
      id: 'user-001',
      email: 'user@test.com',
      displayName: 'Test User',
      isAnonymous: false,
      emailVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      lastSignInAt: DateTime.now().subtract(const Duration(hours: 12)),
      providers: ['email'],
      role: UserRole.user,
      permissions: UserRole.user.permissions,
    );
    
    _users[user.id] = user;
    _passwords['user@test.com'] = _hashPassword('user123');
    
    // Viewer user
    final viewer = User(
      id: 'viewer-001',
      email: 'viewer@test.com',
      displayName: 'Viewer User',
      isAnonymous: false,
      emailVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      providers: ['email'],
      role: UserRole.viewer,
      permissions: UserRole.viewer.permissions,
    );
    
    _users[viewer.id] = viewer;
    _passwords['viewer@test.com'] = _hashPassword('viewer123');
  }
  
  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}