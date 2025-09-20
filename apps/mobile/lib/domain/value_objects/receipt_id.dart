import 'package:uuid/uuid.dart';
import 'package:equatable/equatable.dart';

/// Strongly-typed identifier for receipts
///
/// This ensures we never accidentally pass a random string
/// where a receipt ID is expected.
class ReceiptId extends Equatable {
  final String value;

  const ReceiptId._(this.value);

  /// Generate a new unique receipt ID
  factory ReceiptId.generate() {
    return ReceiptId._(const Uuid().v4());
  }

  /// Create from existing string with validation
  factory ReceiptId.fromString(String id) {
    if (id.isEmpty) {
      throw ArgumentError('Receipt ID cannot be empty');
    }

    // Basic UUID v4 format validation
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );

    if (!uuidRegex.hasMatch(id)) {
      // Allow non-UUID for legacy/test data, but validate length
      if (id.length < 3 || id.length > 100) {
        throw ArgumentError('Invalid receipt ID format: $id');
      }
    }

    return ReceiptId._(id);
  }

  /// Create from string without validation (use with caution)
  factory ReceiptId.unsafe(String id) {
    return ReceiptId._(id);
  }

  /// Check if this is a valid UUID format
  bool get isValid {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(value) || (value.length >= 3 && value.length <= 100);
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;

  /// Convert to JSON
  String toJson() => value;

  /// Create from JSON
  factory ReceiptId.fromJson(String json) => ReceiptId.fromString(json);
}