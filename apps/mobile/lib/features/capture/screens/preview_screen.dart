import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/capture/providers/capture_provider.dart';
import 'package:receipt_organizer/features/capture/widgets/capture_failed_state.dart';
import 'package:receipt_organizer/features/capture/widgets/retry_prompt_dialog.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:receipt_organizer/features/receipts/presentation/widgets/field_editor.dart';
import 'package:receipt_organizer/features/receipts/presentation/widgets/merchant_field_editor_with_normalization.dart';
import 'package:receipt_organizer/features/capture/widgets/notes_field_editor.dart';

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
  bool _hasUnsavedChanges = false;
  String _notes = '';

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

  void _handleMerchantChanged(FieldData updatedField) {
    _updateOCRField('merchant', updatedField);
  }

  void _handleDateChanged(FieldData updatedField) {
    _updateOCRField('date', updatedField);
  }

  void _handleTotalChanged(FieldData updatedField) {
    _updateOCRField('total', updatedField);
  }

  void _handleTaxChanged(FieldData updatedField) {
    _updateOCRField('tax', updatedField);
  }

  void _handleNotesChanged(String notes) {
    setState(() {
      _notes = notes;
      _hasUnsavedChanges = true;
    });
    
    // Notes are saved automatically through the receipt update
    // Since notes is not an OCR field, we need to handle it separately
    // For now, we'll store it in the component state and save it when the user accepts
    _scheduleAutoSaveConfirmation();
  }

  void _updateOCRField(String fieldName, FieldData updatedField) async {
    // Use CaptureProvider to handle field updates with proper auto-save
    final captureNotifier = ref.read(captureProvider.notifier);
    final success = await captureNotifier.updateField(fieldName, updatedField);
    
    if (success) {
      setState(() {
        _hasUnsavedChanges = true;
      });

      // Schedule auto-save confirmation
      _scheduleAutoSaveConfirmation();
    }
  }

  void _scheduleAutoSaveConfirmation() {
    // Show brief save confirmation after successful update
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _hasUnsavedChanges = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('Changes saved'),
              ],
            ),
            duration: Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
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
    // Use the current result from CaptureProvider state
    final captureState = ref.watch(captureProvider);
    final displayResult = captureState.lastProcessingResult ?? result;
    
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
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Receipt Processed Successfully',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_hasUnsavedChanges) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.orange[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 12, color: Colors.orange[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Edited',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Editable fields using FieldEditor components
          Text(
            'Receipt Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          MerchantFieldEditorWithNormalization(
            fieldData: displayResult.merchant,
            onChanged: _handleMerchantChanged,
            showNormalizationIndicator: true,
          ),
          
          DateFieldEditor(
            fieldData: displayResult.date,
            onChanged: _handleDateChanged,
          ),
          
          AmountFieldEditor(
            fieldName: 'Total',
            label: 'Total Amount',
            fieldData: displayResult.total,
            onChanged: _handleTotalChanged,
          ),
          
          AmountFieldEditor(
            fieldName: 'Tax',
            label: 'Tax Amount',
            fieldData: displayResult.tax,
            onChanged: _handleTaxChanged,
          ),
          
          const SizedBox(height: 16),
          
          // Notes field
          NotesFieldEditor(
            initialValue: _notes,
            onChanged: _handleNotesChanged,
            enabled: true,
          ),
          
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
                    'Overall Confidence: ${displayResult.overallConfidence.toStringAsFixed(1)}%',
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
                // Changes are auto-saved through CaptureProvider
                Navigator.of(context).pop();
              },
              child: const Text('Accept & Continue'),
            ),
          ),
        ],
      ),
    );
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