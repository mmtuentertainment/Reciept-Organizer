# Cleanup Plan for Orphaned Files

## Current State Analysis

### Receipt Model Confusion (3 different Receipt classes!)
1. **`/lib/core/models/receipt.dart`** - Used by 5 files (infrastructure services)
2. **`/lib/data/models/receipt.dart`** - Used by 5 files (repositories, database)
3. **`/lib/domain/models/receipt_model.dart`** - NEW domain model (should be the only one)

### Mock/Test Files Duplication
```
test/mocks/
├── async_receipt_mock.dart         # Duplicate async mock
├── proper_async_receipt_mock.dart  # Another async mock (duplicate)
├── simple_sync_receipt_provider.dart # Sync provider
└── sync_receipt_provider.dart      # Another sync provider (duplicate)
```

### Test Fixtures
```
test/fixtures/
├── receipt_fixtures_simplified.dart  # New simplified version
├── receipt_fixtures.dart.backup     # Already removed ✅
└── test_data_generator.dart        # May still be needed
```

## Files to Remove

### High Priority - Conflicting Models
1. **KEEP FOR NOW** (used by 5+ files each):
   - `/lib/core/models/receipt.dart`
   - `/lib/data/models/receipt.dart`

   These need migration to domain model first!

### Medium Priority - Duplicate Mocks
Remove these duplicate mock files:
- `test/mocks/async_receipt_mock.dart` (replaced by proper_async_receipt_mock.dart)
- `test/mocks/sync_receipt_provider.dart` (replaced by simple_sync_receipt_provider.dart)

### Low Priority - May Keep
- `test/fixtures/test_data_generator.dart` - Check if still used
- `lib/core/models/receipt_extended.dart` - Check dependencies

## Safe Cleanup Commands

```bash
# 1. Remove duplicate mock files
rm test/mocks/async_receipt_mock.dart
rm test/mocks/sync_receipt_provider.dart

# 2. Check if test_data_generator is used
grep -r "test_data_generator" test/

# 3. Check receipt_extended usage
grep -r "receipt_extended" lib/
```

## Migration Plan (Future)

To fully clean up, need to:
1. Migrate all uses of `/lib/core/models/receipt.dart` to domain model
2. Migrate all uses of `/lib/data/models/receipt.dart` to domain model
3. Update all imports
4. Remove old Receipt classes
5. Keep only `/lib/domain/models/receipt_model.dart`

## Current Dependencies to Fix

### Files using core/models/receipt.dart:
- `lib/infrastructure/services/receipt_api_service.dart`
- `lib/infrastructure/services/mock_sync_service.dart`
- `lib/infrastructure/services/supabase_sync_service.dart`
- `lib/infrastructure/repositories/hybrid_receipt_repository.dart`
- `lib/domain/services/interfaces/i_sync_service.dart`

### Files using data/models/receipt.dart:
- `lib/core/repositories/interfaces/i_receipt_repository.dart`
- `lib/database/app_database.dart`
- `lib/infrastructure/repositories/hybrid_receipt_repository.dart`
- `lib/domain/mappers/receipt_mapper.dart`
- `lib/domain/services/csv_export_service.dart`

## Recommendation

**DO NOT remove the Receipt model files yet** - they're actively used!

Safe to remove now:
- Duplicate mock files
- Backup files (already done ✅)

Need migration first:
- Core and data Receipt models (10+ files depend on them)