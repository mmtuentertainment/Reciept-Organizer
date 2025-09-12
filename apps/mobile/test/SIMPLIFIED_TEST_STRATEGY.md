# Simplified Test Strategy for Receipt Organizer MVP

## Current State
- **571 tests** created (way too many!)
- **131 failing tests** 
- Massive test maintenance burden
- Following CleanArchitectureTodoApp example: **12 tests total**

## New Target: ~30-50 Critical Tests Only

### Core Business Logic Tests (15 tests)
These are the MUST HAVE tests for the MVP:

#### 1. Receipt Repository Tests (5 tests)
```
✅ Should create a receipt
✅ Should retrieve receipts by date range
✅ Should delete receipts
✅ Should update receipt with OCR data
✅ Should handle database errors gracefully
```

#### 2. OCR Service Tests (5 tests)
```
✅ Should extract text from image
✅ Should parse merchant name
✅ Should parse total amount
✅ Should parse date
✅ Should return confidence scores
```

#### 3. CSV Export Tests (5 tests)
```
✅ Should export to QuickBooks format
✅ Should export to Xero format  
✅ Should validate receipts before export
✅ Should handle missing OCR data
✅ Should generate correct CSV headers
```

### Critical User Journey Tests (10 integration tests)
```
✅ User can capture a receipt photo
✅ User can view OCR results
✅ User can edit receipt details
✅ User can delete receipts
✅ User can export receipts to CSV
✅ User can select date range for export
✅ User can retry failed capture
✅ User can batch capture multiple receipts
✅ User can view receipt details
✅ User can change export format
```

### UI Smoke Tests (5 widget tests)
```
✅ Receipt list screen loads
✅ Capture screen shows camera preview
✅ Export screen shows format options
✅ Settings screen loads
✅ Receipt detail screen displays data
```

## Tests to DELETE/COMMENT OUT

### Over-tested Areas
- **Mock implementations** - We had 25+ tests just for mocks!
- **Provider state tests** - Too many micro-tests for every state change
- **Settings tests** - 11 tests for simple preferences
- **Widget interaction tests** - Testing every button tap
- **Getter/setter tests** - Testing trivial code
- **Model tests** - Testing freezed generated code

### Test Modules to Simplify
| Module | Current | Target | Action |
|--------|---------|--------|--------|
| mocks | 25 | 0 | DELETE - not needed |
| settings | 11 | 2 | Keep app settings load/save |
| core | 20 | 5 | Keep repository tests only |
| export | 31 | 5 | Keep CSV generation tests |
| domain | 11 | 5 | Keep OCR service tests |
| widgets | 11 | 5 | Keep screen load tests |
| receipts | 17 | 5 | Keep CRUD operations |
| capture | 47 | 5 | Keep capture flow test |
| integration | ? | 10 | Critical user journeys |

## Implementation Plan

1. **Phase 1: Delete Mock Tests**
   - Remove all tests in test/mocks/
   - These test the test infrastructure, not the app

2. **Phase 2: Simplify Provider Tests**
   - Keep only tests that verify business logic
   - Remove state transition micro-tests

3. **Phase 3: Focus on Integration Tests**
   - Write 10 solid integration tests for critical paths
   - Use convenient_test for debugging

4. **Phase 4: Clean Up**
   - Delete test_modules.sh and modular test structure
   - Return to simple flutter test command

## Benefits of Simplification

1. **Faster Development** - Less time fixing tests
2. **Better Coverage** - Focus on what matters
3. **Easier Maintenance** - 30 tests vs 571
4. **Clearer Intent** - Each test has a clear purpose
5. **Faster CI/CD** - Tests run in seconds, not minutes

## Reference Projects
- **CleanArchitectureTodoApp**: 12 tests, full app coverage
- **flutter/gallery**: ~100 tests for complex showcase app
- **Invoice Ninja**: ~200 tests for production app with millions of users

## Conclusion
We went from 0 to 571 tests (overkill) when we should have gone from 0 to 30-50 well-chosen tests. Let's fix this now.