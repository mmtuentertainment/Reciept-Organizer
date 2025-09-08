#!/bin/bash

echo "Fixing @GenerateNiceMocks to use MockSpec format..."

# List of files to fix
test_files=(
    "test/unit/services/ocr_service_retry_test.dart"
    "test/widget/capture/preview_screen_integration_test.dart"
    "test/widget/capture/preview_screen_test.dart"
    "test/domain/services/security_manager_test.dart"
    "test/integration/capture_retry_flow_test.dart"
    "test/mocks/mock_text_recognizer.dart"
    "test/providers/batch_capture_provider_test.dart"
    "test/performance/date_range_selection_performance_test.dart"
    "test/unit/providers/capture_provider_test.dart"
    "test/unit/capture/batch_capture_notifier_test.dart"
    "test/widget/capture/batch_capture_screen_test.dart"
)

# First, add MockSpec import where needed
for file in "${test_files[@]}"; do
    if [ -f "$file" ]; then
        # Check if MockSpec import is already there
        if ! grep -q "MockSpec" "$file"; then
            # Add MockSpec import after mockito/annotations.dart import
            sed -i '/import.*mockito\/annotations\.dart/a import '\''package:mockito/mockito.dart'\'';' "$file"
        fi
    fi
done

# Now fix the annotations
echo "Updating annotations to MockSpec format..."

# Simple cases with single class
sed -i 's/@GenerateNiceMocks(\[\([A-Za-z0-9_]*\)\])/@GenerateNiceMocks([MockSpec<\1>()])/g' test/providers/batch_capture_provider_test.dart
sed -i 's/@GenerateNiceMocks(\[\([A-Za-z0-9_]*\)\])/@GenerateNiceMocks([MockSpec<\1>()])/g' test/performance/date_range_selection_performance_test.dart
sed -i 's/@GenerateNiceMocks(\[\([A-Za-z0-9_]*\)\])/@GenerateNiceMocks([MockSpec<\1>()])/g' test/unit/capture/batch_capture_notifier_test.dart
sed -i 's/@GenerateNiceMocks(\[\([A-Za-z0-9_]*\)\])/@GenerateNiceMocks([MockSpec<\1>()])/g' test/widget/capture/batch_capture_screen_test.dart
sed -i 's/@GenerateNiceMocks(\[\([A-Za-z0-9_]*\)\])/@GenerateNiceMocks([MockSpec<\1>()])/g' test/domain/services/security_manager_test.dart
sed -i 's/@GenerateNiceMocks(\[\([A-Za-z0-9_]*\)\])/@GenerateNiceMocks([MockSpec<\1>()])/g' test/unit/services/ocr_service_retry_test.dart

# Handle multi-line annotations manually
echo "Fixing multi-line annotations..."

# Fix preview_screen_test.dart
cat > /tmp/fix_preview_screen_test.dart << 'EOF'
@GenerateNiceMocks([
  MockSpec<CaptureNotifier>(),
])
EOF
perl -i -0pe 's/@GenerateNiceMocks\(\[\s*CaptureNotifier,?\s*\]\)/@GenerateNiceMocks([\n  MockSpec<CaptureNotifier>(),\n])/gs' test/widget/capture/preview_screen_test.dart

# Fix capture_provider_test.dart
cat > /tmp/fix_capture_provider_test.dart << 'EOF'
@GenerateNiceMocks([
  MockSpec<OCRService>(),
  MockSpec<ICameraService>(),
  MockSpec<RetrySessionManager>(),
])
EOF
perl -i -0pe 's/@GenerateNiceMocks\(\[\s*OCRService,\s*ICameraService,\s*RetrySessionManager,?\s*\]\)/@GenerateNiceMocks([\n  MockSpec<OCRService>(),\n  MockSpec<ICameraService>(),\n  MockSpec<RetrySessionManager>(),\n])/gs' test/unit/providers/capture_provider_test.dart

# Fix capture_retry_flow_test.dart
sed -i 's/@GenerateNiceMocks(\[TextRecognizer, ICameraService, RetrySessionManager\])/@GenerateNiceMocks([MockSpec<TextRecognizer>(), MockSpec<ICameraService>(), MockSpec<RetrySessionManager>()])/g' test/integration/capture_retry_flow_test.dart

# Fix preview_screen_integration_test.dart
sed -i 's/@GenerateNiceMocks(\[SharedPreferences, Directory\])/@GenerateNiceMocks([MockSpec<SharedPreferences>(), MockSpec<Directory>()])/g' test/widget/capture/preview_screen_integration_test.dart

# Fix mock_text_recognizer.dart - this one is more complex
cat > /tmp/fix_mock_text_recognizer.dart << 'EOF'
@GenerateNiceMocks([
  MockSpec<TextRecognizer>(),
  MockSpec<RecognizedText>(),
  MockSpec<TextBlock>(),
  MockSpec<TextLine>()
])
EOF
perl -i -0pe 's/@GenerateNiceMocks\(\[\s*TextRecognizer,\s*RecognizedText,\s*TextBlock,\s*TextLine\s*\]\)/@GenerateNiceMocks([\n  MockSpec<TextRecognizer>(),\n  MockSpec<RecognizedText>(),\n  MockSpec<TextBlock>(),\n  MockSpec<TextLine>()\n])/gs' test/mocks/mock_text_recognizer.dart

echo "Done! All annotations updated to use MockSpec format"