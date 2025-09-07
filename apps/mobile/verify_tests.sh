#!/bin/bash

echo "=== Verifying Test Structure ==="
echo "Checking for test files..."
find test -name "*.dart" -type f | wc -l

echo ""
echo "=== Checking Import Dependencies ==="
echo "Checking preview_screen_test.dart imports..."

# Check if all imported files exist
while IFS= read -r import; do
    # Extract the path from the import statement
    path=$(echo "$import" | grep -oP "(?<=').*(?=')" || echo "$import" | grep -oP '(?<=").*(?=")')
    
    if [[ $path == package:receipt_organizer/* ]]; then
        # Convert package import to file path
        file_path="lib/${path#package:receipt_organizer/}"
        if [[ -f "$file_path" ]]; then
            echo "✓ Found: $file_path"
        else
            echo "✗ Missing: $file_path"
        fi
    elif [[ $path == *.dart ]]; then
        # Relative import
        test_dir="test/widget/capture"
        resolved_path="$test_dir/$path"
        # Resolve relative paths
        resolved_path=$(cd "$test_dir" && realpath -m "$path" 2>/dev/null || echo "$path")
        if [[ -f "$resolved_path" ]]; then
            echo "✓ Found: $resolved_path"
        else
            echo "✗ Missing: $resolved_path"
        fi
    fi
done < <(grep "^import" test/widget/capture/preview_screen_test.dart)

echo ""
echo "=== Checking Test Structure ==="
echo "Analyzing test/widget/capture/preview_screen_test.dart..."

# Count test groups and individual tests
groups=$(grep -c "^\s*group(" test/widget/capture/preview_screen_test.dart || echo 0)
tests=$(grep -c "^\s*testWidgets(" test/widget/capture/preview_screen_test.dart || echo 0)

echo "Found $groups test groups"
echo "Found $tests individual tests"

echo ""
echo "=== Checking for Common Issues ==="

# Check for missing semicolons
missing_semicolons=$(grep -n "[^;]$" test/widget/capture/preview_screen_test.dart | grep -v -E "(//|{|\s*$)" | wc -l)
if [[ $missing_semicolons -gt 0 ]]; then
    echo "⚠ Potential missing semicolons found"
else
    echo "✓ No obvious missing semicolons"
fi

# Check for unmatched brackets
open_brackets=$(grep -o "[({[]" test/widget/capture/preview_screen_test.dart | wc -l)
close_brackets=$(grep -o "[)}]]" test/widget/capture/preview_screen_test.dart | wc -l)
if [[ $open_brackets -eq $close_brackets ]]; then
    echo "✓ Brackets appear balanced ($open_brackets open, $close_brackets close)"
else
    echo "⚠ Unbalanced brackets: $open_brackets open, $close_brackets close"
fi

echo ""
echo "=== Mock Files Status ==="
if [[ -f "test/widget/capture/preview_screen_test.mocks.dart" ]]; then
    echo "✓ Mock file exists"
    lines=$(wc -l < test/widget/capture/preview_screen_test.mocks.dart)
    echo "  Contains $lines lines"
else
    echo "✗ Mock file missing - needs to be generated"
fi

echo ""
echo "=== Summary ==="
echo "To run tests, use: flutter test test/widget/capture/preview_screen_test.dart"
echo "To generate mocks: flutter pub run build_runner build --delete-conflicting-outputs"