import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/features/capture/presentation/widgets/notes_field_editor.dart';

void main() {
  group('NotesFieldEditor Widget', () {
    testWidgets('displays initial value', (WidgetTester tester) async {
      // Given: Initial notes value
      const initialNotes = 'Test note';

      // When: Building widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotesFieldEditor(
              initialValue: initialNotes,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Then: Initial value is displayed
      expect(find.text(initialNotes), findsOneWidget);
    });

    testWidgets('shows character counter', (WidgetTester tester) async {
      // Given: Notes field
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotesFieldEditor(
              onChanged: (_) {},
              maxLength: 500,
            ),
          ),
        ),
      );

      // Then: Character counter is displayed
      expect(find.text('0/500'), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (WidgetTester tester) async {
      // Given: Notes field with callback
      String? capturedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotesFieldEditor(
              onChanged: (value) => capturedValue = value,
            ),
          ),
        ),
      );

      // When: Entering text
      await tester.enterText(find.byType(TextFormField), 'New note');
      await tester.pump();

      // Then: Callback is called with new value
      expect(capturedValue, equals('New note'));
    });

    testWidgets('displays hint text when empty', (WidgetTester tester) async {
      // Given: Empty notes field
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotesFieldEditor(
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Then: Hint text is displayed
      expect(find.text('Add notes about this receipt...'), findsOneWidget);
    });

    testWidgets('enforces max length', (WidgetTester tester) async {
      // Given: Notes field with max length
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotesFieldEditor(
              onChanged: (_) {},
              maxLength: 10,
            ),
          ),
        ),
      );

      // When: Entering text longer than max
      await tester.enterText(find.byType(TextFormField), 'This is a very long text');
      await tester.pump();

      // Then: Text is truncated to max length
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.controller?.text.length, lessThanOrEqualTo(10));
    });
  });
}