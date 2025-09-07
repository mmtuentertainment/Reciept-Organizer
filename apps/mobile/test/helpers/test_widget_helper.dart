import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared_preferences_test_helper.dart';

/// Helper to create a test widget with all necessary scaffolding
Widget createTestWidget({
  required Widget child,
  ProviderContainer? container,
  List<Override>? overrides,
  Map<String, Object>? initialPreferences,
}) {
  // Create container if not provided
  container ??= ProviderContainer(
    overrides: overrides ?? [
      if (initialPreferences != null)
        sharedPreferencesProvider.overrideWithValue(
          TestSharedPreferences()..setInitialValues(initialPreferences),
        ),
    ],
  );

  return ProviderScope(
    parent: container,
    child: MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

/// Helper for creating a basic test app without Riverpod
Widget createBasicTestApp({
  required Widget child,
  ThemeData? theme,
}) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(
      body: child,
    ),
  );
}

/// Helper to pump a widget with all necessary setup
Future<void> pumpTestWidget(
  WidgetTester tester, {
  required Widget child,
  ProviderContainer? container,
  List<Override>? overrides,
  Map<String, Object>? initialPreferences,
}) async {
  await tester.pumpWidget(
    createTestWidget(
      child: child,
      container: container,
      overrides: overrides,
      initialPreferences: initialPreferences,
    ),
  );
}

/// Helper to find text ignoring semantics
Finder findTextIgnoreSemantics(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is Text && widget.data == text,
  );
}

/// Helper to find rich text containing specific text
Finder findRichTextContaining(String text) {
  return find.byWidgetPredicate(
    (widget) {
      if (widget is RichText) {
        final textSpan = widget.text;
        if (textSpan is TextSpan) {
          return textSpan.toPlainText().contains(text);
        }
      }
      return false;
    },
  );
}