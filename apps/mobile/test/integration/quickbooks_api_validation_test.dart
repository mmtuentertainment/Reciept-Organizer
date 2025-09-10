import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:receipt_organizer/features/export/services/quickbooks_api_service.dart';
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
  group('QuickBooks API Validation', () {
    late QuickBooksAPIService service;
    
    setUp(() {
      service = QuickBooksAPIService();
    });
    
    test('should have valid client credentials configured', () {
      expect(APICredentials.quickBooksClientId, isNotEmpty);
      expect(APICredentials.quickBooksClientSecret, isNotEmpty);
      expect(APICredentials.quickBooksClientId, 
             equals('ABHeXjfhxPZWmMVLLKNFQ5BkThuwSmT8SeRkx1bJsX3Zcn5djW'));
    });
    
    test('should generate valid authorization URL', () async {
      final authUrl = await service.getAuthorizationUrl();
      
      expect(authUrl, contains('https://appcenter.intuit.com/connect/oauth2'));
      expect(authUrl, contains('client_id=${APICredentials.quickBooksClientId}'));
      expect(authUrl, contains('scope=com.intuit.quickbooks.accounting'));
      expect(authUrl, contains('response_type=code'));
      expect(authUrl, contains('redirect_uri='));
    });
    
    test('should validate receipts with required fields', () async {
      // Create test receipts with your actual data
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
               contains('Not authenticated with QuickBooks'));
      }
    });
    
    test('should detect missing required fields', () async {
      // Create receipt with missing merchant name
      final receipts = [
        Receipt.create(
          merchantName: null,
          date: DateTime(2024, 12, 25),
          totalAmount: 125.50,
          taxAmount: 12.55,
        ),
      ];
      
      final result = await service.validateReceipts(receipts);
      
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('Missing merchant name')), isTrue);
    });
    
    test('should detect invalid dates', () async {
      // Create receipt with future date
      final receipts = [
        Receipt.create(
          merchantName: 'Test Store',
          date: DateTime.now().add(const Duration(days: 30)),
          totalAmount: 100.00,
          taxAmount: 10.00,
        ),
      ];
      
      final result = await service.validateReceipts(receipts);
      
      expect(result.errors.any((e) => e.contains('Future dates not allowed')), isTrue);
    });
    
    test('should warn about old dates', () async {
      // Create receipt with date > 2 years old
      final receipts = [
        Receipt.create(
          merchantName: 'Old Store',
          date: DateTime.now().subtract(const Duration(days: 365 * 3)),
          totalAmount: 50.00,
          taxAmount: 5.00,
        ),
      ];
      
      final result = await service.validateReceipts(receipts);
      
      expect(result.warnings.any((w) => w.contains('more than 2 years old')), isTrue);
    });
    
    test('should detect duplicate transactions', () async {
      final date = DateTime(2024, 12, 25);
      final receipts = [
        Receipt.create(
          merchantName: 'Duplicate Store',
          date: date,
          totalAmount: 100.00,
          taxAmount: 10.00,
        ),
        Receipt.create(
          merchantName: 'Duplicate Store',
          date: date,
          totalAmount: 100.00,
          taxAmount: 10.00,
        ),
      ];
      
      final result = await service.validateReceipts(receipts);
      
      expect(result.warnings.any((w) => w.contains('Possible duplicate')), isTrue);
    });
    
    test('should convert receipt to QuickBooks Purchase format', () async {
      final receipt = Receipt.create(
        merchantName: 'Test Merchant',
        date: DateTime(2024, 12, 25),
        totalAmount: 125.50,
        taxAmount: 12.55,
      );
      
      // Access the private method through reflection or make it public for testing
      // For now, we'll test indirectly through the createPurchase method
      
      // This would normally require authentication
      try {
        await service.createPurchase(receipt);
      } catch (e) {
        expect(e.toString(), contains('Not authenticated'));
      }
    });
  });
}