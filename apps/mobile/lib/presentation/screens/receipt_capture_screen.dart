import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/camera_preview_with_overlay.dart';
import '../widgets/manual_adjustment_interface.dart';
import '../../domain/services/camera_service.dart';
import '../../data/models/edge_detection_result.dart';

/// Complete receipt capture screen with edge detection
class ReceiptCaptureScreen extends ConsumerStatefulWidget {
  const ReceiptCaptureScreen({super.key});

  @override
  ConsumerState<ReceiptCaptureScreen> createState() => _ReceiptCaptureScreenState();
}

class _ReceiptCaptureScreenState extends ConsumerState<ReceiptCaptureScreen> {
  late CameraService _cameraService;
  EdgeDetectionResult? _currentEdgeResult;
  bool _isManualAdjustmentMode = false;
  bool _isCapturing = false;
  
  @override
  void initState() {
    super.initState();
    _cameraService = CameraService();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize camera: $e')),
        );
      }
    }
  }

  void _onEdgeDetectionResult(EdgeDetectionResult result) {
    setState(() {
      _currentEdgeResult = result;
    });
  }

  void _toggleManualAdjustment() {
    setState(() {
      _isManualAdjustmentMode = !_isManualAdjustmentMode;
    });
  }

  void _onManualAdjustmentConfirm(EdgeDetectionResult result) {
    setState(() {
      _currentEdgeResult = result;
      _isManualAdjustmentMode = false;
    });
    
    // Auto-capture after manual confirmation
    _captureReceipt();
  }

  void _onManualAdjustmentCancel() {
    setState(() {
      _isManualAdjustmentMode = false;
    });
  }

  void _onManualAdjustmentReset() {
    // Reset to auto-detected result
    // The camera preview will update with the latest auto-detected result
  }

  Future<void> _captureReceipt() async {
    if (_currentEdgeResult?.success != true || _isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      // Simulate capture delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // In a real implementation, this would capture the image using the detected edges
      final captureResult = await _cameraService.captureReceipt();
      
      if (mounted && captureResult.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receipt captured successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to processing or editing screen
        // Navigator.push(context, MaterialPageRoute(builder: (_) => ProcessingScreen()));
      } else {
        throw Exception(captureResult.errorMessage ?? 'Capture failed');
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
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview with edge overlay
            if (!_isManualAdjustmentMode)
              Positioned.fill(
                child: CameraPreviewWithOverlay(
                  cameraService: _cameraService,
                  onEdgeDetectionResult: _onEdgeDetectionResult,
                  enableManualAdjustment: false, // We handle manual adjustment separately
                ),
              ),

            // Manual adjustment interface
            if (_isManualAdjustmentMode)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withAlpha((0.8 * 255).round()),
                  child: ManualAdjustmentInterface(
                    currentResult: _currentEdgeResult,
                    viewSize: MediaQuery.of(context).size,
                    onConfirm: _onManualAdjustmentConfirm,
                    onCancel: _onManualAdjustmentCancel,
                    onResetToAuto: _onManualAdjustmentReset,
                    showInstructions: true,
                  ),
                ),
              ),

            // Top controls
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _buildTopControls(),
            ),

            // Bottom controls
            Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: _buildBottomControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Row(
      children: [
        // Back button
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withAlpha((0.6 * 255).round()),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        const Spacer(),
        
        // Settings or help button
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withAlpha((0.6 * 255).round()),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              // Show help dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Receipt Capture Help'),
                  content: const Text(
                    'Position your phone over the receipt and wait for the green overlay. '
                    'Use the adjust button to manually fine-tune the detection area.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    if (_isManualAdjustmentMode) {
      // Manual adjustment mode controls are handled by ManualAdjustmentInterface
      return const SizedBox.shrink();
    }

    final hasValidDetection = _currentEdgeResult?.success == true && 
                            _currentEdgeResult!.confidence > 0.6;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edge detection status
        if (_currentEdgeResult != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.8 * 255).round()),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _buildStatusText(),
              style: TextStyle(
                color: _getStatusColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        // Main controls row
        Row(
          children: [
            // Manual adjustment button
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha((0.6 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.tune, color: Colors.white, size: 28),
                onPressed: hasValidDetection ? _toggleManualAdjustment : null,
              ),
            ),
            
            const Spacer(),

            // Capture button
            GestureDetector(
              onTap: hasValidDetection && !_isCapturing ? _captureReceipt : null,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isCapturing 
                      ? Colors.grey 
                      : hasValidDetection 
                          ? Colors.white 
                          : Colors.grey,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                ),
                child: _isCapturing
                    ? const CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 3,
                      )
                    : Icon(
                        Icons.camera_alt,
                        color: hasValidDetection ? Colors.black : Colors.grey.shade600,
                        size: 32,
                      ),
              ),
            ),

            const Spacer(),

            // Flash or other controls
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha((0.6 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.flash_auto, color: Colors.white, size: 28),
                onPressed: () {
                  // Toggle flash if needed
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _buildStatusText() {
    if (_currentEdgeResult == null) return 'Initializing...';
    
    final result = _currentEdgeResult!;
    if (!result.success) {
      return 'Position camera over receipt';
    } else if (result.confidence >= 0.8) {
      return 'Receipt detected - Ready to capture';
    } else if (result.confidence >= 0.6) {
      return 'Receipt partially detected';
    } else {
      return 'Improve positioning for better detection';
    }
  }

  Color _getStatusColor() {
    if (_currentEdgeResult == null) return Colors.white;
    
    final result = _currentEdgeResult!;
    if (!result.success) {
      return Colors.orange;
    } else if (result.confidence >= 0.8) {
      return Colors.green;
    } else if (result.confidence >= 0.6) {
      return Colors.yellow;
    } else {
      return Colors.orange;
    }
  }
}