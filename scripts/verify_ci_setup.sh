#!/bin/bash

# Script to verify CI/CD setup for Receipt Organizer
# Run this after setting up GitHub secrets

set -e

echo "======================================"
echo "Receipt Organizer CI/CD Setup Verifier"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ] && [ ! -d "apps/mobile" ]; then
    echo -e "${RED}❌ Error: Not in Receipt Organizer root directory${NC}"
    echo "Please run this script from the project root"
    exit 1
fi

# Navigate to mobile app directory if needed
if [ -d "apps/mobile" ]; then
    cd apps/mobile
fi

echo "📁 Checking project structure..."
echo ""

# Check Flutter project files
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} Found: $1"
        return 0
    else
        echo -e "${RED}✗${NC} Missing: $1"
        return 1
    fi
}

# Check required files
check_file "pubspec.yaml"
check_file "lib/main.dart"
check_file "test/widget_test.dart" || echo -e "${YELLOW}  Warning: No widget tests found${NC}"

echo ""
echo "🔍 Checking GitHub Actions workflows..."
echo ""

# Go back to root for workflow checks
if [ -d "apps/mobile" ]; then
    cd ../..
fi

# Check workflow files
check_file ".github/workflows/codeql.yml"
check_file ".github/workflows/security.yml"
check_file ".github/workflows/flutter-ci.yml"
check_file ".gitleaks.toml"

echo ""
echo "🧪 Running local tests..."
echo ""

# Navigate to mobile app for tests
if [ -d "apps/mobile" ]; then
    cd apps/mobile
fi

# Check Flutter installation
if command -v flutter &> /dev/null; then
    echo -e "${GREEN}✓${NC} Flutter is installed"
    flutter --version | head -n 1
else
    echo -e "${RED}✗${NC} Flutter is not installed"
    echo "  Please install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo ""
echo "📦 Checking dependencies..."
flutter pub get > /dev/null 2>&1
echo -e "${GREEN}✓${NC} Dependencies resolved"

echo ""
echo "🔍 Running Flutter analyze..."
if flutter analyze --no-fatal-infos --no-fatal-warnings > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Code analysis passed"
else
    echo -e "${YELLOW}⚠${NC} Code analysis has warnings"
    echo "  Run 'flutter analyze' to see details"
fi

echo ""
echo "🧪 Running tests..."
if flutter test --reporter=compact > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Tests passed"
else
    echo -e "${YELLOW}⚠${NC} Some tests failed"
    echo "  Run 'flutter test' to see details"
fi

echo ""
echo "📋 Checking for secrets in code..."
if [ -d "apps/mobile" ]; then
    cd ../..
fi

# Simple check for common secret patterns
if grep -r --include="*.dart" -E "(api[_-]?key|secret|token|password)" . 2>/dev/null | grep -v "test" | grep -v "example" | grep -v "//" > /dev/null; then
    echo -e "${YELLOW}⚠${NC} Potential secrets found in code"
    echo "  Please review and ensure no real secrets are committed"
else
    echo -e "${GREEN}✓${NC} No obvious secrets in code"
fi

echo ""
echo "======================================"
echo "📝 Next Steps:"
echo "======================================"
echo ""
echo "1. Add GitHub Secrets (if not already done):"
echo "   - Go to: https://github.com/mmtuentertainment/Receipt-Organizer/settings/secrets/actions"
echo "   - Add SNYK_TOKEN from https://snyk.io"
echo "   - Add CODECOV_TOKEN from https://codecov.io"
echo ""
echo "2. Commit and push the workflow files:"
echo -e "${YELLOW}   git add .github/workflows/ .gitleaks.toml${NC}"
echo -e "${YELLOW}   git commit -m \"fix: Add proper Flutter CI/CD workflows\"${NC}"
echo -e "${YELLOW}   git push origin main${NC}"
echo ""
echo "3. Monitor the Actions tab on GitHub:"
echo "   https://github.com/mmtuentertainment/Receipt-Organizer/actions"
echo ""
echo "4. Check coverage reports (after first run):"
echo "   https://codecov.io/gh/mmtuentertainment/Receipt-Organizer"
echo ""
echo -e "${GREEN}✨ Setup verification complete!${NC}"