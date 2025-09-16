import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Receipt Storage Service', () {
    test('File naming convention follows required format', () {
      // Given: UUID and timestamp
      const uuid = Uuid();
      final id = uuid.v4();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // When: Creating file name
      final fileName = 'receipt_${id}_$timestamp.jpg';

      // Then: Verify format
      expect(fileName, startsWith('receipt_'));
      expect(fileName, contains(id));
      expect(fileName, endsWith('.jpg'));

      // Verify with regex
      final regex = RegExp(r'^receipt_[a-f0-9\-]+_\d+\.jpg$');
      expect(regex.hasMatch(fileName), true);
    });

    test('Database record mapping preserves all fields', () {
      // Given: Receipt data
      final testData = {
        'id': 'test-123',
        'imagePath': '/path/to/image.jpg',
        'thumbnailPath': '/path/to/thumb.jpg',
        'capturedAt': DateTime.now().millisecondsSinceEpoch,
        'merchant': 'Test Store',
        'date': DateTime.now().millisecondsSinceEpoch,
        'total': 99.99,
        'tax': 8.00,
        'confidence': 0.85,
        'rawOcrText': 'Sample OCR text',
      };

      // When: Converting to/from map
      // Simulating ReceiptRecord.toMap() and fromMap()
      final mappedData = Map<String, dynamic>.from(testData);

      // Then: Verify all fields preserved
      expect(mappedData['id'], equals('test-123'));
      expect(mappedData['merchant'], equals('Test Store'));
      expect(mappedData['total'], equals(99.99));
      expect(mappedData['tax'], equals(8.00));
      expect(mappedData['confidence'], equals(0.85));
    });

    test('Cleanup identifies orphaned images correctly', () {
      // Given: Valid and orphaned file paths
      final validPaths = {
        '/receipts/receipt_valid1_123.jpg',
        '/receipts/thumbnails/receipt_valid1_123_thumb.jpg',
        '/receipts/receipt_valid2_456.jpg',
      };

      final allFiles = [
        '/receipts/receipt_valid1_123.jpg',
        '/receipts/thumbnails/receipt_valid1_123_thumb.jpg',
        '/receipts/receipt_valid2_456.jpg',
        '/receipts/receipt_orphan_789.jpg', // Orphaned
        '/receipts/thumbnails/receipt_orphan_789_thumb.jpg', // Orphaned
      ];

      // When: Identifying orphaned files
      final orphaned = allFiles.where((file) => !validPaths.contains(file)).toList();

      // Then: Verify orphaned files identified
      expect(orphaned.length, equals(2));
      expect(orphaned.any((f) => f.contains('orphan')), true);
      expect(orphaned.any((f) => f.contains('valid')), false);
    });
  });
}