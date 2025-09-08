# Android Device Testing Checklist - September 2025

## Pre-Testing Requirements

### Environment Setup
- [ ] Android SDK 21+ (minSdkVersion requirement)
- [ ] Physical Android devices from multiple manufacturers
- [ ] Android Studio updated to latest stable
- [ ] ADB debugging enabled on all test devices
- [ ] Firebase Test Lab access (optional but recommended)

### Build Verification
- [ ] Clean build: `flutter clean`
- [ ] Delete build artifacts: `rm -rf android/.gradle android/app/build`
- [ ] Fresh build: `flutter build apk --debug`
- [ ] Verify APK size is reasonable (<50MB)
- [ ] Check for build warnings in gradle

## Core Functionality Tests

### 1. Camera Integration (CameraX - camera 0.11.0+2)

#### CameraX Compatibility
- [ ] **Initial Setup**
  - First launch camera permission request
  - Permission dialog shows correctly
  - Grant permission
  - Camera preview initializes

- [ ] **CameraX Features**
  - Preview displays correctly
  - Auto-focus works on tap
  - Exposure adjustment functions
  - Zoom controls work smoothly
  - Flash modes (auto/on/off/torch)

- [ ] **Device-Specific Camera Issues**
  - Samsung: Test on One UI devices
  - Xiaomi/Redmi: Test MIUI camera permissions
  - OnePlus: Test OxygenOS compatibility
  - Google Pixel: Verify Camera2 API usage
  - Huawei: Test without Google Services

- [ ] **Edge Cases**
  - Multiple camera app usage
  - Switch between native camera and app
  - Background/foreground transitions
  - Camera during low memory conditions

### 2. OCR Processing (google_mlkit_text_recognition)
- [ ] **ML Kit Model Management**
  - First-time model download
  - Model updates handled gracefully
  - Offline model availability
  - Storage space for models (~20MB)

- [ ] **Performance by Device Class**
  - **High-end** (Snapdragon 8 Gen 2/3): <2s processing
  - **Mid-range** (Snapdragon 7 series): <5s processing
  - **Budget** (Snapdragon 4 series): <10s processing
  - **Legacy** (3+ years old): Functions without crash

- [ ] **Text Recognition Quality**
  - Standard receipts: 90%+ accuracy
  - Thermal receipts: 85%+ accuracy
  - Handwritten additions: Detected but may be inaccurate
  - Non-Latin characters: Basic support

### 3. Android Version Specific Testing

#### Android 14 (API 34) - Latest
- [ ] Predictive back gesture works
- [ ] Photo picker integration
- [ ] Foreground service restrictions respected
- [ ] Themed icons display correctly

#### Android 13 (API 33)
- [ ] Photo picker available
- [ ] Notification permissions handled
- [ ] Themed icons work
- [ ] Language preferences respected

#### Android 12/12L (API 31-32)
- [ ] Material You theming works
- [ ] Splash screen displays correctly
- [ ] Privacy dashboard shows appropriate usage
- [ ] Overscroll animations work

#### Android 11 (API 30)
- [ ] Scoped storage compliance
- [ ] Package visibility handled
- [ ] One-time permissions work
- [ ] Auto-reset permissions handled

#### Android 10 (API 29)
- [ ] Dark theme support
- [ ] Gesture navigation compatible
- [ ] Location permissions (if used)

#### Android 9 (API 28)
- [ ] Cutout display support
- [ ] Adaptive battery compatible
- [ ] Security patches don't break app

#### Android 8/8.1 (API 26-27)
- [ ] Notification channels work
- [ ] Background limits respected
- [ ] Adaptive icons display

#### Android 7/7.1 (API 24-25)
- [ ] Multi-window support
- [ ] Direct boot aware
- [ ] File provider works

#### Android 6 (API 23)
- [ ] Runtime permissions work
- [ ] Doze mode handling
- [ ] App standby behavior

#### Android 5/5.1 (API 21-22) - Minimum
- [ ] Basic functionality works
- [ ] Material Design renders
- [ ] No crashes on launch
- [ ] Camera functions (may use Camera2)

### 4. Storage & File System
- [ ] **Scoped Storage (Android 11+)**
  - Images save correctly
  - Can access own files
  - Media Store integration works
  - No legacy storage access

- [ ] **File Paths**
  - Internal storage paths work
  - Cache directory used appropriately
  - External storage not required
  - Cleanup on uninstall

- [ ] **Storage Permissions**
  - No WRITE_EXTERNAL_STORAGE needed (Android 11+)
  - READ_EXTERNAL_STORAGE only if needed
  - Storage Access Framework works
  - Document picker integration

### 5. Export Functionality
- [ ] **CSV Export**
  - Export to Downloads folder
  - Share via intent works
  - Gmail attachment works
  - Google Drive upload works
  - Bluetooth transfer works

- [ ] **File Formats**
  - UTF-8 encoding correct
  - Special characters preserved
  - Line endings appropriate
  - File extension associations work

### 6. Performance Testing

#### Memory Management
- [ ] **RAM Usage Monitoring**
  - Normal operation: <150MB
  - During OCR: <300MB
  - Memory released after operations
  - No memory leaks detected

- [ ] **Low Memory Behavior**
  - Test with many apps open
  - Force low memory conditions
  - App handles killing gracefully
  - State restored on restart

#### CPU Usage
- [ ] OCR doesn't block UI thread
- [ ] Background processing efficient
- [ ] No ANRs during operation
- [ ] Smooth scrolling maintained

### 7. Manufacturer-Specific Testing

#### Samsung Devices
- [ ] Samsung Galaxy S24/S23 (Flagship)
- [ ] Galaxy A54/A34 (Mid-range)
- [ ] Edge panel doesn't interfere
- [ ] S Pen support (if applicable)
- [ ] Samsung DeX compatibility
- [ ] One UI specific features

#### Google Pixel
- [ ] Pixel 8/8 Pro (Latest)
- [ ] Pixel 7a (Mid-range)
- [ ] Pixel 5a (Older)
- [ ] Stock Android behavior
- [ ] Quick tap gestures
- [ ] Live Caption doesn't interfere

#### Xiaomi/Redmi
- [ ] Xiaomi 14/13 (Flagship)
- [ ] Redmi Note series
- [ ] MIUI permissions
- [ ] Battery optimization
- [ ] Ads don't interfere
- [ ] Dark mode works

#### OnePlus
- [ ] OnePlus 12/11
- [ ] OxygenOS features
- [ ] Zen mode compatibility
- [ ] Alert slider doesn't affect

#### OPPO/Vivo/Realme
- [ ] ColorOS/FuntouchOS
- [ ] Aggressive battery management
- [ ] Permission handling
- [ ] Clone apps support

#### Motorola
- [ ] Moto G series
- [ ] Moto Actions compatible
- [ ] Near-stock experience
- [ ] Gesture navigation

### 8. Android Features Integration

#### Widgets (if applicable)
- [ ] Home screen widgets work
- [ ] Update correctly
- [ ] Resize properly
- [ ] Actions work from widget

#### Shortcuts
- [ ] App shortcuts work
- [ ] Long press on icon
- [ ] Quick capture shortcut
- [ ] Dynamic shortcuts update

#### Assistant Integration
- [ ] "Hey Google" commands
- [ ] App actions work
- [ ] Routines compatible

### 9. Connectivity Testing

#### Offline Mode
- [ ] Airplane mode functionality
- [ ] All features work offline
- [ ] No network calls attempted
- [ ] Error messages appropriate

#### Network Conditions
- [ ] 2G/EDGE speeds
- [ ] Unstable connection
- [ ] VPN compatibility
- [ ] Proxy support

### 10. Security Testing

#### Data Security
- [ ] No plain text storage
- [ ] SharedPreferences encrypted
- [ ] Database encrypted
- [ ] No sensitive data in logs

#### App Security
- [ ] ProGuard/R8 doesn't break functionality
- [ ] Certificate pinning (if used)
- [ ] No debugging enabled in release
- [ ] Backup restrictions appropriate

### 11. Accessibility Testing

#### TalkBack
- [ ] Navigation possible
- [ ] All elements labeled
- [ ] Actions announced
- [ ] Focus order logical

#### Display Options
- [ ] Large text support
- [ ] High contrast works
- [ ] Color blind modes
- [ ] Font scaling handled

### 12. Power Management

#### Battery Usage
- [ ] Doze mode compliance
- [ ] App standby handling
- [ ] Battery optimization
- [ ] Wake locks appropriate

#### Background Restrictions
- [ ] Foreground service (if used)
- [ ] JobScheduler/WorkManager
- [ ] No excessive background activity
- [ ] Push notifications work

### 13. Play Store Requirements

#### Target SDK Compliance
- [ ] Targets latest SDK
- [ ] 64-bit support
- [ ] App Bundle ready
- [ ] Permissions justified

#### Content Rating
- [ ] No violations
- [ ] Age appropriate
- [ ] Data safety filled
- [ ] Privacy policy linked

### 14. Error Scenarios

#### Permission Handling
- [ ] Camera denied
- [ ] Storage denied
- [ ] All permissions denied
- [ ] Settings navigation works

#### System Integration
- [ ] Default apps handling
- [ ] Intent filters work
- [ ] Deep links function
- [ ] App links verified

### 15. Update Testing

#### In-app Updates
- [ ] Update notification works
- [ ] Flexible update flow
- [ ] Immediate update flow
- [ ] Update doesn't lose data

#### Migration Testing
- [ ] Old version → New version
- [ ] Database migrations work
- [ ] Preferences preserved
- [ ] No data loss

## Device Test Matrix

### High Priority Devices
- [ ] Samsung Galaxy S24 (Android 14)
- [ ] Google Pixel 8 (Android 14)
- [ ] Samsung Galaxy A54 (Android 13)
- [ ] Xiaomi Redmi Note 12 (Android 13)
- [ ] OnePlus 11 (Android 13)

### Medium Priority Devices
- [ ] Samsung Galaxy S21 (Android 12)
- [ ] Google Pixel 5 (Android 12)
- [ ] Motorola Moto G Power (Android 11)
- [ ] OPPO Reno8 (Android 12)
- [ ] Realme 10 Pro (Android 13)

### Low Priority Devices
- [ ] Samsung Galaxy S10 (Android 10)
- [ ] LG G8 (Android 10)
- [ ] OnePlus 6T (Android 9)
- [ ] Xiaomi Mi 9 (Android 9)
- [ ] Legacy device (Android 5/6)

## Performance Benchmarks

### Target Metrics
- [ ] App size < 50MB (APK)
- [ ] Cold start < 3s
- [ ] Warm start < 1s
- [ ] OCR processing < 5s (average device)
- [ ] Memory usage < 200MB (normal)
- [ ] Battery drain < 5%/hour active use
- [ ] Crash rate < 1%
- [ ] ANR rate < 0.5%

## Sign-off Criteria

### Functionality
- [ ] All core features work across device matrix
- [ ] No crashes during 1-hour usage session
- [ ] Data integrity maintained
- [ ] Export/Import works correctly

### Performance
- [ ] Meets benchmark targets
- [ ] Smooth UI (60 FPS)
- [ ] No jank in animations
- [ ] Responsive to input

### Compatibility
- [ ] Android 5.0+ support verified
- [ ] Major manufacturers tested
- [ ] Different screen sizes handled
- [ ] Various Android skins compatible

## Issues Log

### Critical (P0)
1. 
2. 

### High (P1)
1. 
2. 

### Medium (P2)
1. 
2. 

### Low (P3)
1. 
2. 

## Testing Metadata
- Test date: 
- Tester: 
- APK version: 
- Build flavor: 
- Test duration: 

## Recommendations
1. 
2. 
3. 

## CameraX Specific Notes
- Fallback to Camera2 API available: Yes/No
- CameraX version compatibility issues: 
- Device-specific workarounds needed: 