import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_models.freezed.dart';
part 'api_models.g.dart';

/// Response model for receipt creation
@freezed
class CreateReceiptResponse with _$CreateReceiptResponse {
  const factory CreateReceiptResponse({
    required String jobId,
    required bool deduped,
  }) = _CreateReceiptResponse;

  factory CreateReceiptResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateReceiptResponseFromJson(json);
}

/// Request model for URL-based receipt upload
@freezed
class ReceiptUploadByUrl with _$ReceiptUploadByUrl {
  const factory ReceiptUploadByUrl({
    @Default('url') String source,
    required String url,
    Map<String, dynamic>? metadata,
  }) = _ReceiptUploadByUrl;

  factory ReceiptUploadByUrl.fromJson(Map<String, dynamic> json) =>
      _$ReceiptUploadByUrlFromJson(json);
}

/// Request model for Base64 receipt upload
@freezed
class ReceiptUploadByBase64 with _$ReceiptUploadByBase64 {
  const factory ReceiptUploadByBase64({
    @Default('base64') String source,
    required String contentType,
    required String data,
    Map<String, dynamic>? metadata,
  }) = _ReceiptUploadByBase64;

  factory ReceiptUploadByBase64.fromJson(Map<String, dynamic> json) =>
      _$ReceiptUploadByBase64FromJson(json);
}

/// RFC9457 Problem Details error response
@freezed
class ProblemDetails with _$ProblemDetails {
  const factory ProblemDetails({
    required String type,
    required String title,
    int? status,
    String? detail,
    String? instance,
    Map<String, dynamic>? extensions,
  }) = _ProblemDetails;

  factory ProblemDetails.fromJson(Map<String, dynamic> json) =>
      _$ProblemDetailsFromJson(json);
}

/// Job status response
@freezed
class JobStatus with _$JobStatus {
  const factory JobStatus({
    required String jobId,
    required String status,
    String? message,
    Map<String, dynamic>? result,
    DateTime? createdAt,
    DateTime? completedAt,
  }) = _JobStatus;

  factory JobStatus.fromJson(Map<String, dynamic> json) =>
      _$JobStatusFromJson(json);
}