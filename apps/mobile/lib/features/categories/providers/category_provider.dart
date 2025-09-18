import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/category.dart';
import '../../../domain/services/category_service.dart';

/// Provider for the CategoryService
final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});

/// Provider for fetching all user categories
final userCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final service = ref.watch(categoryServiceProvider);
  return await service.getUserCategories();
});

/// Provider for searching categories
final categorySearchProvider = FutureProvider.family<List<Category>, String>((ref, query) async {
  final service = ref.watch(categoryServiceProvider);

  if (query.isEmpty) {
    return await service.getUserCategories();
  }

  return await service.searchCategories(query);
});

/// Provider for a single category by ID
final categoryByIdProvider = FutureProvider.family<Category?, String>((ref, categoryId) async {
  final service = ref.watch(categoryServiceProvider);
  return await service.getCategoryById(categoryId);
});

/// State notifier for managing selected category
class SelectedCategoryNotifier extends StateNotifier<Category?> {
  SelectedCategoryNotifier() : super(null);

  void selectCategory(Category? category) {
    state = category;
  }

  void clearSelection() {
    state = null;
  }
}

/// Provider for managing selected category state
final selectedCategoryProvider = StateNotifierProvider<SelectedCategoryNotifier, Category?>((ref) {
  return SelectedCategoryNotifier();
});

/// Provider for managing category CRUD operations with state
class CategoryManagementNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final CategoryService _service;
  final Ref _ref;

  CategoryManagementNotifier(this._service, this._ref) : super(const AsyncLoading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = const AsyncLoading();
    try {
      final categories = await _service.getUserCategories();
      state = AsyncData(categories);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<bool> createCategory({
    required String name,
    String? color,
    String? icon,
  }) async {
    try {
      final newCategory = await _service.createCategory(
        name: name,
        color: color,
        icon: icon,
      );

      if (newCategory != null) {
        // Reload categories to get the updated list
        await loadCategories();
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating category: $e');
      return false;
    }
  }

  Future<bool> updateCategory({
    required String categoryId,
    String? name,
    String? color,
    String? icon,
  }) async {
    try {
      final updatedCategory = await _service.updateCategory(
        categoryId: categoryId,
        name: name,
        color: color,
        icon: icon,
      );

      if (updatedCategory != null) {
        // Reload categories to get the updated list
        await loadCategories();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating category: $e');
      return false;
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    try {
      final success = await _service.deleteCategory(categoryId);

      if (success) {
        // Reload categories to get the updated list
        await loadCategories();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }

  Future<void> createDefaultCategories() async {
    try {
      await _service.createDefaultCategoriesForUser();
      await loadCategories();
    } catch (e) {
      print('Error creating default categories: $e');
    }
  }
}

/// Provider for category management with CRUD operations
final categoryManagementProvider = StateNotifierProvider<CategoryManagementNotifier, AsyncValue<List<Category>>>((ref) {
  final service = ref.watch(categoryServiceProvider);
  return CategoryManagementNotifier(service, ref);
});

/// Provider for category names list (useful for dropdowns)
final categoryNamesProvider = Provider<List<String>>((ref) {
  final categoriesAsync = ref.watch(categoryManagementProvider);

  return categoriesAsync.when(
    data: (categories) => categories.map((c) => c.name).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for finding a category by name
final categoryByNameProvider = Provider.family<Category?, String>((ref, name) {
  final categoriesAsync = ref.watch(categoryManagementProvider);

  return categoriesAsync.when(
    data: (categories) => categories.firstWhere(
      (c) => c.name == name,
      orElse: () => Category(
        id: 'unknown',
        userId: 'unknown',
        name: name,
        createdAt: DateTime.now(),
      ),
    ),
    loading: () => null,
    error: (_, __) => null,
  );
});