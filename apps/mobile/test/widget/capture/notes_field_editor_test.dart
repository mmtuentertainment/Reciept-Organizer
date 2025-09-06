import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/features/capture/widgets/notes_field_editor.dart';

void main() {
  group('NotesFieldEditor', () {
    Widget buildTestWidget({
      String? initialValue,
      ValueChanged<String>? onChanged,
      bool enabled = true,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: NotesFieldEditor(
            initialValue: initialValue,
            onChanged: onChanged ?? (_) {},
            enabled: enabled,
          ),
        ),
      );
    }

    testWidgets('should display initial value', (WidgetTester tester) async {
      // Given
      const initialValue = 'Test notes content';
      
      // When
      await tester.pumpWidget(buildTestWidget(initialValue: initialValue));
      
      // Then
      expect(find.text(initialValue), findsOneWidget);
    });

    testWidgets('should show hint text when empty', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(buildTestWidget());
      
      // Then
      expect(find.text('Add notes about this receipt...'), findsOneWidget);
    });

    testWidgets('should show character counter', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(buildTestWidget());
      
      // Then
      expect(find.text('0 / 500'), findsOneWidget);
    });

    testWidgets('should update character counter as user types', (WidgetTester tester) async {
      // Given
      String? capturedText;
      await tester.pumpWidget(buildTestWidget(
        onChanged: (text) => capturedText = text,
      ));
      
      // When
      await tester.enterText(find.byType(TextFormField), 'Hello world');
      await tester.pump();
      
      // Then
      expect(find.text('11 / 500'), findsOneWidget);
      expect(capturedText, equals('Hello world'));
    });

    testWidgets('should enforce character limit', (WidgetTester tester) async {
      // Given
      final longText = 'a' * 600; // More than 500 characters
      await tester.pumpWidget(buildTestWidget());
      
      // When
      await tester.enterText(find.byType(TextFormField), longText);
      await tester.pump();
      
      // Then
      expect(find.text('500 / 500'), findsOneWidget);
      
      // Verify the text was truncated
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.controller!.text.length, equals(500));
    });

    testWidgets('should show error color when at character limit', (WidgetTester tester) async {
      // Given
      final maxText = 'a' * 500;
      await tester.pumpWidget(buildTestWidget());
      
      // When
      await tester.enterText(find.byType(TextFormField), maxText);
      await tester.pump();
      
      // Then
      final counterText = tester.widget<Text>(
        find.text('500 / 500'),
      );
      expect(counterText.style!.color, equals(Theme.of(tester.element(find.byType(Text).first)).colorScheme.error));
    });

    testWidgets('should be disabled when enabled is false', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(buildTestWidget(enabled: false));
      
      // Then
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.enabled, isFalse);
      
      // Verify the field shows disabled styling
      expect(textField.decoration!.filled, isTrue);
    });

    testWidgets('should call onChanged callback when text changes', (WidgetTester tester) async {
      // Given
      final changedTexts = <String>[];
      await tester.pumpWidget(buildTestWidget(
        onChanged: changedTexts.add,
      ));
      
      // When
      await tester.enterText(find.byType(TextFormField), 'First');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), 'First Second');
      await tester.pump();
      
      // Then
      expect(changedTexts, equals(['First', 'First Second']));
    });

    testWidgets('should support multiline input', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(buildTestWidget());
      
      // Then
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.maxLines, equals(3));
      expect(textField.keyboardType, equals(TextInputType.multiline));
    });

    testWidgets('should show Notes label', (WidgetTester tester) async {
      // When
      await tester.pumpWidget(buildTestWidget());
      
      // Then
      expect(find.text('Notes'), findsOneWidget);
    });

    group('Input Sanitization', () {
      testWidgets('should remove control characters', (WidgetTester tester) async {
        // Given
        final changedTexts = <String>[];
        await tester.pumpWidget(buildTestWidget(
          onChanged: changedTexts.add,
        ));
        
        // When - Enter text with null byte and control characters
        await tester.enterText(find.byType(TextFormField), 'Test\x00\x01\x1FNotes');
        await tester.pump();
        
        // Then - Control characters should be removed
        expect(changedTexts.last, equals('TestNotes'));
        expect(find.text('TestNotes'), findsOneWidget);
      });

      testWidgets('should preserve legitimate newlines and tabs', (WidgetTester tester) async {
        // Given
        final changedTexts = <String>[];
        await tester.pumpWidget(buildTestWidget(
          onChanged: changedTexts.add,
        ));
        
        // When
        await tester.enterText(find.byType(TextFormField), 'Line 1\nLine 2\tTabbed');
        await tester.pump();
        
        // Then
        expect(changedTexts.last, equals('Line 1\nLine 2\tTabbed'));
      });

      testWidgets('should remove script tags', (WidgetTester tester) async {
        // Given
        final changedTexts = <String>[];
        await tester.pumpWidget(buildTestWidget(
          onChanged: changedTexts.add,
        ));
        
        // When
        await tester.enterText(find.byType(TextFormField), 'Normal text <script>alert("test")</script> more text');
        await tester.pump();
        
        // Then
        expect(changedTexts.last, equals('Normal text  more text'));
      });

      testWidgets('should remove javascript: URLs', (WidgetTester tester) async {
        // Given
        final changedTexts = <String>[];
        await tester.pumpWidget(buildTestWidget(
          onChanged: changedTexts.add,
        ));
        
        // When
        await tester.enterText(find.byType(TextFormField), 'Click javascript:void(0) here');
        await tester.pump();
        
        // Then
        expect(changedTexts.last, equals('Click void(0) here'));
      });

      testWidgets('should normalize excessive whitespace', (WidgetTester tester) async {
        // Given
        final changedTexts = <String>[];
        await tester.pumpWidget(buildTestWidget(
          onChanged: changedTexts.add,
        ));
        
        // When - Multiple newlines and spaces
        await tester.enterText(find.byType(TextFormField), 'Text\n\n\n\nwith     spaces');
        await tester.pump();
        
        // Then - Should normalize to max 2 newlines and 2 spaces
        expect(changedTexts.last, equals('Text\n\nwith  spaces'));
      });

      testWidgets('should handle normal text without modification', (WidgetTester tester) async {
        // Given
        final changedTexts = <String>[];
        await tester.pumpWidget(buildTestWidget(
          onChanged: changedTexts.add,
        ));
        
        // When
        const normalText = 'This is a normal receipt note with $50.00 and #tags!';
        await tester.enterText(find.byType(TextFormField), normalText);
        await tester.pump();
        
        // Then
        expect(changedTexts.last, equals(normalText));
      });
    });
  });
}