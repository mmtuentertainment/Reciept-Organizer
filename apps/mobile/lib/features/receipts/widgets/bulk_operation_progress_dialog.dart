import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/core/services/bulk_operation_service.dart';

class BulkOperationProgressDialog extends ConsumerStatefulWidget {
  final Stream<BulkOperationProgress> progressStream;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;
  final String title;
  
  const BulkOperationProgressDialog({
    Key? key,
    required this.progressStream,
    this.onComplete,
    this.onCancel,
    this.title = 'Processing',
  }) : super(key: key);
  
  @override
  ConsumerState<BulkOperationProgressDialog> createState() => 
      _BulkOperationProgressDialogState();
}

class _BulkOperationProgressDialogState 
    extends ConsumerState<BulkOperationProgressDialog> 
    with SingleTickerProviderStateMixin {
  
  StreamSubscription<BulkOperationProgress>? _subscription;
  BulkOperationProgress? _currentProgress;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  double _targetProgress = 0;
  bool _hasError = false;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _subscription = widget.progressStream.listen(
      (progress) {
        setState(() {
          _currentProgress = progress;
          _hasError = progress.error != null;
          
          // Animate progress bar
          final newProgress = progress.percentage / 100;
          _progressAnimation = Tween<double>(
            begin: _targetProgress,
            end: newProgress,
          ).animate(CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ));
          _targetProgress = newProgress;
          _animationController.forward(from: 0);
        });
        
        // Handle completion
        if (progress.isComplete && !_hasError) {
          HapticFeedback.heavyImpact();
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.of(context).pop();
              widget.onComplete?.call();
            }
          });
        }
        
        // Announce progress for accessibility
        if (progress.current % 10 == 0 || progress.isComplete) {
          SemanticsService.announce(
            progress.isComplete 
                ? 'Operation complete'
                : 'Progress: ${progress.percentage.toInt()}%',
            Directionality.of(context),
          );
        }
      },
      onError: (error) {
        setState(() {
          _hasError = true;
          _currentProgress = BulkOperationProgress(
            total: _currentProgress?.total ?? 0,
            current: _currentProgress?.current ?? 0,
            operation: 'Failed',
            error: error.toString(),
          );
        });
      },
    );
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _currentProgress;
    
    return WillPopScope(
      onWillPop: () async {
        // Prevent accidental dismissal during operation
        if (progress?.isComplete == true || _hasError) {
          return true;
        }
        
        final shouldCancel = await _showCancelConfirmation();
        if (shouldCancel && widget.onCancel != null) {
          widget.onCancel!();
        }
        return shouldCancel;
      },
      child: Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildIcon(theme),
              ),
              
              const SizedBox(height: 16),
              
              // Title
              Text(
                _hasError
                    ? 'Operation Failed'
                    : progress?.isComplete == true
                        ? 'Complete!'
                        : widget.title,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Progress indicator
              if (!_hasError && progress?.isComplete != true) ...[
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Column(
                      children: [
                        // Linear progress bar
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: theme.colorScheme.surfaceVariant,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress != null 
                                  ? _progressAnimation.value
                                  : null,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Progress text
                        if (progress != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${progress.current} of ${progress.total}',
                                style: theme.textTheme.bodyMedium,
                              ),
                              Text(
                                '${progress.percentage.toInt()}%',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          
                          if (progress.currentItem != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              progress.currentItem!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          
                          if (progress.operation.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              progress.operation,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ],
                    );
                  },
                ),
              ],
              
              // Error message
              if (_hasError && progress?.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.error.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 20,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          progress!.error!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Success summary
              if (progress?.isComplete == true && !_hasError) ...[
                Icon(
                  Icons.check_circle,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Successfully processed ${progress!.total} items',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!_hasError && progress?.isComplete != true && widget.onCancel != null)
                    TextButton(
                      onPressed: () async {
                        final shouldCancel = await _showCancelConfirmation();
                        if (shouldCancel) {
                          widget.onCancel!();
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      child: const Text('Cancel'),
                    ),
                  
                  if (_hasError || progress?.isComplete == true)
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(_hasError ? 'Close' : 'Done'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildIcon(ThemeData theme) {
    if (_hasError) {
      return Icon(
        Icons.error_outline,
        size: 48,
        color: theme.colorScheme.error,
        key: const ValueKey('error'),
      );
    }
    
    if (_currentProgress?.isComplete == true) {
      return Icon(
        Icons.check_circle_outline,
        size: 48,
        color: theme.colorScheme.primary,
        key: const ValueKey('complete'),
      );
    }
    
    return SizedBox(
      width: 48,
      height: 48,
      key: const ValueKey('progress'),
      child: CircularProgressIndicator(
        value: _currentProgress != null 
            ? _currentProgress!.percentage / 100
            : null,
        strokeWidth: 3,
      ),
    );
  }
  
  Future<bool> _showCancelConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Operation?'),
        content: Text(
          'Are you sure you want to cancel? '
          '${_currentProgress?.current ?? 0} of ${_currentProgress?.total ?? 0} items have been processed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continue'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Cancel Operation'),
          ),
        ],
      ),
    ) ?? false;
  }
}

// Simplified progress overlay for non-blocking operations
class BulkOperationProgressOverlay extends StatelessWidget {
  final BulkOperationProgress progress;
  final VoidCallback? onDismiss;
  
  const BulkOperationProgressOverlay({
    Key? key,
    required this.progress,
    this.onDismiss,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Progress indicator
            SizedBox(
              width: 24,
              height: 24,
              child: progress.isComplete
                  ? Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                    )
                  : CircularProgressIndicator(
                      value: progress.percentage / 100,
                      strokeWidth: 2,
                    ),
            ),
            
            const SizedBox(width: 16),
            
            // Text
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    progress.isComplete
                        ? 'Operation complete'
                        : '${progress.operation} (${progress.percentage.toInt()}%)',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (!progress.isComplete)
                    Text(
                      '${progress.current} of ${progress.total}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            
            // Dismiss button
            if (progress.isComplete && onDismiss != null)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onDismiss,
                iconSize: 20,
              ),
          ],
        ),
      ),
    );
  }
}