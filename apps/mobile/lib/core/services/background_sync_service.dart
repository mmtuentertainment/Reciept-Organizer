import 'dart:io';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:receipt_organizer/core/platform/background.dart';
import 'package:receipt_organizer/core/platform/mobile/background_processor_mobile.dart';
import 'package:receipt_organizer/core/platform/web/background_processor_web.dart';
import 'request_queue_service.dart';
import 'network_connectivity_service.dart';

/// Background sync service for processing queue
///
/// EXPERIMENT: Phase 4 - Minimal background processing
/// Implements a simple periodic sync approach without complex scheduling.
///
/// Sync Strategy:
/// - Checks queue every 30 seconds for pending requests
/// - Processes pending requests when connected
/// - Minimal battery impact
/// - Works on both Android and iOS
class BackgroundSyncService {
  static const Duration _syncInterval = Duration(seconds: 30);
  static const Duration _initialDelay = Duration(minutes: 5);

  final BackgroundProcessor _processor;

  BackgroundSyncService._() : _processor = kIsWeb
      ? BackgroundProcessorWeb()
      : BackgroundProcessorMobile();

  static final BackgroundSyncService _instance = BackgroundSyncService._();
  static BackgroundSyncService get instance => _instance;

  /// Initialize background sync
  /// This should be called from main() before runApp()
  static Future<void> initialize() async {
    await _instance._processor.initialize();
  }

  /// Register periodic sync task
  Future<void> registerPeriodicSync() async {
    try {
      await _processor.schedulePeriodic(
        taskId: 'queue_sync',
        interval: _syncInterval,
        task: _performSync,
      );

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
      await _processor.scheduleOneTime(
        taskId: 'one_time_sync',
        when: DateTime.now().add(delay),
        task: _performSync,
      );

      print('BackgroundSyncService: Registered one-time sync');
    } catch (e) {
      print('BackgroundSyncService: Failed to register one-time sync: $e');
    }
  }

  /// Cancel all sync tasks
  Future<void> cancelSync() async {
    try {
      await _processor.cancelAllTasks();
      print('BackgroundSyncService: Cancelled all sync tasks');
    } catch (e) {
      print('BackgroundSyncService: Failed to cancel sync: $e');
    }
  }

  /// Check if background sync is available
  /// Some devices may restrict background execution
  Future<bool> isBackgroundSyncAvailable() async {
    return await _processor.isAvailable();
  }

  /// Perform the actual sync operation
  static Future<void> _performSync() async {
    print('BackgroundSyncService: Starting sync at ${DateTime.now()}');

    try {
      // Check network connectivity
      final connectivity = NetworkConnectivityService.instance;
      if (!await connectivity.isConnected) {
        print('BackgroundSyncService: No network connection, skipping sync');
        return;
      }

      // Process queue
      final queue = RequestQueueService.instance;
      await queue.processQueue();

      // processQueue() handles its own logging
      print('BackgroundSyncService: Queue processing completed');
    } catch (e) {
      print('BackgroundSyncService: Sync failed: $e');
    }
  }

  /// Handle sync success for analytics/monitoring
  void handleSyncSuccess(int itemsProcessed) {
    // Log to analytics
    print('BackgroundSync: Successfully processed $itemsProcessed items');

    // Could send telemetry here
  }

  /// Handle sync failure for retry logic
  void handleSyncFailure(String error) {
    // Log error
    print('BackgroundSync: Sync failed: $error');

    // Schedule retry with exponential backoff
    registerOneTimeSync(delay: const Duration(minutes: 5));
  }
}