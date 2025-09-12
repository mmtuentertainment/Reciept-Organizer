import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Supabase service wrapper for the Receipt Organizer app
class SupabaseService {
  static SupabaseService? _instance;
  
  SupabaseService._();
  
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }
  
  /// Get the Supabase client instance
  SupabaseClient get client => Supabase.instance.client;
  
  /// Check if user is authenticated
  bool get isAuthenticated => client.auth.currentUser != null;
  
  /// Get current user
  User? get currentUser => client.auth.currentUser;
  
  /// Get current session
  Session? get currentSession => client.auth.currentSession;
  
  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
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
  
  /// Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }
  
  /// Upload receipt to Supabase
  Future<Map<String, dynamic>> uploadReceipt({
    required String merchant,
    required DateTime date,
    required double total,
    double? tax,
    int? merchantConfidence,
    int? dateConfidence,
    int? totalConfidence,
    int? taxConfidence,
    String? imagePath,
    String? rawOcrText,
    String? notes,
    List<String>? tags,
    String? category,
  }) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final response = await client
          .from('receipts')
          .insert({
            'user_id': userId,
            'merchant': merchant,
            'date': date.toIso8601String(),
            'total': total,
            'tax': tax,
            'merchant_confidence': merchantConfidence,
            'date_confidence': dateConfidence,
            'total_confidence': totalConfidence,
            'tax_confidence': taxConfidence,
            'image_path': imagePath,
            'raw_ocr_text': rawOcrText,
            'notes': notes,
            'tags': tags,
            'category': category,
            'processing_status': 'completed',
            'ocr_engine': 'ml_kit',
          })
          .select()
          .single();
      
      return response;
    } catch (e) {
      debugPrint('Error uploading receipt to Supabase: $e');
      rethrow;
    }
  }
  
  /// Get receipts from Supabase
  Future<List<Map<String, dynamic>>> getReceipts({
    int? limit,
    int? offset,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Build the base query
      var queryBuilder = client
          .from('receipts')
          .select()
          .eq('user_id', userId)
          .isFilter('deleted_at', null);
      
      // Add date filters if provided
      if (startDate != null) {
        queryBuilder = queryBuilder.gte('date', startDate.toIso8601String());
      }
      
      if (endDate != null) {
        queryBuilder = queryBuilder.lte('date', endDate.toIso8601String());
      }
      
      // Add ordering, limit and offset
      var finalQuery = queryBuilder.order('date', ascending: false);
      
      if (offset != null && limit != null) {
        finalQuery = finalQuery.range(offset, offset + limit - 1);
      } else if (limit != null) {
        finalQuery = finalQuery.limit(limit);
      }
      
      final response = await finalQuery;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching receipts from Supabase: $e');
      rethrow;
    }
  }
  
  /// Subscribe to receipt changes
  RealtimeChannel subscribeToReceipts({
    required Function(PostgresChangePayload) onInsert,
    required Function(PostgresChangePayload) onUpdate,
    required Function(PostgresChangePayload) onDelete,
  }) {
    final userId = currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
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
  
  /// Unsubscribe from channel
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await channel.unsubscribe();
  }
}

/// Extension for easy access to Supabase in widgets
extension SupabaseExtension on BuildContext {
  SupabaseClient get supabase => SupabaseService.instance.client;
  User? get currentUser => SupabaseService.instance.currentUser;
  bool get isAuthenticated => SupabaseService.instance.isAuthenticated;
}