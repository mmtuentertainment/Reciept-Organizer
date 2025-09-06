import 'package:flutter/material.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';

class OCRResultsWidget extends StatelessWidget {
  final Receipt receipt;
  final bool isExpanded;
  final VoidCallback? onToggle;
  final Function(String field, dynamic value)? onFieldEdit;

  const OCRResultsWidget({
    super.key,
    required this.receipt,
    this.isExpanded = false,
    this.onToggle,
    this.onFieldEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (!receipt.hasOCRResults) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.warning, color: Colors.orange),
          title: Text('No OCR Results'),
          subtitle: Text('Receipt needs processing'),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: _buildConfidenceIcon(receipt.overallConfidence),
            title: Text('OCR Results (${receipt.overallConfidence.toStringAsFixed(1)}%)'),
            subtitle: Text('${_getConfidenceLevel(receipt.overallConfidence)} confidence'),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: onToggle,
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            _buildFieldTile('Merchant', receipt.ocrResults?.merchant, Icons.store),
            _buildFieldTile('Date', receipt.ocrResults?.date, Icons.calendar_today),
            _buildFieldTile('Total', receipt.ocrResults?.total, Icons.attach_money),
            _buildFieldTile('Tax', receipt.ocrResults?.tax, Icons.receipt),
            if (receipt.ocrResults?.allText.isNotEmpty == true) ...[
              const Divider(height: 1),
              ExpansionTile(
                leading: const Icon(Icons.text_fields, size: 20),
                title: const Text('All Text', style: TextStyle(fontSize: 14)),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      receipt.ocrResults!.allText.join('\n'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildFieldTile(String label, FieldData? field, IconData icon) {
    if (field == null) {
      return ListTile(
        leading: Icon(icon, size: 20, color: Colors.grey),
        title: Text(label, style: const TextStyle(fontSize: 14)),
        subtitle: const Text('Not found', style: TextStyle(color: Colors.grey)),
        dense: true,
      );
    }

    return ListTile(
      leading: Icon(icon, size: 20, color: _getConfidenceColor(field.confidence)),
      title: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          _buildConfidenceBadge(field.confidence),
        ],
      ),
      subtitle: Text(
        field.value.toString(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: field.isManuallyEdited ? Colors.blue : Colors.black,
        ),
      ),
      trailing: onFieldEdit != null 
          ? IconButton(
              icon: const Icon(Icons.edit, size: 16),
              onPressed: () => _showEditDialog(label, field),
            )
          : null,
      dense: true,
    );
  }

  Widget _buildConfidenceIcon(double confidence) {
    if (confidence >= 85) {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else if (confidence >= 70) {
      return const Icon(Icons.warning, color: Colors.orange);
    } else {
      return const Icon(Icons.error, color: Colors.red);
    }
  }

  Widget _buildConfidenceBadge(double confidence) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getConfidenceColor(confidence).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _getConfidenceColor(confidence), width: 1),
      ),
      child: Text(
        '${confidence.toStringAsFixed(0)}%',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getConfidenceColor(confidence),
        ),
      ),
    );
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

  String _getConfidenceLevel(double confidence) {
    if (confidence >= 85) {
      return 'High';
    } else if (confidence >= 70) {
      return 'Medium';
    } else {
      return 'Low';
    }
  }

  void _showEditDialog(String fieldName, FieldData field) {
    if (onFieldEdit == null) return;

    // This would show an edit dialog for the field
    // Implementation would depend on field type (text, number, date, etc.)
  }
}