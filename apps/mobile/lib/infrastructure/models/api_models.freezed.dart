// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CreateReceiptResponse _$CreateReceiptResponseFromJson(
  Map<String, dynamic> json,
) {
  return _CreateReceiptResponse.fromJson(json);
}

/// @nodoc
mixin _$CreateReceiptResponse {
  String get jobId => throw _privateConstructorUsedError;
  bool get deduped => throw _privateConstructorUsedError;

  /// Serializes this CreateReceiptResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateReceiptResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateReceiptResponseCopyWith<CreateReceiptResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateReceiptResponseCopyWith<$Res> {
  factory $CreateReceiptResponseCopyWith(
    CreateReceiptResponse value,
    $Res Function(CreateReceiptResponse) then,
  ) = _$CreateReceiptResponseCopyWithImpl<$Res, CreateReceiptResponse>;
  @useResult
  $Res call({String jobId, bool deduped});
}

/// @nodoc
class _$CreateReceiptResponseCopyWithImpl<
  $Res,
  $Val extends CreateReceiptResponse
>
    implements $CreateReceiptResponseCopyWith<$Res> {
  _$CreateReceiptResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateReceiptResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? jobId = null, Object? deduped = null}) {
    return _then(
      _value.copyWith(
            jobId: null == jobId
                ? _value.jobId
                : jobId // ignore: cast_nullable_to_non_nullable
                      as String,
            deduped: null == deduped
                ? _value.deduped
                : deduped // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateReceiptResponseImplCopyWith<$Res>
    implements $CreateReceiptResponseCopyWith<$Res> {
  factory _$$CreateReceiptResponseImplCopyWith(
    _$CreateReceiptResponseImpl value,
    $Res Function(_$CreateReceiptResponseImpl) then,
  ) = __$$CreateReceiptResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String jobId, bool deduped});
}

/// @nodoc
class __$$CreateReceiptResponseImplCopyWithImpl<$Res>
    extends
        _$CreateReceiptResponseCopyWithImpl<$Res, _$CreateReceiptResponseImpl>
    implements _$$CreateReceiptResponseImplCopyWith<$Res> {
  __$$CreateReceiptResponseImplCopyWithImpl(
    _$CreateReceiptResponseImpl _value,
    $Res Function(_$CreateReceiptResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateReceiptResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? jobId = null, Object? deduped = null}) {
    return _then(
      _$CreateReceiptResponseImpl(
        jobId: null == jobId
            ? _value.jobId
            : jobId // ignore: cast_nullable_to_non_nullable
                  as String,
        deduped: null == deduped
            ? _value.deduped
            : deduped // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateReceiptResponseImpl implements _CreateReceiptResponse {
  const _$CreateReceiptResponseImpl({
    required this.jobId,
    required this.deduped,
  });

  factory _$CreateReceiptResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateReceiptResponseImplFromJson(json);

  @override
  final String jobId;
  @override
  final bool deduped;

  @override
  String toString() {
    return 'CreateReceiptResponse(jobId: $jobId, deduped: $deduped)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateReceiptResponseImpl &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.deduped, deduped) || other.deduped == deduped));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, jobId, deduped);

  /// Create a copy of CreateReceiptResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateReceiptResponseImplCopyWith<_$CreateReceiptResponseImpl>
  get copyWith =>
      __$$CreateReceiptResponseImplCopyWithImpl<_$CreateReceiptResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateReceiptResponseImplToJson(this);
  }
}

abstract class _CreateReceiptResponse implements CreateReceiptResponse {
  const factory _CreateReceiptResponse({
    required final String jobId,
    required final bool deduped,
  }) = _$CreateReceiptResponseImpl;

  factory _CreateReceiptResponse.fromJson(Map<String, dynamic> json) =
      _$CreateReceiptResponseImpl.fromJson;

  @override
  String get jobId;
  @override
  bool get deduped;

  /// Create a copy of CreateReceiptResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateReceiptResponseImplCopyWith<_$CreateReceiptResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ReceiptUploadByUrl _$ReceiptUploadByUrlFromJson(Map<String, dynamic> json) {
  return _ReceiptUploadByUrl.fromJson(json);
}

/// @nodoc
mixin _$ReceiptUploadByUrl {
  String get source => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this ReceiptUploadByUrl to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReceiptUploadByUrl
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReceiptUploadByUrlCopyWith<ReceiptUploadByUrl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReceiptUploadByUrlCopyWith<$Res> {
  factory $ReceiptUploadByUrlCopyWith(
    ReceiptUploadByUrl value,
    $Res Function(ReceiptUploadByUrl) then,
  ) = _$ReceiptUploadByUrlCopyWithImpl<$Res, ReceiptUploadByUrl>;
  @useResult
  $Res call({String source, String url, Map<String, dynamic>? metadata});
}

/// @nodoc
class _$ReceiptUploadByUrlCopyWithImpl<$Res, $Val extends ReceiptUploadByUrl>
    implements $ReceiptUploadByUrlCopyWith<$Res> {
  _$ReceiptUploadByUrlCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReceiptUploadByUrl
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? url = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReceiptUploadByUrlImplCopyWith<$Res>
    implements $ReceiptUploadByUrlCopyWith<$Res> {
  factory _$$ReceiptUploadByUrlImplCopyWith(
    _$ReceiptUploadByUrlImpl value,
    $Res Function(_$ReceiptUploadByUrlImpl) then,
  ) = __$$ReceiptUploadByUrlImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String source, String url, Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$ReceiptUploadByUrlImplCopyWithImpl<$Res>
    extends _$ReceiptUploadByUrlCopyWithImpl<$Res, _$ReceiptUploadByUrlImpl>
    implements _$$ReceiptUploadByUrlImplCopyWith<$Res> {
  __$$ReceiptUploadByUrlImplCopyWithImpl(
    _$ReceiptUploadByUrlImpl _value,
    $Res Function(_$ReceiptUploadByUrlImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReceiptUploadByUrl
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? url = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _$ReceiptUploadByUrlImpl(
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReceiptUploadByUrlImpl implements _ReceiptUploadByUrl {
  const _$ReceiptUploadByUrlImpl({
    this.source = 'url',
    required this.url,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$ReceiptUploadByUrlImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReceiptUploadByUrlImplFromJson(json);

  @override
  @JsonKey()
  final String source;
  @override
  final String url;
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
    return 'ReceiptUploadByUrl(source: $source, url: $url, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceiptUploadByUrlImpl &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.url, url) || other.url == url) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    source,
    url,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of ReceiptUploadByUrl
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReceiptUploadByUrlImplCopyWith<_$ReceiptUploadByUrlImpl> get copyWith =>
      __$$ReceiptUploadByUrlImplCopyWithImpl<_$ReceiptUploadByUrlImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReceiptUploadByUrlImplToJson(this);
  }
}

abstract class _ReceiptUploadByUrl implements ReceiptUploadByUrl {
  const factory _ReceiptUploadByUrl({
    final String source,
    required final String url,
    final Map<String, dynamic>? metadata,
  }) = _$ReceiptUploadByUrlImpl;

  factory _ReceiptUploadByUrl.fromJson(Map<String, dynamic> json) =
      _$ReceiptUploadByUrlImpl.fromJson;

  @override
  String get source;
  @override
  String get url;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of ReceiptUploadByUrl
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReceiptUploadByUrlImplCopyWith<_$ReceiptUploadByUrlImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReceiptUploadByBase64 _$ReceiptUploadByBase64FromJson(
  Map<String, dynamic> json,
) {
  return _ReceiptUploadByBase64.fromJson(json);
}

/// @nodoc
mixin _$ReceiptUploadByBase64 {
  String get source => throw _privateConstructorUsedError;
  String get contentType => throw _privateConstructorUsedError;
  String get data => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this ReceiptUploadByBase64 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReceiptUploadByBase64
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReceiptUploadByBase64CopyWith<ReceiptUploadByBase64> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReceiptUploadByBase64CopyWith<$Res> {
  factory $ReceiptUploadByBase64CopyWith(
    ReceiptUploadByBase64 value,
    $Res Function(ReceiptUploadByBase64) then,
  ) = _$ReceiptUploadByBase64CopyWithImpl<$Res, ReceiptUploadByBase64>;
  @useResult
  $Res call({
    String source,
    String contentType,
    String data,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$ReceiptUploadByBase64CopyWithImpl<
  $Res,
  $Val extends ReceiptUploadByBase64
>
    implements $ReceiptUploadByBase64CopyWith<$Res> {
  _$ReceiptUploadByBase64CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReceiptUploadByBase64
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? contentType = null,
    Object? data = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
            contentType: null == contentType
                ? _value.contentType
                : contentType // ignore: cast_nullable_to_non_nullable
                      as String,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as String,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReceiptUploadByBase64ImplCopyWith<$Res>
    implements $ReceiptUploadByBase64CopyWith<$Res> {
  factory _$$ReceiptUploadByBase64ImplCopyWith(
    _$ReceiptUploadByBase64Impl value,
    $Res Function(_$ReceiptUploadByBase64Impl) then,
  ) = __$$ReceiptUploadByBase64ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String source,
    String contentType,
    String data,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$ReceiptUploadByBase64ImplCopyWithImpl<$Res>
    extends
        _$ReceiptUploadByBase64CopyWithImpl<$Res, _$ReceiptUploadByBase64Impl>
    implements _$$ReceiptUploadByBase64ImplCopyWith<$Res> {
  __$$ReceiptUploadByBase64ImplCopyWithImpl(
    _$ReceiptUploadByBase64Impl _value,
    $Res Function(_$ReceiptUploadByBase64Impl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReceiptUploadByBase64
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? contentType = null,
    Object? data = null,
    Object? metadata = freezed,
  }) {
    return _then(
      _$ReceiptUploadByBase64Impl(
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
        contentType: null == contentType
            ? _value.contentType
            : contentType // ignore: cast_nullable_to_non_nullable
                  as String,
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as String,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReceiptUploadByBase64Impl implements _ReceiptUploadByBase64 {
  const _$ReceiptUploadByBase64Impl({
    this.source = 'base64',
    required this.contentType,
    required this.data,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$ReceiptUploadByBase64Impl.fromJson(Map<String, dynamic> json) =>
      _$$ReceiptUploadByBase64ImplFromJson(json);

  @override
  @JsonKey()
  final String source;
  @override
  final String contentType;
  @override
  final String data;
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
    return 'ReceiptUploadByBase64(source: $source, contentType: $contentType, data: $data, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceiptUploadByBase64Impl &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.data, data) || other.data == data) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    source,
    contentType,
    data,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of ReceiptUploadByBase64
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReceiptUploadByBase64ImplCopyWith<_$ReceiptUploadByBase64Impl>
  get copyWith =>
      __$$ReceiptUploadByBase64ImplCopyWithImpl<_$ReceiptUploadByBase64Impl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReceiptUploadByBase64ImplToJson(this);
  }
}

abstract class _ReceiptUploadByBase64 implements ReceiptUploadByBase64 {
  const factory _ReceiptUploadByBase64({
    final String source,
    required final String contentType,
    required final String data,
    final Map<String, dynamic>? metadata,
  }) = _$ReceiptUploadByBase64Impl;

  factory _ReceiptUploadByBase64.fromJson(Map<String, dynamic> json) =
      _$ReceiptUploadByBase64Impl.fromJson;

  @override
  String get source;
  @override
  String get contentType;
  @override
  String get data;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of ReceiptUploadByBase64
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReceiptUploadByBase64ImplCopyWith<_$ReceiptUploadByBase64Impl>
  get copyWith => throw _privateConstructorUsedError;
}

ProblemDetails _$ProblemDetailsFromJson(Map<String, dynamic> json) {
  return _ProblemDetails.fromJson(json);
}

/// @nodoc
mixin _$ProblemDetails {
  String get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  int? get status => throw _privateConstructorUsedError;
  String? get detail => throw _privateConstructorUsedError;
  String? get instance => throw _privateConstructorUsedError;
  Map<String, dynamic>? get extensions => throw _privateConstructorUsedError;

  /// Serializes this ProblemDetails to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProblemDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProblemDetailsCopyWith<ProblemDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProblemDetailsCopyWith<$Res> {
  factory $ProblemDetailsCopyWith(
    ProblemDetails value,
    $Res Function(ProblemDetails) then,
  ) = _$ProblemDetailsCopyWithImpl<$Res, ProblemDetails>;
  @useResult
  $Res call({
    String type,
    String title,
    int? status,
    String? detail,
    String? instance,
    Map<String, dynamic>? extensions,
  });
}

/// @nodoc
class _$ProblemDetailsCopyWithImpl<$Res, $Val extends ProblemDetails>
    implements $ProblemDetailsCopyWith<$Res> {
  _$ProblemDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProblemDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? title = null,
    Object? status = freezed,
    Object? detail = freezed,
    Object? instance = freezed,
    Object? extensions = freezed,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as int?,
            detail: freezed == detail
                ? _value.detail
                : detail // ignore: cast_nullable_to_non_nullable
                      as String?,
            instance: freezed == instance
                ? _value.instance
                : instance // ignore: cast_nullable_to_non_nullable
                      as String?,
            extensions: freezed == extensions
                ? _value.extensions
                : extensions // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProblemDetailsImplCopyWith<$Res>
    implements $ProblemDetailsCopyWith<$Res> {
  factory _$$ProblemDetailsImplCopyWith(
    _$ProblemDetailsImpl value,
    $Res Function(_$ProblemDetailsImpl) then,
  ) = __$$ProblemDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String type,
    String title,
    int? status,
    String? detail,
    String? instance,
    Map<String, dynamic>? extensions,
  });
}

/// @nodoc
class __$$ProblemDetailsImplCopyWithImpl<$Res>
    extends _$ProblemDetailsCopyWithImpl<$Res, _$ProblemDetailsImpl>
    implements _$$ProblemDetailsImplCopyWith<$Res> {
  __$$ProblemDetailsImplCopyWithImpl(
    _$ProblemDetailsImpl _value,
    $Res Function(_$ProblemDetailsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProblemDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? title = null,
    Object? status = freezed,
    Object? detail = freezed,
    Object? instance = freezed,
    Object? extensions = freezed,
  }) {
    return _then(
      _$ProblemDetailsImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as int?,
        detail: freezed == detail
            ? _value.detail
            : detail // ignore: cast_nullable_to_non_nullable
                  as String?,
        instance: freezed == instance
            ? _value.instance
            : instance // ignore: cast_nullable_to_non_nullable
                  as String?,
        extensions: freezed == extensions
            ? _value._extensions
            : extensions // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProblemDetailsImpl implements _ProblemDetails {
  const _$ProblemDetailsImpl({
    required this.type,
    required this.title,
    this.status,
    this.detail,
    this.instance,
    final Map<String, dynamic>? extensions,
  }) : _extensions = extensions;

  factory _$ProblemDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProblemDetailsImplFromJson(json);

  @override
  final String type;
  @override
  final String title;
  @override
  final int? status;
  @override
  final String? detail;
  @override
  final String? instance;
  final Map<String, dynamic>? _extensions;
  @override
  Map<String, dynamic>? get extensions {
    final value = _extensions;
    if (value == null) return null;
    if (_extensions is EqualUnmodifiableMapView) return _extensions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ProblemDetails(type: $type, title: $title, status: $status, detail: $detail, instance: $instance, extensions: $extensions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProblemDetailsImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.detail, detail) || other.detail == detail) &&
            (identical(other.instance, instance) ||
                other.instance == instance) &&
            const DeepCollectionEquality().equals(
              other._extensions,
              _extensions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    title,
    status,
    detail,
    instance,
    const DeepCollectionEquality().hash(_extensions),
  );

  /// Create a copy of ProblemDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProblemDetailsImplCopyWith<_$ProblemDetailsImpl> get copyWith =>
      __$$ProblemDetailsImplCopyWithImpl<_$ProblemDetailsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProblemDetailsImplToJson(this);
  }
}

abstract class _ProblemDetails implements ProblemDetails {
  const factory _ProblemDetails({
    required final String type,
    required final String title,
    final int? status,
    final String? detail,
    final String? instance,
    final Map<String, dynamic>? extensions,
  }) = _$ProblemDetailsImpl;

  factory _ProblemDetails.fromJson(Map<String, dynamic> json) =
      _$ProblemDetailsImpl.fromJson;

  @override
  String get type;
  @override
  String get title;
  @override
  int? get status;
  @override
  String? get detail;
  @override
  String? get instance;
  @override
  Map<String, dynamic>? get extensions;

  /// Create a copy of ProblemDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProblemDetailsImplCopyWith<_$ProblemDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

JobStatus _$JobStatusFromJson(Map<String, dynamic> json) {
  return _JobStatus.fromJson(json);
}

/// @nodoc
mixin _$JobStatus {
  String get jobId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  Map<String, dynamic>? get result => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this JobStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JobStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobStatusCopyWith<JobStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobStatusCopyWith<$Res> {
  factory $JobStatusCopyWith(JobStatus value, $Res Function(JobStatus) then) =
      _$JobStatusCopyWithImpl<$Res, JobStatus>;
  @useResult
  $Res call({
    String jobId,
    String status,
    String? message,
    Map<String, dynamic>? result,
    DateTime? createdAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class _$JobStatusCopyWithImpl<$Res, $Val extends JobStatus>
    implements $JobStatusCopyWith<$Res> {
  _$JobStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? status = null,
    Object? message = freezed,
    Object? result = freezed,
    Object? createdAt = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            jobId: null == jobId
                ? _value.jobId
                : jobId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
            result: freezed == result
                ? _value.result
                : result // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JobStatusImplCopyWith<$Res>
    implements $JobStatusCopyWith<$Res> {
  factory _$$JobStatusImplCopyWith(
    _$JobStatusImpl value,
    $Res Function(_$JobStatusImpl) then,
  ) = __$$JobStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String jobId,
    String status,
    String? message,
    Map<String, dynamic>? result,
    DateTime? createdAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class __$$JobStatusImplCopyWithImpl<$Res>
    extends _$JobStatusCopyWithImpl<$Res, _$JobStatusImpl>
    implements _$$JobStatusImplCopyWith<$Res> {
  __$$JobStatusImplCopyWithImpl(
    _$JobStatusImpl _value,
    $Res Function(_$JobStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JobStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? status = null,
    Object? message = freezed,
    Object? result = freezed,
    Object? createdAt = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(
      _$JobStatusImpl(
        jobId: null == jobId
            ? _value.jobId
            : jobId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        result: freezed == result
            ? _value._result
            : result // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$JobStatusImpl implements _JobStatus {
  const _$JobStatusImpl({
    required this.jobId,
    required this.status,
    this.message,
    final Map<String, dynamic>? result,
    this.createdAt,
    this.completedAt,
  }) : _result = result;

  factory _$JobStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$JobStatusImplFromJson(json);

  @override
  final String jobId;
  @override
  final String status;
  @override
  final String? message;
  final Map<String, dynamic>? _result;
  @override
  Map<String, dynamic>? get result {
    final value = _result;
    if (value == null) return null;
    if (_result is EqualUnmodifiableMapView) return _result;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? createdAt;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'JobStatus(jobId: $jobId, status: $status, message: $message, result: $result, createdAt: $createdAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobStatusImpl &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._result, _result) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    jobId,
    status,
    message,
    const DeepCollectionEquality().hash(_result),
    createdAt,
    completedAt,
  );

  /// Create a copy of JobStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobStatusImplCopyWith<_$JobStatusImpl> get copyWith =>
      __$$JobStatusImplCopyWithImpl<_$JobStatusImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JobStatusImplToJson(this);
  }
}

abstract class _JobStatus implements JobStatus {
  const factory _JobStatus({
    required final String jobId,
    required final String status,
    final String? message,
    final Map<String, dynamic>? result,
    final DateTime? createdAt,
    final DateTime? completedAt,
  }) = _$JobStatusImpl;

  factory _JobStatus.fromJson(Map<String, dynamic> json) =
      _$JobStatusImpl.fromJson;

  @override
  String get jobId;
  @override
  String get status;
  @override
  String? get message;
  @override
  Map<String, dynamic>? get result;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get completedAt;

  /// Create a copy of JobStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobStatusImplCopyWith<_$JobStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
