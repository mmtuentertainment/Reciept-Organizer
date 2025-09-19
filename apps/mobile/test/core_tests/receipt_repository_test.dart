import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:receipt_organizer/database/app_database.dart';
import 'package:receipt_organizer/data/repositories/receipt_repository.dart';
import 'package:receipt_organizer/data/models/receipt.dart' as models;
import 'package:uuid/uuid.dart';

void main() {
  group('Receipt Repository Tests - Drift Database', () {
    late AppDatabase database;
    late ReceiptRepository repository;
    final uuid = const Uuid();

    setUp(() async {
      // Create in-memory database for testing
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = ReceiptRepository.withDatabase(database);
    });

    tearDown(() async {
      await database.close();
    });

    group('CRUD Operations', () {
      test('should create a receipt with all fields', () async {
        // Given
        final receipt = models.Receipt(
          id: uuid.v4(),
          userId: 'user-123',
          imageUri: '/path/to/image.jpg',
          thumbnailUri: '/path/to/thumb.jpg',
          imageUrl: 'https://example.com/image.jpg',
          capturedAt: DateTime.now(),
          lastModified: DateTime.now(),
          status: models.ReceiptStatus.ready,
          isProcessed: true,
          needsReview: false,
          batchId: 'batch-001',
          vendorName: 'Test Store',
          receiptDate: DateTime.now().subtract(const Duration(days: 1)),
          totalAmount: 99.99,
          taxAmount: 8.99,
          tipAmount: 15.00,
          currency: 'USD',
          categoryId: 'cat-001',
          subcategory: 'Office Supplies',
          paymentMethod: 'Credit Card',
          ocrConfidence: 0.95,
          ocrRawText: 'Raw OCR text here',
          businessPurpose: 'Office supplies for Q1',
          notes: 'Purchased printer paper and pens',
          tags: ['office', 'supplies', 'q1'],
          syncStatus: 'synced',
          lastSyncAt: DateTime.now(),
        );

        // When
        final created = await repository.createReceipt(receipt);

        // Then
        expect(created.id, isNotEmpty);
        expect(created.vendorName, equals('Test Store'));
        expect(created.totalAmount, equals(99.99));
        expect(created.taxAmount, equals(8.99));
        expect(created.tipAmount, equals(15.00));
        expect(created.categoryId, equals('cat-001'));
        expect(created.tags, contains('office'));
        expect(created.isProcessed, isTrue);
        expect(created.needsReview, isFalse);
      });

      test('should retrieve receipt by ID', () async {
        // Given
        final id = uuid.v4();
        final receipt = models.Receipt(
          id: id,
          imageUri: '/test.jpg',
          capturedAt: DateTime.now(),
          vendorName: 'Target',
          totalAmount: 45.67,
        );
        await repository.createReceipt(receipt);

        // When
        final retrieved = await repository.getReceiptById(id);

        // Then
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals(id));
        expect(retrieved.vendorName, equals('Target'));
        expect(retrieved.totalAmount, equals(45.67));
      });

      test('should update receipt with partial data', () async {
        // Given
        final id = uuid.v4();
        final receipt = models.Receipt(
          id: id,
          imageUri: '/original.jpg',
          capturedAt: DateTime.now(),
          vendorName: 'Original Store',
          totalAmount: 100.00,
        );
        await repository.createReceipt(receipt);

        // When - Update only specific fields
        final updated = receipt.copyWith(
          vendorName: 'Updated Store',
          totalAmount: 200.00,
          notes: 'Updated notes',
          isProcessed: true,
        );
        await repository.updateReceipt(updated);

        // Then
        final retrieved = await repository.getReceiptById(id);
        expect(retrieved!.vendorName, equals('Updated Store'));
        expect(retrieved.totalAmount, equals(200.00));
        expect(retrieved.notes, equals('Updated notes'));
        expect(retrieved.isProcessed, isTrue);
      });

      test('should delete receipt', () async {
        // Given
        final id = uuid.v4();
        final receipt = models.Receipt(
          id: id,
          imageUri: '/delete-me.jpg',
          capturedAt: DateTime.now(),
        );
        await repository.createReceipt(receipt);

        // Verify it exists
        var retrieved = await repository.getReceiptById(id);
        expect(retrieved, isNotNull);

        // When
        await repository.deleteReceipt(id);

        // Then
        retrieved = await repository.getReceiptById(id);
        expect(retrieved, isNull);
      });

      test('should delete multiple receipts', () async {
        // Given
        final ids = List.generate(5, (_) => uuid.v4());
        for (final id in ids) {
          await repository.createReceipt(models.Receipt(
            id: id,
            imageUri: '/batch-$id.jpg',
            capturedAt: DateTime.now(),
          ));
        }

        // When
        await repository.deleteReceipts(ids);

        // Then
        for (final id in ids) {
          final receipt = await repository.getReceiptById(id);
          expect(receipt, isNull);
        }
      });
    });

    group('Query Operations', () {
      test('should get all receipts sorted by capture date', () async {
        // Given
        final now = DateTime.now();
        await repository.createReceipt(models.Receipt(
          id: 'newest',
          imageUri: '/newest.jpg',
          capturedAt: now,
          vendorName: 'Newest Store',
        ));
        await repository.createReceipt(models.Receipt(
          id: 'middle',
          imageUri: '/middle.jpg',
          capturedAt: now.subtract(const Duration(hours: 1)),
          vendorName: 'Middle Store',
        ));
        await repository.createReceipt(models.Receipt(
          id: 'oldest',
          imageUri: '/oldest.jpg',
          capturedAt: now.subtract(const Duration(hours: 2)),
          vendorName: 'Oldest Store',
        ));

        // When
        final receipts = await repository.getAllReceipts();

        // Then
        expect(receipts.length, equals(3));
        expect(receipts[0].id, equals('newest'));
        expect(receipts[1].id, equals('middle'));
        expect(receipts[2].id, equals('oldest'));
      });

      test('should get receipts by date range', () async {
        // Given
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final twoDaysAgo = now.subtract(const Duration(days: 2));
        final tomorrow = now.add(const Duration(days: 1));

        await repository.createReceipt(models.Receipt(
          id: 'yesterday',
          imageUri: '/yesterday.jpg',
          capturedAt: now,
          receiptDate: yesterday,
          vendorName: 'Yesterday Store',
        ));
        await repository.createReceipt(models.Receipt(
          id: 'today',
          imageUri: '/today.jpg',
          capturedAt: now,
          receiptDate: now,
          vendorName: 'Today Store',
        ));
        await repository.createReceipt(models.Receipt(
          id: 'two-days-ago',
          imageUri: '/two-days.jpg',
          capturedAt: now,
          receiptDate: twoDaysAgo,
          vendorName: 'Old Store',
        ));
        await repository.createReceipt(models.Receipt(
          id: 'tomorrow',
          imageUri: '/tomorrow.jpg',
          capturedAt: now,
          receiptDate: tomorrow,
          vendorName: 'Future Store',
        ));

        // When - Get receipts from yesterday to today
        final receipts = await repository.getReceiptsByDateRange(
          DateTime(yesterday.year, yesterday.month, yesterday.day),
          DateTime(now.year, now.month, now.day, 23, 59, 59),
        );

        // Then
        expect(receipts.length, greaterThanOrEqualTo(2));
        final ids = receipts.map((r) => r.id).toList();
        expect(ids, containsAll(['yesterday', 'today']));
      });

      test('should search receipts by vendor name', () async {
        // Given
        await repository.createReceipt(models.Receipt(
          id: '1',
          imageUri: '/1.jpg',
          capturedAt: DateTime.now(),
          vendorName: 'Walmart',
        ));
        await repository.createReceipt(models.Receipt(
          id: '2',
          imageUri: '/2.jpg',
          capturedAt: DateTime.now(),
          vendorName: 'Target',
        ));
        await repository.createReceipt(models.Receipt(
          id: '3',
          imageUri: '/3.jpg',
          capturedAt: DateTime.now(),
          vendorName: 'Walgreens',
        ));

        // When
        final results = await repository.searchReceipts('Wal');

        // Then
        expect(results.length, equals(2));
        final vendors = results.map((r) => r.vendorName).toList();
        expect(vendors, containsAll(['Walmart', 'Walgreens']));
      });

      test('should search receipts by notes and business purpose', () async {
        // Given
        await repository.createReceipt(models.Receipt(
          id: '1',
          imageUri: '/1.jpg',
          capturedAt: DateTime.now(),
          notes: 'Office supplies for the new project',
        ));
        await repository.createReceipt(models.Receipt(
          id: '2',
          imageUri: '/2.jpg',
          capturedAt: DateTime.now(),
          businessPurpose: 'Client meeting expenses',
        ));
        await repository.createReceipt(models.Receipt(
          id: '3',
          imageUri: '/3.jpg',
          capturedAt: DateTime.now(),
          notes: 'Personal purchase',
        ));

        // When - Search for "office"
        final officeResults = await repository.searchReceipts('office');
        expect(officeResults.length, equals(1));

        // When - Search for "meeting"
        final meetingResults = await repository.searchReceipts('meeting');
        expect(meetingResults.length, equals(1));
      });

      test('should get receipts by batch ID', () async {
        // Given
        const batchId = 'batch-2024-01';
        await repository.createReceipt(models.Receipt(
          id: '1',
          imageUri: '/1.jpg',
          capturedAt: DateTime.now(),
          batchId: batchId,
          vendorName: 'Store A',
        ));
        await repository.createReceipt(models.Receipt(
          id: '2',
          imageUri: '/2.jpg',
          capturedAt: DateTime.now(),
          batchId: batchId,
          vendorName: 'Store B',
        ));
        await repository.createReceipt(models.Receipt(
          id: '3',
          imageUri: '/3.jpg',
          capturedAt: DateTime.now(),
          batchId: 'other-batch',
          vendorName: 'Store C',
        ));

        // When
        final receipts = await repository.getReceiptsByBatchId(batchId);

        // Then
        expect(receipts.length, equals(2));
        expect(receipts.every((r) => r.batchId == batchId), isTrue);
      });

      test('should get receipts by status', () async {
        // Given
        await repository.createReceipt(models.Receipt(
          id: '1',
          imageUri: '/1.jpg',
          capturedAt: DateTime.now(),
          status: models.ReceiptStatus.captured,
        ));
        await repository.createReceipt(models.Receipt(
          id: '2',
          imageUri: '/2.jpg',
          capturedAt: DateTime.now(),
          status: models.ReceiptStatus.ready,
        ));
        await repository.createReceipt(models.Receipt(
          id: '3',
          imageUri: '/3.jpg',
          capturedAt: DateTime.now(),
          status: models.ReceiptStatus.captured,
        ));

        // When
        final pending = await repository.getReceiptsByStatus(models.ReceiptStatus.captured);
        final completed = await repository.getReceiptsByStatus(models.ReceiptStatus.ready);

        // Then
        expect(pending.length, equals(2));
        expect(completed.length, equals(1));
      });

      test('should paginate receipts', () async {
        // Given - Create 10 receipts
        for (int i = 0; i < 10; i++) {
          await repository.createReceipt(models.Receipt(
            id: 'receipt-$i',
            imageUri: '/image-$i.jpg',
            capturedAt: DateTime.now().subtract(Duration(hours: i)),
            vendorName: 'Store $i',
          ));
        }

        // When - Get first page
        final page1 = await repository.getReceiptsPaginated(0, 3);

        // When - Get second page
        final page2 = await repository.getReceiptsPaginated(3, 3);

        // Then
        expect(page1.length, equals(3));
        expect(page2.length, equals(3));
        expect(page1[0].id, equals('receipt-0'));
        expect(page2[0].id, equals('receipt-3'));
      });

      test('should get receipt count', () async {
        // Given
        for (int i = 0; i < 5; i++) {
          await repository.createReceipt(models.Receipt(
            id: 'receipt-$i',
            imageUri: '/image-$i.jpg',
            capturedAt: DateTime.now(),
          ));
        }

        // When
        final count = await repository.getReceiptCount();

        // Then
        expect(count, equals(5));
      });
    });

    group('OCR and Processing', () {
      test('should save and retrieve OCR results', () async {
        // Given
        final id = uuid.v4();
        // Note: Removed OCR test as ocrResults field not present in Receipt model
        // This would need to be added to the Receipt model or handled differently

        final receipt = models.Receipt(
          id: id,
          imageUri: '/ocr-test.jpg',
          capturedAt: DateTime.now(),
          ocrConfidence: 0.97,
          ocrRawText: 'STARBUCKS\nDEC 25, 2024\n\$5.75\nThank you!',
          vendorName: 'Starbucks',
          totalAmount: 5.75,
          receiptDate: DateTime(2024, 12, 25),
        );

        // When
        await repository.createReceipt(receipt);
        final retrieved = await repository.getReceiptById(id);

        // Then
        expect(retrieved, isNotNull);
        expect(retrieved!.ocrConfidence, equals(0.97));
        expect(retrieved.ocrRawText, contains('STARBUCKS'));
        expect(retrieved.vendorName, equals('Starbucks'));
        expect(retrieved.totalAmount, equals(5.75));
      });
    });

    group('Sync and Queue', () {
      test('should track sync status', () async {
        // Given
        final now = DateTime.now();
        final receipt = models.Receipt(
          id: uuid.v4(),
          imageUri: '/sync-test.jpg',
          capturedAt: now,
          syncStatus: 'pending',
          lastSyncAt: null,
        );
        await repository.createReceipt(receipt);

        // When - Update sync status
        final updated = receipt.copyWith(
          syncStatus: 'synced',
          lastSyncAt: now,
        );
        await repository.updateReceipt(updated);

        // Then
        final retrieved = await repository.getReceiptById(receipt.id);
        expect(retrieved!.syncStatus, equals('synced'));
        expect(retrieved.lastSyncAt, isNotNull);
      });

      test('should handle metadata storage', () async {
        // Given
        final metadata = {
          'source': 'mobile_app',
          'version': '1.0.0',
          'device': 'iPhone 15',
          'custom_fields': {
            'project_code': 'PROJ-123',
            'cost_center': 'CC-456',
          },
        };

        final receipt = models.Receipt(
          id: uuid.v4(),
          imageUri: '/metadata-test.jpg',
          capturedAt: DateTime.now(),
          metadata: metadata,
        );

        // When
        await repository.createReceipt(receipt);
        final retrieved = await repository.getReceiptById(receipt.id);

        // Then
        expect(retrieved!.metadata, isNotNull);
        expect(retrieved.metadata!['source'], equals('mobile_app'));
        expect(retrieved.metadata!['custom_fields']['project_code'], equals('PROJ-123'));
      });
    });

    group('Batch Operations', () {
      test('should clear all data', () async {
        // Given
        for (int i = 0; i < 5; i++) {
          await repository.createReceipt(models.Receipt(
            id: 'receipt-$i',
            imageUri: '/image-$i.jpg',
            capturedAt: DateTime.now(),
          ));
        }
        expect(await repository.getReceiptCount(), equals(5));

        // When
        await repository.clearAllData();

        // Then
        expect(await repository.getReceiptCount(), equals(0));
      });

      test('should get database statistics', () async {
        // Given
        await repository.createReceipt(models.Receipt(
          id: '1',
          imageUri: '/1.jpg',
          capturedAt: DateTime.now(),
          isProcessed: true,
          syncStatus: 'synced',
        ));
        await repository.createReceipt(models.Receipt(
          id: '2',
          imageUri: '/2.jpg',
          capturedAt: DateTime.now(),
          isProcessed: false,
          syncStatus: 'pending',
        ));

        // When
        final stats = await repository.getStats();

        // Then
        expect(stats['totalReceipts'], equals(2));
        // Add more stat assertions based on implementation
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle null values correctly', () async {
        // Given - Receipt with minimal required fields
        final receipt = models.Receipt(
          id: uuid.v4(),
          imageUri: '/minimal.jpg',
          capturedAt: DateTime.now(),
        );

        // When
        await repository.createReceipt(receipt);
        final retrieved = await repository.getReceiptById(receipt.id);

        // Then
        expect(retrieved, isNotNull);
        expect(retrieved!.vendorName, isNull);
        expect(retrieved.totalAmount, isNull);
        expect(retrieved.notes, isNull);
        expect(retrieved.tags ?? [], isEmpty);
      });

      test('should handle empty search query', () async {
        // Given
        await repository.createReceipt(models.Receipt(
          id: '1',
          imageUri: '/1.jpg',
          capturedAt: DateTime.now(),
        ));

        // When
        final results = await repository.searchReceipts('');

        // Then - Should return all receipts
        expect(results.length, equals(1));
      });

      test('should handle date range edge cases', () async {
        // Given
        final date = DateTime(2024, 1, 15);
        await repository.createReceipt(models.Receipt(
          id: '1',
          imageUri: '/1.jpg',
          capturedAt: DateTime.now(),
          receiptDate: date,
        ));

        // When - Query with same start and end date
        final receipts = await repository.getReceiptsByDateRange(
          date,
          date,
        );

        // Then - Should include receipts from that day
        expect(receipts.length, equals(1));
      });

      test('should handle concurrent operations', () async {
        // Given
        final futures = <Future>[];

        // When - Create multiple receipts concurrently
        for (int i = 0; i < 10; i++) {
          futures.add(repository.createReceipt(models.Receipt(
            id: 'concurrent-$i',
            imageUri: '/concurrent-$i.jpg',
            capturedAt: DateTime.now(),
          )));
        }

        await Future.wait(futures);

        // Then
        final count = await repository.getReceiptCount();
        expect(count, equals(10));
      });
    });
  });
}