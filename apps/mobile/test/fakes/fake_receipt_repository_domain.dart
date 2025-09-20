import 'dart:async';
import 'package:receipt_organizer/domain/repositories/i_receipt_repository.dart';
import 'package:receipt_organizer/domain/models/receipt_model.dart';
import 'package:receipt_organizer/domain/value_objects/receipt_id.dart';
import 'package:receipt_organizer/domain/value_objects/category.dart';
import 'package:receipt_organizer/domain/value_objects/money.dart';
import 'package:receipt_organizer/domain/entities/receipt_status.dart';
import 'package:receipt_organizer/domain/core/result.dart';
import 'package:receipt_organizer/domain/core/failures.dart' as failures;

/// Fake implementation of IReceiptRepository for testing
///
/// Uses the domain model directly - no data layer concerns.
/// Fast, predictable, and configurable for different test scenarios.
class FakeReceiptRepositoryDomain implements IReceiptRepository {
  final Map<ReceiptId, ReceiptModel> _store = {};
  final _streamController = StreamController<List<ReceiptModel>>.broadcast();

  /// Configurable delay for simulating async operations
  Duration delay;

  /// Whether to simulate failures
  bool shouldFail = false;
  failures.Failure? nextFailure;

  FakeReceiptRepositoryDomain({
    this.delay = Duration.zero,
    List<ReceiptModel>? initialReceipts,
  }) {
    if (initialReceipts != null) {
      for (final receipt in initialReceipts) {
        _store[receipt.id] = receipt;
      }
    }
  }

  /// Simulate async delay
  Future<void> _simulateDelay() async {
    if (delay != Duration.zero) {
      await Future.delayed(delay);
    }
  }

  /// Check if should fail
  Result<T, failures.Failure> _checkFailure<T>(T value) {
    if (shouldFail || nextFailure != null) {
      final failure = nextFailure ?? const failures.Failure.unexpected(
        message: 'Simulated failure',
      );
      nextFailure = null; // Reset after use
      return Result.failure(failure);
    }
    return Result.success(value);
  }

  /// Notify stream listeners
  void _notifyListeners() {
    final receipts = _store.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _streamController.add(receipts);
  }

  @override
  Future<Result<ReceiptModel, failures.Failure>> create(ReceiptModel receipt) async {
    await _simulateDelay();

    if (shouldFail || nextFailure != null) {
      return _checkFailure(receipt);
    }

    // Ensure ID is set
    final toStore = receipt.copyWith(
      updatedAt: DateTime.now(),
    );

    _store[toStore.id] = toStore;
    _notifyListeners();

    return Result.success(toStore);
  }

  @override
  Future<Result<ReceiptModel, failures.Failure>> update(ReceiptModel receipt) async {
    await _simulateDelay();

    if (shouldFail || nextFailure != null) {
      return _checkFailure(receipt);
    }

    if (!_store.containsKey(receipt.id)) {
      return Result.failure(failures.Failure.notFound(
        message: 'Receipt not found',
        resourceId: receipt.id.value,
        resourceType: 'Receipt',
      ));
    }

    final updated = receipt.copyWith(
      updatedAt: DateTime.now(),
    );

    _store[receipt.id] = updated;
    _notifyListeners();

    return Result.success(updated);
  }

  @override
  Future<Result<void, failures.Failure>> delete(ReceiptId id) async {
    await _simulateDelay();

    if (shouldFail || nextFailure != null) {
      return _checkFailure(null);
    }

    if (!_store.containsKey(id)) {
      return Result.failure(failures.Failure.notFound(
        message: 'Receipt not found',
        resourceId: id.value,
        resourceType: 'Receipt',
      ));
    }

    _store.remove(id);
    _notifyListeners();

    return const Result.success(null);
  }

  @override
  Future<Result<void, failures.Failure>> deleteMultiple(List<ReceiptId> ids) async {
    await _simulateDelay();

    if (shouldFail || nextFailure != null) {
      return _checkFailure(null);
    }

    for (final id in ids) {
      _store.remove(id);
    }

    _notifyListeners();
    return const Result.success(null);
  }

  @override
  Future<Result<ReceiptModel, failures.Failure>> getById(ReceiptId id) async {
    await _simulateDelay();

    if (shouldFail || nextFailure != null) {
      return _checkFailure(_store[id]!);
    }

    final receipt = _store[id];
    if (receipt == null) {
      return Result.failure(failures.Failure.notFound(
        message: 'Receipt not found',
        resourceId: id.value,
        resourceType: 'Receipt',
      ));
    }

    return Result.success(receipt);
  }

  @override
  Future<Result<List<ReceiptModel>, failures.Failure>> getAll() async {
    await _simulateDelay();

    if (shouldFail || nextFailure != null) {
      return _checkFailure([]);
    }

    final receipts = _store.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Result.success(receipts);
  }

  @override
  Future<Result<ReceiptPage, failures.Failure>> getPaginated({
    required int page,
    required int pageSize,
    ReceiptSort? sort,
  }) async {
    await _simulateDelay();

    if (shouldFail || nextFailure != null) {
      return _checkFailure(ReceiptPage(
        items: [],
        page: 0,
        pageSize: pageSize,
        totalItems: 0,
        totalPages: 0,
      ));
    }

    var receipts = _store.values.toList();

    // Apply sorting
    switch (sort) {
      case ReceiptSort.dateDesc:
        receipts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ReceiptSort.dateAsc:
        receipts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case ReceiptSort.amountDesc:
        receipts.sort((a, b) =>
          (b.totalAmount?.amount ?? 0).compareTo(a.totalAmount?.amount ?? 0));
        break;
      case ReceiptSort.amountAsc:
        receipts.sort((a, b) =>
          (a.totalAmount?.amount ?? 0).compareTo(b.totalAmount?.amount ?? 0));
        break;
      case ReceiptSort.merchantAsc:
        receipts.sort((a, b) =>
          (a.merchant ?? '').compareTo(b.merchant ?? ''));
        break;
      case ReceiptSort.merchantDesc:
        receipts.sort((a, b) =>
          (b.merchant ?? '').compareTo(a.merchant ?? ''));
        break;
      case ReceiptSort.statusAsc:
        receipts.sort((a, b) =>
          a.status.index.compareTo(b.status.index));
        break;
      default:
        receipts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    // Calculate pagination
    final totalItems = receipts.length;
    final totalPages = (totalItems / pageSize).ceil();
    final startIndex = page * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, totalItems);

    final pageItems = startIndex < totalItems
      ? receipts.sublist(startIndex, endIndex)
      : <ReceiptModel>[];

    return Result.success(ReceiptPage(
      items: pageItems,
      page: page,
      pageSize: pageSize,
      totalItems: totalItems,
      totalPages: totalPages,
    ));
  }

  @override
  Future<Result<List<ReceiptModel>, failures.Failure>> search(String query) async {
    await _simulateDelay();

    if (shouldFail || nextFailure != null) {
      return _checkFailure([]);
    }

    if (query.isEmpty) {
      return getAll();
    }

    final lowercaseQuery = query.toLowerCase();
    final results = _store.values.where((receipt) {
      // Search in merchant name
      if (receipt.merchant?.toLowerCase().contains(lowercaseQuery) == true) {
        return true;
      }

      // Search in notes
      if (receipt.notes?.toLowerCase().contains(lowercaseQuery) == true) {
        return true;
      }

      // Search in amount
      if (receipt.totalAmount != null) {
        final amountStr = receipt.totalAmount!.displayAmount;
        if (amountStr.contains(query)) {
          return true;
        }
      }

      // Search in tags
      if (receipt.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))) {
        return true;
      }

      return false;
    }).toList();

    return Result.success(results);
  }

  @override
  Future<Result<List<ReceiptModel>, failures.Failure>> getByStatus(
    ReceiptStatus status,
  ) async {
    await _simulateDelay();

    if (shouldFail || nextFailure != null) {
      return _checkFailure([]);
    }

    final results = _store.values
      .where((r) => r.status == status)
      .toList();

    return Result.success(results);
  }

  @override
  Future<Result<List<ReceiptModel>, failures.Failure>> getByCategory(
    Category category,
  ) async {
    await _simulateDelay();

    if (shouldFail || nextFailure != null) {
      return _checkFailure([]);
    }

    final results = _store.values
      .where((r) => r.category == category)
      .toList();

    return Result.success(results);
  }

  @override
  Future<Result<List<ReceiptModel>, failures.Failure>> getByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    await _simulateDelay();

    if (shouldFail || nextFailure != null) {
      return _checkFailure([]);
    }

    final results = _store.values.where((receipt) {
      final date = receipt.purchaseDate ?? receipt.createdAt;
      return date.isAfter(start.subtract(const Duration(days: 1))) &&
             date.isBefore(end.add(const Duration(days: 1)));
    }).toList();

    return Result.success(results);
  }

  @override
  Future<Result<List<ReceiptModel>, failures.Failure>> getByBatchId(
    String batchId,
  ) async {
    await _simulateDelay();

    if (shouldFail || nextFailure != null) {
      return _checkFailure([]);
    }

    final results = _store.values
      .where((r) => r.batchId == batchId)
      .toList();

    return Result.success(results);
  }

  @override
  Stream<Result<List<ReceiptModel>, failures.Failure>> watchAll() {
    // Create a stream that emits the current state immediately, then listens to changes
    return Stream.multi((controller) {
      // Emit current state immediately
      final currentReceipts = _store.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (shouldFail || nextFailure != null) {
        controller.add(_checkFailure(currentReceipts));
      } else {
        controller.add(Result.success(currentReceipts));
      }

      // Listen to future changes
      final subscription = _streamController.stream.listen(
        (receipts) {
          if (shouldFail || nextFailure != null) {
            controller.add(_checkFailure(receipts));
          } else {
            controller.add(Result.success(receipts));
          }
        },
        onDone: controller.close,
        onError: controller.addError,
      );

      // Clean up subscription when stream is cancelled
      controller.onCancel = () {
        subscription.cancel();
      };
    });
  }

  @override
  Stream<Result<ReceiptModel, failures.Failure>> watchById(ReceiptId id) {
    // Create a stream that emits the current state immediately, then listens to changes
    return Stream.multi((controller) {
      // Emit current state immediately
      final receipt = _store[id];
      if (receipt == null) {
        controller.add(Result.failure(failures.Failure.notFound(
          message: 'Receipt not found',
          resourceId: id.value,
          resourceType: 'Receipt',
        )));
      } else if (shouldFail || nextFailure != null) {
        controller.add(_checkFailure(receipt));
      } else {
        controller.add(Result.success(receipt));
      }

      // Listen to future changes
      final subscription = _streamController.stream.listen(
        (receipts) {
          final updatedReceipt = _store[id];
          if (updatedReceipt == null) {
            controller.add(Result.failure(failures.Failure.notFound(
              message: 'Receipt not found',
              resourceId: id.value,
              resourceType: 'Receipt',
            )));
          } else if (shouldFail || nextFailure != null) {
            controller.add(_checkFailure(updatedReceipt));
          } else {
            controller.add(Result.success(updatedReceipt));
          }
        },
        onDone: controller.close,
        onError: controller.addError,
      );

      // Clean up subscription when stream is cancelled
      controller.onCancel = () {
        subscription.cancel();
      };
    });
  }

  @override
  Future<Result<ReceiptStatistics, failures.Failure>> getStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _simulateDelay();

    if (shouldFail || nextFailure != null) {
      return _checkFailure(ReceiptStatistics(
        totalCount: 0,
        processedCount: 0,
        errorCount: 0,
        pendingCount: 0,
        totalAmount: 0,
        averageAmount: 0,
        amountByCategory: {},
        countByCategory: {},
        amountByDay: {},
      ));
    }

    var receipts = _store.values.toList();

    // Filter by date range if provided
    if (startDate != null || endDate != null) {
      receipts = receipts.where((r) {
        final date = r.purchaseDate ?? r.createdAt;
        if (startDate != null && date.isBefore(startDate)) return false;
        if (endDate != null && date.isAfter(endDate)) return false;
        return true;
      }).toList();
    }

    // Calculate statistics
    final processedReceipts = receipts.where((r) => r.status == ReceiptStatus.processed);
    final totalAmount = processedReceipts.fold<double>(
      0,
      (sum, r) => sum + (r.totalAmount?.amount ?? 0),
    );

    // Group by category
    final amountByCategory = <Category, double>{};
    final countByCategory = <Category, int>{};

    for (final receipt in processedReceipts) {
      if (receipt.category != null && receipt.totalAmount != null) {
        amountByCategory.update(
          receipt.category!,
          (value) => value + receipt.totalAmount!.amount,
          ifAbsent: () => receipt.totalAmount!.amount,
        );
        countByCategory.update(
          receipt.category!,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }

    // Group by day
    final amountByDay = <DateTime, double>{};
    for (final receipt in processedReceipts) {
      final date = receipt.purchaseDate ?? receipt.createdAt;
      final dayOnly = DateTime(date.year, date.month, date.day);

      if (receipt.totalAmount != null) {
        amountByDay.update(
          dayOnly,
          (value) => value + receipt.totalAmount!.amount,
          ifAbsent: () => receipt.totalAmount!.amount,
        );
      }
    }

    return Result.success(ReceiptStatistics(
      totalCount: receipts.length,
      processedCount: receipts.where((r) => r.status == ReceiptStatus.processed).length,
      errorCount: receipts.where((r) => r.status == ReceiptStatus.error).length,
      pendingCount: receipts.where((r) => r.status == ReceiptStatus.pending).length,
      totalAmount: totalAmount,
      averageAmount: processedReceipts.isEmpty ? 0 : totalAmount / processedReceipts.length,
      amountByCategory: amountByCategory,
      countByCategory: countByCategory,
      amountByDay: amountByDay,
    ));
  }

  @override
  Future<Result<ExportData, failures.Failure>> exportReceipts({
    required List<ReceiptId> ids,
    required ExportFormat format,
  }) async {
    await _simulateDelay();

    if (shouldFail || nextFailure != null) {
      return _checkFailure(ExportData(
        fileName: '',
        mimeType: '',
        bytes: [],
        receiptCount: 0,
      ));
    }

    // Filter receipts by IDs
    final receipts = ids
      .map((id) => _store[id])
      .whereType<ReceiptModel>()
      .toList();

    // Simulate export (in real impl, would generate actual file)
    final fileName = 'receipts_${DateTime.now().millisecondsSinceEpoch}.${format.extension}';
    final mimeType = switch (format) {
      ExportFormat.csv => 'text/csv',
      ExportFormat.json => 'application/json',
      ExportFormat.pdf => 'application/pdf',
      ExportFormat.excel => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    };

    // Simulated file content
    final bytes = 'Simulated export data'.codeUnits;

    return Result.success(ExportData(
      fileName: fileName,
      mimeType: mimeType,
      bytes: bytes,
      receiptCount: receipts.length,
    ));
  }

  @override
  Future<Result<List<ReceiptModel>, failures.Failure>> batchCreate(
    List<ReceiptModel> receipts,
  ) async {
    await _simulateDelay();

    if (shouldFail || nextFailure != null) {
      return _checkFailure([]);
    }

    final created = <ReceiptModel>[];
    for (final receipt in receipts) {
      final toStore = receipt.copyWith(
        updatedAt: DateTime.now(),
      );
      _store[toStore.id] = toStore;
      created.add(toStore);
    }

    _notifyListeners();
    return Result.success(created);
  }

  @override
  Future<Result<void, failures.Failure>> markAsReviewed(List<ReceiptId> ids) async {
    await _simulateDelay();

    if (shouldFail || nextFailure != null) {
      return _checkFailure(null);
    }

    for (final id in ids) {
      final receipt = _store[id];
      if (receipt != null) {
        _store[id] = receipt.copyWith(
          needsReview: false,
          status: ReceiptStatus.reviewed,
          updatedAt: DateTime.now(),
        );
      }
    }

    _notifyListeners();
    return const Result.success(null);
  }

  @override
  Future<Result<void, failures.Failure>> clearAll() async {
    await _simulateDelay();

    if (shouldFail || nextFailure != null) {
      return _checkFailure(null);
    }

    _store.clear();
    _notifyListeners();
    return const Result.success(null);
  }

  // Test helper methods

  /// Set failure for next operation
  void setNextFailure(failures.Failure failure) {
    nextFailure = failure;
  }

  /// Toggle failure mode
  void setFailureMode(bool enabled) {
    shouldFail = enabled;
  }

  /// Get current store size
  int get storeSize => _store.length;

  /// Get all stored receipts (sync)
  List<ReceiptModel> get allReceiptsSync => _store.values.toList();

  /// Add receipt directly (sync)
  void addReceiptSync(ReceiptModel receipt) {
    _store[receipt.id] = receipt;
    _notifyListeners();
  }

  /// Clear store (sync)
  void clearSync() {
    _store.clear();
    _notifyListeners();
  }

  /// Filter by status
  Future<Result<List<ReceiptModel>, failures.Failure>> filterByStatus(
    ReceiptStatus status,
  ) async {
    await _simulateDelay();

    if (shouldFail || nextFailure != null) {
      return _checkFailure([]);
    }

    final filtered = _store.values
        .where((receipt) => receipt.status == status)
        .toList();

    return Result.success(filtered);
  }

  /// Set should fail for testing error conditions
  void setShouldFail(bool value) {
    shouldFail = value;
  }

  void dispose() {
    _streamController.close();
  }
}