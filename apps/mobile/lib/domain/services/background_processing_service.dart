import 'dart:async';
import 'dart:collection';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:receipt_organizer/domain/services/image_optimization_service.dart';

enum ProcessingTaskType { ocr, imageOptimization, both }

class ProcessingTask {
  final String id;
  final ProcessingTaskType type;
  final String receiptId;
  final Uint8List? imageData;
  final DateTime createdAt;
  final int priority; // Higher number = higher priority

  ProcessingTask({
    required this.id,
    required this.type,
    required this.receiptId,
    this.imageData,
    DateTime? createdAt,
    this.priority = 1,
  }) : createdAt = createdAt ?? DateTime.now();
}

class ProcessingResult {
  final String taskId;
  final String receiptId;
  final ProcessingTaskType type;
  final bool success;
  final ProcessingResult? ocrResult;
  final String? imagePath;
  final String? thumbnailPath;
  final String? error;
  final Duration processingDuration;

  ProcessingResult({
    required this.taskId,
    required this.receiptId,
    required this.type,
    required this.success,
    this.ocrResult,
    this.imagePath,
    this.thumbnailPath,
    this.error,
    required this.processingDuration,
  });
}

class BackgroundProcessingService {
  static final BackgroundProcessingService _instance = BackgroundProcessingService._internal();
  factory BackgroundProcessingService() => _instance;
  BackgroundProcessingService._internal();

  // Task queue with priority ordering
  final PriorityQueue<ProcessingTask> _taskQueue = PriorityQueue<ProcessingTask>();
  
  // Currently processing tasks
  final Map<String, ProcessingTask> _activeTasks = {};
  
  // Completed task results
  final Map<String, ProcessingResult> _completedResults = {};
  
  // Services
  final IOCRService _ocrService = OCRService();
  final ImageOptimizationService _imageOptimizationService = ImageOptimizationService();
  
  // Processing control
  bool _isProcessing = false;
  int _maxConcurrentTasks = 2;
  Timer? _processTimer;
  
  // Statistics
  int _totalTasksProcessed = 0;
  int _totalTasksFailed = 0;
  Duration _totalProcessingTime = Duration.zero;
  
  // Stream controllers for real-time updates
  final StreamController<ProcessingResult> _resultController = StreamController<ProcessingResult>.broadcast();
  final StreamController<ProcessingStats> _statsController = StreamController<ProcessingStats>.broadcast();

  // Public streams
  Stream<ProcessingResult> get resultStream => _resultController.stream;
  Stream<ProcessingStats> get statsStream => _statsController.stream;

  Future<void> initialize() async {
    if (_isProcessing) return;
    
    await _ocrService.initialize();
    _isProcessing = true;
    
    // Start background processing
    _processTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _processNextTasks();
    });
  }

  void dispose() {
    _isProcessing = false;
    _processTimer?.cancel();
    _ocrService.dispose();
    _resultController.close();
    _statsController.close();
  }

  String addTask({
    required ProcessingTaskType type,
    required String receiptId,
    Uint8List? imageData,
    int priority = 1,
  }) {
    final task = ProcessingTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      receiptId: receiptId,
      imageData: imageData,
      priority: priority,
    );
    
    _taskQueue.add(task);
    
    // Emit stats update
    _emitStats();
    
    return task.id;
  }

  ProcessingResult? getResult(String taskId) {
    return _completedResults[taskId];
  }

  List<ProcessingTask> getPendingTasks() {
    return _taskQueue.toList();
  }

  ProcessingStats getStats() {
    return ProcessingStats(
      queueLength: _taskQueue.length,
      activeTasks: _activeTasks.length,
      completedTasks: _totalTasksProcessed,
      failedTasks: _totalTasksFailed,
      averageProcessingTime: _totalTasksProcessed > 0 
          ? Duration(microseconds: _totalProcessingTime.inMicroseconds ~/ _totalTasksProcessed)
          : Duration.zero,
      totalProcessingTime: _totalProcessingTime,
    );
  }

  void clearCompletedResults({int keepLastN = 100}) {
    if (_completedResults.length <= keepLastN) return;
    
    // Keep only the most recent results
    final sortedEntries = _completedResults.entries.toList()
      ..sort((a, b) => b.value.processingDuration.compareTo(a.value.processingDuration));
    
    _completedResults.clear();
    for (final entry in sortedEntries.take(keepLastN)) {
      _completedResults[entry.key] = entry.value;
    }
  }

  Future<void> _processNextTasks() async {
    if (!_isProcessing || _activeTasks.length >= _maxConcurrentTasks) return;
    
    final availableSlots = _maxConcurrentTasks - _activeTasks.length;
    
    for (int i = 0; i < availableSlots && _taskQueue.isNotEmpty; i++) {
      final task = _taskQueue.removeFirst();
      _activeTasks[task.id] = task;
      
      // Process task in background (don't await to allow parallel processing)
      _processTask(task).catchError((error) {
        _handleTaskError(task, error);
      });
    }
  }

  Future<void> _processTask(ProcessingTask task) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      switch (task.type) {
        case ProcessingTaskType.ocr:
          await _processOCRTask(task, stopwatch);
          break;
        case ProcessingTaskType.imageOptimization:
          await _processImageOptimizationTask(task, stopwatch);
          break;
        case ProcessingTaskType.both:
          await _processBothTask(task, stopwatch);
          break;
      }
    } catch (e) {
      _handleTaskError(task, e);
    } finally {
      stopwatch.stop();
      _activeTasks.remove(task.id);
    }
  }

  Future<void> _processOCRTask(ProcessingTask task, Stopwatch stopwatch) async {
    if (task.imageData == null) {
      throw Exception('No image data provided for OCR task');
    }
    
    final ocrResult = await _ocrService.processReceipt(task.imageData!);
    stopwatch.stop();
    
    final result = ProcessingResult(
      taskId: task.id,
      receiptId: task.receiptId,
      type: task.type,
      success: true,
      ocrResult: ocrResult,
      processingDuration: stopwatch.elapsed,
    );
    
    _completeTask(result);
  }

  Future<void> _processImageOptimizationTask(ProcessingTask task, Stopwatch stopwatch) async {
    if (task.imageData == null) {
      throw Exception('No image data provided for optimization task');
    }
    
    final optimizationResult = await _imageOptimizationService.optimizeReceiptImage(
      task.imageData!,
      task.receiptId,
    );
    
    stopwatch.stop();
    
    final result = ProcessingResult(
      taskId: task.id,
      receiptId: task.receiptId,
      type: task.type,
      success: optimizationResult.success,
      imagePath: optimizationResult.imagePath,
      thumbnailPath: optimizationResult.thumbnailPath,
      error: optimizationResult.error,
      processingDuration: stopwatch.elapsed,
    );
    
    _completeTask(result);
  }

  Future<void> _processBothTask(ProcessingTask task, Stopwatch stopwatch) async {
    if (task.imageData == null) {
      throw Exception('No image data provided for combined task');
    }
    
    // Process image optimization first
    final optimizationResult = await _imageOptimizationService.optimizeReceiptImage(
      task.imageData!,
      task.receiptId,
    );
    
    // Then process OCR
    final ocrResult = await _ocrService.processReceipt(task.imageData!);
    
    stopwatch.stop();
    
    final result = ProcessingResult(
      taskId: task.id,
      receiptId: task.receiptId,
      type: task.type,
      success: optimizationResult.success,
      ocrResult: ocrResult,
      imagePath: optimizationResult.imagePath,
      thumbnailPath: optimizationResult.thumbnailPath,
      error: optimizationResult.error,
      processingDuration: stopwatch.elapsed,
    );
    
    _completeTask(result);
  }

  void _completeTask(ProcessingResult result) {
    _completedResults[result.taskId] = result;
    
    // Update statistics
    _totalTasksProcessed++;
    _totalProcessingTime += result.processingDuration;
    
    if (!result.success) {
      _totalTasksFailed++;
    }
    
    // Emit result and stats
    _resultController.add(result);
    _emitStats();
  }

  void _handleTaskError(ProcessingTask task, dynamic error) {
    final result = ProcessingResult(
      taskId: task.id,
      receiptId: task.receiptId,
      type: task.type,
      success: false,
      error: error.toString(),
      processingDuration: Duration.zero,
    );
    
    _completeTask(result);
  }

  void _emitStats() {
    _statsController.add(getStats());
  }
}

class ProcessingStats {
  final int queueLength;
  final int activeTasks;
  final int completedTasks;
  final int failedTasks;
  final Duration averageProcessingTime;
  final Duration totalProcessingTime;

  ProcessingStats({
    required this.queueLength,
    required this.activeTasks,
    required this.completedTasks,
    required this.failedTasks,
    required this.averageProcessingTime,
    required this.totalProcessingTime,
  });

  double get successRate => completedTasks > 0 
      ? ((completedTasks - failedTasks) / completedTasks) * 100 
      : 0.0;

  bool get isIdle => queueLength == 0 && activeTasks == 0;
}

// Priority queue implementation
class PriorityQueue<T extends ProcessingTask> {
  final List<T> _items = [];

  void add(T item) {
    _items.add(item);
    _items.sort((a, b) => b.priority.compareTo(a.priority)); // Higher priority first
  }

  T removeFirst() {
    if (_items.isEmpty) throw StateError('Queue is empty');
    return _items.removeAt(0);
  }

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;
  int get length => _items.length;
  
  List<T> toList() => List<T>.from(_items);
  
  void clear() => _items.clear();
}