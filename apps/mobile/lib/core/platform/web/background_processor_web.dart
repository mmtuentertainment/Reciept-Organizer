import 'dart:async';
import '../interfaces/background_processor.dart';

/// Web background processing using timers
/// Note: Web Workers could be used for more intensive background tasks
class BackgroundProcessorWeb implements BackgroundProcessor {
  final Map<String, Timer> _timers = {};
  bool _isInitialized = false;

  @override
  String get platform => 'web';

  @override
  Future<bool> isAvailable() async {
    // Basic timer-based background processing is always available on web
    return true;
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    print('BackgroundProcessorWeb initialized');
  }

  @override
  Future<void> schedulePeriodic({
    required String taskId,
    required Duration interval,
    required Future<void> Function() task,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Cancel existing timer if any
    _timers[taskId]?.cancel();

    // Use JavaScript setInterval for background execution
    _timers[taskId] = Timer.periodic(interval, (_) async {
      try {
        // Run task
        await task();
        print('Web background task $taskId executed successfully');
      } catch (e) {
        print('Web background task $taskId failed: $e');
      }
    });

    print('Scheduled periodic web task $taskId with interval $interval');
  }

  @override
  Future<void> scheduleOneTime({
    required String taskId,
    required DateTime when,
    required Future<void> Function() task,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final delay = when.difference(DateTime.now());
    if (delay.isNegative) {
      print('Task $taskId scheduled time has passed, executing immediately');
      await task();
      return;
    }

    _timers[taskId]?.cancel();
    _timers[taskId] = Timer(delay, () async {
      try {
        await task();
        _timers.remove(taskId);
        print('One-time web task $taskId executed successfully');
      } catch (e) {
        print('One-time web task $taskId failed: $e');
      }
    });

    print('Scheduled one-time web task $taskId at $when');
  }

  @override
  Future<void> cancelTask(String taskId) async {
    _timers[taskId]?.cancel();
    _timers.remove(taskId);
    print('Cancelled web task $taskId');
  }

  @override
  Future<void> cancelAllTasks() async {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    print('Cancelled all web background tasks');
  }

  /// Example of using Web Workers for CPU-intensive tasks
  /// This would be created in a separate worker.js file
  /*
  // worker.js content:
  self.addEventListener('message', function(e) {
    const data = e.data;
    switch (data.cmd) {
      case 'process':
        // Perform intensive processing
        const result = performProcessing(data.payload);
        self.postMessage({cmd: 'result', data: result});
        break;
      case 'stop':
        self.close();
        break;
    }
  });

  // In Dart, you would use:
  html.Worker? _createWorker(String scriptUrl) {
    try {
      return html.Worker(scriptUrl);
    } catch (e) {
      print('Failed to create Web Worker: $e');
      return null;
    }
  }
  */
}