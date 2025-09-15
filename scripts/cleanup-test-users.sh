#!/bin/bash

# Test User Cleanup Script
# Safely removes test users and their data from the database

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Receipt Organizer - Test User Cleanup         ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# Configuration
TEST_USER_PREFIX="${TEST_USER_PREFIX:-test_}"
DRY_RUN=false
FORCE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --prefix)
            TEST_USER_PREFIX="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --dry-run       Show what would be deleted without executing"
            echo "  --force         Skip confirmation prompt"
            echo "  --prefix PREFIX Use custom test user prefix (default: test_)"
            echo "  --help          Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Function to count test users
count_test_users() {
    echo -e "${BLUE}Counting test users...${NC}"

    cat << EOF
-- Execute via mcp__supabase__execute_sql
SELECT
  COUNT(*) as total_test_users,
  COUNT(CASE WHEN created_at < NOW() - INTERVAL '24 hours' THEN 1 END) as old_test_users,
  COUNT(CASE WHEN created_at >= NOW() - INTERVAL '24 hours' THEN 1 END) as recent_test_users
FROM auth.users
WHERE email LIKE '${TEST_USER_PREFIX}%'
  OR raw_user_meta_data->>'test_user' = 'true';
EOF
}

# Function to list test users
list_test_users() {
    echo -e "\n${BLUE}Test users to be deleted:${NC}"

    cat << EOF
-- Execute via mcp__supabase__execute_sql
SELECT
  id,
  email,
  created_at,
  last_sign_in_at,
  raw_user_meta_data->>'role' as test_role
FROM auth.users
WHERE email LIKE '${TEST_USER_PREFIX}%'
  OR raw_user_meta_data->>'test_user' = 'true'
ORDER BY created_at DESC
LIMIT 20;
EOF
}

# Function to delete test receipts
delete_test_receipts() {
    echo -e "\n${YELLOW}Deleting test receipts...${NC}"

    local sql="
-- Delete receipts for test users
DELETE FROM receipts
WHERE user_id IN (
  SELECT id FROM auth.users
  WHERE email LIKE '${TEST_USER_PREFIX}%'
    OR raw_user_meta_data->>'test_user' = 'true'
);"

    if [ "$DRY_RUN" = true ]; then
        echo -e "${BLUE}[DRY RUN] Would execute:${NC}"
        echo "$sql"
    else
        echo "$sql"
        echo -e "${GREEN}✓ Test receipts deleted${NC}"
    fi
}

# Function to delete test sessions
delete_test_sessions() {
    echo -e "\n${YELLOW}Deleting test sessions...${NC}"

    local sql="
-- Delete sessions for test users
DELETE FROM auth.sessions
WHERE user_id IN (
  SELECT id FROM auth.users
  WHERE email LIKE '${TEST_USER_PREFIX}%'
    OR raw_user_meta_data->>'test_user' = 'true'
);"

    if [ "$DRY_RUN" = true ]; then
        echo -e "${BLUE}[DRY RUN] Would execute:${NC}"
        echo "$sql"
    else
        echo "$sql"
        echo -e "${GREEN}✓ Test sessions deleted${NC}"
    fi
}

# Function to delete test users
delete_test_users() {
    echo -e "\n${YELLOW}Deleting test users...${NC}"

    local sql="
-- Delete test users
DELETE FROM auth.users
WHERE email LIKE '${TEST_USER_PREFIX}%'
  OR raw_user_meta_data->>'test_user' = 'true';"

    if [ "$DRY_RUN" = true ]; then
        echo -e "${BLUE}[DRY RUN] Would execute:${NC}"
        echo "$sql"
    else
        echo "$sql"
        echo -e "${GREEN}✓ Test users deleted${NC}"
    fi
}

# Function to verify cleanup
verify_cleanup() {
    echo -e "\n${BLUE}Verifying cleanup...${NC}"

    cat << EOF
-- Execute via mcp__supabase__execute_sql

-- Check remaining test users
SELECT COUNT(*) as remaining_test_users
FROM auth.users
WHERE email LIKE '${TEST_USER_PREFIX}%'
  OR raw_user_meta_data->>'test_user' = 'true';

-- Check remaining test receipts
SELECT COUNT(*) as remaining_test_receipts
FROM receipts r
WHERE EXISTS (
  SELECT 1 FROM auth.users u
  WHERE u.id = r.user_id
    AND (u.email LIKE '${TEST_USER_PREFIX}%'
         OR u.raw_user_meta_data->>'test_user' = 'true')
);
EOF

    echo -e "${GREEN}✓ Cleanup verification complete${NC}"
}

# Main cleanup function
perform_cleanup() {
    # Count users first
    count_test_users

    # List users to be deleted
    list_test_users

    # Confirmation prompt (unless forced)
    if [ "$FORCE" = false ] && [ "$DRY_RUN" = false ]; then
        echo ""
        echo -e "${YELLOW}⚠ WARNING: This will permanently delete test data!${NC}"
        read -p "Are you sure you want to continue? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Cleanup cancelled${NC}"
            exit 0
        fi
    fi

    # Perform cleanup in order
    delete_test_receipts
    delete_test_sessions
    delete_test_users

    # Verify cleanup
    verify_cleanup
}

# Main execution
main() {
    echo "Test User Cleanup Tool"
    echo "====================="
    echo ""
    echo "Configuration:"
    echo "  Prefix: ${TEST_USER_PREFIX}"
    echo "  Dry Run: ${DRY_RUN}"
    echo "  Force: ${FORCE}"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        echo -e "${BLUE}Running in DRY RUN mode - no changes will be made${NC}"
    fi

    perform_cleanup

    echo ""
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    if [ "$DRY_RUN" = true ]; then
        echo -e "${BLUE}Dry run complete - no changes made${NC}"
        echo -e "${BLUE}Remove --dry-run flag to execute cleanup${NC}"
    else
        echo -e "${GREEN}Cleanup complete!${NC}"
    fi
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo ""
    echo "To execute these SQL commands, use:"
    echo "  mcp__supabase__execute_sql --query '<sql>'"
}

# Run main function
main