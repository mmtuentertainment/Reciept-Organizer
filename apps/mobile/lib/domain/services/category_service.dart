import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/category.dart';

/// Service for managing receipt categories
class CategoryService {
  final SupabaseClient _client;

  CategoryService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Fetch all categories for the current authenticated user
  Future<List<Category>> getUserCategories() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('categories')
          .select('*')
          .eq('user_id', user.id)
          .order('name', ascending: true);

      final List<dynamic> data = response as List<dynamic>;

      return data.map((json) => Category.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching categories: $e');
      // Return default categories as fallback
      return _getDefaultCategories();
    }
  }

  /// Create a new category
  Future<Category?> createCategory({
    required String name,
    String? color,
    String? icon,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('categories')
          .insert({
            'user_id': user.id,
            'name': name,
            'color': color,
            'icon': icon,
          })
          .select()
          .single();

      return Category.fromJson(response);
    } catch (e) {
      print('Error creating category: $e');
      return null;
    }
  }

  /// Update an existing category
  Future<Category?> updateCategory({
    required String categoryId,
    String? name,
    String? color,
    String? icon,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (color != null) updateData['color'] = color;
      if (icon != null) updateData['icon'] = icon;

      final response = await _client
          .from('categories')
          .update(updateData)
          .eq('id', categoryId)
          .eq('user_id', user.id)  // Ensure user owns this category
          .select()
          .single();

      return Category.fromJson(response);
    } catch (e) {
      print('Error updating category: $e');
      return null;
    }
  }

  /// Delete a category
  Future<bool> deleteCategory(String categoryId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _client
          .from('categories')
          .delete()
          .eq('id', categoryId)
          .eq('user_id', user.id);  // Ensure user owns this category

      return true;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }

  /// Get a single category by ID
  Future<Category?> getCategoryById(String categoryId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('categories')
          .select('*')
          .eq('id', categoryId)
          .eq('user_id', user.id)
          .single();

      return Category.fromJson(response);
    } catch (e) {
      print('Error fetching category: $e');
      return null;
    }
  }

  /// Create default categories for a new user
  Future<void> createDefaultCategoriesForUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Call the Supabase function to create default categories
      await _client.rpc('create_default_categories', params: {
        'user_uuid': user.id,
      });
    } catch (e) {
      print('Error creating default categories: $e');
      // Try to create them manually as fallback
      for (final categoryData in DefaultCategories.categories) {
        await createCategory(
          name: categoryData['name']!,
          color: categoryData['color'],
          icon: categoryData['icon'],
        );
      }
    }
  }

  /// Get default categories (for offline mode or fallback)
  List<Category> _getDefaultCategories() {
    final user = _client.auth.currentUser;
    final userId = user?.id ?? 'offline';

    return DefaultCategories.categories.map((data) {
      return Category(
        id: 'default_${data['name']?.toLowerCase().replaceAll(' ', '_')}',
        userId: userId,
        name: data['name']!,
        color: data['color'],
        icon: data['icon'],
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  /// Search categories by name
  Future<List<Category>> searchCategories(String query) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('categories')
          .select('*')
          .eq('user_id', user.id)
          .ilike('name', '%$query%')
          .order('name', ascending: true);

      final List<dynamic> data = response as List<dynamic>;

      return data.map((json) => Category.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error searching categories: $e');
      return [];
    }
  }
}