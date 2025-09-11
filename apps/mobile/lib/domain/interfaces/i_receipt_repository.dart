import 'package:receipt_organizer/core/models/receipt.dart';
import 'package:receipt_organizer/core/models/result.dart';

/// Repository interface for receipt data access with cloud-ready abstraction.
/// 
/// This interface provides a complete abstraction over receipt storage,
/// supporting local (SQLite), cloud (Supabase), and hybrid implementations.
/// All methods return Result types for proper error handling.
abstract class IReceiptRepository {
  /// Create a new receipt.
  /// 
  /// [receipt] The receipt to create. ID will be generated if not provided.
  /// 
  /// Returns a Result containing the created receipt with generated ID,
  /// or an error if creation fails (e.g., duplicate ID, storage failure).
  /// 
  /// Example:
  /// ```dart
  /// final result = await repository.create(receipt);
  /// result.onSuccess((created) => print('Created: ${created.id}'))
  ///       .onFailure((error) => print('Error: ${error.message}'));
  /// ```
  Future<Result<Receipt>> create(Receipt receipt);
  
  /// Get a receipt by its unique identifier.
  /// 
  /// [id] The unique identifier of the receipt.
  /// 
  /// Returns a Result containing the receipt if found,
  /// or a NotFoundError if the receipt doesn't exist.
  Future<Result<Receipt>> getById(String id);
  
  /// Get all receipts with optional pagination.
  /// 
  /// [limit] Maximum number of receipts to return (null for all).
  /// [offset] Number of receipts to skip for pagination.
  /// [excludeDeleted] Whether to exclude soft-deleted receipts (default: true).
  /// 
  /// Returns a Result containing a list of receipts,
  /// or an error if the query fails.
  Future<Result<List<Receipt>>> getAll({
    int? limit,
    int? offset,
    bool excludeDeleted = true,
  });
  
  /// Get receipts within a date range.
  /// 
  /// [start] Start date (inclusive).
  /// [end] End date (inclusive).
  /// [excludeDeleted] Whether to exclude soft-deleted receipts (default: true).
  /// 
  /// Returns receipts ordered by receiptDate descending.
  Future<Result<List<Receipt>>> getByDateRange(
    DateTime start,
    DateTime end, {
    bool excludeDeleted = true,
  });
  
  /// Update an existing receipt.
  /// 
  /// [receipt] The receipt with updated data. Must have a valid ID.
  /// 
  /// Returns a Result containing the updated receipt,
  /// or an error if the update fails (e.g., receipt not found, validation error).
  Future<Result<Receipt>> update(Receipt receipt);
  
  /// Delete a single receipt by ID.
  /// 
  /// [id] The ID of the receipt to delete.
  /// [permanent] If true, permanently delete. If false, soft delete (default).
  /// 
  /// Returns a Result indicating success or failure.
  Future<Result<void>> delete(String id, {bool permanent = false});
  
  /// Delete multiple receipts by IDs.
  /// 
  /// [ids] List of receipt IDs to delete.
  /// [permanent] If true, permanently delete. If false, soft delete (default).
  /// 
  /// This operation is atomic - either all succeed or all fail.
  /// Returns a Result indicating success or failure.
  Future<Result<void>> deleteMultiple(List<String> ids, {bool permanent = false});
  
  /// Watch all receipts for real-time updates.
  /// 
  /// Returns a stream that emits the current list of receipts
  /// whenever changes occur (create, update, delete).
  /// 
  /// The stream will emit errors if the subscription fails.
  /// Remember to cancel the subscription when done.
  Stream<List<Receipt>> watchAll();
  
  /// Search receipts by query string.
  /// 
  /// [query] Search query (searches merchant names, amounts, notes).
  /// [limit] Maximum number of results.
  /// 
  /// Returns receipts ranked by relevance.
  Future<Result<List<Receipt>>> search(String query, {int? limit});
  
  /// Get statistics about stored receipts.
  /// 
  /// Returns aggregated statistics including:
  /// - Total count
  /// - Total amount
  /// - Date range
  /// - Top merchants
  Future<Result<ReceiptStats>> getStatistics();
  
  /// Get receipts by batch ID.
  /// 
  /// [batchId] The batch identifier.
  /// 
  /// Returns all receipts from the specified batch.
  Future<Result<List<Receipt>>> getByBatchId(String batchId);
  
  /// Restore soft-deleted receipts.
  /// 
  /// [ids] List of receipt IDs to restore.
  /// 
  /// Returns a Result indicating success or failure.
  Future<Result<void>> restore(List<String> ids);
  
  /// Get soft-deleted receipts older than specified days.
  /// 
  /// [daysOld] Number of days since deletion.
  /// 
  /// Used for automatic cleanup of old soft-deleted items.
  Future<Result<List<Receipt>>> getExpiredSoftDeletes(int daysOld);
  
  /// Get count of receipts.
  /// 
  /// [excludeDeleted] Whether to exclude soft-deleted receipts.
  /// 
  /// Returns the total count of receipts.
  Future<Result<int>> getCount({bool excludeDeleted = true});
}

/// Statistics about stored receipts
class ReceiptStats {
  final int totalCount;
  final double totalAmount;
  final double averageAmount;
  final DateTime? earliestDate;
  final DateTime? latestDate;
  final Map<String, int> topMerchants; // merchant -> count
  final Map<String, double> monthlyTotals; // YYYY-MM -> total
  
  const ReceiptStats({
    required this.totalCount,
    required this.totalAmount,
    required this.averageAmount,
    this.earliestDate,
    this.latestDate,
    this.topMerchants = const {},
    this.monthlyTotals = const {},
  });
}