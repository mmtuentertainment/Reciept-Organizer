/// Base exception for service layer errors
class ServiceException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  ServiceException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ServiceException: $message');
    if (code != null) {
      buffer.write(' (Code: $code)');
    }
    if (originalError != null) {
      buffer.write('\nOriginal error: $originalError');
    }
    return buffer.toString();
  }
}

/// Exception for OCR processing errors
class OCRServiceException extends ServiceException {
  OCRServiceException(String message, {String? code, dynamic originalError})
      : super(message, code: code ?? 'OCR_ERROR', originalError: originalError);
}

/// Exception for storage operation errors
class StorageException extends ServiceException {
  StorageException(String message, {String? code, dynamic originalError})
      : super(message, code: code ?? 'STORAGE_ERROR', originalError: originalError);
}

/// Exception for export operation errors
class ExportException extends ServiceException {
  ExportException(String message, {String? code, dynamic originalError})
      : super(message, code: code ?? 'EXPORT_ERROR', originalError: originalError);
}

/// Exception for validation errors
class ValidationException extends ServiceException {
  final Map<String, List<String>>? fieldErrors;

  ValidationException(
    String message, {
    String? code,
    this.fieldErrors,
    dynamic originalError,
  }) : super(message, code: code ?? 'VALIDATION_ERROR', originalError: originalError);
  
  @override
  String toString() {
    final buffer = StringBuffer(super.toString());
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      buffer.write('\nField errors:');
      fieldErrors!.forEach((field, errors) {
        buffer.write('\n  $field: ${errors.join(', ')}');
      });
    }
    return buffer.toString();
  }
}