# GitHub Repository Secrets Template

Copy and use these when setting up secrets in GitHub repository settings.

## Required Secrets

### SNYK_TOKEN
- **Purpose**: Vulnerability scanning for dependencies
- **Get from**: https://app.snyk.io/account
- **Format**: UUID string (e.g., `12345678-1234-1234-1234-123456789012`)
- **Required for**: `security.yml` workflow

### CODECOV_TOKEN
- **Purpose**: Code coverage reporting
- **Get from**: https://app.codecov.io/gh/mmtuentertainment/Receipt-Organizer/settings
- **Format**: UUID string (e.g., `abcdef12-3456-7890-abcd-ef1234567890`)
- **Required for**: `flutter-ci.yml` workflow

## How to Add via GitHub Web UI

1. Navigate to: https://github.com/mmtuentertainment/Receipt-Organizer/settings/secrets/actions
2. Click "New repository secret"
3. Add each secret with the exact name above
4. Paste the token value
5. Click "Add secret"

## How to Add via GitHub CLI

```bash
# Install GitHub CLI if needed
# brew install gh (macOS)
# sudo apt install gh (Ubuntu/Debian)

# Authenticate
gh auth login

# Add secrets
gh secret set SNYK_TOKEN
# (paste token and press Ctrl+D)

gh secret set CODECOV_TOKEN
# (paste token and press Ctrl+D)

# List secrets to verify
gh secret list
```

## Verify Secrets Are Working

After adding secrets, push any change to trigger workflows:

```bash
git commit --allow-empty -m "test: Trigger CI workflows"
git push origin main
```

Then check:
- https://github.com/mmtuentertainment/Receipt-Organizer/actions
- Look for green checkmarks on "Security Scan" and "Flutter CI" workflows

## 🔐 Security Notes

- These tokens are encrypted by GitHub
- Only visible to workflows running in your repository
- Never commit these values to code
- Rotate tokens every 90 days for security