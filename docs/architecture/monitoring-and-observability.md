# Monitoring and Observability

### Key Metrics to Track

```typescript
interface AuthMetrics {
  // Performance
  loginDuration: Histogram;        // Time to complete login
  tokenRefreshDuration: Histogram; // Time to refresh token
  sessionCheckDuration: Histogram; // Time to validate session

  // Reliability
  loginSuccessRate: Gauge;         // % successful logins
  tokenRefreshFailures: Counter;   // Failed refresh attempts
  authErrors: Counter;              // Auth errors by type

  // Usage
  activeUsers: Gauge;               // Currently authenticated users
  loginAttempts: Counter;           // Login attempts by method
  logoutEvents: Counter;            // Logout events by trigger

  // Security
  failedLogins: Counter;            // Failed login attempts
  suspiciousActivity: Counter;     // Unusual patterns detected
  tokenExpirations: Counter;        // Expired tokens
}

// MCP monitoring integration
async function collectAuthMetrics(): Promise<AuthMetrics> {
  const logs = await mcp.supabase.getLogs({ service: 'auth' });
  const metrics = processLogs(logs);

  // Check for issues
  const advisors = await mcp.supabase.getAdvisors({ type: 'security' });
  metrics.securityIssues = advisors.filter(a => a.category === 'auth');

  return metrics;
}
```
