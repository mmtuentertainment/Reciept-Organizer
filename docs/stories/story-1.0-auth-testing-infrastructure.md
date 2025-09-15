# Story 1.0: Authentication Testing Infrastructure Setup

## Story Overview
**ID**: STORY-1.0
**Epic**: Phase 2 - Authentication & User Management
**Priority**: P0 - Critical (Must complete first)
**Risk Level**: Low
**Estimated Points**: 5

**As a** developer,
**I want** comprehensive auth testing infrastructure,
**so that** I can safely test authentication without affecting production data.

## Business Value
- Enables safe development and testing of all authentication features
- Prevents production data corruption during development
- Provides foundation for automated testing of auth flows
- Reduces risk for all subsequent authentication stories

## Acceptance Criteria

### 1. Test Environment Configuration
- [ ] Separate Supabase project created for testing
- [ ] Test project URL and keys configured in .env.test
- [ ] Environment variable switching implemented
- [ ] Test database seeded with sample data

### 2. MCP Command Documentation
- [ ] Document test user creation: `mcp__supabase__execute_sql`
- [ ] Document test data cleanup commands
- [ ] Create helper scripts for common test scenarios
- [ ] Include rollback procedures for test data

### 3. Auth State Mocking
- [ ] Create auth mock utilities for existing 15 tests
- [ ] Implement mock authenticated user states
- [ ] Add mock session management
- [ ] Ensure all existing tests pass with mocks

### 4. Monitoring Dashboard
- [ ] Configure `mcp__supabase__get_logs` for auth events
- [ ] Set up `mcp__supabase__get_advisors` for security checks
- [ ] Create auth metrics tracking queries
- [ ] Document monitoring procedures

### 5. Rollback Procedures
- [ ] Document database rollback steps
- [ ] Create auth disable feature flag
- [ ] Test rollback procedures
- [ ] Prepare emergency response plan

## Technical Implementation

### Environment Setup
```bash
# Create test environment file
cp .env .env.test

# Update with test Supabase project
NEXT_PUBLIC_SUPABASE_URL=https://test-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=test-anon-key
SUPABASE_SERVICE_KEY=test-service-key
```

### Test User Creation (MCP Commands)
```sql
-- Via mcp__supabase__execute_sql
-- Create test users
INSERT INTO auth.users (id, email, encrypted_password)
VALUES
  ('test-user-1', 'test1@example.com', crypt('password123', gen_salt('bf'))),
  ('test-user-2', 'test2@example.com', crypt('password456', gen_salt('bf')));

-- Create test profiles
INSERT INTO profiles (id, username, full_name)
VALUES
  ('test-user-1', 'testuser1', 'Test User One'),
  ('test-user-2', 'testuser2', 'Test User Two');

-- Create test receipts
INSERT INTO receipts (user_id, merchant, amount, receipt_date)
VALUES
  ('test-user-1', 'Test Store', 99.99, '2024-01-01'),
  ('test-user-2', 'Sample Shop', 49.99, '2024-01-02');
```

### Auth Mock Utilities
```typescript
// test/utils/auth-mocks.ts
export const mockAuthUser = {
  id: 'test-user-1',
  email: 'test@example.com',
  user_metadata: { full_name: 'Test User' }
};

export const mockSession = {
  access_token: 'mock-access-token',
  refresh_token: 'mock-refresh-token',
  expires_at: Date.now() + 3600000,
  user: mockAuthUser
};

export const setupAuthMocks = () => {
  // Mock Supabase auth methods
  jest.mock('@supabase/supabase-js', () => ({
    createClient: jest.fn(() => ({
      auth: {
        getSession: jest.fn(() => ({ data: { session: mockSession } })),
        signIn: jest.fn(() => ({ data: { session: mockSession } })),
        signOut: jest.fn(() => ({ error: null }))
      }
    }))
  }));
};
```

### Monitoring Setup
```typescript
// scripts/monitor-auth.ts
import { mcp } from './mcp-client';

async function monitorAuth() {
  // Get recent auth logs
  const logs = await mcp.supabase.getLogs({ service: 'auth' });

  // Check for security advisories
  const advisories = await mcp.supabase.getAdvisors({ type: 'security' });

  // Track auth metrics
  const metrics = await mcp.supabase.executeSQL({
    query: `
      SELECT
        COUNT(DISTINCT user_id) as total_users,
        COUNT(*) as total_sessions,
        AVG(EXTRACT(EPOCH FROM (last_sign_in - created_at))) as avg_session_duration
      FROM auth.sessions
      WHERE created_at > NOW() - INTERVAL '24 hours'
    `
  });

  return { logs, advisories, metrics };
}
```

## Integration Verification

### IV1: Existing Tests Pass
```bash
# Run existing test suite with auth mocks
npm test -- --coverage

# Expected output:
# Test Suites: 15 passed, 15 total
# Tests: 87 passed, 87 total
# Coverage: 85%
```

### IV2: Test Data Isolation
```sql
-- Via mcp__supabase__execute_sql
-- Verify test data doesn't appear in production
SELECT COUNT(*) FROM receipts WHERE user_id LIKE 'test-%';
-- Expected: 0 in production, >0 in test
```

### IV3: Performance Verification
```typescript
// Measure test execution time
console.time('Test Suite Execution');
await runTests();
console.timeEnd('Test Suite Execution');
// Should be < 30 seconds
```

## Definition of Done
- [ ] Test environment fully configured and documented
- [ ] All 15 existing tests pass with auth mocks
- [ ] MCP commands documented and tested
- [ ] Monitoring dashboard accessible
- [ ] Rollback procedures tested successfully
- [ ] Team trained on test infrastructure usage
- [ ] Documentation added to project wiki

## Dependencies
- Supabase test project created
- Access to MCP Supabase tools
- Existing test suite analysis complete

## Risks & Mitigation
| Risk | Impact | Mitigation |
|------|--------|------------|
| Test data leaks to production | High | Separate project, different keys |
| Mocks don't match real auth | Medium | Regular sync with actual auth behavior |
| Test environment downtime | Low | Local fallback testing option |

## Follow-up Stories
- Story 1.1: Web Authentication Enhancement
- Story 1.2: Database RLS and Migration Setup
- All subsequent auth stories depend on this infrastructure

## Notes
- This story MUST be completed first to ensure safe development
- Consider creating a test data generator for complex scenarios
- Document any discovered auth edge cases for future reference