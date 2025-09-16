# Testing Documentation

## Testing Strategy

The Receipt Organizer app follows a **minimal test strategy** focusing on critical business logic rather than exhaustive edge cases.

### Test Philosophy
- **15 Critical Tests**: Core functionality only
- **Real Data**: Use actual merchant names and realistic amounts
- **Fast Feedback**: Tests should run in < 30 seconds
- **No Flaky Tests**: Deterministic, reliable tests only

## Test Structure

```
apps/mobile/test/
├── core_tests/           # Unit tests for core business logic
│   ├── app_launch_test.dart
│   ├── csv_export_test.dart
│   └── receipt_repository_test.dart
├── integration_tests/    # Critical user flow tests
│   └── critical_user_flows_test.dart
├── integration/         # Feature integration tests
│   └── export_validation_flow_test.dart
├── infrastructure/      # Infrastructure tests
│   ├── service_infrastructure_test.dart
│   └── supabase_integration_test.dart
└── fixtures/           # Test data and utilities
    └── real_transaction_data.csv
```

## Running Tests

### All Critical Tests (Recommended)
```bash
cd apps/mobile
flutter test test/core_tests/ test/integration_tests/
```

### Specific Test Categories

#### Core Business Logic
```bash
flutter test test/core_tests/
```

#### Integration Tests
```bash
flutter test test/integration_tests/
```

#### Export Validation
```bash
flutter test test/integration/export_validation_flow_test.dart
```

#### Supabase Integration (requires local Supabase)
```bash
CI=true flutter test test/infrastructure/supabase_integration_test.dart
```

## Test Data

### Real Data Fixtures
Located at: `apps/mobile/lib/test/fixtures/real_data_loader.dart`

Provides:
- 50+ real merchant names
- Realistic amount distributions
- Proper date ranges
- Valid tax calculations

### CSV Test Data
Located at: `apps/mobile/test/fixtures/real_transaction_data.csv`

Contains actual receipt data for testing CSV import/export functionality.

## Performance Benchmarks

### Target Metrics
- **CSV Export**: < 2s for 1000 receipts
- **Validation**: < 500ms for 100 receipts
- **OCR Processing**: < 5s per receipt (p95)

### Running Performance Tests
```bash
flutter test test/integration/export_validation_flow_test.dart \
  --name "should handle large datasets efficiently"
```

## Continuous Integration

### Pre-commit Checks
The project includes pre-commit hooks that:
- Run `flutter analyze`
- Check for secrets in code
- Verify test count remains ~15

### GitHub Actions
Workflow located at: `.github/workflows/test.yml`
- Runs on every PR
- Tests against Flutter 3.35.3
- Validates both Android and iOS builds

## Test Coverage

### What We Test
✅ Core receipt operations (CRUD)
✅ CSV export with proper formatting
✅ Export validation for QuickBooks/Xero
✅ Critical navigation flows
✅ Service initialization
✅ Infrastructure interfaces

### What We Don't Test
❌ Every UI widget interaction
❌ Every edge case
❌ Third-party library internals
❌ Platform-specific features
❌ Cosmetic changes

## Debugging Tests

### Verbose Output
```bash
flutter test --reporter expanded
```

### Single Test
```bash
flutter test --name "specific test name"
```

### With Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Adding New Tests

⚠️ **IMPORTANT**: Do not add tests without explicit discussion!

Before adding any test:
1. Verify it tests critical business logic
2. Ensure no existing test covers it
3. Confirm it uses real data fixtures
4. Get approval in the PR

## Test Maintenance

### Monthly Review
- Remove flaky tests
- Update deprecated patterns
- Refresh test data
- Verify performance targets

### Test Hygiene
- Keep tests under 50 lines
- One assertion per test preferred
- Clear test names describing behavior
- Use fixtures for complex data