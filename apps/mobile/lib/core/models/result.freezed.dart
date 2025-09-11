// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Result<T> {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T value) success,
    required TResult Function(AppError error) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T value)? success,
    TResult? Function(AppError error)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T value)? success,
    TResult Function(AppError error)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Success<T> value) success,
    required TResult Function(Failure<T> value) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Success<T> value)? success,
    TResult? Function(Failure<T> value)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Success<T> value)? success,
    TResult Function(Failure<T> value)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultCopyWith<T, $Res> {
  factory $ResultCopyWith(Result<T> value, $Res Function(Result<T>) then) =
      _$ResultCopyWithImpl<T, $Res, Result<T>>;
}

/// @nodoc
class _$ResultCopyWithImpl<T, $Res, $Val extends Result<T>>
    implements $ResultCopyWith<T, $Res> {
  _$ResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SuccessImplCopyWith<T, $Res> {
  factory _$$SuccessImplCopyWith(
          _$SuccessImpl<T> value, $Res Function(_$SuccessImpl<T>) then) =
      __$$SuccessImplCopyWithImpl<T, $Res>;
  @useResult
  $Res call({T value});
}

/// @nodoc
class __$$SuccessImplCopyWithImpl<T, $Res>
    extends _$ResultCopyWithImpl<T, $Res, _$SuccessImpl<T>>
    implements _$$SuccessImplCopyWith<T, $Res> {
  __$$SuccessImplCopyWithImpl(
      _$SuccessImpl<T> _value, $Res Function(_$SuccessImpl<T>) _then)
      : super(_value, _then);

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = freezed,
  }) {
    return _then(_$SuccessImpl<T>(
      freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as T,
    ));
  }
}

/// @nodoc

class _$SuccessImpl<T> extends Success<T> {
  const _$SuccessImpl(this.value) : super._();

  @override
  final T value;

  @override
  String toString() {
    return 'Result<$T>.success(value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuccessImpl<T> &&
            const DeepCollectionEquality().equals(other.value, value));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(value));

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SuccessImplCopyWith<T, _$SuccessImpl<T>> get copyWith =>
      __$$SuccessImplCopyWithImpl<T, _$SuccessImpl<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T value) success,
    required TResult Function(AppError error) failure,
  }) {
    return success(value);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T value)? success,
    TResult? Function(AppError error)? failure,
  }) {
    return success?.call(value);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T value)? success,
    TResult Function(AppError error)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(value);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Success<T> value) success,
    required TResult Function(Failure<T> value) failure,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Success<T> value)? success,
    TResult? Function(Failure<T> value)? failure,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Success<T> value)? success,
    TResult Function(Failure<T> value)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class Success<T> extends Result<T> {
  const factory Success(final T value) = _$SuccessImpl<T>;
  const Success._() : super._();

  T get value;

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SuccessImplCopyWith<T, _$SuccessImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FailureImplCopyWith<T, $Res> {
  factory _$$FailureImplCopyWith(
          _$FailureImpl<T> value, $Res Function(_$FailureImpl<T>) then) =
      __$$FailureImplCopyWithImpl<T, $Res>;
  @useResult
  $Res call({AppError error});

  $AppErrorCopyWith<$Res> get error;
}

/// @nodoc
class __$$FailureImplCopyWithImpl<T, $Res>
    extends _$ResultCopyWithImpl<T, $Res, _$FailureImpl<T>>
    implements _$$FailureImplCopyWith<T, $Res> {
  __$$FailureImplCopyWithImpl(
      _$FailureImpl<T> _value, $Res Function(_$FailureImpl<T>) _then)
      : super(_value, _then);

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$FailureImpl<T>(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as AppError,
    ));
  }

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppErrorCopyWith<$Res> get error {
    return $AppErrorCopyWith<$Res>(_value.error, (value) {
      return _then(_value.copyWith(error: value));
    });
  }
}

/// @nodoc

class _$FailureImpl<T> extends Failure<T> {
  const _$FailureImpl(this.error) : super._();

  @override
  final AppError error;

  @override
  String toString() {
    return 'Result<$T>.failure(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FailureImpl<T> &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FailureImplCopyWith<T, _$FailureImpl<T>> get copyWith =>
      __$$FailureImplCopyWithImpl<T, _$FailureImpl<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T value) success,
    required TResult Function(AppError error) failure,
  }) {
    return failure(error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T value)? success,
    TResult? Function(AppError error)? failure,
  }) {
    return failure?.call(error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T value)? success,
    TResult Function(AppError error)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Success<T> value) success,
    required TResult Function(Failure<T> value) failure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Success<T> value)? success,
    TResult? Function(Failure<T> value)? failure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Success<T> value)? success,
    TResult Function(Failure<T> value)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class Failure<T> extends Result<T> {
  const factory Failure(final AppError error) = _$FailureImpl<T>;
  const Failure._() : super._();

  AppError get error;

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FailureImplCopyWith<T, _$FailureImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AppError {
  String get message => throw _privateConstructorUsedError;
  String? get code => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        notFound,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        unauthorized,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        network,
    required TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)
        validation,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        storage,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        duplicate,
    required TResult Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)
        sync,
    required TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)
        unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        notFound,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        unauthorized,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        network,
    TResult? Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)?
        validation,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        storage,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        duplicate,
    TResult? Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)?
        sync,
    TResult? Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)?
        unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        notFound,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        unauthorized,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        network,
    TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)?
        validation,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        storage,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        duplicate,
    TResult Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)?
        sync,
    TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)?
        unknown,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(UnauthorizedError value) unauthorized,
    required TResult Function(NetworkError value) network,
    required TResult Function(ValidationError value) validation,
    required TResult Function(StorageError value) storage,
    required TResult Function(DuplicateError value) duplicate,
    required TResult Function(SyncError value) sync,
    required TResult Function(UnknownError value) unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(UnauthorizedError value)? unauthorized,
    TResult? Function(NetworkError value)? network,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(StorageError value)? storage,
    TResult? Function(DuplicateError value)? duplicate,
    TResult? Function(SyncError value)? sync,
    TResult? Function(UnknownError value)? unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotFoundError value)? notFound,
    TResult Function(UnauthorizedError value)? unauthorized,
    TResult Function(NetworkError value)? network,
    TResult Function(ValidationError value)? validation,
    TResult Function(StorageError value)? storage,
    TResult Function(DuplicateError value)? duplicate,
    TResult Function(SyncError value)? sync,
    TResult Function(UnknownError value)? unknown,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppErrorCopyWith<AppError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppErrorCopyWith<$Res> {
  factory $AppErrorCopyWith(AppError value, $Res Function(AppError) then) =
      _$AppErrorCopyWithImpl<$Res, AppError>;
  @useResult
  $Res call({String message, String? code, Map<String, dynamic>? metadata});
}

/// @nodoc
class _$AppErrorCopyWithImpl<$Res, $Val extends AppError>
    implements $AppErrorCopyWith<$Res> {
  _$AppErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotFoundErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$NotFoundErrorImplCopyWith(
          _$NotFoundErrorImpl value, $Res Function(_$NotFoundErrorImpl) then) =
      __$$NotFoundErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? code, Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$NotFoundErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$NotFoundErrorImpl>
    implements _$$NotFoundErrorImplCopyWith<$Res> {
  __$$NotFoundErrorImplCopyWithImpl(
      _$NotFoundErrorImpl _value, $Res Function(_$NotFoundErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$NotFoundErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$NotFoundErrorImpl extends NotFoundError {
  const _$NotFoundErrorImpl(
      {required this.message, this.code, final Map<String, dynamic>? metadata})
      : _metadata = metadata,
        super._();

  @override
  final String message;
  @override
  final String? code;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppError.notFound(message: $message, code: $code, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotFoundErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotFoundErrorImplCopyWith<_$NotFoundErrorImpl> get copyWith =>
      __$$NotFoundErrorImplCopyWithImpl<_$NotFoundErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        notFound,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        unauthorized,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        network,
    required TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)
        validation,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        storage,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        duplicate,
    required TResult Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)
        sync,
    required TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)
        unknown,
  }) {
    return notFound(message, code, metadata);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        notFound,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        unauthorized,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        network,
    TResult? Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)?
        validation,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        storage,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        duplicate,
    TResult? Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)?
        sync,
    TResult? Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)?
        unknown,
  }) {
    return notFound?.call(message, code, metadata);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        notFound,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        unauthorized,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        network,
    TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)?
        validation,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        storage,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        duplicate,
    TResult Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)?
        sync,
    TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)?
        unknown,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(message, code, metadata);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(UnauthorizedError value) unauthorized,
    required TResult Function(NetworkError value) network,
    required TResult Function(ValidationError value) validation,
    required TResult Function(StorageError value) storage,
    required TResult Function(DuplicateError value) duplicate,
    required TResult Function(SyncError value) sync,
    required TResult Function(UnknownError value) unknown,
  }) {
    return notFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(UnauthorizedError value)? unauthorized,
    TResult? Function(NetworkError value)? network,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(StorageError value)? storage,
    TResult? Function(DuplicateError value)? duplicate,
    TResult? Function(SyncError value)? sync,
    TResult? Function(UnknownError value)? unknown,
  }) {
    return notFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotFoundError value)? notFound,
    TResult Function(UnauthorizedError value)? unauthorized,
    TResult Function(NetworkError value)? network,
    TResult Function(ValidationError value)? validation,
    TResult Function(StorageError value)? storage,
    TResult Function(DuplicateError value)? duplicate,
    TResult Function(SyncError value)? sync,
    TResult Function(UnknownError value)? unknown,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(this);
    }
    return orElse();
  }
}

abstract class NotFoundError extends AppError {
  const factory NotFoundError(
      {required final String message,
      final String? code,
      final Map<String, dynamic>? metadata}) = _$NotFoundErrorImpl;
  const NotFoundError._() : super._();

  @override
  String get message;
  @override
  String? get code;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotFoundErrorImplCopyWith<_$NotFoundErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnauthorizedErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$UnauthorizedErrorImplCopyWith(_$UnauthorizedErrorImpl value,
          $Res Function(_$UnauthorizedErrorImpl) then) =
      __$$UnauthorizedErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? code, Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$UnauthorizedErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$UnauthorizedErrorImpl>
    implements _$$UnauthorizedErrorImplCopyWith<$Res> {
  __$$UnauthorizedErrorImplCopyWithImpl(_$UnauthorizedErrorImpl _value,
      $Res Function(_$UnauthorizedErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$UnauthorizedErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$UnauthorizedErrorImpl extends UnauthorizedError {
  const _$UnauthorizedErrorImpl(
      {required this.message, this.code, final Map<String, dynamic>? metadata})
      : _metadata = metadata,
        super._();

  @override
  final String message;
  @override
  final String? code;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppError.unauthorized(message: $message, code: $code, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnauthorizedErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnauthorizedErrorImplCopyWith<_$UnauthorizedErrorImpl> get copyWith =>
      __$$UnauthorizedErrorImplCopyWithImpl<_$UnauthorizedErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        notFound,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        unauthorized,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        network,
    required TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)
        validation,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        storage,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        duplicate,
    required TResult Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)
        sync,
    required TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)
        unknown,
  }) {
    return unauthorized(message, code, metadata);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        notFound,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        unauthorized,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        network,
    TResult? Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)?
        validation,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        storage,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        duplicate,
    TResult? Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)?
        sync,
    TResult? Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)?
        unknown,
  }) {
    return unauthorized?.call(message, code, metadata);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        notFound,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        unauthorized,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        network,
    TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)?
        validation,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        storage,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        duplicate,
    TResult Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)?
        sync,
    TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)?
        unknown,
    required TResult orElse(),
  }) {
    if (unauthorized != null) {
      return unauthorized(message, code, metadata);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(UnauthorizedError value) unauthorized,
    required TResult Function(NetworkError value) network,
    required TResult Function(ValidationError value) validation,
    required TResult Function(StorageError value) storage,
    required TResult Function(DuplicateError value) duplicate,
    required TResult Function(SyncError value) sync,
    required TResult Function(UnknownError value) unknown,
  }) {
    return unauthorized(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(UnauthorizedError value)? unauthorized,
    TResult? Function(NetworkError value)? network,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(StorageError value)? storage,
    TResult? Function(DuplicateError value)? duplicate,
    TResult? Function(SyncError value)? sync,
    TResult? Function(UnknownError value)? unknown,
  }) {
    return unauthorized?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotFoundError value)? notFound,
    TResult Function(UnauthorizedError value)? unauthorized,
    TResult Function(NetworkError value)? network,
    TResult Function(ValidationError value)? validation,
    TResult Function(StorageError value)? storage,
    TResult Function(DuplicateError value)? duplicate,
    TResult Function(SyncError value)? sync,
    TResult Function(UnknownError value)? unknown,
    required TResult orElse(),
  }) {
    if (unauthorized != null) {
      return unauthorized(this);
    }
    return orElse();
  }
}

abstract class UnauthorizedError extends AppError {
  const factory UnauthorizedError(
      {required final String message,
      final String? code,
      final Map<String, dynamic>? metadata}) = _$UnauthorizedErrorImpl;
  const UnauthorizedError._() : super._();

  @override
  String get message;
  @override
  String? get code;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnauthorizedErrorImplCopyWith<_$UnauthorizedErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NetworkErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$NetworkErrorImplCopyWith(
          _$NetworkErrorImpl value, $Res Function(_$NetworkErrorImpl) then) =
      __$$NetworkErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? code, Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$NetworkErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$NetworkErrorImpl>
    implements _$$NetworkErrorImplCopyWith<$Res> {
  __$$NetworkErrorImplCopyWithImpl(
      _$NetworkErrorImpl _value, $Res Function(_$NetworkErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$NetworkErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$NetworkErrorImpl extends NetworkError {
  const _$NetworkErrorImpl(
      {required this.message, this.code, final Map<String, dynamic>? metadata})
      : _metadata = metadata,
        super._();

  @override
  final String message;
  @override
  final String? code;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppError.network(message: $message, code: $code, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkErrorImplCopyWith<_$NetworkErrorImpl> get copyWith =>
      __$$NetworkErrorImplCopyWithImpl<_$NetworkErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        notFound,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        unauthorized,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        network,
    required TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)
        validation,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        storage,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        duplicate,
    required TResult Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)
        sync,
    required TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)
        unknown,
  }) {
    return network(message, code, metadata);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        notFound,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        unauthorized,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        network,
    TResult? Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)?
        validation,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        storage,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        duplicate,
    TResult? Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)?
        sync,
    TResult? Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)?
        unknown,
  }) {
    return network?.call(message, code, metadata);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        notFound,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        unauthorized,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        network,
    TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)?
        validation,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        storage,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        duplicate,
    TResult Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)?
        sync,
    TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)?
        unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(message, code, metadata);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(UnauthorizedError value) unauthorized,
    required TResult Function(NetworkError value) network,
    required TResult Function(ValidationError value) validation,
    required TResult Function(StorageError value) storage,
    required TResult Function(DuplicateError value) duplicate,
    required TResult Function(SyncError value) sync,
    required TResult Function(UnknownError value) unknown,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(UnauthorizedError value)? unauthorized,
    TResult? Function(NetworkError value)? network,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(StorageError value)? storage,
    TResult? Function(DuplicateError value)? duplicate,
    TResult? Function(SyncError value)? sync,
    TResult? Function(UnknownError value)? unknown,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotFoundError value)? notFound,
    TResult Function(UnauthorizedError value)? unauthorized,
    TResult Function(NetworkError value)? network,
    TResult Function(ValidationError value)? validation,
    TResult Function(StorageError value)? storage,
    TResult Function(DuplicateError value)? duplicate,
    TResult Function(SyncError value)? sync,
    TResult Function(UnknownError value)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class NetworkError extends AppError {
  const factory NetworkError(
      {required final String message,
      final String? code,
      final Map<String, dynamic>? metadata}) = _$NetworkErrorImpl;
  const NetworkError._() : super._();

  @override
  String get message;
  @override
  String? get code;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NetworkErrorImplCopyWith<_$NetworkErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ValidationErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$ValidationErrorImplCopyWith(_$ValidationErrorImpl value,
          $Res Function(_$ValidationErrorImpl) then) =
      __$$ValidationErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String message,
      String? code,
      Map<String, dynamic>? metadata,
      Map<String, List<String>>? fieldErrors});
}

/// @nodoc
class __$$ValidationErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$ValidationErrorImpl>
    implements _$$ValidationErrorImplCopyWith<$Res> {
  __$$ValidationErrorImplCopyWithImpl(
      _$ValidationErrorImpl _value, $Res Function(_$ValidationErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? metadata = freezed,
    Object? fieldErrors = freezed,
  }) {
    return _then(_$ValidationErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      fieldErrors: freezed == fieldErrors
          ? _value._fieldErrors
          : fieldErrors // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>?,
    ));
  }
}

/// @nodoc

class _$ValidationErrorImpl extends ValidationError {
  const _$ValidationErrorImpl(
      {required this.message,
      this.code,
      final Map<String, dynamic>? metadata,
      final Map<String, List<String>>? fieldErrors})
      : _metadata = metadata,
        _fieldErrors = fieldErrors,
        super._();

  @override
  final String message;
  @override
  final String? code;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, List<String>>? _fieldErrors;
  @override
  Map<String, List<String>>? get fieldErrors {
    final value = _fieldErrors;
    if (value == null) return null;
    if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppError.validation(message: $message, code: $code, metadata: $metadata, fieldErrors: $fieldErrors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            const DeepCollectionEquality()
                .equals(other._fieldErrors, _fieldErrors));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      message,
      code,
      const DeepCollectionEquality().hash(_metadata),
      const DeepCollectionEquality().hash(_fieldErrors));

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationErrorImplCopyWith<_$ValidationErrorImpl> get copyWith =>
      __$$ValidationErrorImplCopyWithImpl<_$ValidationErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        notFound,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        unauthorized,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        network,
    required TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)
        validation,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        storage,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        duplicate,
    required TResult Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)
        sync,
    required TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)
        unknown,
  }) {
    return validation(message, code, metadata, fieldErrors);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        notFound,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        unauthorized,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        network,
    TResult? Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)?
        validation,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        storage,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        duplicate,
    TResult? Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)?
        sync,
    TResult? Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)?
        unknown,
  }) {
    return validation?.call(message, code, metadata, fieldErrors);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        notFound,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        unauthorized,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        network,
    TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)?
        validation,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        storage,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        duplicate,
    TResult Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)?
        sync,
    TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)?
        unknown,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(message, code, metadata, fieldErrors);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(UnauthorizedError value) unauthorized,
    required TResult Function(NetworkError value) network,
    required TResult Function(ValidationError value) validation,
    required TResult Function(StorageError value) storage,
    required TResult Function(DuplicateError value) duplicate,
    required TResult Function(SyncError value) sync,
    required TResult Function(UnknownError value) unknown,
  }) {
    return validation(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(UnauthorizedError value)? unauthorized,
    TResult? Function(NetworkError value)? network,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(StorageError value)? storage,
    TResult? Function(DuplicateError value)? duplicate,
    TResult? Function(SyncError value)? sync,
    TResult? Function(UnknownError value)? unknown,
  }) {
    return validation?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotFoundError value)? notFound,
    TResult Function(UnauthorizedError value)? unauthorized,
    TResult Function(NetworkError value)? network,
    TResult Function(ValidationError value)? validation,
    TResult Function(StorageError value)? storage,
    TResult Function(DuplicateError value)? duplicate,
    TResult Function(SyncError value)? sync,
    TResult Function(UnknownError value)? unknown,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(this);
    }
    return orElse();
  }
}

abstract class ValidationError extends AppError {
  const factory ValidationError(
      {required final String message,
      final String? code,
      final Map<String, dynamic>? metadata,
      final Map<String, List<String>>? fieldErrors}) = _$ValidationErrorImpl;
  const ValidationError._() : super._();

  @override
  String get message;
  @override
  String? get code;
  @override
  Map<String, dynamic>? get metadata;
  Map<String, List<String>>? get fieldErrors;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationErrorImplCopyWith<_$ValidationErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$StorageErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$StorageErrorImplCopyWith(
          _$StorageErrorImpl value, $Res Function(_$StorageErrorImpl) then) =
      __$$StorageErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? code, Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$StorageErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$StorageErrorImpl>
    implements _$$StorageErrorImplCopyWith<$Res> {
  __$$StorageErrorImplCopyWithImpl(
      _$StorageErrorImpl _value, $Res Function(_$StorageErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$StorageErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$StorageErrorImpl extends StorageError {
  const _$StorageErrorImpl(
      {required this.message, this.code, final Map<String, dynamic>? metadata})
      : _metadata = metadata,
        super._();

  @override
  final String message;
  @override
  final String? code;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppError.storage(message: $message, code: $code, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StorageErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StorageErrorImplCopyWith<_$StorageErrorImpl> get copyWith =>
      __$$StorageErrorImplCopyWithImpl<_$StorageErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        notFound,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        unauthorized,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        network,
    required TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)
        validation,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        storage,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        duplicate,
    required TResult Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)
        sync,
    required TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)
        unknown,
  }) {
    return storage(message, code, metadata);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        notFound,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        unauthorized,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        network,
    TResult? Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)?
        validation,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        storage,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        duplicate,
    TResult? Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)?
        sync,
    TResult? Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)?
        unknown,
  }) {
    return storage?.call(message, code, metadata);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        notFound,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        unauthorized,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        network,
    TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)?
        validation,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        storage,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        duplicate,
    TResult Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)?
        sync,
    TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)?
        unknown,
    required TResult orElse(),
  }) {
    if (storage != null) {
      return storage(message, code, metadata);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(UnauthorizedError value) unauthorized,
    required TResult Function(NetworkError value) network,
    required TResult Function(ValidationError value) validation,
    required TResult Function(StorageError value) storage,
    required TResult Function(DuplicateError value) duplicate,
    required TResult Function(SyncError value) sync,
    required TResult Function(UnknownError value) unknown,
  }) {
    return storage(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(UnauthorizedError value)? unauthorized,
    TResult? Function(NetworkError value)? network,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(StorageError value)? storage,
    TResult? Function(DuplicateError value)? duplicate,
    TResult? Function(SyncError value)? sync,
    TResult? Function(UnknownError value)? unknown,
  }) {
    return storage?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotFoundError value)? notFound,
    TResult Function(UnauthorizedError value)? unauthorized,
    TResult Function(NetworkError value)? network,
    TResult Function(ValidationError value)? validation,
    TResult Function(StorageError value)? storage,
    TResult Function(DuplicateError value)? duplicate,
    TResult Function(SyncError value)? sync,
    TResult Function(UnknownError value)? unknown,
    required TResult orElse(),
  }) {
    if (storage != null) {
      return storage(this);
    }
    return orElse();
  }
}

abstract class StorageError extends AppError {
  const factory StorageError(
      {required final String message,
      final String? code,
      final Map<String, dynamic>? metadata}) = _$StorageErrorImpl;
  const StorageError._() : super._();

  @override
  String get message;
  @override
  String? get code;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StorageErrorImplCopyWith<_$StorageErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DuplicateErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$DuplicateErrorImplCopyWith(_$DuplicateErrorImpl value,
          $Res Function(_$DuplicateErrorImpl) then) =
      __$$DuplicateErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? code, Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$DuplicateErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$DuplicateErrorImpl>
    implements _$$DuplicateErrorImplCopyWith<$Res> {
  __$$DuplicateErrorImplCopyWithImpl(
      _$DuplicateErrorImpl _value, $Res Function(_$DuplicateErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$DuplicateErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$DuplicateErrorImpl extends DuplicateError {
  const _$DuplicateErrorImpl(
      {required this.message, this.code, final Map<String, dynamic>? metadata})
      : _metadata = metadata,
        super._();

  @override
  final String message;
  @override
  final String? code;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppError.duplicate(message: $message, code: $code, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DuplicateErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DuplicateErrorImplCopyWith<_$DuplicateErrorImpl> get copyWith =>
      __$$DuplicateErrorImplCopyWithImpl<_$DuplicateErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        notFound,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        unauthorized,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        network,
    required TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)
        validation,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        storage,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        duplicate,
    required TResult Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)
        sync,
    required TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)
        unknown,
  }) {
    return duplicate(message, code, metadata);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        notFound,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        unauthorized,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        network,
    TResult? Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)?
        validation,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        storage,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        duplicate,
    TResult? Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)?
        sync,
    TResult? Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)?
        unknown,
  }) {
    return duplicate?.call(message, code, metadata);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        notFound,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        unauthorized,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        network,
    TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)?
        validation,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        storage,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        duplicate,
    TResult Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)?
        sync,
    TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)?
        unknown,
    required TResult orElse(),
  }) {
    if (duplicate != null) {
      return duplicate(message, code, metadata);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(UnauthorizedError value) unauthorized,
    required TResult Function(NetworkError value) network,
    required TResult Function(ValidationError value) validation,
    required TResult Function(StorageError value) storage,
    required TResult Function(DuplicateError value) duplicate,
    required TResult Function(SyncError value) sync,
    required TResult Function(UnknownError value) unknown,
  }) {
    return duplicate(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(UnauthorizedError value)? unauthorized,
    TResult? Function(NetworkError value)? network,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(StorageError value)? storage,
    TResult? Function(DuplicateError value)? duplicate,
    TResult? Function(SyncError value)? sync,
    TResult? Function(UnknownError value)? unknown,
  }) {
    return duplicate?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotFoundError value)? notFound,
    TResult Function(UnauthorizedError value)? unauthorized,
    TResult Function(NetworkError value)? network,
    TResult Function(ValidationError value)? validation,
    TResult Function(StorageError value)? storage,
    TResult Function(DuplicateError value)? duplicate,
    TResult Function(SyncError value)? sync,
    TResult Function(UnknownError value)? unknown,
    required TResult orElse(),
  }) {
    if (duplicate != null) {
      return duplicate(this);
    }
    return orElse();
  }
}

abstract class DuplicateError extends AppError {
  const factory DuplicateError(
      {required final String message,
      final String? code,
      final Map<String, dynamic>? metadata}) = _$DuplicateErrorImpl;
  const DuplicateError._() : super._();

  @override
  String get message;
  @override
  String? get code;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DuplicateErrorImplCopyWith<_$DuplicateErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SyncErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$SyncErrorImplCopyWith(
          _$SyncErrorImpl value, $Res Function(_$SyncErrorImpl) then) =
      __$$SyncErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String message,
      String? code,
      Map<String, dynamic>? metadata,
      List<String>? conflictIds});
}

/// @nodoc
class __$$SyncErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$SyncErrorImpl>
    implements _$$SyncErrorImplCopyWith<$Res> {
  __$$SyncErrorImplCopyWithImpl(
      _$SyncErrorImpl _value, $Res Function(_$SyncErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? metadata = freezed,
    Object? conflictIds = freezed,
  }) {
    return _then(_$SyncErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      conflictIds: freezed == conflictIds
          ? _value._conflictIds
          : conflictIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc

class _$SyncErrorImpl extends SyncError {
  const _$SyncErrorImpl(
      {required this.message,
      this.code,
      final Map<String, dynamic>? metadata,
      final List<String>? conflictIds})
      : _metadata = metadata,
        _conflictIds = conflictIds,
        super._();

  @override
  final String message;
  @override
  final String? code;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<String>? _conflictIds;
  @override
  List<String>? get conflictIds {
    final value = _conflictIds;
    if (value == null) return null;
    if (_conflictIds is EqualUnmodifiableListView) return _conflictIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'AppError.sync(message: $message, code: $code, metadata: $metadata, conflictIds: $conflictIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            const DeepCollectionEquality()
                .equals(other._conflictIds, _conflictIds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      message,
      code,
      const DeepCollectionEquality().hash(_metadata),
      const DeepCollectionEquality().hash(_conflictIds));

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncErrorImplCopyWith<_$SyncErrorImpl> get copyWith =>
      __$$SyncErrorImplCopyWithImpl<_$SyncErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        notFound,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        unauthorized,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        network,
    required TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)
        validation,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        storage,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        duplicate,
    required TResult Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)
        sync,
    required TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)
        unknown,
  }) {
    return sync(message, code, metadata, conflictIds);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        notFound,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        unauthorized,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        network,
    TResult? Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)?
        validation,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        storage,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        duplicate,
    TResult? Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)?
        sync,
    TResult? Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)?
        unknown,
  }) {
    return sync?.call(message, code, metadata, conflictIds);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        notFound,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        unauthorized,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        network,
    TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)?
        validation,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        storage,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        duplicate,
    TResult Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)?
        sync,
    TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)?
        unknown,
    required TResult orElse(),
  }) {
    if (sync != null) {
      return sync(message, code, metadata, conflictIds);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(UnauthorizedError value) unauthorized,
    required TResult Function(NetworkError value) network,
    required TResult Function(ValidationError value) validation,
    required TResult Function(StorageError value) storage,
    required TResult Function(DuplicateError value) duplicate,
    required TResult Function(SyncError value) sync,
    required TResult Function(UnknownError value) unknown,
  }) {
    return sync(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(UnauthorizedError value)? unauthorized,
    TResult? Function(NetworkError value)? network,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(StorageError value)? storage,
    TResult? Function(DuplicateError value)? duplicate,
    TResult? Function(SyncError value)? sync,
    TResult? Function(UnknownError value)? unknown,
  }) {
    return sync?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotFoundError value)? notFound,
    TResult Function(UnauthorizedError value)? unauthorized,
    TResult Function(NetworkError value)? network,
    TResult Function(ValidationError value)? validation,
    TResult Function(StorageError value)? storage,
    TResult Function(DuplicateError value)? duplicate,
    TResult Function(SyncError value)? sync,
    TResult Function(UnknownError value)? unknown,
    required TResult orElse(),
  }) {
    if (sync != null) {
      return sync(this);
    }
    return orElse();
  }
}

abstract class SyncError extends AppError {
  const factory SyncError(
      {required final String message,
      final String? code,
      final Map<String, dynamic>? metadata,
      final List<String>? conflictIds}) = _$SyncErrorImpl;
  const SyncError._() : super._();

  @override
  String get message;
  @override
  String? get code;
  @override
  Map<String, dynamic>? get metadata;
  List<String>? get conflictIds;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncErrorImplCopyWith<_$SyncErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnknownErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$UnknownErrorImplCopyWith(
          _$UnknownErrorImpl value, $Res Function(_$UnknownErrorImpl) then) =
      __$$UnknownErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String message,
      String? code,
      Map<String, dynamic>? metadata,
      Object? originalError,
      StackTrace? stackTrace});
}

/// @nodoc
class __$$UnknownErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$UnknownErrorImpl>
    implements _$$UnknownErrorImplCopyWith<$Res> {
  __$$UnknownErrorImplCopyWithImpl(
      _$UnknownErrorImpl _value, $Res Function(_$UnknownErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? metadata = freezed,
    Object? originalError = freezed,
    Object? stackTrace = freezed,
  }) {
    return _then(_$UnknownErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      originalError:
          freezed == originalError ? _value.originalError : originalError,
      stackTrace: freezed == stackTrace
          ? _value.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as StackTrace?,
    ));
  }
}

/// @nodoc

class _$UnknownErrorImpl extends UnknownError {
  const _$UnknownErrorImpl(
      {required this.message,
      this.code,
      final Map<String, dynamic>? metadata,
      this.originalError,
      this.stackTrace})
      : _metadata = metadata,
        super._();

  @override
  final String message;
  @override
  final String? code;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final Object? originalError;
  @override
  final StackTrace? stackTrace;

  @override
  String toString() {
    return 'AppError.unknown(message: $message, code: $code, metadata: $metadata, originalError: $originalError, stackTrace: $stackTrace)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            const DeepCollectionEquality()
                .equals(other.originalError, originalError) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      message,
      code,
      const DeepCollectionEquality().hash(_metadata),
      const DeepCollectionEquality().hash(originalError),
      stackTrace);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownErrorImplCopyWith<_$UnknownErrorImpl> get copyWith =>
      __$$UnknownErrorImplCopyWithImpl<_$UnknownErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        notFound,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        unauthorized,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        network,
    required TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)
        validation,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        storage,
    required TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)
        duplicate,
    required TResult Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)
        sync,
    required TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)
        unknown,
  }) {
    return unknown(message, code, metadata, originalError, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        notFound,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        unauthorized,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        network,
    TResult? Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)?
        validation,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        storage,
    TResult? Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        duplicate,
    TResult? Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)?
        sync,
    TResult? Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)?
        unknown,
  }) {
    return unknown?.call(message, code, metadata, originalError, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        notFound,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        unauthorized,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        network,
    TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Map<String, List<String>>? fieldErrors)?
        validation,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        storage,
    TResult Function(
            String message, String? code, Map<String, dynamic>? metadata)?
        duplicate,
    TResult Function(String message, String? code,
            Map<String, dynamic>? metadata, List<String>? conflictIds)?
        sync,
    TResult Function(
            String message,
            String? code,
            Map<String, dynamic>? metadata,
            Object? originalError,
            StackTrace? stackTrace)?
        unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(message, code, metadata, originalError, stackTrace);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(UnauthorizedError value) unauthorized,
    required TResult Function(NetworkError value) network,
    required TResult Function(ValidationError value) validation,
    required TResult Function(StorageError value) storage,
    required TResult Function(DuplicateError value) duplicate,
    required TResult Function(SyncError value) sync,
    required TResult Function(UnknownError value) unknown,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(UnauthorizedError value)? unauthorized,
    TResult? Function(NetworkError value)? network,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(StorageError value)? storage,
    TResult? Function(DuplicateError value)? duplicate,
    TResult? Function(SyncError value)? sync,
    TResult? Function(UnknownError value)? unknown,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotFoundError value)? notFound,
    TResult Function(UnauthorizedError value)? unauthorized,
    TResult Function(NetworkError value)? network,
    TResult Function(ValidationError value)? validation,
    TResult Function(StorageError value)? storage,
    TResult Function(DuplicateError value)? duplicate,
    TResult Function(SyncError value)? sync,
    TResult Function(UnknownError value)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class UnknownError extends AppError {
  const factory UnknownError(
      {required final String message,
      final String? code,
      final Map<String, dynamic>? metadata,
      final Object? originalError,
      final StackTrace? stackTrace}) = _$UnknownErrorImpl;
  const UnknownError._() : super._();

  @override
  String get message;
  @override
  String? get code;
  @override
  Map<String, dynamic>? get metadata;
  Object? get originalError;
  StackTrace? get stackTrace;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnknownErrorImplCopyWith<_$UnknownErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
