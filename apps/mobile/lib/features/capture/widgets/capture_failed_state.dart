import 'package:flutter/material.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';

/// Widget that displays the failed capture state with retry options
class CaptureFailedState extends StatelessWidget {
  final FailureReason failureReason;
  final int attemptNumber;
  final int attemptsRemaining;
  final double qualityScore;
  final VoidCallback onRetry;
  final VoidCallback onRetakePhoto;
  final VoidCallback onCancel;

  const CaptureFailedState({
    super.key,
    required this.failureReason,
    required this.attemptNumber,
    required this.attemptsRemaining,
    required this.qualityScore,
    required this.onRetry,
    required this.onRetakePhoto,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Failure icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getFailureIcon(),
              size: 40,
              color: colorScheme.onErrorContainer,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Failure title
          Text(
            'Capture Failed',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Failure message
          Text(
            failureReason.userMessage,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Attempt counter
          RetryCountIndicator(
            attemptNumber: attemptNumber,
            attemptsRemaining: attemptsRemaining,
            qualityScore: qualityScore,
          ),
          
          const SizedBox(height: 32),
          
          // Action buttons
          Column(
            children: [
              // Primary retry button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: attemptsRemaining > 0 ? onRetry : null,
                  icon: const Icon(Icons.refresh),
                  label: Text(attemptsRemaining > 0 
                      ? 'Try Again' 
                      : 'No Attempts Left'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Secondary retake button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onRetakePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Retake Photo'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Cancel button
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Tips section
          if (_getTip() != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        size: 16,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tip',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getTip()!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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
        return 'Hold your device steady and make sure the receipt is clearly focused before taking the photo.';
      case FailureReason.poorLighting:
        return 'Try moving to an area with better lighting, or turn on additional lights to illuminate the receipt.';
      case FailureReason.noReceiptDetected:
        return 'Ensure the entire receipt is visible within the camera frame and is not obscured by shadows.';
      case FailureReason.lowConfidence:
        return 'Make sure the receipt is flat and uncrumpled, with all text clearly readable.';
      case FailureReason.processingTimeout:
        return 'Close other running apps to free up device memory and processing power.';
      case FailureReason.processingError:
        return 'If this problem continues, try restarting the app or your device.';
    }
  }
}

/// Widget that shows retry attempt information with visual feedback
class RetryCountIndicator extends StatelessWidget {
  final int attemptNumber;
  final int attemptsRemaining;
  final double qualityScore;

  const RetryCountIndicator({
    super.key,
    required this.attemptNumber,
    required this.attemptsRemaining,
    required this.qualityScore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Attempt information
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.replay,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Attempt $attemptNumber',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: attemptsRemaining > 0 
                      ? colorScheme.primary.withOpacity(0.1)
                      : colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$attemptsRemaining left',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: attemptsRemaining > 0 
                        ? colorScheme.primary
                        : colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Quality score indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Quality Score: ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${qualityScore.toStringAsFixed(1)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _getQualityScoreColor(colorScheme),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 40 * (qualityScore / 100).clamp(0.0, 1.0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: _getQualityScoreColor(colorScheme),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getQualityScoreColor(ColorScheme colorScheme) {
    if (qualityScore >= 75) {
      return colorScheme.primary;
    } else if (qualityScore >= 50) {
      return colorScheme.tertiary;
    } else {
      return colorScheme.error;
    }
  }
}