# Authentication Testing Guide

## Overview

This guide provides safe testing procedures for authentication features using production Supabase with test user isolation.

## Test User Management

### Creating Test Users

Use MCP commands to create isolated test users:

```sql
-- Via mcp__supabase__execute_sql
-- Create test user with specific prefix
INSERT INTO auth.users (
  id,
  email,
  raw_user_meta_data,
  created_at,
  updated_at
) VALUES (
  gen_random_uuid(),
  'test_' || gen_random_uuid()::text || '@example.com',
  '{"test_user": true}'::jsonb,
  NOW(),
  NOW()
);
```

### Test User Conventions

- **Email Pattern**: `test_*@example.com`
- **Metadata Marker**: `{"test_user": true}`
- **Username Prefix**: `test_`
- **Auto-cleanup**: After 24 hours

## MCP Commands for Testing

### 1. Check Auth Logs
```bash
# Monitor authentication attempts
mcp__supabase__get_logs --service auth

# Check for failed logins
mcp__supabase__execute_sql --query "
  SELECT * FROM auth.audit_log_entries
  WHERE payload->>'type' = 'LOGIN_FAILED'
  AND created_at > NOW() - INTERVAL '1 hour'
"
```

### 2. Create Test Session
```sql
-- Via mcp__supabase__execute_sql
-- Create a test session for automated testing
INSERT INTO auth.sessions (
  id,
  user_id,
  created_at,
  updated_at,
  factor_id,
  aal,
  not_after
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email LIKE 'test_%' LIMIT 1),
  NOW(),
  NOW(),
  NULL,
  'aal1',
  NOW() + INTERVAL '2 hours'
);
```

### 3. Clean Test Data
```sql
-- Via mcp__supabase__execute_sql
-- Remove test users and their data
DELETE FROM receipts WHERE user_id IN (
  SELECT id FROM auth.users
  WHERE email LIKE 'test_%'
  OR raw_user_meta_data->>'test_user' = 'true'
);

DELETE FROM auth.users
WHERE email LIKE 'test_%'
OR raw_user_meta_data->>'test_user' = 'true';
```

## Security Monitoring

### Check Security Advisories
```bash
# Regular security checks
mcp__supabase__get_advisors --type security

# Monitor for suspicious activity
mcp__supabase__execute_sql --query "
  SELECT
    COUNT(*) as attempt_count,
    payload->>'email' as email
  FROM auth.audit_log_entries
  WHERE payload->>'type' = 'LOGIN_FAILED'
  AND created_at > NOW() - INTERVAL '1 hour'
  GROUP BY payload->>'email'
  HAVING COUNT(*) > 5
"
```

### Performance Monitoring
```sql
-- Via mcp__supabase__execute_sql
-- Check auth response times
SELECT
  AVG(EXTRACT(EPOCH FROM (updated_at - created_at))) as avg_auth_time,
  COUNT(*) as total_auths
FROM auth.sessions
WHERE created_at > NOW() - INTERVAL '24 hours';
```

## Test Environment Variables

### Development Testing (.env.test)
```bash
# Use production Supabase with test user isolation
NEXT_PUBLIC_SUPABASE_URL=https://xbadaalqaeszooyxuoac.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=<production-anon-key>
TEST_USER_PREFIX=test_
TEST_AUTO_CLEANUP=true
```

### Running Tests with Auth
```bash
# Flutter tests with auth mocks
cd apps/mobile
flutter test --dart-define=TEST_MODE=true

# Web tests with auth
cd apps/web
npm test -- --env=test

# Native tests
cd apps/native
npm test -- --testEnvironment=node
```

## Rollback Procedures

### 1. Disable Authentication
```sql
-- Via mcp__supabase__apply_migration
-- Emergency auth disable
ALTER TABLE auth.users RENAME TO auth.users_backup;
CREATE VIEW auth.users AS
  SELECT * FROM auth.users_backup WHERE false;
```

### 2. Restore Authentication
```sql
-- Via mcp__supabase__apply_migration
-- Restore auth functionality
DROP VIEW IF EXISTS auth.users;
ALTER TABLE auth.users_backup RENAME TO auth.users;
```

### 3. Reset Sessions
```sql
-- Via mcp__supabase__execute_sql
-- Clear all active sessions
TRUNCATE auth.sessions CASCADE;
```

## Automated Test Scripts

### Monitor Auth Health
Create `scripts/monitor-auth.js`:
```javascript
async function monitorAuth() {
  // Check auth service health
  const logs = await mcp.supabase.getLogs({ service: 'auth' });

  // Check for security issues
  const advisories = await mcp.supabase.getAdvisors({ type: 'security' });

  // Monitor metrics
  const metrics = await mcp.supabase.executeSQL({
    query: `
      SELECT
        COUNT(DISTINCT user_id) as active_users,
        COUNT(*) as total_sessions,
        AVG(EXTRACT(EPOCH FROM (updated_at - created_at))) as avg_session_duration
      FROM auth.sessions
      WHERE created_at > NOW() - INTERVAL '24 hours'
    `
  });

  console.log({ logs, advisories, metrics });
}
```

## Best Practices

1. **Always use test user prefix** (`test_`) for test accounts
2. **Set metadata markers** to identify test data
3. **Clean up test data** after testing sessions
4. **Monitor auth logs** during development
5. **Use MCP commands** instead of direct database access
6. **Document any test users** created for specific scenarios

## Emergency Contacts

- **Production Issues**: Check Supabase dashboard
- **Security Concerns**: Run `mcp__supabase__get_advisors`
- **Performance Issues**: Check auth metrics via MCP

## Test User Examples

### Basic Test User
```javascript
const testUser = {
  email: 'test_basic@example.com',
  password: 'TestPass123!',
  metadata: { test_user: true, scenario: 'basic' }
};
```

### Premium Test User
```javascript
const premiumTestUser = {
  email: 'test_premium@example.com',
  password: 'TestPass456!',
  metadata: {
    test_user: true,
    scenario: 'premium',
    features: ['unlimited_receipts', 'export_all']
  }
};
```

## Verification Checklist

- [ ] Test users created with proper prefix
- [ ] Auth logs monitored for errors
- [ ] Security advisories checked
- [ ] Performance metrics within limits
- [ ] Test data cleaned after session
- [ ] No production users affected
- [ ] Rollback procedures tested