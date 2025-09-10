import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/date_range_picker.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/format_selection.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/csv_preview_table.dart';
import 'package:receipt_organizer/features/export/presentation/providers/date_range_provider.dart';
import 'package:receipt_organizer/features/export/presentation/providers/export_format_provider.dart';
import 'package:receipt_organizer/features/export/presentation/providers/csv_preview_provider.dart';
import 'package:receipt_organizer/features/export/domain/services/csv_preview_service.dart';
import 'package:receipt_organizer/core/theme/app_theme.dart';

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

  Future<void> _handleExport(DateRangeState state) async {
    final format = ref.read(selectedExportFormatProvider);
    final formatNotifier = ref.read(exportFormatNotifierProvider.notifier);
    final previewState = ref.read(csvPreviewProvider).value;
    
    // Double-check for critical warnings (SEC-001)
    if (previewState != null && previewState.hasCriticalWarnings) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.security, color: Colors.red, size: 48),
          title: const Text('Security Risk Detected'),
          content: const Text(
            'Cannot export due to potential CSV injection attacks detected in the data. '
            'Please review and fix the highlighted security issues before exporting.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Understood'),
            ),
          ],
        ),
      );
      return;
    }
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export ${state.receiptCount} Receipts?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to export ${state.receiptCount} receipt${state.receiptCount == 1 ? '' : 's'} '
              'in ${formatNotifier.getFormatDisplayName(format)} format.',
            ),
            if (previewState != null && previewState.hasWarnings) ...[
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
                        '${previewState.validationWarnings.length} validation warnings present',
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

    // TODO: Implement actual export logic using CSVExportService
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