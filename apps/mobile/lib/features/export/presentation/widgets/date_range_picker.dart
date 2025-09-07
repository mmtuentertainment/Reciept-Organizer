import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DateRangePreset {
  thisMonth('This Month'),
  lastMonth('Last Month'),
  last30Days('Last 30 Days'),
  last90Days('Last 90 Days'),
  custom('Custom');

  final String label;
  const DateRangePreset(this.label);
}

class DateRangePickerWidget extends ConsumerStatefulWidget {
  const DateRangePickerWidget({super.key});

  @override
  ConsumerState<DateRangePickerWidget> createState() => _DateRangePickerWidgetState();
  
  /// Calculate the start and end dates based on the selected preset
  static DateTimeRange calculateDateRange(DateRangePreset preset, {DateTimeRange? customRange}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (preset) {
      case DateRangePreset.thisMonth:
        final firstDayOfMonth = DateTime(now.year, now.month, 1);
        return DateTimeRange(start: firstDayOfMonth, end: today);
        
      case DateRangePreset.lastMonth:
        final firstDayOfLastMonth = DateTime(now.year, now.month - 1, 1);
        final lastDayOfLastMonth = DateTime(now.year, now.month, 0);
        return DateTimeRange(start: firstDayOfLastMonth, end: lastDayOfLastMonth);
        
      case DateRangePreset.last30Days:
        final thirtyDaysAgo = today.subtract(const Duration(days: 30));
        return DateTimeRange(start: thirtyDaysAgo, end: today);
        
      case DateRangePreset.last90Days:
        final ninetyDaysAgo = today.subtract(const Duration(days: 90));
        return DateTimeRange(start: ninetyDaysAgo, end: today);
        
      case DateRangePreset.custom:
        return customRange ?? DateTimeRange(
          start: today.subtract(const Duration(days: 30)),
          end: today,
        );
    }
  }
}

class _DateRangePickerWidgetState extends ConsumerState<DateRangePickerWidget> {
  DateRangePreset _selectedPreset = DateRangePreset.last30Days;
  DateTimeRange? _customDateRange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Date Range',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SegmentedButton<DateRangePreset>(
              segments: DateRangePreset.values.map((preset) {
                return ButtonSegment<DateRangePreset>(
                  value: preset,
                  label: Text(preset.label),
                );
              }).toList(),
              selected: {_selectedPreset},
              onSelectionChanged: (Set<DateRangePreset> newSelection) {
                _onPresetChanged(newSelection.first);
              },
              showSelectedIcon: false,
            ),
            if (_selectedPreset == DateRangePreset.custom && _customDateRange != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.date_range,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatDate(_customDateRange!.start)} - ${_formatDate(_customDateRange!.end)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onPresetChanged(DateRangePreset preset) async {
    setState(() {
      _selectedPreset = preset;
    });

    if (preset == DateRangePreset.custom) {
      final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)), // 2 years ago
        lastDate: DateTime.now(),
        initialDateRange: _customDateRange ?? DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        ),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context), // Use Material 3 theme
            child: child!,
          );
        },
      );

      if (picked != null) {
        setState(() {
          _customDateRange = picked;
        });
      } else {
        // If user cancels, revert to previous selection
        setState(() {
          _selectedPreset = DateRangePreset.last30Days;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }
}