// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receipt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Receipt _$ReceiptFromJson(Map<String, dynamic> json) {
  return _Receipt.fromJson(json);
}

/// @nodoc
mixin _$Receipt {
  String get id => throw _privateConstructorUsedError;
  String? get merchantName => throw _privateConstructorUsedError;
  DateTime? get date => throw _privateConstructorUsedError;
  double? get totalAmount => throw _privateConstructorUsedError;
  double? get taxAmount =>
      throw _privateConstructorUsedError; // OCR processing results
  ProcessingResult? get ocrResults =>
      throw _privateConstructorUsedError; // Metadata
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get imagePath => throw _privateConstructorUsedError;
  String? get thumbnailPath =>
      throw _privateConstructorUsedError; // Export tracking
  DateTime? get lastExportedAt => throw _privateConstructorUsedError;
  String? get lastExportFormat => throw _privateConstructorUsedError;

  /// Serializes this Receipt to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReceiptCopyWith<Receipt> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReceiptCopyWith<$Res> {
  factory $ReceiptCopyWith(Receipt value, $Res Function(Receipt) then) =
      _$ReceiptCopyWithImpl<$Res, Receipt>;
  @useResult
  $Res call({
    String id,
    String? merchantName,
    DateTime? date,
    double? totalAmount,
    double? taxAmount,
    ProcessingResult? ocrResults,
    DateTime createdAt,
    DateTime? updatedAt,
    String? imagePath,
    String? thumbnailPath,
    DateTime? lastExportedAt,
    String? lastExportFormat,
  });

  $ProcessingResultCopyWith<$Res>? get ocrResults;
}

/// @nodoc
class _$ReceiptCopyWithImpl<$Res, $Val extends Receipt>
    implements $ReceiptCopyWith<$Res> {
  _$ReceiptCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? merchantName = freezed,
    Object? date = freezed,
    Object? totalAmount = freezed,
    Object? taxAmount = freezed,
    Object? ocrResults = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? imagePath = freezed,
    Object? thumbnailPath = freezed,
    Object? lastExportedAt = freezed,
    Object? lastExportFormat = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            merchantName: freezed == merchantName
                ? _value.merchantName
                : merchantName // ignore: cast_nullable_to_non_nullable
                      as String?,
            date: freezed == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            totalAmount: freezed == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
            taxAmount: freezed == taxAmount
                ? _value.taxAmount
                : taxAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
            ocrResults: freezed == ocrResults
                ? _value.ocrResults
                : ocrResults // ignore: cast_nullable_to_non_nullable
                      as ProcessingResult?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            imagePath: freezed == imagePath
                ? _value.imagePath
                : imagePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            thumbnailPath: freezed == thumbnailPath
                ? _value.thumbnailPath
                : thumbnailPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastExportedAt: freezed == lastExportedAt
                ? _value.lastExportedAt
                : lastExportedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastExportFormat: freezed == lastExportFormat
                ? _value.lastExportFormat
                : lastExportFormat // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProcessingResultCopyWith<$Res>? get ocrResults {
    if (_value.ocrResults == null) {
      return null;
    }

    return $ProcessingResultCopyWith<$Res>(_value.ocrResults!, (value) {
      return _then(_value.copyWith(ocrResults: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReceiptImplCopyWith<$Res> implements $ReceiptCopyWith<$Res> {
  factory _$$ReceiptImplCopyWith(
    _$ReceiptImpl value,
    $Res Function(_$ReceiptImpl) then,
  ) = __$$ReceiptImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? merchantName,
    DateTime? date,
    double? totalAmount,
    double? taxAmount,
    ProcessingResult? ocrResults,
    DateTime createdAt,
    DateTime? updatedAt,
    String? imagePath,
    String? thumbnailPath,
    DateTime? lastExportedAt,
    String? lastExportFormat,
  });

  @override
  $ProcessingResultCopyWith<$Res>? get ocrResults;
}

/// @nodoc
class __$$ReceiptImplCopyWithImpl<$Res>
    extends _$ReceiptCopyWithImpl<$Res, _$ReceiptImpl>
    implements _$$ReceiptImplCopyWith<$Res> {
  __$$ReceiptImplCopyWithImpl(
    _$ReceiptImpl _value,
    $Res Function(_$ReceiptImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? merchantName = freezed,
    Object? date = freezed,
    Object? totalAmount = freezed,
    Object? taxAmount = freezed,
    Object? ocrResults = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? imagePath = freezed,
    Object? thumbnailPath = freezed,
    Object? lastExportedAt = freezed,
    Object? lastExportFormat = freezed,
  }) {
    return _then(
      _$ReceiptImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        merchantName: freezed == merchantName
            ? _value.merchantName
            : merchantName // ignore: cast_nullable_to_non_nullable
                  as String?,
        date: freezed == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        totalAmount: freezed == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
        taxAmount: freezed == taxAmount
            ? _value.taxAmount
            : taxAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
        ocrResults: freezed == ocrResults
            ? _value.ocrResults
            : ocrResults // ignore: cast_nullable_to_non_nullable
                  as ProcessingResult?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        imagePath: freezed == imagePath
            ? _value.imagePath
            : imagePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        thumbnailPath: freezed == thumbnailPath
            ? _value.thumbnailPath
            : thumbnailPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastExportedAt: freezed == lastExportedAt
            ? _value.lastExportedAt
            : lastExportedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastExportFormat: freezed == lastExportFormat
            ? _value.lastExportFormat
            : lastExportFormat // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReceiptImpl implements _Receipt {
  const _$ReceiptImpl({
    required this.id,
    this.merchantName,
    this.date,
    this.totalAmount,
    this.taxAmount,
    this.ocrResults,
    required this.createdAt,
    this.updatedAt,
    this.imagePath,
    this.thumbnailPath,
    this.lastExportedAt,
    this.lastExportFormat,
  });

  factory _$ReceiptImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReceiptImplFromJson(json);

  @override
  final String id;
  @override
  final String? merchantName;
  @override
  final DateTime? date;
  @override
  final double? totalAmount;
  @override
  final double? taxAmount;
  // OCR processing results
  @override
  final ProcessingResult? ocrResults;
  // Metadata
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? imagePath;
  @override
  final String? thumbnailPath;
  // Export tracking
  @override
  final DateTime? lastExportedAt;
  @override
  final String? lastExportFormat;

  @override
  String toString() {
    return 'Receipt(id: $id, merchantName: $merchantName, date: $date, totalAmount: $totalAmount, taxAmount: $taxAmount, ocrResults: $ocrResults, createdAt: $createdAt, updatedAt: $updatedAt, imagePath: $imagePath, thumbnailPath: $thumbnailPath, lastExportedAt: $lastExportedAt, lastExportFormat: $lastExportFormat)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceiptImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.merchantName, merchantName) ||
                other.merchantName == merchantName) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.taxAmount, taxAmount) ||
                other.taxAmount == taxAmount) &&
            (identical(other.ocrResults, ocrResults) ||
                other.ocrResults == ocrResults) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.thumbnailPath, thumbnailPath) ||
                other.thumbnailPath == thumbnailPath) &&
            (identical(other.lastExportedAt, lastExportedAt) ||
                other.lastExportedAt == lastExportedAt) &&
            (identical(other.lastExportFormat, lastExportFormat) ||
                other.lastExportFormat == lastExportFormat));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    merchantName,
    date,
    totalAmount,
    taxAmount,
    ocrResults,
    createdAt,
    updatedAt,
    imagePath,
    thumbnailPath,
    lastExportedAt,
    lastExportFormat,
  );

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReceiptImplCopyWith<_$ReceiptImpl> get copyWith =>
      __$$ReceiptImplCopyWithImpl<_$ReceiptImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReceiptImplToJson(this);
  }
}

abstract class _Receipt implements Receipt {
  const factory _Receipt({
    required final String id,
    final String? merchantName,
    final DateTime? date,
    final double? totalAmount,
    final double? taxAmount,
    final ProcessingResult? ocrResults,
    required final DateTime createdAt,
    final DateTime? updatedAt,
    final String? imagePath,
    final String? thumbnailPath,
    final DateTime? lastExportedAt,
    final String? lastExportFormat,
  }) = _$ReceiptImpl;

  factory _Receipt.fromJson(Map<String, dynamic> json) = _$ReceiptImpl.fromJson;

  @override
  String get id;
  @override
  String? get merchantName;
  @override
  DateTime? get date;
  @override
  double? get totalAmount;
  @override
  double? get taxAmount; // OCR processing results
  @override
  ProcessingResult? get ocrResults; // Metadata
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  String? get imagePath;
  @override
  String? get thumbnailPath; // Export tracking
  @override
  DateTime? get lastExportedAt;
  @override
  String? get lastExportFormat;

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReceiptImplCopyWith<_$ReceiptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProcessingResult _$ProcessingResultFromJson(Map<String, dynamic> json) {
  return _ProcessingResult.fromJson(json);
}

/// @nodoc
mixin _$ProcessingResult {
  StringFieldData get merchantName => throw _privateConstructorUsedError;
  DoubleFieldData get totalAmount => throw _privateConstructorUsedError;
  DateFieldData get date => throw _privateConstructorUsedError;
  DoubleFieldData get taxAmount => throw _privateConstructorUsedError;
  String get processingEngine => throw _privateConstructorUsedError;
  DateTime get processedAt => throw _privateConstructorUsedError;
  double? get overallConfidence => throw _privateConstructorUsedError;

  /// Serializes this ProcessingResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProcessingResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProcessingResultCopyWith<ProcessingResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProcessingResultCopyWith<$Res> {
  factory $ProcessingResultCopyWith(
    ProcessingResult value,
    $Res Function(ProcessingResult) then,
  ) = _$ProcessingResultCopyWithImpl<$Res, ProcessingResult>;
  @useResult
  $Res call({
    StringFieldData merchantName,
    DoubleFieldData totalAmount,
    DateFieldData date,
    DoubleFieldData taxAmount,
    String processingEngine,
    DateTime processedAt,
    double? overallConfidence,
  });

  $StringFieldDataCopyWith<$Res> get merchantName;
  $DoubleFieldDataCopyWith<$Res> get totalAmount;
  $DateFieldDataCopyWith<$Res> get date;
  $DoubleFieldDataCopyWith<$Res> get taxAmount;
}

/// @nodoc
class _$ProcessingResultCopyWithImpl<$Res, $Val extends ProcessingResult>
    implements $ProcessingResultCopyWith<$Res> {
  _$ProcessingResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProcessingResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? merchantName = null,
    Object? totalAmount = null,
    Object? date = null,
    Object? taxAmount = null,
    Object? processingEngine = null,
    Object? processedAt = null,
    Object? overallConfidence = freezed,
  }) {
    return _then(
      _value.copyWith(
            merchantName: null == merchantName
                ? _value.merchantName
                : merchantName // ignore: cast_nullable_to_non_nullable
                      as StringFieldData,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as DoubleFieldData,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateFieldData,
            taxAmount: null == taxAmount
                ? _value.taxAmount
                : taxAmount // ignore: cast_nullable_to_non_nullable
                      as DoubleFieldData,
            processingEngine: null == processingEngine
                ? _value.processingEngine
                : processingEngine // ignore: cast_nullable_to_non_nullable
                      as String,
            processedAt: null == processedAt
                ? _value.processedAt
                : processedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            overallConfidence: freezed == overallConfidence
                ? _value.overallConfidence
                : overallConfidence // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }

  /// Create a copy of ProcessingResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StringFieldDataCopyWith<$Res> get merchantName {
    return $StringFieldDataCopyWith<$Res>(_value.merchantName, (value) {
      return _then(_value.copyWith(merchantName: value) as $Val);
    });
  }

  /// Create a copy of ProcessingResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DoubleFieldDataCopyWith<$Res> get totalAmount {
    return $DoubleFieldDataCopyWith<$Res>(_value.totalAmount, (value) {
      return _then(_value.copyWith(totalAmount: value) as $Val);
    });
  }

  /// Create a copy of ProcessingResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DateFieldDataCopyWith<$Res> get date {
    return $DateFieldDataCopyWith<$Res>(_value.date, (value) {
      return _then(_value.copyWith(date: value) as $Val);
    });
  }

  /// Create a copy of ProcessingResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DoubleFieldDataCopyWith<$Res> get taxAmount {
    return $DoubleFieldDataCopyWith<$Res>(_value.taxAmount, (value) {
      return _then(_value.copyWith(taxAmount: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProcessingResultImplCopyWith<$Res>
    implements $ProcessingResultCopyWith<$Res> {
  factory _$$ProcessingResultImplCopyWith(
    _$ProcessingResultImpl value,
    $Res Function(_$ProcessingResultImpl) then,
  ) = __$$ProcessingResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    StringFieldData merchantName,
    DoubleFieldData totalAmount,
    DateFieldData date,
    DoubleFieldData taxAmount,
    String processingEngine,
    DateTime processedAt,
    double? overallConfidence,
  });

  @override
  $StringFieldDataCopyWith<$Res> get merchantName;
  @override
  $DoubleFieldDataCopyWith<$Res> get totalAmount;
  @override
  $DateFieldDataCopyWith<$Res> get date;
  @override
  $DoubleFieldDataCopyWith<$Res> get taxAmount;
}

/// @nodoc
class __$$ProcessingResultImplCopyWithImpl<$Res>
    extends _$ProcessingResultCopyWithImpl<$Res, _$ProcessingResultImpl>
    implements _$$ProcessingResultImplCopyWith<$Res> {
  __$$ProcessingResultImplCopyWithImpl(
    _$ProcessingResultImpl _value,
    $Res Function(_$ProcessingResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProcessingResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? merchantName = null,
    Object? totalAmount = null,
    Object? date = null,
    Object? taxAmount = null,
    Object? processingEngine = null,
    Object? processedAt = null,
    Object? overallConfidence = freezed,
  }) {
    return _then(
      _$ProcessingResultImpl(
        merchantName: null == merchantName
            ? _value.merchantName
            : merchantName // ignore: cast_nullable_to_non_nullable
                  as StringFieldData,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as DoubleFieldData,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateFieldData,
        taxAmount: null == taxAmount
            ? _value.taxAmount
            : taxAmount // ignore: cast_nullable_to_non_nullable
                  as DoubleFieldData,
        processingEngine: null == processingEngine
            ? _value.processingEngine
            : processingEngine // ignore: cast_nullable_to_non_nullable
                  as String,
        processedAt: null == processedAt
            ? _value.processedAt
            : processedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        overallConfidence: freezed == overallConfidence
            ? _value.overallConfidence
            : overallConfidence // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProcessingResultImpl implements _ProcessingResult {
  const _$ProcessingResultImpl({
    required this.merchantName,
    required this.totalAmount,
    required this.date,
    required this.taxAmount,
    required this.processingEngine,
    required this.processedAt,
    this.overallConfidence,
  });

  factory _$ProcessingResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProcessingResultImplFromJson(json);

  @override
  final StringFieldData merchantName;
  @override
  final DoubleFieldData totalAmount;
  @override
  final DateFieldData date;
  @override
  final DoubleFieldData taxAmount;
  @override
  final String processingEngine;
  @override
  final DateTime processedAt;
  @override
  final double? overallConfidence;

  @override
  String toString() {
    return 'ProcessingResult(merchantName: $merchantName, totalAmount: $totalAmount, date: $date, taxAmount: $taxAmount, processingEngine: $processingEngine, processedAt: $processedAt, overallConfidence: $overallConfidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProcessingResultImpl &&
            (identical(other.merchantName, merchantName) ||
                other.merchantName == merchantName) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.taxAmount, taxAmount) ||
                other.taxAmount == taxAmount) &&
            (identical(other.processingEngine, processingEngine) ||
                other.processingEngine == processingEngine) &&
            (identical(other.processedAt, processedAt) ||
                other.processedAt == processedAt) &&
            (identical(other.overallConfidence, overallConfidence) ||
                other.overallConfidence == overallConfidence));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    merchantName,
    totalAmount,
    date,
    taxAmount,
    processingEngine,
    processedAt,
    overallConfidence,
  );

  /// Create a copy of ProcessingResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProcessingResultImplCopyWith<_$ProcessingResultImpl> get copyWith =>
      __$$ProcessingResultImplCopyWithImpl<_$ProcessingResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProcessingResultImplToJson(this);
  }
}

abstract class _ProcessingResult implements ProcessingResult {
  const factory _ProcessingResult({
    required final StringFieldData merchantName,
    required final DoubleFieldData totalAmount,
    required final DateFieldData date,
    required final DoubleFieldData taxAmount,
    required final String processingEngine,
    required final DateTime processedAt,
    final double? overallConfidence,
  }) = _$ProcessingResultImpl;

  factory _ProcessingResult.fromJson(Map<String, dynamic> json) =
      _$ProcessingResultImpl.fromJson;

  @override
  StringFieldData get merchantName;
  @override
  DoubleFieldData get totalAmount;
  @override
  DateFieldData get date;
  @override
  DoubleFieldData get taxAmount;
  @override
  String get processingEngine;
  @override
  DateTime get processedAt;
  @override
  double? get overallConfidence;

  /// Create a copy of ProcessingResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProcessingResultImplCopyWith<_$ProcessingResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StringFieldData _$StringFieldDataFromJson(Map<String, dynamic> json) {
  return _StringFieldData.fromJson(json);
}

/// @nodoc
mixin _$StringFieldData {
  String get value => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  String? get rawText => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this StringFieldData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StringFieldData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StringFieldDataCopyWith<StringFieldData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StringFieldDataCopyWith<$Res> {
  factory $StringFieldDataCopyWith(
    StringFieldData value,
    $Res Function(StringFieldData) then,
  ) = _$StringFieldDataCopyWithImpl<$Res, StringFieldData>;
  @useResult
  $Res call({
    String value,
    double confidence,
    String? rawText,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$StringFieldDataCopyWithImpl<$Res, $Val extends StringFieldData>
    implements $StringFieldDataCopyWith<$Res> {
  _$StringFieldDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StringFieldData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? confidence = null,
    Object? rawText = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as String,
            confidence: null == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as double,
            rawText: freezed == rawText
                ? _value.rawText
                : rawText // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$StringFieldDataImplCopyWith<$Res>
    implements $StringFieldDataCopyWith<$Res> {
  factory _$$StringFieldDataImplCopyWith(
    _$StringFieldDataImpl value,
    $Res Function(_$StringFieldDataImpl) then,
  ) = __$$StringFieldDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String value,
    double confidence,
    String? rawText,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$StringFieldDataImplCopyWithImpl<$Res>
    extends _$StringFieldDataCopyWithImpl<$Res, _$StringFieldDataImpl>
    implements _$$StringFieldDataImplCopyWith<$Res> {
  __$$StringFieldDataImplCopyWithImpl(
    _$StringFieldDataImpl _value,
    $Res Function(_$StringFieldDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StringFieldData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? confidence = null,
    Object? rawText = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$StringFieldDataImpl(
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as String,
        confidence: null == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double,
        rawText: freezed == rawText
            ? _value.rawText
            : rawText // ignore: cast_nullable_to_non_nullable
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
@JsonSerializable()
class _$StringFieldDataImpl implements _StringFieldData {
  const _$StringFieldDataImpl({
    required this.value,
    required this.confidence,
    this.rawText,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$StringFieldDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$StringFieldDataImplFromJson(json);

  @override
  final String value;
  @override
  final double confidence;
  @override
  final String? rawText;
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
    return 'StringFieldData(value: $value, confidence: $confidence, rawText: $rawText, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StringFieldDataImpl &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.rawText, rawText) || other.rawText == rawText) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    value,
    confidence,
    rawText,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of StringFieldData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StringFieldDataImplCopyWith<_$StringFieldDataImpl> get copyWith =>
      __$$StringFieldDataImplCopyWithImpl<_$StringFieldDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StringFieldDataImplToJson(this);
  }
}

abstract class _StringFieldData implements StringFieldData {
  const factory _StringFieldData({
    required final String value,
    required final double confidence,
    final String? rawText,
    final Map<String, dynamic>? metadata,
  }) = _$StringFieldDataImpl;

  factory _StringFieldData.fromJson(Map<String, dynamic> json) =
      _$StringFieldDataImpl.fromJson;

  @override
  String get value;
  @override
  double get confidence;
  @override
  String? get rawText;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of StringFieldData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StringFieldDataImplCopyWith<_$StringFieldDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DoubleFieldData _$DoubleFieldDataFromJson(Map<String, dynamic> json) {
  return _DoubleFieldData.fromJson(json);
}

/// @nodoc
mixin _$DoubleFieldData {
  double get value => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  String? get rawText => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this DoubleFieldData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DoubleFieldData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DoubleFieldDataCopyWith<DoubleFieldData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DoubleFieldDataCopyWith<$Res> {
  factory $DoubleFieldDataCopyWith(
    DoubleFieldData value,
    $Res Function(DoubleFieldData) then,
  ) = _$DoubleFieldDataCopyWithImpl<$Res, DoubleFieldData>;
  @useResult
  $Res call({
    double value,
    double confidence,
    String? rawText,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$DoubleFieldDataCopyWithImpl<$Res, $Val extends DoubleFieldData>
    implements $DoubleFieldDataCopyWith<$Res> {
  _$DoubleFieldDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DoubleFieldData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? confidence = null,
    Object? rawText = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as double,
            confidence: null == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as double,
            rawText: freezed == rawText
                ? _value.rawText
                : rawText // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$DoubleFieldDataImplCopyWith<$Res>
    implements $DoubleFieldDataCopyWith<$Res> {
  factory _$$DoubleFieldDataImplCopyWith(
    _$DoubleFieldDataImpl value,
    $Res Function(_$DoubleFieldDataImpl) then,
  ) = __$$DoubleFieldDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double value,
    double confidence,
    String? rawText,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$DoubleFieldDataImplCopyWithImpl<$Res>
    extends _$DoubleFieldDataCopyWithImpl<$Res, _$DoubleFieldDataImpl>
    implements _$$DoubleFieldDataImplCopyWith<$Res> {
  __$$DoubleFieldDataImplCopyWithImpl(
    _$DoubleFieldDataImpl _value,
    $Res Function(_$DoubleFieldDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DoubleFieldData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? confidence = null,
    Object? rawText = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$DoubleFieldDataImpl(
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as double,
        confidence: null == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double,
        rawText: freezed == rawText
            ? _value.rawText
            : rawText // ignore: cast_nullable_to_non_nullable
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
@JsonSerializable()
class _$DoubleFieldDataImpl implements _DoubleFieldData {
  const _$DoubleFieldDataImpl({
    required this.value,
    required this.confidence,
    this.rawText,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$DoubleFieldDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DoubleFieldDataImplFromJson(json);

  @override
  final double value;
  @override
  final double confidence;
  @override
  final String? rawText;
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
    return 'DoubleFieldData(value: $value, confidence: $confidence, rawText: $rawText, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DoubleFieldDataImpl &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.rawText, rawText) || other.rawText == rawText) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    value,
    confidence,
    rawText,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of DoubleFieldData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DoubleFieldDataImplCopyWith<_$DoubleFieldDataImpl> get copyWith =>
      __$$DoubleFieldDataImplCopyWithImpl<_$DoubleFieldDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DoubleFieldDataImplToJson(this);
  }
}

abstract class _DoubleFieldData implements DoubleFieldData {
  const factory _DoubleFieldData({
    required final double value,
    required final double confidence,
    final String? rawText,
    final Map<String, dynamic>? metadata,
  }) = _$DoubleFieldDataImpl;

  factory _DoubleFieldData.fromJson(Map<String, dynamic> json) =
      _$DoubleFieldDataImpl.fromJson;

  @override
  double get value;
  @override
  double get confidence;
  @override
  String? get rawText;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of DoubleFieldData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DoubleFieldDataImplCopyWith<_$DoubleFieldDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DateFieldData _$DateFieldDataFromJson(Map<String, dynamic> json) {
  return _DateFieldData.fromJson(json);
}

/// @nodoc
mixin _$DateFieldData {
  DateTime get value => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  String? get rawText => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this DateFieldData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DateFieldData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DateFieldDataCopyWith<DateFieldData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DateFieldDataCopyWith<$Res> {
  factory $DateFieldDataCopyWith(
    DateFieldData value,
    $Res Function(DateFieldData) then,
  ) = _$DateFieldDataCopyWithImpl<$Res, DateFieldData>;
  @useResult
  $Res call({
    DateTime value,
    double confidence,
    String? rawText,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$DateFieldDataCopyWithImpl<$Res, $Val extends DateFieldData>
    implements $DateFieldDataCopyWith<$Res> {
  _$DateFieldDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DateFieldData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? confidence = null,
    Object? rawText = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            confidence: null == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as double,
            rawText: freezed == rawText
                ? _value.rawText
                : rawText // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$DateFieldDataImplCopyWith<$Res>
    implements $DateFieldDataCopyWith<$Res> {
  factory _$$DateFieldDataImplCopyWith(
    _$DateFieldDataImpl value,
    $Res Function(_$DateFieldDataImpl) then,
  ) = __$$DateFieldDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime value,
    double confidence,
    String? rawText,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$DateFieldDataImplCopyWithImpl<$Res>
    extends _$DateFieldDataCopyWithImpl<$Res, _$DateFieldDataImpl>
    implements _$$DateFieldDataImplCopyWith<$Res> {
  __$$DateFieldDataImplCopyWithImpl(
    _$DateFieldDataImpl _value,
    $Res Function(_$DateFieldDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DateFieldData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
    Object? confidence = null,
    Object? rawText = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$DateFieldDataImpl(
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        confidence: null == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double,
        rawText: freezed == rawText
            ? _value.rawText
            : rawText // ignore: cast_nullable_to_non_nullable
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
@JsonSerializable()
class _$DateFieldDataImpl implements _DateFieldData {
  const _$DateFieldDataImpl({
    required this.value,
    required this.confidence,
    this.rawText,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$DateFieldDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DateFieldDataImplFromJson(json);

  @override
  final DateTime value;
  @override
  final double confidence;
  @override
  final String? rawText;
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
    return 'DateFieldData(value: $value, confidence: $confidence, rawText: $rawText, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DateFieldDataImpl &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.rawText, rawText) || other.rawText == rawText) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    value,
    confidence,
    rawText,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of DateFieldData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DateFieldDataImplCopyWith<_$DateFieldDataImpl> get copyWith =>
      __$$DateFieldDataImplCopyWithImpl<_$DateFieldDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DateFieldDataImplToJson(this);
  }
}

abstract class _DateFieldData implements DateFieldData {
  const factory _DateFieldData({
    required final DateTime value,
    required final double confidence,
    final String? rawText,
    final Map<String, dynamic>? metadata,
  }) = _$DateFieldDataImpl;

  factory _DateFieldData.fromJson(Map<String, dynamic> json) =
      _$DateFieldDataImpl.fromJson;

  @override
  DateTime get value;
  @override
  double get confidence;
  @override
  String? get rawText;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of DateFieldData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DateFieldDataImplCopyWith<_$DateFieldDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
