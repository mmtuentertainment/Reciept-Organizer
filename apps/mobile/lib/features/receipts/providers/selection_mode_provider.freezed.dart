// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'selection_mode_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SelectionModeState {
  bool get isSelectionMode => throw _privateConstructorUsedError;
  Set<String> get selectedIds => throw _privateConstructorUsedError;
  List<Receipt> get allReceipts => throw _privateConstructorUsedError;
  String? get lastFocusedId => throw _privateConstructorUsedError;

  /// Create a copy of SelectionModeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SelectionModeStateCopyWith<SelectionModeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SelectionModeStateCopyWith<$Res> {
  factory $SelectionModeStateCopyWith(
          SelectionModeState value, $Res Function(SelectionModeState) then) =
      _$SelectionModeStateCopyWithImpl<$Res, SelectionModeState>;
  @useResult
  $Res call(
      {bool isSelectionMode,
      Set<String> selectedIds,
      List<Receipt> allReceipts,
      String? lastFocusedId});
}

/// @nodoc
class _$SelectionModeStateCopyWithImpl<$Res, $Val extends SelectionModeState>
    implements $SelectionModeStateCopyWith<$Res> {
  _$SelectionModeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SelectionModeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSelectionMode = null,
    Object? selectedIds = null,
    Object? allReceipts = null,
    Object? lastFocusedId = freezed,
  }) {
    return _then(_value.copyWith(
      isSelectionMode: null == isSelectionMode
          ? _value.isSelectionMode
          : isSelectionMode // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedIds: null == selectedIds
          ? _value.selectedIds
          : selectedIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      allReceipts: null == allReceipts
          ? _value.allReceipts
          : allReceipts // ignore: cast_nullable_to_non_nullable
              as List<Receipt>,
      lastFocusedId: freezed == lastFocusedId
          ? _value.lastFocusedId
          : lastFocusedId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SelectionModeStateImplCopyWith<$Res>
    implements $SelectionModeStateCopyWith<$Res> {
  factory _$$SelectionModeStateImplCopyWith(_$SelectionModeStateImpl value,
          $Res Function(_$SelectionModeStateImpl) then) =
      __$$SelectionModeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isSelectionMode,
      Set<String> selectedIds,
      List<Receipt> allReceipts,
      String? lastFocusedId});
}

/// @nodoc
class __$$SelectionModeStateImplCopyWithImpl<$Res>
    extends _$SelectionModeStateCopyWithImpl<$Res, _$SelectionModeStateImpl>
    implements _$$SelectionModeStateImplCopyWith<$Res> {
  __$$SelectionModeStateImplCopyWithImpl(_$SelectionModeStateImpl _value,
      $Res Function(_$SelectionModeStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SelectionModeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSelectionMode = null,
    Object? selectedIds = null,
    Object? allReceipts = null,
    Object? lastFocusedId = freezed,
  }) {
    return _then(_$SelectionModeStateImpl(
      isSelectionMode: null == isSelectionMode
          ? _value.isSelectionMode
          : isSelectionMode // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedIds: null == selectedIds
          ? _value._selectedIds
          : selectedIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      allReceipts: null == allReceipts
          ? _value._allReceipts
          : allReceipts // ignore: cast_nullable_to_non_nullable
              as List<Receipt>,
      lastFocusedId: freezed == lastFocusedId
          ? _value.lastFocusedId
          : lastFocusedId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$SelectionModeStateImpl extends _SelectionModeState {
  const _$SelectionModeStateImpl(
      {this.isSelectionMode = false,
      final Set<String> selectedIds = const {},
      final List<Receipt> allReceipts = const [],
      this.lastFocusedId})
      : _selectedIds = selectedIds,
        _allReceipts = allReceipts,
        super._();

  @override
  @JsonKey()
  final bool isSelectionMode;
  final Set<String> _selectedIds;
  @override
  @JsonKey()
  Set<String> get selectedIds {
    if (_selectedIds is EqualUnmodifiableSetView) return _selectedIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_selectedIds);
  }

  final List<Receipt> _allReceipts;
  @override
  @JsonKey()
  List<Receipt> get allReceipts {
    if (_allReceipts is EqualUnmodifiableListView) return _allReceipts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allReceipts);
  }

  @override
  final String? lastFocusedId;

  @override
  String toString() {
    return 'SelectionModeState(isSelectionMode: $isSelectionMode, selectedIds: $selectedIds, allReceipts: $allReceipts, lastFocusedId: $lastFocusedId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SelectionModeStateImpl &&
            (identical(other.isSelectionMode, isSelectionMode) ||
                other.isSelectionMode == isSelectionMode) &&
            const DeepCollectionEquality()
                .equals(other._selectedIds, _selectedIds) &&
            const DeepCollectionEquality()
                .equals(other._allReceipts, _allReceipts) &&
            (identical(other.lastFocusedId, lastFocusedId) ||
                other.lastFocusedId == lastFocusedId));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isSelectionMode,
      const DeepCollectionEquality().hash(_selectedIds),
      const DeepCollectionEquality().hash(_allReceipts),
      lastFocusedId);

  /// Create a copy of SelectionModeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SelectionModeStateImplCopyWith<_$SelectionModeStateImpl> get copyWith =>
      __$$SelectionModeStateImplCopyWithImpl<_$SelectionModeStateImpl>(
          this, _$identity);
}

abstract class _SelectionModeState extends SelectionModeState {
  const factory _SelectionModeState(
      {final bool isSelectionMode,
      final Set<String> selectedIds,
      final List<Receipt> allReceipts,
      final String? lastFocusedId}) = _$SelectionModeStateImpl;
  const _SelectionModeState._() : super._();

  @override
  bool get isSelectionMode;
  @override
  Set<String> get selectedIds;
  @override
  List<Receipt> get allReceipts;
  @override
  String? get lastFocusedId;

  /// Create a copy of SelectionModeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SelectionModeStateImplCopyWith<_$SelectionModeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
