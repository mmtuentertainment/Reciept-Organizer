import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/category.dart';
import '../../../ui/components/shad/shad_components.dart';
import '../../../ui/responsive/responsive_builder.dart';
import '../../../ui/theme/shadcn_theme_provider.dart';
import '../providers/category_provider.dart';

/// Categories management screen
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryManagementProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(categoryManagementProvider.notifier).loadCategories();
            },
          ),
        ],
      ),
      body: ResponsiveBuilder(
        mobile: _buildMobileLayout(context, ref, categoriesAsync),
        tablet: _buildTabletLayout(context, ref, categoriesAsync),
        desktop: _buildDesktopLayout(context, ref, categoriesAsync),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateCategoryDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Category>> categoriesAsync,
  ) {
    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return _buildEmptyState(context, ref);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return _buildCategoryCard(context, ref, categories[index]);
          },
        );
      },
      loading: () => const AppListSkeleton(),
      error: (error, _) => Center(
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: ReceiptColors.error),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              AppButton(
                onPressed: () {
                  ref.read(categoryManagementProvider.notifier).loadCategories();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Category>> categoriesAsync,
  ) {
    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return _buildEmptyState(context, ref);
        }

        return AdaptiveGrid(
          padding: const EdgeInsets.all(16),
          mobileColumns: 1,
          tabletColumns: 2,
          desktopColumns: 3,
          children: categories
              .map((category) => _buildCategoryCard(context, ref, category))
              .toList(),
        );
      },
      loading: () => const AppListSkeleton(),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Category>> categoriesAsync,
  ) {
    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return _buildEmptyState(context, ref);
        }

        return AdaptiveGrid(
          padding: const EdgeInsets.all(24),
          mobileColumns: 2,
          tabletColumns: 3,
          desktopColumns: 4,
          children: categories
              .map((category) => _buildCategoryCard(context, ref, category))
              .toList(),
        );
      },
      loading: () => const AppListSkeleton(),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildCategoryCard(BuildContext context, WidgetRef ref, Category category) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: category.colorValue?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category.iconData,
                  color: category.colorValue ?? ReceiptColors.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Created ${_formatDate(category.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: ReceiptColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditCategoryDialog(context, ref, category);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context, ref, category);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: ReceiptColors.error),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: ReceiptColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: AppEmptyState(
        icon: Icons.category,
        title: 'No Categories',
        description: 'Create your first category to organize receipts',
        action: AppButton(
          onPressed: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Create Default Categories?'),
                content: const Text(
                  'Would you like to create default categories or start with a custom one?'
                ),
                actions: [
                  AppTextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Custom'),
                  ),
                  AppButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Default Categories'),
                  ),
                ],
              ),
            );

            if (result == true) {
              await ref.read(categoryManagementProvider.notifier).createDefaultCategories();
              showSuccessToast(context, 'Default categories created');
            } else if (result == false) {
              _showCreateCategoryDialog(context, ref);
            }
          },
          child: const Text('Get Started'),
        ),
      ),
    );
  }

  void _showCreateCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String selectedIcon = 'folder';
    String selectedColor = '#3B82F6';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Create New Category'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    label: 'Category Name',
                    placeholder: 'Enter category name',
                    controller: nameController,
                  ),
                  const SizedBox(height: 16),
                  _buildIconPicker(selectedIcon, (icon) {
                    setState(() => selectedIcon = icon);
                  }),
                  const SizedBox(height: 16),
                  _buildColorPicker(selectedColor, (color) {
                    setState(() => selectedColor = color);
                  }),
                ],
              ),
            ),
            actions: [
              AppTextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              AppButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    final success = await ref
                        .read(categoryManagementProvider.notifier)
                        .createCategory(
                          name: nameController.text,
                          icon: selectedIcon,
                          color: selectedColor,
                        );

                    if (success) {
                      Navigator.pop(context);
                      showSuccessToast(context, 'Category created successfully');
                    } else {
                      showErrorToast(context, 'Failed to create category');
                    }
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, WidgetRef ref, Category category) {
    final nameController = TextEditingController(text: category.name);
    String selectedIcon = category.icon ?? 'folder';
    String selectedColor = category.color ?? '#3B82F6';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Category'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    label: 'Category Name',
                    placeholder: 'Enter category name',
                    controller: nameController,
                  ),
                  const SizedBox(height: 16),
                  _buildIconPicker(selectedIcon, (icon) {
                    setState(() => selectedIcon = icon);
                  }),
                  const SizedBox(height: 16),
                  _buildColorPicker(selectedColor, (color) {
                    setState(() => selectedColor = color);
                  }),
                ],
              ),
            ),
            actions: [
              AppTextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              AppButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    final success = await ref
                        .read(categoryManagementProvider.notifier)
                        .updateCategory(
                          categoryId: category.id,
                          name: nameController.text,
                          icon: selectedIcon,
                          color: selectedColor,
                        );

                    if (success) {
                      Navigator.pop(context);
                      showSuccessToast(context, 'Category updated successfully');
                    } else {
                      showErrorToast(context, 'Failed to update category');
                    }
                  }
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          AppTextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          AppButton(
            onPressed: () async {
              final success = await ref
                  .read(categoryManagementProvider.notifier)
                  .deleteCategory(category.id);

              Navigator.pop(context);

              if (success) {
                showSuccessToast(context, 'Category deleted successfully');
              } else {
                showErrorToast(context, 'Failed to delete category');
              }
            },
            isDestructive: true,
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildIconPicker(String selectedIcon, ValueChanged<String> onIconSelected) {
    final icons = [
      'folder', 'utensils', 'plane', 'briefcase',
      'laptop', 'megaphone', 'user-tie', 'wrench', 'zap'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Icon',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: icons.map((icon) {
            final isSelected = icon == selectedIcon;
            return InkWell(
              onTap: () => onIconSelected(icon),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? ReceiptColors.primary : ReceiptColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconData(icon),
                  size: 24,
                  color: isSelected ? ReceiptColors.primary : ReceiptColors.textSecondary,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorPicker(String selectedColor, ValueChanged<String> onColorSelected) {
    final colors = [
      '#3B82F6', '#10B981', '#8B5CF6', '#F59E0B',
      '#EF4444', '#6B7280', '#9333EA', '#14B8A6', '#64748B'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) {
            final isSelected = color == selectedColor;
            return InkWell(
              onTap: () => onColorSelected(color),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Color(int.parse('FF${color.replaceAll('#', '')}', radix: 16)),
                  border: Border.all(
                    color: isSelected ? ReceiptColors.primary : ReceiptColors.border,
                    width: isSelected ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getIconData(String icon) {
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
      default:
        return Icons.folder;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }
}