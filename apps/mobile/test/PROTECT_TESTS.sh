#!/bin/bash

# Test Protection Script - Prevents accidental test bloat
# This script monitors and protects the simplified test suite

echo "================================================"
echo "    TEST SUITE PROTECTION CHECK"
echo "================================================"

# Configuration
MAX_TEST_FILES=20  # We should have ~15 tests, allow small buffer
MAX_TEST_DIRECTORIES=5  # core_tests, integration_tests, and a few helpers

# Count test files
TEST_FILE_COUNT=$(find test -name "*.dart" -type f 2>/dev/null | wc -l)
TEST_DIR_COUNT=$(find test -type d -mindepth 1 2>/dev/null | wc -l)

# Check if exceeding limits
if [ "$TEST_FILE_COUNT" -gt "$MAX_TEST_FILES" ]; then
    echo "❌ ERROR: Too many test files!"
    echo "   Found: $TEST_FILE_COUNT test files"
    echo "   Maximum allowed: $MAX_TEST_FILES"
    echo ""
    echo "⚠️  REMEMBER: This project uses a SIMPLIFIED test strategy"
    echo "   - Only 15 critical tests should exist"
    echo "   - Read test/SIMPLIFIED_TEST_STRATEGY.md"
    echo "   - DO NOT add tests without discussion"
    echo ""
    echo "Recent test files added:"
    find test -name "*.dart" -type f -mtime -1 2>/dev/null | head -10
    exit 1
fi

if [ "$TEST_DIR_COUNT" -gt "$MAX_TEST_DIRECTORIES" ]; then
    echo "⚠️  WARNING: Too many test directories"
    echo "   Found: $TEST_DIR_COUNT directories"
    echo "   Expected: $MAX_TEST_DIRECTORIES or fewer"
    echo ""
    echo "Test directories:"
    find test -type d -mindepth 1 2>/dev/null
fi

echo "✅ Test suite is properly maintained"
echo "   Test files: $TEST_FILE_COUNT (max: $MAX_TEST_FILES)"
echo "   Test directories: $TEST_DIR_COUNT (max: $MAX_TEST_DIRECTORIES)"
echo ""
echo "Critical tests location:"
echo "   - Core: test/core_tests/"
echo "   - Integration: test/integration_tests/"
echo ""
echo "Run tests with:"
echo "   flutter test test/core_tests/ test/integration_tests/"
echo "================================================"