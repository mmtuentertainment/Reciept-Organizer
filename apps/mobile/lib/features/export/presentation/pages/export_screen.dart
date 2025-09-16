import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/date_range_picker.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/format_selection.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/csv_preview_table.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/export_progress_dialog.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/export_history_sheet.dart';
import 'package:receipt_organizer/features/export/presentation/providers/date_range_provider.dart';
import 'package:receipt_organizer/features/export/presentation/providers/export_format_provider.dart';
import 'package:receipt_organizer/features/export/presentation/providers/csv_preview_provider.dart';
import 'package:receipt_organizer/features/export/presentation/providers/export_provider.dart';
import 'package:receipt_organizer/features/export/domain/services/csv_preview_service.dart';
import 'package:receipt_organizer/core/theme/app_theme.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/validation_report_dialog.dart';
import 'package:receipt_organizer/features/export/presentation/providers/export_validation_provider.dart';
import 'package:receipt_organizer/features/export/domain/export_validator.dart' hide ExportFormat, ValidationResult;
import 'package:receipt_organizer/core/models/receipt.dart';
import 'package:receipt_organizer/core/providers/repository_providers.dart';
import 'package:receipt_organizer/features/export/domain/receipt_converter.dart';
import 'package:receipt_organizer/domain/services/csv_export_service.dart';

/// Main export screen with date range selection, format options, and CSV preview
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
        actions: [
          // Export history button
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Export History',
            onPressed: () => ExportHistorySheet.show(context),
          ),
          // Refresh preview button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Preview',
            onPressed: () {
              ref.read(csvPreviewProvider.notifier).refresh();
            },
          ),
        ],
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

          // CSV Preview Section - ENHANCED WITH ACTUAL PREVIEW TABLE
          Container(
            color: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CSV Preview',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Performance indicator
                      Consumer(
                        builder: (context, ref, _) {
                          final performanceDuration = ref.watch(previewPerformanceProvider);
                          if (performanceDuration != null) {
                            final isWithinTarget = performanceDuration.inMilliseconds <= 100;
                            return Chip(
                              avatar: Icon(
                                isWithinTarget ? Icons.speed : Icons.warning_amber,
                                size: 16,
                                color: isWithinTarget ? AppColors.success : theme.colorScheme.error,
                              ),
                              label: Text(
                                '${performanceDuration.inMilliseconds}ms',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isWithinTarget ? AppColors.success : theme.colorScheme.error,
                                ),
                              ),
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // CSV Preview Table Widget
                  _buildCSVPreview(),
                ],
              ),
            ),
          ),

          // Add some space before the button
          const SizedBox(height: 100),
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

  Widget _buildCSVPreview() {
    final previewAsync = ref.watch(csvPreviewProvider);
    
    return previewAsync.when(
      loading: () => const CSVPreviewTable(
        previewRows: [],
        totalCount: 0,
        isLoading: true,
      ),
      error: (error, _) => CSVPreviewTable(
        previewRows: const [],
        totalCount: 0,
        error: error.toString(),
      ),
      data: (previewState) {
        if (previewState.isLoading) {
          return const CSVPreviewTable(
            previewRows: [],
            totalCount: 0,
            isLoading: true,
          );
        }
        
        if (previewState.error != null) {
          return CSVPreviewTable(
            previewRows: const [],
            totalCount: 0,
            error: previewState.error,
          );
        }
        
        return CSVPreviewTable(
          previewRows: previewState.previewData,
          totalCount: previewState.totalCount,
          warnings: previewState.validationWarnings,
        );
      },
    );
  }

  Widget _buildExportButton(DateRangeState state) {
    final theme = Theme.of(context);
    final canExport = ref.watch(canExportProvider);
    final previewAsync = ref.watch(csvPreviewProvider);
    
    // Determine button state and message
    String buttonText = 'Preparing Export...';
    bool isEnabled = false;
    Color? buttonColor;
    
    previewAsync.whenData((preview) {
      if (preview.hasCriticalWarnings) {
        buttonText = 'Export Blocked - Critical Security Issues';
        buttonColor = theme.colorScheme.error;
        isEnabled = false;
      } else if (state.receiptCount == null || state.receiptCount == 0) {
        buttonText = 'No Receipts to Export';
        isEnabled = false;
      } else if (preview.isLoading) {
        buttonText = 'Generating Preview...';
        isEnabled = false;
      } else if (canExport) {
        buttonText = 'Export ${state.receiptCount} Receipt${state.receiptCount == 1 ? '' : 's'}';
        isEnabled = true;
      } else {
        buttonText = 'Cannot Export - Fix Validation Issues';
        buttonColor = theme.colorScheme.error;
        isEnabled = false;
      }
    });

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning summary if present
              if (previewAsync.hasValue) ...[
                _buildValidationSummary(previewAsync.value!),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isEnabled && !state.isLoading
                      ? () => _handleExport(state)
                      : null,
                  icon: Icon(
                    isEnabled ? Icons.download : Icons.block,
                  ),
                  label: Text(buttonText),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: theme.textTheme.titleMedium,
                    backgroundColor: buttonColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValidationSummary(CSVPreviewState preview) {
    if (!preview.hasWarnings) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    final warningSummary = ref.read(csvPreviewProvider.notifier).getWarningSummary();
    
    final criticalCount = warningSummary[WarningSeverity.critical] ?? 0;
    final highCount = warningSummary[WarningSeverity.high] ?? 0;
    final mediumCount = warningSummary[WarningSeverity.medium] ?? 0;
    
    if (criticalCount == 0 && highCount == 0 && mediumCount == 0) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: criticalCount > 0 
          ? theme.colorScheme.errorContainer 
          : theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: criticalCount > 0
                  ? theme.colorScheme.onErrorContainer
                  : theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'Validation Issues Found',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: criticalCount > 0
                    ? theme.colorScheme.onErrorContainer
                    : theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (criticalCount > 0) ...[
            Text(
              '• $criticalCount Critical security issues (MUST FIX)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (highCount > 0) ...[
            Text(
              '• $highCount High priority issues',
              style: theme.textTheme.bodySmall?.copyWith(
                color: criticalCount > 0
                  ? theme.colorScheme.onErrorContainer
                  : theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ],
          if (mediumCount > 0) ...[
            Text(
              '• $mediumCount Medium priority issues',
              style: theme.textTheme.bodySmall?.copyWith(
                color: criticalCount > 0
                  ? theme.colorScheme.onErrorContainer
                  : theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }

  ExportFormat _getExportFormat(String format) {
    switch (format.toLowerCase()) {
      case 'quickbooks':
      case 'qb':
        return ExportFormat.quickbooks;
      case 'xero':
        return ExportFormat.xero;
      default:
        return ExportFormat.generic;
    }
  }
  
  Future<void> _handleExport(DateRangeState state) async {
    final format = ref.read(selectedExportFormatProvider);
    final exportNotifier = ref.read(exportProvider.notifier);
    final formatNotifier = ref.read(exportFormatNotifierProvider.notifier);
    final previewState = ref.read(csvPreviewProvider).value;

    // Set date range in export provider
    if (state.dateRange.start != null && state.dateRange.end != null) {
      exportNotifier.setDateRange(state.dateRange.start, state.dateRange.end);
    }

    // Convert format to ExportFormat enum
    final exportFormat = _getExportFormat(format.toString());

    // Set export format
    exportNotifier.setExportFormat(exportFormat);

    // Wait for receipts to load
    await Future.delayed(const Duration(milliseconds: 500));

    final exportState = ref.read(exportProvider);

    // Check if we have receipts
    if (exportState.selectedReceipts.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No receipts found in the selected date range that are ready for export'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Show validation if there are issues
    if (exportState.validationResult != null &&
        (exportState.validationResult!.errors.isNotEmpty ||
         exportState.validationResult!.warnings.isNotEmpty)) {

      if (!mounted) return;
      final shouldExport = await showValidationReportDialog(
        context: context,
        validationResult: exportState.validationResult!,
        exportFormat: format.toString(),
      );

      if (!shouldExport) {
        return;
      }
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export ${exportState.selectedReceipts.length} Receipts?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to export ${exportState.selectedReceipts.length} receipt${exportState.selectedReceipts.length == 1 ? '' : 's'} '
              'in ${formatNotifier.getFormatDisplayName(format)} format.',
            ),
            if (exportState.validationResult != null &&
                exportState.validationResult!.warnings.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${exportState.validationResult!.warnings.length} validation warnings present',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
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

    // Show progress dialog
    if (!mounted) return;
    await ExportProgressDialog.show(
      context: context,
      totalReceipts: exportState.selectedReceipts.length,
      formatName: formatNotifier.getFormatDisplayName(format),
    );

    // Start the export
    final filename = 'receipts_${exportFormat.name}_${DateTime.now().millisecondsSinceEpoch}.csv';

    // Listen for export completion in the background
    ref.listen<ExportState>(
      exportProvider,
      (previous, next) {
        // Check if export just completed
        if (previous?.isExporting == true && !next.isExporting) {
          // Close progress dialog if still showing
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          // Handle export result with enhanced notifications
          if (next.lastExportResult != null && next.lastExportResult!.success) {
            // Show success notification
            if (mounted) {
              _showSuccessNotification(
                context,
                next.lastExportResult!.recordCount ?? next.selectedReceipts.length,
                next.lastExportResult!.fileName ?? 'receipts.csv',
                exportNotifier,
              );
            }
          } else if (next.error != null) {
            // Show error notification
            if (mounted) {
              _showErrorNotification(context, next.error!);
            }
          }
        }
      },
    );

    // Start the export
    await exportNotifier.exportReceipts(customFileName: filename);
  }

  // Enhanced notification for successful export
  void _showSuccessNotification(
    BuildContext context,
    int receiptCount,
    String fileName,
    ExportNotifier exportNotifier,
  ) {
    final theme = Theme.of(context);

    // Provide haptic feedback for success
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Export Complete!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$receiptCount receipts • $fileName',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Share',
          textColor: Colors.white,
          onPressed: () => exportNotifier.shareExportedFile(),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // Enhanced notification for export errors
  void _showErrorNotification(BuildContext context, String error) {
    final theme = Theme.of(context);

    // Provide haptic feedback for error
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Export Failed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            ref.read(exportProvider.notifier).retryLastExport();
          },
        ),
        duration: const Duration(seconds: 6),
      ),
    );
  }
}