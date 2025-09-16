import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/batch_capture_provider.dart';

// Provider for camera controller
final cameraControllerProvider = StateNotifierProvider<CameraControllerNotifier, AsyncValue<CameraController?>>((ref) {
  return CameraControllerNotifier();
});

class CameraControllerNotifier extends StateNotifier<AsyncValue<CameraController?>> {
  CameraControllerNotifier() : super(const AsyncValue.loading());

  CameraController? _controller;

  Future<void> initialize() async {
    try {
      state = const AsyncValue.loading();

      // Check camera permission
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        throw Exception('Camera permission denied');
      }

      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      // Initialize with back camera
      final camera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      state = AsyncValue.data(_controller);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<String?> captureImage() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        final image = await _controller!.takePicture();
        return image.path;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class CameraCaptureScreen extends ConsumerStatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  ConsumerState<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends ConsumerState<CameraCaptureScreen> {
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    // Initialize camera on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cameraControllerProvider.notifier).initialize();
    });
  }

  Future<void> _captureReceipt() async {
    if (_isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      // Haptic feedback
      HapticFeedback.mediumImpact();

      // Capture image
      final imagePath = await ref.read(cameraControllerProvider.notifier).captureImage();

      if (imagePath != null && mounted) {
        // Save to proper location with naming convention
        final directory = await getApplicationDocumentsDirectory();
        final uuid = const Uuid().v4();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'receipt_${uuid}_$timestamp.jpg';
        final newPath = path.join(directory.path, 'receipts', fileName);

        // Create receipts directory if it doesn't exist
        final receiptsDir = Directory(path.join(directory.path, 'receipts'));
        if (!await receiptsDir.exists()) {
          await receiptsDir.create(recursive: true);
        }

        // Move file to proper location
        final file = File(imagePath);
        await file.copy(newPath);
        await file.delete();

        // Add to batch if in batch mode
        final batchNotifier = ref.read(batchCaptureProvider.notifier);
        batchNotifier.addImage(newPath);

        // Show batch option dialog
        if (mounted) {
          final continueCapturing = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Receipt ${batchNotifier.captureCount} Captured'),
              content: const Text('Continue capturing more receipts?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Review Batch'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Continue Capturing'),
                ),
              ],
            ),
          );

          if (continueCapturing == false && mounted) {
            // Navigate to batch review
            Navigator.pushNamed(
              context,
              '/batch-review',
              arguments: {'images': ref.read(batchCaptureProvider).capturedImages},
            );
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraAsync = ref.watch(cameraControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          cameraAsync.when(
            data: (controller) {
              if (controller == null || !controller.value.isInitialized) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              return Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: CameraPreview(controller),
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Camera Error: ${error.toString()}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(cameraControllerProvider.notifier).initialize();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),

          // Top bar with back button and batch count
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final batchState = ref.watch(batchCaptureProvider);
                      if (batchState.capturedImages.isEmpty) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${batchState.capturedImages.length} captured',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom capture button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _isCapturing ? null : _captureReceipt,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: _isCapturing
                        ? Colors.grey.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.3),
                  ),
                  child: _isCapturing
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 32,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}