import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/core/services/background_sync_service.dart';
import 'package:receipt_organizer/core/services/network_connectivity_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize sqflite_ffi for desktop testing
  if (!Platform.isAndroid && !Platform.isIOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  group('Background Service Integration', () {
    late BackgroundSyncService backgroundService;
    late NetworkConnectivityService connectivityService;

    setUp(() {
      backgroundService = BackgroundSyncService();
      connectivityService = NetworkConnectivityService();
    });

    test('Background service should be available on supported platforms', () {
      final isAvailable = backgroundService.isBackgroundSyncAvailable();
      // On test platform (Linux), this will be false
      // On Android/iOS, this should be true
      expect(isAvailable, Platform.isAndroid || Platform.isIOS);
    });

    test('Should get sync status with correct configuration', () async {
      final status = await backgroundService.getSyncStatus();

      expect(status['available'], Platform.isAndroid || Platform.isIOS);
      expect(status['syncInterval'], 15); // 15 minutes
      expect(status['taskName'], 'receipt_queue_sync');
    });

    test('Network connectivity service should initialize', () async {
      // Force a connectivity check
      final isConnected = await connectivityService.forceCheck();
      // May be true or false depending on actual network
      expect(isConnected, isA<bool>());
    });

    test('Background service methods should handle platform limitations gracefully', () {
      // On non-mobile platforms, these should complete without throwing
      // even though they won't actually register tasks
      expect(() => backgroundService.registerPeriodicSync(), returnsNormally);
      expect(() => backgroundService.cancelSync(), returnsNormally);
    });

  });
}