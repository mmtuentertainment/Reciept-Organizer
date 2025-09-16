/// Minimal Receipt Repository Tests
/// Following CleanArchitectureTodoApp pattern

import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/data/repositories/receipt_repository.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize FFI for desktop testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Receipt Repository - Core Tests', () {
    late ReceiptRepository repository;
    
    setUp(() async {
      repository = ReceiptRepository();
      // Clean up any existing data
      final db = await repository.database;
      await db.delete('receipts');
    });

    test('should create a receipt', () async {
      // Given
      final receipt = Receipt(
        id: 'test-123',
        imageUri: '/path/to/image.jpg',
        capturedAt: DateTime.now(),
      );

      // When
      final created = await repository.createReceipt(receipt);

      // Then
      expect(created.id, equals('test-123'));
      
      // Verify it was saved
      final retrieved = await repository.getReceiptById('test-123');
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('test-123'));
    });

    test('should retrieve receipts by date range', () async {
      // Given - Create test receipts
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));
      
      await repository.createReceipt(Receipt(
        id: 'yesterday',
        imageUri: '/image1.jpg',
        capturedAt: yesterday,
        receiptDate: yesterday,
        ocrResults: ProcessingResult(
          date: FieldData(value: '${yesterday.month.toString().padLeft(2, '0')}/${yesterday.day.toString().padLeft(2, '0')}/${yesterday.year}', confidence: 0.9, originalText: 'date'),
          overallConfidence: 0.9,
          processingDurationMs: 100,
          allText: [],
        ),
      ));
      
      await repository.createReceipt(Receipt(
        id: 'today',
        imageUri: '/image2.jpg',
        capturedAt: now,
        receiptDate: now,
        ocrResults: ProcessingResult(
          date: FieldData(value: '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}', confidence: 0.9, originalText: 'date'),
          overallConfidence: 0.9,
          processingDurationMs: 100,
          allText: [],
        ),
      ));
      
      await repository.createReceipt(Receipt(
        id: 'tomorrow',
        imageUri: '/image3.jpg',
        capturedAt: tomorrow,
        receiptDate: tomorrow,
        ocrResults: ProcessingResult(
          date: FieldData(value: '${tomorrow.month.toString().padLeft(2, '0')}/${tomorrow.day.toString().padLeft(2, '0')}/${tomorrow.year}', confidence: 0.9, originalText: 'date'),
          overallConfidence: 0.9,
          processingDurationMs: 100,
          allText: [],
        ),
      ));

      // When - Query for today's receipts
      final receipts = await repository.getReceiptsByDateRange(
        DateTime(now.year, now.month, now.day),
        DateTime(now.year, now.month, now.day, 23, 59, 59),
      );

      // Then
      expect(receipts.length, greaterThanOrEqualTo(1));
    });

    test('should delete a receipt', () async {
      // Given
      final receipt = Receipt(
        id: 'to-delete',
        imageUri: '/image.jpg',
        capturedAt: DateTime.now(),
      );
      await repository.createReceipt(receipt);
      
      // Verify it exists
      var retrieved = await repository.getReceiptById('to-delete');
      expect(retrieved, isNotNull);

      // When
      await repository.deleteReceipt('to-delete');

      // Then
      retrieved = await repository.getReceiptById('to-delete');
      expect(retrieved, isNull);
    });
  });
}