# 🚨 URGENT SECURITY ACTION REQUIRED

## Exposed API Keys in Git History

### 1. Google Vision API Key - COMPROMISED
**Key:** `[REDACTED_GOOGLE_API_KEY]`
**Status:** EXPOSED in git history (4 commits)
**Found in commits:**
- 2d0e9ec9 - SECURITY: Remove exposed API keys from version control
- 76874095 - feat(auth): Implement Story 1.4 - React Native Authentication
- 9759c906 - security: Remove exposed API key and add proper .env.example
- daace9f4 - feat: Add React Native mobile app and web infrastructure

### 2. Additional Key Mentioned
**Key:** `AIzaSyDQgb9B-5eQojUtZwXutO6zOmRUQB_dgfY`
**Status:** NOT found in this repository (may be from another project or already regenerated)

### 3. Supabase Credentials
**Project:** `xbadaalqaeszooyxuoac`
**Anon Key:** Also in history but less critical (designed to be public with RLS)

## IMMEDIATE ACTIONS REQUIRED

### Step 1: Regenerate Google API Key NOW
1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Find the project with key `[REDACTED_GOOGLE_API_KEY]`
3. **DELETE** or **RESTRICT** this key immediately
4. Create a new API key
5. Add restrictions:
   - Application restrictions: HTTP referrers or IP addresses
   - API restrictions: Only Google Vision API

### Step 2: Update All Environments
1. Update local `.env.local` files with new key
2. Update CI/CD environment variables
3. Update any deployment environments (Vercel, etc.)

### Step 3: Clean Git History (Optional but Recommended)
Since this is a public repository, the key is permanently compromised even after removal.

Option A: Use BFG Repo-Cleaner
```bash
# Download BFG
wget https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar

# Remove the key from all commits
java -jar bfg-1.14.0.jar --replace-text passwords.txt Receipt-Organizer

# Where passwords.txt contains:
[REDACTED_GOOGLE_API_KEY]==>REDACTED
```

Option B: Filter-branch (more complex)
```bash
git filter-branch --force --index-filter \
"git rm --cached --ignore-unmatch apps/native/.env.local" \
--prune-empty --tag-name-filter cat -- --all
```

### Step 4: Force Push (DESTRUCTIVE)
⚠️ This will rewrite history for all collaborators
```bash
git push origin --force --all
git push origin --force --tags
```

## Prevention for Future

### Already Implemented:
✅ Removed all hardcoded credentials
✅ Added .env files to .gitignore
✅ Created .env.example files
✅ Added validation to fail if env vars missing
✅ Created SECURITY.md documentation

### Additional Recommendations:
1. Use git-secrets or similar pre-commit hooks
2. Regular security audits
3. Rotate API keys periodically
4. Use least-privilege principle for API keys
5. Consider using a secrets management service

## Security Checklist
- [ ] Google API key regenerated
- [ ] New key added to all environments
- [ ] Old key deleted/restricted in Google Console
- [ ] Git history cleaned (optional)
- [ ] Team notified of the incident
- [ ] Pre-commit hooks installed

## Timeline
- **NOW**: Regenerate API key
- **Within 1 hour**: Update all environments
- **Within 24 hours**: Clean git history if desired
- **Ongoing**: Monitor for unauthorized usage

---
**Remember:** The exposed key `[REDACTED_GOOGLE_API_KEY]` is permanently compromised. Even if removed from the repository, it's been in public git history. It MUST be regenerated.