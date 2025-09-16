import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:receipt_organizer/features/export/presentation/providers/export_provider.dart';
import 'package:receipt_organizer/domain/services/csv_export_service.dart';
import 'package:receipt_organizer/core/theme/app_theme.dart';

/// Bottom sheet that displays export history with options to re-download or share
class ExportHistorySheet extends ConsumerWidget {
  const ExportHistorySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const ExportHistorySheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final exportHistory = ref.watch(exportHistoryProvider);
    final selectedFormat = ref.watch(selectedFormatProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: theme.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Export History',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Filter chips
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: true,
                      onSelected: (_) {},
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'QuickBooks',
                      selected: false,
                      onSelected: (_) {
                        // TODO: Filter by format
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Xero',
                      selected: false,
                      onSelected: (_) {
                        // TODO: Filter by format
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Generic',
                      selected: false,
                      onSelected: (_) {
                        // TODO: Filter by format
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Export list
              Expanded(
                child: exportHistory.records.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: exportHistory.records.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final record = exportHistory.records[index];
                        return _ExportHistoryTile(record: record);
                      },
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No exports yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your export history will appear here',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool) onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: selected
          ? theme.colorScheme.onPrimaryContainer
          : theme.colorScheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _ExportHistoryTile extends StatelessWidget {
  final ExportRecord record;

  const _ExportHistoryTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');
    final formattedDate = dateFormat.format(record.exportDate);

    // Get format display name
    String formatName = record.format.name;
    formatName = formatName[0].toUpperCase() + formatName.substring(1);

    // Get format color
    Color formatColor;
    IconData formatIcon;
    switch (record.format) {
      case ExportFormat.quickbooks:
        formatColor = Colors.green;
        formatIcon = Icons.quick_contacts_dialer;
        break;
      case ExportFormat.xero:
        formatColor = Colors.blue;
        formatIcon = Icons.cloud_sync;
        break;
      default:
        formatColor = theme.colorScheme.primary;
        formatIcon = Icons.table_chart;
    }

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _showExportOptions(context, record),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Format icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: formatColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  formatIcon,
                  color: formatColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          formatName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: record.success
                              ? AppColors.success.withOpacity(0.1)
                              : theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            record.success ? 'Success' : 'Failed',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: record.success
                                ? AppColors.success
                                : theme.colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${record.receiptCount} receipts • $formattedDate',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (record.error != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        record.error!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // More button
              IconButton(
                onPressed: () => _showExportOptions(context, record),
                icon: const Icon(Icons.more_vert),
                style: IconButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context, ExportRecord record) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                record.fileName,
                style: theme.textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),

            // Options
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              enabled: record.success,
              onTap: () async {
                Navigator.pop(context);
                await _shareExport(context, record);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: const Text('Open file location'),
              enabled: record.success,
              onTap: () async {
                Navigator.pop(context);
                await _openFileLocation(context, record);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Re-export'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement re-export
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
              title: Text(
                'Delete from history',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement delete from history
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareExport(BuildContext context, ExportRecord record) async {
    try {
      final file = File(record.filePath);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(record.filePath)],
          subject: 'Receipt Export - ${record.format.name}',
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Export file not found'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _openFileLocation(BuildContext context, ExportRecord record) async {
    // Note: This is platform-specific
    // On mobile, we might just show the path or use a file manager intent
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File: ${record.filePath}'),
        action: SnackBarAction(
          label: 'Copy path',
          onPressed: () {
            // TODO: Copy to clipboard
          },
        ),
      ),
    );
  }
}