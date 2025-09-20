import 'package:faker/faker.dart';
import 'package:receipt_organizer/domain/entities/receipt_item.dart';
import 'package:receipt_organizer/domain/value_objects/money.dart' as money;
import 'package:receipt_organizer/domain/value_objects/category.dart';
import 'base_factory.dart';

/// Factory for creating ReceiptItem test data
class ReceiptItemFactory extends BaseFactory<ReceiptItem> {
  static final _faker = Faker();

  // Common grocery items
  static const _groceryItems = [
    {'name': 'Milk 2% Gallon', 'unit': 'gal', 'category': 'dairy', 'price_range': [3.0, 5.0]},
    {'name': 'Bread Whole Wheat', 'unit': 'loaf', 'category': 'bakery', 'price_range': [2.0, 4.0]},
    {'name': 'Eggs Large Dozen', 'unit': 'dozen', 'category': 'dairy', 'price_range': [2.5, 5.0]},
    {'name': 'Bananas', 'unit': 'lb', 'category': 'produce', 'price_range': [0.5, 1.5]},
    {'name': 'Chicken Breast', 'unit': 'lb', 'category': 'meat', 'price_range': [4.0, 8.0]},
    {'name': 'Ground Beef', 'unit': 'lb', 'category': 'meat', 'price_range': [4.5, 7.0]},
    {'name': 'Apples Gala', 'unit': 'lb', 'category': 'produce', 'price_range': [1.0, 3.0]},
    {'name': 'Orange Juice', 'unit': 'gal', 'category': 'beverage', 'price_range': [3.5, 6.0]},
    {'name': 'Yogurt Greek', 'unit': 'oz', 'category': 'dairy', 'price_range': [4.0, 7.0]},
    {'name': 'Cereal', 'unit': 'box', 'category': 'breakfast', 'price_range': [3.0, 6.0]},
  ];

  // Restaurant menu items
  static const _restaurantItems = [
    {'name': 'Caesar Salad', 'price': 12.99},
    {'name': 'Grilled Chicken Sandwich', 'price': 14.99},
    {'name': 'Pasta Carbonara', 'price': 18.99},
    {'name': 'Ribeye Steak', 'price': 32.99},
    {'name': 'Fish Tacos', 'price': 15.99},
    {'name': 'Margherita Pizza', 'price': 16.99},
    {'name': 'Burger & Fries', 'price': 13.99},
    {'name': 'Chicken Wings', 'price': 11.99},
    {'name': 'Soup of the Day', 'price': 7.99},
    {'name': 'House Salad', 'price': 8.99},
  ];

  // Beverage items
  static const _beverageItems = [
    {'name': 'Coffee', 'price': 2.99},
    {'name': 'Latte', 'price': 5.99},
    {'name': 'Cappuccino', 'price': 4.99},
    {'name': 'Iced Tea', 'price': 2.49},
    {'name': 'Soft Drink', 'price': 2.99},
    {'name': 'Orange Juice', 'price': 3.99},
    {'name': 'Smoothie', 'price': 6.99},
    {'name': 'Beer', 'price': 5.99},
    {'name': 'Wine Glass', 'price': 8.99},
  ];

  @override
  Map<String, dynamic> generateDefaults() {
    final item = _groceryItems[_faker.randomGenerator.integer(_groceryItems.length)];
    final priceRange = item['price_range'] as List<double>;
    final unitPrice = _faker.randomGenerator.decimal(
      min: priceRange[0],
      scale: priceRange[1],
    );
    final quantity = _faker.randomGenerator.decimal(min: 1, scale: 5);

    return {
      'name': item['name'] as String,
      'quantity': quantity,
      'unit': item['unit'] as String,
      'unitPrice': money.Money.from(unitPrice, money.Currency.usd),
      'totalPrice': money.Money.from(unitPrice * quantity, money.Currency.usd),
      'category': _mapToCategory(item['category'] as String),
      'sku': _generateSku(item['name'] as String),
      'barcode': _faker.randomGenerator.boolean() ? _generateBarcode() : null,
      'isTaxable': true,
      'discount': _faker.randomGenerator.decimal() < 0.2
          ? money.Money.from(_faker.randomGenerator.decimal(min: 0.5, scale: 5), money.Currency.usd)
          : null,
      'notes': null,
    };
  }

  @override
  ReceiptItem fromMap(Map<String, dynamic> data) {
    return ReceiptItem(
      name: data['name'] as String,
      quantity: data['quantity'] as double? ?? 1,
      unit: data['unit'] as String? ?? 'each',
      unitPrice: data['unitPrice'] as money.Money?,
      totalPrice: data['totalPrice'] as money.Money?,
      category: data['category'] as Category?,
      sku: data['sku'] as String?,
      barcode: data['barcode'] as String?,
      isTaxable: data['isTaxable'] as bool? ?? true,
      discount: data['discount'] as money.Money?,
      notes: data['notes'] as String?,
    );
  }

  /// Create grocery items
  List<ReceiptItem> createGroceryItems(int count) {
    return List.generate(count, (_) {
      final item = _groceryItems[_faker.randomGenerator.integer(_groceryItems.length)];
      final priceRange = item['price_range'] as List<double>;
      final unitPrice = _faker.randomGenerator.decimal(
        min: priceRange[0],
        scale: priceRange[1],
      );
      final quantity = _faker.randomGenerator.decimal(min: 1, scale: 3);

      return create(overrides: {
        'name': item['name'],
        'unit': item['unit'],
        'category': _mapToCategory(item['category'] as String),
        'quantity': quantity,
        'unitPrice': money.Money.from(unitPrice, money.Currency.usd),
        'totalPrice': money.Money.from(unitPrice * quantity, money.Currency.usd),
      });
    });
  }

  /// Create restaurant menu items
  List<ReceiptItem> createRestaurantItems(int count) {
    return List.generate(count, (_) {
      final item = _restaurantItems[_faker.randomGenerator.integer(_restaurantItems.length)];
      final price = item['price'] as double;
      final quantity = _faker.randomGenerator.integer(3, min: 1).toDouble();

      return create(overrides: {
        'name': item['name'],
        'quantity': quantity,
        'unit': 'each',
        'unitPrice': money.Money.from(price, money.Currency.usd),
        'totalPrice': money.Money.from(price * quantity, money.Currency.usd),
        'category': Category(type: CategoryType.dining),
      });
    });
  }

  /// Create beverage items
  List<ReceiptItem> createBeverageItems(int count) {
    return List.generate(count, (_) {
      final item = _beverageItems[_faker.randomGenerator.integer(_beverageItems.length)];
      final price = item['price'] as double;
      final quantity = _faker.randomGenerator.integer(4, min: 1).toDouble();

      return create(overrides: {
        'name': item['name'],
        'quantity': quantity,
        'unit': 'each',
        'unitPrice': money.Money.from(price, money.Currency.usd),
        'totalPrice': money.Money.from(price * quantity, money.Currency.usd),
        'category': Category(type: CategoryType.dining),
      });
    });
  }

  /// Create an item with discount
  ReceiptItem createWithDiscount({
    double discountPercentage = 0.20,
    Map<String, dynamic>? overrides,
  }) {
    final regularPrice = _faker.randomGenerator.decimal(min: 5, scale: 50);
    final discountAmount = regularPrice * discountPercentage;
    final finalPrice = regularPrice - discountAmount;

    return create(overrides: {
      'unitPrice': money.Money.from(regularPrice, money.Currency.usd),
      'totalPrice': money.Money.from(finalPrice, money.Currency.usd),
      'discount': money.Money.from(discountAmount, money.Currency.usd),
      'notes': '${(discountPercentage * 100).toStringAsFixed(0)}% off',
      ...?overrides,
    });
  }

  /// Create a simple item with just name and price
  ReceiptItem createSimple(String name, double price) {
    return ReceiptItem.simple(
      name: name,
      price: price,
      quantity: 1,
      currency: money.Currency.usd,
    );
  }

  /// Create bulk items (like produce sold by weight)
  ReceiptItem createBulkItem({
    String? name,
    double? weight,
    double? pricePerUnit,
    Map<String, dynamic>? overrides,
  }) {
    final itemName = name ?? 'Organic Produce';
    final itemWeight = weight ?? _faker.randomGenerator.decimal(min: 0.5, scale: 5);
    final unitPrice = pricePerUnit ?? _faker.randomGenerator.decimal(min: 1, scale: 10);

    return create(overrides: {
      'name': itemName,
      'quantity': itemWeight,
      'unit': 'lb',
      'unitPrice': money.Money.from(unitPrice, money.Currency.usd),
      'totalPrice': money.Money.from(unitPrice * itemWeight, money.Currency.usd),
      ...?overrides,
    });
  }

  /// Create non-taxable item
  ReceiptItem createNonTaxable({Map<String, dynamic>? overrides}) {
    return create(overrides: {
      'isTaxable': false,
      'category': Category(type: CategoryType.groceries), // Many groceries are non-taxable
      ...?overrides,
    });
  }

  /// Generate SKU from item name
  String _generateSku(String itemName) {
    final parts = itemName.toUpperCase().split(' ').map((word) {
      return word.length > 3 ? word.substring(0, 3) : word;
    }).join('-');

    final number = _faker.randomGenerator.integer(9999, min: 1000);
    return '$parts-$number';
  }

  /// Generate realistic barcode
  String _generateBarcode() {
    // Generate UPC-A format (12 digits)
    final manufacturer = _faker.randomGenerator.integer(99999, min: 10000);
    final product = _faker.randomGenerator.integer(99999, min: 10000);
    final checkDigit = _faker.randomGenerator.integer(9);

    return '0$manufacturer$product$checkDigit';
  }

  /// Map category string to Category object
  Category? _mapToCategory(String categoryStr) {
    switch (categoryStr) {
      case 'dairy':
      case 'meat':
      case 'produce':
      case 'bakery':
      case 'breakfast':
        return Category(type: CategoryType.groceries, subcategory: categoryStr);
      case 'beverage':
        return Category(type: CategoryType.groceries, subcategory: 'beverages');
      default:
        return Category(type: CategoryType.other);
    }
  }
}