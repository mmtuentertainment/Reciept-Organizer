# GitHub Secrets Setup Guide

## Required Secrets for CI/CD Workflows

This guide explains how to set up the required secrets for the Receipt Organizer GitHub Actions workflows.

## 🔑 Required Secrets

### 1. **SNYK_TOKEN**
For vulnerability scanning in dependencies

**Setup Steps:**
1. Go to [Snyk.io](https://snyk.io) and sign up for a free account
2. Connect your GitHub account
3. Navigate to **Account Settings** → **Service Accounts** or **Auth Tokens**
4. Click **Generate Token**
5. Copy the token value
6. Add to GitHub repository (see instructions below)

### 2. **CODECOV_TOKEN**
For code coverage reporting

**Setup Steps:**
1. Go to [Codecov.io](https://codecov.io) and sign up with GitHub
2. Add your repository: **Add a repository** → Select `mmtuentertainment/Receipt-Organizer`
3. Once added, you'll see a **Upload Token** in the repository settings
4. Copy the token value
5. Add to GitHub repository (see instructions below)

## 📝 Adding Secrets to GitHub Repository

### Method 1: Via GitHub Web Interface (Recommended)

1. Go to your repository: https://github.com/mmtuentertainment/Receipt-Organizer
2. Click on **Settings** tab
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Add each secret:
   - **Name**: `SNYK_TOKEN`
   - **Value**: (paste your Snyk token)
   - Click **Add secret**
6. Repeat for `CODECOV_TOKEN`

### Method 2: Via GitHub CLI

If you have GitHub CLI installed:

```bash
# Set Snyk token
gh secret set SNYK_TOKEN

# Set Codecov token
gh secret set CODECOV_TOKEN
```

When prompted, paste the token value and press Ctrl+D (Linux/Mac) or Ctrl+Z (Windows).

## 🔒 Security Best Practices

1. **Never commit secrets** to your repository
2. **Rotate tokens regularly** (every 90 days recommended)
3. **Use least privilege** - only grant necessary permissions
4. **Monitor usage** through Snyk and Codecov dashboards

## ✅ Verification

After adding secrets, you can verify they're working by:

1. **Triggering a workflow run**:
   ```bash
   git push origin main
   ```

2. **Check workflow logs**:
   - Go to **Actions** tab in GitHub
   - Click on the latest workflow run
   - Look for successful completion of:
     - `Security Scan` → `Dependency Vulnerability Check`
     - `Flutter CI` → `Upload coverage to Codecov`

## 🚀 Optional Additional Secrets

### For deployment services (if needed):
- Firebase token - For hosting/functions deployment
- App Store Connect API key - iOS App Store deployment
- Google Play service account - Android Play Store deployment

### For Supabase (if using environment-specific):
- Production URL - Production Supabase URL
- Production anon key - Production Supabase anon key
- Production service key - Production Supabase service key (admin)

## 📊 Free Tier Limits

### Snyk Free Tier:
- 200 tests/month
- Unlimited open source projects
- Basic vulnerability detection

### Codecov Free Tier:
- Unlimited public repositories
- 5 private repository users
- Basic coverage reporting

## 🔄 Token Rotation

Set calendar reminders to rotate tokens every 90 days:

1. Generate new token from service
2. Update in GitHub Secrets
3. Delete old token from service
4. Verify workflows still pass

## 🆘 Troubleshooting

### Workflow fails with "Bad credentials"
- Verify secret name matches exactly (case-sensitive)
- Regenerate and update the token
- Check token hasn't expired

### Codecov not showing reports
- Ensure `flutter test --coverage` is generating `lcov.info`
- Check Codecov dashboard for repository setup
- Verify token is for the correct repository

### Snyk not finding vulnerabilities
- Check Snyk dashboard to ensure project is imported
- Verify `pubspec.lock` file exists
- Run `flutter pub get` to ensure dependencies are resolved

---

*Last updated: 2025-01-16*
*For issues, check the [GitHub Actions documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)*