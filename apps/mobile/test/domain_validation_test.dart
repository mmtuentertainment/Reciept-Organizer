import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/domain/models/receipt_model.dart';
import 'package:receipt_organizer/domain/value_objects/receipt_id.dart';
import 'package:receipt_organizer/domain/value_objects/money.dart';
import 'package:receipt_organizer/domain/value_objects/category.dart';
import 'package:receipt_organizer/domain/entities/receipt_status.dart';
import 'package:receipt_organizer/domain/core/result.dart';
import 'package:receipt_organizer/domain/core/failures.dart' as failures;
import 'package:receipt_organizer/domain/mappers/receipt_mapper.dart';
import 'package:receipt_organizer/data/models/receipt.dart' as data;
import 'fakes/fake_receipt_repository_domain.dart';

void main() {
  group('Domain Architecture Validation', () {
    test('ReceiptModel can be created with factory', () {
      // Arrange & Act
      final receipt = ReceiptModel.create(
        imagePath: '/test/image.jpg',
        batchId: 'batch-123',
      );

      // Assert
      expect(receipt.id, isA<ReceiptId>());
      expect(receipt.imagePath, '/test/image.jpg');
      expect(receipt.batchId, 'batch-123');
      expect(receipt.status, ReceiptStatus.pending);
      expect(receipt.createdAt, isA<DateTime>());
    });

    test('Value objects work correctly', () {
      // Test ReceiptId
      final id1 = ReceiptId.generate();
      final id2 = ReceiptId.fromString(id1.value);
      expect(id1, equals(id2));
      expect(id1.isValid, true);

      // Test Money
      final money = Money.from(99.99, Currency.usd);
      expect(money.amount, 99.99);
      expect(money.currency, Currency.usd);
      expect(money.displayAmount, '99.99');
      expect(money.display, '\$99.99');

      // Test Category
      final category = Category(type: CategoryType.groceries);
      expect(category.type, CategoryType.groceries);
      expect(category.displayName, 'Groceries');
      expect(category.icon, '🛒');
    });

    test('Result type handles success and failure', () {
      // Success case
      final success = Result<int, failures.Failure>.success(42);
      expect(success.isSuccess, true);
      expect(success.isFailure, false);
      expect(success.successOrNull, 42);
      expect(success.failureOrNull, null);

      // Failure case
      final failure = Result<int, failures.Failure>.failure(
        const failures.Failure.unexpected(message: 'Error'),
      );
      expect(failure.isSuccess, false);
      expect(failure.isFailure, true);
      expect(failure.successOrNull, null);
      expect(failure.failureOrNull, isA<failures.Failure>());
    });

    test('FakeReceiptRepository works correctly', () async {
      // Arrange
      final repo = FakeReceiptRepositoryDomain();
      final receipt = ReceiptModel.create(
        imagePath: '/test/receipt.jpg',
      );

      // Act - Create
      final createResult = await repo.create(receipt);

      // Assert - Create
      expect(createResult.isSuccess, true);
      final created = createResult.successOrNull!;
      expect(created.imagePath, '/test/receipt.jpg');

      // Act - Get by ID
      final getResult = await repo.getById(created.id);

      // Assert - Get by ID
      expect(getResult.isSuccess, true);
      expect(getResult.successOrNull!.id, created.id);

      // Act - Get all
      final allResult = await repo.getAll();

      // Assert - Get all
      expect(allResult.isSuccess, true);
      expect(allResult.successOrNull!.length, 1);

      // Act - Delete
      final deleteResult = await repo.delete(created.id);

      // Assert - Delete
      expect(deleteResult.isSuccess, true);

      // Verify deleted
      final afterDelete = await repo.getAll();
      expect(afterDelete.successOrNull!.length, 0);
    });

    test('Repository handles failures correctly', () async {
      // Arrange
      final repo = FakeReceiptRepositoryDomain();
      repo.setFailureMode(true);
      final receipt = ReceiptModel.create(
        imagePath: '/test/receipt.jpg',
      );

      // Act
      final result = await repo.create(receipt);

      // Assert
      expect(result.isFailure, true);
      expect(result.failureOrNull, isA<failures.Failure>());
    });

    test('Mapper converts between domain and data models', () {
      // Arrange
      final dataReceipt = data.Receipt(
        id: 'test-123',
        imageUri: '/test/image.jpg',
        capturedAt: DateTime.now(),
        status: data.ReceiptStatus.ready,
        lastModified: DateTime.now(),
        vendorName: 'Test Store',
        totalAmount: 99.99,
        categoryId: 'groceries',
      );

      // Act - To Domain
      final domainReceipt = ReceiptMapper.toDomain(dataReceipt);

      // Assert - To Domain
      expect(domainReceipt.id.value, 'test-123');
      expect(domainReceipt.imagePath, '/test/image.jpg');
      expect(domainReceipt.merchant, 'Test Store');
      expect(domainReceipt.totalAmount?.amount, 99.99);
      expect(domainReceipt.category?.type, CategoryType.groceries);
      expect(domainReceipt.status, ReceiptStatus.processed);

      // Act - Back to Data
      final dataBack = ReceiptMapper.toData(domainReceipt);

      // Assert - Back to Data
      expect(dataBack.id, 'test-123');
      expect(dataBack.imageUri, '/test/image.jpg');
      expect(dataBack.vendorName, 'Test Store');
      expect(dataBack.totalAmount, 99.99);
      expect(dataBack.categoryId, 'groceries');
      expect(dataBack.status, data.ReceiptStatus.ready);
    });

    test('Domain model with Freezed copyWith works', () {
      // Arrange
      final original = ReceiptModel.create(
        imagePath: '/test/original.jpg',
      );

      // Act
      final updated = original.copyWith(
        merchant: 'Updated Store',
        totalAmount: Money.from(123.45, Currency.usd),
        status: ReceiptStatus.processed,
      );

      // Assert
      expect(updated.id, original.id); // ID unchanged
      expect(updated.imagePath, original.imagePath); // Path unchanged
      expect(updated.merchant, 'Updated Store'); // Updated
      expect(updated.totalAmount?.amount, 123.45); // Updated
      expect(updated.status, ReceiptStatus.processed); // Updated
    });

    test('Receipt statistics calculation works', () async {
      // Arrange
      final repo = FakeReceiptRepositoryDomain();

      // Create test receipts
      final receipts = [
        ReceiptModel.create(imagePath: '/1.jpg').copyWith(
          totalAmount: Money.from(50, Currency.usd),
          category: Category(type: CategoryType.groceries),
          status: ReceiptStatus.processed,
        ),
        ReceiptModel.create(imagePath: '/2.jpg').copyWith(
          totalAmount: Money.from(30, Currency.usd),
          category: Category(type: CategoryType.dining),
          status: ReceiptStatus.processed,
        ),
        ReceiptModel.create(imagePath: '/3.jpg').copyWith(
          totalAmount: Money.from(20, Currency.usd),
          category: Category(type: CategoryType.groceries),
          status: ReceiptStatus.processed,
        ),
        ReceiptModel.create(imagePath: '/4.jpg').copyWith(
          status: ReceiptStatus.error,
        ),
      ];

      for (final receipt in receipts) {
        await repo.create(receipt);
      }

      // Act
      final statsResult = await repo.getStatistics();

      // Assert
      expect(statsResult.isSuccess, true);
      final stats = statsResult.successOrNull!;
      expect(stats.totalCount, 4);
      expect(stats.processedCount, 3);
      expect(stats.errorCount, 1);
      expect(stats.totalAmount, 100.0);
      expect(stats.averageAmount, closeTo(33.33, 0.01));
    });

    test('Stream watching works', () async {
      // Arrange
      final repo = FakeReceiptRepositoryDomain();
      final receipt = ReceiptModel.create(imagePath: '/test.jpg');

      // Act & Assert
      final stream = repo.watchAll();

      // Listen to stream
      expectLater(
        stream.map((result) => result.successOrNull?.length ?? 0),
        emitsInOrder([0, 1, 0]),
      );

      // Trigger events
      await repo.create(receipt);
      await repo.delete(receipt.id);
    });
  });
}