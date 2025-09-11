import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/receipts/screens/receipt_list_screen.dart';
import 'package:receipt_organizer/features/receipts/providers/selection_mode_provider.dart';
import 'package:receipt_organizer/features/receipts/widgets/delete_confirmation_dialog.dart';
import 'package:receipt_organizer/features/receipts/widgets/bulk_operation_progress_dialog.dart';
import 'package:receipt_organizer/features/receipts/widgets/undo_snackbar.dart';
import 'package:receipt_organizer/core/models/receipt.dart';
import 'package:receipt_organizer/core/services/bulk_operation_service.dart';
import 'package:receipt_organizer/core/services/authorization_service.dart';
import 'package:receipt_organizer/core/services/undo_service.dart';
import 'package:receipt_organizer/core/repositories/interfaces/i_receipt_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:async';
import 'package:flutter/services.dart';

@GenerateMocks([
  IReceiptRepository,
  AuthorizationService,
  UndoService,
  BulkOperationService,
])
import 'bulk_delete_workflow_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Initialize FFI for testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  group('Bulk Delete Workflow Integration Tests', () {
    late MockIReceiptRepository mockRepository;
    late MockAuthorizationService mockAuthService;
    late MockUndoService mockUndoService;
    late MockBulkOperationService mockBulkService;
    late List<Receipt> testReceipts;
    
    setUp(() {
      mockRepository = MockIReceiptRepository();
      mockAuthService = MockAuthorizationService();
      mockUndoService = MockUndoService();
      mockBulkService = MockBulkOperationService();
      
      // Create test receipts
      testReceipts = List.generate(5, (i) => Receipt(
        id: 'receipt_$i',
        merchantName: 'Test Merchant $i',
        date: DateTime.now().subtract(Duration(days: i)),
        totalAmount: 100.0 + i * 10,
        taxAmount: 10.0 + i,
        createdAt: DateTime.now(),
        imagePath: 'path/to/image_$i.jpg',
        thumbnailPath: 'path/to/thumb_$i.jpg',
      ));
      
      // Setup mock responses
      when(mockRepository.getAllReceipts()).thenAnswer((_) async => testReceipts);
      when(mockAuthService.filterOwnedReceipts(any)).thenAnswer((_) async => testReceipts);
      when(mockAuthService.requireReauthentication(any)).thenAnswer((_) async => false);
    });
    
    testWidgets('Should enter selection mode on long press', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            receiptRepositoryProvider.overrideWithValue(mockRepository),
            authorizationServiceProvider.overrideWithValue(mockAuthService),
          ],
          child: const MaterialApp(
            home: ReceiptListScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Act - Long press on first receipt
      await tester.longPress(find.text('Test Merchant 0'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Assert - Selection mode should be active
      expect(find.text('1 item selected'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget); // Exit selection button
    });
    
    testWidgets('Should show selection toolbar with actions', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            receiptRepositoryProvider.overrideWithValue(mockRepository),
            authorizationServiceProvider.overrideWithValue(mockAuthService),
          ],
          child: const MaterialApp(
            home: ReceiptListScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Enter selection mode
      await tester.longPress(find.text('Test Merchant 0'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Assert - Toolbar actions should be visible
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);
      expect(find.byIcon(Icons.select_all), findsOneWidget);
    });
    
    testWidgets('Should select multiple items', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            receiptRepositoryProvider.overrideWithValue(mockRepository),
            authorizationServiceProvider.overrideWithValue(mockAuthService),
          ],
          child: const MaterialApp(
            home: ReceiptListScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Enter selection mode
      await tester.longPress(find.text('Test Merchant 0'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Select additional items
      await tester.tap(find.text('Test Merchant 1'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      await tester.tap(find.text('Test Merchant 2'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Assert - Multiple items selected
      expect(find.text('3 items selected'), findsOneWidget);
    });
    
    testWidgets('Should show delete confirmation dialog', (tester) async {
      // Arrange
      final selectedReceipts = testReceipts.take(3).toList();
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: DeleteConfirmationDialog(
              receipts: selectedReceipts,
              onConfirm: (_) {},
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Assert - Dialog content
      expect(find.text('Delete 3 Receipts'), findsOneWidget);
      expect(find.text('Total receipts'), findsOneWidget);
      expect(find.text('3'), findsWidgets); // May appear multiple times
      expect(find.text('Permanently delete immediately'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });
    
    testWidgets('Should show progress during bulk delete', (tester) async {
      // Arrange
      final progressController = StreamController<BulkOperationProgress>();
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: BulkOperationProgressDialog(
              progressStream: progressController.stream,
              title: 'Deleting Receipts',
            ),
          ),
        ),
      );
      
      // Emit progress updates
      progressController.add(BulkOperationProgress(
        total: 10,
        current: 3,
        operation: 'Deleting',
      ));
      
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Assert - Progress shown
      expect(find.text('Deleting Receipts'), findsOneWidget);
      expect(find.text('3 of 10'), findsOneWidget);
      expect(find.text('30%'), findsOneWidget);
      
      // Emit completion
      progressController.add(BulkOperationProgress(
        total: 10,
        current: 10,
        operation: 'Complete',
        isComplete: true,
      ));
      
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Assert - Completion shown
      expect(find.text('Complete!'), findsOneWidget);
      expect(find.text('Successfully processed 10 items'), findsOneWidget);
      
      progressController.close();
    });
    
    testWidgets('Should show undo snackbar after delete', (tester) async {
      // Arrange
      final deletedReceipts = testReceipts.take(2).toList();
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    UndoSnackBar.show(
                      context: context,
                      deletedReceipts: deletedReceipts,
                      onUndo: () {},
                      duration: const Duration(seconds: 5),
                    );
                  },
                  child: const Text('Delete'),
                ),
              ),
            ),
          ),
        ),
      );
      
      // Trigger snackbar
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Assert - Undo snackbar shown
      expect(find.text('2 receipts deleted'), findsOneWidget);
      expect(find.text('UNDO'), findsOneWidget);
      expect(find.textContaining('Undo available for'), findsOneWidget);
    });
    
    testWidgets('Should filter receipts by confidence', (tester) async {
      // Arrange - Add OCR results to some receipts
      testReceipts[0] = testReceipts[0].copyWith(
        ocrResults: ProcessingResult(
          merchantName: StringFieldData(value: 'Test', confidence: 0.95),
          totalAmount: DoubleFieldData(value: 100.0, confidence: 0.95),
          date: DateFieldData(value: DateTime.now(), confidence: 0.95),
          taxAmount: DoubleFieldData(value: 10.0, confidence: 0.95),
          processingEngine: 'test',
          processedAt: DateTime.now(),
          overallConfidence: 0.95,
        ),
      );
      
      testReceipts[1] = testReceipts[1].copyWith(
        ocrResults: ProcessingResult(
          merchantName: StringFieldData(value: 'Test', confidence: 0.65),
          totalAmount: DoubleFieldData(value: 110.0, confidence: 0.65),
          date: DateFieldData(value: DateTime.now(), confidence: 0.65),
          taxAmount: DoubleFieldData(value: 11.0, confidence: 0.65),
          processingEngine: 'test',
          processedAt: DateTime.now(),
          overallConfidence: 0.65,
        ),
      );
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            receiptRepositoryProvider.overrideWithValue(mockRepository),
            authorizationServiceProvider.overrideWithValue(mockAuthService),
          ],
          child: const MaterialApp(
            home: ReceiptListScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Open filter dialog
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Enable high confidence filter
      await tester.tap(find.text('High Confidence Only'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Apply filters
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Assert - Only high confidence receipt shown
      expect(find.text('Test Merchant 0'), findsOneWidget);
      expect(find.text('Test Merchant 1'), findsNothing); // Low confidence filtered out
    });
    
    testWidgets('Should handle authorization denial', (tester) async {
      // Arrange - Setup auth to deny some receipts
      when(mockAuthService.filterOwnedReceipts(any))
          .thenAnswer((_) async => testReceipts.take(2).toList()); // Only 2 of 5 owned
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            receiptRepositoryProvider.overrideWithValue(mockRepository),
            authorizationServiceProvider.overrideWithValue(mockAuthService),
            bulkOperationServiceProvider.overrideWithValue((ref, userId) => mockBulkService),
          ],
          child: const MaterialApp(
            home: ReceiptListScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Only owned receipts should be visible
      expect(find.text('Test Merchant 0'), findsOneWidget);
      expect(find.text('Test Merchant 1'), findsOneWidget);
      expect(find.text('Test Merchant 2'), findsNothing); // Not owned
    });
    
    testWidgets('Should exit selection mode on escape', (tester) async {
      // Skip this test on mobile as keyboard shortcuts are desktop/web only
      if (tester.binding.window.physicalSize.width < 600) {
        return;
      }
      
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            receiptRepositoryProvider.overrideWithValue(mockRepository),
            authorizationServiceProvider.overrideWithValue(mockAuthService),
          ],
          child: const MaterialApp(
            home: ReceiptListScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Enter selection mode
      await tester.longPress(find.text('Test Merchant 0'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      expect(find.text('1 item selected'), findsOneWidget);
      
      // Press escape key
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // Assert - Selection mode exited
      expect(find.text('1 item selected'), findsNothing);
      expect(find.text('Receipts'), findsOneWidget); // Back to normal title
    });
    
    testWidgets('Should validate batch size limit', (tester) async {
      // Create 15 receipts (more than batch limit of 10)
      final manyReceipts = List.generate(15, (i) => Receipt(
        id: 'receipt_$i',
        merchantName: 'Test Merchant $i',
        date: DateTime.now().subtract(Duration(days: i)),
        totalAmount: 100.0 + i * 10,
        createdAt: DateTime.now(),
        imagePath: 'path/to/image_$i.jpg',
        thumbnailPath: 'path/to/thumb_$i.jpg',
      ));
      
      when(mockRepository.getAllReceipts()).thenAnswer((_) async => manyReceipts);
      when(mockAuthService.filterOwnedReceipts(any)).thenAnswer((_) async => manyReceipts);
      
      final service = BulkOperationService(
        repository: mockRepository,
        authService: mockAuthService,
        undoService: mockUndoService,
        userId: 'test_user',
      );
      
      // Track batch sizes
      final batchSizes = <int>[];
      when(mockRepository.softDelete(any, any)).thenAnswer((invocation) async {
        final ids = invocation.positionalArguments[0] as List<String>;
        batchSizes.add(ids.length);
      });
      
      when(mockRepository.logAudit(any)).thenAnswer((_) async {});
      when(mockUndoService.schedulePermanentDeletion(any)).thenAnswer((_) async {});
      
      // Perform bulk delete
      await service.deleteReceipts(manyReceipts);
      
      // Verify batch sizes
      expect(batchSizes, [10, 5]); // 15 items split into 10 and 5
      for (final size in batchSizes) {
        expect(size, lessThanOrEqualTo(10));
      }
      
      service.dispose();
    });
  });
}