// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failures.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Failure {
  String get message => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode, String? code)
    network,
    required TResult Function(String message, String? query, String? stackTrace)
    database,
    required TResult Function(String message, Map<String, List<String>> errors)
    validation,
    required TResult Function(
      String message,
      String resourceId,
      String? resourceType,
    )
    notFound,
    required TResult Function(String message, String? requiredPermission)
    permission,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )
    business,
    required TResult Function(String message, String? path, String? operation)
    storage,
    required TResult Function(String message, double? confidence, String? stage)
    processing,
    required TResult Function(String message, String? stackTrace) unexpected,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode, String? code)? network,
    TResult? Function(String message, String? query, String? stackTrace)?
    database,
    TResult? Function(String message, Map<String, List<String>> errors)?
    validation,
    TResult? Function(String message, String resourceId, String? resourceType)?
    notFound,
    TResult? Function(String message, String? requiredPermission)? permission,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )?
    business,
    TResult? Function(String message, String? path, String? operation)? storage,
    TResult? Function(String message, double? confidence, String? stage)?
    processing,
    TResult? Function(String message, String? stackTrace)? unexpected,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode, String? code)? network,
    TResult Function(String message, String? query, String? stackTrace)?
    database,
    TResult Function(String message, Map<String, List<String>> errors)?
    validation,
    TResult Function(String message, String resourceId, String? resourceType)?
    notFound,
    TResult Function(String message, String? requiredPermission)? permission,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )?
    business,
    TResult Function(String message, String? path, String? operation)? storage,
    TResult Function(String message, double? confidence, String? stage)?
    processing,
    TResult Function(String message, String? stackTrace)? unexpected,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(DatabaseFailure value) database,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(BusinessFailure value) business,
    required TResult Function(StorageFailure value) storage,
    required TResult Function(ProcessingFailure value) processing,
    required TResult Function(UnexpectedFailure value) unexpected,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(DatabaseFailure value)? database,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(BusinessFailure value)? business,
    TResult? Function(StorageFailure value)? storage,
    TResult? Function(ProcessingFailure value)? processing,
    TResult? Function(UnexpectedFailure value)? unexpected,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(DatabaseFailure value)? database,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(BusinessFailure value)? business,
    TResult Function(StorageFailure value)? storage,
    TResult Function(ProcessingFailure value)? processing,
    TResult Function(UnexpectedFailure value)? unexpected,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FailureCopyWith<Failure> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FailureCopyWith<$Res> {
  factory $FailureCopyWith(Failure value, $Res Function(Failure) then) =
      _$FailureCopyWithImpl<$Res, Failure>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$FailureCopyWithImpl<$Res, $Val extends Failure>
    implements $FailureCopyWith<$Res> {
  _$FailureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _value.copyWith(
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NetworkFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$NetworkFailureImplCopyWith(
    _$NetworkFailureImpl value,
    $Res Function(_$NetworkFailureImpl) then,
  ) = __$$NetworkFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, int? statusCode, String? code});
}

/// @nodoc
class __$$NetworkFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$NetworkFailureImpl>
    implements _$$NetworkFailureImplCopyWith<$Res> {
  __$$NetworkFailureImplCopyWithImpl(
    _$NetworkFailureImpl _value,
    $Res Function(_$NetworkFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? statusCode = freezed,
    Object? code = freezed,
  }) {
    return _then(
      _$NetworkFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        statusCode: freezed == statusCode
            ? _value.statusCode
            : statusCode // ignore: cast_nullable_to_non_nullable
                  as int?,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$NetworkFailureImpl extends NetworkFailure {
  const _$NetworkFailureImpl({
    required this.message,
    this.statusCode,
    this.code,
  }) : super._();

  @override
  final String message;
  @override
  final int? statusCode;
  @override
  final String? code;

  @override
  String toString() {
    return 'Failure.network(message: $message, statusCode: $statusCode, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.code, code) || other.code == code));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, statusCode, code);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkFailureImplCopyWith<_$NetworkFailureImpl> get copyWith =>
      __$$NetworkFailureImplCopyWithImpl<_$NetworkFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode, String? code)
    network,
    required TResult Function(String message, String? query, String? stackTrace)
    database,
    required TResult Function(String message, Map<String, List<String>> errors)
    validation,
    required TResult Function(
      String message,
      String resourceId,
      String? resourceType,
    )
    notFound,
    required TResult Function(String message, String? requiredPermission)
    permission,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )
    business,
    required TResult Function(String message, String? path, String? operation)
    storage,
    required TResult Function(String message, double? confidence, String? stage)
    processing,
    required TResult Function(String message, String? stackTrace) unexpected,
  }) {
    return network(message, statusCode, code);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode, String? code)? network,
    TResult? Function(String message, String? query, String? stackTrace)?
    database,
    TResult? Function(String message, Map<String, List<String>> errors)?
    validation,
    TResult? Function(String message, String resourceId, String? resourceType)?
    notFound,
    TResult? Function(String message, String? requiredPermission)? permission,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )?
    business,
    TResult? Function(String message, String? path, String? operation)? storage,
    TResult? Function(String message, double? confidence, String? stage)?
    processing,
    TResult? Function(String message, String? stackTrace)? unexpected,
  }) {
    return network?.call(message, statusCode, code);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode, String? code)? network,
    TResult Function(String message, String? query, String? stackTrace)?
    database,
    TResult Function(String message, Map<String, List<String>> errors)?
    validation,
    TResult Function(String message, String resourceId, String? resourceType)?
    notFound,
    TResult Function(String message, String? requiredPermission)? permission,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )?
    business,
    TResult Function(String message, String? path, String? operation)? storage,
    TResult Function(String message, double? confidence, String? stage)?
    processing,
    TResult Function(String message, String? stackTrace)? unexpected,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(message, statusCode, code);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(DatabaseFailure value) database,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(BusinessFailure value) business,
    required TResult Function(StorageFailure value) storage,
    required TResult Function(ProcessingFailure value) processing,
    required TResult Function(UnexpectedFailure value) unexpected,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(DatabaseFailure value)? database,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(BusinessFailure value)? business,
    TResult? Function(StorageFailure value)? storage,
    TResult? Function(ProcessingFailure value)? processing,
    TResult? Function(UnexpectedFailure value)? unexpected,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(DatabaseFailure value)? database,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(BusinessFailure value)? business,
    TResult Function(StorageFailure value)? storage,
    TResult Function(ProcessingFailure value)? processing,
    TResult Function(UnexpectedFailure value)? unexpected,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class NetworkFailure extends Failure {
  const factory NetworkFailure({
    required final String message,
    final int? statusCode,
    final String? code,
  }) = _$NetworkFailureImpl;
  const NetworkFailure._() : super._();

  @override
  String get message;
  int? get statusCode;
  String? get code;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NetworkFailureImplCopyWith<_$NetworkFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DatabaseFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$DatabaseFailureImplCopyWith(
    _$DatabaseFailureImpl value,
    $Res Function(_$DatabaseFailureImpl) then,
  ) = __$$DatabaseFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? query, String? stackTrace});
}

/// @nodoc
class __$$DatabaseFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$DatabaseFailureImpl>
    implements _$$DatabaseFailureImplCopyWith<$Res> {
  __$$DatabaseFailureImplCopyWithImpl(
    _$DatabaseFailureImpl _value,
    $Res Function(_$DatabaseFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? query = freezed,
    Object? stackTrace = freezed,
  }) {
    return _then(
      _$DatabaseFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        query: freezed == query
            ? _value.query
            : query // ignore: cast_nullable_to_non_nullable
                  as String?,
        stackTrace: freezed == stackTrace
            ? _value.stackTrace
            : stackTrace // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$DatabaseFailureImpl extends DatabaseFailure {
  const _$DatabaseFailureImpl({
    required this.message,
    this.query,
    this.stackTrace,
  }) : super._();

  @override
  final String message;
  @override
  final String? query;
  @override
  final String? stackTrace;

  @override
  String toString() {
    return 'Failure.database(message: $message, query: $query, stackTrace: $stackTrace)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DatabaseFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, query, stackTrace);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DatabaseFailureImplCopyWith<_$DatabaseFailureImpl> get copyWith =>
      __$$DatabaseFailureImplCopyWithImpl<_$DatabaseFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode, String? code)
    network,
    required TResult Function(String message, String? query, String? stackTrace)
    database,
    required TResult Function(String message, Map<String, List<String>> errors)
    validation,
    required TResult Function(
      String message,
      String resourceId,
      String? resourceType,
    )
    notFound,
    required TResult Function(String message, String? requiredPermission)
    permission,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )
    business,
    required TResult Function(String message, String? path, String? operation)
    storage,
    required TResult Function(String message, double? confidence, String? stage)
    processing,
    required TResult Function(String message, String? stackTrace) unexpected,
  }) {
    return database(message, query, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode, String? code)? network,
    TResult? Function(String message, String? query, String? stackTrace)?
    database,
    TResult? Function(String message, Map<String, List<String>> errors)?
    validation,
    TResult? Function(String message, String resourceId, String? resourceType)?
    notFound,
    TResult? Function(String message, String? requiredPermission)? permission,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )?
    business,
    TResult? Function(String message, String? path, String? operation)? storage,
    TResult? Function(String message, double? confidence, String? stage)?
    processing,
    TResult? Function(String message, String? stackTrace)? unexpected,
  }) {
    return database?.call(message, query, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode, String? code)? network,
    TResult Function(String message, String? query, String? stackTrace)?
    database,
    TResult Function(String message, Map<String, List<String>> errors)?
    validation,
    TResult Function(String message, String resourceId, String? resourceType)?
    notFound,
    TResult Function(String message, String? requiredPermission)? permission,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )?
    business,
    TResult Function(String message, String? path, String? operation)? storage,
    TResult Function(String message, double? confidence, String? stage)?
    processing,
    TResult Function(String message, String? stackTrace)? unexpected,
    required TResult orElse(),
  }) {
    if (database != null) {
      return database(message, query, stackTrace);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(DatabaseFailure value) database,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(BusinessFailure value) business,
    required TResult Function(StorageFailure value) storage,
    required TResult Function(ProcessingFailure value) processing,
    required TResult Function(UnexpectedFailure value) unexpected,
  }) {
    return database(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(DatabaseFailure value)? database,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(BusinessFailure value)? business,
    TResult? Function(StorageFailure value)? storage,
    TResult? Function(ProcessingFailure value)? processing,
    TResult? Function(UnexpectedFailure value)? unexpected,
  }) {
    return database?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(DatabaseFailure value)? database,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(BusinessFailure value)? business,
    TResult Function(StorageFailure value)? storage,
    TResult Function(ProcessingFailure value)? processing,
    TResult Function(UnexpectedFailure value)? unexpected,
    required TResult orElse(),
  }) {
    if (database != null) {
      return database(this);
    }
    return orElse();
  }
}

abstract class DatabaseFailure extends Failure {
  const factory DatabaseFailure({
    required final String message,
    final String? query,
    final String? stackTrace,
  }) = _$DatabaseFailureImpl;
  const DatabaseFailure._() : super._();

  @override
  String get message;
  String? get query;
  String? get stackTrace;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DatabaseFailureImplCopyWith<_$DatabaseFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ValidationFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$ValidationFailureImplCopyWith(
    _$ValidationFailureImpl value,
    $Res Function(_$ValidationFailureImpl) then,
  ) = __$$ValidationFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, Map<String, List<String>> errors});
}

/// @nodoc
class __$$ValidationFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$ValidationFailureImpl>
    implements _$$ValidationFailureImplCopyWith<$Res> {
  __$$ValidationFailureImplCopyWithImpl(
    _$ValidationFailureImpl _value,
    $Res Function(_$ValidationFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? errors = null}) {
    return _then(
      _$ValidationFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        errors: null == errors
            ? _value._errors
            : errors // ignore: cast_nullable_to_non_nullable
                  as Map<String, List<String>>,
      ),
    );
  }
}

/// @nodoc

class _$ValidationFailureImpl extends ValidationFailure {
  const _$ValidationFailureImpl({
    required this.message,
    required final Map<String, List<String>> errors,
  }) : _errors = errors,
       super._();

  @override
  final String message;
  final Map<String, List<String>> _errors;
  @override
  Map<String, List<String>> get errors {
    if (_errors is EqualUnmodifiableMapView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_errors);
  }

  @override
  String toString() {
    return 'Failure.validation(message: $message, errors: $errors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._errors, _errors));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    const DeepCollectionEquality().hash(_errors),
  );

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationFailureImplCopyWith<_$ValidationFailureImpl> get copyWith =>
      __$$ValidationFailureImplCopyWithImpl<_$ValidationFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode, String? code)
    network,
    required TResult Function(String message, String? query, String? stackTrace)
    database,
    required TResult Function(String message, Map<String, List<String>> errors)
    validation,
    required TResult Function(
      String message,
      String resourceId,
      String? resourceType,
    )
    notFound,
    required TResult Function(String message, String? requiredPermission)
    permission,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )
    business,
    required TResult Function(String message, String? path, String? operation)
    storage,
    required TResult Function(String message, double? confidence, String? stage)
    processing,
    required TResult Function(String message, String? stackTrace) unexpected,
  }) {
    return validation(message, errors);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode, String? code)? network,
    TResult? Function(String message, String? query, String? stackTrace)?
    database,
    TResult? Function(String message, Map<String, List<String>> errors)?
    validation,
    TResult? Function(String message, String resourceId, String? resourceType)?
    notFound,
    TResult? Function(String message, String? requiredPermission)? permission,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )?
    business,
    TResult? Function(String message, String? path, String? operation)? storage,
    TResult? Function(String message, double? confidence, String? stage)?
    processing,
    TResult? Function(String message, String? stackTrace)? unexpected,
  }) {
    return validation?.call(message, errors);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode, String? code)? network,
    TResult Function(String message, String? query, String? stackTrace)?
    database,
    TResult Function(String message, Map<String, List<String>> errors)?
    validation,
    TResult Function(String message, String resourceId, String? resourceType)?
    notFound,
    TResult Function(String message, String? requiredPermission)? permission,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )?
    business,
    TResult Function(String message, String? path, String? operation)? storage,
    TResult Function(String message, double? confidence, String? stage)?
    processing,
    TResult Function(String message, String? stackTrace)? unexpected,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(message, errors);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(DatabaseFailure value) database,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(BusinessFailure value) business,
    required TResult Function(StorageFailure value) storage,
    required TResult Function(ProcessingFailure value) processing,
    required TResult Function(UnexpectedFailure value) unexpected,
  }) {
    return validation(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(DatabaseFailure value)? database,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(BusinessFailure value)? business,
    TResult? Function(StorageFailure value)? storage,
    TResult? Function(ProcessingFailure value)? processing,
    TResult? Function(UnexpectedFailure value)? unexpected,
  }) {
    return validation?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(DatabaseFailure value)? database,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(BusinessFailure value)? business,
    TResult Function(StorageFailure value)? storage,
    TResult Function(ProcessingFailure value)? processing,
    TResult Function(UnexpectedFailure value)? unexpected,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(this);
    }
    return orElse();
  }
}

abstract class ValidationFailure extends Failure {
  const factory ValidationFailure({
    required final String message,
    required final Map<String, List<String>> errors,
  }) = _$ValidationFailureImpl;
  const ValidationFailure._() : super._();

  @override
  String get message;
  Map<String, List<String>> get errors;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationFailureImplCopyWith<_$ValidationFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NotFoundFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$NotFoundFailureImplCopyWith(
    _$NotFoundFailureImpl value,
    $Res Function(_$NotFoundFailureImpl) then,
  ) = __$$NotFoundFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String resourceId, String? resourceType});
}

/// @nodoc
class __$$NotFoundFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$NotFoundFailureImpl>
    implements _$$NotFoundFailureImplCopyWith<$Res> {
  __$$NotFoundFailureImplCopyWithImpl(
    _$NotFoundFailureImpl _value,
    $Res Function(_$NotFoundFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? resourceId = null,
    Object? resourceType = freezed,
  }) {
    return _then(
      _$NotFoundFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        resourceId: null == resourceId
            ? _value.resourceId
            : resourceId // ignore: cast_nullable_to_non_nullable
                  as String,
        resourceType: freezed == resourceType
            ? _value.resourceType
            : resourceType // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$NotFoundFailureImpl extends NotFoundFailure {
  const _$NotFoundFailureImpl({
    required this.message,
    required this.resourceId,
    this.resourceType,
  }) : super._();

  @override
  final String message;
  @override
  final String resourceId;
  @override
  final String? resourceType;

  @override
  String toString() {
    return 'Failure.notFound(message: $message, resourceId: $resourceId, resourceType: $resourceType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotFoundFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.resourceId, resourceId) ||
                other.resourceId == resourceId) &&
            (identical(other.resourceType, resourceType) ||
                other.resourceType == resourceType));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, message, resourceId, resourceType);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotFoundFailureImplCopyWith<_$NotFoundFailureImpl> get copyWith =>
      __$$NotFoundFailureImplCopyWithImpl<_$NotFoundFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode, String? code)
    network,
    required TResult Function(String message, String? query, String? stackTrace)
    database,
    required TResult Function(String message, Map<String, List<String>> errors)
    validation,
    required TResult Function(
      String message,
      String resourceId,
      String? resourceType,
    )
    notFound,
    required TResult Function(String message, String? requiredPermission)
    permission,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )
    business,
    required TResult Function(String message, String? path, String? operation)
    storage,
    required TResult Function(String message, double? confidence, String? stage)
    processing,
    required TResult Function(String message, String? stackTrace) unexpected,
  }) {
    return notFound(message, resourceId, resourceType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode, String? code)? network,
    TResult? Function(String message, String? query, String? stackTrace)?
    database,
    TResult? Function(String message, Map<String, List<String>> errors)?
    validation,
    TResult? Function(String message, String resourceId, String? resourceType)?
    notFound,
    TResult? Function(String message, String? requiredPermission)? permission,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )?
    business,
    TResult? Function(String message, String? path, String? operation)? storage,
    TResult? Function(String message, double? confidence, String? stage)?
    processing,
    TResult? Function(String message, String? stackTrace)? unexpected,
  }) {
    return notFound?.call(message, resourceId, resourceType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode, String? code)? network,
    TResult Function(String message, String? query, String? stackTrace)?
    database,
    TResult Function(String message, Map<String, List<String>> errors)?
    validation,
    TResult Function(String message, String resourceId, String? resourceType)?
    notFound,
    TResult Function(String message, String? requiredPermission)? permission,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )?
    business,
    TResult Function(String message, String? path, String? operation)? storage,
    TResult Function(String message, double? confidence, String? stage)?
    processing,
    TResult Function(String message, String? stackTrace)? unexpected,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(message, resourceId, resourceType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(DatabaseFailure value) database,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(BusinessFailure value) business,
    required TResult Function(StorageFailure value) storage,
    required TResult Function(ProcessingFailure value) processing,
    required TResult Function(UnexpectedFailure value) unexpected,
  }) {
    return notFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(DatabaseFailure value)? database,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(BusinessFailure value)? business,
    TResult? Function(StorageFailure value)? storage,
    TResult? Function(ProcessingFailure value)? processing,
    TResult? Function(UnexpectedFailure value)? unexpected,
  }) {
    return notFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(DatabaseFailure value)? database,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(BusinessFailure value)? business,
    TResult Function(StorageFailure value)? storage,
    TResult Function(ProcessingFailure value)? processing,
    TResult Function(UnexpectedFailure value)? unexpected,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(this);
    }
    return orElse();
  }
}

abstract class NotFoundFailure extends Failure {
  const factory NotFoundFailure({
    required final String message,
    required final String resourceId,
    final String? resourceType,
  }) = _$NotFoundFailureImpl;
  const NotFoundFailure._() : super._();

  @override
  String get message;
  String get resourceId;
  String? get resourceType;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotFoundFailureImplCopyWith<_$NotFoundFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PermissionFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$PermissionFailureImplCopyWith(
    _$PermissionFailureImpl value,
    $Res Function(_$PermissionFailureImpl) then,
  ) = __$$PermissionFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? requiredPermission});
}

/// @nodoc
class __$$PermissionFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$PermissionFailureImpl>
    implements _$$PermissionFailureImplCopyWith<$Res> {
  __$$PermissionFailureImplCopyWithImpl(
    _$PermissionFailureImpl _value,
    $Res Function(_$PermissionFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? requiredPermission = freezed}) {
    return _then(
      _$PermissionFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        requiredPermission: freezed == requiredPermission
            ? _value.requiredPermission
            : requiredPermission // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$PermissionFailureImpl extends PermissionFailure {
  const _$PermissionFailureImpl({
    required this.message,
    this.requiredPermission,
  }) : super._();

  @override
  final String message;
  @override
  final String? requiredPermission;

  @override
  String toString() {
    return 'Failure.permission(message: $message, requiredPermission: $requiredPermission)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PermissionFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.requiredPermission, requiredPermission) ||
                other.requiredPermission == requiredPermission));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, requiredPermission);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PermissionFailureImplCopyWith<_$PermissionFailureImpl> get copyWith =>
      __$$PermissionFailureImplCopyWithImpl<_$PermissionFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode, String? code)
    network,
    required TResult Function(String message, String? query, String? stackTrace)
    database,
    required TResult Function(String message, Map<String, List<String>> errors)
    validation,
    required TResult Function(
      String message,
      String resourceId,
      String? resourceType,
    )
    notFound,
    required TResult Function(String message, String? requiredPermission)
    permission,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )
    business,
    required TResult Function(String message, String? path, String? operation)
    storage,
    required TResult Function(String message, double? confidence, String? stage)
    processing,
    required TResult Function(String message, String? stackTrace) unexpected,
  }) {
    return permission(message, requiredPermission);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode, String? code)? network,
    TResult? Function(String message, String? query, String? stackTrace)?
    database,
    TResult? Function(String message, Map<String, List<String>> errors)?
    validation,
    TResult? Function(String message, String resourceId, String? resourceType)?
    notFound,
    TResult? Function(String message, String? requiredPermission)? permission,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )?
    business,
    TResult? Function(String message, String? path, String? operation)? storage,
    TResult? Function(String message, double? confidence, String? stage)?
    processing,
    TResult? Function(String message, String? stackTrace)? unexpected,
  }) {
    return permission?.call(message, requiredPermission);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode, String? code)? network,
    TResult Function(String message, String? query, String? stackTrace)?
    database,
    TResult Function(String message, Map<String, List<String>> errors)?
    validation,
    TResult Function(String message, String resourceId, String? resourceType)?
    notFound,
    TResult Function(String message, String? requiredPermission)? permission,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )?
    business,
    TResult Function(String message, String? path, String? operation)? storage,
    TResult Function(String message, double? confidence, String? stage)?
    processing,
    TResult Function(String message, String? stackTrace)? unexpected,
    required TResult orElse(),
  }) {
    if (permission != null) {
      return permission(message, requiredPermission);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(DatabaseFailure value) database,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(BusinessFailure value) business,
    required TResult Function(StorageFailure value) storage,
    required TResult Function(ProcessingFailure value) processing,
    required TResult Function(UnexpectedFailure value) unexpected,
  }) {
    return permission(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(DatabaseFailure value)? database,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(BusinessFailure value)? business,
    TResult? Function(StorageFailure value)? storage,
    TResult? Function(ProcessingFailure value)? processing,
    TResult? Function(UnexpectedFailure value)? unexpected,
  }) {
    return permission?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(DatabaseFailure value)? database,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(BusinessFailure value)? business,
    TResult Function(StorageFailure value)? storage,
    TResult Function(ProcessingFailure value)? processing,
    TResult Function(UnexpectedFailure value)? unexpected,
    required TResult orElse(),
  }) {
    if (permission != null) {
      return permission(this);
    }
    return orElse();
  }
}

abstract class PermissionFailure extends Failure {
  const factory PermissionFailure({
    required final String message,
    final String? requiredPermission,
  }) = _$PermissionFailureImpl;
  const PermissionFailure._() : super._();

  @override
  String get message;
  String? get requiredPermission;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PermissionFailureImplCopyWith<_$PermissionFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BusinessFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$BusinessFailureImplCopyWith(
    _$BusinessFailureImpl value,
    $Res Function(_$BusinessFailureImpl) then,
  ) = __$$BusinessFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? code, Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$BusinessFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$BusinessFailureImpl>
    implements _$$BusinessFailureImplCopyWith<$Res> {
  __$$BusinessFailureImplCopyWithImpl(
    _$BusinessFailureImpl _value,
    $Res Function(_$BusinessFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? code = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$BusinessFailureImpl(
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
      ),
    );
  }
}

/// @nodoc

class _$BusinessFailureImpl extends BusinessFailure {
  const _$BusinessFailureImpl({
    required this.message,
    this.code,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata,
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
    return 'Failure.business(message: $message, code: $code, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusinessFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    code,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BusinessFailureImplCopyWith<_$BusinessFailureImpl> get copyWith =>
      __$$BusinessFailureImplCopyWithImpl<_$BusinessFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode, String? code)
    network,
    required TResult Function(String message, String? query, String? stackTrace)
    database,
    required TResult Function(String message, Map<String, List<String>> errors)
    validation,
    required TResult Function(
      String message,
      String resourceId,
      String? resourceType,
    )
    notFound,
    required TResult Function(String message, String? requiredPermission)
    permission,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )
    business,
    required TResult Function(String message, String? path, String? operation)
    storage,
    required TResult Function(String message, double? confidence, String? stage)
    processing,
    required TResult Function(String message, String? stackTrace) unexpected,
  }) {
    return business(message, code, metadata);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode, String? code)? network,
    TResult? Function(String message, String? query, String? stackTrace)?
    database,
    TResult? Function(String message, Map<String, List<String>> errors)?
    validation,
    TResult? Function(String message, String resourceId, String? resourceType)?
    notFound,
    TResult? Function(String message, String? requiredPermission)? permission,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )?
    business,
    TResult? Function(String message, String? path, String? operation)? storage,
    TResult? Function(String message, double? confidence, String? stage)?
    processing,
    TResult? Function(String message, String? stackTrace)? unexpected,
  }) {
    return business?.call(message, code, metadata);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode, String? code)? network,
    TResult Function(String message, String? query, String? stackTrace)?
    database,
    TResult Function(String message, Map<String, List<String>> errors)?
    validation,
    TResult Function(String message, String resourceId, String? resourceType)?
    notFound,
    TResult Function(String message, String? requiredPermission)? permission,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )?
    business,
    TResult Function(String message, String? path, String? operation)? storage,
    TResult Function(String message, double? confidence, String? stage)?
    processing,
    TResult Function(String message, String? stackTrace)? unexpected,
    required TResult orElse(),
  }) {
    if (business != null) {
      return business(message, code, metadata);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(DatabaseFailure value) database,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(BusinessFailure value) business,
    required TResult Function(StorageFailure value) storage,
    required TResult Function(ProcessingFailure value) processing,
    required TResult Function(UnexpectedFailure value) unexpected,
  }) {
    return business(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(DatabaseFailure value)? database,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(BusinessFailure value)? business,
    TResult? Function(StorageFailure value)? storage,
    TResult? Function(ProcessingFailure value)? processing,
    TResult? Function(UnexpectedFailure value)? unexpected,
  }) {
    return business?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(DatabaseFailure value)? database,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(BusinessFailure value)? business,
    TResult Function(StorageFailure value)? storage,
    TResult Function(ProcessingFailure value)? processing,
    TResult Function(UnexpectedFailure value)? unexpected,
    required TResult orElse(),
  }) {
    if (business != null) {
      return business(this);
    }
    return orElse();
  }
}

abstract class BusinessFailure extends Failure {
  const factory BusinessFailure({
    required final String message,
    final String? code,
    final Map<String, dynamic>? metadata,
  }) = _$BusinessFailureImpl;
  const BusinessFailure._() : super._();

  @override
  String get message;
  String? get code;
  Map<String, dynamic>? get metadata;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BusinessFailureImplCopyWith<_$BusinessFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$StorageFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$StorageFailureImplCopyWith(
    _$StorageFailureImpl value,
    $Res Function(_$StorageFailureImpl) then,
  ) = __$$StorageFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? path, String? operation});
}

/// @nodoc
class __$$StorageFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$StorageFailureImpl>
    implements _$$StorageFailureImplCopyWith<$Res> {
  __$$StorageFailureImplCopyWithImpl(
    _$StorageFailureImpl _value,
    $Res Function(_$StorageFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? path = freezed,
    Object? operation = freezed,
  }) {
    return _then(
      _$StorageFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        path: freezed == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String?,
        operation: freezed == operation
            ? _value.operation
            : operation // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$StorageFailureImpl extends StorageFailure {
  const _$StorageFailureImpl({required this.message, this.path, this.operation})
    : super._();

  @override
  final String message;
  @override
  final String? path;
  @override
  final String? operation;

  @override
  String toString() {
    return 'Failure.storage(message: $message, path: $path, operation: $operation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StorageFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.operation, operation) ||
                other.operation == operation));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, path, operation);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StorageFailureImplCopyWith<_$StorageFailureImpl> get copyWith =>
      __$$StorageFailureImplCopyWithImpl<_$StorageFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode, String? code)
    network,
    required TResult Function(String message, String? query, String? stackTrace)
    database,
    required TResult Function(String message, Map<String, List<String>> errors)
    validation,
    required TResult Function(
      String message,
      String resourceId,
      String? resourceType,
    )
    notFound,
    required TResult Function(String message, String? requiredPermission)
    permission,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )
    business,
    required TResult Function(String message, String? path, String? operation)
    storage,
    required TResult Function(String message, double? confidence, String? stage)
    processing,
    required TResult Function(String message, String? stackTrace) unexpected,
  }) {
    return storage(message, path, operation);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode, String? code)? network,
    TResult? Function(String message, String? query, String? stackTrace)?
    database,
    TResult? Function(String message, Map<String, List<String>> errors)?
    validation,
    TResult? Function(String message, String resourceId, String? resourceType)?
    notFound,
    TResult? Function(String message, String? requiredPermission)? permission,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )?
    business,
    TResult? Function(String message, String? path, String? operation)? storage,
    TResult? Function(String message, double? confidence, String? stage)?
    processing,
    TResult? Function(String message, String? stackTrace)? unexpected,
  }) {
    return storage?.call(message, path, operation);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode, String? code)? network,
    TResult Function(String message, String? query, String? stackTrace)?
    database,
    TResult Function(String message, Map<String, List<String>> errors)?
    validation,
    TResult Function(String message, String resourceId, String? resourceType)?
    notFound,
    TResult Function(String message, String? requiredPermission)? permission,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )?
    business,
    TResult Function(String message, String? path, String? operation)? storage,
    TResult Function(String message, double? confidence, String? stage)?
    processing,
    TResult Function(String message, String? stackTrace)? unexpected,
    required TResult orElse(),
  }) {
    if (storage != null) {
      return storage(message, path, operation);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(DatabaseFailure value) database,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(BusinessFailure value) business,
    required TResult Function(StorageFailure value) storage,
    required TResult Function(ProcessingFailure value) processing,
    required TResult Function(UnexpectedFailure value) unexpected,
  }) {
    return storage(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(DatabaseFailure value)? database,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(BusinessFailure value)? business,
    TResult? Function(StorageFailure value)? storage,
    TResult? Function(ProcessingFailure value)? processing,
    TResult? Function(UnexpectedFailure value)? unexpected,
  }) {
    return storage?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(DatabaseFailure value)? database,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(BusinessFailure value)? business,
    TResult Function(StorageFailure value)? storage,
    TResult Function(ProcessingFailure value)? processing,
    TResult Function(UnexpectedFailure value)? unexpected,
    required TResult orElse(),
  }) {
    if (storage != null) {
      return storage(this);
    }
    return orElse();
  }
}

abstract class StorageFailure extends Failure {
  const factory StorageFailure({
    required final String message,
    final String? path,
    final String? operation,
  }) = _$StorageFailureImpl;
  const StorageFailure._() : super._();

  @override
  String get message;
  String? get path;
  String? get operation;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StorageFailureImplCopyWith<_$StorageFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ProcessingFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$ProcessingFailureImplCopyWith(
    _$ProcessingFailureImpl value,
    $Res Function(_$ProcessingFailureImpl) then,
  ) = __$$ProcessingFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, double? confidence, String? stage});
}

/// @nodoc
class __$$ProcessingFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$ProcessingFailureImpl>
    implements _$$ProcessingFailureImplCopyWith<$Res> {
  __$$ProcessingFailureImplCopyWithImpl(
    _$ProcessingFailureImpl _value,
    $Res Function(_$ProcessingFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? confidence = freezed,
    Object? stage = freezed,
  }) {
    return _then(
      _$ProcessingFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        confidence: freezed == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double?,
        stage: freezed == stage
            ? _value.stage
            : stage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ProcessingFailureImpl extends ProcessingFailure {
  const _$ProcessingFailureImpl({
    required this.message,
    this.confidence,
    this.stage,
  }) : super._();

  @override
  final String message;
  @override
  final double? confidence;
  @override
  final String? stage;

  @override
  String toString() {
    return 'Failure.processing(message: $message, confidence: $confidence, stage: $stage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProcessingFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.stage, stage) || other.stage == stage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, confidence, stage);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProcessingFailureImplCopyWith<_$ProcessingFailureImpl> get copyWith =>
      __$$ProcessingFailureImplCopyWithImpl<_$ProcessingFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode, String? code)
    network,
    required TResult Function(String message, String? query, String? stackTrace)
    database,
    required TResult Function(String message, Map<String, List<String>> errors)
    validation,
    required TResult Function(
      String message,
      String resourceId,
      String? resourceType,
    )
    notFound,
    required TResult Function(String message, String? requiredPermission)
    permission,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )
    business,
    required TResult Function(String message, String? path, String? operation)
    storage,
    required TResult Function(String message, double? confidence, String? stage)
    processing,
    required TResult Function(String message, String? stackTrace) unexpected,
  }) {
    return processing(message, confidence, stage);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode, String? code)? network,
    TResult? Function(String message, String? query, String? stackTrace)?
    database,
    TResult? Function(String message, Map<String, List<String>> errors)?
    validation,
    TResult? Function(String message, String resourceId, String? resourceType)?
    notFound,
    TResult? Function(String message, String? requiredPermission)? permission,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )?
    business,
    TResult? Function(String message, String? path, String? operation)? storage,
    TResult? Function(String message, double? confidence, String? stage)?
    processing,
    TResult? Function(String message, String? stackTrace)? unexpected,
  }) {
    return processing?.call(message, confidence, stage);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode, String? code)? network,
    TResult Function(String message, String? query, String? stackTrace)?
    database,
    TResult Function(String message, Map<String, List<String>> errors)?
    validation,
    TResult Function(String message, String resourceId, String? resourceType)?
    notFound,
    TResult Function(String message, String? requiredPermission)? permission,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )?
    business,
    TResult Function(String message, String? path, String? operation)? storage,
    TResult Function(String message, double? confidence, String? stage)?
    processing,
    TResult Function(String message, String? stackTrace)? unexpected,
    required TResult orElse(),
  }) {
    if (processing != null) {
      return processing(message, confidence, stage);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(DatabaseFailure value) database,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(BusinessFailure value) business,
    required TResult Function(StorageFailure value) storage,
    required TResult Function(ProcessingFailure value) processing,
    required TResult Function(UnexpectedFailure value) unexpected,
  }) {
    return processing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(DatabaseFailure value)? database,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(BusinessFailure value)? business,
    TResult? Function(StorageFailure value)? storage,
    TResult? Function(ProcessingFailure value)? processing,
    TResult? Function(UnexpectedFailure value)? unexpected,
  }) {
    return processing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(DatabaseFailure value)? database,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(BusinessFailure value)? business,
    TResult Function(StorageFailure value)? storage,
    TResult Function(ProcessingFailure value)? processing,
    TResult Function(UnexpectedFailure value)? unexpected,
    required TResult orElse(),
  }) {
    if (processing != null) {
      return processing(this);
    }
    return orElse();
  }
}

abstract class ProcessingFailure extends Failure {
  const factory ProcessingFailure({
    required final String message,
    final double? confidence,
    final String? stage,
  }) = _$ProcessingFailureImpl;
  const ProcessingFailure._() : super._();

  @override
  String get message;
  double? get confidence;
  String? get stage;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProcessingFailureImplCopyWith<_$ProcessingFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnexpectedFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$UnexpectedFailureImplCopyWith(
    _$UnexpectedFailureImpl value,
    $Res Function(_$UnexpectedFailureImpl) then,
  ) = __$$UnexpectedFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? stackTrace});
}

/// @nodoc
class __$$UnexpectedFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$UnexpectedFailureImpl>
    implements _$$UnexpectedFailureImplCopyWith<$Res> {
  __$$UnexpectedFailureImplCopyWithImpl(
    _$UnexpectedFailureImpl _value,
    $Res Function(_$UnexpectedFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? stackTrace = freezed}) {
    return _then(
      _$UnexpectedFailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        stackTrace: freezed == stackTrace
            ? _value.stackTrace
            : stackTrace // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$UnexpectedFailureImpl extends UnexpectedFailure {
  const _$UnexpectedFailureImpl({required this.message, this.stackTrace})
    : super._();

  @override
  final String message;
  @override
  final String? stackTrace;

  @override
  String toString() {
    return 'Failure.unexpected(message: $message, stackTrace: $stackTrace)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnexpectedFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, stackTrace);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnexpectedFailureImplCopyWith<_$UnexpectedFailureImpl> get copyWith =>
      __$$UnexpectedFailureImplCopyWithImpl<_$UnexpectedFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode, String? code)
    network,
    required TResult Function(String message, String? query, String? stackTrace)
    database,
    required TResult Function(String message, Map<String, List<String>> errors)
    validation,
    required TResult Function(
      String message,
      String resourceId,
      String? resourceType,
    )
    notFound,
    required TResult Function(String message, String? requiredPermission)
    permission,
    required TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )
    business,
    required TResult Function(String message, String? path, String? operation)
    storage,
    required TResult Function(String message, double? confidence, String? stage)
    processing,
    required TResult Function(String message, String? stackTrace) unexpected,
  }) {
    return unexpected(message, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode, String? code)? network,
    TResult? Function(String message, String? query, String? stackTrace)?
    database,
    TResult? Function(String message, Map<String, List<String>> errors)?
    validation,
    TResult? Function(String message, String resourceId, String? resourceType)?
    notFound,
    TResult? Function(String message, String? requiredPermission)? permission,
    TResult? Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )?
    business,
    TResult? Function(String message, String? path, String? operation)? storage,
    TResult? Function(String message, double? confidence, String? stage)?
    processing,
    TResult? Function(String message, String? stackTrace)? unexpected,
  }) {
    return unexpected?.call(message, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode, String? code)? network,
    TResult Function(String message, String? query, String? stackTrace)?
    database,
    TResult Function(String message, Map<String, List<String>> errors)?
    validation,
    TResult Function(String message, String resourceId, String? resourceType)?
    notFound,
    TResult Function(String message, String? requiredPermission)? permission,
    TResult Function(
      String message,
      String? code,
      Map<String, dynamic>? metadata,
    )?
    business,
    TResult Function(String message, String? path, String? operation)? storage,
    TResult Function(String message, double? confidence, String? stage)?
    processing,
    TResult Function(String message, String? stackTrace)? unexpected,
    required TResult orElse(),
  }) {
    if (unexpected != null) {
      return unexpected(message, stackTrace);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(DatabaseFailure value) database,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(NotFoundFailure value) notFound,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(BusinessFailure value) business,
    required TResult Function(StorageFailure value) storage,
    required TResult Function(ProcessingFailure value) processing,
    required TResult Function(UnexpectedFailure value) unexpected,
  }) {
    return unexpected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(DatabaseFailure value)? database,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(NotFoundFailure value)? notFound,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(BusinessFailure value)? business,
    TResult? Function(StorageFailure value)? storage,
    TResult? Function(ProcessingFailure value)? processing,
    TResult? Function(UnexpectedFailure value)? unexpected,
  }) {
    return unexpected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(DatabaseFailure value)? database,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(NotFoundFailure value)? notFound,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(BusinessFailure value)? business,
    TResult Function(StorageFailure value)? storage,
    TResult Function(ProcessingFailure value)? processing,
    TResult Function(UnexpectedFailure value)? unexpected,
    required TResult orElse(),
  }) {
    if (unexpected != null) {
      return unexpected(this);
    }
    return orElse();
  }
}

abstract class UnexpectedFailure extends Failure {
  const factory UnexpectedFailure({
    required final String message,
    final String? stackTrace,
  }) = _$UnexpectedFailureImpl;
  const UnexpectedFailure._() : super._();

  @override
  String get message;
  String? get stackTrace;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnexpectedFailureImplCopyWith<_$UnexpectedFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
