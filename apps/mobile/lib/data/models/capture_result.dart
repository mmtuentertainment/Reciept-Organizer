class CaptureResult {
  final bool success;
  final String? imageUri;
  final String? errorMessage;
  final String? errorCode;

  CaptureResult({
    required this.success,
    this.imageUri,
    this.errorMessage,
    this.errorCode,
  });

  factory CaptureResult.success(String imageUri) {
    return CaptureResult(
      success: true,
      imageUri: imageUri,
    );
  }

  factory CaptureResult.error(String message, {String? code}) {
    return CaptureResult(
      success: false,
      errorMessage: message,
      errorCode: code,
    );
  }
}