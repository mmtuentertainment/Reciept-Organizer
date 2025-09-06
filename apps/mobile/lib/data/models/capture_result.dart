import 'package:receipt_organizer/domain/services/ocr_service.dart';

class CaptureResult {
  final bool success;
  final String? imageUri;
  final String? thumbnailUri;
  final String? errorMessage;
  final String? errorCode;
  final ProcessingResult? ocrResults;

  CaptureResult({
    required this.success,
    this.imageUri,
    this.thumbnailUri,
    this.errorMessage,
    this.errorCode,
    this.ocrResults,
  });

  factory CaptureResult.success(String imageUri, {String? thumbnailUri, ProcessingResult? ocrResults}) {
    return CaptureResult(
      success: true,
      imageUri: imageUri,
      thumbnailUri: thumbnailUri,
      ocrResults: ocrResults,
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