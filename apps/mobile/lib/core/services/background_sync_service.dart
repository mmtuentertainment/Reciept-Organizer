import 'dart:io';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'request_queue_service.dart';
import 'network_connectivity_service.dart';

/// Background sync service for processing queue
///
/// EXPERIMENT: Phase 4 - Minimal background processing
/// Uses flutter_background_service for Android and iOS background execution
class BackgroundSyncService {
  static final BackgroundSyncService _instance = BackgroundSyncService._internal();
  factory BackgroundSyncService() => _instance;
  BackgroundSyncService._internal();

  // Task identifiers
  static const String _syncTaskName = 'receipt_queue_sync';
  static const String _syncTaskTag = 'queue_sync';

  // Configuration
  static const Duration _syncInterval = Duration(minutes: 15);
  static const Duration _initialDelay = Duration(minutes: 5);

  /// Initialize background sync
  /// This should be called from main() before runApp()
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'receipt_organizer_background',
        initialNotificationTitle: 'Receipt Organizer',
        initialNotificationContent: 'Background sync running',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  /// Register periodic sync task
  Future<void> registerPeriodicSync() async {
    try {
      final service = FlutterBackgroundService();

      // Start the service if not already running
      final isRunning = await service.isRunning();
      if (!isRunning) {
        await service.startService();
      }

      // Set up periodic timer in the service
      // The actual periodic execution is handled in onStart method
      print('BackgroundSyncService: Registered periodic sync');
    } catch (e) {
      print('BackgroundSyncService: Failed to register sync: $e');
    }
  }

  /// Register one-time sync task
  /// Useful for immediate retry after queue operation
  Future<void> registerOneTimeSync({
    Duration delay = const Duration(minutes: 1),
  }) async {
    try {
      final service = FlutterBackgroundService();

      // Schedule a one-time sync by invoking the service
      Timer(delay, () async {
        if (await service.isRunning()) {
          service.invoke('oneTimeSync');
        }
      });

      print('BackgroundSyncService: Registered one-time sync');
    } catch (e) {
      print('BackgroundSyncService: Failed to register one-time sync: $e');
    }
  }

  /// Cancel all sync tasks
  Future<void> cancelSync() async {
    try {
      final service = FlutterBackgroundService();
      service.invoke('stop');
      print('BackgroundSyncService: Cancelled all sync tasks');
    } catch (e) {
      print('BackgroundSyncService: Failed to cancel sync: $e');
    }
  }

  /// Check if background sync is available
  /// Some devices may restrict background execution
  bool isBackgroundSyncAvailable() {
    // Basic check - can be enhanced with device-specific logic
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    return {
      'available': isBackgroundSyncAvailable(),
      'platform': Platform.operatingSystem,
      'syncInterval': _syncInterval.inMinutes,
      'taskName': _syncTaskName,
    };
  }
}

/// Android/iOS foreground service entry point
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only for Android
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  // Handle stop event
  service.on('stop').listen((event) {
    service.stopSelf();
  });

  // Handle one-time sync
  service.on('oneTimeSync').listen((event) async {
    await _performSync();
  });

  // Set up periodic timer for sync
  Timer.periodic(const Duration(minutes: 15), (timer) async {
    await _performSync();
  });

  // Initial sync
  await _performSync();
}

/// iOS background task entry point
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  await _performSync();

  return true;
}

/// Perform the actual sync operation
Future<void> _performSync() async {
  print('BackgroundSyncService: Performing sync');

  try {
    // Initialize services
    final queueService = RequestQueueService();
    final connectivity = NetworkConnectivityService();

    // Check connectivity
    final canSync = await connectivity.forceCheck();
    if (!canSync) {
      print('BackgroundSyncService: No connectivity, skipping sync');
      return;
    }

    // Process queue
    print('BackgroundSyncService: Processing queue in background');
    await queueService.processQueue();

    // Get statistics for logging
    final stats = await queueService.getStatistics();
    print('BackgroundSyncService: Queue stats: $stats');
  } catch (e) {
    print('BackgroundSyncService: Error during background sync: $e');
  }
}