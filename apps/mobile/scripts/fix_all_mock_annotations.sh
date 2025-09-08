#!/bin/bash

echo "Fixing all @GenerateNiceMocks annotations..."

# Fix preview_screen_test.dart - already done

# Fix widget/capture/preview_screen_integration_test.dart
echo "Fixing preview_screen_integration_test.dart..."
sed -i 's/@GenerateNiceMocks(\[SharedPreferences, Directory\])/@GenerateNiceMocks([MockSpec<SharedPreferences>(), MockSpec<Directory>()])/g' test/widget/capture/preview_screen_integration_test.dart

# Fix domain/services/security_manager_test.dart
echo "Fixing security_manager_test.dart..."
sed -i 's/@GenerateNiceMocks(\[Directory\])/@GenerateNiceMocks([MockSpec<Directory>()])/g' test/domain/services/security_manager_test.dart

# Fix integration/capture_retry_flow_test.dart
echo "Fixing capture_retry_flow_test.dart..."
sed -i 's/@GenerateNiceMocks(\[TextRecognizer, ICameraService, RetrySessionManager\])/@GenerateNiceMocks([MockSpec<ICameraService>(), MockSpec<RetrySessionManager>()])/g' test/integration/capture_retry_flow_test.dart
# Also need to import manual mocks for TextRecognizer
sed -i '/import.*capture_retry_flow_test.mocks.dart.*;/a import '\''../mocks/mock_text_recognizer.dart'\'';' test/integration/capture_retry_flow_test.dart

# Fix providers/batch_capture_provider_test.dart
echo "Fixing batch_capture_provider_test.dart..."
sed -i 's/@GenerateNiceMocks(\[ICameraService\])/@GenerateNiceMocks([MockSpec<ICameraService>()])/g' test/providers/batch_capture_provider_test.dart

# Fix performance/date_range_selection_performance_test.dart
echo "Fixing date_range_selection_performance_test.dart..."
sed -i 's/@GenerateNiceMocks(\[IReceiptRepository\])/@GenerateNiceMocks([MockSpec<IReceiptRepository>()])/g' test/performance/date_range_selection_performance_test.dart

# Fix unit/providers/capture_provider_test.dart
echo "Fixing capture_provider_test.dart..."
perl -i -0pe 's/@GenerateNiceMocks\(\[\s*OCRService,\s*ICameraService,\s*RetrySessionManager,?\s*\]\)/@GenerateNiceMocks([\n  MockSpec<OCRService>(),\n  MockSpec<ICameraService>(),\n  MockSpec<RetrySessionManager>(),\n])/gs' test/unit/providers/capture_provider_test.dart

# Fix unit/capture/batch_capture_notifier_test.dart
echo "Fixing batch_capture_notifier_test.dart..."
sed -i 's/@GenerateNiceMocks(\[ICameraService\])/@GenerateNiceMocks([MockSpec<ICameraService>()])/g' test/unit/capture/batch_capture_notifier_test.dart

# Fix widget/capture/batch_capture_screen_test.dart
echo "Fixing batch_capture_screen_test.dart..."
sed -i 's/@GenerateNiceMocks(\[ICameraService\])/@GenerateNiceMocks([MockSpec<ICameraService>()])/g' test/widget/capture/batch_capture_screen_test.dart

echo "All annotations updated!"