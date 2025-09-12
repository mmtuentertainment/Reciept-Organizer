# Flutter 3.35 Migration Plan - Verified

## Migration Overview
- **Current**: Flutter 3.24.3 (Dart 3.5.3)
- **Target**: Flutter 3.35.0 (Dart 3.8)
- **Strategy**: Incremental migration through stable versions

## Verified Migration Path

```
3.24.3 → 3.27.0 → 3.29.0 → 3.32.0 → 3.35.0
```

## Phase 1: Pre-Migration Preparation

### 1.1 Create Feature Branch
```bash
git checkout -b feature/flutter-3.35-migration
```

### 1.2 Capture Baseline Metrics
```bash
# Document current performance
cd /home/matt/FINAPP/Receipt\ Organizer/apps/mobile
../../flutter/bin/flutter test --coverage
../../flutter/bin/flutter analyze
# Record: build time, app size, test pass rate
```

### 1.3 Apply Minor Package Updates First
Update these packages before Flutter SDK:
```yaml
dependencies:
  camera: ^0.11.2  # from 0.11.0+2
  path: ^1.9.1     # from 1.9.0
  sqflite: ^2.4.2  # from 2.4.1
  url_launcher: ^6.3.2  # from 6.3.1
```

## Phase 2: Flutter 3.27.0 Migration

### 2.1 Update Flutter
```bash
flutter channel stable
flutter upgrade 3.27.0
```

### 2.2 Breaking Changes for 3.27
- **MaterialState → WidgetState migration**
- **Material 3 theme normalization**
- Review TabBarTheme, CardTheme usage

### 2.3 Test & Verify
```bash
flutter pub get
flutter analyze
flutter test
```

## Phase 3: Flutter 3.29.0 Migration

### 3.1 Update Flutter
```bash
flutter upgrade 3.29.0
```

### 3.2 Breaking Changes for 3.29
- **WebAssembly support changes**
- **Package discontinuations** (check if using: ios_platform_images, css_colors, palette_generator)
- **Dart 3.7.0 compatibility**

### 3.3 Test & Verify
```bash
flutter clean
flutter pub get
flutter analyze
flutter test
```

## Phase 4: Flutter 3.32.0 Migration

### 4.1 Update Flutter
```bash
flutter upgrade 3.32.0
```

### 4.2 Breaking Changes for 3.32
- Review patch releases (3.32.1, 3.32.5, 3.32.6, 3.32.7)
- Platform-specific improvements

### 4.3 Test & Verify
```bash
flutter pub get
flutter analyze
flutter test
```

## Phase 5: Flutter 3.35.0 Final Migration

### 5.1 Update Flutter
```bash
flutter upgrade 3.35.0
```

### 5.2 Breaking Changes for 3.35
- **iOS minimum version: 13.0**
- **macOS minimum version: 10.15**
- **Dart 3.8 compatibility**
- **Component theme normalization**
- **DropdownButtonFormField**: `value` → `initialValue`
- **Radio widget redesign**
- **Android build ABI filters**

### 5.3 Platform Configuration Updates

#### Android (android/app/build.gradle)
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

#### iOS (ios/Podfile)
```ruby
platform :ios, '13.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
```

### 5.4 Final Testing
```bash
flutter clean
flutter pub get
flutter analyze --no-fatal-warnings
flutter test
flutter build apk --debug
flutter build ios --debug --no-codesign
```

## Package Compatibility Review

### Packages Already Compatible
- ✅ flutter_riverpod 2.6.1 (works with 3.35)
- ✅ google_mlkit_text_recognition 0.15.0
- ✅ supabase_flutter 2.9.0
- ✅ camera 0.11.0+2 (update to 0.11.2)

### Consider Future Updates (Not Required)
- Riverpod 3.0 (wait for stability)
- flutter_lints 6.0.0 (after migration complete)
- share_plus 12.0.0 (major breaking changes)

## Migration Checklist

### Pre-Migration
- [ ] Create feature branch
- [ ] Document baseline metrics
- [ ] Apply minor package updates
- [ ] Run full test suite

### Per Version Update
- [ ] Update Flutter SDK
- [ ] Run `flutter pub get`
- [ ] Fix any analyzer warnings
- [ ] Run all tests
- [ ] Test on physical devices
- [ ] Document any issues

### Post-Migration
- [ ] Full regression testing
- [ ] Performance comparison
- [ ] Update CI/CD pipelines
- [ ] Update documentation
- [ ] Create PR for review

## Risk Mitigation

### Rollback Plan
Each migration step is reversible:
```bash
# If issues at any step:
flutter downgrade  # Returns to previous version
git reset --hard HEAD~1  # Revert code changes
```

### Known Risks
1. **iOS 13.0 requirement** - Verify device compatibility
2. **Material 3 changes** - UI may need adjustments
3. **Dart 3.8** - Review null safety and new language features

## Expected Timeline

- **Day 1**: Pre-migration prep + Flutter 3.27
- **Day 2**: Flutter 3.29 + 3.32
- **Day 3**: Flutter 3.35 + platform configs
- **Day 4**: Testing & validation
- **Day 5**: Fix issues & create PR

## Success Criteria

- ✅ All tests passing
- ✅ No new analyzer warnings
- ✅ Camera functionality working
- ✅ OCR accuracy maintained
- ✅ Supabase sync functional
- ✅ Build size increase < 10%
- ✅ No performance regression

## Commands Reference

```bash
# Check current Flutter version
flutter --version

# List available Flutter versions
flutter channel

# Upgrade to specific version
flutter upgrade [version]

# Clean and rebuild
flutter clean && flutter pub get

# Run tests with coverage
flutter test --coverage

# Build for platforms
flutter build apk --debug
flutter build ios --debug --no-codesign
```

---

*Document created: 2025-09-12*
*Based on verified Flutter releases and official documentation*