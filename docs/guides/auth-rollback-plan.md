# Authentication Rollback Plan

## Quick Rollback (< 1 minute)

### 1. Disable Auth via Feature Flags
```sql
-- Execute via mcp__supabase__execute_sql
UPDATE feature_flags SET value = 'false' WHERE name = 'auth_enabled';
UPDATE feature_flags SET value = 'true' WHERE name = 'auth_bypass';
```

### 2. Or use the monitoring script
```bash
npm run auth:rollback
```

## Full Rollback Procedure

### Step 1: Enable Bypass Mode (Immediate Relief)
```sql
-- Via mcp__supabase__execute_sql
UPDATE feature_flags SET
  value = 'true',
  updated_at = NOW()
WHERE name = 'auth_bypass';
```

### Step 2: Disable Authentication Features
```sql
UPDATE feature_flags SET
  value = 'false',
  updated_at = NOW()
WHERE name = 'auth_enabled';
```

### Step 3: Clear Active Sessions (Optional)
```sql
-- Only if needed to force all users out
DELETE FROM auth.sessions WHERE expires_at > NOW();
```

### Step 4: Disable RLS (If Critical)
```sql
-- CAUTION: This removes all data protection
ALTER TABLE receipts DISABLE ROW LEVEL SECURITY;
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
```

### Step 5: Notify Users
```javascript
// Use in-app notification system
await notifyAllUsers({
  type: 'maintenance',
  message: 'Authentication temporarily disabled for maintenance',
  severity: 'info'
});
```

## Rollback Triggers

Initiate rollback if any of these occur:

1. **Auth failure rate > 50%** for 5+ minutes
2. **Database response time > 1000ms** consistently
3. **RLS violations > 100** per minute
4. **User reports** of inability to access receipts
5. **Session creation failures** affecting > 10% of users

## Monitoring During Rollback

```bash
# Watch auth metrics
npm run auth:monitor monitor 1

# Check system health
npm run health:check

# Verify bypass mode is active
npm run auth:status
```

## Recovery After Rollback

### 1. Identify Root Cause
- Check logs: `mcp__supabase__get_logs({ service: 'auth' })`
- Review security advisories: `mcp__supabase__get_advisors({ type: 'security' })`
- Analyze error patterns in monitoring dashboard

### 2. Fix Issues
- Apply necessary patches
- Update RLS policies if needed
- Fix any integration issues

### 3. Test in Staging
```bash
# Switch to test environment
export NODE_ENV=test
npm run test:auth
```

### 4. Gradual Re-enable
```sql
-- Start with 10% of users
UPDATE feature_flags SET value = '10' WHERE name = 'auth_rollout_percentage';

-- Monitor, then increase gradually
-- 10% -> 25% -> 50% -> 100%
```

## Emergency Contacts

- **DevOps Lead**: [Contact Info]
- **Security Team**: [Contact Info]
- **Database Admin**: [Contact Info]
- **Customer Support Lead**: [Contact Info]

## Command Reference

### Feature Flag Commands
```bash
# Check current flags
npm run flags:status

# Enable auth
npm run flags:set auth_enabled true

# Disable auth
npm run flags:set auth_enabled false

# Set rollout percentage
npm run flags:set auth_rollout_percentage 25
```

### MCP Commands
```typescript
// Get auth logs
mcp__supabase__get_logs({ service: 'auth' })

// Check security advisories
mcp__supabase__get_advisors({ type: 'security' })

// Execute SQL
mcp__supabase__execute_sql({ query: 'SELECT * FROM feature_flags' })

// Apply migration
mcp__supabase__apply_migration({
  name: 'rollback_auth',
  query: '...'
})
```

## Post-Incident Review

After any rollback, conduct a review covering:

1. **Timeline** of events leading to rollback
2. **Root cause** analysis
3. **Impact** on users and data
4. **Response time** and effectiveness
5. **Improvements** for future incidents

Document findings in `/docs/incidents/[date]-auth-rollback.md`