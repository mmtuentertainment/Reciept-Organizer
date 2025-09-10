# 🔐 Emergency Credential Rotation Guide

## 🚨 IMMEDIATE ACTIONS REQUIRED

If credentials have been exposed in git history or elsewhere, follow these steps IMMEDIATELY:

## Step 1: Generate New Credentials (15 minutes)

### 1.1 QuickBooks Credentials
1. Go to https://developer.intuit.com/app/developer/dashboard
2. Select your app
3. Click "Keys & credentials"
4. Generate new Client Secret
5. Copy the new secret (you won't see it again)
6. **DO NOT** paste it anywhere except Vercel Dashboard

### 1.2 Xero Credentials  
1. Go to https://developer.xero.com/myapps
2. Select your app
3. Generate new client secret if compromised
4. Copy the new secret immediately

### 1.3 Upstash Redis Tokens
1. Go to https://console.upstash.com
2. Select your database
3. Go to "REST API" tab
4. Click "Reset Token" for both tokens
5. Copy new tokens:
   - REST API Token (full access)
   - Read Only Token

### 1.4 JWT Secret
Generate a new secure secret:
```bash
openssl rand -base64 32
```
Copy this value for Vercel.

## Step 2: Update Vercel Environment Variables (5 minutes)

1. Go to https://vercel.com/dashboard
2. Select your project
3. Go to Settings → Environment Variables
4. Update each variable:
   - `QB_CLIENT_SECRET` → New QuickBooks secret
   - `KV_REST_API_TOKEN` → New Upstash token
   - `KV_REST_API_READ_ONLY_TOKEN` → New read-only token
   - `JWT_SECRET` → New JWT secret
5. Click "Save" for each

## Step 3: Redeploy Application (5 minutes)

```bash
cd /home/matt/FINAPP/Receipt\ Organizer/apps/api
vercel --prod
```

This ensures new credentials are active.

## Step 4: Verify Everything Works (5 minutes)

Test all OAuth flows:
```bash
# Test QuickBooks OAuth
curl https://receipt-organizer-api.vercel.app/api/auth/quickbooks

# Test Xero OAuth
curl https://receipt-organizer-api.vercel.app/api/auth/xero
```

## Step 5: Clean Git History (If Needed)

### Option A: Remove Sensitive File from History
```bash
# Create backup first
cp -r .git .git.backup

# Remove file from all history
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch apps/api/DEPLOYMENT.md" \
  --prune-empty --tag-name-filter cat -- --all

# Clean up
git for-each-ref --format="delete %(refname)" refs/original | git update-ref --stdin
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push (WARNING: This rewrites history)
git push origin --force --all
git push origin --force --tags
```

### Option B: BFG Repo Cleaner (Easier)
```bash
# Download BFG
wget https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar

# Create file with secrets to remove
echo 'IZD9kUK4lpRMnzIW3vQZXLE85TJkqtvJZVfoNQib' > passwords.txt
echo 'AS1lAAIncDE2ZjE1N2JlNzkxYWQ0Y2ViODQ5MjU3ZmQ3N2VmMjViM3AxMTE2MjE' >> passwords.txt
echo 'MJOyqf/tBV6d8DQQELZpXscd1vEasvZ/NDMes2cTEUQ=' >> passwords.txt

# Run BFG
java -jar bfg-1.14.0.jar --replace-text passwords.txt

# Clean and push
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push origin --force --all
```

## Step 6: Monitor for Unauthorized Access

### Check Upstash Logs
1. Go to https://console.upstash.com
2. Check "Logs" tab for unusual activity
3. Look for IPs you don't recognize

### Check QuickBooks Activity
1. Go to developer dashboard
2. Check API call logs
3. Look for unexpected API calls

### Check Xero Activity  
1. Go to developer portal
2. Review API metrics
3. Check for unusual patterns

## 🛡️ Prevention Measures

### 1. Install git-secrets
```bash
# Install git-secrets
brew install git-secrets  # macOS
# or
git clone https://github.com/awslabs/git-secrets.git
cd git-secrets && make install

# Configure for your repo
cd /home/matt/FINAPP/Receipt\ Organizer
git secrets --install
git secrets --register-aws  # Adds common patterns

# Add custom patterns
git secrets --add 'QB_CLIENT_SECRET=\S+'
git secrets --add 'KV_REST_API_TOKEN=\S+'
git secrets --add 'JWT_SECRET=\S+'
```

### 2. Pre-commit Hook
Create `.git/hooks/pre-commit`:
```bash
#!/bin/bash
# Check for secrets before commit
git secrets --pre_commit_hook -- "$@"

# Check for console.log with sensitive data
if git diff --cached --name-only | xargs grep -E "console\.(log|error).*token|secret|password" 2>/dev/null; then
    echo "ERROR: Remove console.log statements with sensitive data"
    exit 1
fi
```

### 3. Use .env.example
Always commit an example file with placeholders:
```bash
# .env.example
QB_CLIENT_SECRET=your_quickbooks_client_secret_here
KV_REST_API_TOKEN=your_upstash_token_here
JWT_SECRET=generate_with_openssl_rand_base64_32
```

## 📋 Rotation Schedule

### Every 90 Days
- Rotate JWT secret
- Rotate API tokens

### Every 6 Months
- Rotate OAuth client secrets
- Review access logs

### Immediately When
- Employee leaves company
- Credentials exposed
- Suspicious activity detected
- Security breach suspected

## 🔍 Security Checklist

- [ ] All exposed credentials rotated
- [ ] Vercel environment variables updated
- [ ] Application redeployed
- [ ] OAuth flows tested
- [ ] Git history cleaned (if needed)
- [ ] git-secrets installed
- [ ] Pre-commit hooks added
- [ ] Team notified of rotation
- [ ] Incident documented

## 📞 Emergency Contacts

- **Upstash Support**: https://upstash.com/support
- **QuickBooks Developer Support**: https://developer.intuit.com/support
- **Xero Developer Support**: https://developer.xero.com/documentation/api-guides/oauth2/support
- **Vercel Support**: https://vercel.com/support

---
Remember: **NEVER** paste real credentials in any file that gets committed to git, even temporarily.