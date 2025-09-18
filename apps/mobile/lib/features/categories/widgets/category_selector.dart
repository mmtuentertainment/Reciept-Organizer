import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/category.dart';
import '../../../ui/components/shad/shad_components.dart';
import '../../../ui/theme/shadcn_theme_provider.dart';
import '../providers/category_provider.dart';

/// Category selector widget for receipt forms
class CategorySelector extends ConsumerWidget {
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;
  final bool showCreateOption;

  const CategorySelector({
    Key? key,
    this.selectedCategoryId,
    required this.onCategorySelected,
    this.showCreateOption = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryManagementProvider);

    return categoriesAsync.when(
      data: (categories) {
        final selectedCategory = categories.firstWhere(
          (cat) => cat.id == selectedCategoryId,
          orElse: () => categories.isNotEmpty ? categories.first : Category(
            id: '',
            userId: '',
            name: 'No categories',
            createdAt: DateTime.now(),
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showCategoryPicker(context, ref, categories),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: ReceiptColors.border),
                  borderRadius: BorderRadius.circular(8),
                  color: context.isDarkMode
                    ? ReceiptColors.surfaceDark
                    : ReceiptColors.surface,
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedCategory.iconData,
                      size: 20,
                      color: selectedCategory.colorValue ?? ReceiptColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedCategory.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ),
            ),
            if (showCreateOption) ...[
              const SizedBox(height: 8),
              AppTextButton(
                onPressed: () => _showCreateCategoryDialog(context, ref),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add, size: 16),
                    SizedBox(width: 4),
                    Text('Create new category', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const AppSkeleton(height: 48),
      error: (error, _) => AppCard(
        backgroundColor: ReceiptColors.error.withOpacity(0.1),
        child: Text('Error loading categories: $error'),
      ),
    );
  }

  void _showCategoryPicker(
    BuildContext context,
    WidgetRef ref,
    List<Category> categories,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.isDarkMode
        ? ReceiptColors.surfaceDark
        : ReceiptColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category.id == selectedCategoryId;

                  return ListTile(
                    leading: Icon(
                      category.iconData,
                      color: category.colorValue ?? ReceiptColors.textSecondary,
                    ),
                    title: Text(category.name),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: ReceiptColors.success)
                        : null,
                    selected: isSelected,
                    onTap: () {
                      onCategorySelected(category.id);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
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
}