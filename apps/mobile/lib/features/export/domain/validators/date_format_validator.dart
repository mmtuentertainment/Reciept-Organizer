import 'package:intl/intl.dart';
import '../export_validator.dart';
import '../../services/export_format_validator.dart' show ExportFormat;

/// Validates and converts date formats for different export targets
class DateFormatValidator {
  static const String quickBooksFormat = 'MM/dd/yyyy';
  static const String xeroFormat = 'dd/MM/yyyy';
  static const String isoFormat = 'yyyy-MM-dd';
  
  final DateFormat _qbFormatter = DateFormat(quickBooksFormat);
  final DateFormat _xeroFormatter = DateFormat(xeroFormat);
  final DateFormat _isoFormatter = DateFormat(isoFormat);
  
  /// Validate date and return issues if any
  ValidationIssue? validateDate(
    DateTime? date,
    ExportFormat format,
    int receiptIndex,
  ) {
    if (date == null) {
      return ValidationIssue(
        id: 'DATE_NULL',
        field: 'date',
        message: 'Receipt #${receiptIndex + 1}: Date is missing',
        severity: ValidationSeverity.error,
        suggestedFix: 'Add a date to this receipt',
      );
    }
    
    final now = DateTime.now();
    final twoYearsAgo = DateTime(now.year - 2, now.month, now.day);
    
    // Check if date is in the future
    if (date.isAfter(now)) {
      return ValidationIssue(
        id: 'DATE_FUTURE',
        field: 'date',
        message: 'Receipt #${receiptIndex + 1}: Date is in the future',
        severity: ValidationSeverity.error,
        actualValue: formatDate(date, format),
        suggestedFix: 'Use a date on or before today',
      );
    }
    
    // Check if date is too old (warning only)
    if (date.isBefore(twoYearsAgo)) {
      return ValidationIssue(
        id: 'DATE_OLD',
        field: 'date',
        message: 'Receipt #${receiptIndex + 1}: Date is older than 2 years',
        severity: ValidationSeverity.warning,
        actualValue: formatDate(date, format),
        suggestedFix: 'Receipts older than 2 years may not be accepted for tax purposes',
      );
    }
    
    // Check for specific format requirements
    if (format == ExportFormat.quickbooks) {
      return _validateQuickBooksDate(date, receiptIndex);
    } else if (format == ExportFormat.xero) {
      return _validateXeroDate(date, receiptIndex);
    }
    
    return null;
  }
  
  /// Format date according to export format
  String formatDate(DateTime date, ExportFormat format) {
    switch (format) {
      case ExportFormat.quickbooks:
      case ExportFormat.quickBooks3Column:
      case ExportFormat.quickBooks4Column:
        return _qbFormatter.format(date);
      case ExportFormat.xero:
        return _xeroFormatter.format(date);
      case ExportFormat.generic:
        return _isoFormatter.format(date);
    }
  }
  
  /// Detect date format from string
  ExportFormat? detectFormat(String dateString) {
    // Try to parse as QuickBooks format (MM/DD/YYYY)
    try {
      _qbFormatter.parseStrict(dateString);
      return ExportFormat.quickbooks;
    } catch (_) {}
    
    // Try to parse as Xero format (DD/MM/YYYY)
    try {
      _xeroFormatter.parseStrict(dateString);
      return ExportFormat.xero;
    } catch (_) {}
    
    // Try ISO format
    try {
      _isoFormatter.parseStrict(dateString);
      return ExportFormat.generic;
    } catch (_) {}
    
    return null;
  }
  
  /// Convert date string between formats
  String? convertDateFormat(
    String dateString,
    ExportFormat fromFormat,
    ExportFormat toFormat,
  ) {
    try {
      DateTime date;
      
      // Parse from source format
      switch (fromFormat) {
        case ExportFormat.quickbooks:
        case ExportFormat.quickBooks3Column:
        case ExportFormat.quickBooks4Column:
          date = _qbFormatter.parseStrict(dateString);
          break;
        case ExportFormat.xero:
          date = _xeroFormatter.parseStrict(dateString);
          break;
        case ExportFormat.generic:
          date = _isoFormatter.parseStrict(dateString);
          break;
      }
      
      // Format to target format
      return formatDate(date, toFormat);
    } catch (e) {
      return null;
    }
  }
  
  ValidationIssue? _validateQuickBooksDate(DateTime date, int receiptIndex) {
    // QuickBooks specific date validation
    if (date.year < 1900) {
      return ValidationIssue(
        id: 'QB_DATE_TOO_OLD',
        field: 'date',
        message: 'Receipt #${receiptIndex + 1}: QuickBooks requires dates after 1900',
        severity: ValidationSeverity.error,
        actualValue: date.year,
        expectedValue: '>= 1900',
      );
    }
    return null;
  }
  
  ValidationIssue? _validateXeroDate(DateTime date, int receiptIndex) {
    // Xero specific date validation
    if (date.year < 1900) {
      return ValidationIssue(
        id: 'XERO_DATE_TOO_OLD',
        field: 'date',
        message: 'Receipt #${receiptIndex + 1}: Xero requires dates after 1900',
        severity: ValidationSeverity.error,
        actualValue: date.year,
        expectedValue: '>= 1900',
      );
    }
    return null;
  }
}