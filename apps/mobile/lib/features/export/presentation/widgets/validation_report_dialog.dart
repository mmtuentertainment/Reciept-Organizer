import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/export_validator.dart';

/// Dialog showing validation results before export
class ValidationReportDialog extends ConsumerWidget {
  final ValidationResult validationResult;
  final VoidCallback onConfirmExport;
  final VoidCallback onCancel;
  
  const ValidationReportDialog({
    super.key,
    required this.validationResult,
    required this.onConfirmExport,
    required this.onCancel,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getOverallIcon(),
            color: _getOverallColor(colorScheme),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getTitle(),
              style: theme.textTheme.headlineSmall,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary section
            _buildSummaryCard(context),
            
            const SizedBox(height: 16),
            
            // Errors section
            if (validationResult.errors.isNotEmpty) ...[
              _buildIssueSection(
                context,
                'Errors (Must Fix)',
                validationResult.errors,
                Icons.error,
                colorScheme.error,
              ),
              const SizedBox(height: 12),
            ],
            
            // Warnings section
            if (validationResult.warnings.isNotEmpty) ...[
              _buildIssueSection(
                context,
                'Warnings (Review Recommended)',
                validationResult.warnings,
                Icons.warning,
                colorScheme.tertiary,
              ),
              const SizedBox(height: 12),
            ],
            
            // Info section
            if (validationResult.info.isNotEmpty) ...[
              _buildIssueSection(
                context,
                'Information',
                validationResult.info,
                Icons.info,
                colorScheme.primary,
              ),
            ],
            
            // Security notice
            if (_hasSecurityIssues()) ...[
              const SizedBox(height: 16),
              _buildSecurityNotice(context),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        if (validationResult.canExport)
          FilledButton.icon(
            onPressed: onConfirmExport,
            icon: Icon(
              validationResult.warnings.isEmpty
                  ? Icons.check_circle
                  : Icons.warning,
            ),
            label: Text(
              validationResult.warnings.isEmpty
                  ? 'Export'
                  : 'Export Anyway',
            ),
          ),
      ],
    );
  }
  
  Widget _buildSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    final metadata = validationResult.metadata;
    final receiptCount = metadata['receiptCount'] ?? 0;
    final format = metadata['format'] ?? 'Unknown';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '$receiptCount Receipts',
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                Chip(
                  label: Text(format.toString().split('.').last.toUpperCase()),
                  avatar: const Icon(Icons.file_present, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _calculateHealthScore(),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getHealthColor(theme.colorScheme),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Health Score: ${(_calculateHealthScore() * 100).toInt()}%',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildIssueSection(
    BuildContext context,
    String title,
    List<ValidationIssue> issues,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${issues.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...issues.take(5).map((issue) => _buildIssueItem(context, issue)),
        if (issues.length > 5)
          Padding(
            padding: const EdgeInsets.only(left: 28, top: 4),
            child: Text(
              '... and ${issues.length - 5} more',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildIssueItem(BuildContext context, ValidationIssue issue) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(left: 28, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            issue.message,
            style: theme.textTheme.bodyMedium,
          ),
          if (issue.suggestedFix != null)
            Text(
              'Fix: ${issue.suggestedFix}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildSecurityNotice(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.error),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Security Warning',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'CSV injection vulnerabilities detected. These have been automatically sanitized but please review.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getOverallIcon() {
    if (!validationResult.isValid) return Icons.error;
    if (validationResult.warnings.isNotEmpty) return Icons.warning;
    return Icons.check_circle;
  }
  
  Color _getOverallColor(ColorScheme colorScheme) {
    if (!validationResult.isValid) return colorScheme.error;
    if (validationResult.warnings.isNotEmpty) return colorScheme.tertiary;
    return colorScheme.primary;
  }
  
  String _getTitle() {
    if (!validationResult.isValid) {
      return 'Export Blocked - Issues Found';
    }
    if (validationResult.warnings.isNotEmpty) {
      return 'Export Ready with Warnings';
    }
    return 'Export Ready';
  }
  
  double _calculateHealthScore() {
    final totalIssues = validationResult.errors.length * 3 +
        validationResult.warnings.length * 2 +
        validationResult.info.length;
    
    if (totalIssues == 0) return 1.0;
    
    // Decrease score based on issue count
    final score = 1.0 - (totalIssues * 0.05);
    return score.clamp(0.0, 1.0);
  }
  
  Color _getHealthColor(ColorScheme colorScheme) {
    final score = _calculateHealthScore();
    if (score > 0.8) return colorScheme.primary;
    if (score > 0.6) return colorScheme.tertiary;
    return colorScheme.error;
  }
  
  bool _hasSecurityIssues() {
    return validationResult.errors.any((e) => e.id.startsWith('SEC_')) ||
        validationResult.warnings.any((e) => e.id.startsWith('SEC_'));
  }
}

/// Helper function to show the validation dialog
Future<bool> showValidationReportDialog({
  required BuildContext context,
  required ValidationResult validationResult,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ValidationReportDialog(
      validationResult: validationResult,
      onConfirmExport: () => Navigator.of(context).pop(true),
      onCancel: () => Navigator.of(context).pop(false),
    ),
  );
  
  return result ?? false;
}