import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/core/services/monitoring_service.dart';
import 'dart:async';

class MonitoringDashboard extends ConsumerStatefulWidget {
  const MonitoringDashboard({super.key});

  @override
  ConsumerState<MonitoringDashboard> createState() => _MonitoringDashboardState();
}

class _MonitoringDashboardState extends ConsumerState<MonitoringDashboard> {
  Timer? _refreshTimer;
  final _monitoringService = MonitoringService.instance;
  
  @override
  void initState() {
    super.initState();
    // Refresh dashboard every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final sessionStats = _monitoringService.getSessionStats();
    final healthStatus = _monitoringService.getHealthStatus();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') {
                _exportData();
              } else if (value == 'clear') {
                _clearData();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Text('Export Data'),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear Data'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Health Status Card
            _buildHealthCard(healthStatus),
            const SizedBox(height: 16),
            
            // Session Statistics Card
            _buildSessionCard(sessionStats),
            const SizedBox(height: 16),
            
            // Performance Metrics
            _buildPerformanceSection(),
            const SizedBox(height: 16),
            
            // Error Summary
            _buildErrorSection(),
            const SizedBox(height: 16),
            
            // Recent Activity
            _buildRecentActivitySection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHealthCard(Map<String, dynamic> health) {
    final status = health['status'] as String;
    final color = status == 'healthy' 
      ? Colors.green 
      : status == 'degraded' 
        ? Colors.orange 
        : Colors.red;
    
    final icon = status == 'healthy' 
      ? Icons.check_circle 
      : status == 'degraded' 
        ? Icons.warning 
        : Icons.error;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Health',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Error Rate: ${health['error_rate']}',
                    style: TextStyle(color: color),
                  ),
                ),
              ],
            ),
            if ((health['recent_errors'] as List).isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Recent Errors',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              ...((health['recent_errors'] as List).map((error) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(error.toString()),
                    ],
                  ),
                ),
              )),
            ],
            const SizedBox(height: 8),
            Text(
              'Uptime: ${_formatDuration(health['uptime_seconds'] as int)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSessionCard(Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildStatRow('Duration', _formatDuration(stats['session_duration_seconds'] as int)),
            _buildStatRow('API Calls', stats['api_calls'].toString()),
            _buildStatRow('DB Operations', stats['db_operations'].toString()),
            _buildStatRow('Sync Events', stats['sync_events'].toString()),
            _buildStatRow('Total Errors', stats['total_errors'].toString()),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPerformanceSection() {
    final metrics = _monitoringService.exportMonitoringData()['performance'] as Map<String, dynamic>;
    
    if (metrics.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Performance Metrics',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const Text('No performance data yet'),
            ],
          ),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...metrics.entries.map((entry) {
              final metric = entry.value as Map<String, dynamic>;
              if (metric.containsKey('error')) return const SizedBox.shrink();
              
              return ExpansionTile(
                title: Text(entry.key),
                subtitle: Text('${metric['count']} operations'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildStatRow('Average', '${metric['avg']}ms'),
                        _buildStatRow('Min', '${metric['min']}ms'),
                        _buildStatRow('Max', '${metric['max']}ms'),
                        _buildStatRow('P50', '${metric['p50']}ms'),
                        _buildStatRow('P95', '${metric['p95']}ms'),
                        _buildStatRow('P99', '${metric['p99']}ms'),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorSection() {
    final data = _monitoringService.exportMonitoringData();
    final errors = data['errors'] as Map<String, dynamic>;
    
    if (errors.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Error Summary',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text('No errors recorded'),
                ],
              ),
            ],
          ),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Error Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...errors.entries.map((entry) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(entry.key),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentActivitySection() {
    // This would show recent user actions, API calls, etc.
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Placeholder for activity feed
            const Text('Activity tracking will appear here'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
  
  void _exportData() {
    final data = _monitoringService.exportMonitoringData();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Monitoring Data'),
        content: SingleChildScrollView(
          child: SelectableText(
            data.toString(),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _clearData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Monitoring Data'),
        content: const Text('This will clear all monitoring data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _monitoringService.clearData();
              Navigator.of(context).pop();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Monitoring data cleared')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}