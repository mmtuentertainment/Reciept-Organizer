# Product Requirements Document - Receipt Organizer MVP

**Version:** 1.0  
**Date:** 2025-01-05  
**Status:** Complete  
**Author:** Peter Drucker (PM)

---

## Executive Summary

### Product Vision
Create a pragmatic receipt capture and export tool for mom-and-pop businesses that prioritizes accuracy transparency, offline reliability, and first-try CSV export success over complex automation promises.

### Key Differentiators
- **Honest OCR**: Shows confidence scores, makes corrections trivial
- **Offline-First**: Full functionality without network dependency
- **Export Excellence**: 99%+ first-try success with QuickBooks/Xero
- **Mobile-Optimized**: Camera-first workflow for owner-operators

### Success Metrics (v1.0)
- ≤110s capture-to-export workflow (p95)
- ≥98% CSV import success rate
- ≥70% zero-touch captures (clear photos)
- <50MB memory usage on iPhone 14/Samsung S22

---

## 1. Goals

### 1.1 Business Goals
- **Market Entry**: Capture 1,000 SMB users in first 6 months
- **Retention**: 60-day retention >40% 
- **Revenue Path**: Freemium with $9.99/mo pro tier (post-MVP)
- **Differentiation**: "It just works" reputation vs competitors

### 1.2 User Goals  
- **Time Savings**: Reduce receipt processing from 5min to <2min per receipt
- **Accuracy**: Eliminate manual re-entry for 70%+ of receipts
- **Compliance**: Export-ready CSVs for tax season
- **Peace of Mind**: Local storage, no cloud dependency

### 1.3 Technical Goals
- **Performance**: <5s OCR processing on mid-tier devices
- **Reliability**: 99.5%+ crash-free sessions
- **Compatibility**: iOS 16+, Android 13+
- **Maintainability**: Clean architecture for rapid iteration

---

## 2. Requirements

### 2.1 Functional Requirements

#### Core Capabilities
1. **Smart Camera Capture**
   - Auto edge detection with manual override
   - Multi-receipt batch mode
   - Image quality validation pre-OCR

2. **Transparent OCR Processing**  
   - Extract 4 fields: Merchant, Date, Total, Tax
   - Display confidence scores (0-100%)
   - Highlight low-confidence fields (<75%)

3. **Efficient Correction**
   - One-tap field editing
   - Smart keyboard (numeric for amounts)
   - Inline validation feedback

4. **Reliable Export**
   - QuickBooks Online CSV template
   - Xero CSV template  
   - Pre-export validation with error specifics
   - Batch export (multiple receipts)

5. **Offline-First Storage**
   - Local SQLite/RxDB persistence
   - Automatic image compression
   - Privacy-compliant data handling

### 2.2 Non-Functional Requirements

#### Performance
- Camera ready: <2s from app launch
- OCR processing: <5s for 4 fields
- Field editing: <100ms response time
- Export generation: <3s for 100 receipts

#### Reliability
- Crash-free rate: >99.5%
- Data loss prevention: Auto-save every edit
- Offline operation: 100% features work offline
- Error recovery: Graceful degradation

#### Usability
- Onboarding: <2min to first capture
- Learning curve: Zero training required
- Accessibility: WCAG 2.1 AA compliant
- Platform parity: Consistent iOS/Android UX

#### Security
- Local encryption: AES-256 for stored data
- No PII transmission: All processing on-device
- Privacy policy: Clear, GDPR-compliant
- Audit logging: Track all data operations

---

## 3. User Personas

### 3.1 Primary: Sarah - Restaurant Owner
- **Demographics**: 42, owns 2 cafes, 10 employees
- **Tech Level**: Comfortable with smartphones, basic apps
- **Pain Points**: 
  - Shoebox of receipts for accountant
  - QuickBooks rejects her manual CSVs
  - No time for complex software
- **Success Criteria**: Export month's receipts in <10min

### 3.2 Secondary: Mike - Freelance Contractor  
- **Demographics**: 35, solo operation, project-based work
- **Tech Level**: Power user, efficiency-focused
- **Pain Points**:
  - Loses receipts between job sites
  - Needs categorization for tax deductions
  - Wants to avoid subscription services
- **Success Criteria**: Capture receipt and move on in <30s

### 3.3 Tertiary: Linda - Bookkeeper
- **Demographics**: 58, manages books for 5 small businesses
- **Tech Level**: Expert in QuickBooks, learning mobile
- **Pain Points**:
  - Clients provide crumpled, faded receipts
  - Needs consistent CSV formatting
  - Must verify every transaction
- **Success Criteria**: Batch process 50 receipts with <5 corrections

---

## 4. Epics

### Epic 1: Capture & Extract
**Goal**: Seamless photo-to-data pipeline

#### User Stories
1. **As Sarah**, I want to capture multiple receipts quickly, so I can process a stack during downtime
   - Acceptance: Batch mode captures 10 receipts in <3min
   - Priority: P0

2. **As Mike**, I want automatic edge detection, so I don't waste time cropping
   - Acceptance: 80%+ success rate on standard receipts
   - Priority: P0

3. **As Linda**, I want to see OCR confidence scores, so I know what needs verification
   - Acceptance: Color-coded scores visible for each field
   - Priority: P0

4. **As Sarah**, I want to retry failed captures, so blurry photos don't block my workflow
   - Acceptance: Retry option immediately available
   - Priority: P1

### Epic 2: Review & Correct
**Goal**: Efficient error correction with transparency

#### User Stories
5. **As Linda**, I want to edit low-confidence fields inline, so corrections are fast
   - Acceptance: Single tap to edit, auto-keyboard selection
   - Priority: P0

6. **As Mike**, I want merchant name normalization, so "MCDONALDS #4521" becomes "McDonalds"
   - Acceptance: Common vendors cleaned automatically
   - Priority: P1

7. **As Sarah**, I want to add notes to receipts, so I can remember context
   - Acceptance: Optional note field, searchable
   - Priority: P2

8. **As Linda**, I want to see original image while editing, so I can verify accuracy
   - Acceptance: Zoomable image alongside fields
   - Priority: P1

### Epic 3: Organize & Export
**Goal**: Zero-friction data export

#### User Stories
9. **As Sarah**, I want to select date ranges for export, so I can match my accounting periods
   - Acceptance: Calendar picker with preset options
   - Priority: P0

10. **As Linda**, I want CSV format options, so I can match each client's system
    - Acceptance: QuickBooks & Xero templates included
    - Priority: P0

11. **As Mike**, I want to preview CSV before export, so I can catch issues
    - Acceptance: Show first 5 rows with headers
    - Priority: P1

12. **As Sarah**, I want export validation, so I know it will import successfully
    - Acceptance: Pre-flight check with specific warnings
    - Priority: P0

13. **As Linda**, I want to bulk delete processed receipts, so storage doesn't fill up
    - Acceptance: Multi-select with confirmation
    - Priority: P2

### Epic 4: Settings & Support
**Goal**: User control and assistance

#### User Stories
14. **As Mike**, I want to set default export format, so I don't repeat selections
    - Acceptance: Sticky preference in settings
    - Priority: P2

15. **As Sarah**, I want to see storage usage, so I know when to clean up
    - Acceptance: Visual indicator with management options
    - Priority: P2

16. **As Linda**, I want to adjust OCR confidence thresholds, so I can tune for accuracy vs speed
    - Acceptance: Slider with preview of impact
    - Priority: P3

17. **As Mike**, I want to export all data for backup, so I'm not locked in
    - Acceptance: Full JSON export option
    - Priority: P3

---

## 5. Acceptance Criteria

### 5.1 Feature-Level Criteria

#### Camera Capture
- ✅ Auto-focuses on receipt within 2s
- ✅ Edge detection highlights receipt boundaries
- ✅ Manual adjustment handles visible and responsive
- ✅ Capture button provides haptic feedback
- ✅ Processing indicator shows during OCR

#### OCR Extraction
- ✅ Merchant name extracted with 90%+ accuracy on clear photos
- ✅ Date extracted with 95%+ accuracy
- ✅ Total amount extracted with 95%+ accuracy  
- ✅ Tax amount extracted with 85%+ accuracy
- ✅ Confidence scores displayed as percentages

#### Field Editing
- ✅ Tap field to focus with appropriate keyboard
- ✅ Real-time validation (e.g., date format)
- ✅ Auto-save on field blur
- ✅ Visual confirmation of save

#### CSV Export
- ✅ QuickBooks format passes their validator
- ✅ Xero format passes their validator
- ✅ Export completes in <3s for 100 receipts
- ✅ File downloadable to device storage

### 5.2 System-Level Criteria

#### Performance
- ✅ Cold start to camera: <3s
- ✅ Memory usage: <50MB average, <75MB peak
- ✅ Battery drain: <5% for 30min session
- ✅ Storage: <10MB + photos

#### Reliability  
- ✅ Crash rate: <0.5% of sessions
- ✅ Data integrity: Zero corruption in 10,000 operations
- ✅ Offline mode: All features functional
- ✅ Error messages: User-actionable

#### Compatibility
- ✅ iOS: iPhone 12+ with iOS 16+
- ✅ Android: Pixel 5+ with Android 13+
- ✅ Tablets: Graceful scaling (not optimized)
- ✅ Orientation: Portrait primary, landscape functional

---

## 6. Competitive Analysis

### 6.1 Direct Competitors

#### Expensify
- **Strengths**: SmartScan, bank integration, enterprise features
- **Weaknesses**: Overkill for SMBs, $5-9/user/month, online-required
- **Our Advantage**: Simpler, cheaper, works offline

#### Receipt Bank (Dext)
- **Strengths**: Accurate OCR, accountant integration
- **Weaknesses**: £20+/month, complex onboarding
- **Our Advantage**: Self-serve, transparent pricing

#### Shoeboxed  
- **Strengths**: Mail-in scanning service
- **Weaknesses**: $18-58/month, slow turnaround
- **Our Advantage**: Instant processing, no recurring cost (MVP)

### 6.2 Indirect Competitors

#### QuickBooks Mobile
- **Strengths**: Integrated with accounting
- **Weaknesses**: Requires QuickBooks subscription
- **Our Advantage**: Platform-agnostic

#### Google Drive + Lens
- **Strengths**: Free, powerful OCR
- **Weaknesses**: Manual process, no receipt optimization
- **Our Advantage**: Purpose-built workflow

### 6.3 Competitive Positioning

**"The honest receipt app that just works"**
- Where others promise AI magic, we deliver reliable basics
- Where others require subscriptions, we work out-of-the-box
- Where others need training, we're intuitive from tap one

---

## 7. Release Criteria

### 7.1 MVP Launch Requirements

#### Must Have (P0)
- ✅ Camera capture with edge detection
- ✅ OCR for 4 fields with confidence scores
- ✅ Inline editing with validation
- ✅ QuickBooks & Xero CSV export
- ✅ Offline-first storage
- ✅ Basic receipt list view

#### Should Have (P1)
- ⏸️ Batch capture mode
- ⏸️ Merchant normalization
- ⏸️ Image zoom during editing
- ⏸️ CSV preview
- ⏸️ Date range filtering

#### Nice to Have (P2-P3)
- ❌ Receipt notes/categories
- ❌ Bulk operations
- ❌ Settings customization
- ❌ Data export/backup

### 7.2 Quality Gates

#### Pre-Beta
- [ ] Core flow works end-to-end
- [ ] Memory usage <75MB
- [ ] No critical crashes in 100 operations

#### Beta Exit
- [ ] 50 beta users processed 1,000+ receipts
- [ ] <5% report blocking issues
- [ ] CSV export success rate >95%

#### Public Launch
- [ ] 99.5% crash-free sessions
- [ ] App store rating potential >4.0
- [ ] Support volume <5% of DAU

### 7.3 Success Metrics (Month 1)

#### Adoption
- 1,000+ downloads
- 500+ monthly active users
- 100+ receipts/day processed

#### Quality
- App rating ≥4.0
- Crash rate <0.5%
- Uninstall rate <40%

#### Engagement  
- Day 1 retention >60%
- Day 7 retention >40%
- Day 30 retention >25%

---

## 8. Appendices

### 8.1 Technical Notes

#### OCR Engine Decision
After testing (see research docs):
- **Selected**: Google ML Kit (primary) + TensorFlow Lite (fallback)
- **Rejected**: PaddleOCR (20GB memory leak), Tesseract (slow)
- **Rationale**: Best accuracy/performance balance on mobile

#### Platform Decision
- **Selected**: Flutter 3.24+ 
- **Rejected**: React Native (camera issues), Native (2x development)
- **Rationale**: Single codebase, good camera plugins, proven OCR integration

#### Database Decision
- **Selected**: RxDB with SQLite adapter
- **Rejected**: Realm (licensing), Firebase (online requirement)
- **Rationale**: Offline-first, reactive updates, encryption support

### 8.2 Research References

1. **OCR Accuracy Study** (docs/OCR_Confidence_Threshold_Optimization_Research.md)
   - 75-85% confidence threshold optimal
   - User trust higher with visible scores

2. **Competitor Analysis** (docs/competitor-analysis.md)
   - Feature parity mapping
   - Pricing strategy insights
   - UX pain points to avoid

3. **Device Capability Audit** (MOBILE_DEVICE_CAMERA_TESTING_GUIDE.md)
   - iPhone 14/Samsung S22 as target baseline
   - 89-92% OCR accuracy achievable

### 8.3 Future Roadmap (v2.0+)

#### Q2 2025
- Receipt categories/tags
- Basic search/filter
- Cloud backup option

#### Q3 2025  
- Multi-user/business accounts
- Approval workflows
- Email-in receipt capture

#### Q4 2025
- Line-item extraction
- Expense report generation
- Accounting software APIs

### 8.4 Glossary

- **Confidence Score**: OCR engine's certainty (0-100%) for extracted text
- **Edge Detection**: Algorithm to find receipt boundaries in photo
- **Normalization**: Cleaning merchant names for consistency
- **Pre-flight Validation**: Checking CSV format before export
- **Zero-touch**: Receipt requiring no manual corrections

---

**Document Control**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 0.1 | 2024-12-20 | PM | Initial draft |
| 0.5 | 2024-12-27 | PM | User stories added |
| 0.9 | 2025-01-03 | PM | Research integration |
| 1.0 | 2025-01-05 | PM | Final review complete |

**Sign-off**
- Product: ✅ Peter Drucker
- Engineering: ⏳ Pending architect review
- Design: ✅ Sally (UX Expert)
- QA: ⏳ Pending test plan