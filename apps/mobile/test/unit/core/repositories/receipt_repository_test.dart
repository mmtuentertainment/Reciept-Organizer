import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:receipt_organizer/data/repositories/receipt_repository.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import '../../../helpers/test_database_helper.dart';

void main() {
  late ReceiptRepository repository;
  late Database database;

  setUpAll(() {
    // Initialize sqflite for testing
    TestDatabaseHelper.initialize();
  });

  setUp(() async {
    repository = ReceiptRepository();
    
    // Clean up any existing test database
    final databasePath = await getDatabasesPath();
    final testDbPath = path.join(databasePath, 'test_receipt_organizer.db');
    try {
      await File(testDbPath).delete();
    } catch (_) {
      // Ignore if doesn't exist
    }
  });

  tearDown(() async {
    // Close database connection
    try {
      final db = await repository.database;
      await db.close();
    } catch (_) {
      // Ignore errors during cleanup
    }
  });

  Receipt createTestReceipt({
    String? id,
    String? merchantName,
    String? receiptDate,
    double? totalAmount,
    double? taxAmount,
    DateTime? capturedAt,
    String? batchId,
    ReceiptStatus status = ReceiptStatus.ready,
    String? notes,
  }) {
    final receipt = Receipt(
      id: id,
      imageUri: 'file:///test/image_$id.jpg',
      capturedAt: capturedAt ?? DateTime.now(),
      status: status,
      batchId: batchId,
      notes: notes,
      lastModified: DateTime.now(),
    );

    // Create mock OCR results
    if (merchantName != null || receiptDate != null || totalAmount != null || taxAmount != null) {
      final ocrResults = ProcessingResult(
        merchant: merchantName != null
            ? FieldData(
                value: merchantName,
                confidence: 95.0,
                originalText: merchantName,
              )
            : null,
        date: receiptDate != null
            ? FieldData(
                value: receiptDate,
                confidence: 98.0,
                originalText: receiptDate,
              )
            : null,
        total: totalAmount != null
            ? FieldData(
                value: totalAmount,
                confidence: 96.0,
                originalText: totalAmount.toString(),
              )
            : null,
        tax: taxAmount != null
            ? FieldData(
                value: taxAmount,
                confidence: 92.0,
                originalText: taxAmount.toString(),
              )
            : null,
        overallConfidence: 95.0,
        processingDurationMs: 500,
      );

      // Use copyWith to add OCR results
      return receipt.copyWith(ocrResults: ocrResults);
    }

    return receipt;
  }

  group('Database Initialization', () {
    test('should create database with correct tables', () async {
      // When
      final db = await repository.database;

      // Then
      final tables = await db
          .rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      expect(tables.any((table) => table['name'] == 'receipts'), isTrue);
    });

    test('should create index on receiptDate for performance (PERF-001)', () async {
      // When
      final db = await repository.database;

      // Then
      final indexes = await db
          .rawQuery("SELECT name FROM sqlite_master WHERE type='index'");
      expect(
        indexes.any((index) => index['name'] == 'idx_receipt_date'),
        isTrue,
        reason: 'Database should have index on receiptDate field for performance',
      );
    });

    test('should create index on batchId', () async {
      // When
      final db = await repository.database;

      // Then
      final indexes = await db
          .rawQuery("SELECT name FROM sqlite_master WHERE type='index'");
      expect(
        indexes.any((index) => index['name'] == 'idx_batch_id'),
        isTrue,
      );
    });
  });

  group('Receipt CRUD Operations', () {
    test('should create and retrieve receipt', () async {
      // Given
      final receipt = createTestReceipt(
        id: 'test-1',
        merchantName: 'Test Store',
        receiptDate: '01/15/2024',
        totalAmount: 99.99,
        taxAmount: 8.99,
      );

      // When
      await repository.createReceipt(receipt);
      final retrieved = await repository.getReceiptById('test-1');

      // Then
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('test-1'));
      expect(retrieved.merchantName, equals('Test Store'));
      expect(retrieved.receiptDate, equals('01/15/2024'));
      expect(retrieved.totalAmount, equals(99.99));
      expect(retrieved.taxAmount, equals(8.99));
    });

    test('should update receipt', () async {
      // Given
      final receipt = createTestReceipt(
        id: 'test-2',
        merchantName: 'Old Store',
        totalAmount: 50.0,
      );
      await repository.createReceipt(receipt);

      // When
      final updated = createTestReceipt(
        id: 'test-2',
        merchantName: 'New Store',
        totalAmount: 75.0,
        notes: 'Updated receipt',
      );
      await repository.updateReceipt(updated);
      final retrieved = await repository.getReceiptById('test-2');

      // Then
      expect(retrieved!.merchantName, equals('New Store'));
      expect(retrieved.totalAmount, equals(75.0));
      expect(retrieved.notes, equals('Updated receipt'));
    });

    test('should delete receipt', () async {
      // Given
      final receipt = createTestReceipt(id: 'test-3');
      await repository.createReceipt(receipt);

      // When
      await repository.deleteReceipt('test-3');
      final retrieved = await repository.getReceiptById('test-3');

      // Then
      expect(retrieved, isNull);
    });

    test('should delete multiple receipts', () async {
      // Given
      final receipts = [
        createTestReceipt(id: 'batch-1'),
        createTestReceipt(id: 'batch-2'),
        createTestReceipt(id: 'batch-3'),
      ];
      for (final receipt in receipts) {
        await repository.createReceipt(receipt);
      }

      // When
      await repository.deleteReceipts(['batch-1', 'batch-3']);

      // Then
      expect(await repository.getReceiptById('batch-1'), isNull);
      expect(await repository.getReceiptById('batch-2'), isNotNull);
      expect(await repository.getReceiptById('batch-3'), isNull);
    });
  });

  group('Date Range Queries', () {
    setUp(() async {
      // Create test receipts with various dates
      final receipts = [
        createTestReceipt(
          id: 'jan-1',
          merchantName: 'January Store 1',
          receiptDate: '01/15/2024',
          totalAmount: 100.0,
        ),
        createTestReceipt(
          id: 'jan-2',
          merchantName: 'January Store 2',
          receiptDate: '01/25/2024',
          totalAmount: 200.0,
        ),
        createTestReceipt(
          id: 'feb-1',
          merchantName: 'February Store',
          receiptDate: '02/10/2024',
          totalAmount: 300.0,
        ),
        createTestReceipt(
          id: 'mar-1',
          merchantName: 'March Store',
          receiptDate: '03/05/2024',
          totalAmount: 400.0,
        ),
        createTestReceipt(
          id: 'no-date',
          merchantName: 'No Date Store',
          totalAmount: 500.0,
          receiptDate: null, // No receipt date
        ),
      ];

      for (final receipt in receipts) {
        await repository.createReceipt(receipt);
      }
    });

    test('should retrieve receipts within date range', () async {
      // Given
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 31);

      // When
      final results = await repository.getReceiptsByDateRange(start, end);

      // Then
      expect(results.length, equals(2));
      expect(results.any((r) => r.id == 'jan-1'), isTrue);
      expect(results.any((r) => r.id == 'jan-2'), isTrue);
      expect(results.any((r) => r.id == 'feb-1'), isFalse);
    });

    test('should handle inclusive date ranges', () async {
      // Given - exact date match
      final start = DateTime(2024, 1, 15);
      final end = DateTime(2024, 1, 15);

      // When
      final results = await repository.getReceiptsByDateRange(start, end);

      // Then
      expect(results.length, equals(1));
      expect(results.first.id, equals('jan-1'));
    });

    test('should exclude receipts without dates', () async {
      // Given
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 12, 31);

      // When
      final results = await repository.getReceiptsByDateRange(start, end);

      // Then
      expect(results.any((r) => r.id == 'no-date'), isFalse);
      expect(results.length, equals(4)); // All dated receipts
    });

    test('should return empty list for future date range', () async {
      // Given
      final start = DateTime(2025, 1, 1);
      final end = DateTime(2025, 12, 31);

      // When
      final results = await repository.getReceiptsByDateRange(start, end);

      // Then
      expect(results, isEmpty);
    });

    test('should handle month boundaries correctly', () async {
      // Given - February date range
      final start = DateTime(2024, 2, 1);
      final end = DateTime(2024, 2, 29); // Leap year

      // When
      final results = await repository.getReceiptsByDateRange(start, end);

      // Then
      expect(results.length, equals(1));
      expect(results.first.id, equals('feb-1'));
    });
  });

  group('Performance Tests', () {
    test('should handle 1000+ receipts efficiently (TEST-001)', () async {
      // Given - Create 1000 receipts spread across 3 months
      final receipts = <Receipt>[];
      final baseDate = DateTime(2024, 1, 1);

      for (int i = 0; i < 1000; i++) {
        final dayOffset = i % 90; // Spread across 90 days
        final date = baseDate.add(Duration(days: dayOffset));
        
        receipts.add(createTestReceipt(
          id: 'perf-$i',
          merchantName: 'Store $i',
          receiptDate: '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}',
          totalAmount: 10.0 + (i % 100),
        ));
      }

      // Insert all receipts
      final stopwatch = Stopwatch()..start();
      for (final receipt in receipts) {
        await repository.createReceipt(receipt);
      }
      stopwatch.stop();
      
      print('Inserted 1000 receipts in ${stopwatch.elapsedMilliseconds}ms');

      // When - Query a month's worth of data
      stopwatch.reset();
      stopwatch.start();
      final results = await repository.getReceiptsByDateRange(
        DateTime(2024, 1, 1),
        DateTime(2024, 1, 31),
      );
      stopwatch.stop();

      // Then
      print('Queried date range in ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(100), 
        reason: 'Date range query should complete within 100ms with index');
      expect(results.length, greaterThan(300)); // Should have ~333 receipts in January
    });

    test('should efficiently query edge dates', () async {
      // Given - Create receipts at date boundaries
      final receipts = [
        createTestReceipt(
          id: 'edge-1',
          receiptDate: '01/01/2024', // Start of year
        ),
        createTestReceipt(
          id: 'edge-2',
          receiptDate: '12/31/2024', // End of year
        ),
        createTestReceipt(
          id: 'edge-3',
          receiptDate: '02/29/2024', // Leap day
        ),
      ];

      for (final receipt in receipts) {
        await repository.createReceipt(receipt);
      }

      // When - Query entire year
      final results = await repository.getReceiptsByDateRange(
        DateTime(2024, 1, 1),
        DateTime(2024, 12, 31),
      );

      // Then
      expect(results.length, equals(3));
      expect(results.any((r) => r.receiptDate == '01/01/2024'), isTrue);
      expect(results.any((r) => r.receiptDate == '12/31/2024'), isTrue);
      expect(results.any((r) => r.receiptDate == '02/29/2024'), isTrue);
    });
  });

  group('Batch Operations', () {
    test('should retrieve receipts by batch ID', () async {
      // Given
      final batch1 = [
        createTestReceipt(id: 'b1-1', batchId: 'batch-001'),
        createTestReceipt(id: 'b1-2', batchId: 'batch-001'),
      ];
      final batch2 = [
        createTestReceipt(id: 'b2-1', batchId: 'batch-002'),
      ];

      for (final receipt in [...batch1, ...batch2]) {
        await repository.createReceipt(receipt);
      }

      // When
      final results = await repository.getReceiptsByBatchId('batch-001');

      // Then
      expect(results.length, equals(2));
      expect(results.every((r) => r.batchId == 'batch-001'), isTrue);
    });
  });

  group('Pagination', () {
    setUp(() async {
      // Create 50 receipts for pagination tests
      for (int i = 0; i < 50; i++) {
        await repository.createReceipt(
          createTestReceipt(
            id: 'page-$i',
            merchantName: 'Store $i',
            capturedAt: DateTime.now().subtract(Duration(hours: i)),
          ),
        );
      }
    });

    test('should paginate results correctly', () async {
      // When - Get first page
      final page1 = await repository.getReceiptsPaginated(0, 10);
      final page2 = await repository.getReceiptsPaginated(10, 10);
      final page3 = await repository.getReceiptsPaginated(20, 10);

      // Then
      expect(page1.length, equals(10));
      expect(page2.length, equals(10));
      expect(page3.length, equals(10));

      // Check no overlap
      final page1Ids = page1.map((r) => r.id).toSet();
      final page2Ids = page2.map((r) => r.id).toSet();
      expect(page1Ids.intersection(page2Ids), isEmpty);
    });

    test('should return remaining items on last page', () async {
      // When
      final lastPage = await repository.getReceiptsPaginated(45, 10);

      // Then
      expect(lastPage.length, equals(5));
    });

    test('should return empty list when offset exceeds count', () async {
      // When
      final emptyPage = await repository.getReceiptsPaginated(100, 10);

      // Then
      expect(emptyPage, isEmpty);
    });
  });

  group('Count Operations', () {
    test('should return correct receipt count', () async {
      // Given
      for (int i = 0; i < 25; i++) {
        await repository.createReceipt(createTestReceipt(id: 'count-$i'));
      }

      // When
      final count = await repository.getReceiptCount();

      // Then
      expect(count, equals(25));
    });

    test('should return zero for empty database', () async {
      // When
      final count = await repository.getReceiptCount();

      // Then
      expect(count, equals(0));
    });
  });
}