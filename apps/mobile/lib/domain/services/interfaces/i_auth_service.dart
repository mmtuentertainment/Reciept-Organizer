/// Interface for authentication service
/// 
/// This interface defines the contract for user authentication
/// supporting both offline-first and cloud-based auth
abstract class IAuthService {
  /// Check if user is authenticated
  bool get isAuthenticated;
  
  /// Get current user ID (null if not authenticated)
  String? get currentUserId;
  
  /// Get current user email
  String? get currentUserEmail;
  
  /// Get authentication state stream
  Stream<AuthState> get authStateStream;
  
  /// Sign in with email and password
  Future<AuthResult> signInWithPassword({
    required String email,
    required String password,
  });
  
  /// Sign up with email and password
  Future<AuthResult> signUp({
    required String email,
    required String password,
    String? displayName,
  });
  
  /// Sign in anonymously (for offline-first mode)
  Future<AuthResult> signInAnonymously();
  
  /// Sign out
  Future<void> signOut();
  
  /// Reset password
  Future<void> resetPassword(String email);
  
  /// Verify email
  Future<void> sendEmailVerification();
  
  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  });
  
  /// Delete account
  Future<void> deleteAccount();
  
  /// Convert anonymous account to permanent
  Future<AuthResult> linkAnonymousAccount({
    required String email,
    required String password,
  });
  
  /// Refresh authentication token
  Future<void> refreshToken();
  
  /// Check if current session is valid
  Future<bool> isSessionValid();
  
  /// Get access token for API calls
  Future<String?> getAccessToken();
}

/// Result of an authentication operation
class AuthResult {
  final bool success;
  final String? userId;
  final String? email;
  final String? errorMessage;
  final AuthErrorType? errorType;
  
  AuthResult({
    required this.success,
    this.userId,
    this.email,
    this.errorMessage,
    this.errorType,
  });
  
  AuthResult.success({
    required String userId,
    String? email,
  }) : this(
    success: true,
    userId: userId,
    email: email,
  );
  
  AuthResult.failure({
    required String errorMessage,
    AuthErrorType? errorType,
  }) : this(
    success: false,
    errorMessage: errorMessage,
    errorType: errorType,
  );
}

/// Authentication state
enum AuthState {
  authenticated,
  unauthenticated,
  loading,
  error,
}

/// Types of authentication errors
enum AuthErrorType {
  invalidCredentials,
  userNotFound,
  emailAlreadyInUse,
  weakPassword,
  networkError,
  serverError,
  sessionExpired,
  emailNotVerified,
  tooManyRequests,
  unknown,
}