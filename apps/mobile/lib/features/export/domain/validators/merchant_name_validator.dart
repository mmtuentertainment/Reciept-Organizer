import '../export_validator.dart';

/// Validates merchant name fields for export and security
class MerchantNameValidator {
  static const int maxLength = 100;
  static const int minLength = 1;
  
  // CSV injection patterns - CRITICAL SECURITY
  static final RegExp _csvInjectionPattern = RegExp(
    r'^[=+\-@\t\r]|[\n\r]',
    multiLine: true,
  );
  
  // Special characters that need escaping in CSV
  static final RegExp _csvSpecialChars = RegExp(r'[,"\n\r]');
  
  // Characters that might break imports
  static final RegExp _problematicChars = RegExp(
    r'[<>|\\:*?/]',
  );
  
  /// Validate merchant name for security and format issues
  ValidationIssue? validateMerchantName(
    String? merchantName,
    int receiptIndex,
    ExportFormat format,
  ) {
    if (merchantName == null || merchantName.trim().isEmpty) {
      return ValidationIssue(
        id: 'MERCHANT_EMPTY',
        field: 'merchantName',
        message: 'Receipt #${receiptIndex + 1}: Merchant name is required',
        severity: ValidationSeverity.error,
        suggestedFix: 'Add a merchant name to this receipt',
      );
    }
    
    final trimmed = merchantName.trim();
    
    // CRITICAL: Check for CSV injection
    if (_csvInjectionPattern.hasMatch(trimmed)) {
      return ValidationIssue(
        id: 'MERCHANT_CSV_INJECTION',
        field: 'merchantName',
        message: 'Receipt #${receiptIndex + 1}: Merchant name contains dangerous characters',
        severity: ValidationSeverity.error,
        actualValue: merchantName,
        suggestedFix: 'Remove special characters (=, +, -, @, tab, newline) from the beginning',
      );
    }
    
    // Check length
    if (trimmed.length > maxLength) {
      return ValidationIssue(
        id: 'MERCHANT_TOO_LONG',
        field: 'merchantName',
        message: 'Receipt #${receiptIndex + 1}: Merchant name exceeds $maxLength characters',
        severity: ValidationSeverity.warning,
        actualValue: '${trimmed.length} characters',
        expectedValue: '<= $maxLength characters',
        suggestedFix: 'Shorten merchant name to $maxLength characters or less',
      );
    }
    
    // Check for problematic characters
    if (_problematicChars.hasMatch(trimmed)) {
      return ValidationIssue(
        id: 'MERCHANT_PROBLEMATIC_CHARS',
        field: 'merchantName',
        message: 'Receipt #${receiptIndex + 1}: Merchant name contains characters that may cause import issues',
        severity: ValidationSeverity.warning,
        actualValue: merchantName,
        suggestedFix: 'Remove or replace special characters: < > | \\ : * ? /',
      );
    }
    
    // Info about characters that will be escaped
    if (_csvSpecialChars.hasMatch(trimmed)) {
      return ValidationIssue(
        id: 'MERCHANT_WILL_ESCAPE',
        field: 'merchantName',
        message: 'Receipt #${receiptIndex + 1}: Merchant name contains characters that will be escaped',
        severity: ValidationSeverity.info,
        actualValue: merchantName,
      );
    }
    
    // Format-specific validation
    if (format == ExportFormat.xero) {
      return _validateXeroMerchantName(trimmed, receiptIndex);
    }
    
    return null;
  }
  
  /// Sanitize merchant name for safe CSV export
  String sanitizeMerchantName(String merchantName) {
    var sanitized = merchantName.trim();
    
    // Remove CSV injection characters from the beginning
    while (sanitized.isNotEmpty && _csvInjectionPattern.hasMatch(sanitized[0])) {
      sanitized = sanitized.substring(1);
    }
    
    // Replace problematic characters
    sanitized = sanitized.replaceAll(_problematicChars, '_');
    
    // Truncate if too long
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }
    
    // Ensure not empty after sanitization
    if (sanitized.isEmpty) {
      sanitized = 'Unknown Merchant';
    }
    
    return sanitized;
  }
  
  /// Escape merchant name for CSV export
  String escapeMerchantNameForCSV(String merchantName) {
    // If contains special CSV characters, wrap in quotes and escape internal quotes
    if (_csvSpecialChars.hasMatch(merchantName)) {
      final escaped = merchantName.replaceAll('"', '""');
      return '"$escaped"';
    }
    return merchantName;
  }
  
  ValidationIssue? _validateXeroMerchantName(
    String merchantName,
    int receiptIndex,
  ) {
    // Xero uses merchant name as ContactName, which is required
    if (merchantName.isEmpty) {
      return ValidationIssue(
        id: 'XERO_CONTACT_REQUIRED',
        field: 'merchantName',
        message: 'Receipt #${receiptIndex + 1}: Xero requires ContactName (merchant name)',
        severity: ValidationSeverity.error,
        suggestedFix: 'Add a merchant name for Xero ContactName field',
      );
    }
    return null;
  }
}