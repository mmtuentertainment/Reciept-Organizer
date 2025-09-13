import 'dart:async';
import '../../domain/services/interfaces/i_auth_service.dart';

/// Mock implementation of auth service for testing
class MockAuthService implements IAuthService {
  final StreamController<AuthState> _authStateController = StreamController<AuthState>.broadcast();
  
  String? _currentUserId;
  String? _currentUserEmail;
  AuthState _currentState = AuthState.unauthenticated;
  
  // Mock user database
  final Map<String, String> _users = {
    'test@example.com': 'password123',
    'user@test.com': 'testpass',
  };
  
  @override
  bool get isAuthenticated => _currentUserId != null;
  
  @override
  String? get currentUserId => _currentUserId;
  
  @override
  String? get currentUserEmail => _currentUserEmail;
  
  @override
  Stream<AuthState> get authStateStream => _authStateController.stream;
  
  @override
  Future<AuthResult> signInWithPassword({
    required String email,
    required String password,
  }) async {
    _updateState(AuthState.loading);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Check credentials
    if (_users[email] == password) {
      _currentUserId = 'user_${email.hashCode}';
      _currentUserEmail = email;
      _updateState(AuthState.authenticated);
      
      return AuthResult.success(
        userId: _currentUserId!,
        email: email,
      );
    } else {
      _updateState(AuthState.unauthenticated);
      
      return AuthResult.failure(
        errorMessage: 'Invalid email or password',
        errorType: AuthErrorType.invalidCredentials,
      );
    }
  }
  
  @override
  Future<AuthResult> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _updateState(AuthState.loading);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Check if user already exists
    if (_users.containsKey(email)) {
      _updateState(AuthState.unauthenticated);
      
      return AuthResult.failure(
        errorMessage: 'Email already in use',
        errorType: AuthErrorType.emailAlreadyInUse,
      );
    }
    
    // Validate password
    if (password.length < 6) {
      _updateState(AuthState.unauthenticated);
      
      return AuthResult.failure(
        errorMessage: 'Password must be at least 6 characters',
        errorType: AuthErrorType.weakPassword,
      );
    }
    
    // Create user
    _users[email] = password;
    _currentUserId = 'user_${email.hashCode}';
    _currentUserEmail = email;
    _updateState(AuthState.authenticated);
    
    return AuthResult.success(
      userId: _currentUserId!,
      email: email,
    );
  }
  
  @override
  Future<AuthResult> signInAnonymously() async {
    _updateState(AuthState.loading);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));
    
    _currentUserId = 'anon_${DateTime.now().millisecondsSinceEpoch}';
    _currentUserEmail = null;
    _updateState(AuthState.authenticated);
    
    return AuthResult.success(
      userId: _currentUserId!,
    );
  }
  
  @override
  Future<void> signOut() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    _currentUserId = null;
    _currentUserEmail = null;
    _updateState(AuthState.unauthenticated);
  }
  
  @override
  Future<void> resetPassword(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (!_users.containsKey(email)) {
      throw Exception('User not found');
    }
    
    // In a real implementation, this would send an email
    print('Password reset email sent to $email');
  }
  
  @override
  Future<void> sendEmailVerification() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (_currentUserEmail == null) {
      throw Exception('No email to verify');
    }
    
    print('Verification email sent to $_currentUserEmail');
  }
  
  @override
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (!isAuthenticated) {
      throw Exception('Not authenticated');
    }
    
    print('Profile updated: displayName=$displayName, photoUrl=$photoUrl');
  }
  
  @override
  Future<void> deleteAccount() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!isAuthenticated || _currentUserEmail == null) {
      throw Exception('Not authenticated');
    }
    
    _users.remove(_currentUserEmail);
    _currentUserId = null;
    _currentUserEmail = null;
    _updateState(AuthState.unauthenticated);
  }
  
  @override
  Future<AuthResult> linkAnonymousAccount({
    required String email,
    required String password,
  }) async {
    _updateState(AuthState.loading);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (_currentUserId == null || !_currentUserId!.startsWith('anon_')) {
      _updateState(AuthState.authenticated);
      
      return AuthResult.failure(
        errorMessage: 'Not an anonymous account',
        errorType: AuthErrorType.unknown,
      );
    }
    
    // Check if email already exists
    if (_users.containsKey(email)) {
      _updateState(AuthState.authenticated);
      
      return AuthResult.failure(
        errorMessage: 'Email already in use',
        errorType: AuthErrorType.emailAlreadyInUse,
      );
    }
    
    // Link account
    _users[email] = password;
    _currentUserId = 'user_${email.hashCode}';
    _currentUserEmail = email;
    _updateState(AuthState.authenticated);
    
    return AuthResult.success(
      userId: _currentUserId!,
      email: email,
    );
  }
  
  @override
  Future<void> refreshToken() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!isAuthenticated) {
      throw Exception('Not authenticated');
    }
    
    // Token refreshed (mock)
  }
  
  @override
  Future<bool> isSessionValid() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 50));
    
    return isAuthenticated;
  }
  
  @override
  Future<String?> getAccessToken() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 50));
    
    if (!isAuthenticated) {
      return null;
    }
    
    // Return mock token
    return 'mock_token_${_currentUserId}';
  }
  
  void _updateState(AuthState state) {
    _currentState = state;
    _authStateController.add(state);
  }
  
  // Test helpers
  void setAuthenticated(String userId, String email) {
    _currentUserId = userId;
    _currentUserEmail = email;
    _updateState(AuthState.authenticated);
  }
  
  void clearAuthentication() {
    _currentUserId = null;
    _currentUserEmail = null;
    _updateState(AuthState.unauthenticated);
  }
}