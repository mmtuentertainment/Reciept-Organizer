import 'package:flutter/material.dart';

/// Category model matching the Supabase categories table schema
class Category {
  final String id;
  final String userId;
  final String name;
  final String? color;  // Hex color code like '#3B82F6'
  final String? icon;   // Icon name like 'utensils', 'plane', etc.
  final DateTime createdAt;

  Category({
    required this.id,
    required this.userId,
    required this.name,
    this.color,
    this.icon,
    required this.createdAt,
  });

  /// Create Category from Supabase JSON response
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert Category to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'color': color,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get the Color object from hex string
  Color? get colorValue {
    if (color == null || color!.isEmpty) return null;

    final hexCode = color!.replaceAll('#', '');
    if (hexCode.length != 6) return null;

    try {
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (e) {
      return null;
    }
  }

  /// Get icon data (you can map these to actual icons in your app)
  IconData get iconData {
    // Map icon names to Flutter icons
    switch (icon) {
      case 'utensils':
        return Icons.restaurant;
      case 'plane':
        return Icons.flight;
      case 'briefcase':
        return Icons.work;
      case 'laptop':
        return Icons.computer;
      case 'megaphone':
        return Icons.campaign;
      case 'user-tie':
        return Icons.person;
      case 'wrench':
        return Icons.build;
      case 'zap':
        return Icons.bolt;
      case 'folder':
        return Icons.folder;
      default:
        return Icons.category;
    }
  }

  Category copyWith({
    String? id,
    String? userId,
    String? name,
    String? color,
    String? icon,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Default categories that are created for new users
class DefaultCategories {
  static const List<Map<String, String>> categories = [
    {'name': 'Business Meals', 'color': '#3B82F6', 'icon': 'utensils'},
    {'name': 'Travel & Transportation', 'color': '#10B981', 'icon': 'plane'},
    {'name': 'Office Supplies', 'color': '#8B5CF6', 'icon': 'briefcase'},
    {'name': 'Software & Subscriptions', 'color': '#F59E0B', 'icon': 'laptop'},
    {'name': 'Marketing & Advertising', 'color': '#EF4444', 'icon': 'megaphone'},
    {'name': 'Professional Services', 'color': '#6B7280', 'icon': 'user-tie'},
    {'name': 'Equipment & Hardware', 'color': '#9333EA', 'icon': 'wrench'},
    {'name': 'Utilities', 'color': '#14B8A6', 'icon': 'zap'},
    {'name': 'Other', 'color': '#64748B', 'icon': 'folder'},
  ];
}