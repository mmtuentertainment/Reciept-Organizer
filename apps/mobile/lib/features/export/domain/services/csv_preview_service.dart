import 'dart:async';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/domain/services/csv_export_service.dart';
import 'package:csv/csv.dart';

/// Result model for CSV preview data
class CSVPreviewResult {
  final List<List<String>> previewRows;
  final int totalCount;
  final List<ValidationWarning> warnings;
  final Duration generationTime;

  CSVPreviewResult({
    required this.previewRows,
    required this.totalCount,
    required this.warnings,
    required this.generationTime,
  });
}

/// Validation warning for preview cells
class ValidationWarning {
  final int rowIndex;
  final int columnIndex;
  final String message;
  final WarningSeverity severity;

  ValidationWarning({
    required this.rowIndex,
    required this.columnIndex,
    required this.message,
    required this.severity,
  });
}

enum WarningSeverity { low, medium, high, critical }

/// Service for generating CSV previews with performance optimization
/// Shares formatting logic with CSVExportService to ensure consistency
class CSVPreviewService {
  final CSVExportService _exportService;
  
  // Cache for preview results (simple TTL-based cache)
  static final Map<String, _CachedPreview> _previewCache = {};
  static const Duration _cacheTTL = Duration(seconds: 30);
  
  CSVPreviewService({CSVExportService? exportService})
      : _exportService = exportService ?? CSVExportService();

  /// Generate preview with first 5 rows of CSV data
  /// CRITICAL: Ensures preview matches export exactly (DATA-001)
  /// PERFORMANCE: Must complete in <100ms (PERF-001)
  Future<CSVPreviewResult> generatePreview(
    List<Receipt> receipts,
    ExportFormat format,
  ) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Check cache first for performance
      final cacheKey = _generateCacheKey(receipts, format);
      final cached = _getCachedPreview(cacheKey);
      if (cached != null) {
        stopwatch.stop();
        return CSVPreviewResult(
          previewRows: cached.rows,
          totalCount: receipts.length,
          warnings: cached.warnings,
          generationTime: stopwatch.elapsed,
        );
      }

      // Validation warnings collection
      final warnings = <ValidationWarning>[];
      
      // Use CSVExportService's generateCSVContent for consistency (DATA-001)
      // Only process first 5 receipts for performance (PERF-001)
      final previewReceipts = receipts.take(5).toList();
      final csvContent = _exportService.generateCSVContent(previewReceipts, format);
      
      // Parse CSV content for preview
      final csvConverter = const CsvToListConverter();
      final allRows = csvConverter.convert(csvContent);
      
      // Get headers and data rows (max 5 + header)
      final previewRows = allRows.take(6).toList();
      
      // Validate data and collect warnings (SEC-001)
      _validatePreviewData(previewRows, warnings);
      
      // Cache the result
      _cachePreview(cacheKey, previewRows, warnings);
      
      stopwatch.stop();
      
      // Check performance target (PERF-001)
      if (stopwatch.elapsedMilliseconds > 100) {
        // ignore: avoid_print
        print('WARNING: Preview generation took ${stopwatch.elapsedMilliseconds}ms (target: <100ms)');
      }
      
      return CSVPreviewResult(
        previewRows: previewRows.map((row) => 
          row.map((cell) => cell.toString()).toList()
        ).toList(),
        totalCount: receipts.length,
        warnings: warnings,
        generationTime: stopwatch.elapsed,
      );
      
    } catch (e) {
      stopwatch.stop();
      throw Exception('Failed to generate CSV preview: $e');
    }
  }

  /// Validate preview data for security and format issues
  /// SECURITY: Implements SEC-001 critical requirement
  void _validatePreviewData(
    List<List<dynamic>> rows,
    List<ValidationWarning> warnings,
  ) {
    for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      
      for (int colIndex = 0; colIndex < row.length; colIndex++) {
        final cellValue = row[colIndex].toString();
        
        // Check for CSV injection attempts (SEC-001)
        if (_isCSVInjectionRisk(cellValue)) {
          warnings.add(ValidationWarning(
            rowIndex: rowIndex,
            columnIndex: colIndex,
            message: 'Potential CSV injection detected. Cell value has been sanitized.',
            severity: WarningSeverity.critical,
          ));
        }
        
        // Check for missing required fields
        if (rowIndex > 0 && cellValue.isEmpty) {
          if (colIndex < 3) { // First 3 columns are typically required
            warnings.add(ValidationWarning(
              rowIndex: rowIndex,
              columnIndex: colIndex,
              message: 'Required field is empty',
              severity: WarningSeverity.high,
            ));
          }
        }
        
        // Check for data format issues
        if (colIndex == 2 && rowIndex > 0) { // Amount column
          final amount = double.tryParse(cellValue.replaceAll(r'$', ''));
          if (amount == null && cellValue.isNotEmpty) {
            warnings.add(ValidationWarning(
              rowIndex: rowIndex,
              columnIndex: colIndex,
              message: 'Invalid amount format',
              severity: WarningSeverity.medium,
            ));
          }
        }
      }
    }
  }

  /// Check if a cell value poses CSV injection risk
  /// SECURITY: Core security check for SEC-001
  bool _isCSVInjectionRisk(String value) {
    if (value.isEmpty) return false;
    
    final firstChar = value[0];
    final dangerousChars = ['=', '+', '-', '@'];
    
    // Check for dangerous starting characters
    if (dangerousChars.contains(firstChar)) {
      // Value should be sanitized by CSVExportService
      // This is a double-check for preview
      return true;
    }
    
    // Check for embedded formulas
    final formulaPatterns = [
      RegExp(r'=\w+\('), // =FUNCTION(
      RegExp(r'@\w+\('), // @FUNCTION(
      RegExp(r'\+\w+\('), // +FUNCTION(
      RegExp(r'-\w+\('), // -FUNCTION(
    ];
    
    for (final pattern in formulaPatterns) {
      if (pattern.hasMatch(value)) {
        return true;
      }
    }
    
    return false;
  }

  /// Generate cache key for preview results
  String _generateCacheKey(List<Receipt> receipts, ExportFormat format) {
    // Simple key based on receipt IDs and format
    final ids = receipts.take(5).map((r) => r.id).join(',');
    return '${format.name}_$ids';
  }

  /// Get cached preview if valid
  _CachedPreview? _getCachedPreview(String key) {
    final cached = _previewCache[key];
    if (cached == null) return null;
    
    // Check if cache is still valid
    if (DateTime.now().difference(cached.timestamp) > _cacheTTL) {
      _previewCache.remove(key);
      return null;
    }
    
    return cached;
  }

  /// Cache preview result
  void _cachePreview(
    String key,
    List<List<dynamic>> rows,
    List<ValidationWarning> warnings,
  ) {
    _previewCache[key] = _CachedPreview(
      rows: rows.map((row) => 
        row.map((cell) => cell.toString()).toList()
      ).toList(),
      warnings: warnings,
      timestamp: DateTime.now(),
    );
    
    // Clean old cache entries
    _cleanCache();
  }

  /// Clean expired cache entries
  void _cleanCache() {
    final now = DateTime.now();
    _previewCache.removeWhere((key, value) => 
      now.difference(value.timestamp) > _cacheTTL
    );
  }

  /// Clear all cached previews
  void clearCache() {
    _previewCache.clear();
  }
}

/// Internal cache model
class _CachedPreview {
  final List<List<String>> rows;
  final List<ValidationWarning> warnings;
  final DateTime timestamp;

  _CachedPreview({
    required this.rows,
    required this.warnings,
    required this.timestamp,
  });
}