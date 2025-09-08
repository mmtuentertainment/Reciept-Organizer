# Validation Scripts for Receipt Organizer MVP

This directory contains comprehensive validation and audit scripts for the Receipt Organizer MVP project.

## Overview

These scripts ensure the application meets all quality, security, and performance requirements before release.

## Available Scripts

### 1. `comprehensive_audit.sh`
The main audit script that performs exhaustive validation checks:
- Environment validation
- Dependency audit
- Code quality checks
- Security validation
- Feature implementation verification
- Test execution and coverage
- Build verification
- Performance checks

**Usage:**
```bash
./scripts/comprehensive_audit.sh
```

### 2. `validate_csv_security.dart`
Tests CSV injection prevention to ensure the app is protected against:
- Formula injection (=, +, -, @)
- Special character handling
- Quote escaping
- Real-world edge cases

**Usage:**
```bash
dart run scripts/validate_csv_security.dart
```

### 3. `validate_export_formats.dart`
Validates CSV export formats for compatibility with:
- QuickBooks (MM/DD/YYYY dates, specific headers)
- Xero (DD/MM/YYYY dates, contact name limits)
- Generic format (ISO dates)

**Usage:**
```bash
dart run scripts/validate_export_formats.dart
```

### 4. `validate_performance.dart`
Tests performance metrics against MVP requirements:
- Photo capture < 2s
- OCR processing < 5s (p95)
- CSV export < 1s for 100 receipts
- Date filtering < 100ms
- Memory usage validation

**Usage:**
```bash
dart run scripts/validate_performance.dart
```

### 5. `run_all_validations.sh`
Quick runner that executes all validation scripts in sequence.

**Usage:**
```bash
./scripts/run_all_validations.sh
```

## When to Run

### During Development
- Run `comprehensive_audit.sh` daily
- Run specific validation scripts after related changes

### Before PR/Merge
- Run `run_all_validations.sh`
- Address any failures before merging

### Before Release
- Run all scripts individually
- Review detailed logs
- Perform manual testing based on results

## Interpreting Results

### Success Indicators
- ✓ Green checkmarks indicate passed tests
- "All tests passed" messages
- Exit code 0

### Failure Indicators
- ✗ Red X marks indicate failures
- ⚠ Yellow warnings need attention
- Exit code 1

### Critical Failures
The following require immediate attention:
- CSV injection vulnerabilities
- Build failures
- Security test failures
- Performance targets not met

## Manual Testing Required

These scripts complement but don't replace manual testing:

1. **Device Testing**
   - Test on physical Android device
   - Test on physical iPhone
   - Various OS versions

2. **Integration Testing**
   - Export CSV files
   - Import into QuickBooks Online
   - Import into Xero
   - Verify all fields import correctly

3. **User Experience Testing**
   - Camera in different lighting
   - Various receipt types
   - Offline mode functionality
   - Error recovery flows

## Troubleshooting

### Script Permission Errors
```bash
chmod +x scripts/*.sh
```

### Dart Script Errors
Ensure Dart is in your PATH:
```bash
dart --version
```

### Coverage Tool Missing
Install lcov for coverage reports:
```bash
# macOS
brew install lcov

# Linux
sudo apt-get install lcov
```

## Adding New Validations

1. Create new script in `scripts/` directory
2. Follow naming convention: `validate_<feature>.dart` or `test_<feature>.sh`
3. Update `run_all_validations.sh` to include new script
4. Document in this README

## Audit Logs

Detailed logs are saved with timestamp:
- `audit_report_YYYYMMDD_HHMMSS.log`

Review logs for:
- Detailed failure information
- Performance metrics
- Dependency versions
- Test results

---

**Note**: These validation scripts are critical for maintaining quality. Run them frequently and address issues promptly.