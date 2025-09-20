import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/core/models/receipt.dart' as core_models;
import 'package:receipt_organizer/features/receipts/providers/receipts_provider.dart';
import 'package:uuid/uuid.dart';

/// Simple synchronous receipt provider for testing
/// This avoids async operations and timeouts in tests

// Global list of test receipts that can be modified during tests
final List<core_models.Receipt> _testReceipts = [];

/// Create default test receipts
List<core_models.Receipt> createDefaultTestReceipts() {
  final uuid = const Uuid();
  return [
    core_models.Receipt(
      id: uuid.v4(),
      merchantName: 'Walmart',
      totalAmount: 125.75,
      taxAmount: 10.25,
      date: DateTime.now().subtract(const Duration(days: 1)),
      imagePath: '/test/image1.jpg',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    core_models.Receipt(
      id: uuid.v4(),
      merchantName: 'Target',
      totalAmount: 89.99,
      taxAmount: 7.50,
      date: DateTime.now().subtract(const Duration(days: 2)),
      imagePath: '/test/image2.jpg',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    core_models.Receipt(
      id: uuid.v4(),
      merchantName: 'Gas Station',
      totalAmount: 45.00,
      date: DateTime.now().subtract(const Duration(days: 3)),
      imagePath: '/test/image3.jpg',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];
}

/// Add a receipt to the test list
void addTestReceipt(core_models.Receipt receipt) {
  _testReceipts.add(receipt);
}

/// Clear all test receipts
void clearTestReceipts() {
  _testReceipts.clear();
}

/// Initialize test receipts with defaults
void initializeTestReceipts({List<core_models.Receipt>? receipts}) {
  _testReceipts.clear();
  if (receipts != null) {
    _testReceipts.addAll(receipts);
  }
}

/// Get current test receipts
List<core_models.Receipt> getTestReceipts() {
  return List.from(_testReceipts);
}

/// Synchronous provider overrides for testing
final simpleSyncReceiptProviderOverrides = [
  // Override the main receipts provider with a synchronous version
  receiptsProvider.overrideWith((ref) {
    // Return immediately with current test receipts
    // No actual async operations, just wrapped in Future.value
    return Future.value(getTestReceipts());
  }),

  // Override create receipt provider
  createReceiptProvider.overrideWith((ref) {
    return (core_models.Receipt receipt) async {
      // Add to test list
      addTestReceipt(receipt);

      // Invalidate to trigger UI update
      ref.invalidate(receiptsProvider);

      return receipt;
    };
  }),

  // Override update receipt provider
  updateReceiptProvider.overrideWith((ref) {
    return (core_models.Receipt receipt) async {
      // Find and update in test list
      final index = _testReceipts.indexWhere((r) => r.id == receipt.id);
      if (index != -1) {
        _testReceipts[index] = receipt;
      }

      // Invalidate to trigger UI update
      ref.invalidate(receiptsProvider);

      return receipt;
    };
  }),

  // Override delete receipt provider
  deleteReceiptProvider.overrideWith((ref) {
    return (String receiptId) async {
      // Remove from test list
      _testReceipts.removeWhere((r) => r.id == receiptId);

      // Invalidate to trigger UI update
      ref.invalidate(receiptsProvider);
    };
  }),
];