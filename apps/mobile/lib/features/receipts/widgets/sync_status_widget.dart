import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/receipts/providers/realtime_sync_provider.dart';
import 'package:receipt_organizer/features/receipts/providers/presence_provider.dart';
import 'package:intl/intl.dart';

/// Widget to display real-time sync status
class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(realtimeSyncProvider);
    final presenceState = ref.watch(presenceProvider);
    
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sync Status Header
            Row(
              children: [
                Icon(
                  syncState.isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: syncState.isConnected ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  syncState.isConnected ? 'Connected to Cloud' : 'Offline Mode',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (syncState.isSyncing)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Last Sync Time
            if (syncState.lastSyncTime != null) ...[
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Last synced: ${_formatTime(syncState.lastSyncTime!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            
            // Pending Changes
            if (syncState.pendingChanges > 0) ...[
              Row(
                children: [
                  const Icon(Icons.sync, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    '${syncState.pendingChanges} pending changes',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            
            // Active Devices
            if (presenceState.totalActiveDevices > 0) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Active Devices (${presenceState.totalActiveDevices})',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...presenceState.activeDevices.map((device) => 
                _buildDeviceRow(context, device)
              ),
            ],
            
            // Error Message
            if (syncState.lastError != null) ...[
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.error_outline, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      syncState.lastError!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            // Action Buttons
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!syncState.isConnected)
                  TextButton.icon(
                    onPressed: () => _reconnect(ref),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Reconnect'),
                  )
                else
                  TextButton.icon(
                    onPressed: () => _forceSync(ref),
                    icon: const Icon(Icons.cloud_download, size: 16),
                    label: const Text('Force Sync'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDeviceRow(BuildContext context, ActiveDevice device) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            _getDeviceIcon(device.platform),
            size: 16,
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.deviceName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Last seen: ${_formatTime(device.lastSeen)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (device.isCurrentDevice)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'This device',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  IconData _getDeviceIcon(String platform) {
    switch (platform) {
      case 'android':
        return Icons.phone_android;
      case 'ios':
        return Icons.phone_iphone;
      case 'macos':
      case 'windows':
      case 'linux':
        return Icons.computer;
      case 'web':
        return Icons.language;
      default:
        return Icons.devices;
    }
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return DateFormat('MMM d, h:mm a').format(time);
    }
  }
  
  void _reconnect(WidgetRef ref) async {
    final syncNotifier = ref.read(realtimeSyncProvider.notifier);
    final presenceNotifier = ref.read(presenceProvider.notifier);
    
    await syncNotifier.initialize();
    await presenceNotifier.initialize();
  }
  
  void _forceSync(WidgetRef ref) async {
    final syncNotifier = ref.read(realtimeSyncProvider.notifier);
    await syncNotifier.forceSyncFromCloud();
  }
}

/// Compact sync status indicator for app bar
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(realtimeSyncProvider);
    
    return IconButton(
      icon: Stack(
        children: [
          Icon(
            syncState.isConnected ? Icons.cloud_done : Icons.cloud_off,
            color: syncState.isConnected ? Colors.green : Colors.grey,
          ),
          if (syncState.pendingChanges > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => const SyncStatusWidget(),
        );
      },
    );
  }
}