/// Minimal CSV Export Tests
/// Testing only critical export functionality

import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/domain/services/csv_export_service.dart';
import 'package:receipt_organizer/features/export/services/export_format_validator.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';

void main() {
  group('CSV Export - Core Tests', () {
    late CSVExportService csvService;
    
    setUp(() {
      csvService = CSVExportService();
    });

    test('should generate QuickBooks CSV format', () {
      // Given
      final receipts = <Receipt>[
        Receipt(
          id: 'test-1',
          imageUri: '/image1.jpg',
          capturedAt: DateTime(2024, 12, 6),
          ocrResults: ProcessingResult(
            merchant: FieldData(value: 'Test Store', confidence: 0.95, originalText: 'Test Store'),
            total: FieldData(value: '25.99', confidence: 0.98, originalText: '25.99'),
            date: FieldData(value: '12/06/2024', confidence: 0.92, originalText: '12/06/2024'),
            overallConfidence: 0.95,
            processingDurationMs: 100,
            allText: ['Test Store', '25.99', '12/06/2024'],
          ),
        ),
      ];

      // When
      final csv = csvService.generateCSVContent(receipts, ExportFormat.quickBooks3Column);

      // Then
      expect(csv, contains('Date,Amount,Payee,Category'));
      expect(csv, contains('12/06/2024'));
      expect(csv, contains('25.99'));
      expect(csv, contains('Test Store'));
    });

    test('should generate Xero CSV format', () {
      // Given
      final receipts = <Receipt>[
        Receipt(
          id: 'test-1',
          imageUri: '/image1.jpg',
          capturedAt: DateTime(2024, 12, 6),
          ocrResults: ProcessingResult(
            merchant: FieldData(value: 'Coffee Shop', confidence: 0.95, originalText: 'Coffee Shop'),
            total: FieldData(value: '4.50', confidence: 0.98, originalText: '4.50'),
            date: FieldData(value: '12/06/2024', confidence: 0.92, originalText: '12/06/2024'),
            overallConfidence: 0.95,
            processingDurationMs: 100,
            allText: ['Coffee Shop', '4.50', '12/06/2024'],
          ),
        ),
      ];

      // When
      final csv = csvService.generateCSVContent(receipts, ExportFormat.xero);

      // Then
      expect(csv, contains('Date,Amount,Payee'));
      expect(csv, contains('12/06/2024'));
      expect(csv, contains('4.50'));
      expect(csv, contains('Coffee Shop'));
    });

    test('should handle missing data gracefully', () {
      // Given - Receipt with minimal data
      final receipts = <Receipt>[
        Receipt(
          id: 'test-1',
          imageUri: '/image1.jpg',
          capturedAt: DateTime.now(),
          // No OCR results
        ),
      ];

      // When/Then - Should not throw
      expect(
        () => csvService.generateCSVContent(receipts, ExportFormat.generic),
        returnsNormally,
      );
      
      final csv = csvService.generateCSVContent(receipts, ExportFormat.generic);
      expect(csv, contains('Receipt ID'));
      expect(csv, contains('test-1'));
    });
  });
}