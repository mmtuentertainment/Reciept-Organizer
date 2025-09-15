# Database Backup and Restore Procedure

## Backup Created
- **Date:** 2025-09-13
- **File:** `backup_20250913_124029.sql`
- **Size:** 13,425 bytes
- **Tables Included:** 4 tables (receipts, sync_metadata, export_history, user_preferences)

## Backup Verification
✅ All expected tables present:
- receipts
- sync_metadata
- export_history
- user_preferences

## Restore Procedure (If Needed)

### Option 1: Restore to Local Supabase
```bash
# Stop existing Supabase
npx supabase stop

# Start fresh instance
npx supabase start

# Restore backup
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres < backup_20250913_124029.sql
```

### Option 2: Restore to Production (After Migration Failure)
```bash
# Connect to production database
npx supabase db remote set postgresql://[USER]:[PASSWORD]@[HOST]:[PORT]/[DATABASE]

# Restore backup
psql $DATABASE_URL < backup_20250913_124029.sql
```

### Option 3: Selective Restore
```bash
# Extract specific tables if needed
grep -A 1000 "CREATE TABLE.*receipts" backup_20250913_124029.sql > receipts_only.sql
```

## Important Notes
- Always create a new backup before restoring
- Test restore procedure in development first
- Keep multiple backup versions
- Document any data changes between backup and restore

## Backup Location
- Primary: `/infrastructure/supabase/backup_20250913_124029.sql`
- Keep for: 30 days minimum
- Status: **VERIFIED AND READY**