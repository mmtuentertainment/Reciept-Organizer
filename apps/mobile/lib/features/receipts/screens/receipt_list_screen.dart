import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/core/models/receipt.dart';
import 'package:receipt_organizer/features/receipts/providers/selection_mode_provider.dart';
import 'package:receipt_organizer/features/receipts/widgets/receipt_list_item.dart';
import 'package:receipt_organizer/features/receipts/widgets/selection_toolbar.dart';
import 'package:receipt_organizer/core/services/bulk_operation_service.dart';

// Provider for receipts list
final receiptsListProvider = FutureProvider<List<Receipt>>((ref) async {
  final repository = ref.watch(receiptRepositoryProvider);
  return repository.getAllReceipts();
});

// Provider for filtered receipts
final filteredReceiptsProvider = Provider<List<Receipt>>((ref) {
  final receipts = ref.watch(receiptsListProvider).valueOrNull ?? [];
  final filterState = ref.watch(receiptFilterProvider);
  
  return receipts.where((receipt) {
    // Apply smart filters
    if (filterState.onlyProcessed && 
        (receipt.ocrResults?.overallConfidence ?? 0) < 0.9) {
      return false;
    }
    if (filterState.onlyHighConfidence && 
        (receipt.ocrResults?.overallConfidence ?? 0) < 0.9) {
      return false;
    }
    if (filterState.dateRange != null) {
      final receiptDate = receipt.date;
      if (receiptDate == null) return false;
      if (receiptDate.isBefore(filterState.dateRange!.start) ||
          receiptDate.isAfter(filterState.dateRange!.end)) {
        return false;
      }
    }
    if (!filterState.includeDeleted && receipt.isDeleted) {
      return false;
    }
    return true;
  }).toList();
});

// Filter state
class ReceiptFilterState {
  final bool onlyProcessed;
  final bool onlyHighConfidence;
  final DateTimeRange? dateRange;
  final bool includeDeleted;
  
  const ReceiptFilterState({
    this.onlyProcessed = false,
    this.onlyHighConfidence = false,
    this.dateRange,
    this.includeDeleted = false,
  });
  
  ReceiptFilterState copyWith({
    bool? onlyProcessed,
    bool? onlyHighConfidence,
    DateTimeRange? dateRange,
    bool? includeDeleted,
  }) {
    return ReceiptFilterState(
      onlyProcessed: onlyProcessed ?? this.onlyProcessed,
      onlyHighConfidence: onlyHighConfidence ?? this.onlyHighConfidence,
      dateRange: dateRange ?? this.dateRange,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }
}

final receiptFilterProvider = StateProvider<ReceiptFilterState>((ref) {
  return const ReceiptFilterState();
});

class ReceiptListScreen extends ConsumerStatefulWidget {
  const ReceiptListScreen({Key? key}) : super(key: key);
  
  @override
  ConsumerState<ReceiptListScreen> createState() => _ReceiptListScreenState();
}

class _ReceiptListScreenState extends ConsumerState<ReceiptListScreen> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _handleDelete() {
    final selectedReceipts = ref.read(selectedReceiptsProvider);
    if (selectedReceipts.isEmpty) return;
    
    // Show confirmation dialog (Task 5 - to be implemented)
    showDialog(
      context: context,
      builder: (context) => _buildDeleteConfirmationDialog(selectedReceipts),
    );
  }
  
  void _handleExport() {
    final selectedReceipts = ref.read(selectedReceiptsProvider);
    if (selectedReceipts.isEmpty) return;
    
    // Navigate to export screen with selected receipts
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export ${selectedReceipts.length} receipts'),
        action: SnackBarAction(
          label: 'Export',
          onPressed: () {
            // Navigate to export screen
          },
        ),
      ),
    );
  }
  
  void _handleSelectAll() {
    final receipts = ref.read(filteredReceiptsProvider);
    ref.read(selectionModeProvider.notifier).selectAll(receipts);
    
    // Announce for accessibility
    SemanticsService.announce(
      'Selected all ${receipts.length} receipts',
      Directionality.of(context),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final receiptsAsync = ref.watch(receiptsListProvider);
    final filteredReceipts = ref.watch(filteredReceiptsProvider);
    final selectionState = ref.watch(selectionModeProvider);
    final theme = Theme.of(context);
    
    // Update available receipts when list changes
    ref.listen(filteredReceiptsProvider, (previous, next) {
      ref.read(selectionModeProvider.notifier).updateAvailableReceipts(next);
    });
    
    return SelectionKeyboardHandler(
      onDelete: _handleDelete,
      onSelectAll: _handleSelectAll,
      child: Scaffold(
        appBar: AppBar(
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: selectionState.isSelectionMode
                ? Text(selectionState.selectionSummary)
                : const Text('Receipts'),
          ),
          actions: [
            // Filter button
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
              tooltip: 'Filter receipts',
            ),
            
            // More menu
            if (!selectionState.isSelectionMode)
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'select_all':
                      _handleSelectAll();
                      break;
                    case 'deleted':
                      ref.read(receiptFilterProvider.notifier).update(
                        (state) => state.copyWith(includeDeleted: !state.includeDeleted),
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'select_all',
                    child: ListTile(
                      leading: Icon(Icons.select_all),
                      title: Text('Select all'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'deleted',
                    child: ListTile(
                      leading: const Icon(Icons.delete_sweep),
                      title: Text(
                        ref.watch(receiptFilterProvider).includeDeleted
                            ? 'Hide deleted'
                            : 'Show deleted',
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: Column(
          children: [
            // Selection toolbar
            SelectionToolbar(
              onDelete: _handleDelete,
              onExport: _handleExport,
              onSelectAll: _handleSelectAll,
            ),
            
            // Receipt list
            Expanded(
              child: receiptsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load receipts',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: () => ref.refresh(receiptsListProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (_) {
                  if (filteredReceipts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No receipts found',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ref.watch(receiptFilterProvider).includeDeleted
                                ? 'Try adjusting your filters'
                                : 'Capture your first receipt to get started',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () => ref.refresh(receiptsListProvider.future),
                    child: Scrollbar(
                      controller: _scrollController,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: filteredReceipts.length,
                        itemBuilder: (context, index) {
                          final receipt = filteredReceipts[index];
                          return ReceiptListItem(
                            key: ValueKey(receipt.id),
                            receipt: receipt,
                            onTap: () => _navigateToReceipt(receipt),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: selectionState.isSelectionMode
            ? null
            : FloatingActionButton.extended(
                onPressed: _navigateToCapture,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture'),
                tooltip: 'Capture new receipt',
              ),
      ),
    );
  }
  
  void _navigateToReceipt(Receipt receipt) {
    // Navigate to receipt detail screen
    Navigator.of(context).pushNamed('/receipt/${receipt.id}');
  }
  
  void _navigateToCapture() {
    // Navigate to capture screen
    Navigator.of(context).pushNamed('/capture');
  }
  
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterBottomSheet(),
    );
  }
  
  Widget _buildDeleteConfirmationDialog(List<Receipt> receipts) {
    // This will be implemented in Task 5
    return AlertDialog(
      title: const Text('Delete Receipts'),
      content: Text('Delete ${receipts.length} receipts?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Perform deletion
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

class _FilterBottomSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(receiptFilterProvider);
    final theme = Theme.of(context);
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Receipts',
                  style: theme.textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Smart filters
            SwitchListTile(
              title: const Text('Only Processed'),
              subtitle: const Text('Show only receipts that have been processed'),
              value: filterState.onlyProcessed,
              onChanged: (value) {
                ref.read(receiptFilterProvider.notifier).update(
                  (state) => state.copyWith(onlyProcessed: value),
                );
              },
            ),
            
            SwitchListTile(
              title: const Text('High Confidence Only'),
              subtitle: const Text('Show only receipts with ≥90% confidence'),
              value: filterState.onlyHighConfidence,
              onChanged: (value) {
                ref.read(receiptFilterProvider.notifier).update(
                  (state) => state.copyWith(onlyHighConfidence: value),
                );
              },
            ),
            
            SwitchListTile(
              title: const Text('Include Deleted'),
              subtitle: const Text('Show receipts marked for deletion'),
              value: filterState.includeDeleted,
              onChanged: (value) {
                ref.read(receiptFilterProvider.notifier).update(
                  (state) => state.copyWith(includeDeleted: value),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Date range picker
            ListTile(
              title: const Text('Date Range'),
              subtitle: Text(
                filterState.dateRange != null
                    ? '${_formatDate(filterState.dateRange!.start)} - ${_formatDate(filterState.dateRange!.end)}'
                    : 'All dates',
              ),
              trailing: filterState.dateRange != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        ref.read(receiptFilterProvider.notifier).update(
                          (state) => state.copyWith(dateRange: null),
                        );
                      },
                    )
                  : null,
              onTap: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: filterState.dateRange,
                );
                if (range != null) {
                  ref.read(receiptFilterProvider.notifier).update(
                    (state) => state.copyWith(dateRange: range),
                  );
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // Apply button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}