import 'package:flutter/material.dart';
import '../../../../core/models/confidence_level.dart';

/// Compact circular confidence indicator for receipt list views
/// 
/// Displays as a 24x24dp badge positioned in the top-right corner
/// of receipt cards or thumbnails. Uses color coding to provide
/// immediate visual feedback about data quality.
class ConfidenceBadge extends StatelessWidget {
  final double? confidence;
  final double size;
  final bool showPercentage;

  const ConfidenceBadge({
    Key? key,
    required this.confidence,
    this.size = 24.0,
    this.showPercentage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (confidence == null) {
      return _buildProcessingBadge();
    }

    final confidenceLevel = confidence!.confidenceLevel;
    final color = _getConfidenceColor(confidenceLevel);
    final icon = _getConfidenceIcon(confidenceLevel);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: showPercentage
          ? Center(
              child: Text(
                '${confidence!.round()}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Icon(
              icon,
              color: Colors.white,
              size: size * 0.6,
            ),
    );
  }

  Widget _buildProcessingBadge() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade400,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.5,
          height: size * 0.5,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
        return Icons.warning;
      case ConfidenceLevel.medium:
        return Icons.info;
      case ConfidenceLevel.high:
        return Icons.check;
    }
  }
}

/// Positioned confidence badge for overlaying on receipt thumbnails
class PositionedConfidenceBadge extends StatelessWidget {
  final double? confidence;
  final Widget child;
  final double size;
  final EdgeInsets margin;

  const PositionedConfidenceBadge({
    Key? key,
    required this.confidence,
    required this.child,
    this.size = 24.0,
    this.margin = const EdgeInsets.all(4.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: margin.top,
          right: margin.right,
          child: ConfidenceBadge(
            confidence: confidence,
            size: size,
          ),
        ),
      ],
    );
  }
}