# Test Procedures for Receipt Organizer

## Step 8: Complete Setup Testing

### ✅ Database Connection Test

```sql
-- Run in Supabase SQL Editor
SELECT COUNT(*) FROM public.receipts;
SELECT COUNT(*) FROM public.user_profiles;
SELECT COUNT(*) FROM public.export_batches;
```

**Expected**: All queries should return 0 or more without errors.

### ✅ Storage Buckets Test

1. Go to **Storage** in Supabase Dashboard
2. Verify these buckets exist:
   - `receipts`
   - `thumbnails`
   - `exports`
3. Try uploading a test image to `receipts` bucket
4. Verify RLS policies by checking permissions

### 🔄 Authentication Test

**Prerequisites**: Configure auth providers in Supabase Dashboard first

1. **Test Sign Up**:
   ```bash
   cd apps/mobile
   flutter run
   ```
   - Navigate to Sign Up screen
   - Create account with valid email
   - Check for confirmation email
   - Verify user appears in Supabase Dashboard

2. **Test Sign In**:
   - Use confirmed account credentials
   - Should navigate to home screen
   - User avatar should show in app bar

3. **Test Sign Out**:
   - Click user menu → Sign Out
   - Should return to login screen
   - Protected routes should redirect to login

4. **Test Offline Mode**:
   - Click "Skip for now" on login screen
   - App should work without authentication
   - Sync features will be disabled

### ✅ Real-time Sync Test

1. **Single Device Test**:
   - Sign in to the app
   - Check sync status indicator (cloud icon)
   - Should show "Connected to Cloud"

2. **Multi-Device Test**:
   - Run app on two devices/emulators
   - Sign in with same account on both
   - Check presence indicator shows both devices
   - Create receipt on one device
   - Should appear on other device within seconds

3. **Offline/Online Transition**:
   - Disable network on device
   - Sync indicator should show "Offline Mode"
   - Create/edit receipts
   - Re-enable network
   - Changes should sync automatically

### 🔄 API Integration Test

1. **Vercel API Health Check**:
   ```bash
   curl https://api-aft7gxurp-matthew-utts-projects-89452c41.vercel.app/api/health
   ```
   **Expected**: `{"status":"ok","timestamp":"..."}`

2. **CSV Validation Endpoint**:
   ```bash
   curl -X POST https://api-aft7gxurp-matthew-utts-projects-89452c41.vercel.app/api/validate/csv \
     -H "Content-Type: application/json" \
     -d '{"data":[{"merchant":"Test","date":"2024-01-01","total":10.99}]}'
   ```
   **Expected**: Validation result with format compatibility

3. **OAuth Status Check**:
   ```bash
   curl https://api-aft7gxurp-matthew-utts-projects-89452c41.vercel.app/api/oauth/quickbooks/status
   ```
   **Expected**: OAuth configuration status

### 📱 Flutter App Tests

Run all tests:
```bash
cd apps/mobile
flutter test
```

Run specific test suites:
```bash
# Auth tests
flutter test test/features/auth/

# Real-time sync tests
flutter test test/realtime_sync_test.dart

# Integration tests
flutter test integration_test/
```

### 🔍 Component Testing Checklist

#### Authentication Flow
- [ ] Sign up with new email
- [ ] Email confirmation works
- [ ] Sign in with confirmed account
- [ ] Password validation (min 6 chars, letters + numbers)
- [ ] Sign out functionality
- [ ] Offline mode access
- [ ] Auth state persistence
- [ ] Protected route guards

#### Real-time Features
- [ ] Sync status indicator shows connection
- [ ] Presence tracking shows active devices
- [ ] Receipt changes sync across devices
- [ ] Offline changes queue and sync
- [ ] Conflict resolution works
- [ ] Force sync functionality

#### Database Operations
- [ ] Create receipt
- [ ] Read receipts (with pagination)
- [ ] Update receipt
- [ ] Delete receipt (soft delete)
- [ ] RLS policies enforce user isolation
- [ ] Indexes improve query performance

#### Storage Operations
- [ ] Upload receipt image
- [ ] Generate thumbnail
- [ ] Download image
- [ ] Delete image
- [ ] Storage policies work correctly

### 📊 Performance Benchmarks

| Operation | Target | Actual |
|-----------|--------|--------|
| App startup | < 3s | TBD |
| Auth sign in | < 2s | TBD |
| Receipt sync | < 1s | TBD |
| Image upload | < 5s | TBD |
| OCR processing | < 5s | TBD |
| CSV export | < 3s | TBD |

### 🐛 Known Issues

1. **Email Confirmation**: 
   - May go to spam folder
   - Workaround: Check spam or manually confirm in dashboard

2. **Real-time Sync**:
   - Initial connection may take 2-3 seconds
   - Workaround: Show loading state during connection

3. **OAuth Redirect**:
   - Deep linking not configured for mobile
   - Workaround: Use email auth for now

### ✅ Test Completion Criteria

The setup is considered complete when:

1. **Authentication**: All auth flows work (sign up, sign in, sign out)
2. **Database**: CRUD operations succeed with RLS
3. **Storage**: File upload/download works
4. **Real-time**: Changes sync across devices
5. **API**: All endpoints return expected responses
6. **Offline**: App functions without network
7. **Performance**: All operations within target times

### 📝 Test Report Template

```markdown
## Test Report - [Date]

### Environment
- Flutter Version: 3.24.3
- Supabase Project: yxpkogyljbvbkipiephe
- API URL: https://api-aft7gxurp...
- Device: [Device/Emulator details]

### Test Results
| Test Case | Status | Notes |
|-----------|--------|-------|
| Sign Up | ✅/❌ | |
| Sign In | ✅/❌ | |
| Real-time Sync | ✅/❌ | |
| ... | | |

### Issues Found
1. [Issue description]
   - Steps to reproduce
   - Expected vs Actual
   - Workaround (if any)

### Recommendations
- [Action items]
```

## Next Steps

After completing all tests:

1. **Document any issues** found during testing
2. **Update configuration** based on test results
3. **Optimize performance** where needed
4. **Prepare for production** deployment
5. **Set up monitoring** (Step 10)