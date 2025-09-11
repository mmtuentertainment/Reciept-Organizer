import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

/// A result type that represents either a success with a value or a failure with an error.
/// This provides type-safe error handling without exceptions.
@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(AppError error) = Failure<T>;
  
  const Result._();
  
  /// Returns true if this is a success result
  bool get isSuccess => this is Success<T>;
  
  /// Returns true if this is a failure result
  bool get isFailure => this is Failure<T>;
  
  /// Get the value if success, otherwise return null
  T? get valueOrNull => map(
    success: (s) => s.value,
    failure: (_) => null,
  );
  
  /// Get the error if failure, otherwise return null
  AppError? get errorOrNull => map(
    success: (_) => null,
    failure: (f) => f.error,
  );
  
  /// Transform the value if this is a success
  Result<R> mapSuccess<R>(R Function(T value) mapper) {
    return map(
      success: (s) => Result.success(mapper(s.value)),
      failure: (f) => Result.failure(f.error),
    );
  }
  
  /// Execute a function if this is a success
  Result<T> onSuccess(void Function(T value) action) {
    if (isSuccess) {
      action(valueOrNull as T);
    }
    return this;
  }
  
  /// Execute a function if this is a failure
  Result<T> onFailure(void Function(AppError error) action) {
    if (isFailure) {
      action(errorOrNull!);
    }
    return this;
  }
  
  /// Provide a default value if this is a failure
  T getOrElse(T defaultValue) {
    return valueOrNull ?? defaultValue;
  }
  
  /// Provide a default value from a function if this is a failure
  T getOrElseCall(T Function() defaultValue) {
    return valueOrNull ?? defaultValue();
  }
}

/// Base class for all application errors
@freezed
class AppError with _$AppError {
  const factory AppError.notFound({
    required String message,
    String? code,
    Map<String, dynamic>? metadata,
  }) = NotFoundError;
  
  const factory AppError.unauthorized({
    required String message,
    String? code,
    Map<String, dynamic>? metadata,
  }) = UnauthorizedError;
  
  const factory AppError.network({
    required String message,
    String? code,
    Map<String, dynamic>? metadata,
  }) = NetworkError;
  
  const factory AppError.validation({
    required String message,
    String? code,
    Map<String, dynamic>? metadata,
    Map<String, List<String>>? fieldErrors,
  }) = ValidationError;
  
  const factory AppError.storage({
    required String message,
    String? code,
    Map<String, dynamic>? metadata,
  }) = StorageError;
  
  const factory AppError.duplicate({
    required String message,
    String? code,
    Map<String, dynamic>? metadata,
  }) = DuplicateError;
  
  const factory AppError.sync({
    required String message,
    String? code,
    Map<String, dynamic>? metadata,
    List<String>? conflictIds,
  }) = SyncError;
  
  const factory AppError.unknown({
    required String message,
    String? code,
    Map<String, dynamic>? metadata,
    Object? originalError,
    StackTrace? stackTrace,
  }) = UnknownError;
  
  const AppError._();
  
  /// Get a user-friendly error message
  String get userMessage => map(
    notFound: (_) => 'The requested item could not be found.',
    unauthorized: (_) => 'You are not authorized to perform this action.',
    network: (_) => 'A network error occurred. Please check your connection.',
    validation: (e) => e.message,
    storage: (_) => 'A storage error occurred. Please try again.',
    duplicate: (_) => 'This item already exists.',
    sync: (_) => 'A synchronization error occurred.',
    unknown: (_) => 'An unexpected error occurred. Please try again.',
  );
}