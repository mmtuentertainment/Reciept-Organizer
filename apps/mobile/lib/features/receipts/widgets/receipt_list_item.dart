import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/core/models/receipt.dart';
import 'package:receipt_organizer/features/receipts/providers/selection_mode_provider.dart';
import 'package:intl/intl.dart';

class ReceiptListItem extends ConsumerWidget {
  final Receipt receipt;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showCheckbox;
  
  const ReceiptListItem({
    Key? key,
    required this.receipt,
    this.onTap,
    this.onLongPress,
    this.showCheckbox = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(selectionModeProvider);
    final isSelected = selectionState.isSelected(receipt.id);
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    
    return Semantics(
      selected: isSelected,
      label: _buildAccessibilityLabel(receipt, dateFormat, currencyFormat),
      hint: selectionState.isSelectionMode 
          ? 'Double tap to toggle selection' 
          : 'Double tap to view, long press to select',
      child: Material(
        color: isSelected 
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : Colors.transparent,
        child: InkWell(
          onTap: () {
            if (selectionState.isSelectionMode) {
              HapticFeedback.selectionClick();
              ref.read(selectionModeProvider.notifier).toggleSelection(receipt.id);
            } else {
              onTap?.call();
            }
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            if (!selectionState.isSelectionMode) {
              ref.read(selectionModeProvider.notifier).enterSelectionMode(
                initialSelection: receipt.id,
              );
            }
            onLongPress?.call();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Checkbox (visible in selection mode)
                if (showCheckbox)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: selectionState.isSelectionMode ? 40 : 0,
                    child: selectionState.isSelectionMode
                        ? Checkbox(
                            value: isSelected,
                            onChanged: (_) {
                              HapticFeedback.selectionClick();
                              ref.read(selectionModeProvider.notifier)
                                  .toggleSelection(receipt.id);
                            },
                            semanticLabel: 'Select receipt from ${receipt.merchantName ?? 'Unknown'}',
                          )
                        : const SizedBox.shrink(),
                  ),
                
                // Thumbnail
                Container(
                  width: 56,
                  height: 56,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: receipt.thumbnailPath != null
                        ? Image.asset(
                            receipt.thumbnailPath!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
                          )
                        : _buildPlaceholder(theme),
                  ),
                ),
                
                // Receipt details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Merchant name
                      Text(
                        receipt.merchantName ?? 'Unknown Merchant',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // Date and amount row
                      Row(
                        children: [
                          // Date
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            receipt.date != null
                                ? dateFormat.format(receipt.date!)
                                : 'No date',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // Amount
                          if (receipt.totalAmount != null) ...[
                            Icon(
                              Icons.attach_money,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              currencyFormat.format(receipt.totalAmount),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      // Low confidence indicator
                      if (receipt.ocrResults?.overallConfidence != null && 
                          receipt.ocrResults!.overallConfidence! < 0.9) ...[
                        const SizedBox(height: 4),
                        _buildConfidenceChip(receipt.ocrResults!.overallConfidence!, theme),
                      ],
                      
                      // Soft delete indicator
                      if (receipt.isDeleted) ...[
                        const SizedBox(height: 4),
                        _buildDeletedChip(theme),
                      ],
                    ],
                  ),
                ),
                
                // Confidence indicator
                if (receipt.ocrResults?.overallConfidence != null)
                  _buildConfidenceIndicator(receipt.ocrResults!.overallConfidence!, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPlaceholder(ThemeData theme) {
    return Icon(
      Icons.receipt_outlined,
      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
    );
  }
  
  Widget _buildConfidenceChip(double confidence, ThemeData theme) {
    final String label;
    final Color color;
    
    if (confidence < 0.7) {
      label = 'Low Confidence';
      color = theme.colorScheme.error;
    } else if (confidence < 0.9) {
      label = 'Medium Confidence';
      color = theme.colorScheme.tertiary;
    } else {
      label = 'High Confidence';
      color = theme.colorScheme.primary;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  Widget _buildDeletedChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.delete_outline,
            size: 12,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 4),
          Text(
            'Deleted',
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConfidenceIndicator(double confidence, ThemeData theme) {
    final color = confidence >= 0.9
        ? Colors.green
        : confidence >= 0.7
            ? Colors.orange
            : Colors.red;
    
    return Semantics(
      label: 'Confidence: ${(confidence * 100).toInt()}%',
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(left: 8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: confidence,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: 3,
            ),
            Text(
              '${(confidence * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _buildAccessibilityLabel(
    Receipt receipt,
    DateFormat dateFormat,
    NumberFormat currencyFormat,
  ) {
    final parts = <String>[];
    
    parts.add('Receipt from ${receipt.merchantName ?? 'Unknown merchant'}');
    
    if (receipt.date != null) {
      parts.add('dated ${dateFormat.format(receipt.date!)}');
    }
    
    if (receipt.totalAmount != null) {
      parts.add('for ${currencyFormat.format(receipt.totalAmount)}');
    }
    
    // Remove status check as Receipt doesn't have status field
    
    if (receipt.isDeleted) {
      parts.add('Marked for deletion');
    }
    
    if (receipt.ocrResults?.overallConfidence != null) {
      parts.add('Confidence: ${(receipt.ocrResults!.overallConfidence! * 100).toInt()}%');
    }
    
    return parts.join(', ');
  }
}

// Extension to add missing properties
extension on ThemeData {
  ColorScheme get colorScheme => this.colorScheme;
  TextTheme get textTheme => this.textTheme;
}

extension on ColorScheme {
  Color get orange => const Color(0xFFFF9800);
}