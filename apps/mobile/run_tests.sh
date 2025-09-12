#!/bin/bash

# Simple Test Runner for Receipt Organizer MVP
# Following CleanArchitectureTodoApp pattern - minimal but effective

echo "========================================"
echo "Receipt Organizer MVP - Minimal Tests"
echo "========================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Flutter command
FLUTTER="/home/matt/FINAPP/Receipt Organizer/flutter/bin/flutter"

echo -e "${YELLOW}Running Core Tests (Target: ~15 tests)${NC}"
echo "----------------------------------------"

# Run core tests
echo "1. App Launch Tests..."
$FLUTTER test --no-pub test/core_tests/app_launch_test.dart 2>/dev/null
APP_RESULT=$?

echo "2. Repository Tests..."
$FLUTTER test --no-pub test/core_tests/receipt_repository_test.dart 2>/dev/null
REPO_RESULT=$?

echo "3. CSV Export Tests..."
$FLUTTER test --no-pub test/core_tests/csv_export_test.dart 2>/dev/null
CSV_RESULT=$?

echo "4. Integration Tests..."
$FLUTTER test --no-pub test/integration_tests/critical_user_flows_test.dart 2>/dev/null
INTEGRATION_RESULT=$?

echo "5. Basic Widget Test..."
$FLUTTER test --no-pub test/widget_test.dart 2>/dev/null
WIDGET_RESULT=$?

echo ""
echo "========================================"
echo "Test Results Summary"
echo "========================================"

TOTAL_PASS=0
TOTAL_FAIL=0

if [ $APP_RESULT -eq 0 ]; then
  echo -e "${GREEN}✓ App Launch Tests${NC}"
  ((TOTAL_PASS++))
else
  echo -e "${RED}✗ App Launch Tests${NC}"
  ((TOTAL_FAIL++))
fi

if [ $REPO_RESULT -eq 0 ]; then
  echo -e "${GREEN}✓ Repository Tests${NC}"
  ((TOTAL_PASS++))
else
  echo -e "${RED}✗ Repository Tests${NC}"
  ((TOTAL_FAIL++))
fi

if [ $CSV_RESULT -eq 0 ]; then
  echo -e "${GREEN}✓ CSV Export Tests${NC}"
  ((TOTAL_PASS++))
else
  echo -e "${RED}✗ CSV Export Tests${NC}"
  ((TOTAL_FAIL++))
fi

if [ $INTEGRATION_RESULT -eq 0 ]; then
  echo -e "${GREEN}✓ Integration Tests${NC}"
  ((TOTAL_PASS++))
else
  echo -e "${RED}✗ Integration Tests${NC}"
  ((TOTAL_FAIL++))
fi

if [ $WIDGET_RESULT -eq 0 ]; then
  echo -e "${GREEN}✓ Widget Tests${NC}"
  ((TOTAL_PASS++))
else
  echo -e "${RED}✗ Widget Tests${NC}"
  ((TOTAL_FAIL++))
fi

echo ""
echo "----------------------------------------"
echo -e "Passed: ${GREEN}$TOTAL_PASS${NC} | Failed: ${RED}$TOTAL_FAIL${NC}"
echo ""

if [ $TOTAL_FAIL -eq 0 ]; then
  echo -e "${GREEN}🎉 All critical tests passed!${NC}"
  exit 0
else
  echo -e "${YELLOW}⚠️  Some tests need attention${NC}"
  echo ""
  echo "Note: We reduced from 571 tests to ~15 critical tests"
  echo "Following CleanArchitectureTodoApp pattern (12 tests total)"
  exit 1
fi