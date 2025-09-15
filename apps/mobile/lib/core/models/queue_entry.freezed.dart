// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'queue_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

QueueEntry _$QueueEntryFromJson(Map<String, dynamic> json) {
  return _QueueEntry.fromJson(json);
}

/// @nodoc
mixin _$QueueEntry {
  String get id => throw _privateConstructorUsedError;
  String get endpoint => throw _privateConstructorUsedError;
  String get method =>
      throw _privateConstructorUsedError; // GET, POST, PUT, DELETE
  Map<String, dynamic> get headers => throw _privateConstructorUsedError;
  Map<String, dynamic>? get body => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get lastAttemptAt => throw _privateConstructorUsedError;
  int get retryCount => throw _privateConstructorUsedError;
  int get maxRetries => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  QueueEntryStatus get status =>
      throw _privateConstructorUsedError; // Optional metadata for tracking
  String? get feature =>
      throw _privateConstructorUsedError; // e.g., "quickbooks_validation", "xero_export"
  String? get userId => throw _privateConstructorUsedError;

  /// Serializes this QueueEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QueueEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QueueEntryCopyWith<QueueEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QueueEntryCopyWith<$Res> {
  factory $QueueEntryCopyWith(
    QueueEntry value,
    $Res Function(QueueEntry) then,
  ) = _$QueueEntryCopyWithImpl<$Res, QueueEntry>;
  @useResult
  $Res call({
    String id,
    String endpoint,
    String method,
    Map<String, dynamic> headers,
    Map<String, dynamic>? body,
    DateTime createdAt,
    DateTime? lastAttemptAt,
    int retryCount,
    int maxRetries,
    String? errorMessage,
    QueueEntryStatus status,
    String? feature,
    String? userId,
  });
}

/// @nodoc
class _$QueueEntryCopyWithImpl<$Res, $Val extends QueueEntry>
    implements $QueueEntryCopyWith<$Res> {
  _$QueueEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QueueEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? endpoint = null,
    Object? method = null,
    Object? headers = null,
    Object? body = freezed,
    Object? createdAt = null,
    Object? lastAttemptAt = freezed,
    Object? retryCount = null,
    Object? maxRetries = null,
    Object? errorMessage = freezed,
    Object? status = null,
    Object? feature = freezed,
    Object? userId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            endpoint: null == endpoint
                ? _value.endpoint
                : endpoint // ignore: cast_nullable_to_non_nullable
                      as String,
            method: null == method
                ? _value.method
                : method // ignore: cast_nullable_to_non_nullable
                      as String,
            headers: null == headers
                ? _value.headers
                : headers // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            body: freezed == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastAttemptAt: freezed == lastAttemptAt
                ? _value.lastAttemptAt
                : lastAttemptAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            retryCount: null == retryCount
                ? _value.retryCount
                : retryCount // ignore: cast_nullable_to_non_nullable
                      as int,
            maxRetries: null == maxRetries
                ? _value.maxRetries
                : maxRetries // ignore: cast_nullable_to_non_nullable
                      as int,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as QueueEntryStatus,
            feature: freezed == feature
                ? _value.feature
                : feature // ignore: cast_nullable_to_non_nullable
                      as String?,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QueueEntryImplCopyWith<$Res>
    implements $QueueEntryCopyWith<$Res> {
  factory _$$QueueEntryImplCopyWith(
    _$QueueEntryImpl value,
    $Res Function(_$QueueEntryImpl) then,
  ) = __$$QueueEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String endpoint,
    String method,
    Map<String, dynamic> headers,
    Map<String, dynamic>? body,
    DateTime createdAt,
    DateTime? lastAttemptAt,
    int retryCount,
    int maxRetries,
    String? errorMessage,
    QueueEntryStatus status,
    String? feature,
    String? userId,
  });
}

/// @nodoc
class __$$QueueEntryImplCopyWithImpl<$Res>
    extends _$QueueEntryCopyWithImpl<$Res, _$QueueEntryImpl>
    implements _$$QueueEntryImplCopyWith<$Res> {
  __$$QueueEntryImplCopyWithImpl(
    _$QueueEntryImpl _value,
    $Res Function(_$QueueEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QueueEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? endpoint = null,
    Object? method = null,
    Object? headers = null,
    Object? body = freezed,
    Object? createdAt = null,
    Object? lastAttemptAt = freezed,
    Object? retryCount = null,
    Object? maxRetries = null,
    Object? errorMessage = freezed,
    Object? status = null,
    Object? feature = freezed,
    Object? userId = freezed,
  }) {
    return _then(
      _$QueueEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        endpoint: null == endpoint
            ? _value.endpoint
            : endpoint // ignore: cast_nullable_to_non_nullable
                  as String,
        method: null == method
            ? _value.method
            : method // ignore: cast_nullable_to_non_nullable
                  as String,
        headers: null == headers
            ? _value._headers
            : headers // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        body: freezed == body
            ? _value._body
            : body // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastAttemptAt: freezed == lastAttemptAt
            ? _value.lastAttemptAt
            : lastAttemptAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        retryCount: null == retryCount
            ? _value.retryCount
            : retryCount // ignore: cast_nullable_to_non_nullable
                  as int,
        maxRetries: null == maxRetries
            ? _value.maxRetries
            : maxRetries // ignore: cast_nullable_to_non_nullable
                  as int,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as QueueEntryStatus,
        feature: freezed == feature
            ? _value.feature
            : feature // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QueueEntryImpl implements _QueueEntry {
  const _$QueueEntryImpl({
    required this.id,
    required this.endpoint,
    required this.method,
    required final Map<String, dynamic> headers,
    final Map<String, dynamic>? body,
    required this.createdAt,
    this.lastAttemptAt,
    required this.retryCount,
    required this.maxRetries,
    this.errorMessage,
    required this.status,
    this.feature,
    this.userId,
  }) : _headers = headers,
       _body = body;

  factory _$QueueEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$QueueEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String endpoint;
  @override
  final String method;
  // GET, POST, PUT, DELETE
  final Map<String, dynamic> _headers;
  // GET, POST, PUT, DELETE
  @override
  Map<String, dynamic> get headers {
    if (_headers is EqualUnmodifiableMapView) return _headers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_headers);
  }

  final Map<String, dynamic>? _body;
  @override
  Map<String, dynamic>? get body {
    final value = _body;
    if (value == null) return null;
    if (_body is EqualUnmodifiableMapView) return _body;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime? lastAttemptAt;
  @override
  final int retryCount;
  @override
  final int maxRetries;
  @override
  final String? errorMessage;
  @override
  final QueueEntryStatus status;
  // Optional metadata for tracking
  @override
  final String? feature;
  // e.g., "quickbooks_validation", "xero_export"
  @override
  final String? userId;

  @override
  String toString() {
    return 'QueueEntry(id: $id, endpoint: $endpoint, method: $method, headers: $headers, body: $body, createdAt: $createdAt, lastAttemptAt: $lastAttemptAt, retryCount: $retryCount, maxRetries: $maxRetries, errorMessage: $errorMessage, status: $status, feature: $feature, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QueueEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.endpoint, endpoint) ||
                other.endpoint == endpoint) &&
            (identical(other.method, method) || other.method == method) &&
            const DeepCollectionEquality().equals(other._headers, _headers) &&
            const DeepCollectionEquality().equals(other._body, _body) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastAttemptAt, lastAttemptAt) ||
                other.lastAttemptAt == lastAttemptAt) &&
            (identical(other.retryCount, retryCount) ||
                other.retryCount == retryCount) &&
            (identical(other.maxRetries, maxRetries) ||
                other.maxRetries == maxRetries) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.feature, feature) || other.feature == feature) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    endpoint,
    method,
    const DeepCollectionEquality().hash(_headers),
    const DeepCollectionEquality().hash(_body),
    createdAt,
    lastAttemptAt,
    retryCount,
    maxRetries,
    errorMessage,
    status,
    feature,
    userId,
  );

  /// Create a copy of QueueEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QueueEntryImplCopyWith<_$QueueEntryImpl> get copyWith =>
      __$$QueueEntryImplCopyWithImpl<_$QueueEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QueueEntryImplToJson(this);
  }
}

abstract class _QueueEntry implements QueueEntry {
  const factory _QueueEntry({
    required final String id,
    required final String endpoint,
    required final String method,
    required final Map<String, dynamic> headers,
    final Map<String, dynamic>? body,
    required final DateTime createdAt,
    final DateTime? lastAttemptAt,
    required final int retryCount,
    required final int maxRetries,
    final String? errorMessage,
    required final QueueEntryStatus status,
    final String? feature,
    final String? userId,
  }) = _$QueueEntryImpl;

  factory _QueueEntry.fromJson(Map<String, dynamic> json) =
      _$QueueEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get endpoint;
  @override
  String get method; // GET, POST, PUT, DELETE
  @override
  Map<String, dynamic> get headers;
  @override
  Map<String, dynamic>? get body;
  @override
  DateTime get createdAt;
  @override
  DateTime? get lastAttemptAt;
  @override
  int get retryCount;
  @override
  int get maxRetries;
  @override
  String? get errorMessage;
  @override
  QueueEntryStatus get status; // Optional metadata for tracking
  @override
  String? get feature; // e.g., "quickbooks_validation", "xero_export"
  @override
  String? get userId;

  /// Create a copy of QueueEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QueueEntryImplCopyWith<_$QueueEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
