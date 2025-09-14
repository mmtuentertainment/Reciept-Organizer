# Technical Constraints and Integration Requirements

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
