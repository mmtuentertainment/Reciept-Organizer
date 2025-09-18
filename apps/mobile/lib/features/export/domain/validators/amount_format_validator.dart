import '../export_validator.dart';
import '../../services/export_format_validator.dart' show ExportFormat;

/// Validates amount fields for export
class AmountFormatValidator {
  static const int maxDecimalPlaces = 2;
  static const double maxAmount = 9999999.99;
  static const double minAmount = 0.0;
  
  /// Validate amount format
  ValidationIssue? validateAmount(
    double? amount,
    String fieldName,
    int receiptIndex,
    ExportFormat format,
  ) {
    if (amount == null) {
      return ValidationIssue(
        id: 'AMOUNT_NULL',
        field: fieldName,
        message: 'Receipt #${receiptIndex + 1}: $fieldName is missing',
        severity: fieldName == 'totalAmount' 
            ? ValidationSeverity.error 
            : ValidationSeverity.warning,
        suggestedFix: 'Add $fieldName to this receipt',
      );
    }
    
    // Check for negative amounts
    if (amount < minAmount) {
      return ValidationIssue(
        id: 'AMOUNT_NEGATIVE',
        field: fieldName,
        message: 'Receipt #${receiptIndex + 1}: $fieldName cannot be negative',
        severity: ValidationSeverity.error,
        actualValue: amount,
        expectedValue: '>= 0',
        suggestedFix: 'Use positive amounts only',
      );
    }
    
    // Check for excessive amounts
    if (amount > maxAmount) {
      return ValidationIssue(
        id: 'AMOUNT_TOO_LARGE',
        field: fieldName,
        message: 'Receipt #${receiptIndex + 1}: $fieldName exceeds maximum allowed',
        severity: ValidationSeverity.error,
        actualValue: amount,
        expectedValue: '<= $maxAmount',
        suggestedFix: 'Reduce amount to less than \$${maxAmount.toStringAsFixed(2)}',
      );
    }
    
    // Check decimal places
    final decimalPlaces = _getDecimalPlaces(amount);
    if (decimalPlaces > maxDecimalPlaces) {
      return ValidationIssue(
        id: 'AMOUNT_DECIMAL_PLACES',
        field: fieldName,
        message: 'Receipt #${receiptIndex + 1}: $fieldName has too many decimal places',
        severity: ValidationSeverity.warning,
        actualValue: '$decimalPlaces decimal places',
        expectedValue: '<= $maxDecimalPlaces decimal places',
        suggestedFix: 'Round to 2 decimal places',
      );
    }
    
    // Format-specific validation
    if (format == ExportFormat.quickbooks) {
      return _validateQuickBooksAmount(amount, fieldName, receiptIndex);
    } else if (format == ExportFormat.xero) {
      return _validateXeroAmount(amount, fieldName, receiptIndex);
    }
    
    return null;
  }
  
  /// Validate tax amount specifically
  ValidationIssue? validateTaxAmount(
    double? taxAmount,
    double? totalAmount,
    int receiptIndex,
  ) {
    if (taxAmount == null) {
      return null; // Tax is optional
    }
    
    if (totalAmount == null) {
      return ValidationIssue(
        id: 'TAX_NO_TOTAL',
        field: 'taxAmount',
        message: 'Receipt #${receiptIndex + 1}: Tax amount specified without total amount',
        severity: ValidationSeverity.error,
        suggestedFix: 'Add total amount or remove tax amount',
      );
    }
    
    if (taxAmount > totalAmount) {
      return ValidationIssue(
        id: 'TAX_EXCEEDS_TOTAL',
        field: 'taxAmount',
        message: 'Receipt #${receiptIndex + 1}: Tax amount exceeds total amount',
        severity: ValidationSeverity.error,
        actualValue: taxAmount,
        expectedValue: '<= $totalAmount',
        suggestedFix: 'Tax amount must be less than or equal to total amount',
      );
    }
    
    // Warning if tax is unusually high (>30% of total)
    final taxPercentage = (taxAmount / totalAmount) * 100;
    if (taxPercentage > 30) {
      return ValidationIssue(
        id: 'TAX_HIGH_PERCENTAGE',
        field: 'taxAmount',
        message: 'Receipt #${receiptIndex + 1}: Tax is ${taxPercentage.toStringAsFixed(1)}% of total',
        severity: ValidationSeverity.warning,
        actualValue: taxAmount,
        suggestedFix: 'Verify tax amount is correct',
      );
    }
    
    return null;
  }
  
  /// Format amount for export (2 decimal places, no currency symbol)
  String formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }
  
  /// Clean amount string for parsing
  double? parseAmount(String amountString) {
    // Remove currency symbols and whitespace
    final cleaned = amountString
        .replaceAll(RegExp(r'[$£€¥₹,\s]'), '')
        .trim();
    
    if (cleaned.isEmpty) {
      return null;
    }
    
    try {
      return double.parse(cleaned);
    } catch (e) {
      return null;
    }
  }
  
  int _getDecimalPlaces(double amount) {
    final str = amount.toString();
    final decimalIndex = str.indexOf('.');
    if (decimalIndex == -1) {
      return 0;
    }
    return str.length - decimalIndex - 1;
  }
  
  ValidationIssue? _validateQuickBooksAmount(
    double amount,
    String fieldName,
    int receiptIndex,
  ) {
    // QuickBooks specific validation
    // QuickBooks handles amounts well, just ensure no currency symbols in export
    return null;
  }
  
  ValidationIssue? _validateXeroAmount(
    double amount,
    String fieldName,
    int receiptIndex,
  ) {
    // Xero specific validation
    // Xero requires decimal separator to be period
    return null;
  }
}