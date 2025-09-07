import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:receipt_organizer/core/repositories/interfaces/i_receipt_repository.dart';
import 'package:receipt_organizer/core/providers/repository_providers.dart';
import 'package:receipt_organizer/features/export/presentation/widgets/date_range_picker.dart';
import 'package:receipt_organizer/features/settings/providers/settings_provider.dart';
import 'dart:convert';

part 'date_range_provider.g.dart';

/// State model for date range selection
class DateRangeState {
  final DateTimeRange dateRange;
  final DateRangePreset presetOption;
  final int? receiptCount;
  final bool isLoading;
  final String? error;

  const DateRangeState({
    required this.dateRange,
    required this.presetOption,
    this.receiptCount,
    this.isLoading = false,
    this.error,
  });

  DateRangeState copyWith({
    DateTimeRange? dateRange,
    DateRangePreset? presetOption,
    int? receiptCount,
    bool? isLoading,
    String? error,
  }) {
    return DateRangeState(
      dateRange: dateRange ?? this.dateRange,
      presetOption: presetOption ?? this.presetOption,
      receiptCount: receiptCount ?? this.receiptCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': dateRange.start.toIso8601String(),
      'endDate': dateRange.end.toIso8601String(),
      'presetOption': presetOption.name,
    };
  }

  factory DateRangeState.fromJson(Map<String, dynamic> json) {
    final startDate = DateTime.parse(json['startDate']);
    final endDate = DateTime.parse(json['endDate']);
    final preset = DateRangePreset.values.firstWhere(
      (p) => p.name == json['presetOption'],
      orElse: () => DateRangePreset.last30Days,
    );

    return DateRangeState(
      dateRange: DateTimeRange(start: startDate, end: endDate),
      presetOption: preset,
    );
  }

  factory DateRangeState.initial() {
    final dateRange = DateRangePickerWidget.calculateDateRange(DateRangePreset.last30Days);
    return DateRangeState(
      dateRange: dateRange,
      presetOption: DateRangePreset.last30Days,
    );
  }
}

@riverpod
class DateRangeNotifier extends AutoDisposeAsyncNotifier<DateRangeState> {
  @override
  Future<DateRangeState> build() async {
    // Load saved preset preference from settings
    final settings = ref.watch(appSettingsProvider);
    final savedPreset = DateRangePreset.values.firstWhere(
      (p) => p.name == settings.dateRangePreset,
      orElse: () => DateRangePreset.last30Days,
    );
    
    // Calculate date range from saved preset
    final dateRange = DateRangePickerWidget.calculateDateRange(savedPreset);
    final initialState = DateRangeState(
      dateRange: dateRange,
      presetOption: savedPreset,
    );

    // Fetch initial receipt count
    await _updateReceiptCount(initialState);
    
    return initialState;
  }

  /// Update the date range and fetch new receipt count
  Future<void> updateDateRange(DateRangePreset preset, {DateTimeRange? customRange}) async {
    state = const AsyncValue.loading();

    try {
      final dateRange = DateRangePickerWidget.calculateDateRange(preset, customRange: customRange);
      
      var newState = DateRangeState(
        dateRange: dateRange,
        presetOption: preset,
        isLoading: true,
      );

      // Update state immediately to show loading
      state = AsyncValue.data(newState);

      // Fetch receipt count
      await _updateReceiptCount(newState);

      // Save to settings
      await _saveToSettings(newState);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Fetch receipt count for the current date range
  Future<void> _updateReceiptCount(DateRangeState currentState) async {
    try {
      final receiptRepo = await ref.read(receiptRepositoryProvider.future);
      final receipts = await receiptRepo.getReceiptsByDateRange(
        currentState.dateRange.start,
        currentState.dateRange.end,
      );

      state = AsyncValue.data(currentState.copyWith(
        receiptCount: receipts.length,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(
        isLoading: false,
        error: 'Failed to fetch receipt count: $e',
      ));
    }
  }

  /// Save current selection to settings
  Future<void> _saveToSettings(DateRangeState currentState) async {
    try {
      await ref.read(appSettingsProvider.notifier).updateDateRangePreset(
        currentState.presetOption.name,
      );
    } catch (_) {
      // Silently fail - not critical if settings don't save
    }
  }
}