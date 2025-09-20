import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/money.dart';
import '../value_objects/category.dart';

part 'receipt_item.freezed.dart';
part 'receipt_item.g.dart';

/// Represents a line item on a receipt
@freezed
class ReceiptItem with _$ReceiptItem {
  const ReceiptItem._();

  const factory ReceiptItem({
    /// Item description/name
    required String name,

    /// Quantity purchased
    @Default(1) double quantity,

    /// Unit of measurement (e.g., 'lb', 'kg', 'each')
    @Default('each') String unit,

    /// Price per unit
    Money? unitPrice,

    /// Total price (quantity × unit price)
    Money? totalPrice,

    /// Item category (may differ from receipt category)
    Category? category,

    /// SKU or product code
    String? sku,

    /// Barcode if available
    String? barcode,

    /// Whether this item is taxable
    @Default(true) bool isTaxable,

    /// Discount amount if any
    Money? discount,

    /// Additional notes
    String? notes,
  }) = _ReceiptItem;

  factory ReceiptItem.fromJson(Map<String, dynamic> json) =>
      _$ReceiptItemFromJson(json);

  /// Create a simple item with just name and price
  factory ReceiptItem.simple({
    required String name,
    required double price,
    double quantity = 1,
    Currency currency = Currency.usd,
  }) {
    final unitPrice = Money.from(price, currency);
    final totalPrice = Money.from(price * quantity, currency);

    return ReceiptItem(
      name: name,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
    );
  }

  /// Calculate total price if unit price is set
  Money? get calculatedTotal {
    if (unitPrice == null) return totalPrice;
    return unitPrice! * quantity;
  }

  /// Get display string for quantity
  String get displayQuantity {
    if (quantity == quantity.truncateToDouble()) {
      return '${quantity.toInt()} $unit';
    }
    return '${quantity.toStringAsFixed(2)} $unit';
  }

  /// Get display string for price
  String get displayPrice {
    final price = totalPrice ?? calculatedTotal;
    if (price == null) return '--';
    return price.display;
  }

  /// Check if item has complete pricing data
  bool get hasPricing => unitPrice != null || totalPrice != null;
}