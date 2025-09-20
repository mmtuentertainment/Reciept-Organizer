import 'package:flutter/material.dart';

/// Theme provider stub
abstract class ThemeProvider extends ChangeNotifier {
  ThemeMode get themeMode;
  bool get isDarkMode;
  ThemeData get lightTheme;
  ThemeData get darkTheme;

  void toggleTheme();
  void setThemeMode(ThemeMode mode);
}