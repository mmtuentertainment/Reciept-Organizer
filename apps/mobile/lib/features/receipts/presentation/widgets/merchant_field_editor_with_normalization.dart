import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/services/ocr_service.dart';
import 'field_editor.dart';

/// Enhanced merchant field editor that displays normalization status
/// 
/// Shows an info icon when the merchant name has been normalized,
/// with a tooltip displaying the original vs normalized value
class MerchantFieldEditorWithNormalization extends StatefulWidget {
  final FieldData? fieldData;
  final ValueChanged<FieldData>? onChanged;
  final bool showConfidence;
  final bool showNormalizationIndicator;

  const MerchantFieldEditorWithNormalization({
    Key? key,
    this.fieldData,
    this.onChanged,
    this.showConfidence = true,
    this.showNormalizationIndicator = true,
  }) ;

  @override
  State<MerchantFieldEditorWithNormalization> createState() => 
      _MerchantFieldEditorWithNormalizationState();
}

class _MerchantFieldEditorWithNormalizationState 
    extends State<MerchantFieldEditorWithNormalization> {
  
  bool get _isNormalized {
    if (widget.fieldData == null) return false;
    // Check if the value differs from originalText
    return widget.fieldData!.value != widget.fieldData!.originalText &&
           widget.fieldData!.originalText.isNotEmpty;
  }

  void _showNormalizationDetails() {
    if (!_isNormalized) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.auto_fix_high, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Merchant Name Normalized'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Original:', widget.fieldData!.originalText),
            const SizedBox(height: 8),
            _buildDetailRow('Normalized:', widget.fieldData!.value.toString()),
            const SizedBox(height: 16),
            Text(
              'This merchant name was automatically cleaned up for consistency.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base field editor
        FieldEditor(
          fieldName: 'Merchant',
          fieldData: widget.fieldData,
          label: 'Merchant Name',
          keyboardType: TextInputType.text,
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              // Capitalize first letter of each word
              final words = newValue.text.split(' ');
              final capitalizedWords = words.map((word) {
                if (word.isEmpty) return word;
                return word[0].toUpperCase() + word.substring(1).toLowerCase();
              });
              return newValue.copyWith(text: capitalizedWords.join(' '));
            }),
          ],
          onFieldDataChanged: widget.onChanged,
          showConfidence: widget.showConfidence,
          hintText: 'Enter merchant name',
        ),
        
        // Normalization indicator overlay
        if (_isNormalized && widget.showNormalizationIndicator)
          Positioned(
            right: widget.showConfidence ? 120 : 8,
            top: 20,
            child: _buildNormalizationIndicator(),
          ),
      ],
    );
  }

  Widget _buildNormalizationIndicator() {
    return Tooltip(
      message: 'Name was normalized from: ${widget.fieldData!.originalText}',
      preferBelow: false,
      child: InkWell(
        onTap: _showNormalizationDetails,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.auto_fix_high,
            size: 16,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}