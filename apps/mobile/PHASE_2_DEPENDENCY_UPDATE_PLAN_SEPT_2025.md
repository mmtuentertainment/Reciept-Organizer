# Phase 2: Dependency Update Plan - September 2025

## Executive Summary

This document contains the comprehensive research findings for updating all dependencies to their September 2025 versions. The updates are designed to be compatible with Flutter 3.35 and ensure the application remains current with security patches and performance improvements.

## 1. Flutter SDK Update

### Current → Target
- **Current**: Flutter 3.5.x
- **Target**: Flutter 3.35.0

### Migration Strategy
Due to the major version jump, an incremental migration through stable versions is recommended:
1. Flutter 3.5 → 3.10
2. Flutter 3.10 → 3.19
3. Flutter 3.19 → 3.27
4. Flutter 3.27 → 3.35

### Key Breaking Changes
- Material 3 theming system changes
- Deprecated APIs removed
- Stricter linting rules
- Platform minimum version updates

## 2. Core Package Updates

### Riverpod Ecosystem

| Package | Current | Target | Breaking Changes |
|---------|---------|--------|------------------|
| flutter_riverpod | 2.4.0 | 2.6.1 | No |
| riverpod_generator | 2.6.3 | 2.6.5 | No |
| riverpod_annotation | 2.6.0 | 2.6.1 | No |

**Key Changes:**
- `StreamProvider.stream` is deprecated, use `StreamProvider.future`
- `AsyncValue.copyWithPrevious` enhancements
- Performance improvements

### Google ML Kit Migration

**Old Package**: google_ml_kit ^0.16.0  
**New Package**: google_mlkit_text_recognition ^0.15.0

**Breaking Changes:**
1. Package structure change - must update imports
2. TextRecognizer now requires script specification:
   ```dart
   // Old
   final textRecognizer = GoogleMlKit.vision.textRecognizer();
   
   // New
   final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
   ```
3. iOS minimum version increased to 15.5

### Camera Package Update

**Current**: camera ^0.10.5  
**Target**: camera ^0.11.0+2

**Major Changes:**
- Switch to CameraX on Android (better device compatibility)
- New permission exception codes
- Lifecycle management now required
- iOS 12.0+ minimum (iOS 11 deprecated)

**Migration Required:**
```dart
// Update error handling
catch (e) {
  if (e.code == 'CameraAccessDenied') { // was 'cameraPermission'
    // Handle permission denied
  }
}
```

## 3. Storage & Utility Package Updates

| Package | Current | Target | Notes |
|---------|---------|--------|-------|
| sqflite | 2.3.0 | 2.4.2 | Minor update |
| path_provider | 2.1.1 | 2.1.5 | Minor update |
| path | 1.8.3 | 1.9.1 | Minor update |
| csv | 6.0.0 | 6.0.0 | No update needed |
| uuid | 4.1.0 | 4.5.1 | Minor update |
| shared_preferences | 2.2.2 | 2.5.3 | New async API recommended |
| intl | 0.19.0 | 0.20.2 | Major version - check changelog |
| flutter_image_compress | 2.1.0 | 2.4.0 | Requires Kotlin 1.5.21+ |
| image | 4.5.1 | 4.5.4 | Minor update |

### Important Migration: shared_preferences

New async API provides better performance:
```dart
// Old way
final prefs = await SharedPreferences.getInstance();
prefs.setString('key', 'value');

// New way (recommended)
final prefs = await SharedPreferencesAsync();
await prefs.setString('key', 'value');
```

## 4. Dev Dependencies Updates

| Package | Current | Target | Notes |
|---------|---------|--------|-------|
| flutter_lints | 4.0.0 | 3.0.1 | Downgrade (4.0.0 not available) |
| mockito | 5.4.2 | 5.4.2 | Keep current |
| build_runner | 2.5.4 | 2.6.0 | Update |
| json_annotation | 4.8.1 | 4.8.1 | Keep current |
| json_serializable | 6.9.5 | 6.9.5 | Keep current |
| sqflite_common_ffi | 2.3.3 | 2.3.3 | Keep current |
| mocktail | 1.0.4 | 1.0.4 | Keep current |
| freezed | 3.1.0 | 3.0.0 | Downgrade (3.1.0 not available) |

### Command Changes
Replace all `flutter pub run` commands with `dart run`:
```bash
# Old
flutter pub run build_runner build

# New
dart run build_runner build
```

## 5. Updated pubspec.yaml

```yaml
name: receipt_organizer
description: "A new Flutter project."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.6.0  # Updated for Flutter 3.35

dependencies:
  flutter:
    sdk: flutter

  # UI and State Management
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.6.1  # Updated
  
  # Camera and Image Processing
  camera: ^0.11.0+2  # Updated
  image: ^4.5.4  # Updated
  flutter_image_compress: ^2.4.0  # Updated
  
  # OCR and ML
  google_mlkit_text_recognition: ^0.15.0  # Replaced google_ml_kit
  
  # Database and Storage
  sqflite: ^2.4.2  # Updated
  path_provider: ^2.1.5  # Updated
  path: ^1.9.1  # Updated
  
  # CSV Processing
  csv: ^6.0.0  # No change
  
  # Utilities
  uuid: ^4.5.1  # Updated
  shared_preferences: ^2.5.3  # Updated
  intl: ^0.20.2  # Updated

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Linting and Testing
  flutter_lints: ^3.0.1  # Downgraded
  mockito: ^5.4.2  # No change
  build_runner: ^2.6.0  # Updated
  
  # Code generation  
  riverpod_generator: ^2.6.5  # Updated
  riverpod_annotation: ^2.6.1  # Updated
  json_annotation: ^4.8.1  # No change
  json_serializable: ^6.9.5  # No change
  
  # Database testing
  sqflite_common_ffi: ^2.3.3  # No change
  mocktail: ^1.0.4  # No change
  freezed: ^3.0.0  # Downgraded
```

## 6. Platform Configuration Updates

### Android (android/app/build.gradle)
```gradle
android {
    compileSdkVersion 34  // Update for Flutter 3.35
    defaultConfig {
        minSdkVersion 21  // Required for camera 0.11.0
        targetSdkVersion 34
    }
}
```

### iOS (ios/Podfile)
```ruby
platform :ios, '15.5'  # Updated for google_mlkit_text_recognition

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      config.build_settings['EXCLUDED_ARCHS'] = 'armv7'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.5'
    end
  end
end
```

## 7. Code Migration Tasks

### Task 1: Update Google ML Kit Imports
```dart
// Old
import 'package:google_ml_kit/google_ml_kit.dart';

// New
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
```

### Task 2: Update TextRecognizer Initialization
Update all TextRecognizer instantiations to include script specification.

### Task 3: Update Camera Error Handling
Update all camera permission error handlers to use new exception codes.

### Task 4: Implement Camera Lifecycle Management
Add proper lifecycle management for camera controllers.

### Task 5: Update SharedPreferences Usage (Optional)
Consider migrating to the new async API for better performance.

## 8. Testing Strategy

1. **Unit Tests**: Run all unit tests after each package group update
2. **Integration Tests**: Focus on camera, OCR, and storage functionality
3. **Platform Tests**: Test on both iOS 15.5+ and Android API 21+
4. **Performance Tests**: Verify no regression in OCR processing speed

## 9. Rollback Plan

If issues arise:
1. **Camera Issues**: Fallback to Camera2 implementation
2. **ML Kit Issues**: Temporarily pin to older version
3. **Flutter SDK Issues**: Rollback to Flutter 3.27 (last stable before 3.35)

## 10. Implementation Order

1. Update Flutter SDK incrementally
2. Update Riverpod ecosystem (low risk)
3. Update storage and utility packages (low risk)
4. Update dev dependencies
5. Update camera package (medium risk)
6. Migrate Google ML Kit (highest risk)
7. Run comprehensive tests
8. Update platform configurations

## Success Criteria

- [ ] All tests passing
- [ ] No increase in crash rate
- [ ] OCR accuracy maintained or improved
- [ ] Camera functionality working on test devices
- [ ] Build size increase < 5%
- [ ] No performance regression

## Next Steps

1. Create feature branch for updates
2. Implement updates following the order above
3. Test on physical devices (iOS 15.5+, Android API 21+)
4. Run performance benchmarks
5. Document any workarounds needed