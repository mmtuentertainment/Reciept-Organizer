# 🛡️ Security & Large File Prevention Guide

## Prevention Measures Implemented

### 1. ✅ **Pre-commit Hook**
Location: `.git/hooks/pre-commit`
- Blocks files larger than 50MB
- Scans for common secret patterns
- Prevents committing archive files (tar.xz, zip, etc.)
- Runs automatically before every commit

### 2. ✅ **Enhanced .gitignore**
- Ignores all tar.xz, tar.gz, zip files
- Ignores Flutter download files
- Ignores binary executables
- Ignores database files

### 3. ✅ **Git Attributes for LFS**
Location: `.gitattributes`
- Configured for Git LFS (if you choose to use it)
- Tracks large files separately from main repo

## Common Issues & Solutions

### Problem: "File exceeds GitHub's file size limit"
**Prevention:**
- Pre-commit hook blocks files > 50MB
- .gitignore prevents common large files

**If it happens:**
```bash
# Remove from current commit
git rm --cached path/to/large/file
git commit --amend

# Or use BFG to clean history
java -jar bfg.jar --strip-blobs-bigger-than 50M
git reflog expire --expire=now --all && git gc --prune=now --aggressive
```

### Problem: "Secrets in code"
**Prevention:**
- Pre-commit hook scans for patterns like CLIENT_SECRET=
- Always use environment variables

**Best Practices:**
```bash
# Bad (will be blocked)
const API_KEY = "sk-1234567890abcdef"

# Good
const API_KEY = process.env.API_KEY
```

### Problem: "Flutter downloads committed"
**Prevention:**
- .gitignore blocks flutter_*.tar.xz files
- apps/mobile/tmp/ is ignored

**Best Practice:**
- Never commit SDK downloads
- Document installation steps instead

## Security Checklist

### Before Every Commit
- [ ] No files > 50MB (hook will block)
- [ ] No hardcoded secrets (hook will scan)
- [ ] No binary/archive files
- [ ] Sensitive files in .gitignore

### When Adding Dependencies
- [ ] Check package.json size
- [ ] No vendored dependencies
- [ ] Use package managers (npm, pub)

### For CI/CD
- [ ] Secrets in GitHub Secrets
- [ ] Environment variables in Vercel
- [ ] No .env files in repo

## Quick Commands

### Check file sizes before commit
```bash
git ls-files | xargs -I {} sh -c 'ls -lh "{}" 2>/dev/null' | awk '$5 ~ /M$/ && $5+0 > 50'
```

### Find secrets in staged files
```bash
git diff --cached --name-only | xargs grep -E "(SECRET|TOKEN|KEY|PASSWORD)=" 2>/dev/null
```

### Clean up if large file committed
```bash
# Option 1: Remove from last commit
git reset HEAD~1
git add . --all
git status  # Check large file is gone
git commit

# Option 2: Clean entire history
java -jar bfg.jar --strip-blobs-bigger-than 50M
```

## Emergency Contacts

If you accidentally commit secrets:
1. **Rotate immediately** - See CREDENTIAL_ROTATION_GUIDE.md
2. **Clean history** - Use clean-git-history.sh
3. **Force push** - git push --force --all

## Tools Installed

1. **Pre-commit hook** - Automatic checking
2. **BFG Repo Cleaner** - bfg.jar for cleanup
3. **Git attributes** - For LFS support
4. **Clean script** - clean-git-history.sh

## Never Commit These

### Files
- *.tar.xz, *.tar.gz, *.zip
- *.exe, *.dmg, *.deb, *.rpm
- *.mp4, *.mov, *.avi
- *.sql, *.db, *.sqlite
- .env, .env.*

### Patterns
- Hardcoded secrets
- API keys in code
- Database credentials
- JWT secrets
- Private keys

---

**Remember**: Prevention is better than cleanup. The pre-commit hook will catch most issues automatically!