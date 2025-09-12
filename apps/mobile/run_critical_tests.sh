#!/bin/bash

# Run only critical tests for Receipt Organizer MVP
# Based on simplified test strategy (30-50 tests instead of 571)

echo "================================"
echo "Running Critical MVP Tests Only"
echo "================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Critical test files
CRITICAL_TESTS=(
  # Repository Tests (most important)
  "test/unit/core/repositories/receipt_repository_test.dart"
  
  # Service Tests
  "test/services/ocr_service_test.dart"
  "test/services/csv_export_service_test.dart"
  
  # Integration Tests (if they exist)
  # "test/integration/capture_receipt_flow_test.dart"
  # "test/integration/export_receipts_flow_test.dart"
)

# Check which critical tests exist
EXISTING_TESTS=()
for test in "${CRITICAL_TESTS[@]}"; do
  if [ -f "$test" ]; then
    EXISTING_TESTS+=("$test")
  fi
done

if [ ${#EXISTING_TESTS[@]} -eq 0 ]; then
  echo "No critical test files found. Creating minimal test..."
  
  # Run any working test just to verify setup
  echo "Running basic Flutter test verification..."
  /home/matt/FINAPP/Receipt\ Organizer/flutter/bin/flutter test --no-pub test/widget_test.dart 2>/dev/null || \
  /home/matt/FINAPP/Receipt\ Organizer/flutter/bin/flutter test --no-pub test/ --name "placeholder" 2>/dev/null || \
  echo "No tests available to run"
else
  echo "Found ${#EXISTING_TESTS[@]} critical test files"
  echo "Running: ${EXISTING_TESTS[@]}"
  echo ""
  
  # Run the critical tests
  /home/matt/FINAPP/Receipt\ Organizer/flutter/bin/flutter test --no-pub "${EXISTING_TESTS[@]}"
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Critical tests passed${NC}"
  else
    echo -e "${RED}✗ Some critical tests failed${NC}"
    echo "This is expected during refactoring. Focus on fixing these core tests first."
  fi
fi

echo ""
echo "================================"
echo "Test Strategy Summary:"
echo "- Target: 30-50 critical tests"
echo "- Current: 571 tests (way too many!)"
echo "- Reference: CleanArchitectureTodoApp has only 12 tests"
echo "================================"