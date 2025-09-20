import 'package:equatable/equatable.dart';

/// Receipt category enumeration
enum CategoryType {
  groceries('Groceries', '🛒', 'Food and household supplies'),
  dining('Dining', '🍽️', 'Restaurants and takeout'),
  transportation('Transportation', '🚗', 'Gas, parking, public transit'),
  entertainment('Entertainment', '🎬', 'Movies, events, recreation'),
  shopping('Shopping', '🛍️', 'Clothing, electronics, general retail'),
  utilities('Utilities', '💡', 'Electric, water, internet, phone'),
  healthcare('Healthcare', '🏥', 'Medical, pharmacy, wellness'),
  business('Business', '💼', 'Office supplies, services'),
  travel('Travel', '✈️', 'Hotels, flights, vacation'),
  education('Education', '📚', 'Courses, books, supplies'),
  home('Home', '🏠', 'Rent, mortgage, maintenance'),
  personal('Personal', '👤', 'Personal care, services'),
  other('Other', '📌', 'Uncategorized expenses');

  final String displayName;
  final String icon;
  final String description;

  const CategoryType(this.displayName, this.icon, this.description);

  /// Get category from string
  static CategoryType? fromString(String? value) {
    if (value == null) return null;

    final normalized = value.toLowerCase().trim();
    return CategoryType.values.firstWhere(
      (cat) => cat.name == normalized ||
               cat.displayName.toLowerCase() == normalized,
      orElse: () => CategoryType.other,
    );
  }
}

/// Value object for receipt category with optional subcategory
class Category extends Equatable {
  final CategoryType type;
  final String? subcategory;

  const Category({
    required this.type,
    this.subcategory,
  });

  /// Create from type only
  factory Category.of(CategoryType type) {
    return Category(type: type);
  }

  /// Create with subcategory
  factory Category.withSub(CategoryType type, String subcategory) {
    return Category(type: type, subcategory: subcategory);
  }

  /// Parse from string
  factory Category.parse(String value) {
    // Check for subcategory format: "category:subcategory"
    if (value.contains(':')) {
      final parts = value.split(':');
      final type = CategoryType.fromString(parts[0]) ?? CategoryType.other;
      return Category(type: type, subcategory: parts[1].trim());
    }

    final type = CategoryType.fromString(value) ?? CategoryType.other;
    return Category(type: type);
  }

  /// Get display name
  String get displayName {
    if (subcategory != null) {
      return '${type.displayName} - $subcategory';
    }
    return type.displayName;
  }

  /// Get icon
  String get icon => type.icon;

  /// Get full description
  String get description {
    if (subcategory != null) {
      return '${type.description} ($subcategory)';
    }
    return type.description;
  }

  /// Check if this is the default/other category
  bool get isOther => type == CategoryType.other;

  @override
  List<Object?> get props => [type, subcategory];

  @override
  String toString() => displayName;

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'subcategory': subcategory,
  };

  /// Create from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String;
    final type = CategoryType.values.firstWhere(
      (t) => t.name == typeName,
      orElse: () => CategoryType.other,
    );
    return Category(
      type: type,
      subcategory: json['subcategory'] as String?,
    );
  }
}