import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

/// Result type for functional error handling
///
/// Instead of throwing exceptions, we return Results that can be
/// either Success or Failure, making error handling explicit and type-safe.
@freezed
class Result<S, F> with _$Result<S, F> {
  const Result._();

  /// Successful result containing a value
  const factory Result.success(S value) = Success<S, F>;

  /// Failed result containing an error
  const factory Result.failure(F error) = Failure<S, F>;

  /// Check if this is a success
  bool get isSuccess => this is Success<S, F>;

  /// Check if this is a failure
  bool get isFailure => this is Failure<S, F>;

  /// Get success value or null
  S? get successOrNull => isSuccess ? (this as Success<S, F>).value : null;

  /// Get failure value or null
  F? get failureOrNull => isFailure ? (this as Failure<S, F>).error : null;

  /// Get value or default
  S getOrElse(S defaultValue) {
    return isSuccess ? (this as Success<S, F>).value : defaultValue;
  }

  /// Get value or compute default
  S getOrElseCompute(S Function() compute) {
    return isSuccess ? (this as Success<S, F>).value : compute();
  }

  /// Transform success value
  Result<T, F> mapSuccess<T>(T Function(S) transform) {
    return when(
      success: (value) => Result.success(transform(value)),
      failure: (error) => Result.failure(error),
    );
  }

  /// Transform failure value
  Result<S, T> mapError<T>(T Function(F) transform) {
    return when(
      success: (value) => Result.success(value),
      failure: (error) => Result.failure(transform(error)),
    );
  }

  /// Flat map for chaining operations
  Result<T, F> flatMap<T>(Result<T, F> Function(S) transform) {
    return when(
      success: (value) => transform(value),
      failure: (error) => Result.failure(error),
    );
  }

  /// Execute side effect if success
  Result<S, F> onSuccess(void Function(S) action) {
    if (isSuccess) {
      action((this as Success<S, F>).value);
    }
    return this;
  }

  /// Execute side effect if failure
  Result<S, F> onFailure(void Function(F) action) {
    if (isFailure) {
      action((this as Failure<S, F>).error);
    }
    return this;
  }
}

/// Extension for async Result operations
extension ResultAsync<S, F> on Future<Result<S, F>> {
  /// Async map
  Future<Result<T, F>> mapAsync<T>(Future<T> Function(S) transform) async {
    final result = await this;
    return result.when(
      success: (value) async => Result.success(await transform(value)),
      failure: (error) => Result.failure(error),
    );
  }

  /// Async flat map
  Future<Result<T, F>> flatMapAsync<T>(
    Future<Result<T, F>> Function(S) transform,
  ) async {
    final result = await this;
    return result.when(
      success: (value) => transform(value),
      failure: (error) => Result.failure(error),
    );
  }
}