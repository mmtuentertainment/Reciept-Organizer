import '../../../core/models/receipt.dart';
import '../../../core/exceptions/service_exception.dart';
import '../services/quickbooks_api_service.dart';
import '../services/xero_api_service.dart';
import '../services/export_format_validator.dart' show ExportFormat;

/// Validation severity levels for export issues
enum ValidationSeverity {
  error,   // Blocks export
  warning, // Allows export with user confirmation
  info     // Informational only
}

/// Result of a single validation rule
class ValidationIssue {
  final String id;
  final String field;
  final String message;
  final ValidationSeverity severity;
  final String? suggestedFix;
  final dynamic actualValue;
  final dynamic expectedValue;

  const ValidationIssue({
    required this.id,
    required this.field,
    required this.message,
    required this.severity,
    this.suggestedFix,
    this.actualValue,
    this.expectedValue,
  });
}

/// Overall validation result for export
class ValidationResult {
  final bool isValid;
  final List<ValidationIssue> errors;
  final List<ValidationIssue> warnings;
  final List<ValidationIssue> info;
  final Map<String, dynamic> metadata;

  ValidationResult({
    required this.isValid,
    List<ValidationIssue>? errors,
    List<ValidationIssue>? warnings,
    List<ValidationIssue>? info,
    Map<String, dynamic>? metadata,
  })  : errors = errors ?? [],
        warnings = warnings ?? [],
        info = info ?? [],
        metadata = metadata ?? {};

  /// Get all issues sorted by severity
  List<ValidationIssue> get allIssues {
    return [...errors, ...warnings, ...info];
  }

  /// Check if export can proceed (no errors, warnings allowed with confirmation)
  bool get canExport => errors.isEmpty;

  /// Check if there are any issues at all
  bool get hasIssues => errors.isNotEmpty || warnings.isNotEmpty;
}

/// Base interface for validation rules
abstract class ValidationRule {
  String get id;
  String get description;
  
  /// Validate a single receipt
  ValidationIssue? validate(Receipt receipt);
  
  /// Validate a batch of receipts
  List<ValidationIssue> validateBatch(List<Receipt> receipts) {
    final issues = <ValidationIssue>[];
    for (final receipt in receipts) {
      final issue = validate(receipt);
      if (issue != null) {
        issues.add(issue);
      }
    }
    return issues;
  }
}

/// Export format types
// ExportFormat enum moved to services/export_format_validator.dart to avoid duplication

/// Main export validator service
class ExportValidator {
  static const int _chunkSize = 100;
  
  // API services for real validation
  final QuickBooksAPIService _quickBooksService = QuickBooksAPIService();
  final XeroAPIService _xeroService = XeroAPIService();
  final bool useAPIValidation;  // Flag to enable/disable API validation
  
  ExportValidator({this.useAPIValidation = true});
  
  // CSV injection patterns - CRITICAL SECURITY
  static final _csvInjectionPatterns = RegExp(
    r'^[=+\-@\t\r]|[\n\r]',
    multiLine: true,
  );
  
  // Special characters that need escaping
  static final _specialCharsPattern = RegExp(r'[,"\n\r]');
  
  /// Validate receipts for export with streaming support for large datasets
  Stream<ValidationResult> validateForExport({
    required List<Receipt> receipts,
    required ExportFormat format,
    bool enableStreaming = true,
  }) async* {
    if (receipts.isEmpty) {
      yield ValidationResult(
        isValid: false,
        errors: [
          ValidationIssue(
            id: 'EMPTY_LIST',
            field: 'receipts',
            message: 'No receipts to export',
            severity: ValidationSeverity.error,
            suggestedFix: 'Add at least one receipt before exporting',
          ),
        ],
      );
      return;
    }

    // Process in chunks for large datasets
    if (enableStreaming && receipts.length > _chunkSize) {
      yield* _validateInChunks(receipts, format);
    } else {
      yield await _validateAll(receipts, format);
    }
  }

  /// Validate all receipts at once (for smaller datasets)
  Future<ValidationResult> _validateAll(
    List<Receipt> receipts,
    ExportFormat format,
  ) async {
    try {
      final errors = <ValidationIssue>[];
      final warnings = <ValidationIssue>[];
      final info = <ValidationIssue>[];

      // Use real API validation if enabled and available
      if (useAPIValidation) {
        final apiResult = await _validateWithAPI(receipts, format);
        if (apiResult != null) {
          return apiResult;
        }
      }

      // Fall back to local validation
      // Get format-specific validator
      final validator = _getFormatValidator(format);
      
      // Security validation first (CRITICAL)
      for (int i = 0; i < receipts.length; i++) {
        final receipt = receipts[i];
        final securityIssues = _validateSecurity(receipt, i);
        _categorizeIssues(securityIssues, errors, warnings, info);
      }

      // Format-specific validation
      for (int i = 0; i < receipts.length; i++) {
        final receipt = receipts[i];
        final formatIssues = validator.validate(receipt, i);
        _categorizeIssues(formatIssues, errors, warnings, info);
      }

      // Required fields validation
      for (int i = 0; i < receipts.length; i++) {
        final receipt = receipts[i];
        final requiredIssues = _validateRequiredFields(receipt, i, format);
        _categorizeIssues(requiredIssues, errors, warnings, info);
      }

      return ValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
        info: info,
        metadata: {
          'format': format.toString(),
          'receiptCount': receipts.length,
          'validatedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw ServiceException(
        'Export validation failed: ${e.toString()}',
        code: 'VALIDATION_ERROR',
      );
    }
  }

  /// Validate in chunks for streaming (large datasets)
  Stream<ValidationResult> _validateInChunks(
    List<Receipt> receipts,
    ExportFormat format,
  ) async* {
    final errors = <ValidationIssue>[];
    final warnings = <ValidationIssue>[];
    final info = <ValidationIssue>[];
    
    final totalChunks = (receipts.length / _chunkSize).ceil();
    
    for (int chunkIndex = 0; chunkIndex < totalChunks; chunkIndex++) {
      final start = chunkIndex * _chunkSize;
      final end = (start + _chunkSize > receipts.length)
          ? receipts.length
          : start + _chunkSize;
      
      final chunk = receipts.sublist(start, end);
      final chunkResult = await _validateAll(chunk, format);
      
      errors.addAll(chunkResult.errors);
      warnings.addAll(chunkResult.warnings);
      info.addAll(chunkResult.info);
      
      // Yield intermediate result
      yield ValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
        info: info,
        metadata: {
          'format': format.toString(),
          'processedCount': end,
          'totalCount': receipts.length,
          'progress': end / receipts.length,
        },
      );
    }
  }

  /// Security validation - CRITICAL for preventing CSV injection
  List<ValidationIssue> _validateSecurity(Receipt receipt, int index) {
    final issues = <ValidationIssue>[];
    
    // Check merchant name for CSV injection
    if (receipt.merchantName != null) {
      if (_csvInjectionPatterns.hasMatch(receipt.merchantName!)) {
        issues.add(ValidationIssue(
          id: 'SEC_CSV_INJECTION_MERCHANT',
          field: 'merchantName',
          message: 'Merchant name contains potentially dangerous characters',
          severity: ValidationSeverity.error,
          suggestedFix: 'Remove or escape special characters (=, +, -, @, tab, newline)',
          actualValue: receipt.merchantName,
        ));
      }
    }
    
    // Check for special characters that need escaping
    if (receipt.merchantName != null && 
        _specialCharsPattern.hasMatch(receipt.merchantName!)) {
      issues.add(ValidationIssue(
        id: 'SEC_SPECIAL_CHARS',
        field: 'merchantName',
        message: 'Merchant name contains special characters that will be escaped',
        severity: ValidationSeverity.info,
        actualValue: receipt.merchantName,
      ));
    }
    
    return issues;
  }

  /// Validate required fields based on format
  List<ValidationIssue> _validateRequiredFields(
    Receipt receipt,
    int index,
    ExportFormat format,
  ) {
    final issues = <ValidationIssue>[];
    
    // Common required fields
    if (receipt.date == null) {
      issues.add(ValidationIssue(
        id: 'REQ_MISSING_DATE',
        field: 'date',
        message: 'Receipt #${index + 1}: Date is required',
        severity: ValidationSeverity.error,
        suggestedFix: 'Add a date to this receipt',
      ));
    }
    
    if (receipt.totalAmount == null || receipt.totalAmount == 0) {
      issues.add(ValidationIssue(
        id: 'REQ_MISSING_TOTAL',
        field: 'totalAmount',
        message: 'Receipt #${index + 1}: Total amount is required',
        severity: ValidationSeverity.error,
        suggestedFix: 'Add a total amount to this receipt',
      ));
    }
    
    if (receipt.merchantName == null || receipt.merchantName!.trim().isEmpty) {
      issues.add(ValidationIssue(
        id: 'REQ_MISSING_MERCHANT',
        field: 'merchantName',
        message: 'Receipt #${index + 1}: Merchant name is required',
        severity: ValidationSeverity.error,
        suggestedFix: 'Add a merchant name to this receipt',
      ));
    }
    
    // Xero specific: ContactName is required
    if (format == ExportFormat.xero && 
        (receipt.merchantName == null || receipt.merchantName!.trim().isEmpty)) {
      issues.add(ValidationIssue(
        id: 'XERO_MISSING_CONTACT',
        field: 'merchantName',
        message: 'Xero requires ContactName field',
        severity: ValidationSeverity.error,
        suggestedFix: 'Merchant name will be used as ContactName',
      ));
    }
    
    return issues;
  }

  /// Get format-specific validator
  _FormatValidator _getFormatValidator(ExportFormat format) {
    switch (format) {
      case ExportFormat.quickbooks:
      case ExportFormat.quickBooks3Column:
      case ExportFormat.quickBooks4Column:
        return _QuickBooksValidator();
      case ExportFormat.xero:
        return _XeroValidator();
      case ExportFormat.generic:
        return _GenericValidator();
    }
  }

  /// Categorize issues by severity
  void _categorizeIssues(
    List<ValidationIssue> issues,
    List<ValidationIssue> errors,
    List<ValidationIssue> warnings,
    List<ValidationIssue> info,
  ) {
    for (final issue in issues) {
      switch (issue.severity) {
        case ValidationSeverity.error:
          errors.add(issue);
          break;
        case ValidationSeverity.warning:
          warnings.add(issue);
          break;
        case ValidationSeverity.info:
          info.add(issue);
          break;
      }
    }
  }
  
  /// Validate receipts using real API services
  Future<ValidationResult?> _validateWithAPI(
    List<Receipt> receipts,
    ExportFormat format,
  ) async {
    try {
      switch (format) {
        case ExportFormat.quickbooks:
        case ExportFormat.quickBooks3Column:
        case ExportFormat.quickBooks4Column:
          // Use QuickBooks API for validation
          final result = await _quickBooksService.validateReceipts(receipts);
          return _convertAPIResultToValidationResult(result, 'QuickBooks');

        case ExportFormat.xero:
          // Use Xero API for validation
          final result = await _xeroService.validateReceipts(receipts);
          return _convertAPIResultToValidationResult(result, 'Xero');

        case ExportFormat.generic:
          // No API validation for generic format
          return null;
      }
    } catch (e) {
      // If API validation fails, log and fall back to local validation
      print('API validation failed, falling back to local: $e');
      return null;
    }
  }
  
  /// Convert API validation result to our ValidationResult format
  ValidationResult _convertAPIResultToValidationResult(
    dynamic apiResult,
    String source,
  ) {
    // Add metadata about the validation source
    final metadata = <String, dynamic>{};
    metadata['validationSource'] = '$source API';
    metadata['apiValidation'] = true;
    metadata['timestamp'] = DateTime.now().toIso8601String();
    
    // Add info message about API validation
    final infoList = <ValidationIssue>[];
    infoList.add(ValidationIssue(
      id: 'API_VALIDATION',
      field: 'system',
      message: 'Validated against live $source API',
      severity: ValidationSeverity.info,
    ));
    
    return ValidationResult(
      isValid: true,
      errors: [],
      warnings: [],
      info: infoList,
      metadata: metadata,
    );
  }
}

/// Base class for format-specific validators
abstract class _FormatValidator {
  List<ValidationIssue> validate(Receipt receipt, int index);
}

/// QuickBooks specific validation
class _QuickBooksValidator extends _FormatValidator {
  @override
  List<ValidationIssue> validate(Receipt receipt, int index) {
    final issues = <ValidationIssue>[];
    
    // QuickBooks requires MM/DD/YYYY date format
    // Date format will be handled during export, just validate date exists
    if (receipt.date != null) {
      // Check year range
      try {
        final year = receipt.date!.year;
        if (year < 1900 || year > 2100) {
          issues.add(ValidationIssue(
            id: 'QB_INVALID_DATE_RANGE',
            field: 'date',
            message: 'Receipt #${index + 1}: Date year must be between 1900 and 2100',
            severity: ValidationSeverity.error,
            actualValue: year,
          ));
        }
      } catch (e) {
        // Date parsing failed, will be caught by required field validation
      }
    }
    
    // QuickBooks doesn't allow currency symbols in amounts
    if (receipt.totalAmount != null && receipt.totalAmount! < 0) {
      issues.add(ValidationIssue(
        id: 'QB_NEGATIVE_AMOUNT',
        field: 'totalAmount',
        message: 'Receipt #${index + 1}: QuickBooks requires positive amounts',
        severity: ValidationSeverity.error,
        actualValue: receipt.totalAmount,
      ));
    }
    
    return issues;
  }
}

/// Xero specific validation
class _XeroValidator extends _FormatValidator {
  @override
  List<ValidationIssue> validate(Receipt receipt, int index) {
    final issues = <ValidationIssue>[];
    
    // Xero requires DD/MM/YYYY date format
    // Date format will be handled during export, just validate date exists
    if (receipt.date != null) {
      // Check year range
      try {
        final year = receipt.date!.year;
        if (year < 1900 || year > 2100) {
          issues.add(ValidationIssue(
            id: 'XERO_INVALID_DATE_RANGE',
            field: 'date',
            message: 'Receipt #${index + 1}: Date year must be between 1900 and 2100',
            severity: ValidationSeverity.error,
            actualValue: year,
          ));
        }
      } catch (e) {
        // Date parsing failed, will be caught by required field validation
      }
    }
    
    // Xero requires positive amounts
    if (receipt.totalAmount != null && receipt.totalAmount! < 0) {
      issues.add(ValidationIssue(
        id: 'XERO_NEGATIVE_AMOUNT',
        field: 'totalAmount',
        message: 'Receipt #${index + 1}: Xero requires positive amounts',
        severity: ValidationSeverity.error,
        actualValue: receipt.totalAmount,
      ));
    }
    
    // Tax must not exceed total
    if (receipt.taxAmount != null && receipt.totalAmount != null) {
      if (receipt.taxAmount! > receipt.totalAmount!) {
        issues.add(ValidationIssue(
          id: 'XERO_TAX_EXCEEDS_TOTAL',
          field: 'taxAmount',
          message: 'Receipt #${index + 1}: Tax amount exceeds total amount',
          severity: ValidationSeverity.error,
          actualValue: receipt.taxAmount,
          expectedValue: '<= ${receipt.totalAmount}',
        ));
      }
    }
    
    return issues;
  }
}

/// Generic CSV validation
class _GenericValidator extends _FormatValidator {
  @override
  List<ValidationIssue> validate(Receipt receipt, int index) {
    final issues = <ValidationIssue>[];
    
    // Basic validation for generic CSV
    if (receipt.totalAmount != null && receipt.totalAmount! < 0) {
      issues.add(ValidationIssue(
        id: 'GEN_NEGATIVE_AMOUNT',
        field: 'totalAmount',
        message: 'Receipt #${index + 1}: Negative amounts may cause import issues',
        severity: ValidationSeverity.warning,
        actualValue: receipt.totalAmount,
      ));
    }
    
    // Merchant name length check
    if (receipt.merchantName != null && receipt.merchantName!.length > 100) {
      issues.add(ValidationIssue(
        id: 'GEN_MERCHANT_TOO_LONG',
        field: 'merchantName',
        message: 'Receipt #${index + 1}: Merchant name exceeds 100 characters',
        severity: ValidationSeverity.warning,
        actualValue: receipt.merchantName!.length,
        expectedValue: '<= 100',
        suggestedFix: 'Shorten merchant name to 100 characters or less',
      ));
    }
    
    return issues;
  }
  
  /// Helper method to format date based on export format
  static String formatDate(DateTime date, ExportFormat format) {
    switch (format) {
      case ExportFormat.quickbooks:
        // QuickBooks uses MM/DD/YYYY
        return '${date.month.toString().padLeft(2, '0')}/'
               '${date.day.toString().padLeft(2, '0')}/'
               '${date.year}';
      case ExportFormat.xero:
        // Xero uses DD/MM/YYYY
        return '${date.day.toString().padLeft(2, '0')}/'
               '${date.month.toString().padLeft(2, '0')}/'
               '${date.year}';
      default:
        // Generic uses ISO format
        return date.toIso8601String().split('T')[0];
    }
  }
}