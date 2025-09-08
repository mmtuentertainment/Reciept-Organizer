import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/capture/providers/batch_capture_provider.dart';
import 'package:receipt_organizer/features/capture/widgets/capture_counter_widget.dart';
import 'package:receipt_organizer/features/capture/widgets/camera_preview_widget.dart';
import 'package:receipt_organizer/features/capture/screens/batch_review_screen.dart';

class BatchCaptureScreen extends ConsumerStatefulWidget {
  const BatchCaptureScreen({super.key});

  @override
  ConsumerState<BatchCaptureScreen> createState() => _BatchCaptureScreenState();
}

class _BatchCaptureScreenState extends ConsumerState<BatchCaptureScreen>
    with TickerProviderStateMixin {
  late AnimationController _flashController;
  late AnimationController _thumbnailController;
  late AnimationController _autoAdvanceController;
  bool _autoAdvanceEnabled = true;
  int _autoAdvanceCountdown = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _thumbnailController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _autoAdvanceController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(batchCaptureProvider.notifier).startBatchMode();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _flashController.dispose();
    _thumbnailController.dispose();
    _autoAdvanceController.dispose();
    super.dispose();
  }

  Future<void> _captureReceipt() async {
    final notifier = ref.read(batchCaptureProvider.notifier);
    final success = await notifier.captureReceipt();

    if (success && mounted) {
      HapticFeedback.lightImpact();
      
      _flashController.forward().then((_) {
        _flashController.reverse();
      });
      
      _thumbnailController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            _thumbnailController.reverse();
          }
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Receipt captured! (${ref.read(batchCaptureProvider).batchSize} total)'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );

      // Auto-advance to next capture after a short delay
      if (_autoAdvanceEnabled && mounted) {
        _startAutoAdvanceCountdown();
      }
    }
  }

  void _startAutoAdvanceCountdown() {
    // Cancel any existing timer
    _countdownTimer?.cancel();
    
    setState(() {
      _autoAdvanceCountdown = 3;
    });
    
    _autoAdvanceController.reset();
    _autoAdvanceController.forward();
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_autoAdvanceEnabled) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _autoAdvanceCountdown--;
      });
      
      if (_autoAdvanceCountdown <= 0) {
        timer.cancel();
        if (mounted && _autoAdvanceEnabled) {
          _captureReceipt();
        }
        setState(() {
          _autoAdvanceCountdown = 0;
        });
      }
    });
  }

  void _cancelAutoAdvance() {
    _countdownTimer?.cancel();
    setState(() {
      _autoAdvanceEnabled = false;
      _autoAdvanceCountdown = 0;
    });
    _autoAdvanceController.reset();
  }

  void _finishBatch() {
    final state = ref.read(batchCaptureProvider);
    if (state.receipts.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const BatchReviewScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final batchState = ref.watch(batchCaptureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Capture'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (batchState.receipts.isNotEmpty)
            TextButton(
              onPressed: _finishBatch,
              child: const Text(
                'Review',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const CameraPreviewWidget(),
          
          AnimatedBuilder(
            animation: _flashController,
            builder: (context, child) {
              return Container(
                color: Colors.white.withAlpha((_flashController.value * 0.8 * 255).round()),
              );
            },
          ),
          
          Positioned(
            top: 20,
            left: 20,
            child: CaptureCounterWidget(count: batchState.batchSize),
          ),
          
          // Auto-advance countdown
          if (_autoAdvanceCountdown > 0)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _autoAdvanceController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha((0.9 * 255).round()),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Next capture in $_autoAdvanceCountdown',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 100,
                            height: 4,
                            child: LinearProgressIndicator(
                              value: _autoAdvanceController.value,
                              backgroundColor: Colors.white.withAlpha((0.3 * 255).round()),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _cancelAutoAdvance,
                            child: const Text(
                              'Tap to cancel',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          
          if (batchState.receipts.isNotEmpty)
            Positioned(
              top: 20,
              right: 20,
              child: AnimatedBuilder(
                animation: _thumbnailController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 - (_thumbnailController.value * 0.3),
                    child: Container(
                      width: 60,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.receipt,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
                  );
                },
              ),
            ),
          
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (batchState.receipts.isNotEmpty) ...[
                  ElevatedButton(
                    onPressed: _finishBatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Text('Finish Batch (${batchState.batchSize})'),
                  ),
                  const SizedBox(height: 16),
                ],
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Auto-advance toggle
                    if (batchState.receipts.isNotEmpty)
                      Column(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _autoAdvanceEnabled = !_autoAdvanceEnabled;
                              });
                              if (!_autoAdvanceEnabled) {
                                _cancelAutoAdvance();
                              }
                            },
                            icon: Icon(
                              _autoAdvanceEnabled ? Icons.autorenew : Icons.pause,
                              color: _autoAdvanceEnabled ? Colors.orange : Colors.grey,
                            ),
                          ),
                          Text(
                            _autoAdvanceEnabled ? 'Auto' : 'Manual',
                            style: TextStyle(
                              color: _autoAdvanceEnabled ? Colors.orange : Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    
                    // Main capture button
                    ElevatedButton(
                      onPressed: (batchState.isCapturing || _autoAdvanceCountdown > 0) 
                          ? null 
                          : _captureReceipt,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                      ),
                      child: batchState.isCapturing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : _autoAdvanceCountdown > 0
                              ? Text(
                                  _autoAdvanceCountdown.toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : const Icon(Icons.camera_alt, size: 30),
                    ),
                    
                    // Spacer to balance layout
                    if (batchState.receipts.isNotEmpty)
                      const SizedBox(width: 48),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}