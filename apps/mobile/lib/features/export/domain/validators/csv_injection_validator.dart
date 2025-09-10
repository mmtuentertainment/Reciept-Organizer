import '../export_validator.dart';

/// Security-focused validator to prevent CSV injection attacks
/// 
/// CRITICAL: This validator is essential for preventing remote code execution
/// in spreadsheet applications that process our exported CSV files.
class CSVInjectionValidator {
  // OWASP CSV Injection patterns
  // Characters that can trigger formula execution in Excel/Sheets
  static final List<String> _dangerousPrefixes = [
    '=',  // Excel formula
    '+',  // Formula
    '-',  // Formula
    '@',  // Formula in some contexts
    '\t', // Tab (can be used in attacks)
    '\r', // Carriage return
    '\n', // Newline
  ];
  
  // Additional patterns that might be dangerous
  static final RegExp _formulaPattern = RegExp(
    r'(?:=|\+|-|@).*(?:cmd|exec|system|eval|powershell|script)',
    caseSensitive: false,
  );
  
  // Hyperlink patterns that could be malicious
  static final RegExp _hyperlinkPattern = RegExp(
    r'(?:=HYPERLINK|https?://|ftp://|file://)',
    caseSensitive: false,
  );
  
  // DDE (Dynamic Data Exchange) patterns
  static final RegExp _ddePattern = RegExp(
    r'(?:=DDE|cmd\.exe|powershell|bash|sh\s)',
    caseSensitive: false,
  );
  
  /// Validate a field for CSV injection vulnerabilities
  ValidationIssue? validateField(
    String? value,
    String fieldName,
    int receiptIndex,
  ) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    // Check for dangerous prefixes
    final firstChar = value.isNotEmpty ? value[0] : '';
    if (_dangerousPrefixes.contains(firstChar)) {
      return ValidationIssue(
        id: 'SEC_CSV_INJECTION_PREFIX',
        field: fieldName,
        message: 'Receipt #${receiptIndex + 1}: $fieldName starts with dangerous character',
        severity: ValidationSeverity.error,
        actualValue: value,
        suggestedFix: 'Remove or replace the "$firstChar" at the beginning',
      );
    }
    
    // Check for formula patterns
    if (_formulaPattern.hasMatch(value)) {
      return ValidationIssue(
        id: 'SEC_CSV_INJECTION_FORMULA',
        field: fieldName,
        message: 'Receipt #${receiptIndex + 1}: $fieldName contains potential formula injection',
        severity: ValidationSeverity.error,
        actualValue: value,
        suggestedFix: 'Remove formula-like patterns from the text',
      );
    }
    
    // Check for suspicious hyperlinks
    if (_hyperlinkPattern.hasMatch(value)) {
      return ValidationIssue(
        id: 'SEC_CSV_INJECTION_HYPERLINK',
        field: fieldName,
        message: 'Receipt #${receiptIndex + 1}: $fieldName contains hyperlink patterns',
        severity: ValidationSeverity.warning,
        actualValue: value,
        suggestedFix: 'Remove or validate hyperlink patterns',
      );
    }
    
    // Check for DDE patterns
    if (_ddePattern.hasMatch(value)) {
      return ValidationIssue(
        id: 'SEC_CSV_INJECTION_DDE',
        field: fieldName,
        message: 'Receipt #${receiptIndex + 1}: $fieldName contains potential DDE injection',
        severity: ValidationSeverity.error,
        actualValue: value,
        suggestedFix: 'Remove command execution patterns',
      );
    }
    
    // Check for pipe character (used in some injection techniques)
    if (value.contains('|')) {
      return ValidationIssue(
        id: 'SEC_CSV_INJECTION_PIPE',
        field: fieldName,
        message: 'Receipt #${receiptIndex + 1}: $fieldName contains pipe character',
        severity: ValidationSeverity.warning,
        actualValue: value,
        suggestedFix: 'Replace pipe character (|) with alternative',
      );
    }
    
    return null;
  }
  
  /// Sanitize a value to prevent CSV injection
  String sanitizeValue(String value) {
    if (value.isEmpty) {
      return value;
    }
    
    var sanitized = value;
    
    // Remove dangerous prefixes
    while (sanitized.isNotEmpty && _isDangerousPrefix(sanitized[0])) {
      sanitized = sanitized.substring(1);
    }
    
    // If the entire string was dangerous, return a safe placeholder
    if (sanitized.isEmpty) {
      return '[Sanitized]';
    }
    
    // Prefix with single quote to prevent formula execution
    // This is a common mitigation technique
    if (_requiresPrefixing(sanitized)) {
      sanitized = "'$sanitized";
    }
    
    return sanitized;
  }
  
  /// Check if a character is dangerous as a prefix
  bool _isDangerousPrefix(String char) {
    return _dangerousPrefixes.contains(char);
  }
  
  /// Check if a value requires prefixing for safety
  bool _requiresPrefixing(String value) {
    if (value.isEmpty) {
      return false;
    }
    
    // Check if it matches any dangerous patterns
    return _formulaPattern.hasMatch(value) ||
           _ddePattern.hasMatch(value) ||
           _hyperlinkPattern.hasMatch(value);
  }
  
  /// Validate all text fields in a receipt for CSV injection
  List<ValidationIssue> validateReceipt(
    Map<String, String?> fields,
    int receiptIndex,
  ) {
    final issues = <ValidationIssue>[];
    
    fields.forEach((fieldName, value) {
      final issue = validateField(value, fieldName, receiptIndex);
      if (issue != null) {
        issues.add(issue);
      }
    });
    
    return issues;
  }
  
  /// Get a safe version of the value for display
  String getSafeDisplayValue(String value) {
    if (value.length > 50) {
      return '${value.substring(0, 47)}...';
    }
    return value;
  }
}