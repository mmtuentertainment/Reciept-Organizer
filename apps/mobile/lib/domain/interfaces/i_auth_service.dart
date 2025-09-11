import 'package:receipt_organizer/core/models/result.dart';

/// Service interface for authentication and authorization operations.
/// 
/// This interface provides authentication abstraction supporting multiple providers
/// (email/password, OAuth, anonymous) and authorization for multi-user scenarios.
/// Designed to work with both local-only and cloud-enabled configurations.
abstract class IAuthService {
  /// Sign in with email and password.
  /// 
  /// [email] User's email address.
  /// [password] User's password.
  /// 
  /// Returns a Result containing the authenticated user,
  /// or an error if authentication fails.
  /// 
  /// Example:
  /// ```dart
  /// final result = await auth.signIn(email: 'user@example.com', password: 'secure123');
  /// result.onSuccess((user) => print('Welcome ${user.displayName}'))
  ///       .onFailure((error) => print('Login failed: ${error.message}'));
  /// ```
  Future<Result<User>> signIn({
    required String email,
    required String password,
  });
  
  /// Sign in with Google OAuth.
  /// 
  /// Initiates Google OAuth flow for authentication.
  /// Handles the OAuth dance and returns authenticated user.
  /// 
  /// Returns a Result containing the authenticated user,
  /// or an error if the OAuth flow fails or is cancelled.
  Future<Result<User>> signInWithGoogle();
  
  /// Sign in with Apple ID.
  /// 
  /// Initiates Apple Sign In flow for authentication.
  /// Only available on iOS 13+ and macOS 10.15+.
  /// 
  /// Returns a Result containing the authenticated user,
  /// or an error if the sign in fails or is not supported.
  Future<Result<User>> signInWithApple();
  
  /// Sign in anonymously.
  /// 
  /// Creates an anonymous session for users who want to try the app
  /// without creating an account. Can be upgraded to a full account later.
  /// 
  /// Returns a Result containing the anonymous user session.
  Future<Result<User>> signInAnonymously();
  
  /// Sign up with email and password.
  /// 
  /// [email] User's email address.
  /// [password] User's password.
  /// [displayName] Optional display name for the user.
  /// 
  /// Creates a new user account and signs them in.
  /// Returns a Result containing the new user or an error.
  Future<Result<User>> signUp({
    required String email,
    required String password,
    String? displayName,
  });
  
  /// Sign out the current user.
  /// 
  /// Clears authentication tokens and local session data.
  /// Returns a Result indicating success or failure.
  Future<Result<void>> signOut();
  
  /// Get the currently authenticated user.
  /// 
  /// Returns a Result containing the current user if authenticated,
  /// or null if no user is signed in.
  /// 
  /// This checks the cached session first, then validates with the backend
  /// if cloud-enabled.
  Future<Result<User?>> getCurrentUser();
  
  /// Watch authentication state changes.
  /// 
  /// Returns a stream that emits the current user whenever auth state changes
  /// (sign in, sign out, token refresh, etc.).
  /// 
  /// The stream emits null when no user is authenticated.
  /// Useful for reactive UI updates based on auth state.
  Stream<User?> watchAuthState();
  
  /// Refresh the authentication token.
  /// 
  /// [forceRefresh] If true, forces a token refresh even if not expired.
  /// 
  /// Returns a Result containing the new access token.
  /// This is typically called automatically, but can be triggered manually.
  Future<Result<String>> refreshToken({bool forceRefresh = false});
  
  /// Check if a user is currently authenticated.
  /// 
  /// Returns a Result containing true if authenticated, false otherwise.
  /// This is a quick check without network validation.
  Future<Result<bool>> isAuthenticated();
  
  /// Check if the current user has a specific permission.
  /// 
  /// [permission] The permission to check (e.g., 'receipts.write', 'admin.users').
  /// 
  /// Returns a Result containing true if the user has the permission.
  /// Supports role-based and fine-grained permissions.
  Future<Result<bool>> hasPermission(String permission);
  
  /// Update the current user's profile.
  /// 
  /// [profile] The updated profile information.
  /// 
  /// Returns a Result containing the updated user.
  Future<Result<User>> updateProfile(UserProfile profile);
  
  /// Send a password reset email.
  /// 
  /// [email] The email address to send the reset link to.
  /// 
  /// Returns a Result indicating whether the email was sent successfully.
  Future<Result<void>> sendPasswordResetEmail(String email);
  
  /// Verify email address with verification code.
  /// 
  /// [code] The verification code sent to the user's email.
  /// 
  /// Returns a Result indicating whether verification was successful.
  Future<Result<void>> verifyEmail(String code);
  
  /// Link an anonymous account to permanent credentials.
  /// 
  /// [credential] The authentication credential to link.
  /// 
  /// Upgrades an anonymous session to a permanent account.
  /// Returns a Result containing the upgraded user.
  Future<Result<User>> linkWithCredential(AuthCredential credential);
  
  /// Delete the current user's account.
  /// 
  /// [password] Current password for re-authentication.
  /// 
  /// Permanently deletes the user account and all associated data.
  /// Returns a Result indicating success or failure.
  Future<Result<void>> deleteAccount({required String password});
  
  /// Get available authentication providers.
  /// 
  /// Returns a list of authentication methods available
  /// (email, google, apple, anonymous, etc.).
  Future<Result<List<AuthProvider>>> getAvailableProviders();
  
  /// Enable multi-factor authentication.
  /// 
  /// [method] The MFA method to enable (SMS, TOTP, etc.).
  /// 
  /// Returns a Result with setup information for the MFA method.
  Future<Result<MfaSetup>> enableMfa(MfaMethod method);
  
  /// Verify multi-factor authentication code.
  /// 
  /// [code] The MFA code to verify.
  /// 
  /// Returns a Result indicating whether MFA verification succeeded.
  Future<Result<void>> verifyMfa(String code);
}

/// Authenticated user information
class User {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime? lastSignInAt;
  final List<String> providers; // Authentication providers linked
  final Map<String, dynamic>? customClaims; // Custom JWT claims
  final UserRole role;
  final List<String> permissions;
  
  const User({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.isAnonymous,
    required this.emailVerified,
    required this.createdAt,
    this.lastSignInAt,
    required this.providers,
    this.customClaims,
    required this.role,
    required this.permissions,
  });
  
  /// Check if user has a specific permission
  bool hasPermission(String permission) {
    // Check direct permission
    if (permissions.contains(permission) || 
        role.permissions.contains(permission)) {
      return true;
    }
    
    // Check wildcard permissions (e.g., 'users.*' matches 'users.manage')
    final allPermissions = [...permissions, ...role.permissions];
    for (final perm in allPermissions) {
      if (perm.endsWith('.*')) {
        final prefix = perm.substring(0, perm.length - 2);
        if (permission.startsWith('$prefix.')) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  /// Get user's initials for avatar
  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return parts.first[0].toUpperCase();
    }
    if (email != null && email!.isNotEmpty) {
      return email![0].toUpperCase();
    }
    return '?';
  }
}

/// User profile for updates
class UserProfile {
  final String? displayName;
  final String? photoUrl;
  final Map<String, dynamic>? metadata;
  
  const UserProfile({
    this.displayName,
    this.photoUrl,
    this.metadata,
  });
}

/// User role with permissions
class UserRole {
  final String id;
  final String name;
  final List<String> permissions;
  final int priority; // Higher number = more privileges
  
  const UserRole({
    required this.id,
    required this.name,
    required this.permissions,
    required this.priority,
  });
  
  /// Predefined roles
  static const UserRole viewer = UserRole(
    id: 'viewer',
    name: 'Viewer',
    permissions: ['receipts.read'],
    priority: 10,
  );
  
  static const UserRole user = UserRole(
    id: 'user',
    name: 'User',
    permissions: ['receipts.read', 'receipts.write', 'receipts.delete'],
    priority: 20,
  );
  
  static const UserRole admin = UserRole(
    id: 'admin',
    name: 'Administrator',
    permissions: ['receipts.*', 'users.*', 'settings.*'],
    priority: 100,
  );
}

/// Authentication credential for linking accounts
class AuthCredential {
  final AuthProvider provider;
  final String? accessToken;
  final String? idToken;
  final String? refreshToken;
  final Map<String, dynamic>? additionalData;
  
  const AuthCredential({
    required this.provider,
    this.accessToken,
    this.idToken,
    this.refreshToken,
    this.additionalData,
  });
}

/// Available authentication providers
enum AuthProvider {
  email,
  google,
  apple,
  anonymous,
  microsoft,
  github,
}

/// Multi-factor authentication methods
enum MfaMethod {
  sms,
  totp, // Time-based One-Time Password (Google Authenticator)
  email,
}

/// MFA setup information
class MfaSetup {
  final MfaMethod method;
  final String? secret; // For TOTP
  final String? qrCodeUrl; // For TOTP setup
  final String? phoneNumber; // For SMS
  final String? email; // For email MFA
  final List<String>? backupCodes;
  
  const MfaSetup({
    required this.method,
    this.secret,
    this.qrCodeUrl,
    this.phoneNumber,
    this.email,
    this.backupCodes,
  });
}