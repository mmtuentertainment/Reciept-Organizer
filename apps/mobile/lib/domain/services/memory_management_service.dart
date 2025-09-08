import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class MemoryUsage {
  final int rss; // Resident Set Size (physical memory currently used)
  final int heapUsed;
  final int heapTotal;
  final int external;
  final DateTime timestamp;

  MemoryUsage({
    required this.rss,
    required this.heapUsed,
    required this.heapTotal,
    required this.external,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  double get heapUsagePercent => heapTotal > 0 ? (heapUsed / heapTotal) * 100 : 0;
  
  String get formattedRSS => _formatBytes(rss);
  String get formattedHeapUsed => _formatBytes(heapUsed);
  String get formattedHeapTotal => _formatBytes(heapTotal);

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class MemoryThresholds {
  final int warningThresholdMB;
  final int criticalThresholdMB;
  final double heapUsageWarningPercent;
  final double heapUsageCriticalPercent;

  const MemoryThresholds({
    this.warningThresholdMB = 200,
    this.criticalThresholdMB = 350,
    this.heapUsageWarningPercent = 80.0,
    this.heapUsageCriticalPercent = 90.0,
  });
}

enum MemoryPressure { low, moderate, high, critical }

class MemoryManagementService {
  static final MemoryManagementService _instance = MemoryManagementService._internal();
  factory MemoryManagementService() => _instance;
  MemoryManagementService._internal();

  Timer? _monitoringTimer;
  final List<MemoryUsage> _memoryHistory = [];
  final int _maxHistoryLength = 100;
  
  MemoryThresholds _thresholds = const MemoryThresholds();
  
  // Memory pressure callbacks
  final List<Function(MemoryPressure)> _pressureCallbacks = [];
  MemoryPressure _lastPressure = MemoryPressure.low;
  
  // Image cache management
  final Map<String, Uint8List> _imageCache = {};
  final Map<String, DateTime> _imageCacheAccess = {};
  final int _maxCacheSize = 50;
  final int _maxCacheSizeMB = 100;
  
  // Stream for memory updates
  final StreamController<MemoryUsage> _memoryController = StreamController<MemoryUsage>.broadcast();
  final StreamController<MemoryPressure> _pressureController = StreamController<MemoryPressure>.broadcast();
  
  Stream<MemoryUsage> get memoryStream => _memoryController.stream;
  Stream<MemoryPressure> get pressureStream => _pressureController.stream;

  void initialize({
    MemoryThresholds? thresholds,
    Duration monitoringInterval = const Duration(seconds: 5),
  }) {
    _thresholds = thresholds ?? _thresholds;
    
    if (_monitoringTimer != null) {
      _monitoringTimer!.cancel();
    }
    
    _monitoringTimer = Timer.periodic(monitoringInterval, (_) => _checkMemoryUsage());
    
    // Set up system memory warnings
    SystemChannels.system.setMessageHandler(_handleSystemMessage);
  }

  void dispose() {
    _monitoringTimer?.cancel();
    _memoryController.close();
    _pressureController.close();
    clearImageCache();
  }

  Future<MemoryUsage> getCurrentMemoryUsage() async {
    try {
      // This is a simplified implementation
      // In a real app, you might use platform channels to get actual memory usage
      final processInfo = ProcessInfo.currentRss;
      
      return MemoryUsage(
        rss: processInfo,
        heapUsed: processInfo ~/ 2, // Approximate
        heapTotal: processInfo * 2, // Approximate
        external: 0,
      );
    } catch (e) {
      // Fallback for when ProcessInfo is not available
      return MemoryUsage(
        rss: 100 * 1024 * 1024, // 100MB default
        heapUsed: 50 * 1024 * 1024,
        heapTotal: 200 * 1024 * 1024,
        external: 0,
      );
    }
  }

  MemoryPressure calculateMemoryPressure(MemoryUsage usage) {
    final rssMB = usage.rss / (1024 * 1024);
    final heapPercent = usage.heapUsagePercent;
    
    if (rssMB >= _thresholds.criticalThresholdMB || heapPercent >= _thresholds.heapUsageCriticalPercent) {
      return MemoryPressure.critical;
    } else if (rssMB >= _thresholds.warningThresholdMB || heapPercent >= _thresholds.heapUsageWarningPercent) {
      return MemoryPressure.high;
    } else if (rssMB >= _thresholds.warningThresholdMB * 0.7 || heapPercent >= _thresholds.heapUsageWarningPercent * 0.7) {
      return MemoryPressure.moderate;
    } else {
      return MemoryPressure.low;
    }
  }

  void addPressureCallback(Function(MemoryPressure) callback) {
    _pressureCallbacks.add(callback);
  }

  void removePressureCallback(Function(MemoryPressure) callback) {
    _pressureCallbacks.remove(callback);
  }

  void cacheImage(String id, Uint8List imageData) {
    // Check if we're approaching memory limits
    if (_shouldSkipCaching()) return;
    
    // Remove oldest items if cache is too large
    _evictOldestCacheItems();
    
    _imageCache[id] = imageData;
    _imageCacheAccess[id] = DateTime.now();
  }

  Uint8List? getCachedImage(String id) {
    final image = _imageCache[id];
    if (image != null) {
      _imageCacheAccess[id] = DateTime.now(); // Update access time
    }
    return image;
  }

  void removeCachedImage(String id) {
    _imageCache.remove(id);
    _imageCacheAccess.remove(id);
  }

  void clearImageCache() {
    _imageCache.clear();
    _imageCacheAccess.clear();
  }

  int getCacheSize() {
    return _imageCache.values.fold(0, (sum, image) => sum + image.length);
  }

  int getCacheCount() {
    return _imageCache.length;
  }

  String getFormattedCacheSize() {
    final size = getCacheSize();
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  List<MemoryUsage> getMemoryHistory() {
    return List.from(_memoryHistory);
  }

  double getAverageMemoryUsage({Duration? period}) {
    if (_memoryHistory.isEmpty) return 0;
    
    final now = DateTime.now();
    final items = period != null 
        ? _memoryHistory.where((usage) => now.difference(usage.timestamp) <= period)
        : _memoryHistory;
    
    if (items.isEmpty) return 0;
    
    final sum = items.fold<double>(0, (sum, usage) => sum + (usage.rss / (1024 * 1024)));
    return sum / items.length;
  }

  Future<void> forceGarbageCollection() async {
    // Clear image cache if under memory pressure
    if (_lastPressure == MemoryPressure.high || _lastPressure == MemoryPressure.critical) {
      clearImageCache();
    }
    
    // Force garbage collection (platform specific)
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // On mobile platforms, we can suggest GC
        await SystemChannels.platform.invokeMethod('SystemNavigator.routeUpdated');
      }
    } catch (e) {
      // Ignore if not supported
    }
  }

  Future<void> _checkMemoryUsage() async {
    final usage = await getCurrentMemoryUsage();
    
    // Add to history
    _memoryHistory.add(usage);
    if (_memoryHistory.length > _maxHistoryLength) {
      _memoryHistory.removeAt(0);
    }
    
    // Calculate pressure
    final pressure = calculateMemoryPressure(usage);
    
    // Check if pressure changed
    if (pressure != _lastPressure) {
      _lastPressure = pressure;
      
      // Notify callbacks
      for (final callback in _pressureCallbacks) {
        try {
          callback(pressure);
        } catch (e) {
          // Ignore callback errors
        }
      }
      
      _pressureController.add(pressure);
      
      // Auto-cleanup on high pressure
      if (pressure == MemoryPressure.high || pressure == MemoryPressure.critical) {
        await _performAutomaticCleanup(pressure);
      }
    }
    
    _memoryController.add(usage);
  }

  bool _shouldSkipCaching() {
    // Skip caching if under memory pressure
    if (_lastPressure == MemoryPressure.high || _lastPressure == MemoryPressure.critical) {
      return true;
    }
    
    // Skip if cache is too large
    final cacheSizeMB = getCacheSize() / (1024 * 1024);
    if (cacheSizeMB >= _maxCacheSizeMB) {
      return true;
    }
    
    return false;
  }

  void _evictOldestCacheItems() {
    while (_imageCache.length >= _maxCacheSize) {
      // Find oldest accessed item
      String? oldestKey;
      DateTime? oldestTime;
      
      for (final entry in _imageCacheAccess.entries) {
        if (oldestTime == null || entry.value.isBefore(oldestTime)) {
          oldestTime = entry.value;
          oldestKey = entry.key;
        }
      }
      
      if (oldestKey != null) {
        _imageCache.remove(oldestKey);
        _imageCacheAccess.remove(oldestKey);
      } else {
        break;
      }
    }
  }

  Future<void> _performAutomaticCleanup(MemoryPressure pressure) async {
    if (pressure == MemoryPressure.critical) {
      // Aggressive cleanup
      clearImageCache();
      await forceGarbageCollection();
    } else if (pressure == MemoryPressure.high) {
      // Moderate cleanup - remove half the cache
      final keysToRemove = _imageCacheAccess.entries
          .toList()
          ..sort((a, b) => a.value.compareTo(b.value))
          ..take(_imageCache.length ~/ 2);
      
      for (final entry in keysToRemove) {
        _imageCache.remove(entry.key);
        _imageCacheAccess.remove(entry.key);
      }
    }
  }

  Future<void> _handleSystemMessage(dynamic message) async {
    if (message is Map) {
      final type = message['type'];
      
      if (type == 'memoryPressure') {
        // System is reporting memory pressure
        await forceGarbageCollection();
      }
    }
    
    return;
  }
}