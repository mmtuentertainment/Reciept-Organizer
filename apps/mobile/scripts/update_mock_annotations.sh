#\!/bin/bash

echo "Updating mock generation annotations from @GenerateMocks to @GenerateNiceMocks..."

# Find all test files with @GenerateMocks and update them
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

updated_count=0

for file in "${test_files[@]}"; do
    if [ -f "$file" ]; then
        # Replace @GenerateMocks with @GenerateNiceMocks
        sed -i 's/@GenerateMocks(/@GenerateNiceMocks(/g' "$file"
        
        # Check if file was modified
        if grep -q "@GenerateNiceMocks" "$file"; then
            echo "✓ Updated: $file"
            ((updated_count++))
        fi
    else
        echo "⚠ File not found: $file"
    fi
done

echo ""
echo "Summary: Updated $updated_count files with @GenerateNiceMocks annotation"
echo "Next step: Run 'dart run build_runner build --delete-conflicting-outputs' to regenerate mocks"
EOF < /dev/null
