import '../models/receipt_model.dart';
import '../value_objects/receipt_id.dart';
import '../value_objects/category.dart';
import '../entities/receipt_status.dart';
import '../core/result.dart';
import '../core/failures.dart' as failures;

/// Domain repository interface for receipts
///
/// This interface uses ONLY domain models and value objects.
/// Data layer implementations handle conversion to/from data models.
abstract interface class IReceiptRepository {
  /// Create a new receipt
  Future<Result<ReceiptModel, failures.Failure>> create(ReceiptModel receipt);

  /// Update an existing receipt
  Future<Result<ReceiptModel, failures.Failure>> update(ReceiptModel receipt);

  /// Delete a receipt by ID
  Future<Result<void, failures.Failure>> delete(ReceiptId id);

  /// Delete multiple receipts
  Future<Result<void, failures.Failure>> deleteMultiple(List<ReceiptId> ids);

  /// Get a receipt by ID
  Future<Result<ReceiptModel, failures.Failure>> getById(ReceiptId id);

  /// Get all receipts
  Future<Result<List<ReceiptModel>, failures.Failure>> getAll();

  /// Get receipts with pagination
  Future<Result<ReceiptPage, failures.Failure>> getPaginated({
    required int page,
    required int pageSize,
    ReceiptSort? sort,
  });

  /// Search receipts
  Future<Result<List<ReceiptModel>, failures.Failure>> search(String query);

  /// Get receipts by status
  Future<Result<List<ReceiptModel>, failures.Failure>> getByStatus(ReceiptStatus status);

  /// Get receipts by category
  Future<Result<List<ReceiptModel>, failures.Failure>> getByCategory(Category category);

  /// Get receipts by date range
  Future<Result<List<ReceiptModel>, failures.Failure>> getByDateRange({
    required DateTime start,
    required DateTime end,
  });

  /// Get receipts by batch ID
  Future<Result<List<ReceiptModel>, failures.Failure>> getByBatchId(String batchId);

  /// Watch all receipts (reactive stream)
  Stream<Result<List<ReceiptModel>, failures.Failure>> watchAll();

  /// Watch a single receipt
  Stream<Result<ReceiptModel, failures.Failure>> watchById(ReceiptId id);

  /// Get receipt statistics
  Future<Result<ReceiptStatistics, failures.Failure>> getStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Export receipts
  Future<Result<ExportData, failures.Failure>> exportReceipts({
    required List<ReceiptId> ids,
    required ExportFormat format,
  });

  /// Batch create receipts
  Future<Result<List<ReceiptModel>, failures.Failure>> batchCreate(List<ReceiptModel> receipts);

  /// Mark receipts as reviewed
  Future<Result<void, failures.Failure>> markAsReviewed(List<ReceiptId> ids);

  /// Clear all data (for testing/reset)
  Future<Result<void, failures.Failure>> clearAll();
}

/// Pagination result
class ReceiptPage {
  final List<ReceiptModel> items;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  const ReceiptPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  bool get hasNext => page < totalPages - 1;
  bool get hasPrevious => page > 0;
}

/// Sort options for receipts
enum ReceiptSort {
  dateDesc('Date (Newest)', 'date', false),
  dateAsc('Date (Oldest)', 'date', true),
  amountDesc('Amount (High to Low)', 'amount', false),
  amountAsc('Amount (Low to High)', 'amount', true),
  merchantAsc('Merchant (A-Z)', 'merchant', true),
  merchantDesc('Merchant (Z-A)', 'merchant', false),
  statusAsc('Status', 'status', true);

  final String displayName;
  final String field;
  final bool ascending;

  const ReceiptSort(this.displayName, this.field, this.ascending);
}

/// Receipt statistics
class ReceiptStatistics {
  final int totalCount;
  final int processedCount;
  final int errorCount;
  final int pendingCount;
  final double totalAmount;
  final double averageAmount;
  final Map<Category, double> amountByCategory;
  final Map<Category, int> countByCategory;
  final Map<DateTime, double> amountByDay;

  const ReceiptStatistics({
    required this.totalCount,
    required this.processedCount,
    required this.errorCount,
    required this.pendingCount,
    required this.totalAmount,
    required this.averageAmount,
    required this.amountByCategory,
    required this.countByCategory,
    required this.amountByDay,
  });
}

/// Export format options
enum ExportFormat {
  csv('CSV', 'csv'),
  json('JSON', 'json'),
  pdf('PDF', 'pdf'),
  excel('Excel', 'xlsx');

  final String displayName;
  final String extension;

  const ExportFormat(this.displayName, this.extension);
}

/// Export data result
class ExportData {
  final String fileName;
  final String mimeType;
  final List<int> bytes;
  final int receiptCount;

  const ExportData({
    required this.fileName,
    required this.mimeType,
    required this.bytes,
    required this.receiptCount,
  });
}