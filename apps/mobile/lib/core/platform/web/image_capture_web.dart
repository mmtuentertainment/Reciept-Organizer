import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../interfaces/image_capture.dart';

/// Web implementation using file picker
class ImageCaptureServiceWeb implements ImageCaptureService {
  bool _isInitialized = false;

  @override
  String get platform => 'web';

  @override
  Future<bool> isCameraAvailable() async {
    // Web camera API is limited, we'll use file picker primarily
    return false;
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  @override
  Future<CapturedImage?> captureImage() async {
    // On web, we use file picker instead of camera
    return pickImage();
  }

  @override
  Future<List<CapturedImage>> captureBatch({int? maxImages}) async {
    return pickMultipleImages(maxImages: maxImages);
  }

  @override
  Future<CapturedImage?> pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      if (file.bytes == null) return null;

      return CapturedImage(
        bytes: file.bytes!,
        metadata: {
          'source': 'file_picker',
          'name': file.name,
          'size': file.size,
        },
      );
    } catch (e) {
      debugPrint('Error picking image on web: $e');
      return null;
    }
  }

  @override
  Future<List<CapturedImage>> pickMultipleImages({int? maxImages}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (result == null) return [];

      final images = <CapturedImage>[];
      final limit = maxImages ?? result.files.length;

      for (int i = 0; i < limit && i < result.files.length; i++) {
        final file = result.files[i];
        if (file.bytes != null) {
          images.add(CapturedImage(
            bytes: file.bytes!,
            metadata: {
              'source': 'file_picker',
              'name': file.name,
              'size': file.size,
            },
          ));
        }
      }

      return images;
    } catch (e) {
      debugPrint('Error picking multiple images on web: $e');
      return [];
    }
  }

  @override
  Widget getCameraPreview({
    required Function(CapturedImage) onImageCaptured,
    VoidCallback? onError,
  }) {
    // Web file picker UI
    return _WebImagePickerWidget(
      onImagePicked: onImageCaptured,
    );
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
  }
}

/// Web image picker widget
class _WebImagePickerWidget extends StatefulWidget {
  final Function(CapturedImage) onImagePicked;

  const _WebImagePickerWidget({
    required this.onImagePicked,
  });

  @override
  State<_WebImagePickerWidget> createState() => _WebImagePickerWidgetState();
}

class _WebImagePickerWidgetState extends State<_WebImagePickerWidget> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _pickImage,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isDragging ? Colors.blue.withOpacity(0.1) : Colors.grey[100],
            border: Border.all(
              color: _isDragging ? Colors.blue : Colors.grey[400]!,
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 64,
                  color: _isDragging ? Colors.blue : Colors.grey[600],
                ),
                const SizedBox(height: 16),
                Text(
                  'Upload Receipt Image',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Click to browse or drag and drop',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Choose File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _pickMultiple,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Select Multiple'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final service = ImageCaptureServiceWeb();
    final image = await service.pickImage();
    if (image != null) {
      widget.onImagePicked(image);
    }
  }

  Future<void> _pickMultiple() async {
    final service = ImageCaptureServiceWeb();
    final images = await service.pickMultipleImages();
    for (final image in images) {
      widget.onImagePicked(image);
    }
  }
}