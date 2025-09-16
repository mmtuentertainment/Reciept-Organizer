import 'package:flutter/material.dart';
import 'package:receipt_organizer/features/export/services/export_format_validator.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/domain/services/csv_export_service.dart';
import 'package:receipt_organizer/features/export/presentation/providers/export_format_provider.dart';

/// Widget for selecting CSV export format with Material 3 SegmentedButton
/// Implements WCAG 2.1 AA accessibility requirements
class FormatSelectionWidget extends ConsumerWidget {
  const FormatSelectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatState = ref.watch(exportFormatNotifierProvider);
    final selectedFormat = formatState.selectedFormat;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Format selector with accessibility label
        Semantics(
          label: 'CSV export format selector',
          hint: 'Choose the format for exporting receipts',
          child: SegmentedButton<ExportFormat>(
            segments: ExportFormat.values.map((format) {
              return ButtonSegment<ExportFormat>(
                value: format,
                label: Text(_getFormatDisplayName(format)),
                icon: Icon(_getFormatIcon(format)),
                tooltip: _getFormatDescription(format),
                enabled: true,
              );
            }).toList(),
            selected: {selectedFormat},
            onSelectionChanged: formatState.isLoading
                ? null
                : (Set<ExportFormat> newSelection) async {
                    final newFormat = newSelection.first;
                    
                    // Update provider state
                    try {
                      await ref
                          .read(exportFormatNotifierProvider.notifier)
                          .updateFormat(newFormat);
                      
                      // Announce selection change to screen readers
                      if (context.mounted) {
                        SemanticsService.announce(
                          'Selected ${_getFormatDisplayName(newFormat)} format',
                          Directionality.of(context),
                        );
                      }
                    } catch (e) {
                      // Show error if format change fails
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update format: $e'),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                      }
                    }
                  },
            showSelectedIcon: true,
            style: ButtonStyle(
              textStyle: WidgetStateProperty.all(
                theme.textTheme.labelLarge,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Format description card
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest.withAlpha((0.3 * 255).round()),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getFormatIcon(selectedFormat),
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getFormatDisplayName(selectedFormat),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Description with accessibility
                Semantics(
                  label: 'Format description',
                  child: Text(
                    _getFormatDescription(selectedFormat),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Required fields with accessibility
                Semantics(
                  label: 'Required fields for ${_getFormatDisplayName(selectedFormat)}',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _getRequiredFields(selectedFormat).map((field) {
                      return Chip(
                        label: Text(
                          field,
                          style: theme.textTheme.labelSmall,
                        ),
                        backgroundColor: theme.colorScheme.primaryContainer,
                        side: BorderSide.none,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Additional format information
        const SizedBox(height: 12),
        _buildFormatInfoRow(
          context,
          Icons.calendar_today,
          'Date format',
          _getDateFormat(selectedFormat),
        ),
        const SizedBox(height: 8),
        _buildFormatInfoRow(
          context,
          Icons.attach_money,
          'Amount format',
          _getAmountFormat(selectedFormat),
        ),
        const SizedBox(height: 8),
        _buildFormatInfoRow(
          context,
          Icons.security,
          'Security',
          'CSV injection prevention enabled',
        ),
      ],
    );
  }

  Widget _buildFormatInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    
    return Semantics(
      label: '$label: $value',
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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
        return 'Compatible with QuickBooks Desktop and Online. Uses MM/dd/yyyy date format.';
      case ExportFormat.xero:
        return 'Compatible with Xero accounting software. Uses dd/MM/yyyy date format.';
      case ExportFormat.generic:
        return 'Standard CSV format with all available fields. Uses YYYY-MM-DD date format.';
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

  List<String> _getRequiredFields(ExportFormat format) {
    switch (format) {
      case ExportFormat.quickbooks:
        return ['Date', 'Amount', 'Payee', 'Category'];
      case ExportFormat.xero:
        return ['Date', 'Amount', 'Payee', 'Account Code'];
      case ExportFormat.generic:
        return ['Date', 'Amount', 'Merchant'];
    }
  }

  String _getDateFormat(ExportFormat format) {
    switch (format) {
      case ExportFormat.quickbooks:
        return 'MM/dd/yyyy';
      case ExportFormat.xero:
        return 'dd/MM/yyyy';
      case ExportFormat.generic:
        return 'YYYY-MM-DD';
    }
  }

  String _getAmountFormat(ExportFormat format) {
    // All formats use the same amount format per requirements
    return '0.00 (two decimal places)';
  }
}