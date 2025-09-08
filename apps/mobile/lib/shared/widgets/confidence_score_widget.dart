import 'package:flutter/material.dart';

import '../../core/models/confidence_level.dart';

/// Reusable confidence score widget with percentage display and color coding
/// 
/// Displays OCR confidence scores with visual feedback using color coding:
/// - Red (<75%): Low confidence requiring attention
/// - Orange (75-85%): Medium confidence
/// - Green (>85%): High confidence, reliable data
/// 
/// Supports multiple display variants:
/// - compact: Just percentage with color
/// - detailed: Percentage + progress bar
/// - inline: Compact display for inline use
class ConfidenceScoreWidget extends StatelessWidget {
  final double? confidence;
  final ConfidenceDisplayVariant variant;
  final bool showIcon;
  final double? size;
  final bool animate;

  const ConfidenceScoreWidget({
    Key? key,
    required this.confidence,
    this.variant = ConfidenceDisplayVariant.compact,
    this.showIcon = true,
    this.size,
    this.animate = true,
  }) ;

  @override
  Widget build(BuildContext context) {
    // Handle null confidence and processing states
    if (confidence == null) {
      return _buildProcessingState(context);
    }

    final confidenceLevel = confidence!.confidenceLevel;
    final color = _getConfidenceColor(confidenceLevel);
    final icon = _getConfidenceIcon(confidenceLevel);

    switch (variant) {
      case ConfidenceDisplayVariant.compact:
        return _buildCompactDisplay(context, color, icon);
      case ConfidenceDisplayVariant.detailed:
        return _buildDetailedDisplay(context, color, icon);
      case ConfidenceDisplayVariant.inline:
        return _buildInlineDisplay(context, color, icon);
    }
  }

  Widget _buildCompactDisplay(BuildContext context, Color color, IconData icon) {
    const double defaultSize = 32.0;
    final displaySize = size ?? defaultSize;

    return Container(
      width: displaySize,
      height: displaySize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha((0.1 * 255).round()),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showIcon) ...[
            Icon(icon, color: color, size: displaySize * 0.3),
            const SizedBox(height: 2),
          ],
          Text(
            '${confidence!.round()}%',
            style: TextStyle(
              color: color,
              fontSize: displaySize * 0.2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedDisplay(BuildContext context, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withAlpha((0.1 * 255).round()),
        border: Border.all(color: color.withAlpha((0.3 * 255).round())),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcon) ...[
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                'Confidence: ${confidence!.round()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildProgressBar(color),
        ],
      ),
    );
  }

  Widget _buildInlineDisplay(BuildContext context, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
        ],
        Text(
          '${confidence!.round()}%',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(Color color) {
    return Container(
      height: 6,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: color.withAlpha((0.2 * 255).round()),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (confidence! / 100.0).clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingState(BuildContext context) {
    const color = Colors.grey;
    
    if (variant == ConfidenceDisplayVariant.detailed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color.withAlpha((0.1 * 255).round()),
          border: Border.all(color: color.withAlpha((0.3 * 255).round())),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Processing...',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // For compact and inline variants
    return Container(
      width: size ?? 32.0,
      height: size ?? 32.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha((0.1 * 255).round()),
        border: Border.all(color: color, width: 2),
      ),
      child: const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        ),
      ),
    );
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

/// Display variants for confidence score widget
enum ConfidenceDisplayVariant {
  /// Just percentage with color coding in a circular container
  compact,
  
  /// Percentage, progress bar, and detailed information
  detailed,
  
  /// Minimal inline display for use within other widgets
  inline,
}

