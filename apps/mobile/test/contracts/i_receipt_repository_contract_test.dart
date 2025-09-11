import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/domain/interfaces/i_receipt_repository.dart';
import 'package:receipt_organizer/core/models/receipt.dart';
import 'package:receipt_organizer/core/models/result.dart';

/// Contract tests for IReceiptRepository interface.
/// 
/// These tests define the expected behavior that ALL implementations
/// of IReceiptRepository must satisfy. Any implementation (mock, SQLite, 
/// Supabase, hybrid) must pass these tests.
/// 
/// To test an implementation:
/// ```dart
/// void main() {
///   final repository = YourRepositoryImplementation();
///   runReceiptRepositoryContractTests(repository);
/// }
/// ```
void runReceiptRepositoryContractTests(IReceiptRepository repository) {
  group('IReceiptRepository Contract Tests', () {
    group('Create Operations', () {
      test('should create a receipt with generated ID', () async {
        // Arrange
        final receipt = _createTestReceipt(id: null);
        
        // Act
        final result = await repository.create(receipt);
        
        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, isNotNull);
        expect(result.valueOrNull!.id, isNotNull);
        expect(result.valueOrNull!.id, isNotEmpty);
      });
      
      test('should create a receipt with provided ID', () async {
        // Arrange
        const testId = 'test-receipt-001';
        final receipt = _createTestReceipt(id: testId);
        
        // Act
        final result = await repository.create(receipt);
        
        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull?.id, equals(testId));
      });
      
      test('should fail when creating duplicate ID', () async {
        // Arrange
        const testId = 'duplicate-test-001';
        final receipt1 = _createTestReceipt(id: testId);
        final receipt2 = _createTestReceipt(id: testId);
        
        // Act
        final result1 = await repository.create(receipt1);
        final result2 = await repository.create(receipt2);
        
        // Assert
        expect(result1.isSuccess, isTrue);
        expect(result2.isFailure, isTrue);
        expect(result2.errorOrNull, isA<DuplicateError>());
      });
    });
    
    group('Read Operations', () {
      test('should retrieve receipt by ID', () async {
        // Arrange
        final receipt = _createTestReceipt();
        final createResult = await repository.create(receipt);
        final createdId = createResult.valueOrNull!.id;
        
        // Act
        final result = await repository.getById(createdId);
        
        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull?.id, equals(createdId));
      });
      
      test('should return NotFoundError for non-existent ID', () async {
        // Act
        final result = await repository.getById('non-existent-id');
        
        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
      
      test('should get all receipts with pagination', () async {
        // Arrange
        for (int i = 0; i < 25; i++) {
          await repository.create(_createTestReceipt());
        }
        
        // Act
        final page1 = await repository.getAll(limit: 10, offset: 0);
        final page2 = await repository.getAll(limit: 10, offset: 10);
        final page3 = await repository.getAll(limit: 10, offset: 20);
        
        // Assert
        expect(page1.isSuccess, isTrue);
        expect(page1.valueOrNull?.length, equals(10));
        expect(page2.valueOrNull?.length, equals(10));
        expect(page3.valueOrNull?.length, lessThanOrEqualTo(5));
      });
      
      test('should filter by date range', () async {
        // Arrange
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final tomorrow = now.add(const Duration(days: 1));
        final lastWeek = now.subtract(const Duration(days: 7));
        
        await repository.create(_createTestReceipt(receiptDate: yesterday));
        await repository.create(_createTestReceipt(receiptDate: now));
        await repository.create(_createTestReceipt(receiptDate: tomorrow));
        await repository.create(_createTestReceipt(receiptDate: lastWeek));
        
        // Act
        final result = await repository.getByDateRange(
          yesterday,
          tomorrow,
        );
        
        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull?.length, equals(3));
      });
      
      test('should search receipts by query', () async {
        // Arrange
        await repository.create(_createTestReceipt(
          merchantName: 'Starbucks Coffee',
        ));
        await repository.create(_createTestReceipt(
          merchantName: 'Target Store',
        ));
        await repository.create(_createTestReceipt(
          merchantName: 'Starbucks Reserve',
        ));
        
        // Act
        final result = await repository.search('starbucks');
        
        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull?.length, equals(2));
      });
    });
    
    group('Update Operations', () {
      test('should update existing receipt', () async {
        // Arrange
        final receipt = _createTestReceipt(merchantName: 'Original');
        final createResult = await repository.create(receipt);
        final created = createResult.valueOrNull!;
        
        final updated = created.copyWith(merchantName: 'Updated');
        
        // Act
        final result = await repository.update(updated);
        
        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull?.merchantName, equals('Updated'));
        
        // Verify persisted
        final getResult = await repository.getById(created.id);
        expect(getResult.valueOrNull?.merchantName, equals('Updated'));
      });
      
      test('should fail updating non-existent receipt', () async {
        // Arrange
        final receipt = _createTestReceipt(id: 'non-existent');
        
        // Act
        final result = await repository.update(receipt);
        
        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NotFoundError>());
      });
    });
    
    group('Delete Operations', () {
      test('should soft delete receipt by default', () async {
        // Arrange
        final receipt = _createTestReceipt();
        final createResult = await repository.create(receipt);
        final id = createResult.valueOrNull!.id;
        
        // Act
        final deleteResult = await repository.delete(id);
        
        // Assert
        expect(deleteResult.isSuccess, isTrue);
        
        // Should not be in normal query
        final allResult = await repository.getAll(excludeDeleted: true);
        final ids = allResult.valueOrNull?.map((r) => r.id) ?? [];
        expect(ids.contains(id), isFalse);
        
        // Should be restorable
        final restoreResult = await repository.restore([id]);
        expect(restoreResult.isSuccess, isTrue);
      });
      
      test('should permanently delete when specified', () async {
        // Arrange
        final receipt = _createTestReceipt();
        final createResult = await repository.create(receipt);
        final id = createResult.valueOrNull!.id;
        
        // Act
        final result = await repository.delete(id, permanent: true);
        
        // Assert
        expect(result.isSuccess, isTrue);
        
        // Should not be retrievable
        final getResult = await repository.getById(id);
        expect(getResult.isFailure, isTrue);
        expect(getResult.errorOrNull, isA<NotFoundError>());
      });
      
      test('should delete multiple receipts atomically', () async {
        // Arrange
        final ids = <String>[];
        for (int i = 0; i < 5; i++) {
          final result = await repository.create(_createTestReceipt());
          ids.add(result.valueOrNull!.id);
        }
        
        // Act
        final result = await repository.deleteMultiple(ids);
        
        // Assert
        expect(result.isSuccess, isTrue);
        
        // None should be retrievable
        final allResult = await repository.getAll();
        final remainingIds = allResult.valueOrNull?.map((r) => r.id) ?? [];
        for (final id in ids) {
          expect(remainingIds.contains(id), isFalse);
        }
      });
    });
    
    group('Real-time Operations', () {
      test('should emit updates through watchAll stream', () async {
        // Arrange
        final stream = repository.watchAll();
        final receipts = <List<Receipt>>[];
        
        final subscription = stream.listen((data) {
          receipts.add(data);
        });
        
        // Act
        await Future.delayed(const Duration(milliseconds: 100));
        await repository.create(_createTestReceipt());
        await Future.delayed(const Duration(milliseconds: 100));
        await repository.create(_createTestReceipt());
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(receipts.length, greaterThanOrEqualTo(2));
        expect(receipts.last.length, greaterThan(receipts.first.length));
        
        // Cleanup
        await subscription.cancel();
      });
    });
    
    group('Statistics Operations', () {
      test('should calculate receipt statistics', () async {
        // Arrange
        await repository.create(_createTestReceipt(
          totalAmount: 10.00,
          merchantName: 'Store A',
        ));
        await repository.create(_createTestReceipt(
          totalAmount: 20.00,
          merchantName: 'Store B',
        ));
        await repository.create(_createTestReceipt(
          totalAmount: 30.00,
          merchantName: 'Store A',
        ));
        
        // Act
        final result = await repository.getStatistics();
        
        // Assert
        expect(result.isSuccess, isTrue);
        final stats = result.valueOrNull!;
        expect(stats.totalCount, equals(3));
        expect(stats.totalAmount, equals(60.00));
        expect(stats.averageAmount, equals(20.00));
        expect(stats.topMerchants['Store A'], equals(2));
        expect(stats.topMerchants['Store B'], equals(1));
      });
    });
  });
}

/// Helper to create test receipts with default values
Receipt _createTestReceipt({
  String? id,
  String? merchantName,
  DateTime? receiptDate,
  double? totalAmount,
}) {
  return Receipt(
    id: id ?? '',
    merchantName: merchantName ?? 'Test Merchant',
    date: receiptDate ?? DateTime.now(),
    totalAmount: totalAmount ?? 9.99,
    createdAt: DateTime.now(),
    imagePath: 'test://image.jpg',
  );
}