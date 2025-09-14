import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/core/models/receipt.dart';
import 'package:receipt_organizer/infrastructure/config/supabase_config.dart';
import 'package:receipt_organizer/features/auth/providers/auth_provider.dart';

// Provider for fetching receipts from Supabase
final receiptsProvider = FutureProvider<List<Receipt>>((ref) async {
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return [];
  }

  try {
    final response = await SupabaseConfig.client
        .from('receipts')
        .select('*')
        .eq('user_id', user.id)
        .order('receipt_date', ascending: false);

    final receipts = (response as List)
        .map((json) => _receiptFromJson(json))
        .toList();

    return receipts;
  } catch (e) {
    print('Error fetching receipts: $e');
    throw Exception('Failed to load receipts: $e');
  }
});

// Helper function to convert JSON to Receipt model
Receipt _receiptFromJson(Map<String, dynamic> json) {
  return Receipt(
    id: json['id'] as String,
    userId: json['user_id'] as String?,
    merchant: json['merchant'] as String?,
    receiptDate: json['receipt_date'] as String?,
    total: json['total'] != null ? (json['total'] as num).toDouble() : null,
    tax: json['tax'] != null ? (json['tax'] as num).toDouble() : null,
    category: json['category'] as String?,
    paymentMethod: json['payment_method'] as String?,
    notes: json['notes'] as String?,
    imageUrl: json['image_url'] as String?,
    ocrConfidence: json['ocr_confidence'] != null
        ? (json['ocr_confidence'] as num).toDouble()
        : null,
    status: json['status'] as String? ?? 'ready',
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : null,
    syncStatus: json['sync_status'] as String?,
    lastSyncAt: json['last_sync_at'] != null
        ? DateTime.parse(json['last_sync_at'] as String)
        : null,
  );
}

// Provider for creating a new receipt
final createReceiptProvider = Provider((ref) {
  return (Receipt receipt) async {
    final user = ref.read(currentUserProvider);

    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      final data = {
        'user_id': user.id,
        'merchant': receipt.merchant,
        'receipt_date': receipt.receiptDate,
        'total': receipt.total,
        'tax': receipt.tax,
        'category': receipt.category,
        'payment_method': receipt.paymentMethod,
        'notes': receipt.notes,
        'image_url': receipt.imageUrl,
        'ocr_confidence': receipt.ocrConfidence,
        'status': receipt.status,
      };

      final response = await SupabaseConfig.client
          .from('receipts')
          .insert(data)
          .select()
          .single();

      return _receiptFromJson(response);
    } catch (e) {
      print('Error creating receipt: $e');
      throw Exception('Failed to create receipt: $e');
    }
  };
});

// Provider for updating a receipt
final updateReceiptProvider = Provider((ref) {
  return (Receipt receipt) async {
    final user = ref.read(currentUserProvider);

    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      final data = {
        'merchant': receipt.merchant,
        'receipt_date': receipt.receiptDate,
        'total': receipt.total,
        'tax': receipt.tax,
        'category': receipt.category,
        'payment_method': receipt.paymentMethod,
        'notes': receipt.notes,
        'image_url': receipt.imageUrl,
        'ocr_confidence': receipt.ocrConfidence,
        'status': receipt.status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await SupabaseConfig.client
          .from('receipts')
          .update(data)
          .eq('id', receipt.id)
          .eq('user_id', user.id)
          .select()
          .single();

      // Invalidate the receipts list to refresh
      ref.invalidate(receiptsProvider);

      return _receiptFromJson(response);
    } catch (e) {
      print('Error updating receipt: $e');
      throw Exception('Failed to update receipt: $e');
    }
  };
});

// Provider for deleting a receipt
final deleteReceiptProvider = Provider((ref) {
  return (String receiptId) async {
    final user = ref.read(currentUserProvider);

    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      await SupabaseConfig.client
          .from('receipts')
          .delete()
          .eq('id', receiptId)
          .eq('user_id', user.id);

      // Invalidate the receipts list to refresh
      ref.invalidate(receiptsProvider);
    } catch (e) {
      print('Error deleting receipt: $e');
      throw Exception('Failed to delete receipt: $e');
    }
  };
});