import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../interfaces/image_capture.dart';

/// Mobile implementation using image_picker package
class ImageCaptureServiceMobile implements ImageCaptureService {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isInitialized = false;

  @override
  String get platform => 'mobile';

  @override
  Future<bool> isCameraAvailable() async {
    try {
      final status = await Permission.camera.status;
      if (!status.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) return false;
      }
      return true;
    } catch (e) {
      debugPrint('Error checking camera availability: $e');
      return false;
    }
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request permissions
    await isCameraAvailable();
    _isInitialized = true;
  }

  @override
  Future<CapturedImage?> captureImage() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (photo == null) return null;

      final bytes = await photo.readAsBytes();
      return CapturedImage(
        bytes: bytes,
        path: photo.path,
        metadata: {
          'source': 'camera',
          'originalPath': photo.path,
          'name': photo.name,
        },
      );
    } catch (e) {
      debugPrint('Error capturing image: $e');
      // Fall back to gallery if camera fails
      return pickImage();
    }
  }

  @override
  Future<List<CapturedImage>> captureBatch({int? maxImages}) async {
    // For batch capture, we'll use multiple picks from gallery
    return pickMultipleImages(maxImages: maxImages);
  }

  @override
  Future<CapturedImage?> pickImage() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (photo == null) return null;

      final bytes = await photo.readAsBytes();
      return CapturedImage(
        bytes: bytes,
        path: photo.path,
        metadata: {
          'source': 'gallery',
          'originalPath': photo.path,
          'name': photo.name,
        },
      );
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  @override
  Future<List<CapturedImage>> pickMultipleImages({int? maxImages}) async {
    try {
      final List<XFile> photos = await _imagePicker.pickMultiImage(
        imageQuality: 90,
        limit: maxImages,
      );

      final images = <CapturedImage>[];
      for (final photo in photos) {
        final bytes = await photo.readAsBytes();
        images.add(CapturedImage(
          bytes: bytes,
          path: photo.path,
          metadata: {
            'source': 'gallery',
            'originalPath': photo.path,
            'name': photo.name,
          },
        ));
      }

      return images;
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }

  @override
  Widget getCameraPreview({
    required Function(CapturedImage) onImageCaptured,
    VoidCallback? onError,
  }) {
    // Since we're using image_picker instead of camera package,
    // we provide a simple UI for capture
    return _SimpleCaptureWidget(
      onCapture: () async {
        final image = await captureImage();
        if (image != null) {
          onImageCaptured(image);
        } else {
          onError?.call();
        }
      },
      onPick: () async {
        final image = await pickImage();
        if (image != null) {
          onImageCaptured(image);
        }
      },
    );
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
  }
}

/// Simple capture widget for mobile
class _SimpleCaptureWidget extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onPick;

  const _SimpleCaptureWidget({
    required this.onCapture,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Capture Receipt',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: onCapture,
                  icon: const Icon(Icons.camera),
                  label: const Text('Take Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: onPick,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}