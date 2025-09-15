# Story 1.2: Database RLS and Migration Setup

## Story Overview
**ID**: STORY-1.2
**Epic**: Phase 2 - Authentication & User Management
**Priority**: P0 - Critical
**Risk Level**: Medium (Database changes affect all platforms)
**Estimated Points**: 5

**As a** system administrator,
**I want** Row Level Security policies configured,
**so that** users can only access their own data.

## Business Value
- Ensures data privacy and security compliance
- Enables multi-tenant architecture
- Prevents unauthorized data access
- Foundation for all authenticated features

## Acceptance Criteria

### 1. RLS Policies Creation
- [ ] Create RLS policies via `mcp__supabase__apply_migration`
- [ ] Policy for SELECT: users see only their receipts
- [ ] Policy for INSERT: users create receipts with their ID
- [ ] Policy for UPDATE: users modify only their receipts
- [ ] Policy for DELETE: users delete only their receipts

### 2. Schema Updates
- [ ] Add user_id column to receipts table
- [ ] Create profiles table linked to auth.users
- [ ] Add indexes for user_id queries
- [ ] Update existing receipts with default user

### 3. Migration Management
- [ ] Create reversible migration scripts
- [ ] Test rollback procedures
- [ ] Document migration steps
- [ ] Create backup before migration

### 4. Performance Validation
- [ ] Run `mcp__supabase__get_advisors` for optimization tips
- [ ] Verify query performance < 200ms
- [ ] Check index usage with EXPLAIN
- [ ] Monitor database size changes

### 5. Data Integrity
- [ ] Verify no data loss post-migration
- [ ] Ensure foreign key constraints work
- [ ] Test cascade delete behavior
- [ ] Validate NULL handling for legacy data

## Technical Implementation

### Migration Script via MCP
```sql
-- Migration: 001_add_user_authentication.sql
-- Execute via: mcp__supabase__apply_migration

-- Step 1: Add user_id column to receipts
ALTER TABLE receipts 
ADD COLUMN user_id UUID REFERENCES auth.users(id);

-- Step 2: Create profiles table
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  website TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Step 3: Create indexes
CREATE INDEX idx_receipts_user_id ON receipts(user_id);
CREATE INDEX idx_receipts_user_date ON receipts(user_id, receipt_date DESC);
CREATE INDEX idx_profiles_username ON profiles(username);

-- Step 4: Update existing receipts (temporary default user)
UPDATE receipts 
SET user_id = '00000000-0000-0000-0000-000000000000'
WHERE user_id IS NULL;

-- Step 5: Make user_id required after migration
ALTER TABLE receipts 
ALTER COLUMN user_id SET NOT NULL;
```

### RLS Policies Setup
```sql
-- Execute via: mcp__supabase__apply_migration
-- Migration: 002_enable_rls_policies.sql

-- Enable RLS on tables
ALTER TABLE receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Receipts policies
CREATE POLICY "Users can view own receipts"
  ON receipts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own receipts"
  ON receipts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own receipts"
  ON receipts FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own receipts"
  ON receipts FOR DELETE
  USING (auth.uid() = user_id);

-- Profiles policies
CREATE POLICY "Profiles are viewable by everyone"
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);
```

### Performance Testing Queries
```sql
-- Execute via: mcp__supabase__execute_sql

-- Test query performance with RLS
EXPLAIN ANALYZE
SELECT * FROM receipts 
WHERE user_id = auth.uid()
ORDER BY receipt_date DESC
LIMIT 20;

-- Check index usage
SELECT 
  schemaname,
  tablename,
  indexname,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch
FROM pg_stat_user_indexes
WHERE tablename IN ('receipts', 'profiles');

-- Monitor table sizes
SELECT 
  relname AS table_name,
  pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
  pg_size_pretty(pg_relation_size(relid)) AS table_size,
  pg_size_pretty(pg_indexes_size(relid)) AS indexes_size
FROM pg_stat_user_tables
WHERE schemaname = 'public';
```

### Rollback Script
```sql
-- Rollback: 001_rollback_user_authentication.sql
-- Emergency rollback if needed

-- Disable RLS
ALTER TABLE receipts DISABLE ROW LEVEL SECURITY;
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Drop policies
DROP POLICY IF EXISTS "Users can view own receipts" ON receipts;
DROP POLICY IF EXISTS "Users can insert own receipts" ON receipts;
DROP POLICY IF EXISTS "Users can update own receipts" ON receipts;
DROP POLICY IF EXISTS "Users can delete own receipts" ON receipts;
DROP POLICY IF EXISTS "Profiles are viewable by everyone" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;

-- Drop indexes
DROP INDEX IF EXISTS idx_receipts_user_id;
DROP INDEX IF EXISTS idx_receipts_user_date;
DROP INDEX IF EXISTS idx_profiles_username;

-- Drop profiles table
DROP TABLE IF EXISTS profiles;

-- Remove user_id column
ALTER TABLE receipts DROP COLUMN IF EXISTS user_id;
```

### Monitoring with MCP
```typescript
// scripts/monitor-rls.ts

// Check for RLS violations
const securityCheck = await mcp.supabase.getAdvisors({ 
  type: 'security' 
});

// Monitor query performance
const logs = await mcp.supabase.getLogs({ 
  service: 'postgres' 
});

// Verify RLS is enabled
const rlsStatus = await mcp.supabase.executeSQL({
  query: `
    SELECT 
      schemaname,
      tablename,
      rowsecurity
    FROM pg_tables
    WHERE schemaname = 'public'
      AND tablename IN ('receipts', 'profiles');
  `
});
```

## Integration Verification

### IV1: Existing Queries Work with RLS
```typescript
// Test existing receipt queries
const { data, error } = await supabase
  .from('receipts')
  .select('*')
  .order('receipt_date', { ascending: false });

expect(error).toBeNull();
expect(data).toHaveLength(userReceiptCount);
```

### IV2: No Data Loss
```sql
-- Via mcp__supabase__execute_sql
-- Compare counts before and after
SELECT 
  COUNT(*) as total_receipts,
  COUNT(DISTINCT merchant) as unique_merchants,
  SUM(amount) as total_amount
FROM receipts;
-- Should match pre-migration counts
```

### IV3: Query Performance
```bash
# Run performance test
npm run test:performance -- --test="database-queries"

# Expected results:
# - Receipt list query: < 200ms
# - Single receipt fetch: < 50ms
# - Receipt creation: < 100ms
```

## Definition of Done
- [ ] All migration scripts executed successfully
- [ ] RLS policies active and tested
- [ ] Performance targets met (< 200ms queries)
- [ ] No data loss verified
- [ ] Rollback procedure tested
- [ ] Security advisories addressed
- [ ] Documentation updated
- [ ] Team notified of schema changes

## Dependencies
- Story 1.0 (Testing Infrastructure) complete
- Story 1.1 (Web Authentication) complete
- Backup of production database taken
- MCP Supabase tools available

## Risks & Mitigation
| Risk | Impact | Mitigation |
|------|--------|------------|
| Data loss during migration | Critical | Full backup, test on staging first |
| Performance degradation | High | Index optimization, query analysis |
| RLS misconfiguration | High | Thorough testing, security advisories |
| Migration failure | Medium | Rollback scripts ready |

## Follow-up Stories
- Story 1.3: Mobile (Flutter) Authentication
- Story 1.4: Native (React Native) Authentication
- Story 1.6: User Profile Management

## Notes
- Consider partitioning receipts table if > 1M records
- Monitor slow query log post-deployment
- Plan for archival strategy for old receipts