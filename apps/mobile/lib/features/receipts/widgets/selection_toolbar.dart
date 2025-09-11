import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/receipts/providers/selection_mode_provider.dart';

class SelectionToolbar extends ConsumerWidget {
  final VoidCallback? onDelete;
  final VoidCallback? onExport;
  final VoidCallback? onSelectAll;
  
  const SelectionToolbar({
    Key? key,
    this.onDelete,
    this.onExport,
    this.onSelectAll,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(selectionModeProvider);
    final theme = Theme.of(context);
    
    if (!selectionState.isSelectionMode) {
      return const SizedBox.shrink();
    }
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selection count and actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  // Close button
                  Semantics(
                    label: 'Exit selection mode',
                    button: true,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ref.read(selectionModeProvider.notifier).exitSelectionMode();
                      },
                      tooltip: 'Exit selection mode',
                    ),
                  ),
                  
                  // Selection count
                  Expanded(
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        selectionState.selectionSummary,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ),
                  
                  // Select all button
                  if (onSelectAll != null)
                    Semantics(
                      label: 'Select all items',
                      button: true,
                      child: IconButton(
                        icon: const Icon(Icons.select_all),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onSelectAll!();
                        },
                        tooltip: 'Select all',
                      ),
                    ),
                  
                  // Clear selection button
                  if (selectionState.hasSelection)
                    Semantics(
                      label: 'Clear all selections',
                      button: true,
                      child: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ref.read(selectionModeProvider.notifier).clearSelection();
                        },
                        tooltip: 'Clear selection',
                      ),
                    ),
                ],
              ),
            ),
            
            // Action buttons
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Delete button
                  if (onDelete != null && selectionState.hasSelection)
                    _ActionButton(
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        onDelete!();
                      },
                      color: theme.colorScheme.error,
                      semanticLabel: 'Delete ${selectionState.selectedCount} selected items',
                    ),
                  
                  // Export button
                  if (onExport != null && selectionState.hasSelection)
                    _ActionButton(
                      icon: Icons.download_outlined,
                      label: 'Export',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onExport!();
                      },
                      color: theme.colorScheme.primary,
                      semanticLabel: 'Export ${selectionState.selectedCount} selected items',
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final String? semanticLabel;
  
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
    this.semanticLabel,
  });
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Keyboard shortcut handler for desktop/web
class SelectionKeyboardHandler extends ConsumerStatefulWidget {
  final Widget child;
  final VoidCallback? onDelete;
  final VoidCallback? onSelectAll;
  
  const SelectionKeyboardHandler({
    Key? key,
    required this.child,
    this.onDelete,
    this.onSelectAll,
  }) : super(key: key);
  
  @override
  ConsumerState<SelectionKeyboardHandler> createState() => _SelectionKeyboardHandlerState();
}

class _SelectionKeyboardHandlerState extends ConsumerState<SelectionKeyboardHandler> {
  late final FocusNode _focusNode;
  
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }
  
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
  
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;
    
    final isCtrlOrCmd = event.isControlPressed || event.isMetaPressed;
    
    // Ctrl/Cmd + A: Select all
    if (isCtrlOrCmd && event.logicalKey == LogicalKeyboardKey.keyA) {
      widget.onSelectAll?.call();
    }
    
    // Delete key: Delete selected
    if (event.logicalKey == LogicalKeyboardKey.delete) {
      final hasSelection = ref.read(hasSelectionProvider);
      if (hasSelection) {
        widget.onDelete?.call();
      }
    }
    
    // Escape: Exit selection mode
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      ref.read(selectionModeProvider.notifier).exitSelectionMode();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKeyEvent,
      child: widget.child,
    );
  }
}