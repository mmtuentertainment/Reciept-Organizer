import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/confidence_level.dart';
import '../../../../domain/services/ocr_service.dart';
import 'confidence_indicator.dart';

/// Field editor widget for editing OCR-extracted receipt fields
/// 
/// Provides inline editing with confidence display, validation feedback,
/// and visual highlighting for fields requiring attention.
class FieldEditor extends StatefulWidget {
  final String fieldName;
  final FieldData? fieldData;
  final String? label;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<FieldData>? onFieldDataChanged;
  final bool showConfidence;
  final bool enabled;
  final String? hintText;

  const FieldEditor({
    Key? key,
    required this.fieldName,
    this.fieldData,
    this.label,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onFieldDataChanged,
    this.showConfidence = true,
    this.enabled = true,
    this.hintText,
  }) ;

  @override
  State<FieldEditor> createState() => _FieldEditorState();
}

class _FieldEditorState extends State<FieldEditor> 
    with TickerProviderStateMixin {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late AnimationController _confidenceChangeController;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _confidenceScaleAnimation;
  
  FieldData? _currentFieldData;
  bool _hasBeenEdited = false;
  double? _previousConfidence;

  @override
  void initState() {
    super.initState();
    _currentFieldData = widget.fieldData;
    _previousConfidence = _currentFieldData?.confidence;
    _textController = TextEditingController(
      text: _currentFieldData?.value?.toString() ?? '',
    );
    _focusNode = FocusNode();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _confidenceChangeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _borderColorAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.blue,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _confidenceScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _confidenceChangeController,
      curve: Curves.elasticOut,
    ));

    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    _confidenceChangeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FieldEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.fieldData != widget.fieldData && !_hasBeenEdited) {
      _currentFieldData = widget.fieldData;
      _textController.text = _currentFieldData?.value?.toString() ?? '';
    }
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _handleTextChange(String value) {
    _hasBeenEdited = true;
    
    // Validate the input based on field type
    final validationStatus = _validateFieldValue(value);
    
    // Create updated FieldData with manual edit flag and validation
    final updatedFieldData = _currentFieldData?.copyWith(
      value: value,
      isManuallyEdited: true,
      validationStatus: validationStatus,
      // Preserve original confidence but mark as edited
    ) ?? FieldData(
      value: value,
      confidence: 100.0, // Manual entry gets full confidence
      originalText: value,
      isManuallyEdited: true,
      validationStatus: validationStatus,
    );

    // Check if confidence changed to trigger animation
    final currentConfidence = updatedFieldData.confidence;
    if (_previousConfidence != null && _previousConfidence != currentConfidence) {
      _triggerConfidenceChangeAnimation();
    }
    _previousConfidence = currentConfidence;

    setState(() {
      _currentFieldData = updatedFieldData;
    });

    widget.onChanged?.call(value);
    widget.onFieldDataChanged?.call(updatedFieldData);
  }

  String _validateFieldValue(String value) {
    if (value.trim().isEmpty) {
      return 'error'; // Empty value
    }

    // Field-specific validation based on field name
    switch (widget.fieldName.toLowerCase()) {
      case 'date':
        return _validateDateFormat(value);
      case 'total':
      case 'tax':
        return _validateAmountFormat(value);
      case 'merchant':
        return _validateMerchantName(value);
      default:
        return 'valid';
    }
  }

  String _validateDateFormat(String value) {
    try {
      final dateRegExp = RegExp(r'^\d{1,2}\/\d{1,2}\/\d{4}$');
      if (!dateRegExp.hasMatch(value)) {
        return 'warning'; // Invalid format
      }
      
      final parts = value.split('/');
      final month = int.parse(parts[0]);
      final day = int.parse(parts[1]);
      // final year = int.parse(parts[2]);
      
      if (month < 1 || month > 12 || day < 1 || day > 31) {
        return 'error'; // Invalid date values
      }
      
      return 'valid';
    } catch (e) {
      return 'error';
    }
  }

  String _validateAmountFormat(String value) {
    try {
      final amount = double.parse(value);
      if (amount < 0) {
        return 'warning'; // Negative amounts are unusual
      }
      if (amount > 10000) {
        return 'warning'; // Very large amounts for receipts
      }
      return 'valid';
    } catch (e) {
      return 'error'; // Not a valid number
    }
  }

  String _validateMerchantName(String value) {
    if (value.trim().length < 2) {
      return 'warning'; // Very short merchant names
    }
    if (value.trim().length > 50) {
      return 'warning'; // Unusually long merchant names
    }
    return 'valid';
  }

  void _triggerConfidenceChangeAnimation() {
    _confidenceChangeController.forward().then((_) {
      _confidenceChangeController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final confidenceLevel = _currentFieldData?.confidence.confidenceLevel;
    final shouldHighlight = confidenceLevel == ConfidenceLevel.low ||
                           confidenceLevel == ConfidenceLevel.medium;
    final shouldShowSuccess = confidenceLevel == ConfidenceLevel.high;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) _buildLabel(context),
          const SizedBox(height: 4),
          _buildInputField(context, shouldHighlight, shouldShowSuccess),
          if (widget.showConfidence && _currentFieldData != null) ...[
            const SizedBox(height: 8),
            _buildConfidenceDisplay(),
          ],
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: widget.label!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          if (_currentFieldData?.isManuallyEdited == true) ...[
            const TextSpan(text: ' '),
            WidgetSpan(
              child: Icon(
                Icons.edit,
                size: 14,
                color: Colors.blue[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField(BuildContext context, bool shouldHighlight, bool shouldShowSuccess) {
    return AnimatedBuilder(
      animation: _borderColorAnimation,
      builder: (context, child) {
        Color borderColor = _borderColorAnimation.value ?? Colors.grey;
        Color? backgroundColor;
        
        // Override with warning colors if field needs attention
        if (shouldHighlight && !_focusNode.hasFocus) {
          final confidenceLevel = _currentFieldData!.confidence.confidenceLevel;
          borderColor = confidenceLevel == ConfidenceLevel.low
              ? const Color(0xFFD32F2F) // Red
              : const Color(0xFFF57C00); // Orange
          backgroundColor = confidenceLevel == ConfidenceLevel.low
              ? const Color(0xFFFFEBEE) // Light red background
              : const Color(0xFFFFF3E0); // Light orange background
        } 
        // Add success indicators for high confidence fields
        else if (shouldShowSuccess && !_focusNode.hasFocus) {
          borderColor = const Color(0xFF388E3C); // Green
          backgroundColor = const Color(0xFFE8F5E8); // Light green background
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor,
              width: (shouldHighlight || shouldShowSuccess) ? 2 : 1,
            ),
            color: backgroundColor,
          ),
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            enabled: widget.enabled,
            onChanged: _handleTextChange,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.grey[400],
              ),
              suffixIcon: !_focusNode.hasFocus && (shouldHighlight || shouldShowSuccess)
                  ? shouldHighlight 
                      ? _buildWarningIcon()
                      : _buildSuccessIcon()
                  : null,
            ),
            style: TextStyle(
              fontSize: 16,
              color: widget.enabled ? null : Colors.grey[600],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWarningIcon() {
    final confidenceLevel = _currentFieldData!.confidence.confidenceLevel;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Icon(
        confidenceLevel == ConfidenceLevel.low
            ? Icons.warning_amber
            : Icons.info_outline,
        color: confidenceLevel == ConfidenceLevel.low
            ? const Color(0xFFD32F2F)
            : const Color(0xFFF57C00),
        size: 20,
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return const Padding(
      padding: EdgeInsets.only(right: 8),
      child: Icon(
        Icons.check_circle_outline,
        color: Color(0xFF388E3C), // Green
        size: 20,
      ),
    );
  }

  Widget _buildConfidenceDisplay() {
    return AnimatedBuilder(
      animation: _confidenceScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _confidenceScaleAnimation.value,
          child: Row(
            children: [
              Expanded(
                child: ConfidenceIndicator(
                  fieldData: _currentFieldData,
                  fieldName: widget.fieldName,
                  showLabel: false,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
              const SizedBox(width: 8),
              if (_currentFieldData!.isManuallyEdited)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue[200]!, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 12, color: Colors.blue[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Edited',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              if (_currentFieldData!.validationStatus != 'valid')
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  child: Icon(
                    _currentFieldData!.validationStatus == 'error' 
                        ? Icons.error_outline
                        : Icons.warning_amber_outlined,
                    size: 16,
                    color: _currentFieldData!.validationStatus == 'error'
                        ? const Color(0xFFD32F2F)
                        : const Color(0xFFF57C00),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Specialized field editors for specific data types
class MerchantFieldEditor extends StatelessWidget {
  final FieldData? fieldData;
  final ValueChanged<FieldData>? onChanged;
  final bool showConfidence;

  const MerchantFieldEditor({
    Key? key,
    this.fieldData,
    this.onChanged,
    this.showConfidence = true,
  }) ;

  @override
  Widget build(BuildContext context) {
    return FieldEditor(
      fieldName: 'Merchant',
      fieldData: fieldData,
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
      onFieldDataChanged: onChanged,
      showConfidence: showConfidence,
      hintText: 'Enter merchant name',
    );
  }
}

class DateFieldEditor extends StatelessWidget {
  final FieldData? fieldData;
  final ValueChanged<FieldData>? onChanged;
  final bool showConfidence;

  const DateFieldEditor({
    Key? key,
    this.fieldData,
    this.onChanged,
    this.showConfidence = true,
  }) ;

  @override
  Widget build(BuildContext context) {
    return FieldEditor(
      fieldName: 'Date',
      fieldData: fieldData,
      label: 'Receipt Date',
      keyboardType: TextInputType.datetime,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9/\-]')),
        LengthLimitingTextInputFormatter(10),
      ],
      onFieldDataChanged: onChanged,
      showConfidence: showConfidence,
      hintText: 'MM/DD/YYYY',
    );
  }
}

class AmountFieldEditor extends StatelessWidget {
  final String fieldName;
  final String label;
  final FieldData? fieldData;
  final ValueChanged<FieldData>? onChanged;
  final bool showConfidence;

  const AmountFieldEditor({
    Key? key,
    required this.fieldName,
    required this.label,
    this.fieldData,
    this.onChanged,
    this.showConfidence = true,
  }) ;

  @override
  Widget build(BuildContext context) {
    return FieldEditor(
      fieldName: fieldName,
      fieldData: fieldData,
      label: label,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        TextInputFormatter.withFunction((oldValue, newValue) {
          // Ensure only one decimal point
          final text = newValue.text;
          if (text.split('.').length > 2) {
            return oldValue;
          }
          return newValue;
        }),
      ],
      onFieldDataChanged: onChanged,
      showConfidence: showConfidence,
      hintText: '\$0.00',
    );
  }
}