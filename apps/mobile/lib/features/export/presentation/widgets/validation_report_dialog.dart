import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/export_validator.dart';
import '../providers/export_validation_provider.dart';

/// Dialog showing validation results before export
class ValidationReportDialog extends ConsumerStatefulWidget {
  final ValidationResult validationResult;
  final VoidCallback onConfirmExport;
  final VoidCallback onCancel;
  final VoidCallback? onFixIssues;
  final String? exportFormat;
  
  const ValidationReportDialog({
    super.key,
    required this.validationResult,
    required this.onConfirmExport,
    required this.onCancel,
    this.onFixIssues,
    this.exportFormat,
  });
  
  @override
  ConsumerState<ValidationReportDialog> createState() => _ValidationReportDialogState();
}

class _ValidationReportDialogState extends ConsumerState<ValidationReportDialog> {
  bool _isValidating = false;
  
  @override
  void initState() {
    super.initState();
    // Start validation animation
    _startValidation();
  }
  
  void _startValidation() {
    setState(() {
      _isValidating = true;
    });
    // Simulate validation process
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isValidating = false;
        });
      }
    });
  }
  
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter && widget.validationResult.canExport) {
        widget.onConfirmExport();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        widget.onCancel();
      } else if (event.logicalKey == LogicalKeyboardKey.keyF && widget.onFixIssues != null) {
        widget.onFixIssues!();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: _handleKeyEvent,
      child: AlertDialog(
      title: Row(
        children: [
          if (_isValidating)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            )
          else
            Icon(
              _getOverallIcon(),
              color: _getOverallColor(colorScheme),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isValidating ? 'Validating...' : _getTitle(),
              style: theme.textTheme.headlineSmall,
            ),
          ),
        ],
      ),
      content: _isValidating
        ? const SizedBox(
            height: 100,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Checking export compatibility...'),
                ],
              ),
            ),
          )
        : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary section
                _buildSummaryCard(context),
                
                const SizedBox(height: 16),
                
                // Errors section
                if (widget.validationResult.errors.isNotEmpty) ...[
                  _buildIssueSection(
                    context,
                    'Errors (Must Fix)',
                    widget.validationResult.errors,
                    Icons.error,
                    colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Warnings section
                if (widget.validationResult.warnings.isNotEmpty) ...[
                  _buildIssueSection(
                    context,
                    'Warnings (Review Recommended)',
                    widget.validationResult.warnings,
                    Icons.warning,
                    colorScheme.tertiary,
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Info section
                if (widget.validationResult.info.isNotEmpty) ...[
                  _buildIssueSection(
                    context,
                    'Information',
                    widget.validationResult.info,
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
      actions: _isValidating
        ? []
        : [
            TextButton(
              onPressed: widget.onCancel,
              child: const Text('Cancel (Esc)'),
            ),
            if (widget.onFixIssues != null && widget.validationResult.errors.isNotEmpty)
              TextButton.icon(
                onPressed: widget.onFixIssues,
                icon: const Icon(Icons.build),
                label: const Text('Fix Issues (F)'),
              ),
            if (widget.validationResult.canExport)
              FilledButton.icon(
                onPressed: widget.onConfirmExport,
                icon: Icon(
                  widget.validationResult.warnings.isEmpty
                      ? Icons.check_circle
                      : Icons.warning,
                ),
                label: Text(
                  widget.validationResult.warnings.isEmpty
                      ? 'Export (Enter)'
                      : 'Export Anyway (Enter)',
                ),
              ),
          ],
      ),
    );
  }
  
  Widget _buildSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    final metadata = widget.validationResult.metadata;
    final receiptCount = metadata['receiptCount'] ?? 0;
    final format = widget.exportFormat ?? metadata['format'] ?? 'Unknown';
    
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getFormatColor(format.toString()).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getFormatColor(format.toString()).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getFormatIcon(format.toString()),
                        size: 16,
                        color: _getFormatColor(format.toString()),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        format.toString().split('.').last.toUpperCase(),
                        style: TextStyle(
                          color: _getFormatColor(format.toString()),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
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
    if (!widget.validationResult.isValid) return Icons.error;
    if (widget.validationResult.warnings.isNotEmpty) return Icons.warning;
    return Icons.check_circle;
  }
  
  Color _getOverallColor(ColorScheme colorScheme) {
    if (!widget.validationResult.isValid) return colorScheme.error;
    if (widget.validationResult.warnings.isNotEmpty) return colorScheme.tertiary;
    return colorScheme.primary;
  }
  
  String _getTitle() {
    if (!widget.validationResult.isValid) {
      return 'Export Blocked - Issues Found';
    }
    if (widget.validationResult.warnings.isNotEmpty) {
      return 'Export Ready with Warnings';
    }
    return 'Export Ready';
  }
  
  IconData _getFormatIcon(String format) {
    final formatLower = format.toLowerCase();
    if (formatLower.contains('quickbooks') || formatLower.contains('qbo')) {
      return Icons.account_balance;
    } else if (formatLower.contains('xero')) {
      return Icons.cloud_sync;
    } else if (formatLower.contains('csv')) {
      return Icons.table_chart;
    } else if (formatLower.contains('excel') || formatLower.contains('xlsx')) {
      return Icons.grid_on;
    }
    return Icons.file_present;
  }
  
  Color _getFormatColor(String format) {
    final theme = Theme.of(context);
    final formatLower = format.toLowerCase();
    if (formatLower.contains('quickbooks') || formatLower.contains('qbo')) {
      return Colors.green;
    } else if (formatLower.contains('xero')) {
      return Colors.blue;
    } else if (formatLower.contains('csv')) {
      return theme.colorScheme.primary;
    } else if (formatLower.contains('excel') || formatLower.contains('xlsx')) {
      return Colors.orange;
    }
    return theme.colorScheme.secondary;
  }
  
  double _calculateHealthScore() {
    final totalIssues = widget.validationResult.errors.length * 3 +
        widget.validationResult.warnings.length * 2 +
        widget.validationResult.info.length;
    
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
    return widget.validationResult.errors.any((e) => e.id.startsWith('SEC_')) ||
        widget.validationResult.warnings.any((e) => e.id.startsWith('SEC_'));
  }
}

/// Helper function to show the validation dialog
Future<bool> showValidationReportDialog({
  required BuildContext context,
  required ValidationResult validationResult,
  String? exportFormat,
  VoidCallback? onFixIssues,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ValidationReportDialog(
      validationResult: validationResult,
      onConfirmExport: () => Navigator.of(context).pop(true),
      onCancel: () => Navigator.of(context).pop(false),
      exportFormat: exportFormat,
      onFixIssues: onFixIssues,
    ),
  );
  
  return result ?? false;
}