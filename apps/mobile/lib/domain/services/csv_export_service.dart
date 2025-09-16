import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/features/export/services/export_format_validator.dart';

enum ExportFormat { quickbooks, xero, generic }

class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final int validCount;
  final int totalCount;

  ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
    required this.validCount,
    required this.totalCount,
  });
}

class ExportResult {
  final bool success;
  final String? filePath;
  final String? fileName;
  final String? error;
  final int recordCount;

  ExportResult({
    required this.success,
    this.filePath,
    this.fileName,
    this.error,
    this.recordCount = 0,
  });

  factory ExportResult.success(String filePath, String fileName, int recordCount) {
    return ExportResult(
      success: true,
      filePath: filePath,
      fileName: fileName,
      recordCount: recordCount,
    );
  }

  factory ExportResult.error(String error) {
    return ExportResult(
      success: false,
      error: error,
    );
  }
}

abstract class ICSVExportService {
  Future<ValidationResult> validateForExport(List<Receipt> receipts, ExportFormat format);
  Future<ExportResult> exportToCSV(List<Receipt> receipts, ExportFormat format, {String? customFileName});
  String generateCSVContent(List<Receipt> receipts, ExportFormat format);
  List<String> getRequiredFields(ExportFormat format);
  Stream<double> exportWithProgress(List<Receipt> receipts, ExportFormat format, {String? customFileName});
  List<List<Receipt>> createBatches(List<Receipt> receipts, ExportFormat format);
}

class CSVExportService implements ICSVExportService {
  static const int quickBooksBatchSize = 1000;
  static const int xeroBatchSize = 500;
  static const int genericBatchSize = 5000;

  final ExportFormatValidator _validator = ExportFormatValidator();
  @override
  Future<ValidationResult> validateForExport(List<Receipt> receipts, ExportFormat format) async {
    // First use our comprehensive validator
    final csvContent = generateCSVContent(receipts, format);
    final validatorResult = ExportFormatValidator.validateFormat(csvContent, format);

    if (!validatorResult.isValid) {
      return ValidationResult(
        isValid: false,
        errors: validatorResult.errors,
        warnings: validatorResult.warnings,
        validCount: 0,
        totalCount: receipts.length,
      );
    }

    // Continue with existing validation logic
    final errors = <String>[];
    final warnings = <String>[];
    int validCount = 0;
    
    // final requiredFields = getRequiredFields(format); // TODO: Implement field validation
    
    for (int i = 0; i < receipts.length; i++) {
      final receipt = receipts[i];
      final receiptErrors = <String>[];
      final receiptWarnings = <String>[];
      
      // Check required fields based on format
      if (format == ExportFormat.quickbooks || format == ExportFormat.xero) {
        if (receipt.merchantName == null || receipt.merchantName!.isEmpty) {
          receiptErrors.add('Receipt ${i + 1}: Missing merchant name');
        }
        
        if (receipt.receiptDate == null || receipt.receiptDate!.isEmpty) {
          receiptErrors.add('Receipt ${i + 1}: Missing date');
        }
        
        if (receipt.totalAmount == null || receipt.totalAmount! <= 0) {
          receiptErrors.add('Receipt ${i + 1}: Missing or invalid total amount');
        }
        
        // Warnings for low confidence
        if (receipt.hasOCRResults && receipt.overallConfidence < 70) {
          receiptWarnings.add('Receipt ${i + 1}: Low OCR confidence (${receipt.overallConfidence.toStringAsFixed(1)}%)');
        }
        
        // Format-specific validations
        if (format == ExportFormat.quickbooks) {
          // QuickBooks-specific validations
          if (receipt.merchantName != null && receipt.merchantName!.length > 100) {
            receiptWarnings.add('Receipt ${i + 1}: Merchant name may be too long for QuickBooks');
          }
        }
        
        if (format == ExportFormat.xero) {
          // Xero-specific validations
          if (receipt.totalAmount != null && receipt.totalAmount! > 999999.99) {
            receiptErrors.add('Receipt ${i + 1}: Amount exceeds Xero limits');
          }
        }
      }
      
      if (receiptErrors.isEmpty) {
        validCount++;
      }
      
      errors.addAll(receiptErrors);
      warnings.addAll(receiptWarnings);
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      validCount: validCount,
      totalCount: receipts.length,
    );
  }

  @override
  Future<ExportResult> exportToCSV(List<Receipt> receipts, ExportFormat format, {String? customFileName}) async {
    try {
      // Validate first
      final validation = await validateForExport(receipts, format);
      if (!validation.isValid) {
        return ExportResult.error('Validation failed: ${validation.errors.join(', ')}');
      }

      // Generate CSV content
      final csvContent = generateCSVContent(receipts, format);
      
      // Get export directory
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/exports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      
      // Generate filename
      final timestamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[^\w]'), '_');
      final formatName = format.name;
      final fileName = customFileName ?? 'receipts_${formatName}_$timestamp.csv';
      
      // Write file
      final filePath = '${exportDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(csvContent);
      
      return ExportResult.success(filePath, fileName, receipts.length);
    } catch (e) {
      return ExportResult.error('Export failed: $e');
    }
  }

  @override
  String generateCSVContent(List<Receipt> receipts, ExportFormat format) {
    // Add UTF-8 BOM for Excel compatibility
    const bom = '\uFEFF';
    
    switch (format) {
      case ExportFormat.quickbooks:
        return bom + _generateQuickBooksCSV(receipts);
      case ExportFormat.xero:
        return bom + _generateXeroCSV(receipts);
      case ExportFormat.generic:
        return bom + _generateGenericCSV(receipts);
    }
  }

  @override
  List<String> getRequiredFields(ExportFormat format) {
    switch (format) {
      case ExportFormat.quickbooks:
        return ['Date', 'Amount', 'Payee', 'Category'];
      case ExportFormat.xero:
        return ['Date', 'Amount', 'Payee', 'Account Code'];
      case ExportFormat.generic:
        return ['Date', 'Amount', 'Merchant'];
    }
  }

  String _generateQuickBooksCSV(List<Receipt> receipts) {
    // QuickBooks 3-column format as per validation requirements
    final headers = ['Date', 'Description', 'Amount'];
    final rows = <List<String>>[headers];
    
    for (final receipt in receipts) {
      final description = '${_sanitizeForCSV(receipt.merchantName ?? 'Unknown Merchant')} - ${_sanitizeForCSV(receipt.notes)}';
      rows.add([
        _formatDateQuickBooks(receipt.receiptDate) ?? '',
        description,
        _formatAmount(receipt.totalAmount) ?? '0.00',
      ]);
    }
    
    return const ListToCsvConverter().convert(rows);
  }

  String _generateXeroCSV(List<Receipt> receipts) {
    // Xero format with required fields
    final headers = ['ContactName', 'InvoiceNumber', 'InvoiceDate', 'DueDate', 'Description', 'Quantity', 'UnitAmount', 'AccountCode', 'TaxType'];
    final rows = <List<String>>[headers];
    
    int invoiceNum = 1;
    for (final receipt in receipts) {
      final date = _formatDateXero(receipt.receiptDate) ?? '';
      final unitAmount = receipt.taxAmount != null && receipt.taxAmount! > 0
          ? ((receipt.totalAmount ?? 0) - receipt.taxAmount!)
          : (receipt.totalAmount ?? 0);

      rows.add([
        _sanitizeForCSV(receipt.merchantName ?? 'Unknown Vendor'),
        'REC-${invoiceNum.toString().padLeft(6, '0')}',
        date,
        date, // Due date same as invoice date
        _sanitizeForCSV(receipt.notes ?? 'Receipt'),
        '1',
        _formatAmount(unitAmount) ?? '0.00',
        '400', // Default expense account code
        'Tax on Purchases',
      ]);
      invoiceNum++;
    }
    
    return const ListToCsvConverter().convert(rows);
  }

  String _generateGenericCSV(List<Receipt> receipts) {
    // Generic format: All available fields
    final headers = [
      'Receipt ID',
      'Date',
      'Merchant',
      'Total Amount',
      'Tax Amount',
      'Captured Date',
      'Batch ID',
      'OCR Confidence',
      'Status',
      'Notes'
    ];
    final rows = <List<String>>[headers];
    
    for (final receipt in receipts) {
      rows.add([
        receipt.id,
        _formatDate(receipt.receiptDate) ?? '',
        _sanitizeForCSV(receipt.merchantName),
        _formatAmount(receipt.totalAmount) ?? '',
        _formatAmount(receipt.taxAmount) ?? '',
        _formatDateTime(receipt.capturedAt),
        receipt.batchId ?? '',
        receipt.overallConfidence.toStringAsFixed(1),
        receipt.status.name,
        _sanitizeForCSV(receipt.notes),
      ]);
    }
    
    return const ListToCsvConverter().convert(rows);
  }

  String? _formatAmount(double? amount) {
    if (amount == null) return null;
    return amount.toStringAsFixed(2);
  }

  /// Sanitize string to prevent CSV injection attacks
  /// Escapes special characters: =, +, -, @, tab, CR, LF
  String _sanitizeForCSV(String? value) {
    if (value == null || value.isEmpty) return '';
    
    // Check if value starts with dangerous characters
    final firstChar = value.isEmpty ? '' : value[0];
    final dangerousChars = ['=', '+', '-', '@'];
    
    String sanitized = value;
    
    // If starts with dangerous character, prefix with single quote
    if (dangerousChars.contains(firstChar)) {
      sanitized = "'$value";
    }
    
    // Replace tabs, carriage returns, and line feeds
    sanitized = sanitized
        .replaceAll('\t', ' ')  // Replace tab with space
        .replaceAll('\r', ' ')  // Replace carriage return with space
        .replaceAll('\n', ' '); // Replace line feed with space
    
    return sanitized;
  }

  String? _formatDate(String? dateStr) {
    if (dateStr == null) return null;
    
    try {
      // Try to parse and reformat to MM/DD/YYYY
      DateTime? date;
      
      // Try common formats
      final formats = [
        RegExp(r'^(\d{1,2})[/\-](\d{1,2})[/\-](\d{4})$'), // MM/DD/YYYY or MM-DD-YYYY
        RegExp(r'^(\d{4})[/\-](\d{1,2})[/\-](\d{1,2})$'), // YYYY/MM/DD or YYYY-MM-DD
      ];
      
      for (final format in formats) {
        final match = format.firstMatch(dateStr);
        if (match != null) {
          if (format == formats[0]) {
            // MM/DD/YYYY format
            final month = int.parse(match.group(1)!);
            final day = int.parse(match.group(2)!);
            final year = int.parse(match.group(3)!);
            date = DateTime(year, month, day);
          } else {
            // YYYY/MM/DD format
            final year = int.parse(match.group(1)!);
            final month = int.parse(match.group(2)!);
            final day = int.parse(match.group(3)!);
            date = DateTime(year, month, day);
          }
          break;
        }
      }
      
      if (date != null) {
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
      }
    } catch (e) {
      // If parsing fails, return the original string
    }
    
    return dateStr;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Format date for QuickBooks (MM/DD/YYYY)
  String? _formatDateQuickBooks(String? dateStr) {
    if (dateStr == null) return null;

    try {
      // Try to parse various date formats and convert to MM/DD/YYYY
      DateTime? date;

      // Try common formats
      final formats = [
        RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{4})'), // MM/DD/YYYY or MM-DD-YYYY
        RegExp(r'(\d{4})[/-](\d{1,2})[/-](\d{1,2})'), // YYYY-MM-DD
        RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2})'), // MM/DD/YY
      ];

      for (final format in formats) {
        final match = format.firstMatch(dateStr);
        if (match != null) {
          if (format.pattern.startsWith(r'(\d{4})')) {
            // YYYY-MM-DD format
            final year = int.parse(match.group(1)!);
            final month = int.parse(match.group(2)!);
            final day = int.parse(match.group(3)!);
            date = DateTime(year, month, day);
          } else {
            // MM/DD/YYYY or MM/DD/YY format
            final month = int.parse(match.group(1)!);
            final day = int.parse(match.group(2)!);
            var year = int.parse(match.group(3)!);
            if (year < 100) {
              year += (year > 50) ? 1900 : 2000;
            }
            date = DateTime(year, month, day);
          }
          break;
        }
      }

      if (date != null) {
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
      }
    } catch (e) {
      // If parsing fails, return the original string
    }

    return dateStr;
  }

  /// Format date for Xero (DD/MM/YYYY)
  String? _formatDateXero(String? dateStr) {
    if (dateStr == null) return null;

    try {
      // Try to parse various date formats and convert to DD/MM/YYYY
      DateTime? date;

      // Try common formats
      final formats = [
        RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{4})'), // MM/DD/YYYY or DD/MM/YYYY
        RegExp(r'(\d{4})[/-](\d{1,2})[/-](\d{1,2})'), // YYYY-MM-DD
        RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2})'), // MM/DD/YY
      ];

      for (final format in formats) {
        final match = format.firstMatch(dateStr);
        if (match != null) {
          if (format.pattern.startsWith(r'(\d{4})')) {
            // YYYY-MM-DD format
            final year = int.parse(match.group(1)!);
            final month = int.parse(match.group(2)!);
            final day = int.parse(match.group(3)!);
            date = DateTime(year, month, day);
          } else {
            // Assume MM/DD/YYYY format for parsing
            final month = int.parse(match.group(1)!);
            final day = int.parse(match.group(2)!);
            var year = int.parse(match.group(3)!);
            if (year < 100) {
              year += (year > 50) ? 1900 : 2000;
            }
            date = DateTime(year, month, day);
          }
          break;
        }
      }

      if (date != null) {
        // Return in DD/MM/YYYY format for Xero
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }
    } catch (e) {
      // If parsing fails, return the original string
    }

    return dateStr;
  }

  @override
  Stream<double> exportWithProgress(List<Receipt> receipts, ExportFormat format, {String? customFileName}) async* {
    try {
      yield 0.0;

      // Step 1: Validation (20%)
      final validation = await validateForExport(receipts, format);
      if (!validation.isValid) {
        throw Exception('Validation failed: ${validation.errors.join(', ')}');
      }
      yield 0.2;

      // Step 2: Create batches if needed (30%)
      final batches = createBatches(receipts, format);
      yield 0.3;

      // Step 3: Generate CSV content (60%)
      final csvContent = generateCSVContent(receipts, format);
      yield 0.6;

      // Step 4: Get export directory (70%)
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/exports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      yield 0.7;

      // Step 5: Generate filename (80%)
      final timestamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[^\w]'), '_');
      final formatName = format.name;
      final fileName = customFileName ?? 'receipts_${formatName}_$timestamp.csv';
      yield 0.8;

      // Step 6: Write file (90%)
      final filePath = '${exportDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(csvContent);
      yield 0.9;

      // Complete
      yield 1.0;
    } catch (e) {
      throw Exception('Export failed: $e');
    }
  }

  @override
  List<List<Receipt>> createBatches(List<Receipt> receipts, ExportFormat format) {
    int batchSize;

    switch (format) {
      case ExportFormat.quickbooks:
        batchSize = quickBooksBatchSize;
        break;
      case ExportFormat.xero:
        batchSize = xeroBatchSize;
        break;
      case ExportFormat.generic:
        batchSize = genericBatchSize;
        break;
    }

    final batches = <List<Receipt>>[];

    for (int i = 0; i < receipts.length; i += batchSize) {
      final end = (i + batchSize < receipts.length) ? i + batchSize : receipts.length;
      batches.add(receipts.sublist(i, end));
    }

    return batches;
  }
}