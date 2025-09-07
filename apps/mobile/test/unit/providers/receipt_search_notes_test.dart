import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/features/receipts/providers/receipt_list_provider.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';

void main() {
  group('Receipt Search with Notes', () {
    late ProviderContainer container;
    late ReceiptListNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(receiptListProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    Receipt createReceipt({
      required String id,
      String? merchantName,
      String? date,
      double? total,
      String? notes,
    }) {
      return Receipt(
        id: id,
        imageUri: 'path/to/image.jpg',
        notes: notes,
        ocrResults: merchantName != null || date != null || total != null
            ? ProcessingResult(
                merchant: FieldData(value: merchantName ?? '', confidence: 90, originalText: merchantName ?? ''),
                date: FieldData(value: date ?? '', confidence: 90, originalText: date ?? ''),
                total: FieldData(value: total ?? 0.0, confidence: 90, originalText: total?.toString() ?? '0'),
                tax: FieldData(value: 0.0, confidence: 90, originalText: '0'),
                overallConfidence: 90,
                processingDurationMs: 1000,
              )
            : null,
      );
    }

    test('should find receipts by notes content', () {
      // Given
      final receipts = [
        createReceipt(
          id: '1',
          merchantName: 'Store A',
          notes: 'Business meeting with John',
        ),
        createReceipt(
          id: '2',
          merchantName: 'Store B',
          notes: 'Office supplies purchase',
        ),
        createReceipt(
          id: '3',
          merchantName: 'Store C',
          notes: 'Quarterly tax payment',
        ),
      ];

      // When
      notifier.state = notifier.state.copyWith(
        receipts: receipts,
        filteredReceipts: receipts,
      );
      notifier.searchReceipts('meeting');

      // Then
      final state = container.read(receiptListProvider);
      expect(state.filteredReceipts.length, equals(1));
      expect(state.filteredReceipts.first.id, equals('1'));
      expect(state.filteredReceipts.first.notes, contains('meeting'));
    });

    test('should find receipts with partial notes match', () {
      // Given
      final receipts = [
        createReceipt(
          id: '1',
          notes: 'Important quarterly business expense',
        ),
        createReceipt(
          id: '2',
          notes: 'Quick lunch',
        ),
        createReceipt(
          id: '3',
          notes: 'Quarterly review materials',
        ),
      ];

      // When
      notifier.state = notifier.state.copyWith(
        receipts: receipts,
        filteredReceipts: receipts,
      );
      notifier.searchReceipts('quarter');

      // Then
      final state = container.read(receiptListProvider);
      expect(state.filteredReceipts.length, equals(2));
      expect(state.filteredReceipts.map((r) => r.id).toSet(), equals({'1', '3'}));
    });

    test('should be case-insensitive when searching notes', () {
      // Given
      final receipts = [
        createReceipt(
          id: '1',
          notes: 'IMPORTANT MEETING',
        ),
        createReceipt(
          id: '2',
          notes: 'Important Document',
        ),
        createReceipt(
          id: '3',
          notes: 'Not relevant',
        ),
      ];

      // When
      notifier.state = notifier.state.copyWith(
        receipts: receipts,
        filteredReceipts: receipts,
      );
      notifier.searchReceipts('important');

      // Then
      final state = container.read(receiptListProvider);
      expect(state.filteredReceipts.length, equals(2));
      expect(state.filteredReceipts.map((r) => r.id).toSet(), equals({'1', '2'}));
    });

    test('should handle receipts with null notes', () {
      // Given
      final receipts = [
        createReceipt(
          id: '1',
          notes: 'Has notes',
        ),
        createReceipt(
          id: '2',
          notes: null,
        ),
        createReceipt(
          id: '3',
          notes: '',
        ),
      ];

      // When
      notifier.state = notifier.state.copyWith(
        receipts: receipts,
        filteredReceipts: receipts,
      );
      notifier.searchReceipts('notes');

      // Then
      final state = container.read(receiptListProvider);
      expect(state.filteredReceipts.length, equals(1));
      expect(state.filteredReceipts.first.id, equals('1'));
    });

    test('should search across multiple fields including notes', () {
      // Given
      final receipts = [
        createReceipt(
          id: '1',
          merchantName: 'Office Depot',
          notes: 'Printer supplies',
        ),
        createReceipt(
          id: '2',
          merchantName: 'Restaurant',
          notes: 'Office party catering',
        ),
        createReceipt(
          id: '3',
          merchantName: 'Gas Station',
          notes: 'Trip to client',
        ),
      ];

      // When
      notifier.state = notifier.state.copyWith(
        receipts: receipts,
        filteredReceipts: receipts,
      );
      notifier.searchReceipts('office');

      // Then
      final state = container.read(receiptListProvider);
      expect(state.filteredReceipts.length, equals(2));
      expect(state.filteredReceipts.map((r) => r.id).toSet(), equals({'1', '2'}));
    });

    test('should handle special characters in notes search', () {
      // Given
      final receipts = [
        createReceipt(
          id: '1',
          notes: 'Meeting @ 3PM',
        ),
        createReceipt(
          id: '2',
          notes: 'Email: john@example.com',
        ),
        createReceipt(
          id: '3',
          notes: r'Cost: $50.00',
        ),
      ];

      // When
      notifier.state = notifier.state.copyWith(
        receipts: receipts,
        filteredReceipts: receipts,
      );
      notifier.searchReceipts('@');

      // Then
      final state = container.read(receiptListProvider);
      expect(state.filteredReceipts.length, equals(2));
      expect(state.filteredReceipts.map((r) => r.id).toSet(), equals({'1', '2'}));
    });

    test('should clear search and show all receipts', () {
      // Given
      final receipts = [
        createReceipt(id: '1', notes: 'Note 1'),
        createReceipt(id: '2', notes: 'Note 2'),
        createReceipt(id: '3', notes: 'Note 3'),
      ];

      // When
      notifier.state = notifier.state.copyWith(
        receipts: receipts,
        filteredReceipts: receipts,
      );
      notifier.searchReceipts('Note 1');
      expect(container.read(receiptListProvider).filteredReceipts.length, equals(1));
      
      notifier.clearSearch();

      // Then
      final state = container.read(receiptListProvider);
      expect(state.searchQuery, isEmpty);
      expect(state.filteredReceipts.length, equals(3));
    });

    test('should maintain search when updating a receipt', () {
      // Given
      final receipts = [
        createReceipt(id: '1', notes: 'Tax related'),
        createReceipt(id: '2', notes: 'Personal'),
        createReceipt(id: '3', notes: 'Tax payment'),
      ];

      // When
      notifier.state = notifier.state.copyWith(
        receipts: receipts,
        filteredReceipts: receipts,
      );
      notifier.searchReceipts('tax');
      
      // Update one of the filtered receipts
      final updatedReceipt = createReceipt(
        id: '1',
        notes: 'Tax related - Updated',
      );
      notifier.updateReceipt(updatedReceipt);

      // Then
      final state = container.read(receiptListProvider);
      expect(state.filteredReceipts.length, equals(2));
      expect(state.filteredReceipts.first.notes, contains('Updated'));
      expect(state.searchQuery, equals('tax'));
    });

    test('should handle empty search query', () {
      // Given
      final receipts = [
        createReceipt(id: '1', notes: 'Note 1'),
        createReceipt(id: '2', notes: 'Note 2'),
      ];

      // When
      notifier.state = notifier.state.copyWith(
        receipts: receipts,
        filteredReceipts: receipts,
      );
      notifier.searchReceipts('');

      // Then
      final state = container.read(receiptListProvider);
      expect(state.filteredReceipts.length, equals(receipts.length));
      expect(state.filteredReceipts, equals(receipts));
    });
  });
}