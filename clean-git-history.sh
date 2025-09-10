#!/bin/bash

# Git History Cleanup Script
# This script removes exposed secrets from git history
# IMPORTANT: This will rewrite history - coordinate with team before running

set -e

echo "⚠️  WARNING: This script will rewrite git history!"
echo "This should only be run after:"
echo "1. All credentials have been rotated"
echo "2. Team has been notified"
echo "3. A backup has been created"
echo ""
read -p "Have you completed all prerequisites? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted. Complete prerequisites first."
    exit 1
fi

# Create backup
echo "📦 Creating backup of .git directory..."
cp -r .git .git.backup.$(date +%Y%m%d_%H%M%S)

# Option 1: Using git filter-branch (built-in)
cleanup_with_filter_branch() {
    echo "🔧 Using git filter-branch to remove secrets..."
    
    # Remove the file containing secrets from all history
    git filter-branch --force --index-filter \
        "git rm --cached --ignore-unmatch apps/api/DEPLOYMENT.md" \
        --prune-empty --tag-name-filter cat -- --all
    
    # Clean up refs
    git for-each-ref --format="delete %(refname)" refs/original | git update-ref --stdin
    git reflog expire --expire=now --all
    git gc --prune=now --aggressive
    
    echo "✅ History cleaned with filter-branch"
}

# Option 2: Using BFG Repo Cleaner (if available)
cleanup_with_bfg() {
    echo "🔧 Using BFG Repo Cleaner..."
    
    # Check if BFG is available
    if ! command -v bfg &> /dev/null && [ ! -f "bfg.jar" ]; then
        echo "📥 Downloading BFG Repo Cleaner..."
        wget https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar -O bfg.jar
    fi
    
    # Create file with secrets to remove
    cat > secrets-to-remove.txt << 'EOF'
IZD9kUK4lpRMnzIW3vQZXLE85TJkqtvJZVfoNQib
AS1lAAIncDE2ZjE1N2JlNzkxYWQ0Y2ViODQ5MjU3ZmQ3N2VmMjViM3AxMTE2MjE
Ai1lAAIgcDHbgDmJm85yRFfMfwb3y9YnWszlW8J02MUJ67CzY4Kr1Q
MJOyqf/tBV6d8DQQELZpXscd1vEasvZ/NDMes2cTEUQ=
ABHeXjfhxPZWmMVLLKNFQ5BkThuwSmT8SeRkx1bJsX3Zcn5djW
F7E48B5BA8CC43F9AA035C7803EB1504
EOF
    
    # Run BFG
    if [ -f "bfg.jar" ]; then
        java -jar bfg.jar --replace-text secrets-to-remove.txt
    else
        bfg --replace-text secrets-to-remove.txt
    fi
    
    # Clean up
    rm secrets-to-remove.txt
    git reflog expire --expire=now --all && git gc --prune=now --aggressive
    
    echo "✅ History cleaned with BFG"
}

# Choose cleanup method
echo ""
echo "Select cleanup method:"
echo "1. git filter-branch (built-in, slower)"
echo "2. BFG Repo Cleaner (faster, requires Java)"
read -p "Enter choice (1 or 2): " method

case $method in
    1)
        cleanup_with_filter_branch
        ;;
    2)
        cleanup_with_bfg
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "⚠️  IMPORTANT NEXT STEPS:"
echo "1. Review the changes with: git log --oneline -20"
echo "2. Test that the repository still works correctly"
echo "3. Force push to remote: git push origin --force --all"
echo "4. Force push tags: git push origin --force --tags"
echo "5. Notify team members to re-clone the repository"
echo ""
echo "🔒 Security Reminders:"
echo "- Ensure all credentials have been rotated"
echo "- Check that no forks contain the old history"
echo "- Monitor for any unauthorized access"
echo ""
echo "Backup saved to: .git.backup.*"