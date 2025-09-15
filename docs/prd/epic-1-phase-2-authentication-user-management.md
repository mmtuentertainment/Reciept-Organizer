# Epic 1: Phase 2 - Authentication & User Management

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
