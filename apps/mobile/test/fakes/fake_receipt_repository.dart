import 'dart:async';
import 'package:receipt_organizer/core/repositories/interfaces/i_receipt_repository.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:uuid/uuid.dart';

/// Fake implementation of IReceiptRepository for testing
///
/// This provides an in-memory implementation that's fast and predictable for tests.
/// Supports configurable delays and error simulation for different test scenarios.
class FakeReceiptRepository implements IReceiptRepository {
  final Map<String, Receipt> _receipts = {};
  final _uuid = const Uuid();

  /// Configurable delay for simulating async operations
  Duration delay;

  /// Whether to simulate errors
  bool shouldThrowError = false;

  /// Error message to throw when shouldThrowError is true
  String errorMessage = 'Simulated repository error';

  /// Stream controller for receipt changes
  final _receiptStreamController = StreamController<List<Receipt>>.broadcast();

  /// Stream of receipt changes for reactive updates
  Stream<List<Receipt>> get receiptStream => _receiptStreamController.stream;

  FakeReceiptRepository({
    this.delay = Duration.zero,
    List<Receipt>? initialReceipts,
  }) {
    if (initialReceipts != null) {
      for (final receipt in initialReceipts) {
        _receipts[receipt.id ?? _uuid.v4()] = receipt;
      }
    }
  }

  /// Simulate async delay if configured
  Future<void> _simulateDelay() async {
    if (delay != Duration.zero) {
      await Future.delayed(delay);
    }
  }

  /// Check if should throw error
  void _checkError() {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
  }

  /// Notify listeners of changes
  void _notifyListeners() {
    _receiptStreamController.add(getAllReceiptsSync());
  }

  @override
  Future<List<Receipt>> getAllReceipts() async {
    await _simulateDelay();
    _checkError();
    return getAllReceiptsSync();
  }

  /// Synchronous version for immediate access in tests
  List<Receipt> getAllReceiptsSync() {
    return _receipts.values.toList()
      ..sort((a, b) => (b.capturedAt ?? DateTime.now())
          .compareTo(a.capturedAt ?? DateTime.now()));
  }

  @override
  Future<Receipt?> getReceiptById(String id) async {
    await _simulateDelay();
    _checkError();
    return _receipts[id];
  }

  @override
  Future<List<Receipt>> getReceiptsByBatchId(String batchId) async {
    await _simulateDelay();
    _checkError();
    return _receipts.values
        .where((r) => r.batchId == batchId)
        .toList();
  }

  @override
  Future<List<Receipt>> getReceiptsByDateRange(DateTime start, DateTime end) async {
    await _simulateDelay();
    _checkError();

    return _receipts.values.where((receipt) {
      final date = receipt.receiptDate ?? receipt.capturedAt;
      if (date == null) return false;

      return date.isAfter(start.subtract(const Duration(days: 1))) &&
             date.isBefore(end.add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => (b.receiptDate ?? b.capturedAt ?? DateTime.now())
          .compareTo(a.receiptDate ?? a.capturedAt ?? DateTime.now()));
  }

  @override
  Future<Receipt> createReceipt(Receipt receipt) async {
    await _simulateDelay();
    _checkError();

    final id = receipt.id ?? _uuid.v4();
    final newReceipt = receipt.copyWith(
      id: id,
      capturedAt: receipt.capturedAt ?? DateTime.now(),
      createdAt: receipt.createdAt ?? DateTime.now(),
    );

    _receipts[id] = newReceipt;
    _notifyListeners();
    return newReceipt;
  }

  @override
  Future<void> updateReceipt(Receipt receipt) async {
    await _simulateDelay();
    _checkError();

    if (receipt.id == null || !_receipts.containsKey(receipt.id)) {
      throw Exception('Receipt not found: ${receipt.id}');
    }

    _receipts[receipt.id!] = receipt.copyWith(
      updatedAt: DateTime.now(),
    );
    _notifyListeners();
  }

  @override
  Future<void> deleteReceipt(String id) async {
    await _simulateDelay();
    _checkError();

    if (!_receipts.containsKey(id)) {
      throw Exception('Receipt not found: $id');
    }

    _receipts.remove(id);
    _notifyListeners();
  }

  @override
  Future<void> deleteReceipts(List<String> ids) async {
    await _simulateDelay();
    _checkError();

    for (final id in ids) {
      _receipts.remove(id);
    }
    _notifyListeners();
  }

  @override
  Future<int> getReceiptCount() async {
    await _simulateDelay();
    _checkError();
    return _receipts.length;
  }

  @override
  Future<List<Receipt>> getReceiptsPaginated(int offset, int limit) async {
    await _simulateDelay();
    _checkError();

    final allReceipts = getAllReceiptsSync();
    final endIndex = (offset + limit).clamp(0, allReceipts.length);

    if (offset >= allReceipts.length) {
      return [];
    }

    return allReceipts.sublist(offset, endIndex);
  }

  @override
  Future<List<Receipt>> searchReceipts(String query) async {
    await _simulateDelay();
    _checkError();

    if (query.isEmpty) {
      return getAllReceiptsSync();
    }

    final lowercaseQuery = query.toLowerCase();
    return _receipts.values.where((receipt) {
      // Search in vendor name
      if (receipt.vendorName?.toLowerCase().contains(lowercaseQuery) == true) {
        return true;
      }

      // Search in merchant name (for compatibility)
      if (receipt.merchantName?.toLowerCase().contains(lowercaseQuery) == true) {
        return true;
      }

      // Search in notes
      if (receipt.notes?.toLowerCase().contains(lowercaseQuery) == true) {
        return true;
      }

      // Search in category
      if (receipt.categoryId?.toLowerCase().contains(lowercaseQuery) == true) {
        return true;
      }

      // Search in amount
      if (receipt.totalAmount != null) {
        final amountStr = receipt.totalAmount!.toStringAsFixed(2);
        if (amountStr.contains(lowercaseQuery)) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  // Additional test helper methods

  /// Clear all receipts
  void clear() {
    _receipts.clear();
    _notifyListeners();
  }

  /// Add multiple receipts at once
  Future<void> addAll(List<Receipt> receipts) async {
    for (final receipt in receipts) {
      await createReceipt(receipt);
    }
  }

  /// Get receipts by status
  Future<List<Receipt>> getReceiptsByStatus(ReceiptStatus status) async {
    await _simulateDelay();
    _checkError();

    return _receipts.values
        .where((r) => r.status == status)
        .toList();
  }

  /// Get receipts by category
  Future<List<Receipt>> getReceiptsByCategory(String categoryId) async {
    await _simulateDelay();
    _checkError();

    return _receipts.values
        .where((r) => r.categoryId == categoryId)
        .toList();
  }

  /// Configure to throw errors
  void setErrorMode(bool enabled, [String? message]) {
    shouldThrowError = enabled;
    if (message != null) {
      errorMessage = message;
    }
  }

  /// Configure delay
  void setDelay(Duration newDelay) {
    delay = newDelay;
  }

  /// Get total amount for all receipts
  double getTotalAmount() {
    return _receipts.values
        .fold(0.0, (sum, r) => sum + (r.totalAmount ?? 0.0));
  }

  /// Get receipts grouped by date
  Map<DateTime, List<Receipt>> getReceiptsGroupedByDate() {
    final grouped = <DateTime, List<Receipt>>{};

    for (final receipt in _receipts.values) {
      final date = receipt.receiptDate ?? receipt.capturedAt;
      if (date != null) {
        final dateOnly = DateTime(date.year, date.month, date.day);
        grouped.putIfAbsent(dateOnly, () => []).add(receipt);
      }
    }

    return grouped;
  }

  void dispose() {
    _receiptStreamController.close();
  }
}