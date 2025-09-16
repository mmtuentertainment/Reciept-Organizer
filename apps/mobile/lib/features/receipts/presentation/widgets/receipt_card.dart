import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/confidence_level.dart';
import '../../../../data/models/receipt.dart';
import '../../../../shared/widgets/confidence_score_widget.dart';
import 'confidence_badge.dart';

/// Receipt card widget for displaying receipts in list views
/// 
/// Shows receipt thumbnail, extracted data, and confidence information
/// with visual indicators for data quality assessment.
class ReceiptCard extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showConfidenceSummary;
  final bool isSelected;

  const ReceiptCard({
    super.key,
    required this.receipt,
    this.onTap,
    this.onLongPress,
    this.showConfidenceSummary = true,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final confidenceLevel = receipt.overallConfidence > 0 
        ? receipt.overallConfidence.confidenceLevel 
        : null;

    return Card(
      elevation: isSelected ? 4 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isSelected 
                ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                : _buildConfidenceBorder(confidenceLevel),
            color: _buildConfidenceBackground(confidenceLevel),
          ),
          child: Row(
            children: [
              _buildThumbnail(),
              const SizedBox(width: 16),
              Expanded(child: _buildReceiptInfo(context)),
              if (showConfidenceSummary) _buildConfidenceDisplay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return PositionedConfidenceBadge(
      confidence: receipt.overallConfidence > 0 ? receipt.overallConfidence : null,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: const Icon(
          Icons.receipt,
          color: Colors.grey,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildReceiptInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Merchant name
        Text(
          receipt.merchantName ?? 'Unknown Merchant',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: receipt.merchantName == null ? Colors.grey : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        
        // Date and amount row
        Row(
          children: [
            if (receipt.receiptDate != null) ...[
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMM d, yyyy').format(receipt.receiptDate!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
            ],
            if (receipt.totalAmount != null) ...[
              Icon(Icons.attach_money, size: 14, color: Colors.grey[600]),
              Text(
                '\$${receipt.totalAmount!.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        
        // Status and timestamp
        Row(
          children: [
            _buildStatusIndicator(context),
            const SizedBox(width: 8),
            Text(
              _formatTimestamp(receipt.capturedAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        
        // Notes preview
        if (receipt.notes != null && receipt.notes!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.note, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  receipt.notes!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    
    switch (receipt.status) {
      case ReceiptStatus.processing:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case ReceiptStatus.ready:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case ReceiptStatus.exported:
        statusColor = Colors.blue;
        statusIcon = Icons.download_done;
        break;
      case ReceiptStatus.error:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case ReceiptStatus.captured:
        statusColor = Colors.grey;
        statusIcon = Icons.photo_camera;
        break;
    }

    return Icon(
      statusIcon,
      size: 14,
      color: statusColor,
    );
  }

  Widget _buildConfidenceDisplay() {
    if (!receipt.hasOCRResults) {
      return SizedBox(
        width: 48,
        height: 48,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        ConfidenceScoreWidget(
          confidence: receipt.overallConfidence,
          variant: ConfidenceDisplayVariant.compact,
          size: 48,
        ),
        const SizedBox(height: 4),
        _buildFieldConfidencePreview(),
      ],
    );
  }

  Widget _buildFieldConfidencePreview() {
    if (receipt.ocrResults == null) return const SizedBox.shrink();

    final ocrResults = receipt.ocrResults!;
    final fields = [
      ocrResults.merchant,
      ocrResults.date,
      ocrResults.total,
      ocrResults.tax,
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: fields.map((field) {
        if (field == null) {
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 2),
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          );
        }

        Color color;
        final confidence = field.confidence;
        if (confidence >= 85) {
          color = const Color(0xFF388E3C); // Green
        } else if (confidence >= 75) {
          color = const Color(0xFFF57C00); // Orange
        } else {
          color = const Color(0xFFD32F2F); // Red
        }

        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );
      }).toList(),
    );
  }

  Border? _buildConfidenceBorder(ConfidenceLevel? confidenceLevel) {
    if (confidenceLevel == null) return null;

    Color borderColor;
    switch (confidenceLevel) {
      case ConfidenceLevel.low:
        borderColor = const Color(0xFFD32F2F); // Red
        break;
      case ConfidenceLevel.medium:
        borderColor = const Color(0xFFF57C00); // Orange
        break;
      case ConfidenceLevel.high:
        borderColor = const Color(0xFF388E3C); // Green
        break;
    }
    
    return Border.all(
      color: borderColor.withOpacity(0.3),
      width: 1,
    );
  }

  Color? _buildConfidenceBackground(ConfidenceLevel? confidenceLevel) {
    if (confidenceLevel == null) return null;

    switch (confidenceLevel) {
      case ConfidenceLevel.low:
        return const Color(0xFFFFEBEE).withOpacity(0.3); // Very light red
      case ConfidenceLevel.medium:
        return const Color(0xFFFFF3E0).withOpacity(0.3); // Very light orange
      case ConfidenceLevel.high:
        return const Color(0xFFE8F5E8).withOpacity(0.3); // Very light green
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Compact version of receipt card for grid views
class CompactReceiptCard extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback? onTap;
  final bool isSelected;

  const CompactReceiptCard({
    super.key,
    required this.receipt,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final confidenceLevel = receipt.overallConfidence > 0 
        ? receipt.overallConfidence.confidenceLevel 
        : null;

    return Card(
      elevation: isSelected ? 4 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isSelected 
                ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                : _buildConfidenceBorder(confidenceLevel),
            color: _buildConfidenceBackground(confidenceLevel),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PositionedConfidenceBadge(
                confidence: receipt.overallConfidence > 0 ? receipt.overallConfidence : null,
                size: 20,
                margin: const EdgeInsets.all(2),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: const Icon(
                    Icons.receipt,
                    color: Colors.grey,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                receipt.merchantName ?? 'Unknown',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              if (receipt.totalAmount != null)
                Text(
                  '\$${receipt.totalAmount!.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Border? _buildConfidenceBorder(ConfidenceLevel? confidenceLevel) {
    if (confidenceLevel == null) return null;

    Color borderColor;
    switch (confidenceLevel) {
      case ConfidenceLevel.low:
        borderColor = const Color(0xFFD32F2F); // Red
        break;
      case ConfidenceLevel.medium:
        borderColor = const Color(0xFFF57C00); // Orange
        break;
      case ConfidenceLevel.high:
        borderColor = const Color(0xFF388E3C); // Green
        break;
    }
    
    return Border.all(
      color: borderColor.withOpacity(0.3),
      width: 1,
    );
  }

  Color? _buildConfidenceBackground(ConfidenceLevel? confidenceLevel) {
    if (confidenceLevel == null) return null;

    switch (confidenceLevel) {
      case ConfidenceLevel.low:
        return const Color(0xFFFFEBEE).withOpacity(0.3); // Very light red
      case ConfidenceLevel.medium:
        return const Color(0xFFFFF3E0).withOpacity(0.3); // Very light orange
      case ConfidenceLevel.high:
        return const Color(0xFFE8F5E8).withOpacity(0.3); // Very light green
    }
  }
}