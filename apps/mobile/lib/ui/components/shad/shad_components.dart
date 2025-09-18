import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../theme/shadcn_theme_provider.dart';

/// Centralized shadcn component wrapper for consistent UI across the app
/// This file provides standardized shadcn components with app-specific theming

// ==================== BUTTONS ====================

/// Standard button with primary styling
class AppButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final bool isDestructive;
  final ShadButtonSize size;

  const AppButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.isDestructive = false,
    this.size = ShadButtonSize.regular,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return ShadButton(
      onPressed: isLoading ? null : onPressed,
      size: size,
      backgroundColor: isDestructive
          ? ReceiptColors.error
          : ReceiptColors.primary,
      child: isLoading
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : child,
    );
  }
}

/// Outline button variant
class AppOutlineButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final ShadButtonSize size;

  const AppOutlineButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.size = ShadButtonSize.regular,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadButton.outline(
      onPressed: isLoading ? null : onPressed,
      size: size,
      child: isLoading
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : child,
    );
  }
}

/// Text-only button variant
class AppTextButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ShadButtonSize size;

  const AppTextButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.size = ShadButtonSize.regular,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadButton.ghost(
      onPressed: onPressed,
      size: size,
      child: child,
    );
  }
}

// ==================== CARDS ====================

/// Standard card component with consistent styling
class AppCard extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;

  const AppCard({
    Key? key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;

    return ShadCard(
      backgroundColor: backgroundColor ??
          (isDark ? ReceiptColors.surfaceDark : ReceiptColors.surface),
      padding: padding ?? const EdgeInsets.all(16),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: child,
            )
          : child,
    );
  }
}

// ==================== INPUT FIELDS ====================

/// Standard text input field
class AppTextField extends ConsumerWidget {
  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    Key? key,
    this.label,
    this.placeholder,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        ShadInput(
          controller: controller,
          placeholder: placeholder != null ? Text(placeholder!) : null,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// ==================== DIALOGS ====================

/// Standard dialog/modal component
class AppDialog extends ConsumerWidget {
  final String? title;
  final String? description;
  final Widget content;
  final List<Widget>? actions;

  const AppDialog({
    Key? key,
    this.title,
    this.description,
    required this.content,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadDialog(
      title: title != null ? Text(title!) : null,
      description: description != null ? Text(description!) : null,
      child: content,
      actions: actions ?? [],
    );
  }
}

// ==================== TOASTS ====================

/// Show success toast
void showSuccessToast(BuildContext context, String message) {
  ShadToaster.of(context).show(
    ShadToast(
      title: Text(message),
      backgroundColor: ReceiptColors.success,
    ),
  );
}

/// Show error toast
void showErrorToast(BuildContext context, String message) {
  ShadToaster.of(context).show(
    ShadToast.destructive(
      title: Text(message),
      backgroundColor: ReceiptColors.error,
    ),
  );
}

/// Show info toast
void showInfoToast(BuildContext context, String message) {
  ShadToaster.of(context).show(
    ShadToast(
      title: Text(message),
      backgroundColor: ReceiptColors.info,
    ),
  );
}

// ==================== SELECT/DROPDOWN ====================

/// Standard select/dropdown component
class AppSelect<T> extends ConsumerWidget {
  final T? value;
  final List<AppSelectItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? label;
  final String? placeholder;

  const AppSelect({
    Key? key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.placeholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        ShadSelect<T>(
          placeholder: placeholder != null ? Text(placeholder!) : null,
          onChanged: onChanged,
          options: items.map((item) => ShadOption(
            value: item.value,
            child: item.child,
          )).toList(),
          selectedOptionBuilder: (context, value) {
            final selectedItem = items.firstWhere(
              (item) => item.value == value,
              orElse: () => items.first,
            );
            return selectedItem.child;
          },
        ),
      ],
    );
  }
}

/// Item for AppSelect
class AppSelectItem<T> {
  final T value;
  final Widget child;

  const AppSelectItem({
    required this.value,
    required this.child,
  });
}

// ==================== LOADING STATES ====================

/// Skeleton loading component
class AppSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const AppSkeleton({
    Key? key,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 20,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
      child: const ShadBadge(
        child: SizedBox(),
      ),
    );
  }
}

/// Loading skeleton for list items
class AppListSkeleton extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;

  const AppListSkeleton({
    Key? key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => AppSkeleton(
        height: itemHeight,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

// ==================== BADGES ====================

/// Standard badge component
class AppBadge extends ConsumerWidget {
  final Widget child;
  final Color? backgroundColor;
  final BadgeVariant variant;

  const AppBadge({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.variant = BadgeVariant.primary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color bgColor;
    switch (variant) {
      case BadgeVariant.success:
        bgColor = ReceiptColors.success;
        break;
      case BadgeVariant.warning:
        bgColor = ReceiptColors.warning;
        break;
      case BadgeVariant.error:
        bgColor = ReceiptColors.error;
        break;
      case BadgeVariant.info:
        bgColor = ReceiptColors.info;
        break;
      case BadgeVariant.primary:
        bgColor = backgroundColor ?? ReceiptColors.primary;
    }

    return ShadBadge(
      backgroundColor: bgColor,
      child: child,
    );
  }
}

enum BadgeVariant {
  primary,
  success,
  warning,
  error,
  info,
}

// ==================== EMPTY STATES ====================

/// Standard empty state component
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Widget? action;

  const AppEmptyState({
    Key? key,
    required this.icon,
    required this.title,
    this.description,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: ReceiptColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: ReceiptColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ==================== ERROR BOUNDARIES ====================

/// Error boundary widget for graceful error handling
class AppErrorBoundary extends StatelessWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stack)? errorBuilder;

  const AppErrorBoundary({
    Key? key,
    required this.child,
    this.errorBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          if (errorBuilder != null) {
            return errorBuilder!(details.exception, details.stack);
          }

          return AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: ReceiptColors.error,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  details.exception.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: ReceiptColors.textMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                AppButton(
                  onPressed: () {
                    // Trigger rebuild
                    (context as Element).markNeedsBuild();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        };

        return child;
      },
    );
  }
}

