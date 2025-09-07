import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/main.dart';
import 'package:receipt_organizer/features/receipts/presentation/providers/image_viewer_provider.dart' as img_provider;
import 'helpers/shared_preferences_test_helper.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // Initialize test SharedPreferences
    final testPrefs = TestSharedPreferences();
    
    // Build the app
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          img_provider.sharedPreferencesProvider.overrideWithValue(testPrefs),
        ],
        child: const ReceiptOrganizerApp(),
      ),
    );
    
    // App should show home screen
    expect(find.text('Receipt Organizer'), findsOneWidget);
    expect(find.text('Receipt Organizer MVP'), findsOneWidget);
    expect(find.text('Capture Receipt'), findsOneWidget);
    expect(find.text('View Receipts'), findsOneWidget);
    
    // Verify app started without crashing - that's the main goal
    // Don't test navigation as it may have camera permission dialogs or animations
  });
}