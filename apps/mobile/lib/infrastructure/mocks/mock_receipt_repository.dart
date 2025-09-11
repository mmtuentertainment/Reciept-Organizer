import 'dart:async';
import 'package:receipt_organizer/domain/interfaces/i_receipt_repository.dart';
import 'package:receipt_organizer/core/models/receipt.dart';
import 'package:receipt_organizer/core/models/result.dart';
import 'package:uuid/uuid.dart';

/// Mock implementation of IReceiptRepository for testing.
/// 
/// This implementation stores all data in memory and provides full
/// functionality without requiring a database or file system.
/// Thread-safe and supports concurrent operations.
class MockReceiptRepository implements IReceiptRepository {
  final Map<String, Receipt> _receipts = {};
  final Map<String, DateTime> _softDeleted = {};
  final _uuid = const Uuid();
  final _streamController = StreamController<List<Receipt>>.broadcast();
  
  // Configuration for testing scenarios
  bool shouldFailNextOperation = false;
  Duration? simulatedDelay;
  int? maxItemsLimit;
  
  // Statistics tracking for test assertions
  int createCallCount = 0;
  int readCallCount = 0;
  int updateCallCount = 0;
  int deleteCallCount = 0;
  
  MockReceiptRepository({
    this.simulatedDelay,
    this.maxItemsLimit,
  });
  
  @override
  Future<Result<Receipt>> create(Receipt receipt) async {
    createCallCount++;
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    // Generate ID if not provided
    final id = receipt.id.isEmpty ? _uuid.v4() : receipt.id;
    
    // Check for duplicate
    if (_receipts.containsKey(id)) {
      return Result.failure(
        AppError.duplicate(
          message: 'Receipt with ID $id already exists',
          code: 'DUPLICATE_ID',
        ),
      );
    }
    
    // Check storage limit
    if (maxItemsLimit != null && _receipts.length >= maxItemsLimit!) {
      return const Result.failure(
        AppError.storage(
          message: 'Storage limit exceeded',
          code: 'STORAGE_FULL',
        ),
      );
    }
    
    // Create with generated ID
    final newReceipt = receipt.copyWith(
      id: id,
      updatedAt: DateTime.now(),
    );
    
    _receipts[id] = newReceipt;
    _notifyListeners();
    
    return Result.success(newReceipt);
  }
  
  @override
  Future<Result<Receipt>> getById(String id) async {
    readCallCount++;
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    final receipt = _receipts[id];
    if (receipt == null || _softDeleted.containsKey(id)) {
      return Result.failure(
        AppError.notFound(
          message: 'Receipt not found',
          code: 'NOT_FOUND',
          metadata: {'id': id},
        ),
      );
    }
    
    return Result.success(receipt);
  }
  
  @override
  Future<Result<List<Receipt>>> getAll({
    int? limit,
    int? offset,
    bool excludeDeleted = true,
  }) async {
    readCallCount++;
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    var receipts = _receipts.values.where((r) {
      if (excludeDeleted && _softDeleted.containsKey(r.id)) {
        return false;
      }
      return true;
    }).toList();
    
    // Sort by updated at descending
    receipts.sort((a, b) => (b.updatedAt ?? b.createdAt).compareTo(a.updatedAt ?? a.createdAt));
    
    // Apply pagination
    final startIndex = offset ?? 0;
    final endIndex = limit != null ? startIndex + limit : receipts.length;
    
    if (startIndex < receipts.length) {
      receipts = receipts.sublist(
        startIndex,
        endIndex > receipts.length ? receipts.length : endIndex,
      );
    } else {
      receipts = [];
    }
    
    return Result.success(receipts);
  }
  
  @override
  Future<Result<List<Receipt>>> getByDateRange(
    DateTime start,
    DateTime end, {
    bool excludeDeleted = true,
  }) async {
    readCallCount++;
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    final receipts = _receipts.values.where((r) {
      if (excludeDeleted && _softDeleted.containsKey(r.id)) {
        return false;
      }
      
      final date = r.date;
      if (date == null) return false;
      
      return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
             date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
    
    // Sort by receipt date descending
    receipts.sort((a, b) {
      final aDate = a.date ?? DateTime.now();
      final bDate = b.date ?? DateTime.now();
      return bDate.compareTo(aDate);
    });
    
    return Result.success(receipts);
  }
  
  @override
  Future<Result<Receipt>> update(Receipt receipt) async {
    updateCallCount++;
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    if (!_receipts.containsKey(receipt.id)) {
      return Result.failure(
        AppError.notFound(
          message: 'Receipt not found',
          code: 'NOT_FOUND',
          metadata: {'id': receipt.id},
        ),
      );
    }
    
    final updated = receipt.copyWith(
      updatedAt: DateTime.now(),
    );
    
    _receipts[receipt.id] = updated;
    _notifyListeners();
    
    return Result.success(updated);
  }
  
  @override
  Future<Result<void>> delete(String id, {bool permanent = false}) async {
    deleteCallCount++;
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    if (!_receipts.containsKey(id)) {
      return Result.failure(
        AppError.notFound(
          message: 'Receipt not found',
          code: 'NOT_FOUND',
          metadata: {'id': id},
        ),
      );
    }
    
    if (permanent) {
      _receipts.remove(id);
      _softDeleted.remove(id);
    } else {
      _softDeleted[id] = DateTime.now();
    }
    
    _notifyListeners();
    return const Result.success(null);
  }
  
  @override
  Future<Result<void>> deleteMultiple(
    List<String> ids, {
    bool permanent = false,
  }) async {
    deleteCallCount += ids.length;
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    // Check all exist first (atomic operation)
    for (final id in ids) {
      if (!_receipts.containsKey(id)) {
        return Result.failure(
          AppError.notFound(
            message: 'One or more receipts not found',
            code: 'NOT_FOUND',
            metadata: {'failedId': id},
          ),
        );
      }
    }
    
    // Delete all
    for (final id in ids) {
      if (permanent) {
        _receipts.remove(id);
        _softDeleted.remove(id);
      } else {
        _softDeleted[id] = DateTime.now();
      }
    }
    
    _notifyListeners();
    return const Result.success(null);
  }
  
  @override
  Stream<List<Receipt>> watchAll() {
    // Emit current state immediately
    Timer.run(() {
      _notifyListeners();
    });
    return _streamController.stream;
  }
  
  @override
  Future<Result<List<Receipt>>> search(String query, {int? limit}) async {
    readCallCount++;
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    final lowerQuery = query.toLowerCase();
    var results = _receipts.values.where((r) {
      if (_softDeleted.containsKey(r.id)) return false;
      
      // Search in merchant name and amount
      final merchant = r.merchantName?.toLowerCase() ?? '';
      final amount = r.totalAmount?.toString() ?? '';
      
      return merchant.contains(lowerQuery) ||
             amount.contains(lowerQuery);
    }).toList();
    
    // Sort by relevance (simple: exact match first)
    results.sort((a, b) {
      final aMerchant = a.merchantName?.toLowerCase() ?? '';
      final bMerchant = b.merchantName?.toLowerCase() ?? '';
      
      if (aMerchant == lowerQuery) return -1;
      if (bMerchant == lowerQuery) return 1;
      if (aMerchant.startsWith(lowerQuery)) return -1;
      if (bMerchant.startsWith(lowerQuery)) return 1;
      
      return 0;
    });
    
    if (limit != null && results.length > limit) {
      results = results.sublist(0, limit);
    }
    
    return Result.success(results);
  }
  
  @override
  Future<Result<ReceiptStats>> getStatistics() async {
    readCallCount++;
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    final activeReceipts = _receipts.values
        .where((r) => !_softDeleted.containsKey(r.id))
        .toList();
    
    if (activeReceipts.isEmpty) {
      return const Result.success(
        ReceiptStats(
          totalCount: 0,
          totalAmount: 0,
          averageAmount: 0,
        ),
      );
    }
    
    // Calculate statistics
    double totalAmount = 0;
    DateTime? earliest;
    DateTime? latest;
    final merchantCounts = <String, int>{};
    final monthlyTotals = <String, double>{};
    
    for (final receipt in activeReceipts) {
      // Amount
      if (receipt.totalAmount != null) {
        totalAmount += receipt.totalAmount!;
      }
      
      // Dates
      if (receipt.date != null) {
        earliest ??= receipt.date;
        latest ??= receipt.date;
        
        if (receipt.date!.isBefore(earliest!)) {
          earliest = receipt.date;
        }
        if (receipt.date!.isAfter(latest!)) {
          latest = receipt.date;
        }
        
        // Monthly totals
        final monthKey = 
            '${receipt.date!.year}-${receipt.date!.month.toString().padLeft(2, '0')}';
        monthlyTotals[monthKey] = 
            (monthlyTotals[monthKey] ?? 0) + (receipt.totalAmount ?? 0);
      }
      
      // Merchants
      if (receipt.merchantName != null) {
        merchantCounts[receipt.merchantName!] = 
            (merchantCounts[receipt.merchantName!] ?? 0) + 1;
      }
    }
    
    // Sort merchants by count and take top 10
    final sortedMerchants = merchantCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topMerchants = Map.fromEntries(
      sortedMerchants.take(10),
    );
    
    return Result.success(
      ReceiptStats(
        totalCount: activeReceipts.length,
        totalAmount: totalAmount,
        averageAmount: totalAmount / activeReceipts.length,
        earliestDate: earliest,
        latestDate: latest,
        topMerchants: topMerchants,
        monthlyTotals: monthlyTotals,
      ),
    );
  }
  
  @override
  Future<Result<List<Receipt>>> getByBatchId(String batchId) async {
    readCallCount++;
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    final receipts = _receipts.values
        .where((r) => !_softDeleted.containsKey(r.id))
        .toList();
    
    return Result.success(receipts);
  }
  
  @override
  Future<Result<void>> restore(List<String> ids) async {
    updateCallCount += ids.length;
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    for (final id in ids) {
      _softDeleted.remove(id);
    }
    
    _notifyListeners();
    return const Result.success(null);
  }
  
  @override
  Future<Result<List<Receipt>>> getExpiredSoftDeletes(int daysOld) async {
    readCallCount++;
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    final cutoff = DateTime.now().subtract(Duration(days: daysOld));
    final expired = <Receipt>[];
    
    _softDeleted.forEach((id, deletedAt) {
      if (deletedAt.isBefore(cutoff)) {
        final receipt = _receipts[id];
        if (receipt != null) {
          expired.add(receipt);
        }
      }
    });
    
    return Result.success(expired);
  }
  
  @override
  Future<Result<int>> getCount({bool excludeDeleted = true}) async {
    readCallCount++;
    await _simulateDelay();
    
    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return const Result.failure(
        AppError.storage(message: 'Simulated storage failure'),
      );
    }
    
    if (excludeDeleted) {
      final activeCount = _receipts.values
          .where((r) => !_softDeleted.containsKey(r.id))
          .length;
      return Result.success(activeCount);
    }
    
    return Result.success(_receipts.length);
  }
  
  // Helper methods for testing
  
  /// Clear all data (useful for test setup/teardown)
  void clear() {
    _receipts.clear();
    _softDeleted.clear();
    createCallCount = 0;
    readCallCount = 0;
    updateCallCount = 0;
    deleteCallCount = 0;
    _notifyListeners();
  }
  
  /// Get all receipts including soft-deleted (for test assertions)
  Map<String, Receipt> getAllIncludingDeleted() => Map.from(_receipts);
  
  /// Get soft-deleted IDs (for test assertions)
  Set<String> getSoftDeletedIds() => _softDeleted.keys.toSet();
  
  /// Inject specific receipts (for test setup)
  void injectReceipts(List<Receipt> receipts) {
    for (final receipt in receipts) {
      _receipts[receipt.id] = receipt;
    }
    _notifyListeners();
  }
  
  /// Simulate network/storage delay
  Future<void> _simulateDelay() async {
    if (simulatedDelay != null) {
      await Future.delayed(simulatedDelay!);
    }
  }
  
  /// Notify stream listeners
  void _notifyListeners() {
    if (!_streamController.isClosed) {
      final activeReceipts = _receipts.values
          .where((r) => !_softDeleted.containsKey(r.id))
          .toList();
      
      _streamController.add(activeReceipts);
    }
  }
  
  /// Dispose resources
  void dispose() {
    _streamController.close();
  }
}