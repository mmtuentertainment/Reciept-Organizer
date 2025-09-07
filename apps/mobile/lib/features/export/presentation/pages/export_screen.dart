import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/date_range_picker.dart';
import 'package:receipt_organizer/features/export/presentation/providers/date_range_provider.dart';
import 'package:receipt_organizer/domain/services/csv_export_service.dart';
import 'package:receipt_organizer/core/theme/app_theme.dart';
import 'package:receipt_organizer/features/settings/providers/settings_provider.dart';
import 'package:intl/intl.dart';

/// Main export screen with date range selection and format options
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _exportFormats = ExportFormat.values;

  @override
  void initState() {
    super.initState();
    
    // Load saved export format preference
    final settings = ref.read(appSettingsProvider);
    final savedFormat = _exportFormats.firstWhere(
      (format) => format.name == settings.csvExportFormat,
      orElse: () => ExportFormat.quickbooks,
    );
    final initialIndex = _exportFormats.indexOf(savedFormat);
    
    _tabController = TabController(
      length: _exportFormats.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    
    // Save format preference when tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final selectedFormat = _exportFormats[_tabController.index];
      ref.read(appSettingsProvider.notifier).updateCsvFormat(selectedFormat.name);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getFormatDisplayName(ExportFormat format) {
    switch (format) {
      case ExportFormat.quickbooks:
        return 'QuickBooks';
      case ExportFormat.xero:
        return 'Xero';
      case ExportFormat.generic:
        return 'Generic CSV';
    }
  }

  String _getFormatDescription(ExportFormat format) {
    switch (format) {
      case ExportFormat.quickbooks:
        return 'Compatible with QuickBooks Desktop and Online';
      case ExportFormat.xero:
        return 'Compatible with Xero accounting software';
      case ExportFormat.generic:
        return 'Standard CSV with all available fields';
    }
  }

  IconData _getFormatIcon(ExportFormat format) {
    switch (format) {
      case ExportFormat.quickbooks:
        return Icons.account_balance;
      case ExportFormat.xero:
        return Icons.cloud_circle;
      case ExportFormat.generic:
        return Icons.table_chart;
    }
  }

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
        data: (state) => _buildContent(state),
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

    return Column(
      children: [
        // Date Range Picker Section
        Container(
          color: theme.colorScheme.surface,
          child: Column(
            children: [
              Padding(
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
                      _buildReceiptCountChip(state.receiptCount!),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
            ],
          ),
        ),

        // Format Selection Tabs
        Container(
          color: theme.colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            tabs: _exportFormats.map((format) {
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getFormatIcon(format), size: 18),
                    const SizedBox(width: 8),
                    Text(_getFormatDisplayName(format)),
                  ],
                ),
              );
            }).toList(),
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: theme.colorScheme.primary,
            indicatorWeight: 3,
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _exportFormats.map((format) {
              return _buildFormatContent(format, state);
            }).toList(),
          ),
        ),

        // Export Button
        _buildExportButton(state),
      ],
    );
  }

  Widget _buildReceiptCountChip(int count) {
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
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide.none,
    );
  }

  Widget _buildFormatContent(ExportFormat format, DateRangeState state) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Format Description
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getFormatIcon(format),
                        size: 24,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getFormatDisplayName(format),
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getFormatDescription(format),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Required Fields
          _buildRequiredFields(format),

          const SizedBox(height: 16),

          // Receipt Preview
          if (state.receiptCount != null && state.receiptCount! > 0) ...[
            _buildReceiptPreview(state),
          ],
        ],
      ),
    );
  }

  Widget _buildRequiredFields(ExportFormat format) {
    final theme = Theme.of(context);
    final csvService = CSVExportService();
    final requiredFields = csvService.getRequiredFields(format);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.checklist,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Required Fields',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: requiredFields.map((field) {
                return Chip(
                  label: Text(
                    field,
                    style: theme.textTheme.bodySmall,
                  ),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptPreview(DateRangeState state) {
    final theme = Theme.of(context);
    final dateFormatter = DateFormat('MMM d, yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.preview,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Date Range Preview',
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
                Text(
                  '${state.receiptCount} receipts',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${dateFormatter.format(state.dateRange.start)} - ${dateFormatter.format(state.dateRange.end)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            if (state.presetOption != DateRangePreset.custom) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    state.presetOption.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
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
            color: Colors.black.withOpacity(0.05),
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
    final format = _exportFormats[_tabController.index];
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export ${state.receiptCount} Receipts?'),
        content: Text(
          'You are about to export ${state.receiptCount} receipt${state.receiptCount == 1 ? '' : 's'} '
          'in ${_getFormatDisplayName(format)} format.',
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