# iOS Device Testing Checklist - September 2025

## Pre-Testing Requirements

### Environment Setup
- [ ] iOS 15.5 or higher (required for google_mlkit_text_recognition)
- [ ] Physical iPhone and iPad devices available
- [ ] TestFlight configured for beta testing
- [ ] Crash reporting enabled (Firebase Crashlytics or similar)

### Build Verification
- [ ] Clean build folder: `flutter clean`
- [ ] Delete iOS build artifacts: `rm -rf ios/Pods ios/Podfile.lock`
- [ ] Fresh pod install: `cd ios && pod install`
- [ ] Verify no build warnings in Xcode

## Core Functionality Tests

### 1. Camera Integration (camera 0.11.0+2)
- [ ] **Initial Camera Permission**
  - Launch app fresh install
  - Tap camera button
  - Verify permission dialog appears
  - Grant permission
  - Verify camera preview loads

- [ ] **Camera Preview Quality**
  - Check preview is smooth (30+ FPS)
  - No visual artifacts or distortion
  - Correct orientation in all device orientations
  - Auto-focus works properly

- [ ] **Photo Capture**
  - Single photo capture works
  - Flash modes (auto/on/off) function correctly
  - Photo saves to app storage
  - Memory usage stays reasonable

- [ ] **Camera Switching**
  - Switch between front/back cameras
  - Maintains settings between switches
  - No crashes during rapid switching

### 2. OCR Processing (google_mlkit_text_recognition)
- [ ] **Text Recognition Accuracy**
  - Test with clear receipt image
  - Test with slightly blurred image
  - Test with angled receipt
  - Test with different lighting conditions
  - Verify 90%+ accuracy on clear images

- [ ] **Performance Metrics**
  - Measure processing time (target: <5s for standard receipt)
  - Check CPU usage during processing
  - Monitor memory spikes
  - No UI freezing during OCR

- [ ] **Multi-Language Support**
  - Test English receipts
  - Test receipts with accented characters
  - Test mixed language receipts
  - Verify TextRecognitionScript.latin handles all cases

- [ ] **Field Extraction**
  - Merchant name extracted correctly
  - Date parsed accurately
  - Total amount identified
  - Tax amount found when present

### 3. Batch Capture Flow
- [ ] **Sequential Capture**
  - Capture 5 receipts in succession
  - Verify each saves correctly
  - Check memory doesn't accumulate
  - UI remains responsive

- [ ] **Batch Size Limits**
  - Test with 10 receipts
  - Test with 25 receipts
  - Verify performance acceptable
  - Check storage usage

### 4. Image Storage & Management
- [ ] **Image Quality Settings**
  - Verify compression works (flutter_image_compress 2.4.0)
  - Check file sizes are reasonable
  - Confirm images remain readable after compression
  - Test different quality settings

- [ ] **Storage Paths**
  - Images save to correct directory
  - Thumbnails generate properly
  - Old images can be accessed
  - Cleanup of deleted receipts works

### 5. Data Persistence (sqflite 2.4.2)
- [ ] **Database Operations**
  - Create new receipts
  - Update existing receipts
  - Delete receipts
  - Search functionality works
  - No data corruption

- [ ] **Offline Functionality**
  - Turn on Airplane mode
  - All features work offline
  - Data persists correctly
  - No crashes without network

### 6. Export Functionality
- [ ] **CSV Generation**
  - Export to generic format
  - Export to QuickBooks format
  - Export to Xero format
  - Special characters handled correctly
  - Large exports (100+ receipts) work

- [ ] **File Sharing**
  - Share sheet appears
  - Can save to Files app
  - Can share via email
  - Can AirDrop to Mac
  - File permissions correct

### 7. UI/UX Testing
- [ ] **Screen Transitions**
  - No flicker or jank
  - Animations smooth
  - Proper back navigation
  - Modal dismissal works

- [ ] **Gesture Recognition**
  - Swipe gestures respond correctly
  - Pinch-to-zoom on images works
  - Pull-to-refresh functions
  - Long press actions work

- [ ] **Dark Mode**
  - UI readable in dark mode
  - Colors have sufficient contrast
  - Images display correctly
  - Icons visible

### 8. Performance Testing
- [ ] **App Launch Time**
  - Cold start < 3 seconds
  - Warm start < 1 second
  - No splash screen hang

- [ ] **Memory Usage**
  - Monitor with Xcode Instruments
  - No memory leaks detected
  - Memory returns to baseline after operations
  - Background memory reasonable

- [ ] **Battery Usage**
  - Normal usage doesn't drain battery excessively
  - Camera usage has reasonable power consumption
  - Background processing minimal

### 9. Device-Specific Testing

#### iPhone Models
- [ ] **iPhone 15 Pro Max** (Latest flagship)
  - ProMotion display (120Hz) smooth
  - Dynamic Island doesn't interfere
  - All features work

- [ ] **iPhone 14** (Previous generation)
  - Standard performance acceptable
  - Camera integration works
  - No specific issues

- [ ] **iPhone 12 Mini** (Smallest screen)
  - UI scales properly
  - All text readable
  - Buttons accessible
  - Keyboard doesn't cover inputs

- [ ] **iPhone SE 3rd Gen** (Budget/Older processor)
  - Performance acceptable
  - No crashes
  - OCR processing under 10s

#### iPad Models
- [ ] **iPad Pro 12.9"** (Largest screen)
  - Landscape orientation works
  - Split view compatible
  - UI uses space efficiently
  - Keyboard shortcuts work

- [ ] **iPad Mini** (Smallest tablet)
  - UI elements properly sized
  - Touch targets adequate
  - Camera preview scales correctly

### 10. iOS Feature Integration
- [ ] **Files App Integration**
  - Can import images from Files
  - Can export CSVs to Files
  - Document browser works

- [ ] **Shortcuts App**
  - Basic shortcuts work
  - Quick capture shortcut functions
  - No crashes from Shortcuts

- [ ] **Accessibility**
  - VoiceOver navigation works
  - Dynamic Type supported
  - Sufficient color contrast
  - Reduce Motion respected

### 11. Error Scenarios
- [ ] **Permission Denied**
  - Camera permission denied handling
  - Storage permission issues
  - Proper error messages shown
  - Settings deep link works

- [ ] **Low Storage**
  - App handles low storage gracefully
  - Appropriate warnings shown
  - Can still view existing data
  - Exports still work

- [ ] **Interrupted Operations**
  - Phone call during capture
  - App backgrounding during OCR
  - Notification interruptions
  - All recover gracefully

### 12. Update Scenarios
- [ ] **App Update Testing**
  - Install previous version
  - Add some receipts
  - Update to new version
  - Verify data migrates correctly
  - No crashes on first launch

### 13. Localization
- [ ] **Language Testing**
  - Test with device in different languages
  - Number formats respect locale
  - Date formats correct
  - Currency symbols appropriate

### 14. Network Conditions
- [ ] **Poor Connectivity**
  - 3G/Edge network speeds
  - Intermittent connection
  - Operations timeout appropriately
  - Offline mode engages

### 15. Security Testing
- [ ] **Data Protection**
  - App doesn't screenshot sensitive data
  - Receipts not visible in app switcher
  - Biometric lock works if implemented
  - Keychain storage secure

## Sign-Off Criteria

### Performance Benchmarks
- [ ] 95% crash-free sessions
- [ ] <5s receipt processing time (95th percentile)
- [ ] <3s cold start time
- [ ] <100MB memory usage during normal operation
- [ ] Battery usage "Good" or better in Settings

### User Experience
- [ ] All critical user journeys complete without error
- [ ] No UI glitches or layout issues
- [ ] Smooth animations (60 FPS minimum)
- [ ] Responsive to user input (<100ms feedback)

### Compatibility
- [ ] iOS 15.5+ all working
- [ ] All tested devices pass
- [ ] No architecture-specific crashes
- [ ] Universal app works on iPhone and iPad

## Issues Found

### Critical (Must Fix)
1. 
2. 

### Major (Should Fix)
1. 
2. 

### Minor (Nice to Fix)
1. 
2. 

## Testing Notes
- Date tested: 
- Tester name: 
- Build version: 
- Test environment: 

## Recommendations
1. 
2. 
3.