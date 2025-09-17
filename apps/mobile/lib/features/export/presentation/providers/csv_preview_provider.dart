import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/export/services/export_format_validator.dart';
import 'package:receipt_organizer/domain/services/csv_export_service.dart';
import 'package:receipt_organizer/features/export/domain/services/csv_preview_service.dart';
import 'package:receipt_organizer/features/export/presentation/providers/date_range_provider.dart';
import 'package:receipt_organizer/features/export/presentation/providers/export_format_provider.dart';
import 'package:receipt_organizer/core/providers/repository_providers.dart';

/// State model for CSV preview
class CSVPreviewState {
  final List<List<String>> previewData;
  final int totalCount;
  final List<ValidationWarning> validationWarnings;
  final bool isLoading;
  final String? error;
  final Duration? generationTime;
  final ExportFormat? currentFormat;

  const CSVPreviewState({
    this.previewData = const [],
    this.totalCount = 0,
    this.validationWarnings = const [],
    this.isLoading = false,
    this.error,
    this.generationTime,
    this.currentFormat,
  });

  CSVPreviewState copyWith({
    List<List<String>>? previewData,
    int? totalCount,
    List<ValidationWarning>? validationWarnings,
    bool? isLoading,
    String? error,
    Duration? generationTime,
    ExportFormat? currentFormat,
  }) {
    return CSVPreviewState(
      previewData: previewData ?? this.previewData,
      totalCount: totalCount ?? this.totalCount,
      validationWarnings: validationWarnings ?? this.validationWarnings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      generationTime: generationTime ?? this.generationTime,
      currentFormat: currentFormat ?? this.currentFormat,
    );
  }

  bool get hasData => previewData.isNotEmpty;
  bool get hasWarnings => validationWarnings.isNotEmpty;
  bool get hasCriticalWarnings => validationWarnings.any(
    (w) => w.severity == WarningSeverity.critical
  );
}

/// Provider for CSV preview functionality with auto-refresh on dependencies
class CSVPreviewNotifier extends AsyncNotifier<CSVPreviewState> {
  late final CSVPreviewService _previewService;
  
  @override
  Future<CSVPreviewState> build() async {
    // Initialize service
    _previewService = CSVPreviewService();
    
    // Watch dependencies for auto-refresh
    final dateRangeAsync = ref.watch(dateRangeNotifierProvider);
    final exportFormatState = ref.watch(exportFormatNotifierProvider);
    
    // Handle loading state while waiting for date range
    return await dateRangeAsync.when(
      loading: () async => const CSVPreviewState(isLoading: true),
      error: (error, _) async => CSVPreviewState(
        error: 'Failed to load date range: ${error.toString()}',
      ),
      data: (dateRangeState) async {
        // Generate preview when dependencies change
        return await _generatePreview(
          dateRangeState,
          exportFormatState.selectedFormat,
        );
      },
    );
  }

  /// Generate CSV preview based on current date range and format
  Future<CSVPreviewState> _generatePreview(
    DateRangeState dateRangeState,
    ExportFormat format,
  ) async {
    try {
      // Start loading
      state = const AsyncValue.loading();

      // Get receipts from repository based on date range
      final receiptRepository = await ref.read(receiptRepositoryProvider.future);
      final receipts = await receiptRepository.getReceiptsByDateRange(
        dateRangeState.dateRange.start,
        dateRangeState.dateRange.end,
      );

      // Handle empty results
      if (receipts.isEmpty) {
        return const CSVPreviewState(
          previewData: [],
          totalCount: 0,
          validationWarnings: [],
          isLoading: false,
        );
      }

      // Generate preview using service (CRITICAL: Security and performance handled here)
      final result = await _previewService.generatePreview(receipts, format);
      
      // Log performance warning if exceeds target (PERF-001)
      if (result.generationTime.inMilliseconds > 100) {
        // Using debugPrint instead of print for production
        // ignore: avoid_print
        print('WARNING: CSV preview generation exceeded 100ms target: '
              '${result.generationTime.inMilliseconds}ms');
      }

      return CSVPreviewState(
        previewData: result.previewRows,
        totalCount: result.totalCount,
        validationWarnings: result.warnings,
        generationTime: result.generationTime,
        currentFormat: format,
        isLoading: false,
      );
    } catch (e) {
      // Handle errors gracefully
      return CSVPreviewState(
        isLoading: false,
        error: 'Failed to generate preview: ${e.toString()}',
      );
    }
  }

  /// Manually refresh the preview
  Future<void> refresh() async {
    final dateRangeAsync = ref.read(dateRangeNotifierProvider);
    final exportFormatState = ref.read(exportFormatNotifierProvider);
    
    await dateRangeAsync.when(
      loading: () async {},
      error: (_, __) async {},
      data: (dateRangeState) async {
        state = AsyncValue.data(
          await _generatePreview(
            dateRangeState,
            exportFormatState.selectedFormat,
          ),
        );
      },
    );
  }

  /// Clear preview cache (useful when underlying data changes)
  void clearCache() {
    _previewService.clearCache();
  }

  /// Get export validation status
  bool canExport() {
    return state.maybeWhen(
      data: (preview) => 
        !preview.isLoading && 
        !preview.hasCriticalWarnings &&
        preview.hasData,
      orElse: () => false,
    );
  }

  /// Get warning summary for UI display
  Map<WarningSeverity, int> getWarningSummary() {
    return state.maybeWhen(
      data: (preview) {
        final summary = <WarningSeverity, int>{};
        for (final severity in WarningSeverity.values) {
          summary[severity] = preview.validationWarnings
              .where((w) => w.severity == severity)
              .length;
        }
        return summary;
      },
      orElse: () => {},
    );
  }
}

/// Main provider for CSV preview state
final csvPreviewProvider = AsyncNotifierProvider<CSVPreviewNotifier, CSVPreviewState>(
  () => CSVPreviewNotifier(),
);

/// Provider for export button state
final canExportProvider = Provider<bool>((ref) {
  final previewAsync = ref.watch(csvPreviewProvider);
  
  return previewAsync.maybeWhen(
    data: (preview) => 
      !preview.isLoading && 
      !preview.hasCriticalWarnings &&
      preview.hasData,
    orElse: () => false,
  );
});

/// Provider for performance monitoring
final previewPerformanceProvider = Provider<Duration?>((ref) {
  final previewAsync = ref.watch(csvPreviewProvider);
  
  return previewAsync.maybeWhen(
    data: (preview) => preview.generationTime,
    orElse: () => null,
  );
});