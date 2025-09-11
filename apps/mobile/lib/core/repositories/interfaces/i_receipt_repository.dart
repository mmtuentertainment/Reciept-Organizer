import 'package:receipt_organizer/core/models/receipt.dart';
import 'package:receipt_organizer/core/models/audit_log.dart';

/// Interface for receipt data access
abstract class IReceiptRepository {
  /// Get all receipts (excludes soft deleted by default)
  Future<List<Receipt>> getAllReceipts({bool excludeDeleted = true});
  
  /// Get receipt by ID
  Future<Receipt?> getReceiptById(String id);
  
  /// Get receipts by batch ID
  Future<List<Receipt>> getReceiptsByBatchId(String batchId);
  
  /// Get receipts within a date range
  /// 
  /// [start] and [end] are inclusive dates
  /// Returns receipts ordered by receiptDate descending
  /// [excludeDeleted] filters out soft deleted receipts (default true)
  Future<List<Receipt>> getReceiptsByDateRange(
    DateTime start, 
    DateTime end,
    {bool excludeDeleted = true}
  );
  
  /// Get receipts by user ID (for authorization)
  Future<List<Receipt>> getReceiptsByUserId(
    String userId,
    {bool excludeDeleted = true}
  );
  
  /// Create a new receipt
  Future<Receipt> createReceipt(Receipt receipt);
  
  /// Update an existing receipt
  Future<void> updateReceipt(Receipt receipt);
  
  /// Soft delete receipts (sets deletedAt timestamp)
  Future<void> softDelete(List<String> ids, String userId);
  
  /// Restore soft deleted receipts (clears deletedAt)
  Future<void> restore(List<String> ids, String userId);
  
  /// Permanently delete receipts (removes from database)
  Future<void> permanentDelete(List<String> ids, String userId);
  
  /// Get soft deleted receipts older than specified days
  Future<List<Receipt>> getExpiredSoftDeletes(int daysOld);
  
  /// Delete a receipt (deprecated - use softDelete)
  @Deprecated('Use softDelete instead')
  Future<void> deleteReceipt(String id);
  
  /// Delete multiple receipts (deprecated - use softDelete)
  @Deprecated('Use softDelete instead')
  Future<void> deleteReceipts(List<String> ids);
  
  /// Get receipt count
  Future<int> getReceiptCount({bool excludeDeleted = true});
  
  /// Get receipts paginated
  Future<List<Receipt>> getReceiptsPaginated(
    int offset, 
    int limit,
    {bool excludeDeleted = true}
  );
  
  /// Log audit event
  Future<void> logAudit(AuditLog auditLog);
  
  /// Get audit logs for a user
  Future<List<AuditLog>> getAuditLogs(String userId, {int? limit});
}