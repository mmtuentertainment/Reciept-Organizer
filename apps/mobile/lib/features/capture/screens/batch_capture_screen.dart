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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(batchCaptureProvider.notifier).startBatchMode();
    });
  }

  @override
  void dispose() {
    _flashController.dispose();
    _thumbnailController.dispose();
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
    }
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
                color: Colors.white.withOpacity(_flashController.value * 0.8),
              );
            },
          ),
          
          Positioned(
            top: 20,
            left: 20,
            child: CaptureCounterWidget(count: batchState.batchSize),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: batchState.isCapturing ? null : _captureReceipt,
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
                          : const Icon(Icons.camera_alt, size: 30),
                    ),
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