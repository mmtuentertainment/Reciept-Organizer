import 'package:flutter/material.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';

/// Dialog that prompts user to retry capture after failure
class RetryPromptDialog extends StatelessWidget {
  final FailureReason failureReason;
  final int attemptNumber;
  final int attemptsRemaining;
  final VoidCallback onRetry;
  final VoidCallback onRetakePhoto;
  final VoidCallback onCancel;

  const RetryPromptDialog({
    super.key,
    required this.failureReason,
    required this.attemptNumber,
    required this.attemptsRemaining,
    required this.onRetry,
    required this.onRetakePhoto,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getFailureIcon(),
            color: colorScheme.error,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text('Capture Failed'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Failure reason message
          Text(
            failureReason.userMessage,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          
          // Attempt information
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.replay,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Attempt $attemptNumber • $attemptsRemaining left',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Tips based on failure reason
          if (_getTip() != null) ...[
            Text(
              'Tip:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getTip()!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        
        // Retake photo button
        TextButton.icon(
          onPressed: onRetakePhoto,
          icon: const Icon(Icons.camera_alt, size: 18),
          label: const Text('Retake Photo'),
        ),
        
        // Retry button (disabled if no attempts remaining)
        FilledButton.icon(
          onPressed: attemptsRemaining > 0 ? onRetry : null,
          icon: const Icon(Icons.refresh, size: 18),
          label: Text(attemptsRemaining > 0 ? 'Retry' : 'No Attempts Left'),
        ),
      ],
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actionsAlignment: MainAxisAlignment.spaceBetween,
    );
  }

  IconData _getFailureIcon() {
    switch (failureReason) {
      case FailureReason.blurryImage:
        return Icons.blur_on;
      case FailureReason.poorLighting:
        return Icons.lightbulb_outline;
      case FailureReason.noReceiptDetected:
        return Icons.receipt_long;
      case FailureReason.lowConfidence:
        return Icons.visibility_off;
      case FailureReason.processingTimeout:
        return Icons.timer_off;
      case FailureReason.processingError:
        return Icons.error_outline;
    }
  }

  String? _getTip() {
    switch (failureReason) {
      case FailureReason.blurryImage:
        return 'Hold the camera steady and ensure the receipt is in focus';
      case FailureReason.poorLighting:
        return 'Move to better lighting or turn on more lights';
      case FailureReason.noReceiptDetected:
        return 'Make sure the entire receipt fits within the frame';
      case FailureReason.lowConfidence:
        return 'Ensure the receipt text is clearly visible and not wrinkled';
      case FailureReason.processingTimeout:
        return 'Close other apps to free up device memory';
      case FailureReason.processingError:
        return 'Try restarting the app if the problem persists';
    }
  }

  /// Shows the retry prompt dialog
  static Future<RetryAction?> show({
    required BuildContext context,
    required FailureReason failureReason,
    required int attemptNumber,
    required int attemptsRemaining,
  }) async {
    return showDialog<RetryAction>(
      context: context,
      barrierDismissible: false, // Force user to make a choice
      builder: (context) => RetryPromptDialog(
        failureReason: failureReason,
        attemptNumber: attemptNumber,
        attemptsRemaining: attemptsRemaining,
        onRetry: () => Navigator.of(context).pop(RetryAction.retry),
        onRetakePhoto: () => Navigator.of(context).pop(RetryAction.retakePhoto),
        onCancel: () => Navigator.of(context).pop(RetryAction.cancel),
      ),
    );
  }
}

/// Actions user can take from the retry dialog
enum RetryAction {
  retry,      // Try processing the same image again
  retakePhoto, // Take a new photo
  cancel,     // Cancel the capture flow
}