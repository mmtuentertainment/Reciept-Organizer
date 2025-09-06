import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/capture/widgets/camera_preview_widget.dart';
import 'package:receipt_organizer/features/capture/screens/batch_capture_screen.dart';
import 'package:receipt_organizer/features/capture/providers/capture_provider.dart';
import 'package:receipt_organizer/features/capture/widgets/retry_prompt_dialog.dart';
import 'package:receipt_organizer/features/capture/screens/preview_screen.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen>
    with TickerProviderStateMixin {
  late AnimationController _flashController;
  late AnimationController _longPressController;
  bool _isCapturing = false;
  bool _isLongPressing = false;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _longPressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _flashController.dispose();
    _longPressController.dispose();
    super.dispose();
  }

  Future<void> _captureReceipt() async {
    if (_isCapturing) return;
    
    setState(() {
      _isCapturing = true;
    });

    try {
      // In a real implementation, this would capture from camera
      // For now, simulate image capture with a placeholder
      final mockImageData = await _getMockImageData();
      
      if (mounted) {
        HapticFeedback.lightImpact();
        
        _flashController.forward().then((_) {
          _flashController.reverse();
        });

        // Navigate to preview screen for processing
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PreviewScreen(
              imageData: mockImageData,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Capture failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  /// Mock image data for testing - in real implementation would capture from camera
  Future<Uint8List> _getMockImageData() async {
    // Create a simple 1x1 pixel image for testing
    // In real implementation, this would come from camera
    return Uint8List.fromList([
      0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
      0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
      // ... (minimal JPEG header for testing)
    ]);
  }

  void _onLongPressStart() {
    setState(() {
      _isLongPressing = true;
    });
    
    HapticFeedback.mediumImpact();
    _longPressController.forward();
  }

  void _onLongPressEnd() {
    setState(() {
      _isLongPressing = false;
    });
    
    _longPressController.reverse();
  }

  void _activateBatchMode() {
    HapticFeedback.heavyImpact();
    
    // Show confirmation and navigate to batch mode
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batch Mode Activated'),
        content: const Text('You can now capture multiple receipts quickly. Ready to start batch capture?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const BatchCaptureScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Batch'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Receipt'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BatchCaptureScreen(),
                ),
              );
            },
            icon: const Icon(Icons.collections),
            tooltip: 'Batch Mode',
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          const CameraPreviewWidget(),
          
          // Flash overlay
          AnimatedBuilder(
            animation: _flashController,
            builder: (context, child) {
              return Container(
                color: Colors.white.withOpacity(_flashController.value * 0.8),
              );
            },
          ),
          
          // Instructions overlay
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Tap to capture • Long press for batch mode',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Capture button
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _isCapturing ? null : _captureReceipt,
                  onLongPressStart: (_) => _onLongPressStart(),
                  onLongPressEnd: (_) => _onLongPressEnd(),
                  onLongPress: _activateBatchMode,
                  child: AnimatedBuilder(
                    animation: _longPressController,
                    builder: (context, child) {
                      return Container(
                        width: 80 + (_longPressController.value * 10),
                        height: 80 + (_longPressController.value * 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isLongPressing 
                            ? Colors.orange
                            : Colors.white,
                          border: Border.all(
                            color: _isLongPressing 
                              ? Colors.deepOrange
                              : Colors.grey[300]!,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isLongPressing ? Colors.orange : Colors.black)
                                  .withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isCapturing
                              ? const SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  ),
                                )
                              : Icon(
                                  _isLongPressing 
                                    ? Icons.collections 
                                    : Icons.camera_alt,
                                  size: 35,
                                  color: _isLongPressing 
                                    ? Colors.white 
                                    : Colors.black,
                                ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedBuilder(
                  animation: _longPressController,
                  builder: (context, child) {
                    return AnimatedOpacity(
                      opacity: _longPressController.value,
                      duration: const Duration(milliseconds: 100),
                      child: const Text(
                        'Batch Mode',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}