import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:receipt_organizer/core/services/supabase_service.dart';
import 'package:receipt_organizer/features/receipts/providers/realtime_sync_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

/// Provider for managing user presence and active devices
class PresenceNotifier extends StateNotifier<PresenceState> {
  final SupabaseService _supabaseService;
  RealtimeChannel? _presenceChannel;
  
  PresenceNotifier(this._supabaseService) : super(const PresenceState());
  
  /// Initialize presence tracking
  Future<void> initialize() async {
    if (!_supabaseService.isAuthenticated) {
      state = state.copyWith(
        isActive: false,
        error: 'User not authenticated',
      );
      return;
    }
    
    try {
      final userId = _supabaseService.currentUser?.id;
      final userEmail = _supabaseService.currentUser?.email;
      
      // Create presence channel
      _presenceChannel = _supabaseService.client
          .channel('presence:receipts')
          .onPresenceSync((payload) {
            _handlePresenceSync();
          })
          .onPresenceJoin((payload) {
            _handlePresenceJoin(payload);
          })
          .onPresenceLeave((payload) {
            _handlePresenceLeave(payload);
          });
      
      // Track this device's presence
      final deviceInfo = await _getDeviceInfo();
      await _presenceChannel!.track({
        'user_id': userId,
        'email': userEmail,
        'device': deviceInfo,
        'last_seen': DateTime.now().toIso8601String(),
      });
      
      // Subscribe to the channel
      await _presenceChannel!.subscribe();
      
      state = state.copyWith(
        isActive: true,
        currentUserId: userId,
        currentDevice: deviceInfo,
        error: null,
      );
      
      debugPrint('✅ Presence tracking initialized');
    } catch (e) {
      state = state.copyWith(
        isActive: false,
        error: e.toString(),
      );
      debugPrint('❌ Failed to initialize presence: $e');
    }
  }
  
  /// Get device information
  Future<Map<String, String>> _getDeviceInfo() async {
    String platform = 'unknown';
    String deviceName = 'Unknown Device';
    
    try {
      if (Platform.isAndroid) {
        platform = 'android';
        deviceName = 'Android Device';
      } else if (Platform.isIOS) {
        platform = 'ios';
        deviceName = 'iOS Device';
      } else if (Platform.isMacOS) {
        platform = 'macos';
        deviceName = 'Mac';
      } else if (Platform.isWindows) {
        platform = 'windows';
        deviceName = 'Windows PC';
      } else if (Platform.isLinux) {
        platform = 'linux';
        deviceName = 'Linux Device';
      }
    } catch (e) {
      // Running in web or test environment
      platform = 'web';
      deviceName = 'Web Browser';
    }
    
    return {
      'platform': platform,
      'name': deviceName,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    };
  }
  
  /// Handle presence sync
  void _handlePresenceSync() {
    final presenceState = _presenceChannel?.presenceState();
    if (presenceState == null) return;
    
    final activeDevices = <ActiveDevice>[];
    
    // presenceState is a List<SinglePresenceState>, not a Map
    for (final presence in presenceState) {
      final presences = presence.presences;
      for (final item in presences) {
        final data = item as Map<String, dynamic>;
        activeDevices.add(ActiveDevice(
          userId: data['user_id'] ?? '',
          email: data['email'] ?? '',
          device: Map<String, String>.from(data['device'] ?? {}),
          lastSeen: DateTime.parse(data['last_seen'] ?? DateTime.now().toIso8601String()),
        ));
      }
    }
    
    state = state.copyWith(
      activeDevices: activeDevices,
      totalActiveDevices: activeDevices.length,
    );
    
    debugPrint('👥 Active devices: ${activeDevices.length}');
  }
  
  /// Handle user joining
  void _handlePresenceJoin(dynamic payload) {
    debugPrint('👋 Device joined: $payload');
    _handlePresenceSync();
  }
  
  /// Handle user leaving
  void _handlePresenceLeave(dynamic payload) {
    debugPrint('👋 Device left: $payload');
    _handlePresenceSync();
  }
  
  /// Update presence status
  Future<void> updatePresence() async {
    if (_presenceChannel == null) return;
    
    try {
      final userId = _supabaseService.currentUser?.id;
      final userEmail = _supabaseService.currentUser?.email;
      final deviceInfo = state.currentDevice ?? await _getDeviceInfo();
      
      await _presenceChannel!.track({
        'user_id': userId,
        'email': userEmail,
        'device': deviceInfo,
        'last_seen': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('❌ Failed to update presence: $e');
    }
  }
  
  /// Disconnect presence tracking
  Future<void> disconnect() async {
    if (_presenceChannel != null) {
      await _presenceChannel!.untrack();
      await _supabaseService.unsubscribe(_presenceChannel!);
      _presenceChannel = null;
    }
    
    state = state.copyWith(
      isActive: false,
      activeDevices: [],
      totalActiveDevices: 0,
    );
    
    debugPrint('🔌 Presence tracking disconnected');
  }
  
  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

/// Active device information
@immutable
class ActiveDevice {
  final String userId;
  final String email;
  final Map<String, String> device;
  final DateTime lastSeen;
  
  const ActiveDevice({
    required this.userId,
    required this.email,
    required this.device,
    required this.lastSeen,
  });
  
  String get deviceName => device['name'] ?? 'Unknown Device';
  String get platform => device['platform'] ?? 'unknown';
  String get deviceId => device['id'] ?? '';
  
  bool get isCurrentDevice => deviceId == DateTime.now().millisecondsSinceEpoch.toString();
}

/// State for presence tracking
@immutable
class PresenceState {
  final bool isActive;
  final String? currentUserId;
  final Map<String, String>? currentDevice;
  final List<ActiveDevice> activeDevices;
  final int totalActiveDevices;
  final String? error;
  
  const PresenceState({
    this.isActive = false,
    this.currentUserId,
    this.currentDevice,
    this.activeDevices = const [],
    this.totalActiveDevices = 0,
    this.error,
  });
  
  PresenceState copyWith({
    bool? isActive,
    String? currentUserId,
    Map<String, String>? currentDevice,
    List<ActiveDevice>? activeDevices,
    int? totalActiveDevices,
    String? error,
  }) {
    return PresenceState(
      isActive: isActive ?? this.isActive,
      currentUserId: currentUserId ?? this.currentUserId,
      currentDevice: currentDevice ?? this.currentDevice,
      activeDevices: activeDevices ?? this.activeDevices,
      totalActiveDevices: totalActiveDevices ?? this.totalActiveDevices,
      error: error ?? this.error,
    );
  }
}

/// Provider for presence tracking
final presenceProvider = StateNotifierProvider<PresenceNotifier, PresenceState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return PresenceNotifier(supabaseService);
});

/// Provider to auto-initialize presence
final presenceInitializerProvider = FutureProvider<void>((ref) async {
  final presenceNotifier = ref.read(presenceProvider.notifier);
  await presenceNotifier.initialize();
});

// Note: supabaseServiceProvider is imported from realtime_sync_provider.dart