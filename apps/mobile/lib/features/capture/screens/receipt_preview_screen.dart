import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import '../../domain/services/ocr_service.dart';

class ReceiptPreviewScreen extends ConsumerStatefulWidget {
  final String imagePath;

  const ReceiptPreviewScreen({
    super.key,
    required this.imagePath,
  });

  @override
  ConsumerState<ReceiptPreviewScreen> createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends ConsumerState<ReceiptPreviewScreen> {
  bool _isProcessing = false;
  String? _errorMessage;
  ProcessingResult? _ocrResult;
  final OCRService _ocrService = OCRService();

  @override
  void initState() {
    super.initState();
    _runOCR();
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _runOCR() async {
    setState(() => _isProcessing = true);

    try {
      final result = await _ocrService.processImage(widget.imagePath);
      setState(() {
        _ocrResult = result;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'OCR failed';
        _isProcessing = false;
      });
    }
  }

  Future<void> _compressAndSave() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final file = File(widget.imagePath);
      final bytes = await file.readAsBytes();

      // Simple compression to <500KB
      final image = img.decodeImage(bytes);
      if (image != null) {
        // Calculate quality based on file size
        int quality = 85;
        List<int> compressed = img.encodeJpg(image, quality: quality);

        // Reduce quality if still too large
        while (compressed.length > 500000 && quality > 30) {
          quality -= 10;
          compressed = img.encodeJpg(image, quality: quality);
        }

        // Save compressed version
        await file.writeAsBytes(compressed);

        // Generate thumbnail (150x150)
        final thumbnail = img.copyResize(image, width: 150, height: 150);
        final thumbnailBytes = img.encodeJpg(thumbnail, quality: 70);

        // Save thumbnail
        final dir = path.dirname(widget.imagePath);
        final baseName = path.basenameWithoutExtension(widget.imagePath);
        final thumbnailPath = path.join(dir, 'thumbnails', '${baseName}_thumb.jpg');

        final thumbnailDir = Directory(path.join(dir, 'thumbnails'));
        if (!await thumbnailDir.exists()) {
          await thumbnailDir.create(recursive: true);
        }

        await File(thumbnailPath).writeAsBytes(thumbnailBytes);
      }

      if (mounted) {
        // Navigate to next screen or back to home
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
          arguments: {'savedReceipt': widget.imagePath},
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to process image: ${e.toString()}';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Review Receipt', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Image preview
          Expanded(
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 48),
                          SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // OCR Results display
          if (_ocrResult != null && !_isProcessing)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black87,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_ocrResult!.merchant != null)
                    _buildResultRow('Merchant', _ocrResult!.merchant!,
                        _ocrResult!.confidence['merchant'] ?? 0),
                  if (_ocrResult!.date != null)
                    _buildResultRow('Date', '${_ocrResult!.date!.month}/${_ocrResult!.date!.day}/${_ocrResult!.date!.year}',
                        _ocrResult!.confidence['date'] ?? 0),
                  if (_ocrResult!.total != null)
                    _buildResultRow('Total', '\$${_ocrResult!.total!.toStringAsFixed(2)}',
                        _ocrResult!.confidence['total'] ?? 0),
                  if (_ocrResult!.tax != null)
                    _buildResultRow('Tax', '\$${_ocrResult!.tax!.toStringAsFixed(2)}',
                        _ocrResult!.confidence['tax'] ?? 0),
                ],
              ),
            ),

          // Error message if any
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),

          // Action buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Retake button
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Retake',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),

                  // Use Photo button
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _compressAndSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Use Photo',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, double confidence) {
    final confidenceColor = confidence > 0.8
        ? Colors.green
        : confidence > 0.6
            ? Colors.orange
            : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label: $value',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: confidenceColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: confidenceColor),
            ),
            child: Text(
              '${(confidence * 100).toInt()}%',
              style: TextStyle(color: confidenceColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}