import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'edge_overlay_widget.dart';
import '../../domain/services/camera_service.dart';
import '../../data/models/edge_detection_result.dart';
import '../../data/models/camera_frame.dart';

/// Camera preview widget with real-time edge detection overlay
class CameraPreviewWithOverlay extends ConsumerStatefulWidget {
  const CameraPreviewWithOverlay({
    super.key,
    required this.cameraService,
    this.onEdgeDetectionResult,
    this.enableManualAdjustment = true,
    this.testMode = false,
  });

  final CameraService cameraService;
  final Function(EdgeDetectionResult)? onEdgeDetectionResult;
  final bool enableManualAdjustment;
  final bool testMode; // Skip camera controller in test mode

  @override
  ConsumerState<CameraPreviewWithOverlay> createState() =>
      _CameraPreviewWithOverlayState();
}

class _CameraPreviewWithOverlayState
    extends ConsumerState<CameraPreviewWithOverlay> {
  EdgeDetectionResult? _currentResult;
  bool _isProcessing = false;
  int _frameCount = 0;
  DateTime? _lastProcessTime;

  @override
  void initState() {
    super.initState();
    _startEdgeDetection();
  }

  void _startEdgeDetection() {
    // Listen to camera preview stream
    widget.cameraService.getPreviewStream().listen(_onCameraFrame);
  }

  void _onCameraFrame(CameraFrame frame) async {
    // Process every 3rd frame to maintain 10fps from 30fps camera stream
    _frameCount++;
    if (_frameCount % 3 != 0 || _isProcessing) return;

    // Throttle processing to maintain performance
    final now = DateTime.now();
    if (_lastProcessTime != null &&
        now.difference(_lastProcessTime!) < const Duration(milliseconds: 100)) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      _lastProcessTime = now;
      final result = await widget.cameraService.detectEdges(frame);
      
      if (mounted) {
        setState(() {
          _currentResult = result;
          _isProcessing = false;
        });

        // Notify parent of edge detection result
        widget.onEdgeDetectionResult?.call(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _onCornerDrag(int cornerIndex, Offset newPosition) {
    if (_currentResult == null || !widget.enableManualAdjustment) return;

    final updatedCorners = List<Point>.from(_currentResult!.corners);
    if (cornerIndex < updatedCorners.length) {
      updatedCorners[cornerIndex] = Point(
        newPosition.dx.clamp(0.0, 1.0),
        newPosition.dy.clamp(0.0, 1.0),
      );

      final updatedResult = EdgeDetectionResult(
        success: true,
        corners: updatedCorners,
        confidence: _currentResult!.confidence,
        processingTimeMs: _currentResult!.processingTimeMs,
      );

      setState(() {
        _currentResult = updatedResult;
      });

      widget.onEdgeDetectionResult?.call(updatedResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    // In test mode, skip camera controller and show UI directly
    if (widget.testMode) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return _buildCameraView(size, null);
        },
      );
    }
    
    return FutureBuilder<CameraController?>(
      future: widget.cameraService.getCameraController(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final controller = snapshot.data!;
        if (!controller.value.isInitialized) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            return _buildCameraView(size, controller);
          },
        );
      },
    );
  }
  
  Widget _buildCameraView(Size size, CameraController? controller) {
    return Stack(
      children: [
        // Camera preview or placeholder in test mode
        if (controller != null)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.previewSize?.height ?? size.width,
                height: controller.value.previewSize?.width ?? size.height,
                child: CameraPreview(controller),
              ),
            ),
          )
        else
          Container(
            color: Colors.black,
            child: const Center(
              child: Icon(
                Icons.camera_alt,
                size: 64,
                color: Colors.white24,
              ),
            ),
          ),
                
                // Edge detection overlay
                if (_currentResult != null)
                  Positioned.fill(
                    child: EdgeOverlayWidget(
                      result: _currentResult!,
                      viewSize: size,
                      onCornerDrag: widget.enableManualAdjustment
                          ? _onCornerDrag
                          : null,
                      showCornerHandles: widget.enableManualAdjustment,
                    ),
                  ),

                // Processing indicator
                if (_isProcessing)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha((0.6 * 255).round()),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Detecting...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Edge detection status
                if (_currentResult != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: _buildStatusIndicator(),
                  ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    if (_currentResult == null) return const SizedBox.shrink();

    final confidence = _currentResult!.confidence;
    final isSuccessful = _currentResult!.success;
    final processingTime = _currentResult!.processingTimeMs;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (!isSuccessful) {
      statusColor = Colors.red;
      statusText = 'No receipt detected';
      statusIcon = Icons.warning;
    } else if (confidence >= 0.8) {
      statusColor = Colors.green;
      statusText = 'Receipt detected';
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.orange;
      statusText = 'Partial detection';
      statusIcon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((0.8 * 255).round()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Confidence: ${(confidence * 100).round()}% • ${processingTime}ms',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (widget.enableManualAdjustment && isSuccessful)
            const Icon(
              Icons.touch_app,
              color: Colors.white70,
              size: 16,
            ),
        ],
      ),
    );
  }
}