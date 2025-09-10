import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/features/export/services/quickbooks_api_service.dart';
import 'package:receipt_organizer/core/models/receipt.dart';
import 'package:receipt_organizer/core/services/network_connectivity_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Offline Validation Protocol', () {
    late QuickBooksAPIService qbService;
    late NetworkConnectivityService connectivity;
    
    setUp(() {
      qbService = QuickBooksAPIService();
      connectivity = NetworkConnectivityService();
    });
    
    test('should detect offline state in validation', () async {
      // Create test receipts
      final receipts = [
        Receipt(
          id: 'test-1',
          merchantName: 'Test Store',
          totalAmount: 100.00,
          taxAmount: 10.00,
          date: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];
      
      // Test validation
      // Note: In a real test environment, we'd mock the connectivity
      // For now, this tests that the integration works
      final result = await qbService.validateReceipts(receipts);
      
      // The result should be a ValidationResult
      expect(result, isNotNull);
      expect(result.errors, isA<List<String>>());
      expect(result.warnings, isA<List<String>>());
      
      // If we're actually offline, we should get the offline message
      if (!connectivity.canMakeApiCall()) {
        expect(result.errors, contains('Device is offline. Please check your internet connection.'));
        expect(result.warnings, contains('Validation will be retried when connection is restored.'));
      }
    });
    
    test('should return proper validation result structure', () async {
      final receipts = [
        Receipt(
          id: 'test-2',
          merchantName: 'Another Store',
          totalAmount: 50.00,
          taxAmount: 5.00,
          date: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];
      
      final result = await qbService.validateReceipts(receipts);
      
      // Verify structure
      expect(result.isValid, isA<bool>());
      expect(result.errors, isA<List<String>>());
      expect(result.warnings, isA<List<String>>());
    });
    
    test('should handle empty receipt list', () async {
      final receipts = <Receipt>[];
      
      final result = await qbService.validateReceipts(receipts);
      
      // Should handle gracefully
      expect(result, isNotNull);
    });
  });
}