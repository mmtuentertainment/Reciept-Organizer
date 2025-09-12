import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase client singleton for the Receipt Organizer app
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;
  
  SupabaseService._();
  
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }
  
  /// Initialize Supabase client with environment configuration
  static Future<void> initialize() async {
    try {
      // Load environment variables
      await dotenv.load(fileName: '.env.local');
      
      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
      
      if (supabaseUrl == null || supabaseAnonKey == null) {
        throw Exception('Supabase configuration missing in .env.local');
      }
      
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
          autoRefreshToken: true,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          eventsPerSecond: 10,
        ),
        storageOptions: const StorageClientOptions(
          retryAttempts: 3,
        ),
      );
      
      _client = Supabase.instance.client;
      
      // Set up auth state listener
      _client!.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;
        
        if (kDebugMode) {
          print('Auth event: $event');
        }
        
        switch (event) {
          case AuthChangeEvent.signedIn:
            _handleSignIn(session);
            break;
          case AuthChangeEvent.signedOut:
            _handleSignOut();
            break;
          case AuthChangeEvent.tokenRefreshed:
            _handleTokenRefresh(session);
            break;
          case AuthChangeEvent.userUpdated:
            _handleUserUpdate(session);
            break;
          default:
            break;
        }
      });
      
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize Supabase: $e');
      }
      rethrow;
    }
  }
  
  /// Get the Supabase client instance
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase client not initialized. Call initialize() first.');
    }
    return _client!;
  }
  
  /// Check if user is authenticated
  static bool get isAuthenticated => _client?.auth.currentUser != null;
  
  /// Get current user
  static User? get currentUser => _client?.auth.currentUser;
  
  /// Get current session
  static Session? get currentSession => _client?.auth.currentSession;
  
  // Auth event handlers
  static void _handleSignIn(Session? session) {
    if (session != null) {
      // Create or update user profile
      _createOrUpdateUserProfile(session.user);
    }
  }
  
  static void _handleSignOut() {
    // Clean up local data if needed
  }
  
  static void _handleTokenRefresh(Session? session) {
    // Token refreshed automatically
  }
  
  static void _handleUserUpdate(Session? session) {
    if (session != null) {
      _createOrUpdateUserProfile(session.user);
    }
  }
  
  static Future<void> _createOrUpdateUserProfile(User user) async {
    try {
      await _client!.from('user_profiles').upsert({
        'id': user.id,
        'email': user.email,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update user profile: $e');
      }
    }
  }
  
  /// Sign in with email and password
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  /// Sign up with email and password
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: metadata,
    );
  }
  
  /// Sign in with OAuth provider (Google, Apple)
  static Future<bool> signInWithOAuth(OAuthProvider provider) async {
    return await client.auth.signInWithOAuth(
      provider,
      redirectTo: kIsWeb ? null : 'io.supabase.receiptorganizer://login-callback/',
    );
  }
  
  /// Sign out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }
  
  /// Reset password
  static Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(
      email,
      redirectTo: kIsWeb ? null : 'io.supabase.receiptorganizer://reset-callback/',
    );
  }
  
  /// Upload receipt image to storage
  static Future<String> uploadReceiptImage({
    required String userId,
    required String fileName,
    required Uint8List imageData,
  }) async {
    final path = '$userId/receipts/$fileName';
    
    final response = await client.storage
        .from('receipts')
        .uploadBinary(path, imageData);
    
    return response;
  }
  
  /// Upload thumbnail to storage
  static Future<String> uploadThumbnail({
    required String userId,
    required String fileName,
    required Uint8List thumbnailData,
  }) async {
    final path = '$userId/thumbnails/$fileName';
    
    final response = await client.storage
        .from('thumbnails')
        .uploadBinary(path, thumbnailData);
    
    return response;
  }
  
  /// Get signed URL for private file
  static Future<String> getSignedUrl({
    required String bucket,
    required String path,
    int expiresIn = 3600,
  }) async {
    final response = await client.storage
        .from(bucket)
        .createSignedUrl(path, expiresIn);
    
    return response;
  }
  
  /// Delete receipt image from storage
  static Future<void> deleteReceiptImage(String path) async {
    await client.storage.from('receipts').remove([path]);
  }
  
  /// Delete thumbnail from storage
  static Future<void> deleteThumbnail(String path) async {
    await client.storage.from('thumbnails').remove([path]);
  }
  
  /// Set up realtime subscription for receipts
  static RealtimeChannel subscribeToReceipts({
    required String userId,
    required Function(PostgresChangePayload) onInsert,
    required Function(PostgresChangePayload) onUpdate,
    required Function(PostgresChangePayload) onDelete,
  }) {
    return client
        .channel('receipts_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'receipts',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: onInsert,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'receipts',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: onUpdate,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'receipts',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: onDelete,
        )
        .subscribe();
  }
  
  /// Unsubscribe from realtime channel
  static Future<void> unsubscribe(RealtimeChannel channel) async {
    await channel.unsubscribe();
  }
  
  /// Dispose of Supabase client
  static Future<void> dispose() async {
    await _client?.dispose();
    _client = null;
    _instance = null;
  }
}

/// Extension methods for easier Supabase access
extension SupabaseExtension on BuildContext {
  SupabaseClient get supabase => SupabaseService.client;
  User? get currentUser => SupabaseService.currentUser;
  bool get isAuthenticated => SupabaseService.isAuthenticated;
}