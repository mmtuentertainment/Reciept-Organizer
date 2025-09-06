import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/features/capture/providers/batch_capture_provider.dart';
import 'package:receipt_organizer/features/capture/widgets/receipt_thumbnail_widget.dart';

class BatchReviewScreen extends ConsumerStatefulWidget {
  const BatchReviewScreen({super.key});

  @override
  ConsumerState<BatchReviewScreen> createState() => _BatchReviewScreenState();
}

class _BatchReviewScreenState extends ConsumerState<BatchReviewScreen> {
  final Map<String, Receipt> _recentlyDeleted = {};

  void _deleteReceipt(Receipt receipt) {
    setState(() {
      _recentlyDeleted[receipt.id] = receipt;
    });
    
    ref.read(batchCaptureProvider.notifier).removeReceipt(receipt.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Receipt deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => _undoDelete(receipt.id),
        ),
        duration: const Duration(seconds: 3),
      ),
    ).closed.then((_) {
      setState(() {
        _recentlyDeleted.remove(receipt.id);
      });
    });
  }

  void _undoDelete(String receiptId) {
    final receipt = _recentlyDeleted[receiptId];
    if (receipt != null) {
      final notifier = ref.read(batchCaptureProvider.notifier);
      final currentState = ref.read(batchCaptureProvider);
      notifier.state = currentState.copyWith(
        receipts: [...currentState.receipts, receipt],
      );
      setState(() {
        _recentlyDeleted.remove(receiptId);
      });
    }
  }

  void _processAllReceipts() {
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Processing ${ref.read(batchCaptureProvider).receipts.length} receipts...',
        ),
        backgroundColor: Colors.green,
      ),
    );

    ref.read(batchCaptureProvider.notifier).clearBatch();
  }

  void _addMoreReceipts() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final batchState = ref.watch(batchCaptureProvider);
    final receipts = batchState.receipts;

    return Scaffold(
      appBar: AppBar(
        title: Text('Review Batch (${receipts.length})'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: receipts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No receipts to review',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: receipts.length,
                    onReorder: (oldIndex, newIndex) {
                      ref.read(batchCaptureProvider.notifier)
                          .reorderReceipts(oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final receipt = receipts[index];
                      return Dismissible(
                        key: ValueKey(receipt.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        onDismissed: (_) => _deleteReceipt(receipt),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: ReceiptThumbnailWidget(
                              imageUri: receipt.imageUri,
                              size: 48,
                            ),
                            title: Text('Receipt ${index + 1}'),
                            subtitle: Text(
                              'Captured: ${_formatTime(receipt.capturedAt)}',
                            ),
                            trailing: const Icon(Icons.drag_handle),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _addMoreReceipts,
                          icon: const Icon(Icons.add),
                          label: const Text('Add More'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: receipts.isEmpty ? null : _processAllReceipts,
                          icon: const Icon(Icons.check),
                          label: const Text('Process All'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}