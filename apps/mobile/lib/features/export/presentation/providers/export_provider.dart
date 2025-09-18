import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/domain/services/csv_export_service.dart';
import 'package:receipt_organizer/features/export/services/export_format_validator.dart' hide ValidationResult;
import 'package:receipt_organizer/features/export/domain/export_validator.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/core/repositories/interfaces/i_receipt_repository.dart';
import 'package:receipt_organizer/core/providers/repository_providers.dart' as core_providers;
import 'package:share_plus/share_plus.dart';
import 'dart:io';

// Export state model
class ExportState {
  final bool isExporting;
  final double progress;
  final ExportFormat selectedFormat;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<Receipt> selectedReceipts;
  final ValidationResult? validationResult;
  final ExportResult? lastExportResult;
  final String? error;
  final ExportHistory exportHistory;

  ExportState({
    this.isExporting = false,
    this.progress = 0.0,
    this.selectedFormat = ExportFormat.quickBooks3Column,
    this.startDate,
    this.endDate,
    this.selectedReceipts = const [],
    this.validationResult,
    this.lastExportResult,
    this.error,
    ExportHistory? exportHistory,
  }) : exportHistory = exportHistory ?? ExportHistory();

  ExportState copyWith({
    bool? isExporting,
    double? progress,
    ExportFormat? selectedFormat,
    DateTime? startDate,
    DateTime? endDate,
    List<Receipt>? selectedReceipts,
    ValidationResult? validationResult,
    ExportResult? lastExportResult,
    String? error,
    ExportHistory? exportHistory,
  }) {
    return ExportState(
      isExporting: isExporting ?? this.isExporting,
      progress: progress ?? this.progress,
      selectedFormat: selectedFormat ?? this.selectedFormat,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedReceipts: selectedReceipts ?? this.selectedReceipts,
      validationResult: validationResult ?? this.validationResult,
      lastExportResult: lastExportResult ?? this.lastExportResult,
      error: error ?? this.error,
      exportHistory: exportHistory ?? this.exportHistory,
    );
  }

  // Clear error state
  ExportState clearError() {
    return copyWith(error: null);
  }
}

// Export history tracking
class ExportHistory {
  final List<ExportRecord> records;

  ExportHistory({this.records = const []});

  ExportHistory addRecord(ExportRecord record) {
    final updated = List<ExportRecord>.from(records);
    updated.insert(0, record); // Add to beginning for recent first

    // Keep only last 50 exports
    if (updated.length > 50) {
      updated.removeRange(50, updated.length);
    }

    return ExportHistory(records: updated);
  }

  List<ExportRecord> getRecordsForFormat(ExportFormat format) {
    return records.where((r) => r.format == format).toList();
  }

  ExportRecord? get lastExport => records.isNotEmpty ? records.first : null;
}

// Export record for history
class ExportRecord {
  final String id;
  final DateTime exportDate;
  final ExportFormat format;
  final int receiptCount;
  final String filePath;
  final String fileName;
  final bool success;
  final String? error;

  ExportRecord({
    required this.id,
    required this.exportDate,
    required this.format,
    required this.receiptCount,
    required this.filePath,
    required this.fileName,
    required this.success,
    this.error,
  });

  factory ExportRecord.fromResult(ExportResult result, ExportFormat format, int receiptCount) {
    return ExportRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      exportDate: DateTime.now(),
      format: format,
      receiptCount: receiptCount,
      filePath: result.filePath ?? '',
      fileName: result.fileName ?? '',
      success: result.success,
      error: result.error,
    );
  }
}

// Export state notifier
class ExportNotifier extends StateNotifier<ExportState> {
  final ICSVExportService _csvService;
  final IReceiptRepository _receiptRepository;

  ExportNotifier(this._csvService, this._receiptRepository) : super(ExportState());

  // Set date range for export
  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: start, endDate: end);
    _loadReceiptsForDateRange();
  }

  // Set export format
  void setExportFormat(ExportFormat format) {
    state = state.copyWith(selectedFormat: format);
    // Revalidate if receipts are loaded
    if (state.selectedReceipts.isNotEmpty) {
      _validateReceipts();
    }
  }

  // Load receipts for the selected date range
  Future<void> _loadReceiptsForDateRange() async {
    if (state.startDate == null || state.endDate == null) return;

    try {
      final receipts = await _receiptRepository.getReceiptsByDateRange(
        state.startDate!,
        state.endDate!,
      );

      state = state.copyWith(
        selectedReceipts: receipts,
        error: null,
      );

      // Validate after loading
      await _validateReceipts();
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load receipts: $e',
        selectedReceipts: [],
      );
    }
  }

  // Validate receipts for export
  Future<void> _validateReceipts() async {
    if (state.selectedReceipts.isEmpty) return;

    try {
      final csvValidation = await _csvService.validateForExport(
        state.selectedReceipts,
        state.selectedFormat,
      );

      // Convert CSVValidationResult to ValidationResult
      final validation = ValidationResult(
        isValid: csvValidation.isValid,
        errors: csvValidation.errors.asMap().entries.map((entry) => ValidationIssue(
          id: 'error_${entry.key}',
          message: entry.value,
          severity: ValidationSeverity.error,
          field: 'receipt',
        )).toList(),
        warnings: csvValidation.warnings.asMap().entries.map((entry) => ValidationIssue(
          id: 'warning_${entry.key}',
          message: entry.value,
          severity: ValidationSeverity.warning,
          field: 'receipt',
        )).toList(),
        metadata: {
          'validCount': csvValidation.validCount,
          'totalCount': csvValidation.totalCount,
        },
      );

      state = state.copyWith(
        validationResult: validation,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Validation failed: $e',
      );
    }
  }

  // Export receipts with progress tracking
  Future<void> exportReceipts({String? customFileName}) async {
    if (state.selectedReceipts.isEmpty) {
      state = state.copyWith(error: 'No receipts selected for export');
      return;
    }

    // Clear any previous errors
    state = state.clearError();
    state = state.copyWith(isExporting: true, progress: 0.0);

    try {
      // Stream progress updates
      await for (final progress in _csvService.exportWithProgress(
        state.selectedReceipts,
        state.selectedFormat,
        customFileName: customFileName,
      )) {
        state = state.copyWith(progress: progress);

        // When complete
        if (progress >= 1.0) {
          // Create export result
          final result = ExportResult.success(
            '${(await _csvService.exportToCSV(
              state.selectedReceipts,
              state.selectedFormat,
              customFileName: customFileName,
            )).filePath}',
            customFileName ?? 'receipts_${state.selectedFormat.name}_${DateTime.now().millisecondsSinceEpoch}.csv',
            state.selectedReceipts.length,
          );

          // Create export record
          final record = ExportRecord.fromResult(
            result,
            state.selectedFormat,
            state.selectedReceipts.length,
          );

          // Update state with success
          state = state.copyWith(
            isExporting: false,
            lastExportResult: result,
            exportHistory: state.exportHistory.addRecord(record),
            progress: 0.0,
          );
        }
      }
    } catch (e) {
      // Handle export error
      final errorResult = ExportResult.error(e.toString());
      final record = ExportRecord.fromResult(
        errorResult,
        state.selectedFormat,
        state.selectedReceipts.length,
      );

      state = state.copyWith(
        isExporting: false,
        error: e.toString(),
        lastExportResult: errorResult,
        exportHistory: state.exportHistory.addRecord(record),
        progress: 0.0,
      );
    }
  }

  // Share exported file
  Future<void> shareExportedFile() async {
    if (state.lastExportResult == null || !state.lastExportResult!.success) {
      state = state.copyWith(error: 'No file to share');
      return;
    }

    try {
      final filePath = state.lastExportResult!.filePath!;
      final file = File(filePath);

      if (!await file.exists()) {
        state = state.copyWith(error: 'Export file not found');
        return;
      }

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Receipt Export - ${state.selectedFormat.name}',
        text: 'Exported ${state.selectedReceipts.length} receipts',
      );

      state = state.clearError();
    } catch (e) {
      state = state.copyWith(error: 'Failed to share file: $e');
    }
  }

  // Clear export state
  void clearExport() {
    state = state.copyWith(
      isExporting: false,
      progress: 0.0,
      lastExportResult: null,
      validationResult: null,
      error: null,
    );
  }

  // Get export history for current format
  List<ExportRecord> getFormatHistory() {
    return state.exportHistory.getRecordsForFormat(state.selectedFormat);
  }

  // Retry last export
  Future<void> retryLastExport() async {
    if (state.exportHistory.lastExport == null) {
      state = state.copyWith(error: 'No previous export to retry');
      return;
    }

    final lastExport = state.exportHistory.lastExport!;
    await exportReceipts(customFileName: lastExport.fileName);
  }

  // Export specific batch
  Future<void> exportBatch(int batchIndex) async {
    final batches = _csvService.createBatches(
      state.selectedReceipts,
      state.selectedFormat,
    );

    if (batchIndex >= batches.length) {
      state = state.copyWith(error: 'Invalid batch index');
      return;
    }

    final batchReceipts = batches[batchIndex];
    final originalReceipts = state.selectedReceipts;

    // Temporarily set state to batch receipts
    state = state.copyWith(selectedReceipts: batchReceipts);

    // Export the batch
    await exportReceipts(
      customFileName: 'batch_${batchIndex + 1}_of_${batches.length}_${state.selectedFormat.name}.csv',
    );

    // Restore original receipts
    state = state.copyWith(selectedReceipts: originalReceipts);
  }

  // Get batch information
  BatchInfo getBatchInfo() {
    final batches = _csvService.createBatches(
      state.selectedReceipts,
      state.selectedFormat,
    );

    return BatchInfo(
      totalBatches: batches.length,
      batchSizes: batches.map((b) => b.length).toList(),
      format: state.selectedFormat,
    );
  }
}

// Batch information
class BatchInfo {
  final int totalBatches;
  final List<int> batchSizes;
  final ExportFormat format;

  BatchInfo({
    required this.totalBatches,
    required this.batchSizes,
    required this.format,
  });

  int get totalReceipts => batchSizes.fold(0, (sum, size) => sum + size);

  int getBatchSize(int index) =>
      index < batchSizes.length ? batchSizes[index] : 0;
}

// Provider definitions
final csvExportServiceProvider = Provider<ICSVExportService>((ref) {
  return CSVExportService();
});

// Use the repository provider from core
final exportReceiptRepositoryProvider = FutureProvider<IReceiptRepository>((ref) async {
  return await ref.watch(core_providers.receiptRepositoryProvider.future);
});

final exportProvider = StateNotifierProvider<ExportNotifier, ExportState>((ref) {
  final csvService = ref.watch(csvExportServiceProvider);
  final receiptRepositoryAsync = ref.watch(exportReceiptRepositoryProvider);

  // Handle async repository loading
  final receiptRepository = receiptRepositoryAsync.maybeWhen(
    data: (repo) => repo,
    orElse: () => throw Exception('Repository not yet loaded'),
  );

  return ExportNotifier(csvService, receiptRepository);
});

// Convenience providers
final exportProgressProvider = Provider<double>((ref) {
  return ref.watch(exportProvider.select((state) => state.progress));
});

final exportValidationProvider = Provider<ValidationResult?>((ref) {
  return ref.watch(exportProvider.select((state) => state.validationResult));
});

final exportHistoryProvider = Provider<ExportHistory>((ref) {
  return ref.watch(exportProvider.select((state) => state.exportHistory));
});

final isExportingProvider = Provider<bool>((ref) {
  return ref.watch(exportProvider.select((state) => state.isExporting));
});

final exportErrorProvider = Provider<String?>((ref) {
  return ref.watch(exportProvider.select((state) => state.error));
});

final selectedFormatProvider = Provider<ExportFormat>((ref) {
  return ref.watch(exportProvider.select((state) => state.selectedFormat));
});

final receiptCountProvider = Provider<int>((ref) {
  return ref.watch(exportProvider.select((state) => state.selectedReceipts.length));
});

final batchInfoProvider = Provider<BatchInfo>((ref) {
  final notifier = ref.read(exportProvider.notifier);
  return notifier.getBatchInfo();
});