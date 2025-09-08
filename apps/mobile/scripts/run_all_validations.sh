#!/bin/bash

# Quick validation runner for Receipt Organizer MVP
# Runs all validation scripts in sequence

set -e

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Receipt Organizer MVP - Quick Validation${NC}"
echo -e "${BLUE}========================================${NC}\n"

cd "$(dirname "$0")/.."

# 1. Run comprehensive audit
echo -e "${YELLOW}1. Running Comprehensive Audit...${NC}"
if ./scripts/comprehensive_audit.sh > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Comprehensive audit passed${NC}"
else
    echo -e "${RED}✗ Comprehensive audit failed${NC}"
fi

# 2. Run CSV security validation
echo -e "\n${YELLOW}2. Running CSV Security Validation...${NC}"
if dart run scripts/validate_csv_security.dart; then
    echo -e "${GREEN}✓ CSV security validation passed${NC}"
else
    echo -e "${RED}✗ CSV security validation failed${NC}"
fi

# 3. Run export format validation
echo -e "\n${YELLOW}3. Running Export Format Validation...${NC}"
if dart run scripts/validate_export_formats.dart; then
    echo -e "${GREEN}✓ Export format validation passed${NC}"
else
    echo -e "${RED}✗ Export format validation failed${NC}"
fi

# 4. Run performance validation
echo -e "\n${YELLOW}4. Running Performance Validation...${NC}"
if dart run scripts/validate_performance.dart; then
    echo -e "${GREEN}✓ Performance validation passed${NC}"
else
    echo -e "${RED}✗ Performance validation failed${NC}"
fi

# 5. Quick test run
echo -e "\n${YELLOW}5. Running Quick Test Suite...${NC}"
if flutter test --reporter=expanded test/unit/domain/services/csv_export_service_test.dart test/unit/domain/services/merchant_normalization_service_test.dart > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Key service tests passed${NC}"
else
    echo -e "${RED}✗ Some service tests failed${NC}"
fi

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Validation Complete!${NC}"
echo -e "\nFor detailed results, run individual scripts or check audit logs."
echo -e "\n${YELLOW}Next Steps:${NC}"
echo "1. Review any failures in detail"
echo "2. Test on physical devices"
echo "3. Verify CSV imports with QuickBooks/Xero"
echo "4. Run manual UI/UX testing"