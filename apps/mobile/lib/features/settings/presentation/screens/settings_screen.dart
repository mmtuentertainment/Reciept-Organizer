import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';

/// Settings screen for configuring app preferences
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final settingsNotifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // OCR Processing Section
          _buildSectionHeader(context, 'OCR Processing'),
          _buildSwitchTile(
            title: 'Merchant Name Normalization',
            subtitle: 'Automatically clean up merchant names (e.g., "MCDONALDS #4521" → "McDonalds")',
            value: settings.merchantNormalization,
            onChanged: (value) => settingsNotifier.updateMerchantNormalization(value),
            icon: Icons.auto_fix_high,
          ),

          const Divider(),

          // Capture Settings Section
          _buildSectionHeader(context, 'Capture Settings'),
          _buildSwitchTile(
            title: 'Audio Feedback',
            subtitle: 'Play sounds for capture success/failure',
            value: settings.enableAudioFeedback,
            onChanged: (value) => settingsNotifier.updateAudioFeedback(value),
            icon: Icons.volume_up,
          ),
          _buildSwitchTile(
            title: 'Batch Capture',
            subtitle: 'Capture multiple receipts in sequence',
            value: settings.enableBatchCapture,
            onChanged: (value) => settingsNotifier.updateBatchCapture(value),
            icon: Icons.collections,
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Max Retry Attempts'),
            subtitle: Text('Failed captures can be retried ${settings.maxRetryAttempts} times'),
            trailing: DropdownButton<int>(
              value: settings.maxRetryAttempts,
              items: List.generate(6, (i) => i + 1)
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.toString()),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  settingsNotifier.updateMaxRetryAttempts(value);
                }
              },
            ),
          ),

          const Divider(),

          // Export Settings Section
          _buildSectionHeader(context, 'Export Settings'),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('CSV Export Format'),
            subtitle: Text('Export format: ${_formatName(settings.csvExportFormat)}'),
            trailing: DropdownButton<String>(
              value: settings.csvExportFormat,
              items: const [
                DropdownMenuItem(
                  value: 'quickbooks',
                  child: Text('QuickBooks'),
                ),
                DropdownMenuItem(
                  value: 'xero',
                  child: Text('Xero'),
                ),
                DropdownMenuItem(
                  value: 'generic',
                  child: Text('Generic'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  settingsNotifier.updateCsvFormat(value);
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date Format'),
            subtitle: Text('Current format: ${settings.dateFormat}'),
            trailing: DropdownButton<String>(
              value: settings.dateFormat,
              items: const [
                DropdownMenuItem(
                  value: 'MM/dd/yyyy',
                  child: Text('MM/dd/yyyy'),
                ),
                DropdownMenuItem(
                  value: 'dd/MM/yyyy',
                  child: Text('dd/MM/yyyy'),
                ),
                DropdownMenuItem(
                  value: 'yyyy-MM-dd',
                  child: Text('yyyy-MM-dd'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  settingsNotifier.updateDateFormat(value);
                }
              },
            ),
          ),

          const Divider(),

          // Reset Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton.icon(
              onPressed: () => _showResetDialog(context, settingsNotifier),
              icon: const Icon(Icons.restore),
              label: const Text('Reset to Defaults'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  String _formatName(String format) {
    switch (format) {
      case 'quickbooks':
        return 'QuickBooks';
      case 'xero':
        return 'Xero';
      case 'generic':
        return 'Generic CSV';
      default:
        return format;
    }
  }

  Future<void> _showResetDialog(
    BuildContext context,
    AppSettingsNotifier notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.resetSettings();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings reset to defaults'),
          ),
        );
      }
    }
  }
}