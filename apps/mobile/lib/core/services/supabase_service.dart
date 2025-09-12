import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for accessing the Supabase client instance
final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  try {
    return Supabase.instance.client;
  } catch (e) {
    // Supabase not initialized
    return null;
  }
});

/// Service class for Supabase operations
class SupabaseService {
  final SupabaseClient client;
  
  SupabaseService(this.client);
  
  /// Check if user is authenticated
  bool get isAuthenticated => client.auth.currentUser != null;
  
  /// Get current user
  User? get currentUser => client.auth.currentUser;
  
  /// Sign in with email and password
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }
  
  /// Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }
  
  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}

/// Provider for the Supabase service
final supabaseServiceProvider = Provider<SupabaseService?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return SupabaseService(client);
});