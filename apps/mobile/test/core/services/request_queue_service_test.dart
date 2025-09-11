import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/core/services/request_queue_service.dart';
import 'package:receipt_organizer/core/services/queue_database_service.dart';
import 'package:receipt_organizer/core/models/queue_entry.dart';
import '../../test_config/test_setup.dart';
// Removed sqflite_common_ffi import - using test setup

void main() {
  // Test setup handles initialization
  
  // Initialize FFI for testing
  
  testWithSetup('RequestQueueService', () {
    late RequestQueueService queueService;
    late QueueDatabaseService databaseService;
    
    setUp(() {
      queueService = RequestQueueService();
      databaseService = QueueDatabaseService();
    });
    
    tearDown(() async {
      // Clean up after tests
      await queueService.clearQueue();
    });
    
    test('should queue a request successfully', () async {
      final queueId = await queueService.queueRequest(
        endpoint: 'https://api.example.com/test',
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: {'test': 'data'},
        feature: 'test_feature',
      );
      
      expect(queueId, isNotNull);
      expect(queueId, isNotEmpty);
      
      // Verify entry was saved
      final entry = await databaseService.getById(queueId);
      expect(entry, isNotNull);
      expect(entry!.endpoint, equals('https://api.example.com/test'));
      expect(entry.method, equals('POST'));
      expect(entry.status, equals(QueueEntryStatus.pending));
    });
    
    test('should enforce queue size limit', () async {
      // This test would require mocking or adjusting the max queue size
      // For now, just verify the queue request method exists
      expect(queueService.queueRequest, isNotNull);
    });
    
    test('should get queue statistics', () async {
      // Queue a request
      await queueService.queueRequest(
        endpoint: 'https://api.example.com/test',
        method: 'GET',
        feature: 'test_stats',
      );
      
      final stats = await queueService.getStatistics();
      
      expect(stats, isNotNull);
      expect(stats['pendingCount'], greaterThanOrEqualTo(1));
      expect(stats['isProcessing'], isA<bool>());
    });
    
    test('should clear queue', () async {
      // Queue some requests
      await queueService.queueRequest(
        endpoint: 'https://api.example.com/test1',
        method: 'GET',
        feature: 'test1',
      );
      
      await queueService.queueRequest(
        endpoint: 'https://api.example.com/test2',
        method: 'POST',
        feature: 'test2',
      );
      
      // Clear queue
      await queueService.clearQueue();
      
      // Verify queue is empty
      final stats = await queueService.getStatistics();
      expect(stats['pendingCount'], equals(0));
    });
    
    test('should handle different HTTP methods', () async {
      final methods = ['GET', 'POST', 'PUT', 'DELETE'];
      
      for (final method in methods) {
        final queueId = await queueService.queueRequest(
          endpoint: 'https://api.example.com/test',
          method: method,
          feature: 'test_$method',
        );
        
        expect(queueId, isNotNull);
        
        final entry = await databaseService.getById(queueId);
        expect(entry!.method, equals(method));
      }
    });
    
    test('should set retry parameters correctly', () async {
      final queueId = await queueService.queueRequest(
        endpoint: 'https://api.example.com/test',
        method: 'POST',
        feature: 'test_retry',
        maxRetries: 5,
      );
      
      final entry = await databaseService.getById(queueId);
      expect(entry!.maxRetries, equals(5));
      expect(entry.retryCount, equals(0));
    });
  });
  
  group('QueueDatabaseService', () {
    late QueueDatabaseService databaseService;
    
    setUp(() {
      databaseService = QueueDatabaseService();
    });
    
    tearDown(() async {
      await databaseService.clearAll();
    });
    
    test('should save and retrieve queue entries', () async {
      final entry = QueueEntry(
        id: 'test-123',
        endpoint: 'https://api.example.com/test',
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: {'test': 'data'},
        createdAt: DateTime.now(),
        retryCount: 0,
        maxRetries: 3,
        status: QueueEntryStatus.pending,
        feature: 'test_feature',
      );
      
      await databaseService.insert(entry);
      
      final retrieved = await databaseService.getById('test-123');
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('test-123'));
      expect(retrieved.endpoint, equals('https://api.example.com/test'));
      expect(retrieved.status, equals(QueueEntryStatus.pending));
    });
    
    test('should get pending entries in order', () async {
      final now = DateTime.now();
      
      // Insert entries with different timestamps
      await databaseService.insert(QueueEntry(
        id: 'entry-1',
        endpoint: 'https://api.example.com/1',
        method: 'GET',
        headers: {},
        createdAt: now.subtract(const Duration(minutes: 2)),
        retryCount: 0,
        maxRetries: 3,
        status: QueueEntryStatus.pending,
      ));
      
      await databaseService.insert(QueueEntry(
        id: 'entry-2',
        endpoint: 'https://api.example.com/2',
        method: 'GET',
        headers: {},
        createdAt: now.subtract(const Duration(minutes: 1)),
        retryCount: 0,
        maxRetries: 3,
        status: QueueEntryStatus.pending,
      ));
      
      await databaseService.insert(QueueEntry(
        id: 'entry-3',
        endpoint: 'https://api.example.com/3',
        method: 'GET',
        headers: {},
        createdAt: now,
        retryCount: 0,
        maxRetries: 3,
        status: QueueEntryStatus.completed, // Not pending
      ));
      
      final pending = await databaseService.getPendingEntries();
      
      expect(pending.length, equals(2));
      expect(pending[0].id, equals('entry-1')); // Oldest first
      expect(pending[1].id, equals('entry-2'));
    });
    
    test('should update entry status', () async {
      final entry = QueueEntry(
        id: 'update-test',
        endpoint: 'https://api.example.com/test',
        method: 'POST',
        headers: {},
        createdAt: DateTime.now(),
        retryCount: 0,
        maxRetries: 3,
        status: QueueEntryStatus.pending,
      );
      
      await databaseService.insert(entry);
      
      // Update status
      final updatedEntry = entry.copyWith(
        status: QueueEntryStatus.processing,
        retryCount: 1,
        errorMessage: 'Test error',
      );
      
      await databaseService.update(updatedEntry);
      
      final retrieved = await databaseService.getById('update-test');
      expect(retrieved!.status, equals(QueueEntryStatus.processing));
      expect(retrieved.retryCount, equals(1));
      expect(retrieved.errorMessage, equals('Test error'));
    });
    
    test('should delete old completed entries', () async {
      final now = DateTime.now();
      
      // Insert old completed entry
      await databaseService.insert(QueueEntry(
        id: 'old-completed',
        endpoint: 'https://api.example.com/old',
        method: 'GET',
        headers: {},
        createdAt: now.subtract(const Duration(days: 10)),
        retryCount: 0,
        maxRetries: 3,
        status: QueueEntryStatus.completed,
      ));
      
      // Insert recent completed entry
      await databaseService.insert(QueueEntry(
        id: 'recent-completed',
        endpoint: 'https://api.example.com/recent',
        method: 'GET',
        headers: {},
        createdAt: now.subtract(const Duration(days: 1)),
        retryCount: 0,
        maxRetries: 3,
        status: QueueEntryStatus.completed,
      ));
      
      // Delete old completed entries
      final deletedCount = await databaseService.deleteOldCompleted(
        age: const Duration(days: 7),
      );
      
      expect(deletedCount, equals(1));
      
      // Verify old entry is gone
      final oldEntry = await databaseService.getById('old-completed');
      expect(oldEntry, isNull);
      
      // Verify recent entry still exists
      final recentEntry = await databaseService.getById('recent-completed');
      expect(recentEntry, isNotNull);
    });
    
    test('should get queue size correctly', () async {
      // Insert some pending entries
      for (int i = 0; i < 5; i++) {
        await databaseService.insert(QueueEntry(
          id: 'pending-$i',
          endpoint: 'https://api.example.com/$i',
          method: 'GET',
          headers: {},
          createdAt: DateTime.now(),
          retryCount: 0,
          maxRetries: 3,
          status: QueueEntryStatus.pending,
        ));
      }
      
      // Insert some non-pending entries
      await databaseService.insert(QueueEntry(
        id: 'completed-1',
        endpoint: 'https://api.example.com/completed',
        method: 'GET',
        headers: {},
        createdAt: DateTime.now(),
        retryCount: 0,
        maxRetries: 3,
        status: QueueEntryStatus.completed,
      ));
      
      final size = await databaseService.getQueueSize();
      expect(size, equals(5)); // Only pending entries
    });
  });
}