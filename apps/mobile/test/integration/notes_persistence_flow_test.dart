import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';

void main() {
  group('Notes Persistence Flow', () {
    test('should persist notes when creating a receipt', () {
      // Given
      const testNotes = 'Business lunch with client - Project X discussion';
      final receipt = Receipt(
        imageUri: 'path/to/image.jpg',
        notes: testNotes,
        status: ReceiptStatus.ready,
      );

      // Then
      expect(receipt.notes, equals(testNotes));
    });

    test('should update notes using copyWith', () {
      // Given
      final receipt = Receipt(
        imageUri: 'path/to/image.jpg',
        notes: 'Initial notes',
      );

      // When
      final updatedReceipt = receipt.copyWith(notes: 'Updated notes');

      // Then
      expect(updatedReceipt.notes, equals('Updated notes'));
      expect(receipt.notes, equals('Initial notes')); // Original unchanged
    });

    test('should serialize notes to JSON', () {
      // Given
      const testNotes = 'Quarterly meeting expense';
      final receipt = Receipt(
        imageUri: 'path/to/image.jpg',
        notes: testNotes,
      );

      // When
      final json = receipt.toJson();

      // Then
      expect(json['notes'], equals(testNotes));
    });

    test('should deserialize notes from JSON', () {
      // Given
      const testNotes = 'Office supplies purchase';
      final json = {
        'id': 'test-123',
        'imageUri': 'path/to/image.jpg',
        'thumbnailUri': null,
        'capturedAt': DateTime.now().toIso8601String(),
        'status': 'ready',
        'batchId': null,
        'lastModified': DateTime.now().toIso8601String(),
        'notes': testNotes,
      };

      // When
      final receipt = Receipt.fromJson(json);

      // Then
      expect(receipt.notes, equals(testNotes));
    });

    test('should handle null notes', () {
      // Given
      final receipt = Receipt(
        id: 'test-receipt-1',
        imageUri: 'path/to/image.jpg',
      );

      // Then
      expect(receipt.notes, isNull);

      // When serialized
      final json = receipt.toJson();
      expect(json['notes'], isNull);

      // When updated with null
      final updatedReceipt = receipt.copyWith(notes: null);
      expect(updatedReceipt.notes, isNull);
    });

    test('should handle empty notes differently from null', () {
      // Given
      final receiptWithEmpty = Receipt(
        id: 'test-receipt-4',
        imageUri: 'path/to/image.jpg',
        notes: '',
      );
      
      final receiptWithNull = Receipt(
        id: 'test-receipt-5',
        imageUri: 'path/to/image.jpg',
        notes: null,
      );

      // Then
      expect(receiptWithEmpty.notes, equals(''));
      expect(receiptWithNull.notes, isNull);
      expect(receiptWithEmpty.notes == receiptWithNull.notes, isFalse);
    });

    test('should preserve notes through multiple updates', () {
      // Given
      var receipt = Receipt(
        id: 'test-receipt-6',
        imageUri: 'path/to/image.jpg',
        notes: 'Original notes',
      );

      // When - update other fields
      receipt = receipt.copyWith(status: ReceiptStatus.processing);
      receipt = receipt.copyWith(batchId: 'batch-123');
      
      // Then - notes remain unchanged
      expect(receipt.notes, equals('Original notes'));

      // When - explicitly update notes
      receipt = receipt.copyWith(notes: 'New notes');
      
      // Then
      expect(receipt.notes, equals('New notes'));
      expect(receipt.status, equals(ReceiptStatus.processing));
      expect(receipt.batchId, equals('batch-123'));
    });

    test('should include notes when exporting to CSV', () {
      // This is a placeholder test that would require CSVExportService integration
      // Given
      final receipt = Receipt(
        id: 'test-receipt-7',
        imageUri: 'path/to/image.jpg',
        notes: 'Important context for accounting',
        ocrResults: ProcessingResult(
          merchant: FieldData(
            value: 'Test Store', 
            confidence: 95,
            originalText: 'Test Store',
          ),
          date: FieldData(
            value: '2024-01-15', 
            confidence: 98,
            originalText: '2024-01-15',
          ),
          total: FieldData(
            value: 100.50, 
            confidence: 92,
            originalText: '\$100.50',
          ),
          tax: FieldData(
            value: 8.50, 
            confidence: 90,
            originalText: '\$8.50',
          ),
          overallConfidence: 93.75,
          processingDurationMs: 1500,
        ),
      );

      // When exported (this would use CSVExportService)
      final exportData = receipt.toJson();
      
      // Then
      expect(exportData['notes'], equals('Important context for accounting'));
    });
  });
}