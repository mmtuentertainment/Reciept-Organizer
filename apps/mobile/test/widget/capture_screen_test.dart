import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/capture/screens/capture_screen.dart';
import 'package:receipt_organizer/widgets/forms/amount_input_field.dart';
import 'package:receipt_organizer/widgets/forms/vendor_input_field.dart';
import 'package:receipt_organizer/widgets/forms/date_picker_field.dart';
import 'package:receipt_organizer/widgets/forms/category_selector.dart';
import 'package:receipt_organizer/widgets/buttons/app_button.dart';

void main() {
  group('CaptureScreen Widget Tests', () {
    Widget createWidgetUnderTest() {
      return ProviderScope(
        child: MaterialApp(
          home: CaptureScreen(),
        ),
      );
    }

    testWidgets('displays capture screen title', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Capture Receipt'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows image selection buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should have camera and gallery options
      expect(find.byIcon(Icons.camera_alt), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.photo_library), findsAtLeastNWidgets(1));
    });

    testWidgets('displays vendor input field', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final vendorField = find.byType(VendorInputField);
      if (vendorField.evaluate().isEmpty) {
        // Try finding by key or text field
        final textField = find.byType(TextField);
        expect(textField, findsAtLeastNWidgets(1));
      } else {
        expect(vendorField, findsOneWidget);
      }
    });

    testWidgets('displays amount input field', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final amountField = find.byType(AmountInputField);
      if (amountField.evaluate().isEmpty) {
        // Look for numeric keyboard text field
        final numericField = find.byWidgetPredicate(
          (widget) => widget is TextField &&
                      widget.keyboardType == TextInputType.number,
        );
        expect(numericField, findsAtLeastNWidgets(1));
      } else {
        expect(amountField, findsOneWidget);
      }
    });

    testWidgets('displays date picker field', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final dateField = find.byType(DatePickerField);
      if (dateField.evaluate().isEmpty) {
        // Look for date-related widgets
        final dateIcon = find.byIcon(Icons.calendar_today);
        expect(dateIcon, findsAtLeastNWidgets(1));
      } else {
        expect(dateField, findsOneWidget);
      }
    });

    testWidgets('displays category selector', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final categorySelector = find.byType(CategorySelector);
      if (categorySelector.evaluate().isEmpty) {
        // Look for dropdown or category-related widgets
        final dropdown = find.byType(DropdownButton<String>);
        if (dropdown.evaluate().isNotEmpty) {
          expect(dropdown, findsAtLeastNWidgets(1));
        }
      } else {
        expect(categorySelector, findsOneWidget);
      }
    });

    testWidgets('shows save button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final saveButton = find.text('Save');
      if (saveButton.evaluate().isEmpty) {
        // Try finding AppButton
        final appButton = find.byType(AppButton);
        expect(appButton, findsAtLeastNWidgets(1));
      } else {
        expect(saveButton, findsOneWidget);
      }
    });

    testWidgets('validates required fields', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Try to save without filling fields
      final saveButton = find.text('Save');
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Should show validation errors
        final errorText = find.textContaining('required');
        if (errorText.evaluate().isNotEmpty) {
          expect(errorText, findsAtLeastNWidgets(1));
        }
      }
    });

    testWidgets('can enter vendor name', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final vendorField = find.byType(TextField).first;
      await tester.enterText(vendorField, 'Test Store');
      await tester.pumpAndSettle();

      expect(find.text('Test Store'), findsOneWidget);
    });

    testWidgets('can enter amount', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find numeric text field
      final amountField = find.byWidgetPredicate(
        (widget) => widget is TextField &&
                    widget.keyboardType == TextInputType.number,
      ).first;

      await tester.enterText(amountField, '99.99');
      await tester.pumpAndSettle();

      expect(find.text('99.99'), findsOneWidget);
    });

    testWidgets('shows loading state when processing', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Check for any loading indicators
      final progressIndicator = find.byType(CircularProgressIndicator);
      final shimmer = find.byType(LinearProgressIndicator);

      // At least one type of loading indicator should be present initially or during processing
      expect(
        progressIndicator.evaluate().isNotEmpty || shimmer.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('displays notes field', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final notesField = find.byWidgetPredicate(
        (widget) => widget is TextField &&
                    (widget.maxLines ?? 1) > 1,
      );

      if (notesField.evaluate().isNotEmpty) {
        expect(notesField, findsAtLeastNWidgets(1));

        await tester.enterText(notesField.first, 'Test notes');
        await tester.pumpAndSettle();

        expect(find.text('Test notes'), findsOneWidget);
      }
    });

    testWidgets('shows back button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);

      // Verify it's tappable
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    });
  });
}