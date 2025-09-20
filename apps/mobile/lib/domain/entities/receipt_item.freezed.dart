// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receipt_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReceiptItem _$ReceiptItemFromJson(Map<String, dynamic> json) {
  return _ReceiptItem.fromJson(json);
}

/// @nodoc
mixin _$ReceiptItem {
  /// Item description/name
  String get name => throw _privateConstructorUsedError;

  /// Quantity purchased
  double get quantity => throw _privateConstructorUsedError;

  /// Unit of measurement (e.g., 'lb', 'kg', 'each')
  String get unit => throw _privateConstructorUsedError;

  /// Price per unit
  Money? get unitPrice => throw _privateConstructorUsedError;

  /// Total price (quantity × unit price)
  Money? get totalPrice => throw _privateConstructorUsedError;

  /// Item category (may differ from receipt category)
  Category? get category => throw _privateConstructorUsedError;

  /// SKU or product code
  String? get sku => throw _privateConstructorUsedError;

  /// Barcode if available
  String? get barcode => throw _privateConstructorUsedError;

  /// Whether this item is taxable
  bool get isTaxable => throw _privateConstructorUsedError;

  /// Discount amount if any
  Money? get discount => throw _privateConstructorUsedError;

  /// Additional notes
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this ReceiptItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReceiptItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReceiptItemCopyWith<ReceiptItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReceiptItemCopyWith<$Res> {
  factory $ReceiptItemCopyWith(
    ReceiptItem value,
    $Res Function(ReceiptItem) then,
  ) = _$ReceiptItemCopyWithImpl<$Res, ReceiptItem>;
  @useResult
  $Res call({
    String name,
    double quantity,
    String unit,
    Money? unitPrice,
    Money? totalPrice,
    Category? category,
    String? sku,
    String? barcode,
    bool isTaxable,
    Money? discount,
    String? notes,
  });
}

/// @nodoc
class _$ReceiptItemCopyWithImpl<$Res, $Val extends ReceiptItem>
    implements $ReceiptItemCopyWith<$Res> {
  _$ReceiptItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReceiptItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? quantity = null,
    Object? unit = null,
    Object? unitPrice = freezed,
    Object? totalPrice = freezed,
    Object? category = freezed,
    Object? sku = freezed,
    Object? barcode = freezed,
    Object? isTaxable = null,
    Object? discount = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as double,
            unit: null == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as String,
            unitPrice: freezed == unitPrice
                ? _value.unitPrice
                : unitPrice // ignore: cast_nullable_to_non_nullable
                      as Money?,
            totalPrice: freezed == totalPrice
                ? _value.totalPrice
                : totalPrice // ignore: cast_nullable_to_non_nullable
                      as Money?,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as Category?,
            sku: freezed == sku
                ? _value.sku
                : sku // ignore: cast_nullable_to_non_nullable
                      as String?,
            barcode: freezed == barcode
                ? _value.barcode
                : barcode // ignore: cast_nullable_to_non_nullable
                      as String?,
            isTaxable: null == isTaxable
                ? _value.isTaxable
                : isTaxable // ignore: cast_nullable_to_non_nullable
                      as bool,
            discount: freezed == discount
                ? _value.discount
                : discount // ignore: cast_nullable_to_non_nullable
                      as Money?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReceiptItemImplCopyWith<$Res>
    implements $ReceiptItemCopyWith<$Res> {
  factory _$$ReceiptItemImplCopyWith(
    _$ReceiptItemImpl value,
    $Res Function(_$ReceiptItemImpl) then,
  ) = __$$ReceiptItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    double quantity,
    String unit,
    Money? unitPrice,
    Money? totalPrice,
    Category? category,
    String? sku,
    String? barcode,
    bool isTaxable,
    Money? discount,
    String? notes,
  });
}

/// @nodoc
class __$$ReceiptItemImplCopyWithImpl<$Res>
    extends _$ReceiptItemCopyWithImpl<$Res, _$ReceiptItemImpl>
    implements _$$ReceiptItemImplCopyWith<$Res> {
  __$$ReceiptItemImplCopyWithImpl(
    _$ReceiptItemImpl _value,
    $Res Function(_$ReceiptItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReceiptItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? quantity = null,
    Object? unit = null,
    Object? unitPrice = freezed,
    Object? totalPrice = freezed,
    Object? category = freezed,
    Object? sku = freezed,
    Object? barcode = freezed,
    Object? isTaxable = null,
    Object? discount = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _$ReceiptItemImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as double,
        unit: null == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as String,
        unitPrice: freezed == unitPrice
            ? _value.unitPrice
            : unitPrice // ignore: cast_nullable_to_non_nullable
                  as Money?,
        totalPrice: freezed == totalPrice
            ? _value.totalPrice
            : totalPrice // ignore: cast_nullable_to_non_nullable
                  as Money?,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as Category?,
        sku: freezed == sku
            ? _value.sku
            : sku // ignore: cast_nullable_to_non_nullable
                  as String?,
        barcode: freezed == barcode
            ? _value.barcode
            : barcode // ignore: cast_nullable_to_non_nullable
                  as String?,
        isTaxable: null == isTaxable
            ? _value.isTaxable
            : isTaxable // ignore: cast_nullable_to_non_nullable
                  as bool,
        discount: freezed == discount
            ? _value.discount
            : discount // ignore: cast_nullable_to_non_nullable
                  as Money?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReceiptItemImpl extends _ReceiptItem {
  const _$ReceiptItemImpl({
    required this.name,
    this.quantity = 1,
    this.unit = 'each',
    this.unitPrice,
    this.totalPrice,
    this.category,
    this.sku,
    this.barcode,
    this.isTaxable = true,
    this.discount,
    this.notes,
  }) : super._();

  factory _$ReceiptItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReceiptItemImplFromJson(json);

  /// Item description/name
  @override
  final String name;

  /// Quantity purchased
  @override
  @JsonKey()
  final double quantity;

  /// Unit of measurement (e.g., 'lb', 'kg', 'each')
  @override
  @JsonKey()
  final String unit;

  /// Price per unit
  @override
  final Money? unitPrice;

  /// Total price (quantity × unit price)
  @override
  final Money? totalPrice;

  /// Item category (may differ from receipt category)
  @override
  final Category? category;

  /// SKU or product code
  @override
  final String? sku;

  /// Barcode if available
  @override
  final String? barcode;

  /// Whether this item is taxable
  @override
  @JsonKey()
  final bool isTaxable;

  /// Discount amount if any
  @override
  final Money? discount;

  /// Additional notes
  @override
  final String? notes;

  @override
  String toString() {
    return 'ReceiptItem(name: $name, quantity: $quantity, unit: $unit, unitPrice: $unitPrice, totalPrice: $totalPrice, category: $category, sku: $sku, barcode: $barcode, isTaxable: $isTaxable, discount: $discount, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceiptItemImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.isTaxable, isTaxable) ||
                other.isTaxable == isTaxable) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    quantity,
    unit,
    unitPrice,
    totalPrice,
    category,
    sku,
    barcode,
    isTaxable,
    discount,
    notes,
  );

  /// Create a copy of ReceiptItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReceiptItemImplCopyWith<_$ReceiptItemImpl> get copyWith =>
      __$$ReceiptItemImplCopyWithImpl<_$ReceiptItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReceiptItemImplToJson(this);
  }
}

abstract class _ReceiptItem extends ReceiptItem {
  const factory _ReceiptItem({
    required final String name,
    final double quantity,
    final String unit,
    final Money? unitPrice,
    final Money? totalPrice,
    final Category? category,
    final String? sku,
    final String? barcode,
    final bool isTaxable,
    final Money? discount,
    final String? notes,
  }) = _$ReceiptItemImpl;
  const _ReceiptItem._() : super._();

  factory _ReceiptItem.fromJson(Map<String, dynamic> json) =
      _$ReceiptItemImpl.fromJson;

  /// Item description/name
  @override
  String get name;

  /// Quantity purchased
  @override
  double get quantity;

  /// Unit of measurement (e.g., 'lb', 'kg', 'each')
  @override
  String get unit;

  /// Price per unit
  @override
  Money? get unitPrice;

  /// Total price (quantity × unit price)
  @override
  Money? get totalPrice;

  /// Item category (may differ from receipt category)
  @override
  Category? get category;

  /// SKU or product code
  @override
  String? get sku;

  /// Barcode if available
  @override
  String? get barcode;

  /// Whether this item is taxable
  @override
  bool get isTaxable;

  /// Discount amount if any
  @override
  Money? get discount;

  /// Additional notes
  @override
  String? get notes;

  /// Create a copy of ReceiptItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReceiptItemImplCopyWith<_$ReceiptItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
