import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/receipts/providers/realtime_sync_provider.dart';
import 'package:receipt_organizer/features/receipts/providers/presence_provider.dart';
import 'package:receipt_organizer/core/services/supabase_service.dart';

void main() {
  group('Real-time Sync Tests', () {
    late ProviderContainer container;
    
    setUp(() {
      container = ProviderContainer();
    });
    
    tearDown(() {
      container.dispose();
    });
    
    test('RealtimeSyncState initializes with correct defaults', () {
      const state = RealtimeSyncState();
      
      expect(state.isConnected, false);
      expect(state.isSyncing, false);
      expect(state.lastSyncTime, null);
      expect(state.lastError, null);
      expect(state.pendingChanges, 0);
      expect(state.totalSyncedReceipts, 0);
    });
    
    test('RealtimeSyncState copyWith works correctly', () {
      const state = RealtimeSyncState();
      final newState = state.copyWith(
        isConnected: true,
        pendingChanges: 5,
        lastSyncTime: DateTime(2025, 1, 11),
      );
      
      expect(newState.isConnected, true);
      expect(newState.pendingChanges, 5);
      expect(newState.lastSyncTime?.year, 2025);
      expect(newState.isSyncing, false); // Should remain unchanged
    });
    
    test('PresenceState initializes with correct defaults', () {
      const state = PresenceState();
      
      expect(state.isActive, false);
      expect(state.currentUserId, null);
      expect(state.currentDevice, null);
      expect(state.activeDevices, isEmpty);
      expect(state.totalActiveDevices, 0);
      expect(state.error, null);
    });
    
    test('ActiveDevice getters work correctly', () {
      final device = ActiveDevice(
        userId: 'test-user',
        email: 'test@example.com',
        device: {
          'name': 'Test Phone',
          'platform': 'android',
          'id': '12345',
        },
        lastSeen: DateTime.now(),
      );
      
      expect(device.deviceName, 'Test Phone');
      expect(device.platform, 'android');
      expect(device.deviceId, '12345');
    });
    
    test('ActiveDevice handles missing device info gracefully', () {
      final device = ActiveDevice(
        userId: 'test-user',
        email: 'test@example.com',
        device: {},
        lastSeen: DateTime.now(),
      );
      
      expect(device.deviceName, 'Unknown Device');
      expect(device.platform, 'unknown');
      expect(device.deviceId, '');
    });
  });
  
  group('Provider Tests', () {
    test('supabaseServiceProvider returns singleton instance', () {
      final container = ProviderContainer();
      
      final service1 = container.read(supabaseServiceProvider);
      final service2 = container.read(supabaseServiceProvider);
      
      expect(identical(service1, service2), true);
      expect(service1, equals(SupabaseService.instance));
      
      container.dispose();
    });
  });
}