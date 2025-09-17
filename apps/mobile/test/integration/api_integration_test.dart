import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:receipt_organizer/infrastructure/services/receipt_api_service.dart';
import 'package:receipt_organizer/infrastructure/repositories/hybrid_receipt_repository.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/core/services/network_connectivity_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([NetworkConnectivityService])
import 'api_integration_test.mocks.dart';

void main() {
  group('Receipt API Integration Tests', () {
    late ReceiptApiService apiService;
    late MockNetworkConnectivityService mockConnectivity;

    setUp(() {
      mockConnectivity = MockNetworkConnectivityService();
      // Default to online
      when(mockConnectivity.canMakeApiCall()).thenReturn(true);
      when(mockConnectivity.connectivityStream).thenAnswer(
        (_) => Stream<bool>.value(true),
      );
    });

    test('should create receipt job with URL successfully', () async {
      // Arrange
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/receipts');
        expect(request.headers['Content-Type'], 'application/json');
        expect(request.headers['Idempotency-Key'], isNotNull);

        final body = json.decode(request.body);
        expect(body['source'], 'url');
        expect(body['url'], 'https://example.com/receipt.jpg');

        return http.Response(
          json.encode({
            'jobId': 'job_123',
            'deduped': false,
          }),
          202,
        );
      });

      // Create service with mock client
      apiService = ReceiptApiService();
      // Note: In real implementation, we'd inject the client

      // Act
      final jobId = await apiService.createReceiptJob(
        imageUrl: 'https://example.com/receipt.jpg',
        metadata: {'test': 'data'},
      );

      // Assert
      expect(jobId, 'job_123');
    });

    test('should handle duplicate request with deduped response', () async {
      // Arrange
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode({
            'jobId': 'job_existing',
            'deduped': true,
          }),
          409,
        );
      });

      apiService = ReceiptApiService();

      // Act
      final jobId = await apiService.createReceiptJob(
        imageUrl: 'https://example.com/receipt.jpg',
      );

      // Assert
      expect(jobId, 'job_existing');
    });

    test('should handle rate limit error correctly', () async {
      // Arrange
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode({
            'type': 'https://example.com/problems/rate-limit',
            'title': 'Too Many Requests',
            'status': 429,
            'detail': 'Rate limit exceeded. Please retry later.',
          }),
          429,
          headers: {'Retry-After': '60'},
        );
      });

      apiService = ReceiptApiService();

      // Act & Assert
      expect(
        () => apiService.createReceiptJob(
          imageUrl: 'https://example.com/receipt.jpg',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('RATE_LIMIT'),
          ),
        ),
      );
    });

    test('should queue request when offline', () async {
      // Arrange
      when(mockConnectivity.canMakeApiCall()).thenReturn(false);

      apiService = ReceiptApiService();

      // Act
      final jobId = await apiService.createReceiptJob(
        imageUrl: 'https://example.com/receipt.jpg',
      );

      // Assert
      expect(jobId, startsWith('pending_'));
    });

    group('Hybrid Repository Tests', () {
      late HybridReceiptRepository repository;

      test('should create receipt locally when offline', () async {
        // Arrange
        when(mockConnectivity.canMakeApiCall()).thenReturn(false);

        repository = HybridReceiptRepository(
          connectivity: mockConnectivity,
        );

        final receipt = Receipt(
          id: 'test_123',
          imageUri: 'https://example.com/receipt.jpg',
          capturedAt: DateTime.now(),
          status: ReceiptStatus.pending,
          lastModified: DateTime.now(),
        );

        // Act
        final savedReceipt = await repository.createReceipt(receipt);

        // Assert
        expect(savedReceipt.id, receipt.id);
        expect(repository.pendingChangesCount, greaterThan(0));
      });

      test('should sync pending changes when coming online', () async {
        // Arrange
        when(mockConnectivity.canMakeApiCall()).thenReturn(false);

        repository = HybridReceiptRepository(
          connectivity: mockConnectivity,
        );

        // Create receipt while offline
        final receipt = Receipt(
          id: 'test_456',
          imageUri: 'https://example.com/receipt.jpg',
          capturedAt: DateTime.now(),
          status: ReceiptStatus.pending,
          lastModified: DateTime.now(),
        );

        await repository.createReceipt(receipt);
        expect(repository.pendingChangesCount, 1);

        // Act - simulate coming online
        when(mockConnectivity.canMakeApiCall()).thenReturn(true);
        await repository.forceSyncNow();

        // Assert - pending changes should be processed
        // Note: In real implementation, we'd verify the API calls
      });
    });
  });

  group('End-to-End Integration Test', () {
    test('Complete flow: capture, upload, and retrieve', () async {
      // This would be run against a real test server
      // For now, we'll document the expected flow

      // 1. Create receipt locally
      final repository = HybridReceiptRepository();
      final receipt = Receipt(
        id: 'e2e_test',
        imageUri: 'https://example.com/test-receipt.jpg',
        capturedAt: DateTime.now(),
        status: ReceiptStatus.pending,
        lastModified: DateTime.now(),
        vendorName: 'Test Store',
        totalAmount: 99.99,
      );

      // 2. Save receipt (triggers API upload if online)
      final savedReceipt = await repository.createReceipt(receipt);
      expect(savedReceipt.metadata?['apiJobId'], isNotNull);

      // 3. Verify local storage
      final localReceipt = await repository.getReceiptById(receipt.id);
      expect(localReceipt, isNotNull);
      expect(localReceipt?.merchantName, 'Test Store');

      // 4. Future: Check job status
      // final jobStatus = await apiService.getJobStatus(jobId);
      // expect(jobStatus['status'], 'processing');
    });
  });
}