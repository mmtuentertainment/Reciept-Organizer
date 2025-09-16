import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/features/export/services/export_format_validator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:receipt_organizer/features/export/presentation/pages/export_screen.dart';
import 'package:receipt_organizer/features/export/presentation/providers/export_provider.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/export_progress_dialog.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/export_history_sheet.dart';
import 'package:receipt_organizer/domain/services/csv_export_service.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/core/repositories/interfaces/i_receipt_repository.dart';
import 'dart:io';
import '../fixtures/test_data_generator.dart';

// Mock classes
class MockReceiptRepository extends Mock implements IReceiptRepository {}
class MockCSVExportService extends Mock implements ICSVExportService {}
class MockFile extends Mock implements File {}

void main() {
  late MockReceiptRepository mockRepository;
  late MockCSVExportService mockCSVService;
  late TestDataGenerator testDataGenerator;
  
  setUpAll(() {
    registerFallbackValue(ExportFormat.quickBooks3Column);
    registerFallbackValue(DateTime.now());
    registerFallbackValue(<Receipt>[]);
  });
  
  setUp(() {
    mockRepository = MockReceiptRepository();
    mockCSVService = MockCSVExportService();
    testDataGenerator = TestDataGenerator();
  });
  
  group('Complete Export Workflow', () {
    testWidgets('should successfully complete full export flow', (tester) async {
      // Arrange
      final receipts = testDataGenerator.generateReceipts(count: 10)
          .map((data) => Receipt.fromJson(data))
          .toList();
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 12, 31);
      
      when(() => mockRepository.getReceiptsByDateRange(any(), any()))
          .thenAnswer((_) async => receipts);
      
      when(() => mockCSVService.validateForExport(any(), any()))
          .thenAnswer((_) async => ValidationResult(
            isValid: true,
            warnings: [],
            errors: [],
            validCount: 10,
            totalCount: 10,
          ));
      
      when(() => mockCSVService.createBatches(any(), any()))
          .thenReturn([receipts]);
      
      when(() => mockCSVService.exportWithProgress(any(), any(), customFileName: any(named: 'customFileName')))
          .thenAnswer((_) => Stream<double>.fromIterable([
            0.0, 0.2, 0.4, 0.6, 0.8, 1.0
          ]));
      
      when(() => mockCSVService.exportToCSV(any(), any(), customFileName: any(named: 'customFileName')))
          .thenAnswer((_) async => ExportResult.success(
            '/storage/emulated/0/Download/receipts_export.csv',
            'receipts_export.csv',
            receipts.length,
          ));
      
      // Build the widget
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            csvExportServiceProvider.overrideWithValue(mockCSVService),
            exportReceiptRepositoryProvider.overrideWith((ref) async => mockRepository),
          ],
          child: MaterialApp(
            home: const ExportScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Step 1: Select format
      expect(find.text('Export Receipts'), findsOneWidget);
      expect(find.byType(SegmentedButton<ExportFormat>), findsOneWidget);
      
      // Step 2: Select date range
      await tester.tap(find.text('Choose dates'));
      await tester.pumpAndSettle();
      
      // In the date picker dialog
      expect(find.text('Select date range'), findsOneWidget);
      await tester.tap(find.text('CONFIRM'));
      await tester.pumpAndSettle();
      
      // Step 3: Start export
      await tester.tap(find.text('Export'));
      await tester.pump();
      
      // Step 4: Verify progress dialog appears
      expect(find.text('Exporting Receipts'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      
      // Step 5: Wait for export to complete
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      
      // Step 6: Verify success feedback
      expect(find.text('Export successful'), findsOneWidget);
      
      // Verify all methods were called
      verify(() => mockRepository.getReceiptsByDateRange(any(), any())).called(1);
      verify(() => mockCSVService.validateForExport(any(), any())).called(1);
      verify(() => mockCSVService.exportWithProgress(any(), any(), customFileName: any(named: 'customFileName'))).called(1);
    });
    
    testWidgets('should handle export errors gracefully', (tester) async {
      // Arrange
      final receipts = testDataGenerator.generateReceipts(count:5)
          .map((data) => Receipt.fromJson(data))
          .toList();
      final receiptCount = receipts.length;

      when(() => mockRepository.getReceiptsByDateRange(any(), any()))
          .thenAnswer((_) async => receipts);

      when(() => mockCSVService.validateForExport(any(), any()))
          .thenAnswer((_) async => ValidationResult(
            isValid: true,
            warnings: [],
            errors: [],
            validCount: 5,
            totalCount: 5,
          ));
      
      when(() => mockCSVService.exportWithProgress(any(), any(), customFileName: any(named: 'customFileName')))
          .thenAnswer((_) => Stream<double>.error('Export failed: Disk full'));
      
      // Build widget
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            csvExportServiceProvider.overrideWithValue(mockCSVService),
            exportReceiptRepositoryProvider.overrideWith((ref) async => mockRepository),
          ],
          child: MaterialApp(
            home: const ExportScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Select dates and export
      await tester.tap(find.text('Choose dates'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONFIRM'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export'));
      await tester.pump();
      
      // Wait for error
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      
      // Verify error is shown
      expect(find.text('Export failed'), findsOneWidget);
      expect(find.textContaining('Disk full'), findsOneWidget);
    });
    
    testWidgets('should show validation warnings before export', (tester) async {
      // Arrange
      final receipts = testDataGenerator.generateReceipts(count:3)
          .map((data) => Receipt.fromJson(data))
          .toList();
      final receiptCount = receipts.length;
      
      when(() => mockRepository.getReceiptsByDateRange(any(), any()))
          .thenAnswer((_) async => receipts);
      
      when(() => mockCSVService.validateForExport(any(), any()))
          .thenAnswer((_) async => ValidationResult(
            isValid: true,
            warnings: ['2 receipts have missing merchant names'],
            errors: [],
            validCount: 3,
            totalCount: 3,
          ));
      
      // Build widget
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            csvExportServiceProvider.overrideWithValue(mockCSVService),
            exportReceiptRepositoryProvider.overrideWith((ref) async => mockRepository),
          ],
          child: MaterialApp(
            home: const ExportScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Select dates
      await tester.tap(find.text('Choose dates'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONFIRM'));
      await tester.pumpAndSettle();
      
      // Verify validation results are shown
      expect(find.textContaining('2 receipts have missing merchant names'), findsAny);
      expect(find.byIcon(Icons.warning), findsAny);
    });
    
    testWidgets('should display export history', (tester) async {
      // Build widget with export history
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exportHistoryProvider.overrideWithValue(
              ExportHistory(records: [
                ExportRecord(
                  id: '1',
                  exportDate: DateTime.now(),
                  format: ExportFormat.quickBooks3Column,
                  receiptCount: 25,
                  filePath: '/storage/receipts.csv',
                  fileName: 'receipts.csv',
                  success: true,
                ),
                ExportRecord(
                  id: '2',
                  exportDate: DateTime.now().subtract(const Duration(days: 1)),
                  format: ExportFormat.xero,
                  receiptCount: 15,
                  filePath: '/storage/xero_export.csv',
                  fileName: 'xero_export.csv',
                  success: false,
                  error: 'Network error',
                ),
              ])
            ),
          ],
          child: MaterialApp(
            home: const ExportScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Open history sheet
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();
      
      // Verify history is displayed
      expect(find.text('Export History'), findsOneWidget);
      expect(find.text('25 receipts'), findsOneWidget);
      expect(find.text('15 receipts'), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Failed'), findsOneWidget);
      expect(find.text('Network error'), findsOneWidget);
    });
    
    testWidgets('should handle batch exports for large datasets', (tester) async {
      // Arrange - 2500 receipts will create 3 batches for QuickBooks
      final receipts = testDataGenerator.generateReceipts(count:2500)
          .map((data) => Receipt.fromJson(data))
          .toList();
      final receiptCount = receipts.length;
      final batches = [
        receipts.sublist(0, 1000),
        receipts.sublist(1000, 2000),
        receipts.sublist(2000, 2500),
      ];

      when(() => mockRepository.getReceiptsByDateRange(any(), any()))
          .thenAnswer((_) async => receipts);

      when(() => mockCSVService.validateForExport(any(), any()))
          .thenAnswer((_) async => ValidationResult(
            isValid: true,
            warnings: [],
            errors: [],
            validCount: 2500,
            totalCount: 2500,
          ));
      
      when(() => mockCSVService.createBatches(any(), any()))
          .thenReturn(batches.cast<List<Receipt>>());
      
      // Build widget
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            csvExportServiceProvider.overrideWithValue(mockCSVService),
            exportReceiptRepositoryProvider.overrideWith((ref) async => mockRepository),
            batchInfoProvider.overrideWithValue(
              BatchInfo(
                totalBatches: 3,
                batchSizes: [1000, 1000, 500],
                format: ExportFormat.quickBooks3Column,
              ),
            ),
          ],
          child: MaterialApp(
            home: const ExportScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Select dates
      await tester.tap(find.text('Choose dates'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONFIRM'));
      await tester.pumpAndSettle();
      
      // Verify batch info is displayed
      expect(find.textContaining('2500 receipts'), findsOneWidget);
      expect(find.textContaining('3 batches'), findsAny);
      
      verify(() => mockCSVService.createBatches(any(), any())).called(1);
    });
    
    testWidgets('should allow format switching', (tester) async {
      // Build widget
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const ExportScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify QuickBooks is selected by default
      expect(find.text('QuickBooks'), findsOneWidget);
      
      // Switch to Xero
      await tester.tap(find.text('Xero'));
      await tester.pumpAndSettle();
      
      // Switch to Generic
      await tester.tap(find.text('Generic'));
      await tester.pumpAndSettle();
      
      // Verify format changes are reflected
      final segmentedButton = tester.widget<SegmentedButton<ExportFormat>>(
        find.byType(SegmentedButton<ExportFormat>)
      );
      expect(segmentedButton.selected, contains(ExportFormat.generic));
    });
  });
}