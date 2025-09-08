import 'package:flutter/material.dart';
import '../../../../data/models/receipt.dart';
import '../../../../domain/services/ocr_service.dart';
import '../../../../shared/widgets/confidence_score_widget.dart';
import '../widgets/field_editor.dart';
import '../../../capture/widgets/notes_field_editor.dart';

/// Receipt detail screen for viewing and editing receipt data
/// 
/// Provides comprehensive confidence display for all OCR fields
/// with inline editing capabilities and real-time confidence updates.
class ReceiptDetailScreen extends StatefulWidget {
  final Receipt receipt;
  final ValueChanged<Receipt>? onReceiptUpdated;

  const ReceiptDetailScreen({
    Key? key,
    required this.receipt,
    this.onReceiptUpdated,
  }) ;

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  late Receipt _currentReceipt;
  bool _hasUnsavedChanges = false;
  String? _notes;

  @override
  void initState() {
    super.initState();
    _currentReceipt = widget.receipt;
    _notes = widget.receipt.notes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _currentReceipt.hasOCRResults
          ? _buildReceiptDetails(context)
          : _buildProcessingState(context),
      floatingActionButton: _hasUnsavedChanges 
          ? _buildSaveButton(context)
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        _currentReceipt.merchantName ?? 'Receipt Details',
        style: const TextStyle(fontSize: 18),
      ),
      actions: [
        if (_currentReceipt.hasOCRResults)
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showConfidenceInfo(context),
            tooltip: 'Confidence Information',
          ),
        PopupMenuButton<String>(
          onSelected: _handleMenuSelection,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Export'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReceiptDetails(BuildContext context) {
    final ocrResults = _currentReceipt.ocrResults!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverallConfidenceCard(context),
          const SizedBox(height: 24),
          _buildReceiptImage(context),
          const SizedBox(height: 24),
          _buildFieldsSection(context, ocrResults),
          const SizedBox(height: 24),
          _buildMetadataSection(context),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildOverallConfidenceCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Data Quality Assessment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ConfidenceScoreWidget(
                  confidence: _currentReceipt.overallConfidence,
                  variant: ConfidenceDisplayVariant.detailed,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQualityMessage(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityMessage() {
    final confidence = _currentReceipt.overallConfidence;
    String message;
    Color messageColor;

    if (confidence >= 85) {
      message = 'High quality data. All fields appear reliable.';
      messageColor = const Color(0xFF388E3C);
    } else if (confidence >= 75) {
      message = 'Good data quality. Some fields may need verification.';
      messageColor = const Color(0xFFF57C00);
    } else {
      message = 'Data needs review. Please verify the extracted information.';
      messageColor = const Color(0xFFD32F2F);
    }

    return Text(
      message,
      style: TextStyle(
        color: messageColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildReceiptImage(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt, size: 64, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Receipt Image',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldsSection(BuildContext context, ProcessingResult ocrResults) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Receipt Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        MerchantFieldEditor(
          fieldData: ocrResults.merchant,
          onChanged: _handleMerchantChanged,
        ),
        
        DateFieldEditor(
          fieldData: ocrResults.date,
          onChanged: _handleDateChanged,
        ),
        
        AmountFieldEditor(
          fieldName: 'Total',
          label: 'Total Amount',
          fieldData: ocrResults.total,
          onChanged: _handleTotalChanged,
        ),
        
        AmountFieldEditor(
          fieldName: 'Tax',
          label: 'Tax Amount',
          fieldData: ocrResults.tax,
          onChanged: _handleTaxChanged,
        ),
        
        const SizedBox(height: 16),
        
        // Notes section
        Text(
          'Notes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        
        NotesFieldEditor(
          initialValue: _notes,
          onChanged: _handleNotesChanged,
          enabled: true,
        ),
      ],
    );
  }

  Widget _buildMetadataSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Processing Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildMetadataRow('Captured', _formatDateTime(_currentReceipt.capturedAt)),
            _buildMetadataRow('Last Modified', _formatDateTime(_currentReceipt.lastModified)),
            _buildMetadataRow('Status', _currentReceipt.status.name.toUpperCase()),
            if (_currentReceipt.ocrResults != null) ...[
              _buildMetadataRow('Processing Engine', _currentReceipt.ocrResults!.processingEngine),
              _buildMetadataRow('Processing Time', '${_currentReceipt.ocrResults!.processingDurationMs}ms'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Processing receipt...',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Please wait while we extract information from your receipt.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _saveChanges,
      icon: const Icon(Icons.save),
      label: const Text('Save Changes'),
    );
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
  }

  void _updateOCRField(String fieldName, FieldData updatedField) {
    if (_currentReceipt.ocrResults == null) return;

    final currentResults = _currentReceipt.ocrResults!;
    ProcessingResult updatedResults;

    switch (fieldName) {
      case 'merchant':
        updatedResults = ProcessingResult(
          merchant: updatedField,
          date: currentResults.date,
          total: currentResults.total,
          tax: currentResults.tax,
          overallConfidence: _calculateOverallConfidence(
            updatedField,
            currentResults.date,
            currentResults.total,
            currentResults.tax,
          ),
          processingEngine: currentResults.processingEngine,
          processingDurationMs: currentResults.processingDurationMs,
          allText: currentResults.allText,
        );
        break;
      case 'date':
        updatedResults = ProcessingResult(
          merchant: currentResults.merchant,
          date: updatedField,
          total: currentResults.total,
          tax: currentResults.tax,
          overallConfidence: _calculateOverallConfidence(
            currentResults.merchant,
            updatedField,
            currentResults.total,
            currentResults.tax,
          ),
          processingEngine: currentResults.processingEngine,
          processingDurationMs: currentResults.processingDurationMs,
          allText: currentResults.allText,
        );
        break;
      case 'total':
        updatedResults = ProcessingResult(
          merchant: currentResults.merchant,
          date: currentResults.date,
          total: updatedField,
          tax: currentResults.tax,
          overallConfidence: _calculateOverallConfidence(
            currentResults.merchant,
            currentResults.date,
            updatedField,
            currentResults.tax,
          ),
          processingEngine: currentResults.processingEngine,
          processingDurationMs: currentResults.processingDurationMs,
          allText: currentResults.allText,
        );
        break;
      case 'tax':
        updatedResults = ProcessingResult(
          merchant: currentResults.merchant,
          date: currentResults.date,
          total: currentResults.total,
          tax: updatedField,
          overallConfidence: _calculateOverallConfidence(
            currentResults.merchant,
            currentResults.date,
            currentResults.total,
            updatedField,
          ),
          processingEngine: currentResults.processingEngine,
          processingDurationMs: currentResults.processingDurationMs,
          allText: currentResults.allText,
        );
        break;
      default:
        return;
    }

    setState(() {
      _currentReceipt = _currentReceipt.copyWith(
        ocrResults: updatedResults,
        lastModified: DateTime.now(),
      );
      _hasUnsavedChanges = true;
    });
  }

  double _calculateOverallConfidence(
    FieldData? merchant,
    FieldData? date, 
    FieldData? total,
    FieldData? tax,
  ) {
    final fields = [merchant, date, total, tax];
    final validFields = fields.where((f) => f != null).toList();
    
    if (validFields.isEmpty) return 0.0;
    
    // Weighted average: Total 40%, Date 30%, Merchant 20%, Tax 10%
    double weightedSum = 0.0;
    double totalWeight = 0.0;
    
    if (total != null) {
      weightedSum += total.confidence * 0.4;
      totalWeight += 0.4;
    }
    if (date != null) {
      weightedSum += date.confidence * 0.3;
      totalWeight += 0.3;
    }
    if (merchant != null) {
      weightedSum += merchant.confidence * 0.2;
      totalWeight += 0.2;
    }
    if (tax != null) {
      weightedSum += tax.confidence * 0.1;
      totalWeight += 0.1;
    }
    
    return totalWeight > 0 ? weightedSum / totalWeight : 0.0;
  }

  void _saveChanges() {
    // Update the receipt with the new notes
    final updatedReceipt = _currentReceipt.copyWith(
      notes: _notes,
      lastModified: DateTime.now(),
    );
    
    // TODO: Implement actual save logic with repository
    widget.onReceiptUpdated?.call(updatedReceipt);
    
    setState(() {
      _currentReceipt = updatedReceipt;
      _hasUnsavedChanges = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receipt saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showConfidenceInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confidence Scores'),
        content: const Text(
          'Confidence scores indicate how reliable the extracted data is:\n\n'
          '• Green (85%+): High confidence, data is likely accurate\n'
          '• Orange (75-84%): Medium confidence, may need verification\n'
          '• Red (<75%): Low confidence, please verify\n\n'
          'Manual edits always show 100% confidence.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'export':
        // TODO: Implement export functionality
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Receipt'),
        content: const Text('Are you sure you want to delete this receipt? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to list
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} '
           '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}