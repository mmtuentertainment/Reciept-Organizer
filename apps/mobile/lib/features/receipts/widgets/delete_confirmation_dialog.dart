import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/core/models/receipt.dart';
import 'package:receipt_organizer/core/services/bulk_operation_service.dart';
import 'package:intl/intl.dart';

class DeleteConfirmationDialog extends ConsumerStatefulWidget {
  final List<Receipt> receipts;
  final Function(bool permanent) onConfirm;
  
  const DeleteConfirmationDialog({
    Key? key,
    required this.receipts,
    required this.onConfirm,
  }) : super(key: key);
  
  @override
  ConsumerState<DeleteConfirmationDialog> createState() => _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends ConsumerState<DeleteConfirmationDialog> {
  bool _isPermanent = false;
  bool _isCalculatingStorage = false;
  int? _storageBytes;
  
  @override
  void initState() {
    super.initState();
    _calculateStorage();
  }
  
  Future<void> _calculateStorage() async {
    if (widget.receipts.isEmpty) return;
    
    setState(() => _isCalculatingStorage = true);
    
    try {
      final service = ref.read(bulkOperationServiceProvider('current_user'));
      final bytes = await service.calculateStorageToBeFreed(widget.receipts);
      
      if (mounted) {
        setState(() {
          _storageBytes = bytes;
          _isCalculatingStorage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCalculatingStorage = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    
    // Calculate summary stats
    final totalAmount = widget.receipts
        .where((r) => r.totalAmount != null)
        .fold<double>(0, (sum, r) => sum + r.totalAmount!);
    
    // Count receipts with high confidence as "processed"
    final processedCount = widget.receipts
        .where((r) => r.ocrResults?.overallConfidence != null && 
                      r.ocrResults!.overallConfidence! >= 0.9)
        .length;
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Delete ${widget.receipts.length} Receipt${widget.receipts.length != 1 ? 's' : ''}',
              style: theme.textTheme.headlineSmall,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow(
                    Icons.receipt_outlined,
                    'Total receipts',
                    '${widget.receipts.length}',
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    Icons.check_circle_outline,
                    'Processed',
                    '$processedCount',
                  ),
                  if (totalAmount > 0) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      Icons.attach_money,
                      'Total value',
                      currencyFormat.format(totalAmount),
                    ),
                  ],
                  if (_storageBytes != null) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      Icons.storage,
                      'Storage to free',
                      BulkOperationService.formatStorageSize(_storageBytes!),
                    ),
                  ] else if (_isCalculatingStorage) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      Icons.storage,
                      'Storage',
                      'Calculating...',
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Warning message
            if (!_isPermanent) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Soft Delete (Recommended)',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Receipts will be marked for deletion and can be restored within 7 days. After 7 days, they will be permanently deleted.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.error.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.delete_forever,
                      size: 20,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Permanent Delete',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'This action cannot be undone! Receipts and all associated data will be immediately and permanently deleted.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Permanent delete checkbox
            CheckboxListTile(
              value: _isPermanent,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                setState(() => _isPermanent = value ?? false);
              },
              title: const Text('Permanently delete immediately'),
              subtitle: const Text(
                'Skip the 7-day restoration period',
                style: TextStyle(fontSize: 12),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            
            // Sample of receipts to be deleted
            if (widget.receipts.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                'Receipts to delete:',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 120),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.receipts.take(5).length,
                  itemBuilder: (context, index) {
                    final receipt = widget.receipts[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 6,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              receipt.merchantName ?? 'Unknown Merchant',
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (receipt.totalAmount != null)
                            Text(
                              currencyFormat.format(receipt.totalAmount),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (widget.receipts.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '...and ${widget.receipts.length - 5} more',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).pop();
            widget.onConfirm(_isPermanent);
            
            // Announce action for accessibility
            SemanticsService.announce(
              _isPermanent
                  ? 'Permanently deleting ${widget.receipts.length} receipts'
                  : 'Deleting ${widget.receipts.length} receipts. They can be restored within 7 days.',
              Directionality.of(context),
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: _isPermanent
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
          child: Text(_isPermanent ? 'Delete Forever' : 'Delete'),
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    );
  }
  
  Widget _buildSummaryRow(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Simplified confirmation dialog for single receipt
class QuickDeleteDialog extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback onConfirm;
  
  const QuickDeleteDialog({
    Key? key,
    required this.receipt,
    required this.onConfirm,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    
    return AlertDialog(
      title: const Text('Delete Receipt?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Receipt details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  receipt.merchantName ?? 'Unknown Merchant',
                  style: theme.textTheme.titleSmall,
                ),
                if (receipt.date != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${DateFormat('MM/dd/yyyy').format(receipt.date!)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                if (receipt.totalAmount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Amount: ${currencyFormat.format(receipt.totalAmount)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Info message
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This receipt will be deleted and can be restored within 7 days.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}