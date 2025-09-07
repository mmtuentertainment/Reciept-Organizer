import 'package:receipt_organizer/data/models/receipt.dart';

/// Interface for receipt data access
abstract class IReceiptRepository {
  /// Get all receipts
  Future<List<Receipt>> getAllReceipts();
  
  /// Get receipt by ID
  Future<Receipt?> getReceiptById(String id);
  
  /// Get receipts by batch ID
  Future<List<Receipt>> getReceiptsByBatchId(String batchId);
  
  /// Get receipts within a date range
  /// 
  /// [start] and [end] are inclusive dates
  /// Returns receipts ordered by receiptDate descending
  Future<List<Receipt>> getReceiptsByDateRange(DateTime start, DateTime end);
  
  /// Create a new receipt
  Future<Receipt> createReceipt(Receipt receipt);
  
  /// Update an existing receipt
  Future<void> updateReceipt(Receipt receipt);
  
  /// Delete a receipt
  Future<void> deleteReceipt(String id);
  
  /// Delete multiple receipts
  Future<void> deleteReceipts(List<String> ids);
  
  /// Get receipt count
  Future<int> getReceiptCount();
  
  /// Get receipts paginated
  Future<List<Receipt>> getReceiptsPaginated(int offset, int limit);
}