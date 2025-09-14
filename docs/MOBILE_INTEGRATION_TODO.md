# Mobile Integration TODO List

**Created:** 2025-09-14
**Priority:** HIGH - Required for Phase 1 Feature Completion
**Status:** PENDING - To be addressed after core infrastructure

## Critical Integration Gaps to Address

### 🔴 Priority 1: Category Support (CRITICAL)
**Current State:** Database has 52 categories ready, mobile has 0 support

**Required Implementation:**
- [ ] Create Category model (`lib/core/models/category.dart`)
- [ ] Add CategoryRepository for CRUD operations
- [ ] Create CategoryProvider for state management
- [ ] Build category selector UI component
- [ ] Add category_id field to Receipt model
- [ ] Update receipt forms with category dropdown
- [ ] Implement category filtering in receipt list

### 🔴 Priority 2: New Database Fields
**Current State:** 14 new fields in database not mapped in Flutter

**Fields to Add to Mobile Receipt Model:**
- [ ] `vendor_name` (rename from merchantName)
- [ ] `receipt_date` (rename from date)
- [ ] `currency` (VARCHAR(3) - default 'USD')
- [ ] `tip_amount` (double)
- [ ] `subcategory` (String)
- [ ] `payment_method` (String - default 'card')
- [ ] `business_purpose` (String - text field)
- [ ] `notes` (String - text field)
- [ ] `tags` (List<String> - array)
- [ ] `needs_review` (bool - default false)
- [ ] `is_processed` (bool - default false)

### 🟡 Priority 3: Storage Integration
**Current State:** Helper functions created but not integrated

**Storage Tasks:**
- [ ] Integrate Supabase storage instead of local file system
- [ ] Implement `get_receipt_upload_path` function calls
- [ ] Add storage quota checking before uploads
- [ ] Implement signed URL generation for secure access
- [ ] Update image display to use Supabase URLs
- [ ] Add thumbnail generation support
- [ ] Implement storage quota UI display

### 🟡 Priority 4: Field Name Alignment
**Current State:** Mobile uses different field names than database

**Mapping Required:**
- [ ] `merchantName` → `vendor_name`
- [ ] `date` → `receipt_date`
- [ ] Add backwards compatibility layer
- [ ] Update all references in codebase
- [ ] Migration script for existing local data

## Implementation Strategy

### Phase 1A: Categories (Week 1)
1. Backend integration first
2. Simple category selector UI
3. Basic filtering capability

### Phase 1B: Essential Fields (Week 2)
1. Currency and payment method
2. Tips and business purpose
3. Notes field

### Phase 1C: Storage Migration (Week 3)
1. Dual storage support initially
2. Migrate existing images
3. Remove local storage code

### Phase 1D: Advanced Features (Week 4)
1. Tags implementation
2. Review workflow
3. Processing status tracking

## Testing Requirements

### Integration Tests Needed:
- [ ] Category CRUD operations
- [ ] New field persistence
- [ ] Storage upload/download
- [ ] Field mapping correctness
- [ ] Offline sync with new schema
- [ ] Export with new fields

## Migration Considerations

1. **Backwards Compatibility:** Support both field names temporarily
2. **Data Migration:** Script to update existing receipts
3. **Version Check:** Mobile app version compatibility check
4. **Rollback Plan:** Ability to revert if issues arise

## Success Criteria

- [ ] All 52 categories accessible in mobile
- [ ] All new fields editable in receipt form
- [ ] Storage quota displayed to user
- [ ] Successful export with new fields
- [ ] No data loss during migration
- [ ] Performance remains under 250ms

## Notes

- Database schema is production-ready and deployed
- These updates are for feature parity only
- Basic app functionality works without these updates
- Prioritize categories as they add immediate value

## When to Address

**Recommended Timing:**
- After Phase 2 (Authentication) is complete
- Before Phase 3 (OCR Enhancement)
- Can be done in parallel with Phase 4 (Export)

**Trigger Points:**
- When mobile development resources available
- After initial production deployment success
- When user feedback requests categories

---

*This TODO will be revisited after core infrastructure phases are complete.*
*Database team can proceed with remaining phases independently.*