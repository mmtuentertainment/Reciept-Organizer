import 'package:supabase_flutter/supabase_flutter.dart';

/// A utility class to query Supabase directly for development/debugging purposes
class SupabaseQueryTool {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Fetch all categories from the categories table
  /// Returns a list of category maps with id, name, color, icon, and other fields
  static Future<List<Map<String, dynamic>>> fetchAllCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select('*')
          .order('name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }

  /// Fetch categories for a specific user
  static Future<List<Map<String, dynamic>>> fetchCategoriesForUser(String userId) async {
    try {
      final response = await _client
          .from('categories')
          .select('*')
          .eq('user_id', userId)
          .order('name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching categories for user $userId: $e');
      rethrow;
    }
  }

  /// Print all categories in a formatted way for debugging
  static Future<void> printAllCategories() async {
    try {
      final categories = await fetchAllCategories();

      print('=== CATEGORIES TABLE CONTENT ===');
      print('Total categories: ${categories.length}');
      print('');

      for (int i = 0; i < categories.length; i++) {
        final category = categories[i];
        print('Category ${i + 1}:');
        print('  ID: ${category['id']}');
        print('  User ID: ${category['user_id']}');
        print('  Name: ${category['name']}');
        print('  Color: ${category['color']}');
        print('  Icon: ${category['icon']}');
        print('  Created At: ${category['created_at']}');
        print('');
      }

      // Group by user for analysis
      final userGroups = <String, List<Map<String, dynamic>>>{};
      for (final category in categories) {
        final userId = category['user_id'] as String;
        userGroups[userId] ??= [];
        userGroups[userId]!.add(category);
      }

      print('=== USER DISTRIBUTION ===');
      userGroups.forEach((userId, userCategories) {
        print('User $userId: ${userCategories.length} categories');
        for (final category in userCategories) {
          print('  - ${category['name']} (${category['color']}, ${category['icon']})');
        }
        print('');
      });

    } catch (e) {
      print('Error printing categories: $e');
      rethrow;
    }
  }

  /// Create a Category model from the database data for Flutter mapping
  static Category categoryFromMap(Map<String, dynamic> data) {
    return Category(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      name: data['name'] as String,
      color: data['color'] as String,
      icon: data['icon'] as String,
      displayOrder: data['display_order'] as int?,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }

  /// Convert a list of category maps to Category models
  static List<Category> categoriesToModels(List<Map<String, dynamic>> data) {
    return data.map(categoryFromMap).toList();
  }
}

/// Flutter model class for categories that matches the database schema
class Category {
  final String id;
  final String userId;
  final String name;
  final String color;
  final String icon;
  final int? displayOrder;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.color,
    required this.icon,
    this.displayOrder,
    required this.createdAt,
  });

  /// Create a Category from JSON/Map (from Supabase)
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      icon: json['icon'] as String,
      displayOrder: json['display_order'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert Category to JSON/Map (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'color': color,
      'icon': icon,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy with modifications
  Category copyWith({
    String? id,
    String? userId,
    String? name,
    String? color,
    String? icon,
    int? displayOrder,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, color: $color, icon: $icon, order: $displayOrder)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}