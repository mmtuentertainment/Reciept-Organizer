import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/core/models/receipt.dart';
import 'package:receipt_organizer/core/services/undo_service.dart';

class UndoSnackBar extends ConsumerStatefulWidget {
  final List<Receipt> deletedReceipts;
  final VoidCallback onUndo;
  final Duration duration;
  final bool isPermanent;
  
  const UndoSnackBar({
    Key? key,
    required this.deletedReceipts,
    required this.onUndo,
    this.duration = const Duration(seconds: 10),
    this.isPermanent = false,
  }) : super(key: key);
  
  static void show({
    required BuildContext context,
    required List<Receipt> deletedReceipts,
    required VoidCallback onUndo,
    Duration duration = const Duration(seconds: 10),
    bool isPermanent = false,
  }) {
    // Remove any existing snackbar
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    // Show new snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _UndoSnackBarContent(
          deletedReceipts: deletedReceipts,
          onUndo: onUndo,
          isPermanent: isPermanent,
        ),
        duration: isPermanent ? const Duration(seconds: 5) : duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
      ),
    );
    
    // Announce for accessibility
    SemanticsService.announce(
      '${deletedReceipts.length} receipts deleted. ${isPermanent ? '' : 'Press undo to restore.'}',
      Directionality.of(context),
    );
  }
  
  @override
  ConsumerState<UndoSnackBar> createState() => _UndoSnackBarState();
}

class _UndoSnackBarState extends ConsumerState<UndoSnackBar> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _countdownTimer;
  int _remainingSeconds = 0;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    if (!widget.isPermanent) {
      _remainingSeconds = widget.duration.inSeconds;
      _animationController.forward();
      
      // Update countdown every second
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _remainingSeconds--;
          if (_remainingSeconds <= 0) {
            timer.cancel();
          }
        });
      });
    }
  }
  
  @override
  void dispose() {
    _countdownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return _UndoSnackBarContent(
      deletedReceipts: widget.deletedReceipts,
      onUndo: widget.onUndo,
      isPermanent: widget.isPermanent,
      remainingSeconds: _remainingSeconds,
      animationController: _animationController,
    );
  }
}

class _UndoSnackBarContent extends StatelessWidget {
  final List<Receipt> deletedReceipts;
  final VoidCallback onUndo;
  final bool isPermanent;
  final int? remainingSeconds;
  final AnimationController? animationController;
  
  const _UndoSnackBarContent({
    required this.deletedReceipts,
    required this.onUndo,
    required this.isPermanent,
    this.remainingSeconds,
    this.animationController,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? theme.colorScheme.surface 
            : theme.colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress indicator
          if (!isPermanent && animationController != null)
            AnimatedBuilder(
              animation: animationController!,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: 1 - animationController!.value,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary.withOpacity(0.3),
                  ),
                  minHeight: 2,
                );
              },
            ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Icon
                Icon(
                  isPermanent ? Icons.delete_forever : Icons.delete_outline,
                  color: isDark 
                      ? theme.colorScheme.onSurface 
                      : theme.colorScheme.onInverseSurface,
                ),
                
                const SizedBox(width: 12),
                
                // Message
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _buildMessage(),
                        style: TextStyle(
                          color: isDark 
                              ? theme.colorScheme.onSurface 
                              : theme.colorScheme.onInverseSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (!isPermanent && remainingSeconds != null && remainingSeconds! > 0)
                        Text(
                          'Undo available for $remainingSeconds seconds',
                          style: TextStyle(
                            color: (isDark 
                                ? theme.colorScheme.onSurface 
                                : theme.colorScheme.onInverseSurface)
                                .withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Undo button
                if (!isPermanent)
                  TextButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      onUndo();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    ),
                    child: const Text('UNDO'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _buildMessage() {
    final count = deletedReceipts.length;
    
    if (isPermanent) {
      return count == 1
          ? 'Receipt permanently deleted'
          : '$count receipts permanently deleted';
    } else {
      return count == 1
          ? 'Receipt deleted'
          : '$count receipts deleted';
    }
  }
}

// Deleted items recovery screen
class DeletedItemsScreen extends ConsumerWidget {
  const DeletedItemsScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Get deleted receipts
    final deletedReceiptsAsync = ref.watch(deletedReceiptsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Deleted'),
        actions: [
          deletedReceiptsAsync.when(
            data: (receipts) => receipts.isNotEmpty
                ? TextButton(
                    onPressed: () => _restoreAll(context, ref, receipts),
                    child: const Text('Restore All'),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: deletedReceiptsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (deletedReceipts) => deletedReceipts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recently deleted items',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Deleted receipts appear here for 7 days',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: deletedReceipts.length,
              itemBuilder: (context, index) {
                final receipt = deletedReceipts[index];
                final daysRemaining = _calculateDaysRemaining(receipt.deletedAt!);
                
                return Dismissible(
                  key: ValueKey(receipt.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    color: theme.colorScheme.primary,
                    child: const Icon(
                      Icons.restore,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    await _restoreReceipt(context, ref, receipt);
                    return false; // Don't actually dismiss, let state update handle it
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.errorContainer,
                      child: Icon(
                        Icons.receipt,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    title: Text(receipt.merchantName ?? 'Unknown Merchant'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (receipt.date != null)
                          Text('Date: ${_formatDate(receipt.date!)}'),
                        Text(
                          'Deleted ${_formatDeletedTime(receipt.deletedAt!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.error,
                          ),
                        ),
                        if (daysRemaining > 0)
                          Text(
                            '$daysRemaining days until permanent deletion',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          )
                        else
                          Text(
                            'Will be permanently deleted soon',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.restore),
                      onPressed: () => _restoreReceipt(context, ref, receipt),
                      tooltip: 'Restore receipt',
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
  
  int _calculateDaysRemaining(DateTime deletedAt) {
    final now = DateTime.now();
    final deleteDate = deletedAt.add(const Duration(days: 7));
    final difference = deleteDate.difference(now);
    return difference.inDays;
  }
  
  String _formatDeletedTime(DateTime deletedAt) {
    final now = DateTime.now();
    final difference = now.difference(deletedAt);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
  
  Future<void> _restoreReceipt(
    BuildContext context,
    WidgetRef ref,
    Receipt receipt,
  ) async {
    HapticFeedback.mediumImpact();
    
    try {
      final undoService = ref.read(undoServiceProvider('current_user'));
      await undoService.cancelScheduledDeletion([receipt.id]);
      
      // Show confirmation
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restored ${receipt.merchantName ?? 'receipt'}'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                // Navigate to receipt
                Navigator.of(context).pushNamed('/receipt/${receipt.id}');
              },
            ),
          ),
        );
      }
      
      // Refresh the list
      ref.invalidate(deletedReceiptsProvider);
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restore: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
  
  Future<void> _restoreAll(
    BuildContext context,
    WidgetRef ref,
    List<Receipt> receipts,
  ) async {
    HapticFeedback.heavyImpact();
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore All?'),
        content: Text('Restore ${receipts.length} deleted receipts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restore All'),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    try {
      final undoService = ref.read(undoServiceProvider('current_user'));
      final ids = receipts.map((r) => r.id).toList();
      await undoService.cancelScheduledDeletion(ids);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restored ${receipts.length} receipts'),
          ),
        );
        
        // Go back to main list
        Navigator.of(context).pop();
      }
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restore: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

// Provider for deleted receipts
final deletedReceiptsProvider = FutureProvider<List<Receipt>>((ref) async {
  final repository = ref.watch(receiptRepositoryProvider);
  final allReceipts = await repository.getAllReceipts(excludeDeleted: false);
  return allReceipts.where((r) => r.isDeleted).toList()
    ..sort((a, b) => b.deletedAt!.compareTo(a.deletedAt!));
});

// Stub providers (would be defined elsewhere)
final receiptRepositoryProvider = Provider<dynamic>((ref) {
  throw UnimplementedError('Repository provider needs to be implemented');
});

final undoServiceProvider = Provider.family<UndoService, String>((ref, userId) {
  throw UnimplementedError('Undo service provider needs to be implemented');
});