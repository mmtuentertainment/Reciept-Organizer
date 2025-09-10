import 'package:flutter/material.dart';
import 'package:receipt_organizer/features/export/domain/services/csv_preview_service.dart';

/// CSV Preview Table Widget with horizontal scrolling and validation highlighting
/// Implements AC: 1, 4 - Shows first 5 rows with scrollable table
class CSVPreviewTable extends StatelessWidget {
  final List<List<String>> previewRows;
  final int totalCount;
  final List<ValidationWarning>? warnings;
  final bool isLoading;
  final String? error;

  const CSVPreviewTable({
    Key? key,
    required this.previewRows,
    required this.totalCount,
    this.warnings,
    this.isLoading = false,
    this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isLoading) {
      return _buildLoadingState(theme);
    }
    
    if (error != null) {
      return _buildErrorState(theme, error!);
    }
    
    if (previewRows.isEmpty) {
      return _buildEmptyState(theme);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Validation summary if warnings exist
        if (warnings != null && warnings!.isNotEmpty)
          _buildWarningsSummary(theme),
        
        // Preview table container
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Scrollable table
              Container(
                constraints: BoxConstraints(
                  maxHeight: 300, // Limit height for better UX
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: _buildDataTable(theme),
                  ),
                ),
              ),
              
              // Row count indicator
              _buildRowCountIndicator(theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Generating preview...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.table_chart_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No data to preview',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningsSummary(ThemeData theme) {
    final criticalCount = warnings!.where((w) => 
      w.severity == WarningSeverity.critical).length;
    final highCount = warnings!.where((w) => 
      w.severity == WarningSeverity.high).length;
    
    if (criticalCount == 0 && highCount == 0) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: criticalCount > 0 
          ? theme.colorScheme.errorContainer
          : theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: criticalCount > 0
              ? theme.colorScheme.onErrorContainer
              : theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              criticalCount > 0
                ? '$criticalCount critical security warnings detected'
                : '$highCount validation warnings found',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: criticalCount > 0
                  ? theme.colorScheme.onErrorContainer
                  : theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(ThemeData theme) {
    if (previewRows.isEmpty) return const SizedBox.shrink();
    
    final headers = previewRows.first;
    final dataRows = previewRows.skip(1).toList();
    
    return DataTable(
      headingRowHeight: 48,
      dataRowHeight: 52,
      horizontalMargin: 16,
      columnSpacing: 24,
      headingRowColor: MaterialStateProperty.all(
        theme.colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      border: TableBorder(
        horizontalInside: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      columns: headers.map((header) => DataColumn(
        label: Text(
          header,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      )).toList(),
      rows: dataRows.asMap().entries.map((entry) {
        final rowIndex = entry.key + 1; // +1 because header is row 0
        final row = entry.value;
        
        return DataRow(
          cells: row.asMap().entries.map((cellEntry) {
            final colIndex = cellEntry.key;
            final cellValue = cellEntry.value;
            
            // Check for warnings on this cell
            final cellWarning = warnings?.firstWhere(
              (w) => w.rowIndex == rowIndex && w.columnIndex == colIndex,
              orElse: () => ValidationWarning(
                rowIndex: -1,
                columnIndex: -1,
                message: '',
                severity: WarningSeverity.low,
              ),
            );
            
            final hasWarning = cellWarning != null && cellWarning.rowIndex != -1;
            
            return DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row number for first column
                  if (colIndex == 0) ...[
                    Text(
                      '$rowIndex.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  // Cell value with potential warning styling
                  Flexible(
                    child: Container(
                      padding: hasWarning 
                        ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
                        : null,
                      decoration: hasWarning ? BoxDecoration(
                        color: _getWarningColor(cellWarning!.severity, theme),
                        borderRadius: BorderRadius.circular(4),
                      ) : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              cellValue,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: hasWarning
                                  ? _getWarningTextColor(cellWarning.severity, theme)
                                  : null,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasWarning) ...[
                            const SizedBox(width: 4),
                            Tooltip(
                              message: cellWarning.message,
                              child: Icon(
                                Icons.warning_amber_rounded,
                                size: 16,
                                color: _getWarningIconColor(cellWarning.severity, theme),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildRowCountIndicator(ThemeData theme) {
    final displayedRows = previewRows.length > 1 ? previewRows.length - 1 : 0;
    final remainingRows = totalCount - displayedRows;
    
    if (remainingRows <= 0) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.more_horiz,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Text(
            '... $remainingRows more rows',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Color _getWarningColor(WarningSeverity severity, ThemeData theme) {
    switch (severity) {
      case WarningSeverity.critical:
        return theme.colorScheme.errorContainer;
      case WarningSeverity.high:
        return theme.colorScheme.error.withOpacity(0.2);
      case WarningSeverity.medium:
        return theme.colorScheme.secondaryContainer;
      case WarningSeverity.low:
        return theme.colorScheme.surfaceVariant.withOpacity(0.3);
    }
  }

  Color _getWarningTextColor(WarningSeverity severity, ThemeData theme) {
    switch (severity) {
      case WarningSeverity.critical:
        return theme.colorScheme.onErrorContainer;
      case WarningSeverity.high:
        return theme.colorScheme.error;
      case WarningSeverity.medium:
        return theme.colorScheme.onSecondaryContainer;
      case WarningSeverity.low:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  Color _getWarningIconColor(WarningSeverity severity, ThemeData theme) {
    switch (severity) {
      case WarningSeverity.critical:
        return theme.colorScheme.error;
      case WarningSeverity.high:
        return theme.colorScheme.error.withOpacity(0.8);
      case WarningSeverity.medium:
        return theme.colorScheme.secondary;
      case WarningSeverity.low:
        return theme.colorScheme.onSurfaceVariant.withOpacity(0.6);
    }
  }
}