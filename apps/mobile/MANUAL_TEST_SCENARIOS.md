# Manual Test Scenarios - Receipt Organizer MVP

## Overview

This document contains detailed manual test scenarios for the Receipt Organizer application. Each scenario represents a real-world user journey that should be tested on actual devices.

## Test Environment Setup

### Prerequisites
- Physical iOS device (iPhone)
- Physical Android device  
- Test receipts (various conditions)
- QuickBooks/Xero test accounts
- Stable WiFi and cellular connections

### Test Data Preparation
- 10+ physical receipts (various merchants)
- 5+ crumpled/folded receipts
- 3+ faded thermal receipts
- 2+ receipts with handwritten notes
- Multi-language receipts (if available)

---

## Scenario 1: First-Time User Experience

### Objective
Verify smooth onboarding for new users

### Steps
1. **Fresh Install**
   - Install app from TestFlight/Play Store
   - Launch app for first time
   - ✓ App launches within 3 seconds
   - ✓ No crash on first launch

2. **Permissions Flow**
   - Tap "Start Capturing Receipts"
   - ✓ Camera permission prompt appears
   - Grant camera permission
   - ✓ Camera preview loads immediately
   - ✓ UI provides clear next steps

3. **First Receipt Capture**
   - Point at a clear receipt
   - ✓ Auto-capture triggers when edges detected
   - ✓ Preview shows captured image
   - ✓ OCR processing starts automatically
   - ✓ Results display within 5 seconds

4. **Field Verification**
   - ✓ Merchant name extracted correctly
   - ✓ Date appears in correct format
   - ✓ Total amount identified
   - ✓ Tax amount found (if present)

### Expected Results
- Smooth flow from install to first capture
- No confusion about next steps
- Successful OCR on first attempt

### Pass/Fail: [ ]

---

## Scenario 2: Batch Capture Session

### Objective
Test continuous capture of multiple receipts

### Context
User is a bookkeeper processing monthly receipts

### Steps
1. **Start Batch Mode**
   - Open app
   - Navigate to Batch Capture
   - ✓ Counter shows "0 captured"

2. **Rapid Capture (10 receipts)**
   - Capture receipt 1 → ✓ Counter updates to "1"
   - Immediately capture receipt 2 → ✓ Counter updates  
   - Continue for 10 receipts
   - ✓ No significant slowdown
   - ✓ Memory usage stable
   - ✓ All images saved

3. **Review Batch**
   - Tap "Review Batch"
   - ✓ All 10 receipts display
   - ✓ Can swipe between receipts
   - ✓ OCR results show for each

4. **Edit Fields**
   - Select receipt with wrong merchant
   - Tap merchant field
   - Type correction
   - ✓ Auto-save indicator appears
   - ✓ Change persists

5. **Batch Export**
   - Tap "Export All"
   - Select QuickBooks format
   - ✓ CSV generates with all 10 receipts
   - ✓ Can share via email
   - ✓ File size reasonable

### Expected Results
- Can capture 10+ receipts rapidly
- No performance degradation
- All data preserved correctly

### Pass/Fail: [ ]

---

## Scenario 3: Poor Condition Receipt

### Objective
Test OCR with challenging receipts

### Steps
1. **Crumpled Receipt**
   - Take crumpled receipt
   - Attempt capture without smoothing
   - ✓ Edge detection struggles (expected)
   - Smooth receipt partially
   - ✓ Manual capture available
   - Capture with manual trigger
   - ✓ OCR attempts processing

2. **Faded Thermal Receipt**
   - Use old faded receipt
   - Capture in good lighting
   - ✓ Low confidence warning appears
   - ✓ Can edit all fields manually
   - ✓ Original image retained

3. **Partial Receipt**
   - Use torn receipt (missing bottom)
   - Capture visible portion
   - ✓ Extracts available data
   - ✓ Missing total handled gracefully
   - ✓ Can manually add total

4. **Blurry Capture**
   - Intentionally shake during capture
   - ✓ Blur warning appears
   - ✓ Suggests retaking
   - ✓ Can retry capture
   - ✓ Previous attempt saved

### Expected Results
- App handles poor quality gracefully
- Always allows manual editing
- Provides helpful guidance

### Pass/Fail: [ ]

---

## Scenario 4: Offline Workflow

### Objective
Verify full offline functionality

### Steps
1. **Enable Airplane Mode**
   - Turn on airplane mode
   - Open app
   - ✓ No errors or warnings

2. **Capture Receipts Offline**
   - Capture 5 receipts
   - ✓ All captures work
   - ✓ OCR processes locally
   - ✓ Results display normally

3. **Edit and Organize Offline**
   - Edit merchant names
   - Change dates
   - Add notes
   - ✓ All edits save locally
   - ✓ No sync errors shown

4. **Export Offline**
   - Generate CSV export
   - ✓ File creates successfully
   - ✓ Can save to device
   - ✓ Can view in Files app

5. **Restore Connectivity**
   - Disable airplane mode
   - ✓ App continues normally
   - ✓ No data loss
   - ✓ No duplicate processing

### Expected Results
- 100% functionality offline
- Seamless online/offline transition
- No data loss

### Pass/Fail: [ ]

---

## Scenario 5: Interrupted Operations

### Objective
Test app resilience to interruptions

### Steps
1. **Phone Call During Capture**
   - Start capturing receipt
   - Receive phone call (have someone call)
   - Answer call
   - ✓ App suspends gracefully
   - End call and return
   - ✓ Can resume capture
   - ✓ No crash or data loss

2. **Low Battery During OCR**
   - Start batch capture (5+ receipts)
   - Trigger low battery warning (15%)
   - ✓ Can complete current operation
   - ✓ Warning about saving work
   - ✓ Can export immediately

3. **App Kill During Processing**
   - Capture receipt
   - During OCR, swipe up to kill app
   - Relaunch app
   - ✓ Recovers gracefully
   - ✓ Shows last state
   - ✓ Image not lost

4. **Storage Full**
   - Fill device storage to <100MB
   - Attempt capture
   - ✓ Storage warning appears
   - ✓ Can view existing receipts
   - ✓ Export still works

### Expected Results
- Graceful handling of all interruptions
- No data loss
- Clear user communication

### Pass/Fail: [ ]

---

## Scenario 6: Multi-Language Receipt

### Objective
Test non-English receipt handling

### Steps
1. **Spanish Receipt**
   - Capture receipt from Spanish store
   - ✓ Text extracted (may be imperfect)
   - ✓ Numbers extracted correctly
   - ✓ Can edit to correct text

2. **Receipt with Accents**
   - French café receipt (Café, naïve, etc.)
   - ✓ Accented characters preserved
   - ✓ Export maintains encoding
   - ✓ Imports to accounting software

3. **Mixed Language**
   - Receipt with English and Spanish
   - ✓ Both languages attempted
   - ✓ Numbers consistent
   - ✓ Manual correction available

### Expected Results
- Basic multi-language support
- Numbers always work
- Can manually correct

### Pass/Fail: [ ]

---

## Scenario 7: Export Variations

### Objective
Test different export scenarios

### Steps
1. **Single Receipt Export**
   - Select one receipt
   - Export as CSV
   - ✓ Single row CSV generated
   - ✓ Headers included
   - ✓ Opens in Excel

2. **Date Range Export**
   - Set date range (last 7 days)
   - Export matching receipts
   - ✓ Only selected dates included
   - ✓ Sorted by date
   - ✓ Summary row (optional)

3. **Large Export (50+ receipts)**
   - Select all receipts
   - Export to CSV
   - ✓ Progress indicator shown
   - ✓ Completes within 30 seconds
   - ✓ File size manageable
   - ✓ All data preserved

4. **Format Switching**
   - Export as QuickBooks
   - Export same data as Xero
   - Export as Generic
   - ✓ All three files different
   - ✓ Formats correct
   - ✓ Data consistent

### Expected Results
- Flexible export options
- Fast performance
- Format accuracy

### Pass/Fail: [ ]

---

## Scenario 8: Merchant Normalization

### Objective
Test merchant name standardization

### Steps
1. **Franchise Variations**
   - Capture "WALMART #1234"
   - ✓ Normalizes to "Walmart"
   - Capture "WALMART SUPERCENTER"
   - ✓ Also normalizes to "Walmart"

2. **Manual Override**
   - Capture "STARBUCKS"
   - ✓ Shows as "Starbucks"
   - Edit to "Starbucks - Downtown"
   - ✓ Keeps custom name
   - ✓ Doesn't revert

3. **Unknown Merchant**
   - Capture receipt from local store
   - ✓ Keeps original OCR text
   - ✓ No failed normalization
   - ✓ Can edit manually

### Expected Results
- Smart normalization
- Respects user edits
- No over-normalization

### Pass/Fail: [ ]

---

## Scenario 9: Accessibility Testing

### Objective
Verify app usability with accessibility features

### Steps
1. **VoiceOver/TalkBack**
   - Enable screen reader
   - Navigate entire app
   - ✓ All buttons labeled
   - ✓ Images have descriptions
   - ✓ Can complete capture flow

2. **Large Text**
   - Set system to largest text
   - ✓ Text doesn't overflow
   - ✓ Buttons still tappable
   - ✓ Layout remains usable

3. **One-Handed Use**
   - Hold phone in one hand
   - ✓ Can reach all controls
   - ✓ Critical actions thumb-accessible
   - ✓ No required two-hand gestures

### Expected Results
- Fully accessible app
- No barriers to usage
- Clear navigation

### Pass/Fail: [ ]

---

## Scenario 10: Edge Cases

### Objective
Test unusual but possible scenarios

### Steps
1. **$0.00 Receipt**
   - Create receipt for free sample
   - ✓ Accepts $0.00 amount
   - ✓ Can add notes explaining
   - ✓ Exports correctly

2. **Foreign Currency Symbol**
   - Receipt showing €50.00
   - ✓ Recognizes numbers
   - ✓ Currency noted somewhere
   - ✓ Can edit to USD

3. **Multiple Receipts in Photo**
   - Place 2 receipts side by side
   - Attempt capture
   - ✓ Detects issue or picks one
   - ✓ Guides to single receipt
   - ✓ No crash

4. **Extreme Aspect Ratios**
   - Very long receipt (CVS style)
   - ✓ Captures full length
   - ✓ Can view/zoom entire receipt
   - Very wide receipt
   - ✓ Handles appropriately

5. **Receipt on Colored Background**
   - Place on red/blue surface
   - ✓ Edge detection compensates
   - ✓ Or manual capture works
   - ✓ OCR not affected

### Expected Results
- Handles edge cases gracefully
- No crashes
- Reasonable fallbacks

### Pass/Fail: [ ]

---

## Performance Benchmarks

Track these metrics during testing:

### Speed Metrics
- [ ] Cold start: _____ seconds (target: <3s)
- [ ] Warm start: _____ seconds (target: <1s)
- [ ] Capture to OCR: _____ seconds (target: <5s)
- [ ] 10-receipt export: _____ seconds (target: <10s)

### Resource Usage
- [ ] RAM idle: _____ MB (target: <100MB)
- [ ] RAM during OCR: _____ MB (target: <200MB)
- [ ] Storage per receipt: _____ KB (target: <500KB)
- [ ] Battery drain: _____% per hour active use

### Reliability
- [ ] Crashes during session: _____ (target: 0)
- [ ] Failed OCR attempts: _____% (target: <10%)
- [ ] Successful exports: _____% (target: 100%)

---

## Overall Test Summary

### Critical Features
- [ ] Camera capture works reliably
- [ ] OCR processes successfully
- [ ] Data persists correctly
- [ ] Export generates valid CSV
- [ ] Offline mode fully functional

### User Experience
- [ ] Intuitive flow
- [ ] Fast performance
- [ ] Error recovery
- [ ] Clear feedback

### Pass/Fail Criteria
- All Critical Features must pass
- 90% of scenarios should pass
- No data loss scenarios
- No security vulnerabilities

### Final Verdict: [ ] PASS / [ ] FAIL

### Tester Information
- Name: _____________________
- Date: _____________________
- Devices tested: _____________________
- Version tested: _____________________
- Total test time: _____ hours

### Notes and Recommendations
_________________________________
_________________________________
_________________________________
_________________________________