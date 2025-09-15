# Production Deployment Checklist

**Date:** _______________
**Deployed By:** _______________
**Version:** Production v1.0
**Epic:** 5 - Production Infrastructure

---

## Phase 1: Pre-Deployment Validation ✅

### Story 5.1.1: Local Database Backup
- [x] Local Supabase instance running
- [x] Database backup created with timestamp
- [x] Backup file verified (>100KB)
- [x] Backup location documented: `backup_20250913_124029.sql`
- [x] Restore procedure tested

### Story 5.1.2: Migration Safety Review
- [x] All migrations reviewed for destructive operations
- [x] No DROP/DELETE/TRUNCATE operations found
- [x] Migration dependencies verified
- [x] Rollback procedures documented
- [x] Safety report created: `MIGRATION_SAFETY_REVIEW.md`

### Story 5.1.3: Deployment Checklist (This Document)
- [x] Checklist created
- [x] All critical steps included
- [x] Team notification procedures added

---

## Phase 2: Team Notifications 📢

### Pre-Deployment
- [ ] Notify team in Slack/Discord: "Starting production deployment"
- [ ] Share deployment window: Estimated 2.5 hours
- [ ] Confirm no one is testing production
- [ ] Get approval from team lead

### Contact List
- **Primary Contact:** _______________
- **Backup Contact:** _______________
- **Emergency Escalation:** _______________

---

## Phase 3: Supabase Project Setup 🚀

### Epic 5.2 Execution
- [ ] Open Supabase Dashboard: https://supabase.com/dashboard
- [ ] Create new project "receipt-organizer-prod"
- [ ] Generate strong database password (32+ chars)
- [ ] Store password in password manager
- [ ] Select appropriate region: _______________
- [ ] Capture and secure credentials:
  - [ ] Project URL: _______________
  - [ ] Anon Key: _______________
  - [ ] Service Role Key: _______________
  - [ ] Project Ref: _______________
- [ ] Update `.env.mcp` with Project Ref

### Authentication Configuration
- [ ] Enable Email authentication
- [ ] Enable email confirmation
- [ ] Enable Anonymous authentication
- [ ] Configure JWT expiry (3600 seconds)
- [ ] Test auth endpoints

---

## Phase 4: Database Migration 💾

### Epic 5.3 Execution
- [ ] Link Supabase CLI to production project
- [ ] Run migration dry run: `npx supabase db push --dry-run`
- [ ] Review dry run output - NO destructive operations
- [ ] Create pre-migration backup (even if empty)
- [ ] Apply migrations: `npx supabase db push`
- [ ] Verify schema with: `npx supabase db diff --use-migra`
- [ ] Confirm all tables created:
  - [ ] receipts
  - [ ] sync_metadata
  - [ ] export_history
  - [ ] user_preferences

---

## Phase 5: Security Configuration 🔒

### Epic 5.4 Execution
- [ ] Verify RLS enabled on all tables
- [ ] Test anonymous API access (should return empty/401)
- [ ] Review all policies (10 policies minimum)
- [ ] Test authenticated access
- [ ] Verify user isolation
- [ ] Document API endpoints
- [ ] Create security runbook

### Security Verification Commands
```sql
-- Run in SQL Editor
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public';
-- All should show: rowsecurity = true
```

---

## Phase 6: Environment Configuration 🔧

### Application Updates
- [ ] Update mobile app environment:
  - [ ] SUPABASE_URL
  - [ ] SUPABASE_ANON_KEY
- [ ] Update web app environment:
  - [ ] NEXT_PUBLIC_SUPABASE_URL
  - [ ] NEXT_PUBLIC_SUPABASE_ANON_KEY
- [ ] Update CI/CD secrets
- [ ] Test connections from both apps

---

## Phase 7: Post-Deployment Verification ✔️

### Smoke Tests
- [ ] Create anonymous session
- [ ] Create email account
- [ ] Upload test receipt
- [ ] Verify sync working
- [ ] Test data isolation between users
- [ ] Export test data
- [ ] Check monitoring/logs

### Performance Baseline
- [ ] API response time: _______________ ms
- [ ] Database query time: _______________ ms
- [ ] Storage upload time: _______________ ms

---

## Phase 8: Documentation 📚

### Update Documentation
- [ ] Update README with production URLs
- [ ] Document credentials location
- [ ] Update API documentation
- [ ] Create incident response guide
- [ ] Share deployment notes with team

### Artifacts Created
- [ ] Backup files
- [ ] Migration logs
- [ ] Security audit results
- [ ] Performance baselines

---

## Rollback Procedures 🔄

### Level 1: Configuration Rollback (5 min)
- [ ] Revert environment variables
- [ ] Restart applications
- [ ] Verify rollback successful

### Level 2: Code Rollback (10 min)
- [ ] Git revert to previous commit
- [ ] Redeploy applications
- [ ] Verify functionality

### Level 3: Database Rollback (30 min)
- [ ] Stop all connections
- [ ] Restore from backup: `backup_20250913_124029.sql`
- [ ] Reapply safe migrations only
- [ ] Verify data integrity

### Level 4: Full Rollback (1 hour)
- [ ] Delete Supabase project
- [ ] Restore all components to pre-deployment state
- [ ] Document lessons learned
- [ ] Schedule retry

---

## Sign-Off ✍️

### Deployment Team
- [ ] DevOps Engineer: _______________ Date: _______________
- [ ] Team Lead: _______________ Date: _______________
- [ ] Security Review: _______________ Date: _______________

### Final Status
- [ ] All checks passed
- [ ] Production is live
- [ ] Monitoring active
- [ ] Team notified

---

## Notes Section

### Issues Encountered:
_____________________________________
_____________________________________
_____________________________________

### Resolutions:
_____________________________________
_____________________________________
_____________________________________

### Follow-up Items:
_____________________________________
_____________________________________
_____________________________________

---

**Deployment Complete:** ⏰ _______________
**Total Duration:** _______________
**Status:** ⬜ SUCCESS / ⬜ PARTIAL / ⬜ ROLLED BACK