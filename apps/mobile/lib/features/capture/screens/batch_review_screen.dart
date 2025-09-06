import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/features/capture/providers/batch_capture_provider.dart';
import 'package:receipt_organizer/features/capture/widgets/receipt_thumbnail_widget.dart';
import 'package:receipt_organizer/features/capture/widgets/ocr_results_widget.dart';
import 'package:receipt_organizer/domain/services/csv_export_service.dart';

class BatchReviewScreen extends ConsumerStatefulWidget {
  const BatchReviewScreen({super.key});

  @override
  ConsumerState<BatchReviewScreen> createState() => _BatchReviewScreenState();
}

class _BatchReviewScreenState extends ConsumerState<BatchReviewScreen> {
  final Map<String, Receipt> _recentlyDeleted = {};
  final Set<String> _expandedReceipts = {};
  final ICSVExportService _csvExportService = CSVExportService();
  bool _isExporting = false;

  void _deleteReceipt(Receipt receipt) {
    setState(() {
      _recentlyDeleted[receipt.id] = receipt;
    });
    
    ref.read(batchCaptureProvider.notifier).removeReceipt(receipt.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Receipt deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => _undoDelete(receipt.id),
        ),
        duration: const Duration(seconds: 3),
      ),
    ).closed.then((_) {
      setState(() {
        _recentlyDeleted.remove(receipt.id);
      });
    });
  }

  void _undoDelete(String receiptId) {
    final receipt = _recentlyDeleted[receiptId];
    if (receipt != null) {
      final notifier = ref.read(batchCaptureProvider.notifier);
      final currentState = ref.read(batchCaptureProvider);
      notifier.state = currentState.copyWith(
        receipts: [...currentState.receipts, receipt],
      );
      setState(() {
        _recentlyDeleted.remove(receiptId);
      });
    }
  }

  Future<void> _processAllReceipts() async {
    final receipts = ref.read(batchCaptureProvider).receipts;
    if (receipts.isEmpty) return;

    // Show export format selection dialog
    final format = await _showExportFormatDialog();
    if (format == null) return;

    setState(() {
      _isExporting = true;
    });

    try {
      // Validate receipts for export
      final validation = await _csvExportService.validateForExport(receipts, format);
      
      if (!validation.isValid) {
        await _showValidationDialog(validation);
        return;
      }

      // Show warnings if any
      if (validation.warnings.isNotEmpty) {
        final shouldContinue = await _showWarningsDialog(validation);
        if (!shouldContinue) return;
      }

      // Export to CSV
      final result = await _csvExportService.exportToCSV(receipts, format);
      
      if (result.success) {
        await _showExportSuccessDialog(result);
        
        // Clear batch after successful export
        ref.read(batchCaptureProvider.notifier).clearBatch();
        
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        _showErrorSnackBar('Export failed: ${result.error}');
      }
    } catch (e) {
      _showErrorSnackBar('Export error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  void _addMoreReceipts() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final batchState = ref.watch(batchCaptureProvider);
    final receipts = batchState.receipts;

    return Scaffold(
      appBar: AppBar(
        title: Text('Review Batch (${receipts.length})'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: receipts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No receipts to review',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: receipts.length,
                    onReorder: (oldIndex, newIndex) {
                      ref.read(batchCaptureProvider.notifier)
                          .reorderReceipts(oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final receipt = receipts[index];
                      return Dismissible(
                        key: ValueKey(receipt.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        onDismissed: (_) => _deleteReceipt(receipt),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Stack(
                                  children: [
                                    ReceiptThumbnailWidget(
                                      imageUri: receipt.imageUri,
                                      size: 48,
                                    ),
                                    if (receipt.hasOCRResults)
                                      Positioned(
                                        right: -2,
                                        top: -2,
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: _getConfidenceColor(receipt.overallConfidence),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 1),
                                          ),
                                          child: Icon(
                                            receipt.overallConfidence >= 85 
                                                ? Icons.check 
                                                : Icons.warning,
                                            size: 10,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                title: Row(
                                  children: [
                                    Text('Receipt ${index + 1}'),
                                    const SizedBox(width: 8),
                                    if (receipt.hasOCRResults) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getConfidenceColor(receipt.overallConfidence).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: _getConfidenceColor(receipt.overallConfidence),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          '${receipt.overallConfidence.toStringAsFixed(0)}%',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: _getConfidenceColor(receipt.overallConfidence),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Captured: ${_formatTime(receipt.capturedAt)}'),
                                    if (receipt.hasOCRResults && receipt.merchantName != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '${receipt.merchantName} • \$${receipt.totalAmount?.toStringAsFixed(2) ?? 'N/A'}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (receipt.hasOCRResults)
                                      IconButton(
                                        icon: Icon(
                                          _expandedReceipts.contains(receipt.id) 
                                              ? Icons.expand_less 
                                              : Icons.expand_more,
                                          size: 20,
                                        ),
                                        onPressed: () => _toggleExpanded(receipt.id),
                                        tooltip: 'Show OCR Details',
                                      ),
                                    const Icon(Icons.drag_handle),
                                  ],
                                ),
                              ),
                              if (_expandedReceipts.contains(receipt.id) && receipt.hasOCRResults)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: OCRResultsWidget(
                                    receipt: receipt,
                                    isExpanded: true,
                                    onFieldEdit: (field, value) {
                                      // TODO: Implement field editing
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _addMoreReceipts,
                          icon: const Icon(Icons.add),
                          label: const Text('Add More'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: (receipts.isEmpty || _isExporting) ? null : _processAllReceipts,
                          icon: _isExporting 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.file_download),
                          label: Text(_isExporting ? 'Exporting...' : 'Export CSV'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _toggleExpanded(String receiptId) {
    setState(() {
      if (_expandedReceipts.contains(receiptId)) {
        _expandedReceipts.remove(receiptId);
      } else {
        _expandedReceipts.add(receiptId);
      }
    });
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 85) {
      return Colors.green;
    } else if (confidence >= 70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Future<ExportFormat?> _showExportFormatDialog() async {
    return showDialog<ExportFormat>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Format'),
        content: const Text('Choose the CSV format for your accounting software:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(ExportFormat.quickbooks),
            child: const Text('QuickBooks'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(ExportFormat.xero),
            child: const Text('Xero'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(ExportFormat.generic),
            child: const Text('Generic'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _showValidationDialog(ValidationResult validation) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation Errors'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${validation.errors.length} errors found:'),
              const SizedBox(height: 8),
              ...validation.errors.map((error) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(error, style: const TextStyle(fontSize: 14))),
                  ],
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showWarningsDialog(ValidationResult validation) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Warnings'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${validation.warnings.length} warnings found:'),
              const SizedBox(height: 8),
              ...validation.warnings.map((warning) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(warning, style: const TextStyle(fontSize: 14))),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              const Text('Continue with export?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _showExportSuccessDialog(ExportResult result) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Successful'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Exported ${result.recordCount} receipts successfully!'),
            const SizedBox(height: 8),
            Text('File: ${result.fileName}'),
            const SizedBox(height: 8),
            Text('Location: ${result.filePath}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}