import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/core/platform/image_capture.dart';
import 'package:receipt_organizer/core/platform/mobile/image_capture_mobile.dart';
import 'package:receipt_organizer/core/platform/web/image_capture_web.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/batch_capture_provider.dart';

// Provider for image capture service
final imageCaptureServiceProvider = StateNotifierProvider<ImageCaptureServiceNotifier, AsyncValue<ImageCaptureService?>>((ref) {
  return ImageCaptureServiceNotifier();
});

class ImageCaptureServiceNotifier extends StateNotifier<AsyncValue<ImageCaptureService?>> {
  ImageCaptureServiceNotifier() : super(const AsyncValue.loading());

  ImageCaptureService? _captureService;

  Future<void> initialize() async {
    try {
      state = const AsyncValue.loading();

      // Create platform-specific service
      _captureService = kIsWeb
          ? ImageCaptureServiceWeb()
          : ImageCaptureServiceMobile();

      await _captureService!.initialize();

      // Check camera availability
      final isAvailable = await _captureService!.isCameraAvailable();
      if (!isAvailable && !kIsWeb) {
        throw Exception('Camera not available');
      }

      state = AsyncValue.data(_captureService);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<CapturedImage?> captureImage() async {
    if (_captureService == null) {
      throw Exception('Capture service not initialized');
    }
    return await _captureService!.captureImage();
  }

  void dispose() {
    _captureService?.dispose();
    super.dispose();
  }
}

class CameraCaptureScreen extends ConsumerStatefulWidget {
  final bool isBatchMode;
  final Function(List<String>)? onBatchComplete;

  const CameraCaptureScreen({
    super.key,
    this.isBatchMode = false,
    this.onBatchComplete,
  });

  @override
  ConsumerState<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends ConsumerState<CameraCaptureScreen> {
  final List<String> capturedImages = [];
  bool isCapturing = false;
  final uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await ref.read(imageCaptureServiceProvider.notifier).initialize();
  }

  @override
  void dispose() {
    ref.read(imageCaptureServiceProvider.notifier).dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (isCapturing) return;

    setState(() {
      isCapturing = true;
    });

    try {
      // Use abstracted capture service
      final capturedImage = await ref.read(imageCaptureServiceProvider.notifier).captureImage();

      if (capturedImage != null) {
        // Save image to temporary location
        final tempDir = await getTemporaryDirectory();
        final fileName = '${uuid.v4()}.jpg';
        final filePath = path.join(tempDir.path, fileName);

        // Save bytes to file
        if (!kIsWeb) {
          final file = File(filePath);
          await file.writeAsBytes(capturedImage.bytes);
          capturedImages.add(filePath);
        } else {
          // For web, we'll use the base64 data
          capturedImages.add(capturedImage.toBase64());
        }

        // Haptic feedback
        HapticFeedback.lightImpact();

        if (widget.isBatchMode) {
          // Update batch provider
          ref.read(batchCaptureProvider.notifier).captureReceipt(
            kIsWeb ? capturedImage.toBase64() : filePath
          );

          // Show count
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Captured ${capturedImages.length} receipt(s)'),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        } else {
          // Single capture mode - return immediately
          if (mounted) {
            Navigator.of(context).pop(kIsWeb ? capturedImage.toBase64() : filePath);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing image: $e')),
        );
      }
    } finally {
      setState(() {
        isCapturing = false;
      });
    }
  }

  void _finishBatchCapture() {
    if (widget.onBatchComplete != null) {
      widget.onBatchComplete!(capturedImages);
    }
    Navigator.of(context).pop(capturedImages);
  }

  @override
  Widget build(BuildContext context) {
    final captureServiceAsync = ref.watch(imageCaptureServiceProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview or file picker UI
          captureServiceAsync.when(
            data: (service) {
              if (service == null) {
                return const Center(
                  child: Text(
                    'Camera not available',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              // Use the service's camera preview widget
              return service.getCameraPreview(
                onImageCaptured: (image) {
                  // Handle captured image
                  _handleCapturedImage(image);
                },
                onError: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error capturing image')),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Camera Error:\n$error',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initializeCamera,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),

          // Controls overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    if (widget.isBatchMode) ...[
                      Text(
                        'Captured: ${capturedImages.length} receipt(s)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Cancel button
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, size: 32),
                          color: Colors.white,
                        ),

                        // Capture button
                        GestureDetector(
                          onTap: isCapturing ? null : _captureImage,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: isCapturing ? Colors.grey : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                            ),
                            child: isCapturing
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    color: Colors.black,
                                    size: 32,
                                  ),
                          ),
                        ),

                        // Done button (batch mode) or placeholder
                        if (widget.isBatchMode)
                          IconButton(
                            onPressed: capturedImages.isNotEmpty ? _finishBatchCapture : null,
                            icon: const Icon(Icons.check, size: 32),
                            color: capturedImages.isNotEmpty ? Colors.green : Colors.grey,
                          )
                        else
                          const SizedBox(width: 48),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCapturedImage(CapturedImage image) async {
    // Save captured image
    if (!kIsWeb) {
      final tempDir = await getTemporaryDirectory();
      final fileName = '${uuid.v4()}.jpg';
      final filePath = path.join(tempDir.path, fileName);

      final file = File(filePath);
      await file.writeAsBytes(image.bytes);
      capturedImages.add(filePath);
    } else {
      capturedImages.add(image.toBase64());
    }

    // Update UI
    setState(() {});

    // Haptic feedback
    HapticFeedback.lightImpact();

    if (!widget.isBatchMode && mounted) {
      Navigator.of(context).pop(capturedImages.first);
    }
  }
}