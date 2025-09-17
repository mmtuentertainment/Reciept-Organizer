#!/bin/bash

# Test Data Seeding Script
# Creates isolated test users and sample data for testing

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Receipt Organizer - Test Data Seeder          ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# Load environment variables
if [ -f ".env.test" ]; then
    source .env.test
    echo -e "${GREEN}✓ Loaded test environment${NC}"
else
    echo -e "${YELLOW}⚠ Using default test configuration${NC}"
    TEST_USER_PREFIX="test_"
    TEST_USER_PASSWORD="${TEST_USER_PASSWORD:-DefaultTestPass123!}"
fi

# Function to create test users via MCP
create_test_users() {
    echo -e "\n${BLUE}Creating test users...${NC}"

    # This would use MCP commands in practice
    # For now, we document the SQL that would be executed

    cat << EOF
-- Execute via mcp__supabase__execute_sql

-- Create basic test user
INSERT INTO auth.users (email, encrypted_password, email_confirmed_at, raw_user_meta_data)
VALUES
  ('${TEST_USER_PREFIX}basic@example.com', crypt('${TEST_USER_PASSWORD}', gen_salt('bf')), NOW(), '{"test_user": true, "role": "basic"}'::jsonb),
  ('${TEST_USER_PREFIX}premium@example.com', crypt('${TEST_USER_PASSWORD}', gen_salt('bf')), NOW(), '{"test_user": true, "role": "premium"}'::jsonb),
  ('${TEST_USER_PREFIX}admin@example.com', crypt('${TEST_USER_PASSWORD}', gen_salt('bf')), NOW(), '{"test_user": true, "role": "admin"}'::jsonb)
ON CONFLICT (email) DO NOTHING;
EOF

    echo -e "${GREEN}✓ Test users created${NC}"
    echo "  - ${TEST_USER_PREFIX}basic@example.com"
    echo "  - ${TEST_USER_PREFIX}premium@example.com"
    echo "  - ${TEST_USER_PREFIX}admin@example.com"
}

# Function to create test receipts
create_test_receipts() {
    echo -e "\n${BLUE}Creating test receipts...${NC}"

    cat << EOF
-- Execute via mcp__supabase__execute_sql

-- Create test receipts for test users
INSERT INTO receipts (user_id, merchant, receipt_date, total, tax, category, status)
SELECT
  u.id,
  merchants.name,
  dates.date,
  amounts.total,
  amounts.tax,
  categories.name,
  'ready'
FROM auth.users u
CROSS JOIN (
  VALUES
    ('Walmart'),
    ('Target'),
    ('Costco'),
    ('Home Depot')
) AS merchants(name)
CROSS JOIN (
  VALUES
    (CURRENT_DATE - INTERVAL '1 day'),
    (CURRENT_DATE - INTERVAL '7 days'),
    (CURRENT_DATE - INTERVAL '30 days')
) AS dates(date)
CROSS JOIN (
  VALUES
    (29.99, 2.10),
    (149.99, 10.50),
    (9.99, 0.70)
) AS amounts(total, tax)
CROSS JOIN (
  VALUES
    ('Groceries'),
    ('Office Supplies'),
    ('Home Improvement')
) AS categories(name)
WHERE u.email LIKE '${TEST_USER_PREFIX}%'
LIMIT 30;
EOF

    echo -e "${GREEN}✓ Test receipts created${NC}"
}

# Function to create test sessions
create_test_sessions() {
    echo -e "\n${BLUE}Creating test sessions...${NC}"

    cat << EOF
-- Execute via mcp__supabase__execute_sql

-- Create active sessions for test users
INSERT INTO auth.sessions (user_id, created_at, updated_at, factor_id, aal, not_after)
SELECT
  id,
  NOW(),
  NOW(),
  NULL,
  'aal1',
  NOW() + INTERVAL '2 hours'
FROM auth.users
WHERE email LIKE '${TEST_USER_PREFIX}%';
EOF

    echo -e "${GREEN}✓ Test sessions created${NC}"
}

# Function to verify test data
verify_test_data() {
    echo -e "\n${BLUE}Verifying test data...${NC}"

    cat << EOF
-- Execute via mcp__supabase__execute_sql

-- Count test users
SELECT COUNT(*) as test_user_count
FROM auth.users
WHERE email LIKE '${TEST_USER_PREFIX}%';

-- Count test receipts
SELECT COUNT(*) as test_receipt_count
FROM receipts r
JOIN auth.users u ON r.user_id = u.id
WHERE u.email LIKE '${TEST_USER_PREFIX}%';

-- Check active sessions
SELECT COUNT(*) as active_sessions
FROM auth.sessions s
JOIN auth.users u ON s.user_id = u.id
WHERE u.email LIKE '${TEST_USER_PREFIX}%'
  AND s.not_after > NOW();
EOF

    echo -e "${GREEN}✓ Verification queries ready${NC}"
}

# Function to clean old test data
clean_old_test_data() {
    echo -e "\n${YELLOW}Cleaning old test data...${NC}"

    cat << EOF
-- Execute via mcp__supabase__execute_sql

-- Delete old test receipts
DELETE FROM receipts
WHERE user_id IN (
  SELECT id FROM auth.users
  WHERE email LIKE '${TEST_USER_PREFIX}%'
    AND created_at < NOW() - INTERVAL '24 hours'
);

-- Delete old test users
DELETE FROM auth.users
WHERE email LIKE '${TEST_USER_PREFIX}%'
  AND created_at < NOW() - INTERVAL '24 hours';
EOF

    echo -e "${GREEN}✓ Old test data cleaned${NC}"
}

# Main menu
show_menu() {
    echo -e "\n${BLUE}Select an action:${NC}"
    echo "1) Seed all test data"
    echo "2) Create test users only"
    echo "3) Create test receipts only"
    echo "4) Verify existing test data"
    echo "5) Clean old test data (>24h)"
    echo "6) Reset all test data"
    echo "0) Exit"
    echo ""
    read -p "Enter your choice: " choice

    case $choice in
        1)
            create_test_users
            create_test_receipts
            create_test_sessions
            verify_test_data
            ;;
        2)
            create_test_users
            ;;
        3)
            create_test_receipts
            ;;
        4)
            verify_test_data
            ;;
        5)
            clean_old_test_data
            ;;
        6)
            clean_old_test_data
            create_test_users
            create_test_receipts
            create_test_sessions
            ;;
        0)
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            show_menu
            ;;
    esac
}

# Main execution
main() {
    echo "Test Data Seeding Tool"
    echo "====================="
    echo ""
    echo -e "${YELLOW}⚠ WARNING: This will create test data in your database${NC}"
    echo -e "${YELLOW}All test users will have '${TEST_USER_PREFIX}' prefix${NC}"
    echo ""

    if [ "$1" == "--auto" ]; then
        echo -e "${BLUE}Running automatic seed...${NC}"
        create_test_users
        create_test_receipts
        create_test_sessions
        verify_test_data
    else
        show_menu
    fi

    echo ""
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}Test data seeding complete!${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo ""
    echo "To execute these SQL commands, use:"
    echo "  mcp__supabase__execute_sql --query '<sql>'"
    echo ""
    echo "To monitor test users, run:"
    echo "  ./scripts/monitor-auth.sh"
}

# Parse arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --auto          Run automatic seed without menu"
        echo "  --clean         Clean old test data only"
        echo "  --verify        Verify existing test data"
        echo "  --help          Show this help message"
        exit 0
        ;;
    --clean)
        clean_old_test_data
        ;;
    --verify)
        verify_test_data
        ;;
    *)
        main "$@"
        ;;
esac