# Receipt Organizer Brownfield Architecture Document

## Introduction

This document captures the CURRENT STATE of the Receipt Organizer codebase, including technical debt, integration gaps, and real-world patterns. It serves as a reference for AI agents working on Phase 2 Authentication & User Management enhancements.

### Document Scope

Focused on areas relevant to: **Phase 2 - Authentication & User Management Implementation**
- Current authentication implementations across 3 platforms
- Supabase integration points and gaps
- MCP server capabilities for development
- User session management patterns

### Change Log

| Date       | Version | Description                                    | Author   |
| ---------- | ------- | ---------------------------------------------- | -------- |
| 2025-09-14 | 1.0     | Initial brownfield analysis for Phase 2 Auth  | Winston  |

## Quick Reference - Key Files and Entry Points

### Critical Files for Understanding the System

#### Mobile App (Flutter)
- **Main Entry**: `apps/mobile/lib/main.dart`
- **Auth Provider**: `apps/mobile/lib/features/auth/providers/auth_provider.dart`
- **Session Manager**: `apps/mobile/lib/features/auth/services/session_manager.dart`
- **Supabase Config**: `apps/mobile/lib/infrastructure/config/supabase_config.dart`
- **Login Screen**: `apps/mobile/lib/features/auth/screens/login_screen.dart`

#### Web App (Next.js)
- **Main Entry**: `apps/web/app/layout.tsx`
- **Auth Components**: `apps/web/components/auth/` directory
- **Supabase Client**: `apps/web/lib/supabase/client.ts` and `server.ts`
- **Middleware**: `apps/web/middleware.ts`
- **Dashboard**: `apps/web/app/dashboard/page.tsx`

#### Native App (React Native/Expo)
- **Main Entry**: `apps/native/App.tsx`
- **Navigation**: `apps/native/app/(tabs)/` directory structure
- **Supabase Config**: Not yet implemented (GAP)

#### API Server
- **Main Entry**: `apps/api/src/index.ts`
- **Package.json**: `apps/api/package.json` (minimal setup)

### Enhancement Impact Areas for Phase 2

Files/modules that will be affected by authentication implementation:
- All auth-related files listed above need synchronization
- Session management across platforms
- Token storage strategies
- OAuth flow implementations

## High Level Architecture

### Technical Summary

Multi-platform receipt management system with offline-first architecture, currently completing Phase 1 (Database & Storage) and moving to Phase 2 (Authentication).

### Actual Tech Stack (from package files)

| Category        | Technology              | Version     | Notes                                          |
| --------------- | ----------------------- | ----------- | ---------------------------------------------- |
| Mobile Runtime  | Flutter                 | 3.35.3      | Running on Chrome for development              |
| Mobile State    | Riverpod                | 2.4+        | Provider-based state management                |
| Web Runtime     | Next.js                 | 15.1.3      | App Router, SSR-compatible                    |
| Web UI          | shadcn/ui               | Latest      | Component library via MCP                     |
| Native Runtime  | React Native/Expo       | SDK 52      | NativeWind for styling                        |
| Backend         | Supabase                | Production  | Project: xbadaalqaeszooyxuoac                |
| Database        | PostgreSQL (Supabase)   | Latest      | 6 tables, 100+ columns, 25 indexes           |
| Auth            | Supabase Auth           | Built-in    | Email/password, OAuth, session management     |
| Storage         | Supabase Storage        | Built-in    | Secure buckets, quota tracking                |
| OCR             | Google Vision API       | v1          | 1000 free requests/month                      |

### Repository Structure Reality Check

- Type: Monorepo with mixed maturity levels
- Package Manager: npm for web/native/api, Flutter SDK for mobile
- Notable: Phase 1 complete, significant integration gaps for mobile

## Source Tree and Module Organization

### Project Structure (Actual)

```text
Receipt-Organizer/
├── apps/
│   ├── mobile/          # Flutter app (most mature, but missing Phase 1 features)
│   │   ├── lib/
│   │   │   ├── features/       # Feature-based architecture
│   │   │   │   ├── auth/       # PARTIAL: Basic auth, needs Supabase integration
│   │   │   │   ├── capture/    # COMPLETE: Receipt capture working
│   │   │   │   ├── export/     # COMPLETE: CSV export working
│   │   │   │   └── receipts/   # PARTIAL: Missing category support
│   │   │   ├── infrastructure/ # PARTIAL: Supabase config exists
│   │   │   └── domain/         # Models need field mapping
│   │   └── test/          # 15 critical tests only (DO NOT ADD MORE)
│   ├── web/             # Next.js app (working auth)
│   │   ├── app/          # App Router structure
│   │   ├── components/   # UI components
│   │   └── lib/          # Utilities including Supabase
│   ├── native/          # React Native (basic setup)
│   │   └── app/          # Expo Router structure
│   └── api/             # Express API (minimal)
├── infrastructure/      # Supabase configuration
│   └── supabase/
│       └── migrations/  # 002-004 completed for Phase 1
├── docs/               # Comprehensive documentation
└── .bmad-core/         # BMad methodology files
```

### Key Modules and Their Current State

#### Authentication Systems
- **Mobile Auth**: `apps/mobile/lib/features/auth/` - Basic email/password, needs Supabase integration
- **Web Auth**: `apps/web/components/auth/` - WORKING with Supabase, cookie-based sessions
- **Native Auth**: Not implemented - CRITICAL GAP
- **Session Management**: Inconsistent across platforms

#### Data Models
- **Mobile Models**: `apps/mobile/lib/data/models/receipt.dart` - Missing 14 new fields from Phase 1
- **Categories**: 52 in database, 0 support in mobile - CRITICAL GAP
- **Field Mismatches**: merchantName (mobile) vs vendor_name (database)

## MCP Server Capabilities (Development Tools)

### Supabase MCP Server

The Supabase MCP server provides direct database and infrastructure management:

**Available Commands**:
- `mcp__supabase__list_tables` - View all database tables
- `mcp__supabase__apply_migration` - Apply DDL operations
- `mcp__supabase__execute_sql` - Run queries (for data operations)
- `mcp__supabase__get_project_url` - Get API endpoint
- `mcp__supabase__get_anon_key` - Get public API key
- `mcp__supabase__search_docs` - Search Supabase documentation
- `mcp__supabase__get_advisors` - Security/performance recommendations

**Phase 2 Usage**:
- Create auth-related database migrations
- Set up RLS policies for user isolation
- Test authentication flows directly
- Monitor auth logs with `get_logs`

### shadcn MCP Server

The shadcn MCP server provides UI component management:

**Available Commands**:
- `mcp__shadcn__search_items_in_registries` - Find components
- `mcp__shadcn__get_item_examples_from_registries` - Get usage examples
- `mcp__shadcn__get_add_command_for_items` - Install components
- `mcp__shadcn__get_audit_checklist` - Verify integration

**Phase 2 Usage**:
- Add auth UI components (login forms, user profiles)
- Implement consistent UI across web platform
- Use pre-built, accessible components

## Technical Debt and Known Issues

### Critical Technical Debt

1. **Mobile-Database Mismatch**:
   - 52 categories in DB, 0 in mobile app
   - 14 unmapped fields from Phase 1 enhancements
   - Field naming inconsistencies (merchantName vs vendor_name)

2. **Authentication Fragmentation**:
   - Web: Working Supabase Auth with cookies
   - Mobile: Basic implementation, not connected to Supabase
   - Native: No auth implementation at all

3. **Session Management**:
   - No unified session handling across platforms
   - Token refresh logic incomplete in mobile
   - Cookie vs localStorage inconsistency

4. **Test Coverage**:
   - Limited to 15 critical tests (by design)
   - No auth-specific test coverage
   - Integration tests needed for Phase 2

### Workarounds and Gotchas

- **Flutter Web Runtime**: Running on Chrome, not native - affects auth storage options
- **Environment Variables**: Different patterns across platforms (.env vs dart-define)
- **Supabase Project**: Production instance already deployed (xbadaalqaeszooyxuoac)
- **API Key Security**: Google Vision key was exposed, needs rotation

## Integration Points and External Dependencies

### External Services

| Service         | Purpose        | Integration Type | Key Files                                    |
| --------------- | -------------- | ---------------- | -------------------------------------------- |
| Supabase        | Backend        | SDK/REST API     | Various config files per platform           |
| Google Vision   | OCR            | REST API         | Mobile OCR service files                    |
| Expo            | Native build   | SDK              | `apps/native/` structure                    |

### Internal Integration Points

- **Cross-Platform Auth**: Need unified auth strategy
- **Database Sync**: Offline-first with online sync
- **Storage Integration**: Supabase Storage for receipts/avatars

## Development and Deployment

### Local Development Setup

```bash
# Mobile (Flutter)
cd apps/mobile
flutter pub get
flutter run -d chrome --dart-define=PRODUCTION=true

# Web (Next.js)
cd apps/web
npm install
npm run dev  # Port 3001

# Native (React Native)
cd apps/native
npm install
npm start

# Supabase (via MCP)
# Use mcp__supabase commands for direct database access
```

### Environment Variables Required

```bash
# Mobile (.env or --dart-define)
SUPABASE_URL=https://xbadaalqaeszooyxuoac.supabase.co
SUPABASE_ANON_KEY=[anon_key]
GOOGLE_VISION_API_KEY=[needs_rotation]

# Web (.env.local)
NEXT_PUBLIC_SUPABASE_URL=https://xbadaalqaeszooyxuoac.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=[anon_key]

# Native (.env)
EXPO_PUBLIC_SUPABASE_URL=[not_configured]
EXPO_PUBLIC_SUPABASE_ANON_KEY=[not_configured]
```

## Testing Reality

### Current Test Coverage

- **Critical Tests**: 15 tests in `apps/mobile/test/`
- **DO NOT ADD MORE TESTS** without explicit discussion
- **Test Strategy**: `docs/TESTING_STRATEGY.md`

### Running Tests

```bash
# Mobile tests only
cd apps/mobile
flutter test test/core_tests/ test/integration_tests/

# Web tests
cd apps/web
npm test

# Native tests
cd apps/native
npm test
```

## Phase 2 Authentication - Impact Analysis

### Files That Will Need Modification

#### Mobile Platform
- `lib/infrastructure/config/supabase_config.dart` - Update auth configuration
- `lib/features/auth/providers/auth_provider.dart` - Implement Supabase auth methods
- `lib/features/auth/services/session_manager.dart` - Add token refresh logic
- `lib/features/auth/screens/login_screen.dart` - Update UI for OAuth
- `lib/domain/models/user.dart` - Create/update user model

#### Web Platform
- `lib/supabase/server.ts` - Enhance server-side auth
- `middleware.ts` - Add route protection
- `components/auth/` - Enhance existing components
- `app/api/auth/callback/route.ts` - OAuth callback handling

#### Native Platform
- Create entire auth infrastructure from scratch
- Implement Supabase client configuration
- Add navigation guards
- Create auth UI components

### New Files/Modules Needed

- **Shared Auth Logic**: Consider shared auth utilities
- **Token Management**: Unified token storage strategy
- **Session Sync**: Cross-platform session synchronization
- **OAuth Handlers**: Platform-specific OAuth implementations

### Integration Considerations

- Must maintain offline-first architecture
- Session persistence across app restarts
- Secure token storage per platform
- RLS policies must align with client-side auth
- Consider auth state management patterns (Riverpod for mobile, React Context for web/native)

## MCP-Enabled Development Workflow

### For Phase 2 Implementation

1. **Database Setup** (via Supabase MCP):
   ```
   mcp__supabase__apply_migration - Create auth tables
   mcp__supabase__execute_sql - Seed test users
   mcp__supabase__get_advisors - Check security
   ```

2. **UI Components** (via shadcn MCP):
   ```
   mcp__shadcn__search_items_in_registries - Find auth components
   mcp__shadcn__get_item_examples_from_registries - Get implementations
   mcp__shadcn__get_add_command_for_items - Install to web app
   ```

3. **Testing & Monitoring**:
   ```
   mcp__supabase__get_logs - Monitor auth attempts
   mcp__supabase__execute_sql - Query user sessions
   ```

## Appendix - Useful Commands and Scripts

### Frequently Used Commands

```bash
# Mobile Development
cd apps/mobile && flutter analyze --no-pub
cd apps/mobile && flutter test test/core_tests/ test/integration_tests/
cd apps/mobile && flutter run -d chrome --dart-define=PRODUCTION=true

# Web Development
cd apps/web && npm run dev
cd apps/web && npm run build
cd apps/web && npx shadcn@latest add [component]

# Database Management (via MCP)
# Use mcp__supabase commands directly in conversation

# Check Phase 1 completion
cat docs/phases/PHASE_1_COMPLETION_REPORT.md
cat docs/qa/PHASE_1_AUDIT_REPORT.md
```

### Debugging and Troubleshooting

- **Auth Issues**: Check `mcp__supabase__get_logs service:auth`
- **Session Problems**: Inspect browser DevTools > Application > Cookies
- **Mobile Integration**: Use `flutter inspector` for state debugging
- **Database State**: Use `mcp__supabase__execute_sql` for queries

### Critical Warnings

1. **DO NOT** add tests beyond the 15 critical tests without discussion
2. **DO NOT** modify the production database schema without migrations
3. **ALWAYS** use MCP tools for Supabase operations when available
4. **REMEMBER** Google Vision API key needs rotation before production