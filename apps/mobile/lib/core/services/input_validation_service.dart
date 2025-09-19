import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Comprehensive input validation service
class InputValidationService {
  // Validation patterns
  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _phonePattern = RegExp(
    r'^\+?[\d\s\-\(\)]+$',
  );

  static final RegExp _urlPattern = RegExp(
    r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
  );

  static final RegExp _alphanumericPattern = RegExp(r'^[a-zA-Z0-9]+$');

  static final RegExp _noSpecialCharsPattern = RegExp(r'^[a-zA-Z0-9\s]+$');

  // SQL injection patterns
  static final List<RegExp> _sqlInjectionPatterns = [
    RegExp(r"(\b(SELECT|UPDATE|DELETE|INSERT|DROP|CREATE|ALTER|EXEC|EXECUTE|UNION|FROM|WHERE)\b)", caseSensitive: false),
    RegExp(r"(--|#|\/\*|\*\/)", caseSensitive: false),
    RegExp(r"(\bOR\b.*=.*)", caseSensitive: false),
    RegExp(r"('|(\\x27)|(\\x22)|(\\x22))", caseSensitive: false),
  ];

  // XSS patterns
  static final List<RegExp> _xssPatterns = [
    RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false),
    RegExp(r'<iframe[^>]*>.*?</iframe>', caseSensitive: false),
    RegExp(r'javascript:', caseSensitive: false),
    RegExp(r'on\w+\s*=', caseSensitive: false),
    RegExp(r'<img[^>]*onerror[^>]*>', caseSensitive: false),
  ];

  /// Validate email address
  static ValidationResult validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Email is required',
      );
    }

    final trimmed = email.trim().toLowerCase();

    if (trimmed.length > 254) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Email is too long',
      );
    }

    if (!_emailPattern.hasMatch(trimmed)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Invalid email format',
      );
    }

    // Check for suspicious patterns
    if (_containsSqlInjection(trimmed) || _containsXss(trimmed)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Invalid characters detected',
        isSuspicious: true,
      );
    }

    return ValidationResult(
      isValid: true,
      sanitizedValue: trimmed,
    );
  }

  /// Validate phone number
  static ValidationResult validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Phone number is required',
      );
    }

    final cleaned = phone.replaceAll(RegExp(r'\s+'), '');

    if (cleaned.length < 7 || cleaned.length > 15) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Invalid phone number length',
      );
    }

    if (!_phonePattern.hasMatch(cleaned)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Invalid phone number format',
      );
    }

    return ValidationResult(
      isValid: true,
      sanitizedValue: cleaned,
    );
  }

  /// Validate amount/currency
  static ValidationResult validateAmount(String? amount, {
    double? min,
    double? max,
    int decimalPlaces = 2,
  }) {
    if (amount == null || amount.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Amount is required',
      );
    }

    // Remove currency symbols and spaces
    final cleaned = amount.replaceAll(RegExp(r'[^\d\.\-]'), '');

    double? value;
    try {
      value = double.parse(cleaned);
    } catch (_) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Invalid amount format',
      );
    }

    if (min != null && value < min) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Amount must be at least $min',
      );
    }

    if (max != null && value > max) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Amount must not exceed $max',
      );
    }

    // Check decimal places
    final parts = cleaned.split('.');
    if (parts.length > 1 && parts[1].length > decimalPlaces) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Maximum $decimalPlaces decimal places allowed',
      );
    }

    return ValidationResult(
      isValid: true,
      sanitizedValue: value.toStringAsFixed(decimalPlaces),
      parsedValue: value,
    );
  }

  /// Validate vendor/merchant name
  static ValidationResult validateVendorName(String? name) {
    if (name == null || name.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Vendor name is required',
      );
    }

    final trimmed = name.trim();

    if (trimmed.length < 2) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Vendor name is too short',
      );
    }

    if (trimmed.length > 100) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Vendor name is too long',
      );
    }

    // Check for suspicious patterns
    if (_containsSqlInjection(trimmed) || _containsXss(trimmed)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Invalid characters detected',
        isSuspicious: true,
      );
    }

    // Sanitize by escaping HTML entities
    final sanitized = _escapeHtml(trimmed);

    return ValidationResult(
      isValid: true,
      sanitizedValue: sanitized,
    );
  }

  /// Validate notes/description
  static ValidationResult validateNotes(String? notes, {
    int maxLength = 500,
  }) {
    if (notes == null || notes.isEmpty) {
      // Notes are optional
      return ValidationResult(isValid: true);
    }

    final trimmed = notes.trim();

    if (trimmed.length > maxLength) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Notes must not exceed $maxLength characters',
      );
    }

    // Check for suspicious patterns
    if (_containsSqlInjection(trimmed) || _containsXss(trimmed)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Invalid characters detected',
        isSuspicious: true,
      );
    }

    // Sanitize
    final sanitized = _escapeHtml(trimmed);

    return ValidationResult(
      isValid: true,
      sanitizedValue: sanitized,
    );
  }

  /// Validate date
  static ValidationResult validateDate(DateTime? date, {
    DateTime? minDate,
    DateTime? maxDate,
    bool allowFuture = false,
  }) {
    if (date == null) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Date is required',
      );
    }

    if (!allowFuture && date.isAfter(DateTime.now())) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Future dates are not allowed',
      );
    }

    if (minDate != null && date.isBefore(minDate)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Date is too far in the past',
      );
    }

    if (maxDate != null && date.isAfter(maxDate)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Date is too far in the future',
      );
    }

    return ValidationResult(
      isValid: true,
      parsedValue: date,
    );
  }

  /// Validate URL
  static ValidationResult validateUrl(String? url) {
    if (url == null || url.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'URL is required',
      );
    }

    final trimmed = url.trim().toLowerCase();

    if (!_urlPattern.hasMatch(trimmed)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Invalid URL format',
      );
    }

    // Check for suspicious patterns
    if (_containsXss(trimmed)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Invalid URL detected',
        isSuspicious: true,
      );
    }

    return ValidationResult(
      isValid: true,
      sanitizedValue: trimmed,
    );
  }

  /// Validate file path
  static ValidationResult validateFilePath(String? path) {
    if (path == null || path.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'File path is required',
      );
    }

    // Check for path traversal attempts
    if (path.contains('..') || path.contains('~')) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Invalid file path',
        isSuspicious: true,
      );
    }

    // Check for null bytes
    if (path.contains('\x00')) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Invalid file path',
        isSuspicious: true,
      );
    }

    return ValidationResult(
      isValid: true,
      sanitizedValue: path,
    );
  }

  /// Check for SQL injection patterns
  static bool _containsSqlInjection(String input) {
    for (final pattern in _sqlInjectionPatterns) {
      if (pattern.hasMatch(input)) {
        return true;
      }
    }
    return false;
  }

  /// Check for XSS patterns
  static bool _containsXss(String input) {
    for (final pattern in _xssPatterns) {
      if (pattern.hasMatch(input)) {
        return true;
      }
    }
    return false;
  }

  /// Escape HTML entities
  static String _escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  /// Validate form with multiple fields
  static FormValidationResult validateForm(Map<String, dynamic> formData, {
    required Map<String, FieldValidator> validators,
  }) {
    final errors = <String, String>{};
    final sanitizedData = <String, dynamic>{};
    bool hasErrors = false;
    bool hasSuspiciousInput = false;

    for (final entry in validators.entries) {
      final fieldName = entry.key;
      final validator = entry.value;
      final value = formData[fieldName];

      final result = validator(value);

      if (!result.isValid) {
        hasErrors = true;
        errors[fieldName] = result.errorMessage!;
      } else {
        sanitizedData[fieldName] = result.sanitizedValue ?? value;
      }

      if (result.isSuspicious) {
        hasSuspiciousInput = true;
      }
    }

    return FormValidationResult(
      isValid: !hasErrors,
      errors: errors,
      sanitizedData: sanitizedData,
      hasSuspiciousInput: hasSuspiciousInput,
    );
  }
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? sanitizedValue;
  final dynamic parsedValue;
  final bool isSuspicious;

  ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.sanitizedValue,
    this.parsedValue,
    this.isSuspicious = false,
  });
}

/// Form validation result
class FormValidationResult {
  final bool isValid;
  final Map<String, String> errors;
  final Map<String, dynamic> sanitizedData;
  final bool hasSuspiciousInput;

  FormValidationResult({
    required this.isValid,
    required this.errors,
    required this.sanitizedData,
    required this.hasSuspiciousInput,
  });
}

/// Field validator function type
typedef FieldValidator = ValidationResult Function(dynamic value);

/// Custom text input formatters
class ValidatedInputFormatters {
  /// Amount input formatter
  static TextInputFormatter amountFormatter({
    int decimalPlaces = 2,
  }) {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      if (newValue.text.isEmpty) return newValue;

      // Allow only digits and one decimal point
      final regex = RegExp(r'^\d*\.?\d*$');
      if (!regex.hasMatch(newValue.text)) {
        return oldValue;
      }

      // Check decimal places
      if (newValue.text.contains('.')) {
        final parts = newValue.text.split('.');
        if (parts.length > 2) return oldValue;
        if (parts.length == 2 && parts[1].length > decimalPlaces) {
          return oldValue;
        }
      }

      return newValue;
    });
  }

  /// Phone number formatter
  static TextInputFormatter phoneFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      if (newValue.text.isEmpty) return newValue;

      // Allow only digits, spaces, dashes, parentheses, and plus
      final regex = RegExp(r'^[\d\s\-\(\)\+]*$');
      if (!regex.hasMatch(newValue.text)) {
        return oldValue;
      }

      return newValue;
    });
  }

  /// Alphanumeric only formatter
  static TextInputFormatter alphanumericFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      if (newValue.text.isEmpty) return newValue;

      final regex = RegExp(r'^[a-zA-Z0-9]*$');
      if (!regex.hasMatch(newValue.text)) {
        return oldValue;
      }

      return newValue;
    });
  }

  /// No special characters formatter
  static TextInputFormatter noSpecialCharsFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      if (newValue.text.isEmpty) return newValue;

      final regex = RegExp(r'^[a-zA-Z0-9\s]*$');
      if (!regex.hasMatch(newValue.text)) {
        return oldValue;
      }

      return newValue;
    });
  }

  /// Maximum length formatter with callback
  static TextInputFormatter maxLengthFormatter(
    int maxLength, {
    Function()? onMaxLengthReached,
  }) {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      if (newValue.text.length > maxLength) {
        onMaxLengthReached?.call();
        return oldValue;
      }
      return newValue;
    });
  }
}