/// Application settings model
/// 
/// Stores user preferences and feature toggles
class AppSettings {
  final bool merchantNormalization;
  final bool enableAudioFeedback;
  final bool enableBatchCapture;
  final int maxRetryAttempts;
  final String csvExportFormat;
  final String dateFormat;

  const AppSettings({
    this.merchantNormalization = true,
    this.enableAudioFeedback = true,
    this.enableBatchCapture = false,
    this.maxRetryAttempts = 3,
    this.csvExportFormat = 'quickbooks',
    this.dateFormat = 'MM/dd/yyyy',
  });

  AppSettings copyWith({
    bool? merchantNormalization,
    bool? enableAudioFeedback,
    bool? enableBatchCapture,
    int? maxRetryAttempts,
    String? csvExportFormat,
    String? dateFormat,
  }) {
    return AppSettings(
      merchantNormalization: merchantNormalization ?? this.merchantNormalization,
      enableAudioFeedback: enableAudioFeedback ?? this.enableAudioFeedback,
      enableBatchCapture: enableBatchCapture ?? this.enableBatchCapture,
      maxRetryAttempts: maxRetryAttempts ?? this.maxRetryAttempts,
      csvExportFormat: csvExportFormat ?? this.csvExportFormat,
      dateFormat: dateFormat ?? this.dateFormat,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchantNormalization': merchantNormalization,
      'enableAudioFeedback': enableAudioFeedback,
      'enableBatchCapture': enableBatchCapture,
      'maxRetryAttempts': maxRetryAttempts,
      'csvExportFormat': csvExportFormat,
      'dateFormat': dateFormat,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      merchantNormalization: json['merchantNormalization'] ?? true,
      enableAudioFeedback: json['enableAudioFeedback'] ?? true,
      enableBatchCapture: json['enableBatchCapture'] ?? false,
      maxRetryAttempts: json['maxRetryAttempts'] ?? 3,
      csvExportFormat: json['csvExportFormat'] ?? 'quickbooks',
      dateFormat: json['dateFormat'] ?? 'MM/dd/yyyy',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is AppSettings &&
      other.merchantNormalization == merchantNormalization &&
      other.enableAudioFeedback == enableAudioFeedback &&
      other.enableBatchCapture == enableBatchCapture &&
      other.maxRetryAttempts == maxRetryAttempts &&
      other.csvExportFormat == csvExportFormat &&
      other.dateFormat == dateFormat;
  }

  @override
  int get hashCode {
    return merchantNormalization.hashCode ^
      enableAudioFeedback.hashCode ^
      enableBatchCapture.hashCode ^
      maxRetryAttempts.hashCode ^
      csvExportFormat.hashCode ^
      dateFormat.hashCode;
  }
}