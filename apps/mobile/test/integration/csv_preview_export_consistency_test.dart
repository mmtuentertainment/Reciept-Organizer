import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/domain/services/csv_export_service.dart';
import 'package:receipt_organizer/features/export/domain/services/csv_preview_service.dart';

import 'csv_preview_export_consistency_test.mocks.dart';

@GenerateMocks([])
void main() {
  group('CSV Preview-Export Consistency Test (DATA-001)', () {
    late CSVPreviewService previewService;
    late CSVExportService exportService;

    setUp(() {
      exportService = CSVExportService();
      previewService = CSVPreviewService(exportService: exportService);
    });

    test('E2E: Preview exactly matches first 5 rows of actual export', () async {
      // Arrange - Create test receipts
      final receipts = List.generate(10, (index) {
        return Receipt(
          id: 'receipt_$index',
          merchantName: 'Test Merchant $index',
          totalAmount: 100.0 + (index * 10),
          taxAmount: 10.0 + index,
          receiptDate: '01/${15 + index}/2024',
          notes: index % 2 == 0 ? 'Note $index' : null,
          imagePath: '/path/to/image_$index.jpg',
          status: ReceiptStatus.ready,
          createdAt: DateTime(2024, 1, 15 + index),
          updatedAt: DateTime(2024, 1, 15 + index),
        );
      });

      // Test all formats to ensure consistency
      final formats = [
        ExportFormat.generic,
        ExportFormat.quickbooks,
        ExportFormat.xero,
      ];

      for (final format in formats) {
        // Act - Generate preview
        final previewResult = await previewService.generatePreview(receipts, format);
        
        // Act - Generate actual export
        final exportContent = exportService.generateCSVContent(receipts, format);
        
        // Parse export content to compare
        final exportLines = exportContent.split('\n')
            .where((line) => line.trim().isNotEmpty)
            .take(6) // Header + first 5 rows
            .toList();
        
        // Convert export lines to list of lists for comparison
        final exportRows = exportLines.map((line) {
          // Simple CSV parsing for comparison
          return line.split(',').map((cell) {
            // Remove quotes if present
            String cleaned = cell.trim();
            if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
              cleaned = cleaned.substring(1, cleaned.length - 1);
            }
            return cleaned;
          }).toList();
        }).toList();

        // Assert - Preview matches export exactly
        expect(
          previewResult.previewRows.length,
          equals(exportRows.length),
          reason: 'Preview row count should match export for format: ${format.name}',
        );

        // Compare each row
        for (int i = 0; i < previewResult.previewRows.length; i++) {
          expect(
            previewResult.previewRows[i],
            equals(exportRows[i]),
            reason: 'Row $i should match exactly for format: ${format.name}',
          );
        }

        // Verify total count is accurate
        expect(
          previewResult.totalCount,
          equals(receipts.length),
          reason: 'Total count should match receipt count for format: ${format.name}',
        );
      }
    });

    test('E2E: Preview handles special characters consistently with export', () async {
      // Arrange - Receipts with special characters
      final receipts = [
        Receipt(
          id: 'special_1',
          merchantName: 'Store, Inc.', // Comma in name
          totalAmount: 1000.50,
          taxAmount: 100.05,
          receiptDate: '01/15/2024',
          notes: 'Note with "quotes" and, commas',
          imagePath: '/path/to/image.jpg',
          status: ReceiptStatus.ready,
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
        ),
        Receipt(
          id: 'special_2',
          merchantName: 'Test & Co.', // Ampersand
          totalAmount: 500.00,
          taxAmount: 50.00,
          receiptDate: '01/16/2024',
          notes: 'Line 1\nLine 2', // Newline
          imagePath: '/path/to/image.jpg',
          status: ReceiptStatus.ready,
          createdAt: DateTime(2024, 1, 16),
          updatedAt: DateTime(2024, 1, 16),
        ),
      ];

      // Act - Generate preview and export
      final format = ExportFormat.generic;
      final previewResult = await previewService.generatePreview(receipts, format);
      final exportContent = exportService.generateCSVContent(receipts, format);
      
      // Parse first 3 lines (header + 2 data rows)
      final exportLines = exportContent.split('\n')
          .where((line) => line.trim().isNotEmpty)
          .take(3)
          .toList();

      // Assert - Special characters handled consistently
      expect(previewResult.previewRows.length, equals(3));
      
      // Both should properly escape/quote special characters
      for (int i = 0; i < previewResult.previewRows.length; i++) {
        final previewRow = previewResult.previewRows[i].join(',');
        final exportRow = exportLines[i];
        
        // Both should have quotes around fields with special characters
        if (i > 0) { // Skip header row
          expect(
            exportRow.contains('"'),
            isTrue,
            reason: 'Export should quote fields with special characters',
          );
          // Preview should also handle special characters
          expect(
            previewResult.previewRows[i].any((cell) => 
              cell.contains(',') || cell.contains('"') || cell.contains('\n')),
            isTrue,
            reason: 'Preview should preserve special characters',
          );
        }
      }
    });

    test('E2E: Empty data consistency between preview and export', () async {
      // Arrange - Empty receipt list
      final receipts = <Receipt>[];
      
      // Act
      final format = ExportFormat.quickbooks;
      final previewResult = await previewService.generatePreview(receipts, format);
      final exportContent = exportService.generateCSVContent(receipts, format);
      
      // Assert
      expect(previewResult.totalCount, equals(0));
      expect(previewResult.previewRows.length, equals(1)); // Only header
      
      // Export should also only have header
      final exportLines = exportContent.split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();
      expect(exportLines.length, equals(1)); // Only header
      
      // Headers should match
      final exportHeader = exportLines[0].split(',').map((cell) {
        String cleaned = cell.trim();
        if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
          cleaned = cleaned.substring(1, cleaned.length - 1);
        }
        return cleaned;
      }).toList();
      
      expect(previewResult.previewRows[0], equals(exportHeader));
    });

    test('E2E: Format-specific fields match between preview and export', () async {
      // Arrange
      final receipts = [
        Receipt(
          id: 'format_test',
          merchantName: 'Test Store',
          totalAmount: 150.00,
          taxAmount: 15.00,
          receiptDate: '03/20/2024',
          notes: 'Format test',
          imagePath: '/path/to/image.jpg',
          status: ReceiptStatus.ready,
          createdAt: DateTime(2024, 3, 20),
          updatedAt: DateTime(2024, 3, 20),
        ),
      ];

      // Test QuickBooks format
      var preview = await previewService.generatePreview(receipts, ExportFormat.quickbooks);
      var export = exportService.generateCSVContent(receipts, ExportFormat.quickbooks);
      
      expect(preview.previewRows[0], contains('Date'));
      expect(preview.previewRows[0], contains('Vendor'));
      expect(export, contains('Date'));
      expect(export, contains('Vendor'));
      
      // Test Xero format
      preview = await previewService.generatePreview(receipts, ExportFormat.xero);
      export = exportService.generateCSVContent(receipts, ExportFormat.xero);
      
      expect(preview.previewRows[0], contains('Date'));
      expect(preview.previewRows[0], contains('Supplier'));
      expect(export, contains('Date'));
      expect(export, contains('Supplier'));
      
      // Test Generic format
      preview = await previewService.generatePreview(receipts, ExportFormat.generic);
      export = exportService.generateCSVContent(receipts, ExportFormat.generic);
      
      expect(preview.previewRows[0], contains('Date'));
      expect(preview.previewRows[0], contains('Merchant'));
      expect(export, contains('Date'));
      expect(export, contains('Merchant'));
    });
  });
}