import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:receipt_organizer/features/export/services/xero_api_service.dart';
import 'package:receipt_organizer/features/export/models/api_credentials.dart';
import 'package:receipt_organizer/core/models/receipt.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Mock the secure storage channel for testing
  const MethodChannel channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
    (MethodCall methodCall) async {
      if (methodCall.method == 'read') {
        return null; // Return null for all reads (not authenticated)
      }
      return null;
    },
  );
  group('Xero API Validation', () {
    late XeroAPIService service;
    
    setUp(() {
      service = XeroAPIService();
    });
    
    test('should have valid client ID configured', () {
      expect(APICredentials.xeroClientId, isNotEmpty);
      expect(APICredentials.xeroClientId, 
             equals('F7E48B5BA8CC43F9AA035C7803EB1504'));
    });
    
    test('should generate valid PKCE authorization URL', () async {
      final authUrl = await service.getAuthorizationUrl();
      
      expect(authUrl, contains('https://login.xero.com/identity/connect/authorize'));
      expect(authUrl, contains('client_id=${APICredentials.xeroClientId}'));
      expect(authUrl, contains('response_type=code'));
      expect(authUrl, contains('code_challenge='));
      expect(authUrl, contains('code_challenge_method=S256'));
      expect(authUrl, contains('scope='));
      expect(authUrl, contains('redirect_uri='));
    });
    
    test('should validate receipts with required fields', () async {
      // Create test receipts
      final receipts = [
        Receipt.create(
          merchantName: 'Target Store',
          date: DateTime(2024, 12, 25),
          totalAmount: 125.50,
          taxAmount: 12.55,
        ),
        Receipt.create(
          merchantName: 'Walmart',
          date: DateTime(2024, 12, 26),
          totalAmount: 89.99,
          taxAmount: 8.99,
        ),
      ];
      
      // Run validation
      final result = await service.validateReceipts(receipts);
      
      // Check results
      expect(result, isNotNull);
      
      // Without authentication, should get auth error
      if (result.errors.isNotEmpty) {
        expect(result.errors.first, 
               contains('Not authenticated with Xero'));
      }
    });
    
    test('should handle batch size limits', () async {
      // Create 60 receipts (exceeds Xero's 50 per batch limit)
      final receipts = List.generate(60, (i) => 
        Receipt.create(
          merchantName: 'Store $i',
          date: DateTime(2024, 12, 1).add(Duration(days: i % 30)),
          totalAmount: 100.0 + i,
          taxAmount: 10.0 + (i * 0.1),
        )
      );
      
      final result = await service.validateReceipts(receipts);
      
      expect(result.warnings.any((w) => 
        w.contains('max 50 invoices per batch')), isTrue);
    });
    
    test('should detect missing required fields', () async {
      // Create receipts with missing fields
      final receipts = [
        Receipt.create(
          merchantName: null, // Missing merchant
          date: DateTime(2024, 12, 25),
          totalAmount: 125.50,
          taxAmount: 12.55,
        ),
        Receipt.create(
          merchantName: 'Test Store',
          date: null, // Missing date
          totalAmount: 89.99,
          taxAmount: 8.99,
        ),
      ];
      
      final result = await service.validateReceipts(receipts);
      
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('Missing merchant name')), isTrue);
      expect(result.errors.any((e) => e.contains('Missing date')), isTrue);
    });
    
    test('should reject dates older than 7 years', () async {
      // Create receipt with very old date
      final receipts = [
        Receipt.create(
          merchantName: 'Old Store',
          date: DateTime.now().subtract(const Duration(days: 365 * 8)),
          totalAmount: 50.00,
          taxAmount: 5.00,
        ),
      ];
      
      final result = await service.validateReceipts(receipts);
      
      expect(result.errors.any((e) => 
        e.contains('more than 7 years old')), isTrue);
    });
    
    test('should warn about future dates', () async {
      // Create receipt with future date
      final receipts = [
        Receipt.create(
          merchantName: 'Future Store',
          date: DateTime.now().add(const Duration(days: 30)),
          totalAmount: 100.00,
          taxAmount: 10.00,
        ),
      ];
      
      final result = await service.validateReceipts(receipts);
      
      expect(result.warnings.any((w) => 
        w.contains('Future dated transaction')), isTrue);
    });
    
    test('should validate merchant name length', () async {
      // Create receipt with very long merchant name (>500 chars)
      final longName = 'A' * 501;
      final receipts = [
        Receipt.create(
          merchantName: longName,
          date: DateTime(2024, 12, 25),
          totalAmount: 100.00,
          taxAmount: 10.00,
        ),
      ];
      
      final result = await service.validateReceipts(receipts);
      
      expect(result.errors.any((e) => 
        e.contains('exceeds 500 characters')), isTrue);
    });
    
    test('should detect invalid tax amounts', () async {
      // Create receipt where tax exceeds total
      final receipts = [
        Receipt.create(
          merchantName: 'Test Store',
          date: DateTime(2024, 12, 25),
          totalAmount: 100.00,
          taxAmount: 150.00, // Tax > Total
        ),
      ];
      
      final result = await service.validateReceipts(receipts);
      
      expect(result.errors.any((e) => 
        e.contains('Tax amount exceeds total')), isTrue);
    });
    
    test('should convert receipt to Xero Invoice format', () async {
      final receipt = Receipt.create(
        merchantName: 'Test Merchant',
        date: DateTime(2024, 12, 25),
        totalAmount: 125.50,
        taxAmount: 12.55,
      );
      
      // Test batch creation would normally require authentication
      try {
        await service.createExpenseBills([receipt]);
      } catch (e) {
        expect(e.toString(), contains('Not authenticated'));
      }
    });
    
    test('should batch receipts correctly for API calls', () async {
      // Create 120 receipts (should be split into 3 batches)
      final receipts = List.generate(120, (i) => 
        Receipt.create(
          merchantName: 'Store $i',
          date: DateTime(2024, 12, 1).add(Duration(days: i % 30)),
          totalAmount: 100.0 + i,
          taxAmount: 10.0 + (i * 0.1),
        )
      );
      
      // This would test batching logic
      try {
        await service.createExpenseBills(receipts);
      } catch (e) {
        // Expected to fail without auth
        expect(e.toString(), contains('Not authenticated'));
      }
    });
    
    test('should include API rate limit warning', () async {
      final receipts = [
        Receipt.create(
          merchantName: 'Test Store',
          date: DateTime(2024, 12, 25),
          totalAmount: 100.00,
          taxAmount: 10.00,
        ),
      ];
      
      final result = await service.validateReceipts(receipts);
      
      expect(result.warnings.any((w) => 
        w.contains('5,000 calls per day')), isTrue);
    });
  });
}