#!/bin/bash

# Mid-Development Audit Script for Receipt Organizer MVP
# Date: January 2025
# This script performs comprehensive validation checks on the current development state

set -e

echo "================================================"
echo "Receipt Organizer MVP - Mid-Development Audit"
echo "Date: $(date)"
echo "================================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
        return 1
    fi
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Navigate to mobile app directory
cd "$(dirname "$0")/.."

echo "1. FLUTTER ENVIRONMENT CHECK"
echo "=============================="
flutter --version
echo ""

echo "2. DEPENDENCY AUDIT"
echo "==================="
echo "Checking Flutter dependencies..."
flutter pub outdated || print_warning "Some dependencies may be outdated"
echo ""

echo "3. CODE ANALYSIS"
echo "================"
echo "Running Flutter analyze..."
flutter analyze --no-fatal-infos || print_warning "Code analysis found issues"
echo ""

echo "4. TEST EXECUTION"
echo "================="
echo "Running unit tests..."
flutter test --coverage || print_warning "Some tests failed"
echo ""

echo "5. COVERAGE REPORT"
echo "=================="
if [ -d "coverage" ]; then
    echo "Coverage data found. Generating report..."
    if command -v lcov &> /dev/null; then
        lcov --summary coverage/lcov.info 2>/dev/null || print_warning "Could not generate coverage summary"
    else
        print_warning "lcov not installed. Install it to see coverage summary"
    fi
else
    print_warning "No coverage data found. Run 'flutter test --coverage' first"
fi
echo ""

echo "6. SECURITY CHECKS"
echo "=================="
echo "Checking for CSV injection prevention..."
grep -r "sanitize\|escape\|quote" lib/domain/services/csv_export_service.dart &>/dev/null && \
    print_status 0 "CSV sanitization code found" || \
    print_status 1 "CSV sanitization code NOT found - HIGH PRIORITY"
echo ""

echo "7. FEATURE VALIDATION"
echo "====================="
# Check for key features based on stories
features=(
    "lib/features/capture/presentation/pages/batch_capture_screen.dart:Batch capture"
    "lib/domain/services/edge_detection_service.dart:Edge detection"
    "lib/features/receipts/presentation/widgets/confidence_indicator.dart:Confidence scores"
    "lib/domain/services/merchant_normalization_service.dart:Merchant normalization"
    "lib/features/export/presentation/widgets/format_selection.dart:CSV format options"
    "lib/features/export/presentation/widgets/date_range_picker.dart:Date range selection"
)

for feature in "${features[@]}"; do
    IFS=':' read -r file desc <<< "$feature"
    if [ -f "$file" ]; then
        print_status 0 "$desc implemented"
    else
        print_status 1 "$desc NOT found"
    fi
done
echo ""

echo "8. BUILD VERIFICATION"
echo "===================="
echo "Attempting debug build..."
flutter build apk --debug --no-tree-shake-icons &>/dev/null && \
    print_status 0 "Debug build successful" || \
    print_status 1 "Debug build failed"
echo ""

echo "9. MOCK DATA VALIDATION"
echo "======================="
if [ -f "test/fixtures/merchant_test_data.dart" ]; then
    print_status 0 "Test fixtures found"
else
    print_status 1 "Test fixtures missing"
fi
echo ""

echo "10. PERFORMANCE BENCHMARKS"
echo "========================="
perf_tests=(
    "test/performance/date_range_selection_performance_test.dart"
    "test/performance/receipt_search_performance_test.dart"
    "test/benchmarks/merchant_normalization_performance_test.dart"
)

for test in "${perf_tests[@]}"; do
    if [ -f "$test" ]; then
        print_status 0 "$(basename $test) exists"
    else
        print_warning "$(basename $test) not found"
    fi
done
echo ""

echo "11. INTEGRATION TESTS"
echo "===================="
integration_tests=(
    "test/integration/batch_capture_flow_test.dart"
    "test/integration/capture_retry_flow_test.dart"
    "test/integration/merchant_normalization_flow_test.dart"
    "test/integration/notes_persistence_flow_test.dart"
)

for test in "${integration_tests[@]}"; do
    if [ -f "$test" ]; then
        print_status 0 "$(basename $test) exists"
    else
        print_warning "$(basename $test) not found"
    fi
done
echo ""

echo "12. QA GATE COMPLIANCE"
echo "====================="
latest_gate="../../docs/qa/gates/3.10-csv-format-options.yml"
if [ -f "$latest_gate" ]; then
    echo "Latest QA Gate: Story 3.10 - CSV Format Options"
    echo "Status: CONCERNS - CSV injection risk requires careful implementation"
    print_warning "Ensure SEC-001 (CSV injection prevention) is addressed"
else
    print_warning "QA gate file not found"
fi
echo ""

echo "================================================"
echo "AUDIT SUMMARY"
echo "================================================"
echo ""
echo "Critical items to address:"
echo "1. CSV injection prevention (SEC-001)"
echo "2. Verify QuickBooks/Xero compatibility"
echo "3. Update any outdated dependencies"
echo "4. Fix any failing tests"
echo ""
echo "Recommended actions:"
echo "- Run 'flutter pub upgrade' to update dependencies"
echo "- Run 'flutter test --coverage' to ensure test coverage"
echo "- Test CSV exports with actual QuickBooks/Xero imports"
echo "- Perform manual device testing for camera features"
echo ""
echo "Audit complete at $(date)"