# Epic 4: Settings & Support - Brownfield Enhancement

## Epic Goal

Enable users to customize application behavior, monitor storage usage, and export their data for backup, enhancing user control and preventing data lock-in while maintaining the offline-first architecture.

## Epic Description

### Existing System Context:

- **Current relevant functionality:** 
  - Basic settings infrastructure exists (SettingsRepository from Story 2.2)
  - Merchant normalization toggle already implemented
  - Local SQLite/RxDB storage with offline-first design
  - CSV export functionality for receipts
  - Confidence scoring system with fixed thresholds

- **Technology stack:** 
  - Flutter 3.24+ with Material 3 design
  - Riverpod 2.4+ for state management
  - SQLite via sqflite for persistence
  - Existing SettingsRepository pattern

- **Integration points:** 
  - SettingsRepository for preference persistence
  - CSVExportService for data export
  - OCRService for confidence threshold configuration
  - StorageService for usage calculation

### Enhancement Details:

- **What's being added/changed:**
  - Settings screen with expandable preference sections
  - Default export format preference (QuickBooks/Xero/Generic)
  - Visual storage usage indicator with cleanup options
  - Adjustable OCR confidence thresholds with preview
  - Full data export in JSON format for backup/portability

- **How it integrates:**
  - Extends existing SettingsRepository with new preference keys
  - Uses established UI patterns from field editing screens
  - Leverages existing export infrastructure for JSON generation
  - Integrates with OCRService for dynamic threshold adjustment

- **Success criteria:**
  - Settings persist across app restarts
  - Storage usage calculation completes in <1s
  - Export format preference applies to all exports
  - Confidence threshold changes affect new scans immediately
  - JSON export includes all receipt data and images

## Stories

### Story 14: Default Export Format Setting
**Priority: P2**
As Mike (Freelance Contractor), I want to set my default export format, so I don't have to select it every time.

- Add export format setting to SettingsRepository
- Create settings UI section for export preferences
- Persist selection (QuickBooks/Xero/Generic)
- Apply default on export screen initialization

**Estimated effort:** 2 points

### Story 15: Storage Usage Monitor
**Priority: P2**
As Sarah (Restaurant Owner), I want to see my storage usage, so I know when to clean up old receipts.

- Calculate total storage (images + database)
- Create visual storage indicator (progress bar)
- Add "Clean up old receipts" option
- Show breakdown by receipt age

**Estimated effort:** 3 points

### Story 16: OCR Confidence Threshold Adjustment
**Priority: P3**
As Linda (Bookkeeper), I want to adjust OCR confidence thresholds, so I can balance accuracy vs speed for my workflow.

- Create slider UI for confidence threshold (50-90%)
- Show impact preview (estimated fields needing review)
- Update OCRService to use dynamic threshold
- Persist threshold preference

**Estimated effort:** 3 points

### Story 17: Full Data Export
**Priority: P3**
As Mike, I want to export all my data for backup, so I'm not locked into the app.

- Create JSON export format including all receipt data
- Include Base64 encoded images (optional)
- Generate export timestamp and metadata
- Use existing share functionality for file export

**Estimated effort:** 3 points

## Compatibility Requirements

- [x] Existing SettingsRepository API extended, not changed
- [x] No database schema changes required
- [x] UI follows established Material 3 patterns
- [x] Performance targets maintained (<100ms UI response)
- [x] Offline-first architecture preserved

## Risk Mitigation

- **Primary Risk:** Storage calculation performance impact on large datasets
- **Mitigation:** Calculate storage asynchronously with caching, update only on demand
- **Rollback Plan:** Settings are additive features that can be disabled via feature flags without affecting core functionality

## Definition of Done

- [ ] All 4 stories completed with acceptance criteria met
- [ ] Settings persist correctly across app lifecycle
- [ ] Existing receipt functionality unaffected
- [ ] Performance targets met (storage calc <1s, UI <100ms)
- [ ] Settings accessible from main navigation
- [ ] Comprehensive test coverage for preference persistence
- [ ] User can successfully export and re-import their data
- [ ] No regression in existing features

---

## Story Manager Handoff:

"Please develop detailed user stories for this brownfield Settings & Support epic. Key considerations:

- This is an enhancement to an existing Flutter receipt capture system
- Integration points: SettingsRepository, CSVExportService, OCRService, StorageService
- Existing patterns to follow: Riverpod state management, Material 3 settings UI, existing preference persistence
- Critical compatibility requirements: All settings must be optional with sensible defaults
- Each story must include verification that existing functionality remains intact

The epic should maintain system integrity while delivering user control features that enhance the overall experience without compromising the offline-first architecture."