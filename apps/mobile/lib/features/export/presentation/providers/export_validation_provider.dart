import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/core/models/receipt.dart';
import '../../domain/export_validator.dart';

/// Provider for the export validator service
final exportValidatorProvider = Provider<ExportValidator>((ref) {
  return ExportValidator();
});

/// State for export validation
class ExportValidationState {
  final bool isValidating;
  final ValidationResult? result;
  final double progress;
  final String? currentStep;
  final String? error;
  
  const ExportValidationState({
    this.isValidating = false,
    this.result,
    this.progress = 0.0,
    this.currentStep,
    this.error,
  });
  
  ExportValidationState copyWith({
    bool? isValidating,
    ValidationResult? result,
    double? progress,
    String? currentStep,
    String? error,
  }) {
    return ExportValidationState(
      isValidating: isValidating ?? this.isValidating,
      result: result ?? this.result,
      progress: progress ?? this.progress,
      currentStep: currentStep ?? this.currentStep,
      error: error ?? this.error,
    );
  }
}

/// Notifier for export validation state
class ExportValidationNotifier extends StateNotifier<ExportValidationState> {
  final ExportValidator _validator;
  
  ExportValidationNotifier(this._validator) : super(const ExportValidationState());
  
  /// Validate receipts for export
  Future<ValidationResult?> validateReceipts({
    required List<Receipt> receipts,
    required ExportFormat format,
  }) async {
    // Reset state
    state = const ExportValidationState(isValidating: true);
    
    try {
      // Start validation stream
      final stream = _validator.validateForExport(
        receipts: receipts,
        format: format,
        enableStreaming: receipts.length > 100,
      );
      
      ValidationResult? latestResult;
      
      // Listen to validation progress
      await for (final result in stream) {
        latestResult = result;
        
        // Update progress
        final progress = result.metadata['progress'] as double? ?? 0.0;
        final currentStep = _getCurrentStep(result);
        
        state = state.copyWith(
          progress: progress,
          currentStep: currentStep,
          result: result,
        );
      }
      
      // Final state
      state = ExportValidationState(
        isValidating: false,
        result: latestResult,
        progress: 1.0,
      );
      
      return latestResult;
      
    } catch (e) {
      state = ExportValidationState(
        isValidating: false,
        error: 'Validation failed: ${e.toString()}',
      );
      return null;
    }
  }
  
  /// Clear validation state
  void clearValidation() {
    state = const ExportValidationState();
  }
  
  /// Get current validation step description
  String _getCurrentStep(ValidationResult result) {
    final processedCount = result.metadata['processedCount'] ?? 0;
    final totalCount = result.metadata['totalCount'] ?? 0;
    
    if (processedCount == 0) {
      return 'Starting validation...';
    }
    
    if (processedCount < totalCount) {
      return 'Validating receipt $processedCount of $totalCount...';
    }
    
    return 'Validation complete';
  }
}

/// Provider for export validation state
final exportValidationProvider = 
    StateNotifierProvider<ExportValidationNotifier, ExportValidationState>((ref) {
  final validator = ref.watch(exportValidatorProvider);
  return ExportValidationNotifier(validator);
});

/// Provider to trigger validation
final validateExportProvider = Provider.family<Future<ValidationResult?>, ({
  List<Receipt> receipts,
  ExportFormat format,
})>((ref, params) async {
  final notifier = ref.read(exportValidationProvider.notifier);
  return notifier.validateReceipts(
    receipts: params.receipts,
    format: params.format,
  );
});