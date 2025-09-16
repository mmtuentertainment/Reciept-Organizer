import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
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
  return Receipt.fromJson(json);
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
        'vendor_name': receipt.vendorName,
        'receipt_date': receipt.receiptDate?.toIso8601String()?.substring(0, 10),
        'total_amount': receipt.totalAmount,
        'tax_amount': receipt.taxAmount,
        'tip_amount': receipt.tipAmount,
        'currency': receipt.currency,
        'category_id': receipt.categoryId,
        'subcategory': receipt.subcategory,
        'payment_method': receipt.paymentMethod,
        'notes': receipt.notes,
        'image_url': receipt.imageUrl ?? receipt.imageUri,
        'ocr_confidence': receipt.ocrConfidence,
        'ocr_raw_text': receipt.ocrRawText,
        'is_processed': receipt.isProcessed,
        'needs_review': receipt.needsReview,
        'business_purpose': receipt.businessPurpose,
        'tags': receipt.tags,
        'status': receipt.status.name,
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
        'vendor_name': receipt.vendorName,
        'receipt_date': receipt.receiptDate?.toIso8601String()?.substring(0, 10),
        'total_amount': receipt.totalAmount,
        'tax_amount': receipt.taxAmount,
        'tip_amount': receipt.tipAmount,
        'currency': receipt.currency,
        'category_id': receipt.categoryId,
        'subcategory': receipt.subcategory,
        'payment_method': receipt.paymentMethod,
        'notes': receipt.notes,
        'image_url': receipt.imageUrl ?? receipt.imageUri,
        'ocr_confidence': receipt.ocrConfidence,
        'ocr_raw_text': receipt.ocrRawText,
        'is_processed': receipt.isProcessed,
        'needs_review': receipt.needsReview,
        'business_purpose': receipt.businessPurpose,
        'tags': receipt.tags,
        'status': receipt.status.name,
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