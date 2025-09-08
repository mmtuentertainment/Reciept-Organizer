import 'package:flutter/material.dart';

/// Widget for displaying receipt notes in read-only format.
/// 
/// Shows the full notes content with appropriate styling and an
/// empty state when no notes are present.
class ReceiptNotesDisplay extends StatelessWidget {
  /// The notes text to display.
  final String? notes;
  
  /// Whether to show a border around the notes.
  final bool showBorder;
  
  /// Maximum number of lines to show (null for unlimited).
  final int? maxLines;

  const ReceiptNotesDisplay({
    Key? key,
    required this.notes,
    this.showBorder = true,
    this.maxLines,
  }) ;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasNotes = notes != null && notes!.isNotEmpty;
    
    if (!hasNotes && !showBorder) {
      return _buildEmptyState(context);
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: showBorder
          ? BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withAlpha((0.5 * 255).round()),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
              color: theme.colorScheme.surface,
            )
          : null,
      child: hasNotes
          ? _buildNotesContent(context)
          : _buildEmptyState(context),
    );
  }

  Widget _buildNotesContent(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.note,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'Notes',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          notes!,
          style: theme.textTheme.bodyMedium,
          maxLines: maxLines,
          overflow: maxLines != null ? TextOverflow.ellipsis : null,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          Icons.note_add,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant.withAlpha((0.5 * 255).round()),
        ),
        const SizedBox(width: 8),
        Text(
          'No notes added',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withAlpha((0.5 * 255).round()),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}