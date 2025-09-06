import 'package:flutter/material.dart';
import '../../../../core/models/confidence_level.dart';
import '../../../../domain/services/ocr_service.dart';

/// Comprehensive confidence indicator for field-level confidence display
/// 
/// Used in receipt detail screens and field editors to show OCR confidence
/// with visual highlighting, warnings, and success indicators.
/// Integrates with FieldData model from OCR service.
class ConfidenceIndicator extends StatefulWidget {
  final FieldData? fieldData;
  final String fieldName;
  final bool showLabel;
  final bool showProgressBar;
  final EdgeInsets padding;
  final bool animate;

  const ConfidenceIndicator({
    Key? key,
    required this.fieldData,
    required this.fieldName,
    this.showLabel = true,
    this.showProgressBar = false,
    this.padding = const EdgeInsets.all(8.0),
    this.animate = true,
  }) : super(key: key);

  @override
  State<ConfidenceIndicator> createState() => _ConfidenceIndicatorState();
}

class _ConfidenceIndicatorState extends State<ConfidenceIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    if (widget.animate) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ConfidenceIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate when confidence changes
    if (widget.animate &&
        oldWidget.fieldData?.confidence != widget.fieldData?.confidence) {
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fieldData == null) {
      return _buildProcessingIndicator();
    }

    final fieldData = widget.fieldData!;
    final confidence = fieldData.confidence;
    final confidenceLevel = confidence.confidenceLevel;
    final color = _getConfidenceColor(confidenceLevel);
    final backgroundColor = _getConfidenceBackgroundColor(confidenceLevel);
    final icon = _getConfidenceIcon(confidenceLevel);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.animate ? _scaleAnimation.value : 1.0,
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: fieldData.isManuallyEdited ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 16),
                    const SizedBox(width: 6),
                    if (widget.showLabel) ...[
                      Text(
                        widget.fieldName,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '${confidence.round()}%',
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (fieldData.isManuallyEdited) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.edit,
                        color: Colors.blue,
                        size: 12,
                      ),
                    ],
                  ],
                ),
                if (widget.showProgressBar) ...[
                  const SizedBox(height: 6),
                  _buildProgressBar(color, confidence),
                ],
                if (_shouldShowWarning(confidenceLevel, fieldData)) ...[
                  const SizedBox(height: 6),
                  _buildWarningMessage(confidenceLevel),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(Color color, double confidence) {
    return Container(
      height: 4,
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: color.withOpacity(0.2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (confidence / 100.0).clamp(0.0, 1.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildWarningMessage(ConfidenceLevel level) {
    String message;
    Color messageColor;

    switch (level) {
      case ConfidenceLevel.low:
        message = 'Please verify this field';
        messageColor = const Color(0xFFD32F2F);
        break;
      case ConfidenceLevel.medium:
        message = 'May need verification';
        messageColor = const Color(0xFFF57C00);
        break;
      case ConfidenceLevel.high:
        message = 'High confidence';
        messageColor = const Color(0xFF388E3C);
        break;
    }

    return Text(
      message,
      style: TextStyle(
        color: messageColor,
        fontSize: 11,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Processing ${widget.fieldName}...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowWarning(ConfidenceLevel level, FieldData fieldData) {
    // Always show message for detailed view, but only show warnings for low/medium confidence
    if (widget.showProgressBar) return true;
    return level == ConfidenceLevel.low || level == ConfidenceLevel.medium;
  }

  Color _getConfidenceColor(ConfidenceLevel level) {
    switch (level) {
      case ConfidenceLevel.low:
        return const Color(0xFFD32F2F); // Red
      case ConfidenceLevel.medium:
        return const Color(0xFFF57C00); // Orange
      case ConfidenceLevel.high:
        return const Color(0xFF388E3C); // Green
    }
  }

  Color _getConfidenceBackgroundColor(ConfidenceLevel level) {
    switch (level) {
      case ConfidenceLevel.low:
        return const Color(0xFFFFEBEE); // Red50
      case ConfidenceLevel.medium:
        return const Color(0xFFFFF3E0); // Orange50
      case ConfidenceLevel.high:
        return const Color(0xFFE8F5E8); // Green50
    }
  }

  IconData _getConfidenceIcon(ConfidenceLevel level) {
    switch (level) {
      case ConfidenceLevel.low:
        return Icons.warning_amber;
      case ConfidenceLevel.medium:
        return Icons.info_outline;
      case ConfidenceLevel.high:
        return Icons.check_circle_outline;
    }
  }
}