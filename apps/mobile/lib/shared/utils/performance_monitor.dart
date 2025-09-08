import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';

/// Performance monitoring utility for tracking FPS and gesture response times
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  
  factory PerformanceMonitor() => _instance;
  
  PerformanceMonitor._internal();
  
  // FPS tracking
  int _frameCount = 0;
  double _currentFps = 0;
  Timer? _fpsTimer;
  final List<double> _fpsHistory = [];
  static const int _maxHistorySize = 100;
  
  // Gesture response tracking
  final Map<String, int> _gestureStartTimes = {};
  final List<int> _gestureResponseTimes = [];
  
  // Memory tracking
  int _lastMemoryUsage = 0;
  final List<int> _memoryHistory = [];
  
  // Callbacks
  final List<Function(PerformanceMetrics)> _listeners = [];
  
  /// Start monitoring performance
  void startMonitoring() {
    if (_fpsTimer != null) return;
    
    // Start FPS monitoring
    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentFps = _frameCount.toDouble();
      _frameCount = 0;
      
      _fpsHistory.add(_currentFps);
      if (_fpsHistory.length > _maxHistorySize) {
        _fpsHistory.removeAt(0);
      }
      
      _updateMemoryUsage();
      _notifyListeners();
    });
    
    // Register frame callback
    SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);
  }
  
  /// Stop monitoring
  void stopMonitoring() {
    _fpsTimer?.cancel();
    _fpsTimer = null;
    _frameCount = 0;
    _currentFps = 0;
  }
  
  /// Record frame
  void _onFrame(Duration timestamp) {
    if (_fpsTimer != null) {
      _frameCount++;
    }
  }
  
  /// Record gesture start
  void recordGestureStart(String gestureId) {
    _gestureStartTimes[gestureId] = DateTime.now().microsecondsSinceEpoch;
  }
  
  /// Record gesture end and calculate response time
  void recordGestureEnd(String gestureId) {
    final startTime = _gestureStartTimes.remove(gestureId);
    if (startTime != null) {
      final responseTime = DateTime.now().microsecondsSinceEpoch - startTime;
      _gestureResponseTimes.add(responseTime);
      
      if (_gestureResponseTimes.length > _maxHistorySize) {
        _gestureResponseTimes.removeAt(0);
      }
      
      if (kDebugMode && responseTime > 16000) {
        // Warn if gesture takes more than 16ms
        debugPrint('⚠️ Slow gesture response: ${responseTime ~/ 1000}ms for $gestureId');
      }
    }
  }
  
  /// Update memory usage
  void _updateMemoryUsage() {
    // In a real app, you'd use actual memory profiling
    // For demo, we'll simulate memory usage tracking
    _lastMemoryUsage = DateTime.now().millisecondsSinceEpoch % 100000000; // Fake value
    _memoryHistory.add(_lastMemoryUsage);
    
    if (_memoryHistory.length > _maxHistorySize) {
      _memoryHistory.removeAt(0);
    }
  }
  
  /// Add performance listener
  void addListener(Function(PerformanceMetrics) listener) {
    _listeners.add(listener);
  }
  
  /// Remove performance listener
  void removeListener(Function(PerformanceMetrics) listener) {
    _listeners.remove(listener);
  }
  
  /// Notify all listeners
  void _notifyListeners() {
    final metrics = getMetrics();
    for (final listener in _listeners) {
      listener(metrics);
    }
  }
  
  /// Get current performance metrics
  PerformanceMetrics getMetrics() {
    return PerformanceMetrics(
      currentFps: _currentFps,
      averageFps: _calculateAverage(_fpsHistory),
      minFps: _fpsHistory.isEmpty ? 0 : _fpsHistory.reduce((a, b) => a < b ? a : b),
      maxFps: _fpsHistory.isEmpty ? 0 : _fpsHistory.reduce((a, b) => a > b ? a : b),
      averageGestureResponseUs: _calculateAverageInt(_gestureResponseTimes),
      maxGestureResponseUs: _gestureResponseTimes.isEmpty ? 0 : 
          _gestureResponseTimes.reduce((a, b) => a > b ? a : b),
      currentMemoryMb: _lastMemoryUsage / 1024 / 1024,
      fpsHistory: List.from(_fpsHistory),
      isPerformant: _currentFps >= 55 && 
          (_gestureResponseTimes.isEmpty || 
           _calculateAverageInt(_gestureResponseTimes) < 16000),
    );
  }
  
  /// Calculate average of double list
  double _calculateAverage(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }
  
  /// Calculate average of int list
  int _calculateAverageInt(List<int> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) ~/ values.length;
  }
  
  /// Clear all history
  void clearHistory() {
    _fpsHistory.clear();
    _gestureResponseTimes.clear();
    _memoryHistory.clear();
  }
}

/// Performance metrics data class
class PerformanceMetrics {
  final double currentFps;
  final double averageFps;
  final double minFps;
  final double maxFps;
  final int averageGestureResponseUs;
  final int maxGestureResponseUs;
  final double currentMemoryMb;
  final List<double> fpsHistory;
  final bool isPerformant;
  
  const PerformanceMetrics({
    required this.currentFps,
    required this.averageFps,
    required this.minFps,
    required this.maxFps,
    required this.averageGestureResponseUs,
    required this.maxGestureResponseUs,
    required this.currentMemoryMb,
    required this.fpsHistory,
    required this.isPerformant,
  });
  
  /// Get average gesture response time in milliseconds
  double get averageGestureResponseMs => averageGestureResponseUs / 1000;
  
  /// Get max gesture response time in milliseconds
  double get maxGestureResponseMs => maxGestureResponseUs / 1000;
  
  /// Check if FPS is below target
  bool get isFpsBelowTarget => currentFps < 55;
  
  /// Check if gesture response is slow
  bool get isGestureResponseSlow => averageGestureResponseUs > 16000;
  
  /// Get performance summary
  String get summary {
    return '''
Performance Summary:
- FPS: ${currentFps.toStringAsFixed(1)} (avg: ${averageFps.toStringAsFixed(1)})
- Gesture Response: ${averageGestureResponseMs.toStringAsFixed(1)}ms (max: ${maxGestureResponseMs.toStringAsFixed(1)}ms)
- Memory: ${currentMemoryMb.toStringAsFixed(1)}MB
- Status: ${isPerformant ? '✅ Good' : '⚠️ Needs Optimization'}
''';
  }
}

/// Performance monitoring widget that can be overlaid on any screen
class PerformanceOverlay extends StatefulWidget {
  final Widget child;
  final bool enabled;
  
  const PerformanceOverlay({
    Key? key,
    required this.child,
    this.enabled = true,
  }) ;
  
  @override
  State<PerformanceOverlay> createState() => _PerformanceOverlayState();
}

class _PerformanceOverlayState extends State<PerformanceOverlay> {
  final PerformanceMonitor _monitor = PerformanceMonitor();
  PerformanceMetrics? _metrics;
  
  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _monitor.startMonitoring();
      _monitor.addListener(_onMetricsUpdate);
    }
  }
  
  @override
  void dispose() {
    _monitor.removeListener(_onMetricsUpdate);
    super.dispose();
  }
  
  void _onMetricsUpdate(PerformanceMetrics metrics) {
    if (mounted) {
      setState(() {
        _metrics = metrics;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || _metrics == null) {
      return widget.child;
    }
    
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 50,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _metrics!.isPerformant 
                  ? Colors.green.withAlpha((0.9 * 255).round()) 
                  : Colors.orange.withAlpha((0.9 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'FPS: ${_metrics!.currentFps.toStringAsFixed(1)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Gesture: ${_metrics!.averageGestureResponseMs.toStringAsFixed(1)}ms',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}