import 'dart:typed_data';
import 'dart:io';
<<<<<<< Updated upstream
=======
import 'dart:async';
>>>>>>> Stashed changes
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:receipt_organizer/features/capture/providers/capture_provider.dart';
<<<<<<< Updated upstream
=======
import 'package:receipt_organizer/features/capture/providers/preview_initialization_provider.dart';
>>>>>>> Stashed changes
import 'package:receipt_organizer/features/capture/widgets/capture_failed_state.dart';
import 'package:receipt_organizer/features/capture/widgets/retry_prompt_dialog.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:receipt_organizer/features/receipts/presentation/widgets/field_editor.dart';
import 'package:receipt_organizer/features/receipts/presentation/widgets/merchant_field_editor_with_normalization.dart';
import 'package:receipt_organizer/features/capture/widgets/notes_field_editor.dart';
import 'package:receipt_organizer/shared/widgets/zoomable_image_viewer.dart';
import 'package:receipt_organizer/shared/widgets/bounding_box_overlay.dart';
import 'package:receipt_organizer/features/receipts/presentation/providers/image_viewer_provider.dart';

/// Preview screen that shows capture results and handles retry scenarios
<<<<<<< Updated upstream
class PreviewScreen extends ConsumerStatefulWidget {
=======
class PreviewScreen extends ConsumerWidget {
>>>>>>> Stashed changes
  final Uint8List imageData;
  final String? sessionId;

  const PreviewScreen({
    super.key,
    required this.imageData,
    this.sessionId,
  });

  @override
<<<<<<< Updated upstream
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  bool _isProcessing = false;
  bool _hasUnsavedChanges = false;
  String _notes = '';
  
  // Image viewer state
  String? _imagePath;
  final TransformationController _imageTransformController = TransformationController();
  
  @override
  void initState() {
    super.initState();
    _saveImageToFile();
    _processCapture();
    
    // Connect image viewer provider to transformation controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(imageViewerProvider.notifier).connectToController(_imageTransformController);
=======
  Widget build(BuildContext context, WidgetRef ref) {
    // Create initialization params
    final initParams = PreviewInitParams(
      imageData: imageData,
      sessionId: sessionId,
    );
    
    // Watch the initialization provider
    final initState = ref.watch(previewInitializationProvider(initParams));
    
    // Handle the async value
    return initState.when(
      data: (state) => _PreviewScreenContent(
        initState: state,
        imageData: imageData,
      ),
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Content widget for the preview screen that handles UI without side effects
class _PreviewScreenContent extends ConsumerStatefulWidget {
  final PreviewInitState initState;
  final Uint8List imageData;
  
  const _PreviewScreenContent({
    required this.initState,
    required this.imageData,
  });
  
  @override
  ConsumerState<_PreviewScreenContent> createState() => _PreviewScreenContentState();
}

class _PreviewScreenContentState extends ConsumerState<_PreviewScreenContent> {
  bool _hasUnsavedChanges = false;
  String _notes = '';
  final TransformationController _imageTransformController = TransformationController();
  
  // Track if we've started processing
  bool _processingStarted = false;
  
  // Store reference to image viewer notifier
  ImageViewerNotifier? _imageViewerNotifier;
  
  // Timer for auto-save confirmation
  Timer? _autoSaveTimer;
  
  @override
  void initState() {
    super.initState();
    
    // Connect image viewer provider to transformation controller after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _imageViewerNotifier = ref.read(imageViewerProvider.notifier);
        _imageViewerNotifier?.connectToController(_imageTransformController);
        
        // Start processing after UI is built
        _startProcessing();
      }
>>>>>>> Stashed changes
    });
  }
  
  @override
  void dispose() {
<<<<<<< Updated upstream
    // Disconnect from provider before disposing
    ref.read(imageViewerProvider.notifier).disconnectFromController();
    _imageTransformController.dispose();
    // Clean up temporary image file
    if (_imagePath != null) {
      File(_imagePath!).deleteSync();
    }
    super.dispose();
  }
  
  Future<void> _saveImageToFile() async {
    try {
      // Save image data to a temporary file for ZoomableImageViewer
      final tempDir = await getTemporaryDirectory();
      final uuid = const Uuid().v4();
      final tempFile = File('${tempDir.path}/receipt_$uuid.jpg');
      await tempFile.writeAsBytes(widget.imageData);
      
      if (mounted) {
        setState(() {
          _imagePath = tempFile.path;
        });
      }
    } catch (e) {
      debugPrint('Error saving image to file: $e');
    }
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
=======
    // Cancel any pending auto-save timer
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
    
    // Disconnect from image viewer if connected
    _imageViewerNotifier?.disconnectFromController();
    _imageViewerNotifier = null;
    
    // Dispose transformation controller
    _imageTransformController.dispose();
    super.dispose();
  }
  
  Future<void> _startProcessing() async {
    if (_processingStarted) return;
    _processingStarted = true;
    
    // Get the processing notifier
    final processingNotifier = ref.read(
      previewProcessingProvider(PreviewInitParams(
        imageData: widget.imageData,
        sessionId: widget.initState.sessionId,
      )).notifier
    );
    
    // Start processing
    await processingNotifier.startProcessing();
  }

  bool get _isProcessing {
    final processingState = ref.watch(
      previewProcessingProvider(PreviewInitParams(
        imageData: widget.imageData,
        sessionId: widget.initState.sessionId,
      ))
    );
    return processingState.isProcessing;
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
        setState(() {
          _isProcessing = true;
        });

        final success = await captureNotifier.retryCapture();

        setState(() {
          _isProcessing = false;
        });

=======
        // Processing state is managed by the provider
        final success = await captureNotifier.retryCapture();

>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
    setState(() {
      _isProcessing = true;
    });

    final captureNotifier = ref.read(captureProvider.notifier);
    final success = await captureNotifier.retryCapture();

    setState(() {
      _isProcessing = false;
    });

=======
    // Processing state is managed by the provider
    final captureNotifier = ref.read(captureProvider.notifier);
    final success = await captureNotifier.retryCapture();

>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
    // Show brief save confirmation after successful update
    Future.delayed(const Duration(milliseconds: 300), () {
=======
    // Cancel any existing timer
    _autoSaveTimer?.cancel();
    
    // Show brief save confirmation after successful update
    _autoSaveTimer = Timer(const Duration(milliseconds: 300), () {
>>>>>>> Stashed changes
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
    final imageViewerState = ref.watch(imageViewerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Result'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _onCancel,
        ),
        actions: [
          // View mode toggle
<<<<<<< Updated upstream
          if (!captureState.isRetryMode && captureState.lastProcessingResult != null && _imagePath != null) ...[
=======
          if (!captureState.isRetryMode && captureState.lastProcessingResult != null && widget.initState.imagePath.isNotEmpty) ...[
>>>>>>> Stashed changes
            IconButton(
              icon: Icon(imageViewerState.showBoundingBoxes ? Icons.crop_free : Icons.crop_free_outlined),
              tooltip: imageViewerState.showBoundingBoxes ? 'Hide boxes' : 'Show boxes',
              onPressed: () {
                ref.read(imageViewerProvider.notifier).toggleBoundingBoxes();
              },
            ),
            IconButton(
              icon: Icon(!imageViewerState.isImageOnly ? Icons.image : Icons.view_sidebar),
              tooltip: !imageViewerState.isImageOnly ? 'Image only' : 'Split view',
              onPressed: () {
                ref.read(imageViewerProvider.notifier).toggleImageOnlyMode();
              },
            ),
          ],
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
    
    // Watch image viewer state
    final imageViewerState = ref.watch(imageViewerProvider);
    final imageViewerNotifier = ref.read(imageViewerProvider.notifier);
    
    // If image path is not ready, show loading
<<<<<<< Updated upstream
    if (_imagePath == null) {
=======
    if (widget.initState.imagePath.isEmpty) {
>>>>>>> Stashed changes
      return const Center(child: CircularProgressIndicator());
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if we should use tablet layout (side-by-side)
        final isTablet = constraints.maxWidth > 768;
        
        // Extract bounding boxes from OCR result
        final boundingBoxes = imageViewerState.showBoundingBoxes && displayResult.merchant != null && displayResult.merchant!.boundingBox != null
            ? BoundingBoxOverlay.extractFromProcessingResult(displayResult)
            : <OcrBoundingBox>[];
        
        // Image viewer widget with bounding box overlay
        final imageViewer = ZoomableImageViewer(
<<<<<<< Updated upstream
          imagePath: _imagePath!,
=======
          imagePath: widget.initState.imagePath,
>>>>>>> Stashed changes
          minScale: imageViewerState.minZoom,
          maxScale: imageViewerState.maxZoom,
          showFpsOverlay: false,
          onTap: () {
            // Toggle view mode on tap
            imageViewerNotifier.toggleImageOnlyMode();
          },
          overlayBuilder: boundingBoxes.isNotEmpty ? (imageSize, transform) {
            return BoundingBoxOverlay(
              boundingBoxes: boundingBoxes,
              selectedFieldName: imageViewerState.selectedField,
              imageSize: imageSize,
              displaySize: MediaQuery.of(context).size,
              onFieldTapped: (fieldName) {
                imageViewerNotifier.selectField(fieldName);
                
                // If in split view, show feedback
                if (!imageViewerState.isImageOnly) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selected: $fieldName'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
              debugMode: false, // Set to true for debugging
            );
          } : null,
        );
        
        // Fields editor widget
        final fieldsEditor = Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success header
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Receipt Processed',
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
                
                // Editable fields
                Text(
                  'Receipt Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Wrap each field in a container to highlight when selected
                Container(
                  decoration: BoxDecoration(
                    border: imageViewerState.selectedField == 'merchant' 
                        ? Border.all(color: Colors.green, width: 2)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: MerchantFieldEditorWithNormalization(
                    fieldData: displayResult.merchant,
                    onChanged: _handleMerchantChanged,
                    showNormalizationIndicator: true,
                  ),
                ),
                
                Container(
                  decoration: BoxDecoration(
                    border: imageViewerState.selectedField == 'date'
                        ? Border.all(color: Colors.green, width: 2)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DateFieldEditor(
                    fieldData: displayResult.date,
                    onChanged: _handleDateChanged,
                  ),
                ),
                
                Container(
                  decoration: BoxDecoration(
                    border: imageViewerState.selectedField == 'total'
                        ? Border.all(color: Colors.green, width: 2)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AmountFieldEditor(
                    fieldName: 'Total',
                    label: 'Total Amount',
                    fieldData: displayResult.total,
                    onChanged: _handleTotalChanged,
                  ),
                ),
                
                Container(
                  decoration: BoxDecoration(
                    border: imageViewerState.selectedField == 'tax'
                        ? Border.all(color: Colors.green, width: 2)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AmountFieldEditor(
                    fieldName: 'Tax',
                    label: 'Tax Amount',
                    fieldData: displayResult.tax,
                    onChanged: _handleTaxChanged,
                  ),
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
<<<<<<< Updated upstream
                        Text(
                          'Overall Confidence: ${displayResult.overallConfidence.toStringAsFixed(1)}%',
                          style: const TextStyle(fontWeight: FontWeight.w500),
=======
                        Expanded(
                          child: Text(
                            'Overall Confidence: ${displayResult.overallConfidence.toStringAsFixed(1)}%',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
>>>>>>> Stashed changes
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
          ),
        );
        
        // Build layout based on view mode and device type
        if (imageViewerState.isImageOnly) {
          // Image-only view
          return imageViewer;
        } else if (isTablet) {
          // Tablet: side-by-side layout
          return Row(
            children: [
              // Image viewer on the left (40% width)
              Expanded(
                flex: 40,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: imageViewer,
                ),
              ),
              // Fields editor on the right (60% width)
              Expanded(
                flex: 60,
                child: fieldsEditor,
              ),
            ],
          );
        } else {
          // Phone: stacked layout
          return Column(
            children: [
              // Collapsible image viewer at the top
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: !imageViewerState.isImageOnly ? 250 : 0,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: imageViewer,
                ),
              ),
              // Fields editor below
              Expanded(
                child: fieldsEditor,
              ),
            ],
          );
        }
      },
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
<<<<<<< Updated upstream
              child: Image.memory(
                widget.imageData,
=======
              child: widget.initState.imagePath.isNotEmpty
                ? Image.file(
                    File(widget.initState.imagePath),
                    fit: BoxFit.cover,
                  )
                : Image.memory(
                    widget.imageData,
>>>>>>> Stashed changes
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