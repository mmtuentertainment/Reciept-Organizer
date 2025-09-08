#!/bin/bash

# Comprehensive Mid-Development Audit Script for Receipt Organizer MVP
# Version: 1.0
# Date: January 2025
# This script performs exhaustive validation checks on the Receipt Organizer MVP

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Counters for summary
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Log file for detailed output
AUDIT_LOG="audit_report_$(date +%Y%m%d_%H%M%S).log"

# Function to print section header
print_section() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo "" | tee -a "$AUDIT_LOG"
}

# Function to print subsection
print_subsection() {
    echo -e "${CYAN}>>> $1${NC}" | tee -a "$AUDIT_LOG"
}

# Function to check status
check_status() {
    local status=$1
    local message=$2
    local critical=${3:-false}
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ $status -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $message" | tee -a "$AUDIT_LOG"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        if [ "$critical" = true ]; then
            echo -e "${RED}✗ [CRITICAL]${NC} $message" | tee -a "$AUDIT_LOG"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
        else
            echo -e "${YELLOW}⚠${NC} $message" | tee -a "$AUDIT_LOG"
            WARNING_CHECKS=$((WARNING_CHECKS + 1))
        fi
        return 1
    fi
}

# Function to run command and check
run_check() {
    local command=$1
    local description=$2
    local critical=${3:-false}
    
    if eval "$command" &>/dev/null; then
        check_status 0 "$description"
    else
        check_status 1 "$description" "$critical"
    fi
}

# Navigate to mobile app directory
cd "$(dirname "$0")/.."

echo -e "${MAGENTA}================================================${NC}" | tee "$AUDIT_LOG"
echo -e "${MAGENTA}Receipt Organizer MVP - Comprehensive Audit${NC}" | tee -a "$AUDIT_LOG"
echo -e "${MAGENTA}Date: $(date)${NC}" | tee -a "$AUDIT_LOG"
echo -e "${MAGENTA}================================================${NC}" | tee -a "$AUDIT_LOG"

# 1. ENVIRONMENT VALIDATION
print_section "1. ENVIRONMENT VALIDATION"

print_subsection "Flutter Environment"
flutter --version | tee -a "$AUDIT_LOG"
echo ""

# Check Flutter version
flutter_version=$(flutter --version | grep "Flutter" | awk '{print $2}')
if [[ "$flutter_version" > "3.24.0" ]] || [[ "$flutter_version" == "3.24.0" ]]; then
    check_status 0 "Flutter version $flutter_version meets requirements (≥3.24.0)"
else
    check_status 1 "Flutter version $flutter_version does not meet requirements (≥3.24.0)" true
fi

# Check Dart version
dart_version=$(dart --version 2>&1 | awk '{print $4}')
if [[ "$dart_version" > "3.5.0" ]] || [[ "$dart_version" == "3.5.0" ]]; then
    check_status 0 "Dart version $dart_version meets requirements (≥3.5.0)"
else
    check_status 1 "Dart version $dart_version does not meet requirements (≥3.5.0)" true
fi

print_subsection "Flutter Doctor"
flutter doctor -v | grep -E "(✓|✗|!)" | while read -r line; do
    if [[ $line == *"✓"* ]]; then
        echo -e "${GREEN}$line${NC}" | tee -a "$AUDIT_LOG"
    elif [[ $line == *"✗"* ]]; then
        echo -e "${RED}$line${NC}" | tee -a "$AUDIT_LOG"
    else
        echo -e "${YELLOW}$line${NC}" | tee -a "$AUDIT_LOG"
    fi
done

# 2. DEPENDENCY AUDIT
print_section "2. DEPENDENCY AUDIT"

print_subsection "Package Dependencies"
run_check "flutter pub get" "Dependencies resolved successfully"

# Check for outdated packages
echo "Checking for outdated packages..." | tee -a "$AUDIT_LOG"
outdated_count=$(flutter pub outdated --no-dev-dependencies 2>/dev/null | grep -E "^\*" | wc -l || echo "0")
if [ "$outdated_count" -eq 0 ]; then
    check_status 0 "All production dependencies up to date"
else
    check_status 1 "Found $outdated_count outdated production dependencies"
fi

# Check critical dependencies
print_subsection "Critical Dependencies Version Check"
critical_deps=(
    "flutter_riverpod:2.6.1"
    "google_mlkit_text_recognition:0.15.0"
    "camera:0.11.0"
    "csv:6.0.0"
    "drift:2.21.0"
)

for dep in "${critical_deps[@]}"; do
    IFS=':' read -r package version <<< "$dep"
    if grep -q "$package: [\^~]*$version" pubspec.yaml; then
        check_status 0 "$package version $version or compatible"
    else
        check_status 1 "$package version mismatch (expected $version)"
    fi
done

# 3. CODE QUALITY
print_section "3. CODE QUALITY"

print_subsection "Static Analysis"
if flutter analyze --no-fatal-infos 2>&1 | tee -a "$AUDIT_LOG" | grep -q "No issues found"; then
    check_status 0 "No static analysis issues"
else
    check_status 1 "Static analysis found issues"
fi

print_subsection "Code Formatting"
unformatted=$(dart format --set-exit-if-changed --output=none . 2>&1 | grep -c "changed" || true)
if [ "$unformatted" -eq 0 ]; then
    check_status 0 "All code properly formatted"
else
    check_status 1 "Found $unformatted unformatted files"
fi

# 4. SECURITY VALIDATION
print_section "4. SECURITY VALIDATION"

print_subsection "CSV Injection Prevention"
# Check for CSV sanitization implementation
if grep -q "_sanitizeForCSV" lib/domain/services/csv_export_service.dart; then
    check_status 0 "CSV sanitization method found"
    
    # Check for formula injection prevention
    if grep -q "^[=+@-]" lib/domain/services/csv_export_service.dart; then
        check_status 0 "Formula injection prevention implemented"
    else
        check_status 1 "Formula injection prevention not found" true
    fi
else
    check_status 1 "CSV sanitization not implemented" true
fi

# Run CSV injection test if available
if [ -f "scripts/test_csv_injection_prevention.dart" ]; then
    print_subsection "CSV Injection Test"
    if dart run scripts/test_csv_injection_prevention.dart 2>&1 | tee -a "$AUDIT_LOG" | grep -q "All tests passed"; then
        check_status 0 "CSV injection prevention tests passed"
    else
        check_status 1 "CSV injection prevention tests failed" true
    fi
fi

# 5. FEATURE IMPLEMENTATION
print_section "5. FEATURE IMPLEMENTATION"

print_subsection "Core Features"
features=(
    "lib/features/capture/presentation/pages/batch_capture_screen.dart:Batch Capture Screen"
    "lib/domain/services/edge_detection_service.dart:Edge Detection Service"
    "lib/features/receipts/presentation/widgets/confidence_indicator.dart:Confidence Indicator"
    "lib/features/receipts/presentation/widgets/receipt_detail_screen.dart:Receipt Detail Screen"
    "lib/domain/services/merchant_normalization_service.dart:Merchant Normalization"
    "lib/features/export/presentation/widgets/format_selection.dart:Export Format Selection"
    "lib/features/export/presentation/widgets/date_range_picker.dart:Date Range Picker"
    "lib/domain/services/csv_export_service.dart:CSV Export Service"
    "lib/domain/services/ocr_service.dart:OCR Service"
)

for feature in "${features[@]}"; do
    IFS=':' read -r file desc <<< "$feature"
    run_check "[ -f '$file' ]" "$desc implemented"
done

# 6. TESTING
print_section "6. TESTING"

print_subsection "Test Execution"
# Run tests with coverage
echo "Running all tests with coverage..." | tee -a "$AUDIT_LOG"
if flutter test --coverage 2>&1 | tee -a "$AUDIT_LOG"; then
    check_status 0 "All tests passed"
    
    # Check coverage
    if [ -f "coverage/lcov.info" ]; then
        if command -v lcov &> /dev/null; then
            coverage_percent=$(lcov --summary coverage/lcov.info 2>/dev/null | grep "lines" | grep -o '[0-9.]*%' | head -1 | sed 's/%//')
            if [ -n "$coverage_percent" ]; then
                if (( $(echo "$coverage_percent >= 70" | bc -l) )); then
                    check_status 0 "Test coverage ${coverage_percent}% meets target (≥70%)"
                else
                    check_status 1 "Test coverage ${coverage_percent}% below target (≥70%)"
                fi
            fi
        else
            check_status 1 "lcov not installed - cannot calculate coverage"
        fi
    else
        check_status 1 "No coverage data generated"
    fi
else
    check_status 1 "Some tests failed" true
fi

print_subsection "Integration Tests"
integration_tests=(
    "test/integration/batch_capture_flow_test.dart"
    "test/integration/capture_retry_flow_test.dart"
    "test/integration/merchant_normalization_flow_test.dart"
    "test/integration/notes_persistence_flow_test.dart"
)

for test in "${integration_tests[@]}"; do
    if [ -f "$test" ]; then
        check_status 0 "$(basename $test) exists"
    else
        check_status 1 "$(basename $test) missing"
    fi
done

# 7. BUILD VERIFICATION
print_section "7. BUILD VERIFICATION"

print_subsection "Debug Builds"
echo "Testing Android debug build..." | tee -a "$AUDIT_LOG"
run_check "flutter build apk --debug --no-tree-shake-icons" "Android debug build successful"

# Note: iOS build only works on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Testing iOS debug build..." | tee -a "$AUDIT_LOG"
    run_check "flutter build ios --debug --no-codesign" "iOS debug build successful"
else
    echo "Skipping iOS build check (not on macOS)" | tee -a "$AUDIT_LOG"
fi

# 8. PERFORMANCE CHECKS
print_section "8. PERFORMANCE VALIDATION"

print_subsection "Performance Tests"
perf_tests=(
    "test/performance/date_range_selection_performance_test.dart"
    "test/performance/receipt_search_performance_test.dart"
    "test/benchmarks/merchant_normalization_performance_test.dart"
)

for test in "${perf_tests[@]}"; do
    if [ -f "$test" ]; then
        echo "Running $(basename $test)..." | tee -a "$AUDIT_LOG"
        if flutter test "$test" 2>&1 | tee -a "$AUDIT_LOG" | grep -q "All tests passed"; then
            check_status 0 "$(basename $test) passed"
        else
            check_status 1 "$(basename $test) failed"
        fi
    fi
done

# 9. EXPORT VALIDATION
print_section "9. EXPORT FORMAT VALIDATION"

if [ -f "scripts/test_csv_export_formats.dart" ]; then
    print_subsection "CSV Export Format Tests"
    if dart run scripts/test_csv_export_formats.dart 2>&1 | tee -a "$AUDIT_LOG" | grep -q "All export format tests passed"; then
        check_status 0 "All CSV export formats validated"
    else
        check_status 1 "CSV export format validation failed" true
    fi
fi

# 10. QA GATE COMPLIANCE
print_section "10. QA GATE COMPLIANCE"

print_subsection "Latest QA Gate Status"
qa_gate_file="../../docs/qa/gates/3.10-csv-format-options.yml"
if [ -f "$qa_gate_file" ]; then
    echo "Checking QA Gate: Story 3.10 - CSV Format Options" | tee -a "$AUDIT_LOG"
    if grep -q "APPROVED" "$qa_gate_file"; then
        check_status 0 "QA Gate APPROVED"
    elif grep -q "CONCERNS" "$qa_gate_file"; then
        check_status 1 "QA Gate has CONCERNS - review required"
    else
        check_status 1 "QA Gate status unclear"
    fi
fi

# SUMMARY
print_section "AUDIT SUMMARY"

echo -e "${MAGENTA}Total Checks: $TOTAL_CHECKS${NC}" | tee -a "$AUDIT_LOG"
echo -e "${GREEN}Passed: $PASSED_CHECKS${NC}" | tee -a "$AUDIT_LOG"
echo -e "${RED}Failed: $FAILED_CHECKS${NC}" | tee -a "$AUDIT_LOG"
echo -e "${YELLOW}Warnings: $WARNING_CHECKS${NC}" | tee -a "$AUDIT_LOG"

success_rate=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
echo -e "\n${CYAN}Success Rate: $success_rate%${NC}" | tee -a "$AUDIT_LOG"

# Critical issues summary
if [ $FAILED_CHECKS -gt 0 ]; then
    echo -e "\n${RED}CRITICAL ISSUES FOUND${NC}" | tee -a "$AUDIT_LOG"
    echo "Review the audit log for details: $AUDIT_LOG" | tee -a "$AUDIT_LOG"
    exit 1
else
    echo -e "\n${GREEN}ALL CRITICAL CHECKS PASSED${NC}" | tee -a "$AUDIT_LOG"
fi

# Recommendations
echo -e "\n${CYAN}RECOMMENDATIONS:${NC}" | tee -a "$AUDIT_LOG"
if [ $WARNING_CHECKS -gt 0 ]; then
    echo "• Address $WARNING_CHECKS warning(s) before release" | tee -a "$AUDIT_LOG"
fi
if [ "$outdated_count" -gt 0 ]; then
    echo "• Update $outdated_count outdated dependencies" | tee -a "$AUDIT_LOG"
fi
echo "• Perform manual device testing" | tee -a "$AUDIT_LOG"
echo "• Test CSV exports with QuickBooks/Xero" | tee -a "$AUDIT_LOG"
echo "• Review security implementation" | tee -a "$AUDIT_LOG"

echo -e "\n${MAGENTA}Detailed audit log saved to: $AUDIT_LOG${NC}"
echo -e "${MAGENTA}Audit completed at: $(date)${NC}" | tee -a "$AUDIT_LOG"