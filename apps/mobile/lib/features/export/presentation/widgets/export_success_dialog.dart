import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

/// Dialog shown after successful CSV export
class ExportSuccessDialog extends StatelessWidget {
  final String filePath;
  final int receiptCount;
  final String format;
  final DateTime exportDate;
  final int? fileSize;
  
  const ExportSuccessDialog({
    super.key,
    required this.filePath,
    required this.receiptCount,
    required this.format,
    required this.exportDate,
    this.fileSize,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileName = filePath.split('/').last;
    final directory = filePath.substring(0, filePath.lastIndexOf('/'));
    
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Export Successful'),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$receiptCount Receipts Exported',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      Icons.calendar_today,
                      'Date',
                      _formatDate(exportDate),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      Icons.category,
                      'Format',
                      format.toUpperCase(),
                    ),
                    if (fileSize != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        context,
                        Icons.storage,
                        'File Size',
                        _formatFileSize(fileSize!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // File location section
            Text(
              'File Location',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // File name chip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.insert_drive_file,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fileName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () => _copyToClipboard(context, fileName),
                        tooltip: 'Copy file name',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    directory,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons row
            Wrap(
              spacing: 8,
              children: [
                if (Platform.isAndroid || Platform.isIOS)
                  OutlinedButton.icon(
                    onPressed: () => _shareFile(context),
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share'),
                  ),
                OutlinedButton.icon(
                  onPressed: () => _openFileLocation(context),
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: const Text('Open Location'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _copyPathToClipboard(context),
                  icon: const Icon(Icons.content_copy, size: 18),
                  label: const Text('Copy Path'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Info message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your CSV file is ready for import into $format. '
                      'The file has been saved locally and can be accessed from the location above.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _exportAnother(context),
          child: const Text('Export Another'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
  
  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
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
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $text'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  void _copyPathToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: filePath));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File path copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  Future<void> _shareFile(BuildContext context) async {
    try {
      final file = XFile(filePath);
      await Share.shareXFiles(
        [file],
        subject: 'Receipt Export - $format',
        text: 'Exported $receiptCount receipts on ${_formatDate(exportDate)}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _openFileLocation(BuildContext context) async {
    // Platform-specific implementation to open file explorer
    // This is a simplified version - real implementation would use platform channels
    
    try {
      if (Platform.isAndroid) {
        // TODO: Use platform channel to open file manager
        _copyPathToClipboard(context);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Path copied. Open your file manager to navigate.'),
            ),
          );
        }
      } else if (Platform.isIOS) {
        // iOS doesn't allow direct file system access
        _shareFile(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot open location: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
  
  void _exportAnother(BuildContext context) {
    Navigator.of(context).pop();
    // The parent screen will handle resetting for another export
  }
}

/// Helper function to show the success dialog
Future<void> showExportSuccessDialog({
  required BuildContext context,
  required String filePath,
  required int receiptCount,
  required String format,
  int? fileSize,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ExportSuccessDialog(
      filePath: filePath,
      receiptCount: receiptCount,
      format: format,
      exportDate: DateTime.now(),
      fileSize: fileSize,
    ),
  );
}