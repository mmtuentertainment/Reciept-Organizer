import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/capture/providers/capture_provider.dart';
import 'package:receipt_organizer/features/capture/widgets/capture_failed_state.dart';
import 'package:receipt_organizer/features/capture/widgets/retry_prompt_dialog.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';

/// Preview screen that shows capture results and handles retry scenarios
class PreviewScreen extends ConsumerStatefulWidget {
  final Uint8List imageData;
  final String? sessionId;

  const PreviewScreen({
    super.key,
    required this.imageData,
    this.sessionId,
  });

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _processCapture();
  }

  Future<void> _processCapture() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    final captureNotifier = ref.read(captureProvider.notifier);
    
    // Start or restore session
    if (widget.sessionId != null) {
      final restored = await captureNotifier.restoreSession(widget.sessionId!);
      if (!restored) {
        captureNotifier.startCaptureSession(sessionId: widget.sessionId);
      }
    } else {
      captureNotifier.startCaptureSession();
    }

    // Process the capture
    final success = await captureNotifier.processCapture(widget.imageData);

    setState(() {
      _isProcessing = false;
    });

    if (success) {
      _handleSuccessfulCapture();
    } else {
      _handleFailedCapture();
    }
  }

  void _handleSuccessfulCapture() {
    // Show success feedback and navigate to next step
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receipt processed successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // In a real app, navigate to receipt editing or save screen
    Navigator.of(context).pop();
  }

  void _handleFailedCapture() {
    final captureState = ref.read(captureProvider);
    
    if (captureState.lastFailureReason != null) {
      _showRetryOptions();
    }
  }

  Future<void> _showRetryOptions() async {
    final captureState = ref.read(captureProvider);
    
    if (captureState.lastFailureReason == null) return;

    final action = await RetryPromptDialog.show(
      context: context,
      failureReason: captureState.lastFailureReason!,
      attemptNumber: captureState.retryCount,
      attemptsRemaining: captureState.attemptsRemaining,
    );

    if (action != null && mounted) {
      await _handleRetryAction(action);
    }
  }

  Future<void> _handleRetryAction(RetryAction action) async {
    final captureNotifier = ref.read(captureProvider.notifier);

    switch (action) {
      case RetryAction.retry:
        // Retry processing the same image
        setState(() {
          _isProcessing = true;
        });

        final success = await captureNotifier.retryCapture();

        setState(() {
          _isProcessing = false;
        });

        if (success) {
          _handleSuccessfulCapture();
        } else {
          _handleFailedCapture();
        }
        break;

      case RetryAction.retakePhoto:
        // Navigate back to capture screen
        captureNotifier.retakePhoto();
        Navigator.of(context).pop();
        break;

      case RetryAction.cancel:
        // Cancel and cleanup
        await captureNotifier.clearSession();
        Navigator.of(context).pop();
        break;
    }
  }

  Future<void> _onRetry() async {
    setState(() {
      _isProcessing = true;
    });

    final captureNotifier = ref.read(captureProvider.notifier);
    final success = await captureNotifier.retryCapture();

    setState(() {
      _isProcessing = false;
    });

    if (success) {
      _handleSuccessfulCapture();
    } else {
      _handleFailedCapture();
    }
  }

  Future<void> _onRetakePhoto() async {
    final captureNotifier = ref.read(captureProvider.notifier);
    captureNotifier.retakePhoto();
    Navigator.of(context).pop();
  }

  Future<void> _onCancel() async {
    final captureNotifier = ref.read(captureProvider.notifier);
    await captureNotifier.clearSession();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final captureState = ref.watch(captureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Result'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _onCancel,
        ),
        actions: [
          if (captureState.isRetryMode && captureState.canRetry)
            TextButton(
              onPressed: _isProcessing ? null : _onRetry,
              child: const Text('Retry'),
            ),
        ],
      ),
      body: _buildBody(captureState),
    );
  }

  Widget _buildBody(CaptureState captureState) {
    // Show processing state
    if (_isProcessing || captureState.isProcessing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing receipt...'),
          ],
        ),
      );
    }

    // Show success state
    if (!captureState.isRetryMode && 
        captureState.lastProcessingResult != null) {
      return _buildSuccessState(captureState.lastProcessingResult!);
    }

    // Show failure state with retry options
    if (captureState.isRetryMode && 
        captureState.lastFailureReason != null) {
      return CaptureFailedState(
        failureReason: captureState.lastFailureReason!,
        attemptNumber: captureState.retryCount,
        attemptsRemaining: captureState.attemptsRemaining,
        qualityScore: captureState.lastFailureDetection?.qualityScore ?? 0.0,
        onRetry: _onRetry,
        onRetakePhoto: _onRetakePhoto,
        onCancel: _onCancel,
      );
    }

    // Fallback: show image preview
    return _buildImagePreview();
  }

  Widget _buildSuccessState(ProcessingResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                widget.imageData,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Success header
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24),
              SizedBox(width: 8),
              Text(
                'Receipt Processed Successfully',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Extracted fields
          _buildFieldCard('Merchant', result.merchant),
          _buildFieldCard('Date', result.date),
          _buildFieldCard('Total', result.total),
          _buildFieldCard('Tax', result.tax),
          
          const SizedBox(height: 24),
          
          // Overall confidence
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.insights),
                  const SizedBox(width: 12),
                  Text(
                    'Overall Confidence: ${result.overallConfidence.toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to edit screen or save receipt
                Navigator.of(context).pop();
              },
              child: const Text('Accept & Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCard(String label, FieldData? field) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field?.value?.toString() ?? 'Not detected',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (field != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getConfidenceColor(field.confidence),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${field.confidence.toStringAsFixed(0)}% confidence',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 85) return Colors.green;
    if (confidence >= 75) return Colors.orange;
    return Colors.red;
  }

  Widget _buildImagePreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 300,
            height: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                widget.imageData,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Processing...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}