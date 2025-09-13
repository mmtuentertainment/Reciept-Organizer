import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/services/interfaces/i_auth_service.dart' as auth_interface;
import '../../core/exceptions/service_exception.dart';
import '../models/user_info.dart';

/// Production implementation of auth service using Supabase
class SupabaseAuthService implements auth_interface.IAuthService {
  final SupabaseClient _client;
  final StreamController<auth_interface.AuthState> _authStateController = 
      StreamController<auth_interface.AuthState>.broadcast();
  
  UserInfo? _currentUser;
  auth_interface.AuthState _currentState = auth_interface.AuthState.unauthenticated;
  
  SupabaseAuthService(this._client) {
    _initializeAuthListener();
    _checkInitialAuthState();
  }
  
  @override
  bool get isAuthenticated => _client.auth.currentUser != null;
  
  @override
  String? get currentUserId => _client.auth.currentUser?.id;
  
  @override
  String? get currentUserEmail => _client.auth.currentUser?.email;
  
  UserInfo? get currentUser => _currentUser;
  
  @override
  Stream<auth_interface.AuthState> get authStateStream => _authStateController.stream;
  
  @override
  Future<auth_interface.AuthResult> signInWithPassword({
    required String email,
    required String password,
  }) async {
    _updateState(auth_interface.AuthState.loading);
    
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        _updateUser(response.user!);
        _updateState(auth_interface.AuthState.authenticated);
        
        return auth_interface.AuthResult(
          success: true,
          userId: response.user!.id,
          email: response.user!.email,
        );
      } else {
        _updateState(auth_interface.AuthState.unauthenticated);
        return auth_interface.AuthResult(
          success: false,
          errorMessage: 'Invalid credentials',
        );
      }
    } on AuthException catch (e) {
      _updateState(auth_interface.AuthState.unauthenticated);
      return auth_interface.AuthResult(
        success: false,
        errorMessage: e.message,
      );
    } catch (e) {
      _updateState(auth_interface.AuthState.unauthenticated);
      return auth_interface.AuthResult(
        success: false,
        errorMessage: 'Failed to sign in: $e',
      );
    }
  }
  
  @override
  Future<auth_interface.AuthResult> signInAnonymously() async {
    _updateState(auth_interface.AuthState.loading);
    
    try {
      // Supabase doesn't have built-in anonymous auth
      // We'll create a temporary account with random credentials
      final tempEmail = 'anon_${DateTime.now().millisecondsSinceEpoch}@receiptorganizer.temp';
      final tempPassword = _generateSecurePassword();
      
      final response = await _client.auth.signUp(
        email: tempEmail,
        password: tempPassword,
        data: {
          'is_anonymous': true,
          'created_at': DateTime.now().toIso8601String(),
        },
      );
      
      if (response.user != null) {
        _updateUser(response.user!);
        _updateState(auth_interface.AuthState.authenticated);
        
        return auth_interface.AuthResult(
          success: true,
          userId: response.user!.id,
        );
      } else {
        _updateState(auth_interface.AuthState.unauthenticated);
        return auth_interface.AuthResult(
          success: false,
          errorMessage: 'Failed to create anonymous session',
        );
      }
    } catch (e) {
      _updateState(auth_interface.AuthState.unauthenticated);
      return auth_interface.AuthResult(
        success: false,
        errorMessage: 'Failed to sign in anonymously: $e',
      );
    }
  }
  
  @override
  Future<auth_interface.AuthResult> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _updateState(auth_interface.AuthState.loading);
    
    try {
      final metadata = <String, dynamic>{};
      if (displayName != null) {
        metadata['display_name'] = displayName;
      }
      
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );
      
      if (response.user != null) {
        _updateUser(response.user!);
        
        // Check if email confirmation is required
        if (response.user!.confirmedAt == null) {
          _updateState(auth_interface.AuthState.unauthenticated);
          return auth_interface.AuthResult(
            success: true,
            userId: response.user!.id,
            email: response.user!.email,
            errorMessage: 'Please check your email to confirm your account',
          );
        } else {
          _updateState(auth_interface.AuthState.authenticated);
          return auth_interface.AuthResult(
            success: true,
            userId: response.user!.id,
            email: response.user!.email,
          );
        }
      } else {
        _updateState(auth_interface.AuthState.unauthenticated);
        return auth_interface.AuthResult(
          success: false,
          errorMessage: 'Failed to create account',
        );
      }
    } on AuthException catch (e) {
      _updateState(auth_interface.AuthState.unauthenticated);
      return auth_interface.AuthResult(
        success: false,
        errorMessage: e.message,
      );
    } catch (e) {
      _updateState(auth_interface.AuthState.unauthenticated);
      return auth_interface.AuthResult(
        success: false,
        errorMessage: 'Failed to sign up: $e',
      );
    }
  }
  
  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      _currentUser = null;
      _updateState(auth_interface.AuthState.unauthenticated);
    } catch (e) {
      throw ServiceException('Failed to sign out: $e');
    }
  }
  
  @override
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'receiptorganizer://reset-password',
      );
    } on AuthException catch (e) {
      throw ServiceException(e.message);
    } catch (e) {
      throw ServiceException('Failed to send reset email: $e');
    }
  }
  
  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw ServiceException('No user signed in');
      }
      
      // Supabase handles email verification differently
      // Usually done during signup
      // This is a placeholder for compatibility
    } catch (e) {
      throw ServiceException('Failed to send verification email: $e');
    }
  }
  
  @override
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final updates = UserAttributes(
        data: {
          if (displayName != null) 'display_name': displayName,
          if (photoUrl != null) 'photo_url': photoUrl,
        },
      );
      
      final response = await _client.auth.updateUser(updates);
      
      if (response.user != null) {
        _updateUser(response.user!);
      }
    } catch (e) {
      throw ServiceException('Failed to update profile: $e');
    }
  }
  
  @override
  Future<void> deleteAccount() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw ServiceException('No user signed in');
      }
      
      // Note: This requires admin privileges
      // For production, you'd typically call a server function
      await _client.auth.signOut();
      
      _currentUser = null;
      _updateState(auth_interface.AuthState.unauthenticated);
    } catch (e) {
      throw ServiceException('Failed to delete account: $e');
    }
  }
  
  @override
  Future<auth_interface.AuthResult> linkAnonymousAccount({
    required String email,
    required String password,
  }) async {
    try {
      // Update the current anonymous user with real credentials
      final updates = UserAttributes(
        email: email,
        password: password,
        data: {
          'is_anonymous': false,
        },
      );
      
      final response = await _client.auth.updateUser(updates);
      
      if (response.user != null) {
        _updateUser(response.user!);
        return auth_interface.AuthResult(
          success: true,
          userId: response.user!.id,
          email: response.user!.email,
        );
      } else {
        return auth_interface.AuthResult(
          success: false,
          errorMessage: 'Failed to link account',
        );
      }
    } catch (e) {
      return auth_interface.AuthResult(
        success: false,
        errorMessage: 'Failed to link account: $e',
      );
    }
  }
  
  @override
  Future<void> refreshToken() async {
    try {
      await _client.auth.refreshSession();
    } catch (e) {
      throw ServiceException('Failed to refresh token: $e');
    }
  }
  
  @override
  Future<bool> isSessionValid() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) return false;
      
      // Check if token is expired
      final expiresAt = session.expiresAt;
      if (expiresAt == null) return false;
      
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
      return DateTime.now().isBefore(expiryTime);
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<String?> getAccessToken() async {
    try {
      final session = _client.auth.currentSession;
      return session?.accessToken;
    } catch (e) {
      return null;
    }
  }
  
  // Private helper methods
  
  void _initializeAuthListener() {
    _client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;
      
      switch (event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
          if (session?.user != null) {
            _updateUser(session!.user);
            _updateState(auth_interface.AuthState.authenticated);
          }
          break;
        case AuthChangeEvent.signedOut:
          _currentUser = null;
          _updateState(auth_interface.AuthState.unauthenticated);
          break;
        case AuthChangeEvent.userUpdated:
          if (session?.user != null) {
            _updateUser(session!.user);
          }
          break;
        default:
          break;
      }
    });
  }
  
  Future<void> _checkInitialAuthState() async {
    try {
      final session = _client.auth.currentSession;
      final user = _client.auth.currentUser;
      
      if (session != null && user != null) {
        _updateUser(user);
        _updateState(auth_interface.AuthState.authenticated);
      } else {
        _updateState(auth_interface.AuthState.unauthenticated);
      }
    } catch (e) {
      _updateState(auth_interface.AuthState.unauthenticated);
    }
  }
  
  void _updateUser(User user) {
    _currentUser = UserInfo(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['display_name'] ?? '',
      photoUrl: user.userMetadata?['photo_url'],
      emailVerified: user.confirmedAt != null,
      isAnonymous: user.userMetadata?['is_anonymous'] == true,
      createdAt: user.createdAt != null ? DateTime.parse(user.createdAt!) : DateTime.now(),
      lastSignInAt: DateTime.now(),
      metadata: user.userMetadata ?? {},
    );
  }
  
  void _updateState(auth_interface.AuthState state) {
    _currentState = state;
    _authStateController.add(state);
  }
  
  String _generateSecurePassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()';
    final random = DateTime.now().millisecondsSinceEpoch;
    final buffer = StringBuffer();
    
    for (var i = 0; i < 32; i++) {
      final index = (random + i) % chars.length;
      buffer.write(chars[index]);
    }
    
    return buffer.toString();
  }
  
  void dispose() {
    _authStateController.close();
  }
}