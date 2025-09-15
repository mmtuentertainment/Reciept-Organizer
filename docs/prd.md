# Receipt Organizer Phase 2 Authentication - Brownfield Enhancement PRD

## Intro Project Analysis and Context

### Existing Project Overview

#### Analysis Source
- Document-project output available at: `/home/matt/FINAPP/Receipt Organizer/docs/brownfield-architecture.md`
- IDE-based fresh analysis with MCP server capabilities

#### Current Project State

The Receipt Organizer is a multi-platform receipt management system for mom-and-pop businesses (100-500 receipts/month). Phase 1 (Database Foundation & Storage) is complete with production Supabase infrastructure deployed. The system provides offline-first receipt capture, OCR processing, and CSV export across three platforms: Flutter (mobile/web), Next.js (web), and React Native (native mobile).

### Available Documentation Analysis

Using existing project analysis from document-project output:

**Available Documentation** ✓
- Tech Stack Documentation ✓ (from brownfield-architecture.md)
- Source Tree/Architecture ✓ (comprehensive monorepo structure documented)
- Coding Standards ✓ (platform-specific patterns identified)
- API Documentation ✓ (Supabase REST/GraphQL documented)
- External API Documentation ✓ (Google Vision API, MCP servers)
- Technical Debt Documentation ✓ (critical gaps identified)
- UX/UI Guidelines ⚠️ (shadcn for web, custom for mobile)

### Enhancement Scope Definition

#### Enhancement Type
✓ **Major Feature Modification** - Adding comprehensive authentication system
✓ **Integration with New Systems** - Supabase Auth across all platforms
✓ **Technology Stack Upgrade** - Implementing OAuth, session management

#### Enhancement Description
Implement Phase 2 Authentication & User Management across all three platforms (Flutter, Next.js, React Native), integrating Supabase Auth with email/password, OAuth (Google), session management, and user profiles while maintaining offline-first architecture.

#### Impact Assessment
✓ **Significant Impact** - Substantial existing code changes required across all platforms, new auth flows, session management, and user profile features

### Goals and Background Context

#### Goals
- Enable secure multi-user access with Supabase Auth integration
- Implement consistent authentication across Flutter, Next.js, and React Native
- Support email/password and OAuth (Google) authentication methods
- Provide offline-capable session management with automatic token refresh
- Create user profile management with avatar upload capability
- Leverage MCP servers for rapid development and testing

#### Background Context
With Phase 1's database and storage infrastructure complete, the system needs authentication to support multiple users and secure data isolation. Currently, the web app has basic Supabase auth working, mobile has disconnected auth implementation, and native has no auth at all. This enhancement will unify authentication across all platforms using Supabase Auth, enabling the system to support real business users with proper data isolation and security.

### Change Log

| Change | Date | Version | Description | Author |
|--------|------|---------|-------------|---------|
| Initial Creation | 2025-09-14 | 1.0 | Phase 2 Authentication PRD | John (PM) |

## Requirements

### Functional Requirements

- **FR1**: The system SHALL implement Supabase Auth integration across all three platforms (Flutter web, Next.js, React Native) with consistent user experience
- **FR2**: Users SHALL be able to sign up and log in using email/password authentication with secure password requirements
- **FR3**: Users SHALL be able to authenticate using OAuth providers, starting with Google Sign-In
- **FR4**: The system SHALL maintain user sessions with automatic token refresh before expiration
- **FR5**: Users SHALL be able to manage their profile information including username, full name, website, and avatar
- **FR6**: The system SHALL support profile photo upload to Supabase Storage with automatic thumbnail generation
- **FR7**: Each authenticated user SHALL only access their own receipts via Row Level Security (RLS) policies
- **FR8**: The mobile app SHALL support offline authentication with cached credentials and sync when online
- **FR9**: Users SHALL be able to sign out from any platform, invalidating their session across all devices
- **FR10**: The system SHALL provide password reset functionality via email magic links
- **FR11**: Session state SHALL be synchronized across browser tabs in web applications
- **FR12**: The system SHALL track and display user authentication status in the UI
- **FR13**: The system SHALL remember user login state across app restarts using platform-specific secure storage (Keychain for iOS, Keystore for Android, secure cookies for web)
- **FR14**: The system SHALL support biometric authentication (fingerprint/face) on mobile devices as a convenience feature after initial password authentication
- **FR15**: The system SHALL automatically log out inactive users after configured timeout periods (30 minutes for web, 2 hours for mobile)

### Non-Functional Requirements

- **NFR1**: Authentication responses SHALL complete within 2 seconds under normal network conditions
- **NFR2**: The system SHALL handle up to 1000 concurrent authenticated users without degradation
- **NFR3**: Passwords SHALL be hashed using bcrypt with a minimum cost factor of 10
- **NFR4**: JWT tokens SHALL expire after 1 hour with refresh tokens valid for 7 days
- **NFR5**: The system SHALL log all authentication attempts for security auditing via MCP monitoring
- **NFR6**: OAuth integrations SHALL use PKCE flow for enhanced security
- **NFR7**: The system SHALL maintain 99.9% availability for authentication services
- **NFR8**: Profile images SHALL be limited to 5MB with supported formats: JPG, PNG, WebP
- **NFR9**: The system SHALL comply with GDPR requirements for user data handling
- **NFR10**: Authentication errors SHALL provide user-friendly messages without exposing system details
- **NFR11**: Authentication state changes SHALL be reflected in the UI within 100ms to provide immediate user feedback
- **NFR12**: Biometric authentication SHALL fall back gracefully to password entry if biometric fails or is unavailable
- **NFR13**: Session timeout warnings SHALL be dismissible to extend the session for another timeout period

### Compatibility Requirements

- **CR1**: Existing API Compatibility - All current receipt endpoints SHALL continue functioning with added auth headers
- **CR2**: Database Schema Compatibility - New auth tables SHALL not modify existing receipt schema, only extend via foreign keys
- **CR3**: UI/UX Consistency - Auth UI SHALL use existing design system (shadcn for web, Material for Flutter)
- **CR4**: Integration Compatibility - Google Vision API calls SHALL include user context for quota tracking per user
- **CR5**: Storage Compatibility - Existing receipt images SHALL be migrated to user-specific storage buckets
- **CR6**: Test Suite Compatibility - Authentication SHALL not break the existing 15 critical tests

## User Interface Enhancement Goals

### Integration with Existing UI

New authentication UI elements will integrate with existing patterns:
- **Web (Next.js)**: Use shadcn/ui components for forms, buttons, and modals to match existing dashboard
- **Mobile (Flutter)**: Follow Material Design 3 patterns already established in capture screens
- **Native (React Native)**: Implement NativeWind styling consistent with existing tab navigation

### Modified/New Screens and Views

**New Screens:**
- Login/Sign-up screen (all platforms)
- Password reset screen (all platforms)
- User profile management screen (all platforms)
- OAuth callback handler (web-specific)

**Modified Screens:**
- Main navigation - Add user avatar/menu (all platforms)
- Settings screen - Add authentication section (mobile/native)
- Dashboard header - Add user info widget (web)

### UI Consistency Requirements
- All auth forms must use existing validation error patterns
- Loading states during auth operations must match existing loading indicators
- Success/error messages must use current toast/snackbar implementations
- Color schemes and typography must remain consistent with Phase 1 UI

## Technical Constraints and Integration Requirements

### Existing Technology Stack

**Languages**: Dart (Flutter), TypeScript (Next.js/React Native), JavaScript (API)
**Frameworks**: Flutter 3.35.3, Next.js 15.1.3, React Native/Expo SDK 52
**Database**: PostgreSQL via Supabase (project: xbadaalqaeszooyxuoac)
**Infrastructure**: Supabase Production (Auth, Database, Storage, Realtime)
**External Dependencies**: Google Vision API, MCP Servers (Supabase, shadcn)

### Integration Approach

**Database Integration Strategy**:
- Use Supabase Auth's built-in `auth.users` table
- Link to existing `profiles` table via UUID foreign key
- Apply RLS policies via `mcp__supabase__apply_migration`
- No modifications to existing receipt tables, only add user_id references

**API Integration Strategy**:
- Add Supabase JWT verification middleware to all endpoints
- Include user context in all database queries
- Maintain backward compatibility with temporary anonymous access during migration

**Frontend Integration Strategy**:
- Web: Implement using `@supabase/ssr` for Next.js cookie-based sessions
- Mobile: Use `supabase_flutter` package with secure storage
- Native: Implement `@supabase/supabase-js` with Expo SecureStore

**Testing Integration Strategy**:
- Create test users via `mcp__supabase__execute_sql`
- Mock auth in existing 15 tests to maintain test suite
- Add auth-specific integration tests separately (not counted in 15)

### Code Organization and Standards

**File Structure Approach**:
- Follow existing feature-based structure: `features/auth/` in each platform
- Maintain existing provider patterns (Riverpod for Flutter, Context for React)

**Naming Conventions**:
- Flutter: `auth_provider.dart`, `session_manager.dart`
- Web/Native: `authContext.tsx`, `useAuth.ts`

**Coding Standards**:
- Follow existing patterns identified in brownfield analysis
- Use platform-specific best practices for secure storage

**Documentation Standards**:
- Update inline comments for auth flows
- Create auth-specific README in each platform's auth folder

### Deployment and Operations

**Build Process Integration**:
- Add environment variables for Supabase auth to build configs
- No changes to existing build pipelines

**Deployment Strategy**:
- Deploy database migrations first via MCP
- Rolling deployment: Web → Mobile → Native
- Feature flag for gradual auth rollout

**Monitoring and Logging**:
- Use `mcp__supabase__get_logs service:auth` for auth monitoring
- Integrate with existing error tracking (if any)

**Configuration Management**:
- Store Supabase keys in environment variables
- Use platform-specific secure config methods
- Platform-specific timeout configuration:
  - Web: 30-minute inactivity timeout (desktop usage pattern)
  - Mobile: 2-hour inactivity timeout (accounts for lock screen security)
  - Native: 2-hour inactivity timeout (mobile device pattern)

### Risk Assessment and Mitigation

**Technical Risks**:
- Token refresh race conditions across platforms
- Offline/online auth state sync complexities
- Platform-specific secure storage differences

**Integration Risks**:
- Breaking existing receipt functionality during auth addition
- RLS policies blocking legitimate user access
- Session state conflicts between platforms

**Deployment Risks**:
- User data migration from anonymous to authenticated
- Rollback complexity if auth issues discovered

**Mitigation Strategies**:
- Implement comprehensive auth state machine with clear transitions
- Test RLS policies thoroughly using MCP SQL execution
- Create rollback plan with feature flags
- Gradual rollout with beta user group

## Epic and Story Structure

**Epic Structure Decision**: Single comprehensive epic for Phase 2 Authentication

**Rationale**: All authentication features are tightly interconnected and must be coordinated across three platforms. A single epic ensures consistent implementation and reduces integration risks.

## Epic 1: Phase 2 - Authentication & User Management

**Epic Goal**: Implement secure, cross-platform authentication using Supabase Auth while maintaining existing receipt functionality and offline-first architecture

**Integration Requirements**:
- Zero disruption to existing receipt capture and export features
- Gradual rollout with feature flags
- Backward compatibility during migration period
- Comprehensive monitoring via MCP tools

### Story 1.0: Authentication Testing Infrastructure Setup

**As a** developer,
**I want** comprehensive auth testing infrastructure,
**so that** I can safely test authentication without affecting production data.

#### Acceptance Criteria
1. Test environment configured with separate Supabase project
2. MCP commands documented for test user creation/deletion
3. Auth state mocking utilities created for existing 15 tests
4. Monitoring dashboard configured using `mcp__supabase__get_logs`
5. Rollback procedures documented and tested

#### Integration Verification
- IV1: Existing 15 tests still pass with auth mocks
- IV2: Test data isolation confirmed via MCP SQL queries
- IV3: No performance degradation in test execution

### Story 1.1: Web Authentication Enhancement

**As a** web user,
**I want** to log in and sign up through the Next.js app,
**so that** my receipts are securely associated with my account.

#### Acceptance Criteria
1. Login/signup pages created using shadcn/ui components
2. Supabase Auth integrated with cookie-based sessions
3. Email/password authentication working
4. Password reset flow implemented
5. Session persistence across browser tabs
6. User menu added to dashboard header

#### Integration Verification
- IV1: Existing dashboard and receipt features remain functional
- IV2: Cookie-based auth works with SSR
- IV3: No impact on page load performance (<2s)

### Story 1.2: Database RLS and Migration Setup

**As a** system administrator,
**I want** Row Level Security policies configured,
**so that** users can only access their own data.

#### Acceptance Criteria
1. RLS policies created via `mcp__supabase__apply_migration`
2. User_id column added to receipts table
3. Profiles table linked to auth.users
4. Migration tested and reversible
5. Performance validated via `mcp__supabase__get_advisors`

#### Integration Verification
- IV1: Existing receipt queries still work with RLS
- IV2: No data loss during migration
- IV3: Query performance remains <200ms

### Story 1.3: Mobile (Flutter) Authentication Implementation

**As a** mobile user,
**I want** to authenticate in the Flutter app,
**so that** I can securely access my receipts on mobile web.

#### Acceptance Criteria
1. Login/signup screens matching Material Design 3
2. Supabase Flutter package integrated
3. Secure token storage implemented
4. Session management with auto-refresh
5. Offline authentication with cached credentials
6. 2-hour inactivity timeout configured

#### Integration Verification
- IV1: Receipt capture and export continue working
- IV2: Offline-first functionality preserved
- IV3: Chrome web runtime compatibility maintained

### Story 1.4: Native (React Native) Authentication Implementation

**As a** native mobile app user,
**I want** to authenticate in the React Native app,
**so that** I have secure access on iOS and Android.

#### Acceptance Criteria
1. Auth screens with NativeWind styling
2. Expo SecureStore for token storage
3. Supabase JS client configured
4. Session state management implemented
5. Platform-specific auth flows (iOS/Android)
6. 2-hour inactivity timeout configured

#### Integration Verification
- IV1: Tab navigation continues functioning
- IV2: Expo SDK 52 compatibility maintained
- IV3: Build process unchanged

### Story 1.5: Google OAuth Integration

**As a** user,
**I want** to sign in with my Google account,
**so that** I can authenticate quickly without remembering another password.

#### Acceptance Criteria
1. Google OAuth configured in Supabase dashboard
2. OAuth flow implemented on all platforms
3. PKCE security implemented
4. Callback handlers configured
5. Account linking for existing email users
6. Error handling for OAuth failures

#### Integration Verification
- IV1: Email/password auth still works
- IV2: OAuth doesn't create duplicate accounts
- IV3: Seamless platform transitions

### Story 1.6: User Profile Management

**As an** authenticated user,
**I want** to manage my profile information,
**so that** I can personalize my account.

#### Acceptance Criteria
1. Profile screens on all platforms
2. Edit username, full name, website
3. Avatar upload to Supabase Storage
4. 5MB image size limit enforced
5. Profile data synced across platforms
6. shadcn components for web UI via `mcp__shadcn__get_add_command_for_items`

#### Integration Verification
- IV1: Receipt storage quotas unaffected
- IV2: Profile changes don't break auth
- IV3: Image upload doesn't impact performance

### Story 1.7: Biometric Authentication

**As a** mobile user,
**I want** to use fingerprint/face recognition,
**so that** I can quickly access the app securely.

#### Acceptance Criteria
1. Biometric prompt after initial password auth
2. Secure storage of biometric credentials
3. Graceful fallback to password
4. User opt-in/opt-out settings
5. Platform-specific implementations (Touch ID, Face ID, Android Biometric)

#### Integration Verification
- IV1: Password auth remains primary method
- IV2: Biometric failure doesn't lock out user
- IV3: Settings sync across app restarts

### Story 1.8: Monitoring and Rollback Plan

**As a** system administrator,
**I want** comprehensive monitoring and rollback capability,
**so that** I can respond quickly to any authentication issues.

#### Acceptance Criteria
1. Auth metrics dashboard using MCP logs
2. Alert thresholds configured
3. Feature flags for gradual rollout
4. Rollback procedures tested
5. Data migration reversal plan
6. User communication templates prepared

#### Integration Verification
- IV1: Monitoring doesn't impact performance
- IV2: Rollback preserves all user data
- IV3: Feature flags work across all platforms

## Summary

This PRD defines a comprehensive, risk-minimized approach to implementing Phase 2 Authentication & User Management for the Receipt Organizer application. The implementation leverages existing Supabase infrastructure from Phase 1, utilizes MCP servers for accelerated development, and maintains the critical offline-first architecture while adding secure multi-user capabilities across all three platforms.