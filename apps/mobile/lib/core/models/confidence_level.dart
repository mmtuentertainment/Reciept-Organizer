/// Core confidence model for Receipt Organizer
/// 
/// Consolidates confidence level definitions and extensions
/// to eliminate import conflicts and provide single source of truth.
library confidence_level;

/// Enum representing OCR confidence levels based on percentage thresholds
/// 
/// Used throughout the app to categorize and display confidence scores
/// for extracted receipt fields.
enum ConfidenceLevel {
  /// Less than 75% - requires user attention and verification
  /// Displayed with warning indicators (red/amber)
  low,
  
  /// 75-85% - medium confidence, may need verification  
  /// Displayed with caution indicators (orange)
  medium,
  
  /// Greater than 85% - high confidence, likely accurate
  /// Displayed with success indicators (green)
  high,
}

/// Extension to convert confidence percentages to ConfidenceLevel enum
/// 
/// Provides convenient conversion from double confidence scores
/// to categorical confidence levels for UI display and business logic.
extension ConfidenceLevelExtension on double {
  /// Convert percentage confidence score to ConfidenceLevel
  /// 
  /// Thresholds:
  /// - < 75%: Low confidence (requires attention)
  /// - 75-85%: Medium confidence (caution advised) 
  /// - > 85%: High confidence (likely accurate)
  ConfidenceLevel get confidenceLevel {
    if (this < 75.0) return ConfidenceLevel.low;
    if (this < 85.0) return ConfidenceLevel.medium;
    return ConfidenceLevel.high;
  }
}

/// Extension to provide display properties for ConfidenceLevel
/// 
/// Centralizes UI-related properties like colors and messages
/// for consistent display across the application.
extension ConfidenceLevelDisplay on ConfidenceLevel {
  /// Get user-friendly description of confidence level
  String get description {
    switch (this) {
      case ConfidenceLevel.low:
        return 'Low confidence - please verify';
      case ConfidenceLevel.medium:
        return 'Medium confidence - may need verification';
      case ConfidenceLevel.high:
        return 'High confidence - likely accurate';
    }
  }
  
  /// Get severity level for logging and error handling
  String get severity {
    switch (this) {
      case ConfidenceLevel.low:
        return 'warning';
      case ConfidenceLevel.medium:
        return 'caution';
      case ConfidenceLevel.high:
        return 'success';
    }
  }
  
  /// Check if this confidence level requires user attention
  bool get requiresAttention {
    return this == ConfidenceLevel.low;
  }
  
  /// Check if this confidence level suggests verification
  bool get suggestsVerification {
    return this == ConfidenceLevel.low || this == ConfidenceLevel.medium;
  }
}