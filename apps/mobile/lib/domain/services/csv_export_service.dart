import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receipt_organizer/data/models/receipt.dart';

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
}

class CSVExportService implements ICSVExportService {
  @override
  Future<ValidationResult> validateForExport(List<Receipt> receipts, ExportFormat format) async {
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
    switch (format) {
      case ExportFormat.quickbooks:
        return _generateQuickBooksCSV(receipts);
      case ExportFormat.xero:
        return _generateXeroCSV(receipts);
      case ExportFormat.generic:
        return _generateGenericCSV(receipts);
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
    // QuickBooks format: Date, Amount, Payee, Category, Memo
    final headers = ['Date', 'Amount', 'Payee', 'Category', 'Memo', 'Tax', 'Notes'];
    final rows = <List<String>>[headers];
    
    for (final receipt in receipts) {
      rows.add([
        _formatDate(receipt.receiptDate) ?? '',
        _formatAmount(receipt.totalAmount) ?? '0.00',
        _sanitizeForCSV(receipt.merchantName ?? 'Unknown Merchant'),
        'Business Expenses', // Default category
        'Receipt #${receipt.id.substring(0, 8)}',
        _formatAmount(receipt.taxAmount) ?? '0.00',
        _sanitizeForCSV(receipt.notes),
      ]);
    }
    
    return const ListToCsvConverter().convert(rows);
  }

  String _generateXeroCSV(List<Receipt> receipts) {
    // Xero format: Date, Amount, Payee, Description, Account Code
    final headers = ['Date', 'Amount', 'Payee', 'Description', 'Account Code', 'Tax Amount', 'Notes'];
    final rows = <List<String>>[headers];
    
    for (final receipt in receipts) {
      rows.add([
        _formatDate(receipt.receiptDate) ?? '',
        _formatAmount(receipt.totalAmount) ?? '0.00',
        _sanitizeForCSV(receipt.merchantName ?? 'Unknown Merchant'),
        'Business expense - Receipt #${receipt.id.substring(0, 8)}',
        '400', // Default expense account code
        _formatAmount(receipt.taxAmount) ?? '0.00',
        _sanitizeForCSV(receipt.notes),
      ]);
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
}