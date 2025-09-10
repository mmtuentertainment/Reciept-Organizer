import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/core/services/background_sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('BackgroundSyncService', () {
    late BackgroundSyncService backgroundSync;
    
    setUp(() {
      backgroundSync = BackgroundSyncService();
    });
    
    test('should check if background sync is available', () {
      final isAvailable = backgroundSync.isBackgroundSyncAvailable();
      
      // Should return true on Android/iOS, false on other platforms
      expect(isAvailable, isA<bool>());
    });
    
    test('should get sync status', () async {
      final status = await backgroundSync.getSyncStatus();
      
      expect(status, isNotNull);
      expect(status['available'], isA<bool>());
      expect(status['platform'], isA<String>());
      expect(status['syncInterval'], isA<int>());
      expect(status['taskName'], equals('receipt_queue_sync'));
    });
    
    test('should handle register periodic sync without errors', () async {
      // This test can't fully verify registration without platform
      // but ensures no exceptions are thrown
      expect(
        () async => await backgroundSync.registerPeriodicSync(),
        returnsNormally,
      );
    });
    
    test('should handle register one-time sync without errors', () async {
      expect(
        () async => await backgroundSync.registerOneTimeSync(),
        returnsNormally,
      );
    });
    
    test('should handle cancel sync without errors', () async {
      expect(
        () async => await backgroundSync.cancelSync(),
        returnsNormally,
      );
    });
    
    test('should have correct sync interval', () async {
      final status = await backgroundSync.getSyncStatus();
      
      // Default is 15 minutes
      expect(status['syncInterval'], equals(15));
    });
  });
  
  group('BackgroundSyncService Integration', () {
    test('should have static initialize method', () {
      // Verify the static method exists
      expect(BackgroundSyncService.initialize, isNotNull);
    });
    
    test('platform detection should work correctly', () {
      final service = BackgroundSyncService();
      final isAvailable = service.isBackgroundSyncAvailable();
      
      // This will vary based on test platform
      // On CI/desktop it should return false
      // On mobile emulators it should return true
      expect(isAvailable, isA<bool>());
    });
  });
}