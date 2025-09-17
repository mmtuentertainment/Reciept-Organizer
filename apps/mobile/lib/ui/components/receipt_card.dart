import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/ui/theme/shadcn_theme_provider.dart';
import 'package:intl/intl.dart';

/// Modern receipt card component using shadcn UI
class ReceiptCard extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ReceiptCard({
    super.key,
    required this.receipt,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isDark = context.isDarkMode;
    final statusColor = context.getReceiptStatusColor(receipt.status ?? 'pending');

    return ShadCard(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with merchant and amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receipt.merchantName ?? 'Unknown Merchant',
                        style: theme.textTheme.h4.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, yyyy').format(receipt.purchaseDate),
                        style: theme.textTheme.muted.copyWith(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${receipt.totalAmount.toStringAsFixed(2)}',
                      style: theme.textTheme.h4.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ShadBadge(
                      backgroundColor: statusColor.withOpacity(0.1),
                      child: Text(
                        (receipt.status ?? 'pending').toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Category and payment method
            if (receipt.category != null || receipt.paymentMethod != null) ...[
              const SizedBox(height: 12),
              const ShadDivider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (receipt.category != null) ...[
                    Icon(
                      _getCategoryIcon(receipt.category!),
                      size: 16,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      receipt.category!,
                      style: theme.textTheme.small.copyWith(
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                  if (receipt.category != null && receipt.paymentMethod != null)
                    const SizedBox(width: 16),
                  if (receipt.paymentMethod != null) ...[
                    Icon(
                      _getPaymentIcon(receipt.paymentMethod!),
                      size: 16,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      receipt.paymentMethod!,
                      style: theme.textTheme.small.copyWith(
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ],

            // Notes
            if (receipt.notes != null && receipt.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.messageSquare,
                      size: 14,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        receipt.notes!,
                        style: theme.textTheme.small.copyWith(
                          color: theme.colorScheme.mutedForeground,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action buttons
            if (onEdit != null || onDelete != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onEdit != null)
                    ShadButton.ghost(
                      onPressed: onEdit,
                      size: ShadButtonSize.sm,
                      icon: const Icon(LucideIcons.edit, size: 16),
                      child: const Text('Edit'),
                    ),
                  if (onEdit != null && onDelete != null)
                    const SizedBox(width: 8),
                  if (onDelete != null)
                    ShadButton.ghost(
                      onPressed: onDelete,
                      size: ShadButtonSize.sm,
                      foregroundColor: theme.colorScheme.destructive,
                      icon: const Icon(LucideIcons.trash, size: 16),
                      child: const Text('Delete'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'groceries':
        return LucideIcons.utensils;
      case 'transport':
      case 'transportation':
        return LucideIcons.car;
      case 'shopping':
        return LucideIcons.shoppingBag;
      case 'entertainment':
        return LucideIcons.music;
      case 'health':
      case 'medical':
        return LucideIcons.heart;
      case 'utilities':
        return LucideIcons.home;
      case 'business':
        return LucideIcons.briefcase;
      default:
        return LucideIcons.receipt;
    }
  }

  IconData _getPaymentIcon(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'credit':
      case 'credit card':
        return LucideIcons.creditCard;
      case 'debit':
      case 'debit card':
        return LucideIcons.creditCard;
      case 'cash':
        return LucideIcons.banknote;
      case 'digital':
      case 'online':
        return LucideIcons.smartphone;
      default:
        return LucideIcons.wallet;
    }
  }
}