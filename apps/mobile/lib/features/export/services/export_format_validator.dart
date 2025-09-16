import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

/// Comprehensive export format validator for multiple accounting systems
class ExportFormatValidator {
  /// Supported export formats
  static const Map<String, ExportFormat> formats = {
    'quickbooks_3col': ExportFormat.quickBooks3Column,
    'quickbooks_4col': ExportFormat.quickBooks4Column,
    'xero': ExportFormat.xero,
    'generic': ExportFormat.generic,
  };

  /// Validate CSV content for a specific format
  static ValidationResult validateFormat(
    String csvContent,
    ExportFormat format,
  ) {
    switch (format) {
      case ExportFormat.quickBooks3Column:
        return _validateQuickBooks3Column(csvContent);
      case ExportFormat.quickBooks4Column:
        return _validateQuickBooks4Column(csvContent);
      case ExportFormat.xero:
        return _validateXero(csvContent);
      case ExportFormat.generic:
        return _validateGeneric(csvContent);
    }
  }

  /// Validate QuickBooks 3-column format
  static ValidationResult _validateQuickBooks3Column(String csvContent) {
    final result = ValidationResult();

    try {
      final rows = const CsvToListConverter().convert(csvContent);

      if (rows.isEmpty) {
        result.addError('CSV file is empty');
        return result;
      }

      // Check headers
      final headers = rows[0].map((h) => h.toString().toLowerCase()).toList();
      if (!_validateHeaders(headers, ['date', 'description', 'amount'])) {
        result.addError('Invalid headers. Expected: Date, Description, Amount');
      }

      // Validate each row
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];

        if (row.length != 3) {
          result.addError('Row ${i + 1}: Expected 3 columns, found ${row.length}');
          continue;
        }

        // Validate date (MM/DD/YYYY)
        if (!_isValidQuickBooksDate(row[0].toString())) {
          result.addError('Row ${i + 1}: Invalid date format. Expected MM/DD/YYYY');
        }

        // Validate amount
        if (!_isValidAmount(row[2].toString())) {
          result.addError('Row ${i + 1}: Invalid amount format');
        }

        // Check for CSV injection
        if (_containsCSVInjection(row[1].toString())) {
          result.addWarning('Row ${i + 1}: Contains potentially dangerous characters');
        }

        // Check field lengths
        if (row[1].toString().length > 4000) {
          result.addWarning('Row ${i + 1}: Description exceeds 4000 character limit');
        }
      }

      // Check batch size
      if (rows.length > 1001) { // +1 for header
        result.addWarning('File contains ${rows.length - 1} rows. QuickBooks recommends max 1000 rows per import');
      }

    } catch (e) {
      result.addError('Failed to parse CSV: $e');
    }

    return result;
  }

  /// Validate QuickBooks 4-column format
  static ValidationResult _validateQuickBooks4Column(String csvContent) {
    final result = ValidationResult();

    try {
      final rows = const CsvToListConverter().convert(csvContent);

      if (rows.isEmpty) {
        result.addError('CSV file is empty');
        return result;
      }

      // Check headers
      final headers = rows[0].map((h) => h.toString().toLowerCase()).toList();
      if (!_validateHeaders(headers, ['date', 'description', 'debit', 'credit'])) {
        result.addError('Invalid headers. Expected: Date, Description, Debit, Credit');
      }

      // Validate each row
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];

        if (row.length != 4) {
          result.addError('Row ${i + 1}: Expected 4 columns, found ${row.length}');
          continue;
        }

        // Validate date
        if (!_isValidQuickBooksDate(row[0].toString())) {
          result.addError('Row ${i + 1}: Invalid date format. Expected MM/DD/YYYY');
        }

        // Validate debit/credit (one must be empty, one must have value)
        final debit = row[2].toString().trim();
        final credit = row[3].toString().trim();

        if (debit.isNotEmpty && credit.isNotEmpty) {
          result.addError('Row ${i + 1}: Cannot have both debit and credit');
        } else if (debit.isEmpty && credit.isEmpty) {
          result.addError('Row ${i + 1}: Must have either debit or credit');
        }

        // Validate amounts
        if (debit.isNotEmpty && !_isValidAmount(debit)) {
          result.addError('Row ${i + 1}: Invalid debit amount');
        }
        if (credit.isNotEmpty && !_isValidAmount(credit)) {
          result.addError('Row ${i + 1}: Invalid credit amount');
        }
      }

      if (rows.length > 1001) {
        result.addWarning('File contains ${rows.length - 1} rows. QuickBooks recommends max 1000 rows per import');
      }

    } catch (e) {
      result.addError('Failed to parse CSV: $e');
    }

    return result;
  }

  /// Validate Xero format
  static ValidationResult _validateXero(String csvContent) {
    final result = ValidationResult();

    try {
      final rows = const CsvToListConverter().convert(csvContent);

      if (rows.isEmpty) {
        result.addError('CSV file is empty');
        return result;
      }

      // Check required headers
      final headers = rows[0].map((h) => h.toString().toLowerCase()).toList();
      final requiredHeaders = ['contactname', 'invoicenumber', 'invoicedate'];

      for (final required in requiredHeaders) {
        if (!headers.any((h) => h.contains(required.toLowerCase()))) {
          result.addError('Missing required header: $required');
        }
      }

      // Find column indices
      int? contactIdx, invoiceNumIdx, dateIdx, amountIdx;
      for (int i = 0; i < headers.length; i++) {
        final header = headers[i];
        if (header.contains('contactname')) contactIdx = i;
        if (header.contains('invoicenumber')) invoiceNumIdx = i;
        if (header.contains('invoicedate')) dateIdx = i;
        if (header.contains('unitamount') || header.contains('amount')) amountIdx = i;
      }

      // Validate each row
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];

        // Check required fields
        if (contactIdx != null && row.length > contactIdx) {
          if (row[contactIdx].toString().trim().isEmpty) {
            result.addError('Row ${i + 1}: ContactName is required');
          }
        }

        if (invoiceNumIdx != null && row.length > invoiceNumIdx) {
          if (row[invoiceNumIdx].toString().trim().isEmpty) {
            result.addError('Row ${i + 1}: InvoiceNumber is required');
          }
        }

        // Validate date (DD/MM/YYYY for Xero)
        if (dateIdx != null && row.length > dateIdx) {
          if (!_isValidXeroDate(row[dateIdx].toString())) {
            result.addError('Row ${i + 1}: Invalid date format. Expected DD/MM/YYYY');
          }
        }

        // Validate amount
        if (amountIdx != null && row.length > amountIdx) {
          if (!_isValidAmount(row[amountIdx].toString())) {
            result.addError('Row ${i + 1}: Invalid amount format');
          }
        }
      }

      // Check batch size (Xero recommends 500)
      if (rows.length > 501) {
        result.addWarning('File contains ${rows.length - 1} rows. Xero recommends max 500 rows per import');
      }

    } catch (e) {
      result.addError('Failed to parse CSV: $e');
    }

    return result;
  }

  /// Validate generic CSV format
  static ValidationResult _validateGeneric(String csvContent) {
    final result = ValidationResult();

    try {
      final rows = const CsvToListConverter().convert(csvContent);

      if (rows.isEmpty) {
        result.addError('CSV file is empty');
        return result;
      }

      // Basic validation
      final headerCount = rows[0].length;

      for (int i = 1; i < rows.length; i++) {
        if (rows[i].length != headerCount) {
          result.addWarning('Row ${i + 1}: Column count mismatch');
        }

        // Check for CSV injection
        for (final cell in rows[i]) {
          if (_containsCSVInjection(cell.toString())) {
            result.addWarning('Row ${i + 1}: Contains potentially dangerous characters');
            break;
          }
        }
      }

    } catch (e) {
      result.addError('Failed to parse CSV: $e');
    }

    return result;
  }

  /// Convert receipts to CSV format
  static String convertToCSV(
    List<Map<String, dynamic>> receipts,
    ExportFormat format,
  ) {
    switch (format) {
      case ExportFormat.quickBooks3Column:
        return _convertToQuickBooks3Column(receipts);
      case ExportFormat.quickBooks4Column:
        return _convertToQuickBooks4Column(receipts);
      case ExportFormat.xero:
        return _convertToXero(receipts);
      case ExportFormat.generic:
        return _convertToGeneric(receipts);
    }
  }

  static String _convertToQuickBooks3Column(List<Map<String, dynamic>> receipts) {
    final rows = <List<String>>[
      ['Date', 'Description', 'Amount'],
    ];

    for (final receipt in receipts) {
      final date = DateFormat('MM/dd/yyyy').format(receipt['date'] as DateTime);
      final description = '${receipt['merchant'] ?? 'Unknown'} - ${receipt['notes'] ?? ''}';
      final amount = (receipt['total'] as num).toStringAsFixed(2);

      rows.add([date, _sanitizeField(description), amount]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  static String _convertToQuickBooks4Column(List<Map<String, dynamic>> receipts) {
    final rows = <List<String>>[
      ['Date', 'Description', 'Debit', 'Credit'],
    ];

    for (final receipt in receipts) {
      final date = DateFormat('MM/dd/yyyy').format(receipt['date'] as DateTime);
      final description = '${receipt['merchant'] ?? 'Unknown'} - ${receipt['notes'] ?? ''}';
      final amount = (receipt['total'] as num).toStringAsFixed(2);

      // Expenses go in debit column
      rows.add([date, _sanitizeField(description), amount, '']);
    }

    return const ListToCsvConverter().convert(rows);
  }

  static String _convertToXero(List<Map<String, dynamic>> receipts) {
    final rows = <List<String>>[
      ['ContactName', 'InvoiceNumber', 'InvoiceDate', 'DueDate', 'Description', 'Quantity', 'UnitAmount', 'AccountCode', 'TaxType'],
    ];

    for (int i = 0; i < receipts.length; i++) {
      final receipt = receipts[i];
      final date = DateFormat('dd/MM/yyyy').format(receipt['date'] as DateTime);
      final contactName = _sanitizeField(receipt['merchant'] ?? 'Unknown Vendor');
      final invoiceNumber = receipt['id'] ?? 'INV-${i.toString().padLeft(6, '0')}';
      final description = _sanitizeField(receipt['notes'] ?? 'Receipt');
      final amount = ((receipt['total'] as num) - (receipt['tax'] ?? 0)).toStringAsFixed(2);
      final accountCode = '400'; // Default expense account

      rows.add([
        contactName,
        invoiceNumber,
        date,
        date, // Due date same as invoice date
        description,
        '1',
        amount,
        accountCode,
        'Tax on Purchases',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  static String _convertToGeneric(List<Map<String, dynamic>> receipts) {
    final rows = <List<String>>[
      ['Date', 'Merchant', 'Total', 'Tax', 'Category', 'Notes'],
    ];

    for (final receipt in receipts) {
      final date = DateFormat('yyyy-MM-dd').format(receipt['date'] as DateTime);
      final merchant = _sanitizeField(receipt['merchant'] ?? 'Unknown');
      final total = (receipt['total'] as num).toStringAsFixed(2);
      final tax = (receipt['tax'] ?? 0).toStringAsFixed(2);
      final category = receipt['category'] ?? '';
      final notes = _sanitizeField(receipt['notes'] ?? '');

      rows.add([date, merchant, total, tax, category, notes]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Sanitize field to prevent CSV injection
  static String _sanitizeField(String field) {
    if (field.isEmpty) return field;

    // Remove dangerous characters from the start
    var sanitized = field;
    while (sanitized.isNotEmpty &&
           ['=', '+', '-', '@', '\t', '\r', '\n'].contains(sanitized[0])) {
      sanitized = sanitized.substring(1);
    }

    return sanitized;
  }

  /// Validate headers match expected
  static bool _validateHeaders(List<String> actual, List<String> expected) {
    if (actual.length != expected.length) return false;

    for (int i = 0; i < expected.length; i++) {
      if (!actual[i].contains(expected[i])) {
        return false;
      }
    }
    return true;
  }

  /// Validate QuickBooks date format (MM/DD/YYYY)
  static bool _isValidQuickBooksDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length != 3) return false;

      final month = int.parse(parts[0]);
      final day = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      if (month < 1 || month > 12) return false;
      if (day < 1 || day > 31) return false;
      if (year < 1900 || year > 2100) return false;

      DateTime.utc(year, month, day);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validate Xero date format (DD/MM/YYYY)
  static bool _isValidXeroDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length != 3) return false;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      if (day < 1 || day > 31) return false;
      if (month < 1 || month > 12) return false;
      if (year < 1900 || year > 2100) return false;

      DateTime.utc(year, month, day);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validate amount format
  static bool _isValidAmount(String amount) {
    if (amount.trim().isEmpty) return false;

    try {
      final value = double.parse(amount.replaceAll(',', ''));
      return value >= -999999.99 && value <= 999999.99;
    } catch (e) {
      return false;
    }
  }

  /// Check for CSV injection attempts
  static bool _containsCSVInjection(String text) {
    if (text.isEmpty) return false;

    final dangerous = ['=', '+', '-', '@', '\t', '\r', '\n'];
    return dangerous.contains(text[0]);
  }
}

/// Export format types
enum ExportFormat {
  quickBooks3Column,
  quickBooks4Column,
  xero,
  generic,
}

/// Validation result container
class ValidationResult {
  final List<String> errors = [];
  final List<String> warnings = [];

  bool get isValid => errors.isEmpty;

  void addError(String error) {
    errors.add(error);
  }

  void addWarning(String warning) {
    warnings.add(warning);
  }

  Map<String, dynamic> toMap() {
    return {
      'isValid': isValid,
      'errors': errors,
      'warnings': warnings,
      'errorCount': errors.length,
      'warningCount': warnings.length,
    };
  }

  @override
  String toString() {
    final buffer = StringBuffer();

    if (isValid) {
      buffer.writeln('✅ Validation passed');
    } else {
      buffer.writeln('❌ Validation failed');
    }

    if (errors.isNotEmpty) {
      buffer.writeln('\nErrors:');
      for (final error in errors) {
        buffer.writeln('  • $error');
      }
    }

    if (warnings.isNotEmpty) {
      buffer.writeln('\nWarnings:');
      for (final warning in warnings) {
        buffer.writeln('  • $warning');
      }
    }

    return buffer.toString();
  }
}