import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:receipt_organizer/core/services/supabase_service.dart';
import 'package:flutter/foundation.dart';

/// Auth state management
class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseService _supabaseService;
  
  AuthNotifier(this._supabaseService) : super(const AuthState()) {
    _initializeAuth();
  }
  
  /// Initialize authentication state
  Future<void> _initializeAuth() async {
    try {
      final session = _supabaseService.currentSession;
      final user = _supabaseService.currentUser;
      
      if (session != null && user != null) {
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          session: session,
          isLoading: false,
        );
        
        // Setup auth state listener
        _supabaseService.client.auth.onAuthStateChange.listen((data) {
          final event = data.event;
          final session = data.session;
          
          switch (event) {
            case AuthChangeEvent.signedIn:
              state = state.copyWith(
                isAuthenticated: true,
                user: session?.user,
                session: session,
              );
              break;
            case AuthChangeEvent.signedOut:
              state = const AuthState();
              break;
            case AuthChangeEvent.tokenRefreshed:
              state = state.copyWith(
                session: session,
              );
              break;
            case AuthChangeEvent.userUpdated:
              state = state.copyWith(
                user: session?.user,
              );
              break;
            default:
              break;
          }
        });
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _supabaseService.signInWithEmail(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        state = state.copyWith(
          isAuthenticated: true,
          user: response.user,
          session: response.session,
          isLoading: false,
        );
      } else {
        throw Exception('Sign in failed - no user returned');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
  
  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _supabaseService.signUpWithEmail(
        email: email,
        password: password,
        metadata: {
          'full_name': name,
          'display_name': name.split(' ').first,
        },
      );
      
      if (response.user != null) {
        // Update user profile
        await _createUserProfile(response.user!.id, name, email);
        
        state = state.copyWith(
          isLoading: false,
          requiresEmailVerification: true,
        );
      } else {
        throw Exception('Sign up failed - no user returned');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
  
  /// Create user profile in database
  Future<void> _createUserProfile(String userId, String name, String email) async {
    try {
      await _supabaseService.client
          .from('user_profiles')
          .upsert({
            'id': userId,
            'full_name': name,
            'email': email,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      // Non-critical error, continue
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _supabaseService.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
  
  /// Reset password
  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _supabaseService.client.auth.resetPasswordForEmail(email);
      state = state.copyWith(
        isLoading: false,
        passwordResetSent: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
  
  /// Update user profile
  Future<void> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    if (!state.isAuthenticated || state.user == null) {
      throw Exception('User not authenticated');
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['full_name'] = name;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      
      if (updates.isNotEmpty) {
        updates['updated_at'] = DateTime.now().toIso8601String();
        
        await _supabaseService.client
            .from('user_profiles')
            .update(updates)
            .eq('id', state.user!.id);
        
        // Update auth metadata
        await _supabaseService.client.auth.updateUser(
          UserAttributes(
            data: updates,
          ),
        );
      }
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}

/// Authentication state
@immutable
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final User? user;
  final Session? session;
  final String? error;
  final bool requiresEmailVerification;
  final bool passwordResetSent;
  
  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = true,
    this.user,
    this.session,
    this.error,
    this.requiresEmailVerification = false,
    this.passwordResetSent = false,
  });
  
  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    User? user,
    Session? session,
    String? error,
    bool? requiresEmailVerification,
    bool? passwordResetSent,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      session: session ?? this.session,
      error: error ?? this.error,
      requiresEmailVerification: requiresEmailVerification ?? this.requiresEmailVerification,
      passwordResetSent: passwordResetSent ?? this.passwordResetSent,
    );
  }
}

/// Provider for Supabase service
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});

/// Provider for authentication
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AuthNotifier(supabaseService);
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Provider for current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});