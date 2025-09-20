// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receipt_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReceiptModel _$ReceiptModelFromJson(Map<String, dynamic> json) {
  return _ReceiptModel.fromJson(json);
}

/// @nodoc
mixin _$ReceiptModel {
  /// Unique identifier - always required
  ReceiptId get id => throw _privateConstructorUsedError;

  /// Creation timestamp - always required
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Processing status - always required
  ReceiptStatus get status => throw _privateConstructorUsedError;

  /// Image storage location - always required
  String get imagePath => throw _privateConstructorUsedError;

  /// Last modification timestamp
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // ===== BUSINESS DATA - Nullable when truly unknown =====
  /// Merchant/vendor name from receipt
  String? get merchant => throw _privateConstructorUsedError;

  /// Total amount including tax
  Money? get totalAmount => throw _privateConstructorUsedError;

  /// Tax amount
  Money? get taxAmount => throw _privateConstructorUsedError;

  /// Date on the receipt (not capture date)
  DateTime? get purchaseDate => throw _privateConstructorUsedError;

  /// Business category
  Category? get category => throw _privateConstructorUsedError;

  /// Payment method used
  PaymentMethod? get paymentMethod => throw _privateConstructorUsedError;

  /// User notes
  String? get notes => throw _privateConstructorUsedError;

  /// Business purpose/justification
  String? get businessPurpose => throw _privateConstructorUsedError;

  /// Line items from receipt
  List<ReceiptItem> get items => throw _privateConstructorUsedError;

  /// User-defined tags for organization
  List<String> get tags => throw _privateConstructorUsedError;

  /// Whether this is marked as favorite
  bool get isFavorite => throw _privateConstructorUsedError;

  /// Batch ID if part of batch capture
  String? get batchId => throw _privateConstructorUsedError;

  /// OCR confidence score (0.0 to 1.0)
  double? get ocrConfidence => throw _privateConstructorUsedError;

  /// Raw OCR text for reference
  String? get ocrRawText => throw _privateConstructorUsedError;

  /// Error message if status is error
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Cloud storage URL if synced
  String? get cloudStorageUrl => throw _privateConstructorUsedError;

  /// Whether this needs manual review
  bool get needsReview => throw _privateConstructorUsedError;

  /// Serializes this ReceiptModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReceiptModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReceiptModelCopyWith<ReceiptModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReceiptModelCopyWith<$Res> {
  factory $ReceiptModelCopyWith(
    ReceiptModel value,
    $Res Function(ReceiptModel) then,
  ) = _$ReceiptModelCopyWithImpl<$Res, ReceiptModel>;
  @useResult
  $Res call({
    ReceiptId id,
    DateTime createdAt,
    ReceiptStatus status,
    String imagePath,
    DateTime updatedAt,
    String? merchant,
    Money? totalAmount,
    Money? taxAmount,
    DateTime? purchaseDate,
    Category? category,
    PaymentMethod? paymentMethod,
    String? notes,
    String? businessPurpose,
    List<ReceiptItem> items,
    List<String> tags,
    bool isFavorite,
    String? batchId,
    double? ocrConfidence,
    String? ocrRawText,
    String? errorMessage,
    String? cloudStorageUrl,
    bool needsReview,
  });
}

/// @nodoc
class _$ReceiptModelCopyWithImpl<$Res, $Val extends ReceiptModel>
    implements $ReceiptModelCopyWith<$Res> {
  _$ReceiptModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReceiptModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? status = null,
    Object? imagePath = null,
    Object? updatedAt = null,
    Object? merchant = freezed,
    Object? totalAmount = freezed,
    Object? taxAmount = freezed,
    Object? purchaseDate = freezed,
    Object? category = freezed,
    Object? paymentMethod = freezed,
    Object? notes = freezed,
    Object? businessPurpose = freezed,
    Object? items = null,
    Object? tags = null,
    Object? isFavorite = null,
    Object? batchId = freezed,
    Object? ocrConfidence = freezed,
    Object? ocrRawText = freezed,
    Object? errorMessage = freezed,
    Object? cloudStorageUrl = freezed,
    Object? needsReview = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as ReceiptId,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ReceiptStatus,
            imagePath: null == imagePath
                ? _value.imagePath
                : imagePath // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            merchant: freezed == merchant
                ? _value.merchant
                : merchant // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalAmount: freezed == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as Money?,
            taxAmount: freezed == taxAmount
                ? _value.taxAmount
                : taxAmount // ignore: cast_nullable_to_non_nullable
                      as Money?,
            purchaseDate: freezed == purchaseDate
                ? _value.purchaseDate
                : purchaseDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as Category?,
            paymentMethod: freezed == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                      as PaymentMethod?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            businessPurpose: freezed == businessPurpose
                ? _value.businessPurpose
                : businessPurpose // ignore: cast_nullable_to_non_nullable
                      as String?,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<ReceiptItem>,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            isFavorite: null == isFavorite
                ? _value.isFavorite
                : isFavorite // ignore: cast_nullable_to_non_nullable
                      as bool,
            batchId: freezed == batchId
                ? _value.batchId
                : batchId // ignore: cast_nullable_to_non_nullable
                      as String?,
            ocrConfidence: freezed == ocrConfidence
                ? _value.ocrConfidence
                : ocrConfidence // ignore: cast_nullable_to_non_nullable
                      as double?,
            ocrRawText: freezed == ocrRawText
                ? _value.ocrRawText
                : ocrRawText // ignore: cast_nullable_to_non_nullable
                      as String?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            cloudStorageUrl: freezed == cloudStorageUrl
                ? _value.cloudStorageUrl
                : cloudStorageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            needsReview: null == needsReview
                ? _value.needsReview
                : needsReview // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReceiptModelImplCopyWith<$Res>
    implements $ReceiptModelCopyWith<$Res> {
  factory _$$ReceiptModelImplCopyWith(
    _$ReceiptModelImpl value,
    $Res Function(_$ReceiptModelImpl) then,
  ) = __$$ReceiptModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ReceiptId id,
    DateTime createdAt,
    ReceiptStatus status,
    String imagePath,
    DateTime updatedAt,
    String? merchant,
    Money? totalAmount,
    Money? taxAmount,
    DateTime? purchaseDate,
    Category? category,
    PaymentMethod? paymentMethod,
    String? notes,
    String? businessPurpose,
    List<ReceiptItem> items,
    List<String> tags,
    bool isFavorite,
    String? batchId,
    double? ocrConfidence,
    String? ocrRawText,
    String? errorMessage,
    String? cloudStorageUrl,
    bool needsReview,
  });
}

/// @nodoc
class __$$ReceiptModelImplCopyWithImpl<$Res>
    extends _$ReceiptModelCopyWithImpl<$Res, _$ReceiptModelImpl>
    implements _$$ReceiptModelImplCopyWith<$Res> {
  __$$ReceiptModelImplCopyWithImpl(
    _$ReceiptModelImpl _value,
    $Res Function(_$ReceiptModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReceiptModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? status = null,
    Object? imagePath = null,
    Object? updatedAt = null,
    Object? merchant = freezed,
    Object? totalAmount = freezed,
    Object? taxAmount = freezed,
    Object? purchaseDate = freezed,
    Object? category = freezed,
    Object? paymentMethod = freezed,
    Object? notes = freezed,
    Object? businessPurpose = freezed,
    Object? items = null,
    Object? tags = null,
    Object? isFavorite = null,
    Object? batchId = freezed,
    Object? ocrConfidence = freezed,
    Object? ocrRawText = freezed,
    Object? errorMessage = freezed,
    Object? cloudStorageUrl = freezed,
    Object? needsReview = null,
  }) {
    return _then(
      _$ReceiptModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as ReceiptId,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ReceiptStatus,
        imagePath: null == imagePath
            ? _value.imagePath
            : imagePath // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        merchant: freezed == merchant
            ? _value.merchant
            : merchant // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalAmount: freezed == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as Money?,
        taxAmount: freezed == taxAmount
            ? _value.taxAmount
            : taxAmount // ignore: cast_nullable_to_non_nullable
                  as Money?,
        purchaseDate: freezed == purchaseDate
            ? _value.purchaseDate
            : purchaseDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as Category?,
        paymentMethod: freezed == paymentMethod
            ? _value.paymentMethod
            : paymentMethod // ignore: cast_nullable_to_non_nullable
                  as PaymentMethod?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        businessPurpose: freezed == businessPurpose
            ? _value.businessPurpose
            : businessPurpose // ignore: cast_nullable_to_non_nullable
                  as String?,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<ReceiptItem>,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        isFavorite: null == isFavorite
            ? _value.isFavorite
            : isFavorite // ignore: cast_nullable_to_non_nullable
                  as bool,
        batchId: freezed == batchId
            ? _value.batchId
            : batchId // ignore: cast_nullable_to_non_nullable
                  as String?,
        ocrConfidence: freezed == ocrConfidence
            ? _value.ocrConfidence
            : ocrConfidence // ignore: cast_nullable_to_non_nullable
                  as double?,
        ocrRawText: freezed == ocrRawText
            ? _value.ocrRawText
            : ocrRawText // ignore: cast_nullable_to_non_nullable
                  as String?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        cloudStorageUrl: freezed == cloudStorageUrl
            ? _value.cloudStorageUrl
            : cloudStorageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        needsReview: null == needsReview
            ? _value.needsReview
            : needsReview // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReceiptModelImpl extends _ReceiptModel {
  const _$ReceiptModelImpl({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.imagePath,
    required this.updatedAt,
    this.merchant,
    this.totalAmount,
    this.taxAmount,
    this.purchaseDate,
    this.category,
    this.paymentMethod,
    this.notes,
    this.businessPurpose,
    final List<ReceiptItem> items = const [],
    final List<String> tags = const [],
    this.isFavorite = false,
    this.batchId,
    this.ocrConfidence,
    this.ocrRawText,
    this.errorMessage,
    this.cloudStorageUrl,
    this.needsReview = false,
  }) : _items = items,
       _tags = tags,
       super._();

  factory _$ReceiptModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReceiptModelImplFromJson(json);

  /// Unique identifier - always required
  @override
  final ReceiptId id;

  /// Creation timestamp - always required
  @override
  final DateTime createdAt;

  /// Processing status - always required
  @override
  final ReceiptStatus status;

  /// Image storage location - always required
  @override
  final String imagePath;

  /// Last modification timestamp
  @override
  final DateTime updatedAt;
  // ===== BUSINESS DATA - Nullable when truly unknown =====
  /// Merchant/vendor name from receipt
  @override
  final String? merchant;

  /// Total amount including tax
  @override
  final Money? totalAmount;

  /// Tax amount
  @override
  final Money? taxAmount;

  /// Date on the receipt (not capture date)
  @override
  final DateTime? purchaseDate;

  /// Business category
  @override
  final Category? category;

  /// Payment method used
  @override
  final PaymentMethod? paymentMethod;

  /// User notes
  @override
  final String? notes;

  /// Business purpose/justification
  @override
  final String? businessPurpose;

  /// Line items from receipt
  final List<ReceiptItem> _items;

  /// Line items from receipt
  @override
  @JsonKey()
  List<ReceiptItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  /// User-defined tags for organization
  final List<String> _tags;

  /// User-defined tags for organization
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  /// Whether this is marked as favorite
  @override
  @JsonKey()
  final bool isFavorite;

  /// Batch ID if part of batch capture
  @override
  final String? batchId;

  /// OCR confidence score (0.0 to 1.0)
  @override
  final double? ocrConfidence;

  /// Raw OCR text for reference
  @override
  final String? ocrRawText;

  /// Error message if status is error
  @override
  final String? errorMessage;

  /// Cloud storage URL if synced
  @override
  final String? cloudStorageUrl;

  /// Whether this needs manual review
  @override
  @JsonKey()
  final bool needsReview;

  @override
  String toString() {
    return 'ReceiptModel(id: $id, createdAt: $createdAt, status: $status, imagePath: $imagePath, updatedAt: $updatedAt, merchant: $merchant, totalAmount: $totalAmount, taxAmount: $taxAmount, purchaseDate: $purchaseDate, category: $category, paymentMethod: $paymentMethod, notes: $notes, businessPurpose: $businessPurpose, items: $items, tags: $tags, isFavorite: $isFavorite, batchId: $batchId, ocrConfidence: $ocrConfidence, ocrRawText: $ocrRawText, errorMessage: $errorMessage, cloudStorageUrl: $cloudStorageUrl, needsReview: $needsReview)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceiptModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.merchant, merchant) ||
                other.merchant == merchant) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.taxAmount, taxAmount) ||
                other.taxAmount == taxAmount) &&
            (identical(other.purchaseDate, purchaseDate) ||
                other.purchaseDate == purchaseDate) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.businessPurpose, businessPurpose) ||
                other.businessPurpose == businessPurpose) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.batchId, batchId) || other.batchId == batchId) &&
            (identical(other.ocrConfidence, ocrConfidence) ||
                other.ocrConfidence == ocrConfidence) &&
            (identical(other.ocrRawText, ocrRawText) ||
                other.ocrRawText == ocrRawText) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.cloudStorageUrl, cloudStorageUrl) ||
                other.cloudStorageUrl == cloudStorageUrl) &&
            (identical(other.needsReview, needsReview) ||
                other.needsReview == needsReview));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    createdAt,
    status,
    imagePath,
    updatedAt,
    merchant,
    totalAmount,
    taxAmount,
    purchaseDate,
    category,
    paymentMethod,
    notes,
    businessPurpose,
    const DeepCollectionEquality().hash(_items),
    const DeepCollectionEquality().hash(_tags),
    isFavorite,
    batchId,
    ocrConfidence,
    ocrRawText,
    errorMessage,
    cloudStorageUrl,
    needsReview,
  ]);

  /// Create a copy of ReceiptModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReceiptModelImplCopyWith<_$ReceiptModelImpl> get copyWith =>
      __$$ReceiptModelImplCopyWithImpl<_$ReceiptModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReceiptModelImplToJson(this);
  }
}

abstract class _ReceiptModel extends ReceiptModel {
  const factory _ReceiptModel({
    required final ReceiptId id,
    required final DateTime createdAt,
    required final ReceiptStatus status,
    required final String imagePath,
    required final DateTime updatedAt,
    final String? merchant,
    final Money? totalAmount,
    final Money? taxAmount,
    final DateTime? purchaseDate,
    final Category? category,
    final PaymentMethod? paymentMethod,
    final String? notes,
    final String? businessPurpose,
    final List<ReceiptItem> items,
    final List<String> tags,
    final bool isFavorite,
    final String? batchId,
    final double? ocrConfidence,
    final String? ocrRawText,
    final String? errorMessage,
    final String? cloudStorageUrl,
    final bool needsReview,
  }) = _$ReceiptModelImpl;
  const _ReceiptModel._() : super._();

  factory _ReceiptModel.fromJson(Map<String, dynamic> json) =
      _$ReceiptModelImpl.fromJson;

  /// Unique identifier - always required
  @override
  ReceiptId get id;

  /// Creation timestamp - always required
  @override
  DateTime get createdAt;

  /// Processing status - always required
  @override
  ReceiptStatus get status;

  /// Image storage location - always required
  @override
  String get imagePath;

  /// Last modification timestamp
  @override
  DateTime get updatedAt; // ===== BUSINESS DATA - Nullable when truly unknown =====
  /// Merchant/vendor name from receipt
  @override
  String? get merchant;

  /// Total amount including tax
  @override
  Money? get totalAmount;

  /// Tax amount
  @override
  Money? get taxAmount;

  /// Date on the receipt (not capture date)
  @override
  DateTime? get purchaseDate;

  /// Business category
  @override
  Category? get category;

  /// Payment method used
  @override
  PaymentMethod? get paymentMethod;

  /// User notes
  @override
  String? get notes;

  /// Business purpose/justification
  @override
  String? get businessPurpose;

  /// Line items from receipt
  @override
  List<ReceiptItem> get items;

  /// User-defined tags for organization
  @override
  List<String> get tags;

  /// Whether this is marked as favorite
  @override
  bool get isFavorite;

  /// Batch ID if part of batch capture
  @override
  String? get batchId;

  /// OCR confidence score (0.0 to 1.0)
  @override
  double? get ocrConfidence;

  /// Raw OCR text for reference
  @override
  String? get ocrRawText;

  /// Error message if status is error
  @override
  String? get errorMessage;

  /// Cloud storage URL if synced
  @override
  String? get cloudStorageUrl;

  /// Whether this needs manual review
  @override
  bool get needsReview;

  /// Create a copy of ReceiptModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReceiptModelImplCopyWith<_$ReceiptModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
