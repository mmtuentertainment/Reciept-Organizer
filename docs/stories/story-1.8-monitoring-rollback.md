# Story 1.8: Monitoring and Rollback Plan

## Story Overview
**ID**: STORY-1.8
**Epic**: Phase 2 - Authentication & User Management
**Priority**: P0 - Critical (Safety net)
**Risk Level**: Low (Risk mitigation story)
**Estimated Points**: 3

**As a** system administrator,
**I want** comprehensive monitoring and rollback capability,
**so that** I can respond quickly to any authentication issues.

## Business Value
- Ensures system stability during rollout
- Enables quick response to issues
- Provides visibility into auth performance
- Minimizes user impact from problems
- Supports data-driven decisions

## Acceptance Criteria

### 1. Auth Metrics Dashboard
- [ ] Create monitoring dashboard with MCP logs
- [ ] Track login success/failure rates
- [ ] Monitor token refresh performance
- [ ] Display active sessions count
- [ ] Show auth errors by type

### 2. Alert Thresholds
- [ ] Configure alerts for high failure rates (>10%)
- [ ] Alert on auth service downtime
- [ ] Monitor database RLS violations
- [ ] Track abnormal session patterns
- [ ] Set up escalation procedures

### 3. Feature Flags
- [ ] Implement auth enable/disable flag
- [ ] Per-platform feature toggles
- [ ] Gradual rollout percentage controls
- [ ] User group targeting
- [ ] Real-time flag updates

### 4. Rollback Procedures
- [ ] Document database rollback steps
- [ ] Create auth bypass mechanism
- [ ] Test rollback in staging
- [ ] Prepare rollback automation scripts
- [ ] Define rollback decision criteria

### 5. Data Migration Reversal
- [ ] Backup before migration
- [ ] Create reverse migration scripts
- [ ] Test data restoration
- [ ] Verify no data loss
- [ ] Document recovery time objectives

### 6. User Communication
- [ ] Prepare incident templates
- [ ] Create status page updates
- [ ] Draft email notifications
- [ ] Prepare in-app messages
- [ ] Document support responses

## Technical Implementation

### Monitoring Dashboard Setup
```typescript
// scripts/monitoring/auth-dashboard.ts
import { mcp } from '../../lib/mcp-client';

export class AuthMonitor {
  async getMetrics() {
    // Get auth logs from last hour
    const logs = await mcp.supabase.getLogs({
      service: 'auth'
    });

    // Get security advisories
    const advisories = await mcp.supabase.getAdvisors({
      type: 'security'
    });

    // Query auth metrics
    const metrics = await mcp.supabase.executeSQL({
      query: `
        WITH auth_stats AS (
          SELECT
            date_trunc('hour', created_at) as hour,
            COUNT(*) FILTER (WHERE status = 'success') as success_count,
            COUNT(*) FILTER (WHERE status = 'failed') as failure_count,
            COUNT(*) as total_attempts,
            AVG(EXTRACT(EPOCH FROM (completed_at - created_at))) as avg_duration
          FROM auth.audit_log
          WHERE created_at > NOW() - INTERVAL '24 hours'
          GROUP BY hour
        )
        SELECT
          hour,
          success_count,
          failure_count,
          total_attempts,
          ROUND((success_count::numeric / NULLIF(total_attempts, 0) * 100), 2) as success_rate,
          ROUND(avg_duration::numeric, 3) as avg_duration_seconds
        FROM auth_stats
        ORDER BY hour DESC;
      `
    });

    // Get active sessions
    const sessions = await mcp.supabase.executeSQL({
      query: `
        SELECT
          COUNT(DISTINCT user_id) as unique_users,
          COUNT(*) as total_sessions,
          COUNT(*) FILTER (WHERE created_at > NOW() - INTERVAL '1 hour') as recent_sessions,
          COUNT(*) FILTER (WHERE last_activity < NOW() - INTERVAL '30 minutes') as inactive_sessions
        FROM auth.sessions
        WHERE expires_at > NOW();
      `
    });

    // Check for RLS violations
    const rlsViolations = await mcp.supabase.executeSQL({
      query: `
        SELECT
          COUNT(*) as violation_count,
          array_agg(DISTINCT error_message) as error_types
        FROM postgres_logs
        WHERE
          error_severity = 'ERROR'
          AND error_message LIKE '%row-level security%'
          AND timestamp > NOW() - INTERVAL '1 hour';
      `
    });

    return {
      logs,
      advisories,
      metrics: metrics.data,
      sessions: sessions.data,
      rlsViolations: rlsViolations.data
    };
  }

  async checkAlerts(metrics: any) {
    const alerts = [];

    // Check failure rate
    const latestHour = metrics[0];
    if (latestHour && latestHour.success_rate < 90) {
      alerts.push({
        level: 'critical',
        message: `High auth failure rate: ${100 - latestHour.success_rate}%`,
        action: 'Consider rollback if rate persists'
      });
    }

    // Check for RLS violations
    if (metrics.rlsViolations?.[0]?.violation_count > 0) {
      alerts.push({
        level: 'warning',
        message: `RLS violations detected: ${metrics.rlsViolations[0].violation_count}`,
        action: 'Review RLS policies immediately'
      });
    }

    // Check session anomalies
    const sessions = metrics.sessions[0];
    if (sessions?.inactive_sessions > sessions?.total_sessions * 0.5) {
      alerts.push({
        level: 'info',
        message: 'High number of inactive sessions',
        action: 'Consider session cleanup'
      });
    }

    return alerts;
  }
}
```

### Feature Flag Implementation
```typescript
// lib/feature-flags.ts
export class FeatureFlags {
  private static flags = new Map<string, any>();

  static async initialize() {
    // Load flags from Supabase
    const { data } = await supabase
      .from('feature_flags')
      .select('*')
      .eq('active', true);

    data?.forEach(flag => {
      this.flags.set(flag.name, flag.value);
    });

    // Subscribe to real-time updates
    supabase
      .channel('feature_flags')
      .on('postgres_changes', {
        event: '*',
        schema: 'public',
        table: 'feature_flags'
      }, (payload) => {
        if (payload.new.active) {
          this.flags.set(payload.new.name, payload.new.value);
        } else {
          this.flags.delete(payload.new.name);
        }
      })
      .subscribe();
  }

  static isEnabled(flag: string): boolean {
    return this.flags.get(flag) === true;
  }

  static getValue(flag: string): any {
    return this.flags.get(flag);
  }

  static async setFlag(flag: string, value: any) {
    await supabase
      .from('feature_flags')
      .upsert({
        name: flag,
        value,
        active: true,
        updated_at: new Date().toISOString()
      });
  }
}

// Usage in auth flow
if (FeatureFlags.isEnabled('auth_enabled')) {
  // Proceed with auth
} else {
  // Bypass auth, use anonymous mode
}

// Gradual rollout
const rolloutPercentage = FeatureFlags.getValue('auth_rollout_percentage') || 0;
const userHash = hashCode(userId) % 100;
if (userHash < rolloutPercentage) {
  // Enable auth for this user
}
```

### Rollback Scripts
```sql
-- rollback/001_disable_auth.sql
-- Execute via: mcp__supabase__apply_migration

-- Step 1: Disable RLS (immediate relief)
ALTER TABLE receipts DISABLE ROW LEVEL SECURITY;
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Step 2: Create bypass function
CREATE OR REPLACE FUNCTION auth.bypass_mode()
RETURNS uuid AS $$
BEGIN
  -- Return anonymous user ID for all requests
  RETURN '00000000-0000-0000-0000-000000000000'::uuid;
END;
$$ LANGUAGE plpgsql;

-- Step 3: Update RLS policies to use bypass
CREATE OR REPLACE FUNCTION auth.uid()
RETURNS uuid AS $$
BEGIN
  -- Check if bypass mode is enabled
  IF EXISTS (
    SELECT 1 FROM feature_flags
    WHERE name = 'auth_bypass' AND value = true
  ) THEN
    RETURN auth.bypass_mode();
  ELSE
    RETURN auth.jwt() ->> 'sub';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Step 4: Set bypass flag
INSERT INTO feature_flags (name, value, active)
VALUES ('auth_bypass', true, true)
ON CONFLICT (name) DO UPDATE SET value = true, active = true;
```

### Rollback Automation
```typescript
// scripts/rollback/auth-rollback.ts
export class AuthRollback {
  async execute(reason: string) {
    console.log(`Starting auth rollback: ${reason}`);

    // Step 1: Enable bypass mode
    await FeatureFlags.setFlag('auth_bypass', true);
    console.log('✓ Bypass mode enabled');

    // Step 2: Disable auth features
    await FeatureFlags.setFlag('auth_enabled', false);
    console.log('✓ Auth features disabled');

    // Step 3: Clear active sessions (optional)
    if (await this.confirmAction('Clear all active sessions?')) {
      await mcp.supabase.executeSQL({
        query: 'DELETE FROM auth.sessions WHERE expires_at > NOW()'
      });
      console.log('✓ Sessions cleared');
    }

    // Step 4: Notify users
    await this.notifyUsers({
      type: 'maintenance',
      message: 'Authentication temporarily disabled for maintenance',
      estimatedTime: '2 hours'
    });
    console.log('✓ Users notified');

    // Step 5: Log rollback
    await this.logRollback({
      timestamp: new Date().toISOString(),
      reason,
      executedBy: process.env.USER,
      actions: ['bypass_enabled', 'auth_disabled', 'users_notified']
    });
    console.log('✓ Rollback logged');

    console.log('Rollback complete. System in safe mode.');
  }

  async confirmAction(prompt: string): Promise<boolean> {
    // In production, this would require manual confirmation
    const readline = require('readline').createInterface({
      input: process.stdin,
      output: process.stdout
    });

    return new Promise(resolve => {
      readline.question(`${prompt} (y/n): `, answer => {
        readline.close();
        resolve(answer.toLowerCase() === 'y');
      });
    });
  }

  async notifyUsers(notification: any) {
    // Send in-app notification
    await supabase.from('notifications').insert({
      type: notification.type,
      message: notification.message,
      metadata: notification,
      created_at: new Date().toISOString()
    });

    // Update status page
    await fetch('https://status.receiptorganizer.com/api/incidents', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        title: 'Authentication Service Maintenance',
        status: 'in_progress',
        message: notification.message
      })
    });
  }

  async logRollback(details: any) {
    await supabase.from('rollback_log').insert(details);
  }
}
```

### User Communication Templates
```typescript
// templates/incident-communications.ts
export const templates = {
  authDown: {
    email: {
      subject: 'Temporary Authentication Service Interruption',
      body: `
Dear User,

We are currently experiencing issues with our authentication service.
You may have trouble logging in or accessing your account.

Current Status: Investigating
Estimated Resolution: {estimated_time}

In the meantime, you can still:
- Access receipts in offline mode
- Export your data if previously logged in

We apologize for any inconvenience.

Best regards,
Receipt Organizer Team
      `
    },
    inApp: {
      title: 'Authentication Service Issue',
      message: 'Login temporarily unavailable. Offline mode active.',
      severity: 'warning'
    }
  },

  rollbackComplete: {
    email: {
      subject: 'Service Restored - Action Required',
      body: `
Dear User,

Our authentication service has been restored. For security reasons,
you will need to log in again to access your account.

What happened: {incident_summary}
Resolution: {resolution_summary}

Thank you for your patience.

Best regards,
Receipt Organizer Team
      `
    }
  }
};
```

## Integration Verification

### IV1: Monitoring Doesn't Impact Performance
```typescript
test('Monitoring queries complete quickly', async () => {
  const start = Date.now();
  await authMonitor.getMetrics();
  const duration = Date.now() - start;

  expect(duration).toBeLessThan(1000); // < 1 second
});
```

### IV2: Rollback Preserves Data
```sql
-- Via mcp__supabase__execute_sql
-- Before rollback
SELECT COUNT(*) as before_count FROM receipts;

-- After rollback
SELECT COUNT(*) as after_count FROM receipts;
-- Counts should match
```

### IV3: Feature Flags Work
```typescript
test('Feature flags control auth flow', async () => {
  await FeatureFlags.setFlag('auth_enabled', false);

  const response = await fetch('/api/receipts');
  expect(response.status).toBe(200); // Should work without auth
});
```

## Definition of Done
- [ ] Monitoring dashboard created and accessible
- [ ] Alert thresholds configured and tested
- [ ] Feature flags implemented and working
- [ ] Rollback procedures documented and tested
- [ ] Data migration reversal verified
- [ ] User communication templates prepared
- [ ] Team trained on rollback procedures
- [ ] Runbook created for incidents

## Dependencies
- All auth stories (1.0-1.7) should be complete
- MCP Supabase tools available
- Access to monitoring infrastructure
- Status page configured

## Risks & Mitigation
| Risk | Impact | Mitigation |
|------|--------|------------|
| Rollback fails | Critical | Multiple rollback methods, manual override |
| Data loss during rollback | High | Comprehensive backups, test in staging |
| Users not notified | Medium | Multiple communication channels |

## Follow-up Stories
- Future: Automated rollback triggers
- Future: A/B testing framework
- Future: Advanced monitoring with ML

## Notes
- Run rollback drill monthly
- Keep rollback scripts version-controlled
- Monitor rollback execution time (target < 5 minutes)