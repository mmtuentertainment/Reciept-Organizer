import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/date_range_picker.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/format_selection.dart';
import 'package:receipt_organizer/features/export/presentation/providers/date_range_provider.dart';
import 'package:receipt_organizer/features/export/presentation/providers/export_format_provider.dart';
import 'package:receipt_organizer/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

/// Main export screen with date range selection and format options
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateRangeState = ref.watch(dateRangeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Receipts'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: dateRangeState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(error.toString()),
        data: (state) => Stack(
          children: [
            _buildContent(state),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildExportButton(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading receipts',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => ref.refresh(dateRangeNotifierProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(DateRangeState state) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Format Selection Section (Now First!)
          Container(
            color: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Format',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const FormatSelectionWidget(),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Date Range Picker Section
          Container(
            color: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Date Range',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const DateRangePickerWidget(),
                  if (state.receiptCount != null) ...[
                    const SizedBox(height: 12),
                    _buildReceiptCountChip(context, state.receiptCount!),
                  ],
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Export Preview Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildExportPreview(state),
          ),

          // Add some space before the button
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildReceiptCountChip(BuildContext context, int count) {
    final theme = Theme.of(context);
    final color = count > 0
        ? AppColors.success
        : theme.colorScheme.onSurfaceVariant;

    return Chip(
      avatar: Icon(
        count > 0 ? Icons.check_circle : Icons.info_outline,
        size: 18,
        color: color,
      ),
      label: Text(
        count > 0
            ? '$count receipt${count == 1 ? '' : 's'} found'
            : 'No receipts in this date range',
        style: TextStyle(color: color),
      ),
      backgroundColor: color.withAlpha((0.1 * 255).round()),
      side: BorderSide.none,
    );
  }

  Widget _buildExportPreview(DateRangeState state) {
    final theme = Theme.of(context);
    final dateFormatter = DateFormat('MMM d, yyyy');

    if (state.receiptCount == null || state.receiptCount == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No receipts found in the selected date range',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final selectedFormat = ref.watch(selectedExportFormatProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Preview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // Summary info
            _buildInfoRow(
              context,
              Icons.receipt_long,
              'Receipts',
              '${state.receiptCount} receipt${state.receiptCount == 1 ? '' : 's'}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Icons.calendar_month,
              'Date Range',
              '${dateFormatter.format(state.dateRange.start)} - ${dateFormatter.format(state.dateRange.end)}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Icons.table_chart,
              'Export Format',
              ref.read(exportFormatNotifierProvider.notifier).getFormatDisplayName(selectedFormat),
            ),
            if (state.presetOption != DateRangePreset.custom) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.schedule,
                'Preset',
                state.presetOption.label,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExportButton(DateRangeState state) {
    final theme = Theme.of(context);
    final hasReceipts = state.receiptCount != null && state.receiptCount! > 0;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: hasReceipts && !state.isLoading
                  ? () => _handleExport(state)
                  : null,
              icon: const Icon(Icons.download),
              label: Text(
                hasReceipts
                    ? 'Export ${state.receiptCount} Receipt${state.receiptCount == 1 ? '' : 's'}'
                    : 'No Receipts to Export',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: theme.textTheme.titleMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleExport(DateRangeState state) async {
    final format = ref.read(selectedExportFormatProvider);
    final formatNotifier = ref.read(exportFormatNotifierProvider.notifier);
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export ${state.receiptCount} Receipts?'),
        content: Text(
          'You are about to export ${state.receiptCount} receipt${state.receiptCount == 1 ? '' : 's'} '
          'in ${formatNotifier.getFormatDisplayName(format)} format.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Export'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show progress indicator
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Exporting receipts...'),
              ],
            ),
          ),
        ),
      ),
    );

    // TODO: Implement actual export logic
    await Future.delayed(const Duration(seconds: 2));

    // Close progress dialog
    if (!mounted) return;
    Navigator.pop(context);

    // Show success message
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('Successfully exported ${state.receiptCount} receipts'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Navigate to export location
          },
        ),
      ),
    );
  }
}