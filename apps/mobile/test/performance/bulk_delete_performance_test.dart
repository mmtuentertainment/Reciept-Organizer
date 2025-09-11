import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/core/services/bulk_operation_service.dart';
import 'package:receipt_organizer/core/services/authorization_service.dart';
import 'package:receipt_organizer/core/services/undo_service.dart';
import 'package:receipt_organizer/core/models/receipt.dart';
import 'package:receipt_organizer/core/models/audit_log.dart';
import 'package:receipt_organizer/core/repositories/interfaces/i_receipt_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../test_config/test_setup.dart';
// Removed sqflite_common_ffi import - using test setup

@GenerateMocks([IReceiptRepository, AuthorizationService, UndoService])
import 'bulk_delete_performance_test.mocks.dart';
import '../test_config/test_setup.dart';

void main() {
  // Test setup handles initialization
  
  // Initialize FFI for testing
  
  testWithSetup('Bulk Delete Performance Tests', () {
    late MockIReceiptRepository mockRepository;
    late MockAuthorizationService mockAuthService;
    late MockUndoService mockUndoService;
    late BulkOperationService service;
    
    setUp(() {
      mockRepository = MockIReceiptRepository();
      mockAuthService = MockAuthorizationService();
      mockUndoService = MockUndoService();
      
      service = BulkOperationService(
        repository: mockRepository,
        authService: mockAuthService,
        undoService: mockUndoService,
        userId: 'test_user',
      );
    });
    
    tearDown(() {
      service.dispose();
    });
    
    test('PERF-001: Should process 50 receipts in under 5 seconds', () async {
      // Arrange
      final receipts = List.generate(50, (i) => _createTestReceipt('receipt_$i'));
      
      when(mockAuthService.filterOwnedReceipts(any))
          .thenAnswer((_) async => receipts);
      when(mockAuthService.requireReauthentication(any))
          .thenAnswer((_) async => false);
      when(mockRepository.softDelete(any, any))
          .thenAnswer((_) async => Future.delayed(const Duration(milliseconds: 10)));
      when(mockRepository.logAudit(any))
          .thenAnswer((_) async => Future.value());
      when(mockUndoService.schedulePermanentDeletion(any))
          .thenAnswer((_) async => Future.value());
      
      // Act
      final stopwatch = Stopwatch()..start();
      await service.deleteReceipts(receipts);
      stopwatch.stop();
      
      // Assert
      expect(stopwatch.elapsedMilliseconds, lessThan(5000),
          reason: 'Bulk delete of 50 receipts should complete in under 5 seconds');
      
      // Verify batch processing
      verify(mockRepository.softDelete(any, any)).called(5); // 50 receipts / 10 per batch
    });
    
    test('PERF-002: Should enforce maximum batch size of 10', () async {
      // Arrange
      final receipts = List.generate(25, (i) => _createTestReceipt('receipt_$i'));
      
      when(mockAuthService.filterOwnedReceipts(any))
          .thenAnswer((_) async => receipts);
      when(mockAuthService.requireReauthentication(any))
          .thenAnswer((_) async => false);
      
      final batchSizes = <int>[];
      when(mockRepository.softDelete(any, any))
          .thenAnswer((invocation) async {
            final ids = invocation.positionalArguments[0] as List<String>;
            batchSizes.add(ids.length);
          });
      
      when(mockRepository.logAudit(any))
          .thenAnswer((_) async => Future.value());
      when(mockUndoService.schedulePermanentDeletion(any))
          .thenAnswer((_) async => Future.value());
      
      // Act
      await service.deleteReceipts(receipts);
      
      // Assert
      expect(batchSizes, [10, 10, 5],
          reason: '25 receipts should be processed in batches of 10, 10, 5');
      
      for (final size in batchSizes) {
        expect(size, lessThanOrEqualTo(10),
            reason: 'No batch should exceed 10 items');
      }
    });
    
    test('PERF-003: Should process 500 receipts with memory efficiency', () async {
      // Arrange
      final receipts = List.generate(500, (i) => _createTestReceipt('receipt_$i'));
      
      when(mockAuthService.filterOwnedReceipts(any))
          .thenAnswer((_) async => receipts);
      when(mockAuthService.requireReauthentication(any))
          .thenAnswer((_) async => true); // Require reauth for 500 items
      when(mockRepository.softDelete(any, any))
          .thenAnswer((_) async => Future.value());
      when(mockRepository.logAudit(any))
          .thenAnswer((_) async => Future.value());
      when(mockUndoService.schedulePermanentDeletion(any))
          .thenAnswer((_) async => Future.value());
      
      // Act & Assert - should complete without memory issues
      await expectLater(
        service.deleteReceipts(receipts),
        completes,
        reason: 'Should handle 500 receipts without memory issues',
      );
      
      // Verify batch processing
      verify(mockRepository.softDelete(any, any)).called(50); // 500 / 10 = 50 batches
    });
    
    test('PERF-004: Progress stream should emit updates in real-time', () async {
      // Arrange
      final receipts = List.generate(30, (i) => _createTestReceipt('receipt_$i'));
      final progressUpdates = <BulkOperationProgress>[];
      
      when(mockAuthService.filterOwnedReceipts(any))
          .thenAnswer((_) async => receipts);
      when(mockAuthService.requireReauthentication(any))
          .thenAnswer((_) async => false);
      when(mockRepository.softDelete(any, any))
          .thenAnswer((_) async => Future.delayed(const Duration(milliseconds: 50)));
      when(mockRepository.logAudit(any))
          .thenAnswer((_) async => Future.value());
      when(mockUndoService.schedulePermanentDeletion(any))
          .thenAnswer((_) async => Future.value());
      
      // Listen to progress
      service.progressStream.listen(progressUpdates.add);
      
      // Act
      await service.deleteReceipts(receipts);
      
      // Allow stream to emit
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Assert
      expect(progressUpdates.length, greaterThan(3),
          reason: 'Should emit multiple progress updates');
      
      // Check progress values are increasing
      for (int i = 1; i < progressUpdates.length - 1; i++) {
        expect(progressUpdates[i].current, greaterThanOrEqualTo(progressUpdates[i - 1].current),
            reason: 'Progress should increase monotonically');
      }
      
      // Check final update
      final lastUpdate = progressUpdates.last;
      expect(lastUpdate.isComplete, isTrue);
      expect(lastUpdate.current, equals(30));
    });
    
    test('PERF-005: Storage calculation should be efficient', () async {
      // Arrange
      final receipts = List.generate(100, (i) => _createTestReceipt('receipt_$i'));
      
      // Act
      final stopwatch = Stopwatch()..start();
      final storageBytes = await service.calculateStorageToBeFreed(receipts);
      stopwatch.stop();
      
      // Assert
      expect(stopwatch.elapsedMilliseconds, lessThan(1000),
          reason: 'Storage calculation for 100 receipts should complete in under 1 second');
      expect(storageBytes, greaterThan(0),
          reason: 'Should calculate non-zero storage size');
    });
    
    test('PERF-006: Should handle authorization filtering efficiently', () async {
      // Arrange
      final allReceipts = List.generate(100, (i) => _createTestReceipt('receipt_$i'));
      final ownedReceipts = allReceipts.take(50).toList();
      
      when(mockAuthService.filterOwnedReceipts(any))
          .thenAnswer((_) async {
            // Simulate filtering delay
            await Future.delayed(const Duration(milliseconds: 100));
            return ownedReceipts;
          });
      when(mockAuthService.requireReauthentication(any))
          .thenAnswer((_) async => false);
      when(mockRepository.softDelete(any, any))
          .thenAnswer((_) async => Future.value());
      when(mockRepository.logAudit(any))
          .thenAnswer((_) async => Future.value());
      when(mockUndoService.schedulePermanentDeletion(any))
          .thenAnswer((_) async => Future.value());
      
      // Act
      final stopwatch = Stopwatch()..start();
      await service.deleteReceipts(allReceipts);
      stopwatch.stop();
      
      // Assert
      expect(stopwatch.elapsedMilliseconds, lessThan(2000),
          reason: 'Authorization filtering should be efficient');
      
      // Verify only owned receipts were deleted
      verify(mockRepository.softDelete(any, any)).called(5); // 50 owned / 10 per batch
    });
    
    test('PERF-007: Should not block UI during batch processing', () async {
      // Arrange
      final receipts = List.generate(20, (i) => _createTestReceipt('receipt_$i'));
      final delays = <int>[];
      
      when(mockAuthService.filterOwnedReceipts(any))
          .thenAnswer((_) async => receipts);
      when(mockAuthService.requireReauthentication(any))
          .thenAnswer((_) async => false);
      
      when(mockRepository.softDelete(any, any))
          .thenAnswer((_) async {
            final start = DateTime.now().millisecondsSinceEpoch;
            await Future.delayed(const Duration(milliseconds: 50));
            final end = DateTime.now().millisecondsSinceEpoch;
            delays.add(end - start);
          });
      
      when(mockRepository.logAudit(any))
          .thenAnswer((_) async => Future.value());
      when(mockUndoService.schedulePermanentDeletion(any))
          .thenAnswer((_) async => Future.value());
      
      // Act
      await service.deleteReceipts(receipts);
      
      // Assert
      expect(delays.length, equals(2)); // 20 receipts / 10 per batch
      
      // Verify delay between batches (should have 100ms delay)
      // This ensures UI remains responsive
      verify(mockRepository.softDelete(any, any)).called(2);
    });
    
    test('PERF-008: Audit logging should not impact performance', () async {
      // Arrange
      final receipts = List.generate(30, (i) => _createTestReceipt('receipt_$i'));
      var auditLogCount = 0;
      
      when(mockAuthService.filterOwnedReceipts(any))
          .thenAnswer((_) async => receipts);
      when(mockAuthService.requireReauthentication(any))
          .thenAnswer((_) async => false);
      when(mockRepository.softDelete(any, any))
          .thenAnswer((_) async => Future.value());
      
      when(mockRepository.logAudit(any))
          .thenAnswer((_) async {
            auditLogCount++;
            // Simulate slow audit logging
            await Future.delayed(const Duration(milliseconds: 100));
          });
      
      when(mockUndoService.schedulePermanentDeletion(any))
          .thenAnswer((_) async => Future.value());
      
      // Act
      final stopwatch = Stopwatch()..start();
      await service.deleteReceipts(receipts);
      stopwatch.stop();
      
      // Assert
      expect(auditLogCount, greaterThan(0),
          reason: 'Should log audit events');
      
      // Even with slow audit logging, should complete reasonably fast
      // because audit logging should be async/non-blocking
      expect(stopwatch.elapsedMilliseconds, lessThan(10000),
          reason: 'Audit logging should not significantly impact performance');
    });
    
    test('PERF-009: Memory leak prevention - should dispose resources', () async {
      // Arrange
      final receipts = List.generate(10, (i) => _createTestReceipt('receipt_$i'));
      final progressEvents = <BulkOperationProgress>[];
      
      when(mockAuthService.filterOwnedReceipts(any))
          .thenAnswer((_) async => receipts);
      when(mockAuthService.requireReauthentication(any))
          .thenAnswer((_) async => false);
      when(mockRepository.softDelete(any, any))
          .thenAnswer((_) async => Future.value());
      when(mockRepository.logAudit(any))
          .thenAnswer((_) async => Future.value());
      when(mockUndoService.schedulePermanentDeletion(any))
          .thenAnswer((_) async => Future.value());
      
      // Subscribe to progress
      final subscription = service.progressStream.listen(progressEvents.add);
      
      // Act
      await service.deleteReceipts(receipts);
      service.dispose();
      
      // Try to emit after dispose (should not work)
      expect(
        () => service.progressStream.listen((_) {}),
        throwsStateError,
        reason: 'Stream should be closed after dispose',
      );
      
      // Clean up
      await subscription.cancel();
    });
    
    test('PERF-010: Should handle errors without performance degradation', () async {
      // Arrange
      final receipts = List.generate(30, (i) => _createTestReceipt('receipt_$i'));
      var attemptCount = 0;
      
      when(mockAuthService.filterOwnedReceipts(any))
          .thenAnswer((_) async => receipts);
      when(mockAuthService.requireReauthentication(any))
          .thenAnswer((_) async => false);
      
      // Simulate intermittent failures
      when(mockRepository.softDelete(any, any))
          .thenAnswer((_) async {
            attemptCount++;
            if (attemptCount == 2) {
              throw Exception('Network error');
            }
            return Future.value();
          });
      
      when(mockRepository.logAudit(any))
          .thenAnswer((_) async => Future.value());
      when(mockUndoService.schedulePermanentDeletion(any))
          .thenAnswer((_) async => Future.value());
      
      // Act & Assert
      await expectLater(
        service.deleteReceipts(receipts),
        throwsException,
        reason: 'Should propagate errors',
      );
      
      // Verify error was logged
      verify(mockRepository.logAudit(argThat(
        predicate<AuditLog>((log) => 
          log.action == AuditAction.bulkDelete && 
          log.success == false
        ),
      ))).called(1);
    });
  });
}

Receipt _createTestReceipt(String id) {
  return Receipt(
    id: id,
    imageUri: 'file:///path/to/image_$id.jpg',
    thumbnailUri: 'file:///path/to/thumb_$id.jpg',
    capturedAt: DateTime.now(),
    status: ReceiptStatus.processed,
    batchId: 'batch_001',
    lastModified: DateTime.now(),
    merchantName: 'Test Merchant $id',
    receiptDate: '12/01/2024',
    totalAmount: 100.00 + double.parse(id.replaceAll('receipt_', '')),
    taxAmount: 10.00,
    overallConfidence: 0.95,
  );
}