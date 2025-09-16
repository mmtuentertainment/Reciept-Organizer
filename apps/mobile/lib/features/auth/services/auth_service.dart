import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../infrastructure/config/supabase_config.dart';

class AuthService {
  static final _client = SupabaseConfig.client;

  /// Sign in with email and password
  static Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign in with Google OAuth
  static Future<bool> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.receiptorganizer.app://login-callback/',
        scopes: 'email profile',
      );
      return true;
    } catch (e) {
      print('Google sign-in error: $e');
      return false;
    }
  }

  /// Sign in with Apple OAuth
  static Future<bool> signInWithApple() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'com.receiptorganizer.app://login-callback/',
        scopes: 'email name',
      );
      return true;
    } catch (e) {
      print('Apple sign-in error: $e');
      return false;
    }
  }

  /// Reset password for email
  static Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'com.receiptorganizer.app://reset-password',
    );
  }

  /// Update user password
  static Future<UserResponse> updatePassword(String newPassword) async {
    return await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  /// Resend verification email
  static Future<ResendResponse> resendVerificationEmail(String email) async {
    return await _client.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  /// Sign out
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Get current user
  static User? get currentUser => _client.auth.currentUser;

  /// Get current session
  static Session? get currentSession => _client.auth.currentSession;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Check if user email is verified
  static bool get isEmailVerified => currentUser?.emailConfirmedAt != null;

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Refresh session
  static Future<AuthResponse> refreshSession() async {
    final session = currentSession;
    if (session == null) {
      throw Exception('No session to refresh');
    }
    return await _client.auth.refreshSession();
  }

  /// Set session from deep link
  static Future<Session> setSessionFromUrl(Uri uri) async {
    final response = await _client.auth.getSessionFromUrl(uri);
    // The method returns AuthSessionUrlResponse, we need to extract the session
    if (response.session != null) {
      return response.session!;
    } else {
      throw Exception('Failed to get session from URL');
    }
  }

  /// Check and refresh session if needed
  static Future<void> checkAndRefreshSession() async {
    final session = currentSession;
    if (session == null) return;

    final expiresAt = session.expiresAt;
    if (expiresAt == null) return;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final timeUntilExpiry = expiresAt - now;

    // Refresh if less than 60 seconds until expiry
    if (timeUntilExpiry < 60) {
      try {
        await refreshSession();
      } catch (e) {
        print('Failed to refresh session: $e');
      }
    }
  }
}