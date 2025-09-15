# Testing Strategy

### Auth Testing Matrix

| Test Category | Flutter | Next.js | React Native | MCP Tools |
|--------------|---------|---------|--------------|-----------|
| Unit Tests | ✓ Mock Supabase | ✓ Mock fetch | ✓ Mock SecureStore | - |
| Integration | ✓ Test DB | ✓ Test DB | ✓ Test DB | executeSql |
| E2E | ✓ Chrome | ✓ Playwright | ✓ Detox | - |
| Load Testing | - | ✓ k6 | - | getLogs |
| Security | ✓ Token validation | ✓ CSRF | ✓ Keychain | getAdvisors |

### Test User Management

```sql
-- Create test users with MCP
INSERT INTO auth.users (id, email, email_confirmed_at)
VALUES
  ('test-user-1', 'test1@example.com', NOW()),
  ('test-user-2', 'test2@example.com', NOW());

-- Create test profiles
INSERT INTO profiles (id, username, full_name)
VALUES
  ('test-user-1', 'testuser1', 'Test User One'),
  ('test-user-2', 'testuser2', 'Test User Two');

-- Grant test permissions
INSERT INTO user_roles (user_id, role)
VALUES
  ('test-user-1', 'tester'),
  ('test-user-2', 'tester');
```
