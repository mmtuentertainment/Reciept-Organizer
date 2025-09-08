# Known Issues and Workarounds

## Overview

This document tracks known issues, limitations, and their workarounds for the Receipt Organizer MVP as of the September 2025 mid-development audit. These issues are categorized by severity and include recommended solutions or mitigations.

## Test Suite Issues

### 1. Failing Tests (144 tests)

**Issue**: 144 tests are currently failing due to logic issues, not compilation errors.

**Severity**: High

**Root Causes**:
- Mock behavior mismatches after dependency updates
- State management changes from Riverpod 2.6.1 migration
- Async handling differences in updated packages
- Test data fixtures not matching new validation rules

**Workaround**:
```bash
# Run tests with verbose output to identify specific failures
flutter test --reporter expanded

# Run specific test files to isolate issues
flutter test test/specific_test_file.dart

# Use --no-sound-null-safety flag if encountering null safety issues
flutter test --no-sound-null-safety
```

**Long-term Fix**: Update test logic to match new package behaviors, particularly:
- Riverpod provider lifecycle changes
- Camera preview controller initialization
- OCR result object structures

### 2. Flutter Deprecated API Warnings

**Issue**: 46 warnings about deprecated Flutter APIs (down from 171)

**Severity**: Medium

**Main Deprecations**:
- `TextTheme` properties (headline1-6, bodyText1-2, etc.)
- `RaisedButton` → `ElevatedButton`
- `FlatButton` → `TextButton`
- `RenderObject` layout methods
- Material Design 2 → Material Design 3 components

**Workaround**:
```dart
// Old deprecated way
Theme.of(context).textTheme.headline1

// New way
Theme.of(context).textTheme.displayLarge

// Use migration tool
dart fix --apply
```

**Migration Guide**: [Flutter Breaking Changes](https://docs.flutter.dev/release/breaking-changes)

## Dependency Constraints

### 3. Build Runner Version Lock

**Issue**: build_runner locked to 2.4.8 due to compatibility issues with newer versions

**Severity**: Medium

**Root Cause**: 
- build_runner 2.4.9+ has conflicts with analyzer versions
- Affects code generation for Mockito and Riverpod

**Workaround**:
```yaml
# In pubspec.yaml
dependency_overrides:
  build_runner: 2.4.8
```

**Note**: Monitor for fixes in future build_runner releases

### 4. Google ML Kit Migration

**Issue**: google_ml_kit deprecated, migrated to google_mlkit_text_recognition

**Severity**: Low (already resolved)

**Changes Required**:
```dart
// Old import
import 'package:google_ml_kit/google_ml_kit.dart';

// New import
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// Initialization change
TextRecognizer(script: TextRecognitionScript.latin);
```

## Platform-Specific Issues

### 5. iOS 15.5+ Camera Permissions

**Issue**: iOS 15.5+ requires additional privacy manifest entries

**Severity**: Medium

**Required Info.plist Entries**:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to capture receipt photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to save receipt images</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app needs to save processed receipts to your photo library</string>
```

**Additional Requirement**: Privacy manifest file for iOS 17+

### 6. Android CameraX Compatibility

**Issue**: CameraX requires minSdkVersion 21, some features need 24+

**Severity**: Low

**Workaround for API 21-23**:
```xml
<!-- In android/app/build.gradle -->
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

**Feature Limitations on API < 24**:
- No HDR capture
- Limited zoom controls
- Basic flash modes only
- No advanced focus modes

### 7. Android Proguard Rules

**Issue**: Release builds may strip ML Kit classes

**Severity**: High (for release builds)

**Fix**: Add to `android/app/proguard-rules.pro`:
```
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
```

## OCR Accuracy Issues

### 8. Thermal Receipt Fading

**Issue**: Faded thermal receipts have <70% OCR accuracy

**Severity**: Medium

**Workarounds**:
1. Implement contrast enhancement preprocessing
2. Provide manual entry fallback
3. Show confidence scores to users
4. Allow image brightness/contrast adjustment

### 9. Non-Latin Character Support

**Issue**: Limited support for non-Latin scripts

**Severity**: Low (for MVP)

**Current Limitation**: TextRecognitionScript.latin only

**Future Enhancement**: Add script detection and multiple recognizers

## Performance Issues

### 10. Memory Usage on Batch Capture

**Issue**: Memory usage increases with multiple captures (10+ receipts)

**Severity**: Medium

**Workarounds**:
1. Implement image compression after capture
2. Release image resources after OCR
3. Limit batch size to 20 receipts
4. Show memory warning at 15 receipts

**Code Example**:
```dart
// Compress image after capture
final compressedImage = await FlutterImageCompress.compressWithFile(
  imagePath,
  quality: 85,
  minWidth: 1024,
  minHeight: 1024,
);
```

## CSV Export Issues

### 11. Excel Unicode Handling ✅ FIXED

**Issue**: Excel may not properly display UTF-8 characters without BOM

**Severity**: Low

**Status**: RESOLVED - UTF-8 BOM automatically added to all CSV exports as of September 2025

**Implementation**: 
```dart
// Automatically added in CSVExportService.generateCSVContent()
const bom = '\uFEFF';
return bom + _generateQuickBooksCSV(receipts);
```

### 12. Large Export Performance

**Issue**: Exporting 500+ receipts may cause UI freeze

**Severity**: Low

**Workaround**: Use isolates for large exports:
```dart
final csvData = await compute(generateCsvInBackground, receipts);
```

## State Management Issues

### 13. Riverpod 2.6 Migration

**Issue**: Breaking changes in Ref types and provider lifecycle

**Severity**: Medium (resolved in code, may affect tests)

**Key Changes**:
- `Ref` → specific ref types (e.g., `ReceiptRepositoryRef`)
- Provider lifecycle hooks changed
- AsyncValue API updates

## Build Issues

### 14. iOS Simulator Architecture

**Issue**: M1/M2 Macs may have architecture conflicts

**Severity**: Low

**Fix**:
```bash
# Clean and rebuild for arm64
flutter clean
cd ios
pod cache clean --all
pod install
cd ..
flutter build ios --simulator
```

### 15. Gradle Daemon Memory

**Issue**: Android builds may fail with OutOfMemoryError

**Severity**: Low

**Fix**: In `android/gradle.properties`:
```
org.gradle.jvmargs=-Xmx4096m
org.gradle.daemon=true
org.gradle.parallel=true
```

## Testing Device Limitations

### 16. Emulator Camera Quality

**Issue**: Emulators provide poor camera simulation

**Severity**: Medium (for testing)

**Recommendation**: Always test camera features on physical devices

### 17. iOS Simulator Storage

**Issue**: iOS simulator may run out of space with many test images

**Severity**: Low

**Fix**:
```bash
# Clear simulator storage
xcrun simctl delete all
xcrun simctl create "Test iPhone" "iPhone 14" iOS16.4
```

## Quick Reference Commands

### Useful Debugging Commands

```bash
# Check for outdated packages
flutter pub outdated

# Analyze code issues
flutter analyze

# Run specific test with verbose output
flutter test test/path/to/test.dart -v

# Clean everything and rebuild
flutter clean && flutter pub get && cd ios && pod install && cd ..

# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Common Fixes

```bash
# Fix most common issues
dart fix --apply

# Regenerate mocks
flutter pub run build_runner build --delete-conflicting-outputs

# Update pods for iOS
cd ios && pod update && cd ..

# Clear gradle cache
cd android && ./gradlew clean && cd ..
```

## Monitoring and Reporting

### Issue Tracking
- Report new issues in project issue tracker
- Include device info, OS version, and steps to reproduce
- Attach relevant logs and screenshots

### Priority Classification
- **Critical**: Blocks core functionality
- **High**: Impacts user experience significantly  
- **Medium**: Workaround available, fix needed
- **Low**: Minor issue, enhancement opportunity

## Future Improvements

1. **Automated Testing**: Add integration tests for device-specific features
2. **Performance Monitoring**: Implement APM for production builds
3. **Error Reporting**: Add Sentry or Firebase Crashlytics
4. **Feature Flags**: Implement feature toggles for gradual rollouts
5. **Dependency Management**: Regular automated dependency updates

---

**Last Updated**: September 2025
**Version**: 1.0.0
**Status**: Mid-Development Audit