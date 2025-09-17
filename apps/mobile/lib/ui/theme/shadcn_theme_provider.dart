import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Provider for current theme mode
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Provider for shadcn theme configuration
final shadcnThemeProvider = Provider<ShadThemeData>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  final brightness = themeMode == ThemeMode.dark
      ? Brightness.dark
      : themeMode == ThemeMode.light
          ? Brightness.light
          : WidgetsBinding.instance.platformDispatcher.platformBrightness;

  return ShadThemeData(
    brightness: brightness,
    colorScheme: const ShadSlateColorScheme.light(),
  );
});

/// Custom color scheme for Receipt Organizer
class ReceiptColors {
  // Brand colors
  static const Color primary = Color(0xFF0F172A); // Slate 900
  static const Color primaryLight = Color(0xFF475569); // Slate 600
  static const Color secondary = Color(0xFF3B82F6); // Blue 500
  static const Color secondaryLight = Color(0xFF60A5FA); // Blue 400

  // Status colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color info = Color(0xFF06B6D4); // Cyan 500

  // Receipt status colors
  static const Color pending = Color(0xFFFBBF24); // Yellow 400
  static const Color processing = Color(0xFF3B82F6); // Blue 500
  static const Color completed = Color(0xFF10B981); // Emerald 500
  static const Color failed = Color(0xFFEF4444); // Red 500

  // Neutral colors
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Dark mode colors
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color borderDark = Color(0xFF334155); // Slate 700
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFFCBD5E1); // Slate 300
  static const Color textMutedDark = Color(0xFF94A3B8); // Slate 400
}

/// Extension to provide shadcn theme in Material context
extension ShadThemeExtension on BuildContext {
  ShadThemeData get shadTheme {
    final container = ProviderScope.containerOf(this, listen: false);
    return container.read(shadcnThemeProvider);
  }

  bool get isDarkMode {
    final container = ProviderScope.containerOf(this, listen: false);
    final themeMode = container.read(themeModeProvider);

    return themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(this).platformBrightness == Brightness.dark);
  }

  /// Get receipt status color based on current theme
  Color getReceiptStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ReceiptColors.pending;
      case 'processing':
        return ReceiptColors.processing;
      case 'completed':
        return ReceiptColors.completed;
      case 'failed':
        return ReceiptColors.failed;
      default:
        return isDarkMode ? ReceiptColors.textMutedDark : ReceiptColors.textMuted;
    }
  }
}

/// Theme configuration class for bridging Material and shadcn
class AppTheme {
  /// Get Material theme that matches shadcn styling
  static ThemeData getMaterialTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ReceiptColors.primary,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: isDark ? ReceiptColors.backgroundDark : ReceiptColors.background,
      cardTheme: CardThemeData(
        color: isDark ? ReceiptColors.surfaceDark : ReceiptColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isDark ? ReceiptColors.borderDark : ReceiptColors.border,
            width: 1,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? ReceiptColors.surfaceDark : ReceiptColors.surface,
        foregroundColor: isDark ? ReceiptColors.textPrimaryDark : ReceiptColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ReceiptColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? ReceiptColors.backgroundDark : ReceiptColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: isDark ? ReceiptColors.borderDark : ReceiptColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: isDark ? ReceiptColors.borderDark : ReceiptColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: ReceiptColors.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: isDark ? ReceiptColors.textPrimaryDark : ReceiptColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: isDark ? ReceiptColors.textPrimaryDark : ReceiptColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: isDark ? ReceiptColors.textPrimaryDark : ReceiptColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: isDark ? ReceiptColors.textPrimaryDark : ReceiptColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: isDark ? ReceiptColors.textPrimaryDark : ReceiptColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: isDark ? ReceiptColors.textSecondaryDark : ReceiptColors.textSecondary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: isDark ? ReceiptColors.textSecondaryDark : ReceiptColors.textSecondary,
          fontSize: 14,
        ),
        labelLarge: TextStyle(
          color: isDark ? ReceiptColors.textPrimaryDark : ReceiptColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? ReceiptColors.borderDark : ReceiptColors.border,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? ReceiptColors.surfaceDark : ReceiptColors.surface,
        side: BorderSide(
          color: isDark ? ReceiptColors.borderDark : ReceiptColors.border,
        ),
        labelStyle: TextStyle(
          color: isDark ? ReceiptColors.textSecondaryDark : ReceiptColors.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }
}