import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/infrastructure/mocks/mock_receipt_repository.dart';
import 'package:receipt_organizer/infrastructure/mocks/mock_image_storage_service.dart';
import 'package:receipt_organizer/infrastructure/mocks/mock_sync_service.dart';
import 'package:receipt_organizer/infrastructure/mocks/mock_auth_service.dart';
import 'package:receipt_organizer/domain/services/service_locator.dart';
import 'package:receipt_organizer/core/models/receipt.dart';
import 'dart:typed_data';

void main() {
  group('Mock Services Basic Tests', () {
    test('MockReceiptRepository basic operations', () async {
      final repository = MockReceiptRepository();
      
      // Create a receipt using the actual model
      final receipt = Receipt.create(
        merchantName: 'Test Store',
        date: DateTime.now(),
        totalAmount: 99.99,
      );
      
      // Test create
      final createResult = await repository.create(receipt);
      expect(createResult.isSuccess, isTrue);
      expect(createResult.valueOrNull, isNotNull);
      
      final createdId = createResult.valueOrNull!.id;
      expect(createdId, isNotEmpty);
      
      // Test read
      final getResult = await repository.getById(createdId);
      expect(getResult.isSuccess, isTrue);
      expect(getResult.valueOrNull?.merchantName, equals('Test Store'));
      
      // Test update
      final updatedReceipt = getResult.valueOrNull!.copyWith(
        merchantName: 'Updated Store',
      );
      final updateResult = await repository.update(updatedReceipt);
      expect(updateResult.isSuccess, isTrue);
      
      // Test delete
      final deleteResult = await repository.delete(createdId);
      expect(deleteResult.isSuccess, isTrue);
      
      // Clean up
      repository.clear();
      repository.dispose();
    });
    
    test('MockImageStorageService basic operations', () async {
      final storage = MockImageStorageService();
      
      // Test save image
      final imageData = Uint8List.fromList([1, 2, 3, 4, 5]);
      final saveResult = await storage.saveImage(imageData);
      expect(saveResult.isSuccess, isTrue);
      
      final path = saveResult.valueOrNull!;
      expect(path, isNotEmpty);
      
      // Test get image
      final getResult = await storage.getImage(path);
      expect(getResult.isSuccess, isTrue);
      expect(getResult.valueOrNull, equals(imageData));
      
      // Test get URL
      final urlResult = await storage.getImageUrl(path);
      expect(urlResult.isSuccess, isTrue);
      expect(urlResult.valueOrNull, contains('mock://'));
      
      // Test delete
      final deleteResult = await storage.deleteImage(path);
      expect(deleteResult.isSuccess, isTrue);
      
      // Verify deleted
      final existsResult = await storage.exists(path);
      expect(existsResult.valueOrNull, isFalse);
      
      storage.clear();
    });
    
    test('MockSyncService basic operations', () async {
      final syncService = MockSyncService();
      
      // Test sync all
      final syncResult = await syncService.syncAll();
      expect(syncResult.isSuccess, isTrue);
      expect(syncResult.valueOrNull?.itemsUploaded, greaterThanOrEqualTo(0));
      
      // Test sync state
      final stateResult = await syncService.getSyncState();
      expect(stateResult.isSuccess, isTrue);
      expect(stateResult.valueOrNull?.status, isNotNull);
      
      // Test pause/resume
      await syncService.pauseSync();
      final pausedState = await syncService.getSyncState();
      expect(pausedState.valueOrNull?.status.toString(), contains('paused'));
      
      await syncService.resumeSync();
      final resumedState = await syncService.getSyncState();
      expect(resumedState.valueOrNull?.status.toString(), contains('idle'));
      
      syncService.clear();
      syncService.dispose();
    });
    
    test('MockAuthService basic operations', () async {
      final authService = MockAuthService();
      
      // Test sign up
      final signUpResult = await authService.signUp(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      );
      expect(signUpResult.isSuccess, isTrue);
      expect(signUpResult.valueOrNull?.email, equals('test@example.com'));
      
      // Test sign out
      await authService.signOut();
      
      // Test sign in
      final signInResult = await authService.signIn(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(signInResult.isSuccess, isTrue);
      
      // Test current user
      final currentUser = await authService.getCurrentUser();
      expect(currentUser.valueOrNull, isNotNull);
      
      // Test is authenticated
      final isAuth = await authService.isAuthenticated();
      expect(isAuth.valueOrNull, isTrue);
      
      authService.clear();
      authService.dispose();
    });
    
    test('ServiceLocator initializes with mocks', () async {
      // Reset if already initialized
      if (ServiceLocator.isInitialized) {
        await ServiceLocator.reset();
      }
      
      // Initialize with mocks
      await ServiceLocator.initialize(
        environment: ServiceEnvironment.local,
        useMocks: true,
      );
      
      expect(ServiceLocator.isInitialized, isTrue);
      expect(ServiceLocator.isUsingMocks, isTrue);
      
      // Get services
      final repository = ServiceLocator.instance.receiptRepository;
      final storage = ServiceLocator.instance.imageStorage;
      final sync = ServiceLocator.instance.syncService;
      final auth = ServiceLocator.instance.authService;
      
      expect(repository, isNotNull);
      expect(storage, isNotNull);
      expect(sync, isNotNull);
      expect(auth, isNotNull);
      
      // Test that services work
      final receipt = Receipt.create(
        merchantName: 'ServiceLocator Test',
        totalAmount: 50.00,
      );
      
      final result = await repository.create(receipt);
      expect(result.isSuccess, isTrue);
      
      await ServiceLocator.reset();
    });
  });
}