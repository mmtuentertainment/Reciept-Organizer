import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/export/presentation/providers/export_provider.dart';
import 'package:receipt_organizer/core/theme/app_theme.dart';

/// Dialog that displays export progress with real-time updates
class ExportProgressDialog extends ConsumerWidget {
  final int totalReceipts;
  final String formatName;

  const ExportProgressDialog({
    super.key,
    required this.totalReceipts,
    required this.formatName,
  });

  static Future<void> show({
    required BuildContext context,
    required int totalReceipts,
    required String formatName,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ExportProgressDialog(
        totalReceipts: totalReceipts,
        formatName: formatName,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final exportState = ref.watch(exportProvider);
    final progress = exportState.progress;
    final isExporting = exportState.isExporting;
    final error = exportState.error;

    // Calculate step based on progress
    String currentStep = _getProgressStep(progress);
    IconData stepIcon = _getStepIcon(progress);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: error != null
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    error != null ? Icons.error_outline : stepIcon,
                    size: 24,
                    color: error != null
                      ? theme.colorScheme.onErrorContainer
                      : theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        error != null ? 'Export Failed' : 'Exporting Receipts',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        error != null
                          ? 'An error occurred during export'
                          : '$totalReceipts receipts • $formatName format',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Error message or progress content
            if (error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.error.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        error,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              // Progress indicator
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress > 0 ? progress : null,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0
                      ? AppColors.success
                      : theme.colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Progress percentage and step
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentStep,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Detailed steps
              _buildProgressSteps(context, progress),
            ],

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (error != null || progress >= 1.0) ...[
                  if (progress >= 1.0 && error == null) ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        // Share the exported file
                        ref.read(exportProvider.notifier).shareExportedFile();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      progress >= 1.0 && error == null ? 'Done' : 'Close',
                    ),
                  ),
                ] else ...[
                  TextButton(
                    onPressed: isExporting
                      ? () {
                          // TODO: Implement cancel export
                          Navigator.of(context).pop();
                        }
                      : null,
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getProgressStep(double progress) {
    if (progress < 0.2) return 'Validating receipts...';
    if (progress < 0.3) return 'Creating batches...';
    if (progress < 0.6) return 'Generating CSV content...';
    if (progress < 0.7) return 'Preparing export directory...';
    if (progress < 0.8) return 'Creating file name...';
    if (progress < 0.9) return 'Writing file...';
    if (progress < 1.0) return 'Finalizing export...';
    return 'Export complete!';
  }

  IconData _getStepIcon(double progress) {
    if (progress < 0.2) return Icons.fact_check;
    if (progress < 0.6) return Icons.transform;
    if (progress < 0.9) return Icons.save_alt;
    return Icons.check_circle;
  }

  Widget _buildProgressSteps(BuildContext context, double progress) {
    final theme = Theme.of(context);

    final steps = [
      _ProgressStep('Validation', 0.2, Icons.fact_check),
      _ProgressStep('Processing', 0.6, Icons.transform),
      _ProgressStep('Saving', 0.9, Icons.save_alt),
      _ProgressStep('Complete', 1.0, Icons.check_circle),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: steps.map((step) {
        final isActive = progress >= step.threshold;
        final isCurrent = progress >= (step.threshold - 0.2) &&
                         progress < step.threshold;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: isCurrent
                  ? Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    )
                  : null,
              ),
              child: Icon(
                step.icon,
                size: 16,
                color: isActive
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              step.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isActive
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _ProgressStep {
  final String label;
  final double threshold;
  final IconData icon;

  const _ProgressStep(this.label, this.threshold, this.icon);
}