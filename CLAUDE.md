# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Receipt Organizer MVP** project for mom-and-pop businesses, providing offline-first receipt capture, OCR processing, and CSV export. The project has completed Flutter 3.35.3 migration and uses a simplified 15-test strategy.

## Project Architecture

### Core Requirements
- **Target Users**: Owner-operators, mom-and-pop businesses, solo bookkeepers managing 100-500 receipts/month
- **Offline-First**: All processing must work without network connectivity
- **Core Workflow**: Photo capture → OCR extraction → CSV export
- **Key Fields**: Merchant, Date, Total, Tax (4 fields only for MVP)

### Technical Stack (Implemented)
Based on architecture in `docs/sharded-architecture/tech-stack.md`:

- **Frontend**: Flutter 3.35.3 with Dart 3.2+
- **State Management**: Riverpod 2.4+
- **OCR Engine**: Google ML Kit (primary) + TensorFlow Lite (fallback)
- **Database**: SQLite via sqflite with RxDB reactive layer
- **Image Processing**: Flutter camera plugin with edge detection
- **CSV Generation**: Built-in Dart CSV library (RFC 4180 compliant)
- **Architecture**: Offline-first with progressive cloud enhancement

### Success Metrics
From `project_brief_mom_and_pop_receipt_organizer_mvp_v_1.md`:

- **Capture→Extract latency**: ≤ 5s p95
- **Field accuracy**: Total ≥ 95%, Date ≥ 95%, Merchant ≥ 90%, Tax ≥ 85%
- **Zero-touch happy path**: ≥ 70% require no edits
- **CSV export pass rate**: ≥ 99% pass QuickBooks/Xero validators
- **Offline reliability**: Full functionality without network
- **Stability**: ≥ 99.5% crash-free sessions

## Documentation Structure

### Core Documents
- `README.md` - Project overview and navigation
- `PROJECT_STATUS.md` - Current state and next steps
- `project_brief_mom_and_pop_receipt_organizer_mvp_v_1.md` - Original MVP specification

### Architecture & Technical
- `docs/sharded-architecture/` - Complete technical architecture (20 sections)
  - `tech-stack.md` - Technology decisions and rationale
  - `database-schema.md` - SQLite schema design
  - `frontend-architecture.md` - Flutter app structure
  - `high-level-architecture.md` - System overview

### Product & Features
- `docs/sharded-prd/` - Product requirements in POML format
- `docs/stories/` - User stories (1.1 through 3.12)
- `docs/epics/` - Epic definitions
- `docs/qa/` - Quality gates and assessments

## Development Constraints

### What we WILL build (MVP Scope)
1. Smart edge detection with manual override
2. Confidence-based OCR with quick edit (4 fields only)
3. Basic vendor normalization
4. Pre-flight CSV validation with templates
5. Offline-first local storage
6. Batch capture and simple organizing aids

### What we will NOT build (v1)
- Cloud accounts/multi-user sync
- Bank/ERP integrations
- Line-item extraction
- Complex approvals/workflows
- Heavy ML training
- Multi-device support beyond one Android and one iPhone

## Key Principles

1. **KISS/YAGNI/DIW**: Each change must be reversible, minimal, and measured
2. **Offline-First**: All functionality must work without internet
3. **Evidence-Based**: All technical decisions backed by research data
4. **CSV as Contract**: Publish schemas and validate pre-export
5. **Honest OCR UX**: Visible confidence scores + fast correction over perfect automation

## CRITICAL: Test Suite Management

### ⚠️ IMPORTANT: Simplified Test Strategy (15 Tests Only)
**DO NOT ADD MORE TESTS WITHOUT EXPLICIT DISCUSSION**

This project uses a **minimal test strategy** following the CleanArchitectureTodoApp pattern:
- **Original**: 571 tests (way too many, 131 failing)
- **Current**: 15 critical tests only
- **Location**: `apps/mobile/test/`
- **Strategy**: See `apps/mobile/test/SIMPLIFIED_TEST_STRATEGY.md`

#### The 15 Critical Tests (Currently 11 Active):
1. **Core Tests** (`test/core_tests/`) - 8 tests:
   - Receipt repository operations (3 tests)
   - CSV export functionality (3 tests)
   - App launch verification (2 tests)

2. **Integration Tests** (`test/integration_tests/`) - 3 tests:
   - Critical user flows only
   - Navigation between screens
   - Settings access

### Why Only 15 Tests?
- Industry best practice: Most successful Flutter apps have 50-200 tests, not 500+
- CleanArchitectureTodoApp (a reference implementation) uses only 12 tests
- Maintenance burden of 571 tests was unsustainable
- Focus on critical business logic, not edge cases

### Before Adding ANY Test:
1. Read `apps/mobile/test/SIMPLIFIED_TEST_STRATEGY.md`
2. Justify why it's critical for MVP
3. Consider if existing tests already cover it
4. Get explicit approval in the conversation

## Current Project Status

### Completed ✅
- Flutter 3.35.3 migration (Android Gradle Plugin 8.6.0, Kotlin 1.9.0)
- Test suite simplified from 571 to 15 critical tests
- Documentation consolidated and organized
- Offline-first architecture with cloud-ready interfaces
- Story 3.12: Export validation with 13 integration tests
- Track 1: Test infrastructure interfaces (ISyncService, IAuthService) implemented
- Track 2: Supabase cloud infrastructure fully configured
  - Local Supabase running at http://127.0.0.1:54321
  - Database migrations applied (4 tables with RLS)
  - Auth and sync services implemented with current 2025 API
  - Integration tests configured and passing

### In Progress 🚧
- Hybrid features implementation
- Production Supabase deployment preparation

### Next Steps 📋
1. Deploy Supabase to production environment
2. Implement progressive cloud enhancement features
3. Add user authentication UI components
4. Enable cloud sync with offline queue

### Build & Test Commands
```bash
# Flutter app (from apps/mobile/)
flutter test test/core_tests/ test/integration_tests/  # Run ONLY the 15 critical tests
flutter run                                             # Run the app
flutter analyze --no-pub                                # Check for issues
flutter build apk --debug                               # Build Android APK

# API (from apps/api/)
npm run dev                                            # Start development server
npm run build                                          # Build for production
npm test                                               # Run API tests

# Supabase (from infrastructure/supabase/)
npx supabase start                                     # Start local Supabase
npx supabase stop                                      # Stop local Supabase
npx supabase status                                    # Check Supabase status
npx supabase db push                                   # Apply migrations
npx supabase db seed                                   # Seed test data

# Supabase Integration Tests
CI=true flutter test test/infrastructure/supabase_integration_test.dart

# Utility Scripts (from root)
bash CLEANUP_PROJECT.sh                                # Remove orphaned files
bash apps/mobile/test/PROTECT_TESTS.sh                # Verify test count
```
## Important Reminders

### Test Discipline
- **NEVER** add tests without explicit discussion
- Run `PROTECT_TESTS.sh` to verify test count stays at ~15
- See `apps/mobile/test/SIMPLIFIED_TEST_STRATEGY.md` for rationale

### Code Quality
- All code changes must pass `flutter analyze`
- Tests must pass before any PR/merge
- Follow patterns in existing codebase

### Documentation
- Keep `PROJECT_STATUS.md` updated with progress
- Document significant decisions in appropriate docs/ section
- Update this file when project structure changes

## Supabase Infrastructure

### Local Development Setup
The project includes a fully configured Supabase setup for cloud features:

- **Local URL**: http://127.0.0.1:54321
- **Dashboard**: http://127.0.0.1:54323  
- **Database**: PostgreSQL on port 54322
- **Migrations**: Located in `infrastructure/supabase/migrations/`

### Key Services Implemented
1. **SupabaseAuthService** (`lib/infrastructure/services/supabase_auth_service.dart`)
   - Anonymous authentication for quick start
   - Email/password registration and sign-in
   - Session management and token refresh
   - Implements IAuthService interface

2. **SupabaseSyncService** (`lib/infrastructure/services/supabase_sync_service.dart`)
   - Bidirectional data sync
   - Realtime subscriptions using channels
   - Conflict resolution (Last Write Wins + field merging)
   - Offline queue management
   - Implements ISyncService interface

### Database Schema
- `receipts` - Main receipt storage with user isolation via RLS
- `sync_metadata` - Track sync state per device
- `export_history` - CSV export audit trail
- `user_preferences` - User-specific settings

### Environment Configuration
The app uses standard Supabase local development credentials which are safe for local use:
```dart
// Environment.isDevelopment determines which config to use
const String _localDevUrl = 'http://127.0.0.1:54321';
const String _localDevAnonKey = 'eyJhb...'; // Standard local dev key
```

For production, use environment variables:
```bash
flutter build apk \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

## Recent Enhancements (January 2025)

### Story 3.12: Export Validation ✅
Complete implementation of pre-flight validation before CSV export:

#### Features Implemented:
- **Validation Engine**: Format-specific validators for QuickBooks, Xero, and Generic CSV
- **Security**: Comprehensive CSV injection prevention (OWASP patterns)
- **UI Enhancements**: 
  - Progress indicators during validation
  - Format-specific badges with icons and colors
  - Keyboard shortcuts (Enter/Esc/F)
- **Data Integration**: Properly fetches real receipts from repository
- **Error Handling**: Categorized issues (errors, warnings, info)

#### Key Files:
- `lib/features/export/domain/export_validator.dart` - Core validation logic
- `lib/features/export/presentation/widgets/validation_report_dialog.dart` - Enhanced UI
- `lib/features/export/domain/receipt_converter.dart` - Data model conversion
- `lib/features/export/presentation/pages/export_screen.dart` - Integration point

#### Testing Status:
- **Integration Tests Added**: 13 comprehensive tests using real merchant data
- **Test Data Source**: Discovered and utilized existing test CSVs with 50+ real merchants
- **Coverage**: Date format confusion, CSV injection, performance benchmarks, edge cases
- **Files Created**:
  - `test/integration/export_validation_flow_test.dart` - Full integration test suite
  - `lib/features/export/services/api_credentials.dart` - API credentials stub
- **All tests passing**: 11 core tests + 13 new integration tests = 24 total passing
- CSV injection prevention verified