import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/export/services/export_format_validator.dart';
import 'package:receipt_organizer/domain/services/csv_export_service.dart';
import 'package:receipt_organizer/features/settings/providers/settings_provider.dart';

/// State model for export format selection
class ExportFormatState {
  final ExportFormat selectedFormat;
  final ExportFormat? lastUsedFormat;
  final bool isLoading;
  final bool hasChanges;
  
  const ExportFormatState({
    required this.selectedFormat,
    this.lastUsedFormat,
    this.isLoading = false,
    this.hasChanges = false,
  });
  
  ExportFormatState copyWith({
    ExportFormat? selectedFormat,
    ExportFormat? lastUsedFormat,
    bool? isLoading,
    bool? hasChanges,
  }) {
    return ExportFormatState(
      selectedFormat: selectedFormat ?? this.selectedFormat,
      lastUsedFormat: lastUsedFormat ?? this.lastUsedFormat,
      isLoading: isLoading ?? this.isLoading,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }

  factory ExportFormatState.initial() => const ExportFormatState(
        selectedFormat: ExportFormat.generic,
        lastUsedFormat: null,
        isLoading: false,
        hasChanges: false,
      );
}

/// State notifier for managing export format selection
class ExportFormatNotifier extends StateNotifier<ExportFormatState> {
  final Ref _ref;

  ExportFormatNotifier(this._ref) : super(ExportFormatState.initial()) {
    _loadSavedFormat();
  }

  /// Load saved format preference from settings
  Future<void> _loadSavedFormat() async {
    state = state.copyWith(isLoading: true);

    try {
      final settings = _ref.read(appSettingsProvider);
      final savedFormatName = settings.csvExportFormat;
      
      final savedFormat = ExportFormat.values.firstWhere(
        (format) => format.name == savedFormatName,
        orElse: () => ExportFormat.generic,
      );
      
      state = state.copyWith(
        selectedFormat: savedFormat,
        lastUsedFormat: savedFormat,
        isLoading: false,
      );
    } catch (e) {
      // On error, fall back to generic format
      state = state.copyWith(
        selectedFormat: ExportFormat.generic,
        isLoading: false,
      );
    }
  }

  /// Update the selected format
  Future<void> updateFormat(ExportFormat newFormat) async {
    if (state.selectedFormat == newFormat) return;

    final previousFormat = state.selectedFormat;
    
    // Update state immediately for responsive UI
    state = state.copyWith(
      selectedFormat: newFormat,
      hasChanges: true,
    );

    try {
      // Persist to settings
      await _ref.read(appSettingsProvider.notifier).updateCsvFormat(newFormat.name);
      
      // Update state to reflect successful save
      state = state.copyWith(
        lastUsedFormat: newFormat,
        hasChanges: false,
      );
      
      // Notify other providers about format change
      // This allows preview updates, etc.
      _notifyFormatChange(newFormat);
    } catch (e) {
      // Rollback on error
      state = state.copyWith(
        selectedFormat: previousFormat,
        hasChanges: false,
      );
      
      // Re-throw to allow UI to handle error
      rethrow;
    }
  }

  /// Reset to last used format
  void resetToLastUsed() {
    if (state.lastUsedFormat != null) {
      state = state.copyWith(
        selectedFormat: state.lastUsedFormat!,
        hasChanges: false,
      );
    }
  }

  /// Check if current format has unsaved changes
  bool get hasUnsavedChanges => state.hasChanges;

  /// Get display name for a format
  String getFormatDisplayName(ExportFormat format) {
    switch (format) {
      case ExportFormat.quickbooks:
        return 'QuickBooks';
      case ExportFormat.xero:
        return 'Xero';
      case ExportFormat.generic:
        return 'Generic CSV';
    }
  }

  /// Notify other providers about format change
  void _notifyFormatChange(ExportFormat newFormat) {
    // This method can be extended to notify other providers
    // For example, if we have an export preview provider
    // _ref.read(exportPreviewProvider.notifier).refreshPreview();
  }
}

/// Provider for export format state management
final exportFormatNotifierProvider =
    StateNotifierProvider.autoDispose<ExportFormatNotifier, ExportFormatState>(
  (ref) => ExportFormatNotifier(ref),
);

/// Convenience provider for just the selected format
final selectedExportFormatProvider = Provider.autoDispose<ExportFormat>(
  (ref) => ref.watch(exportFormatNotifierProvider).selectedFormat,
);

/// Provider to check if format has unsaved changes
final hasUnsavedFormatChangesProvider = Provider.autoDispose<bool>(
  (ref) => ref.watch(exportFormatNotifierProvider).hasChanges,
);