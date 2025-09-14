#!/usr/bin/env node

/**
 * Authentication Monitoring Script
 * Uses MCP tools to monitor auth services and gather metrics
 */

import { createClient } from '@supabase/supabase-js';

// Environment configuration
const SUPABASE_URL = process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL || '';
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || '';

if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
  console.error('Missing Supabase configuration. Please set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

/**
 * Auth Monitoring Dashboard
 */
class AuthMonitor {
  /**
   * Get authentication metrics
   */
  async getAuthMetrics() {
    try {
      // Get auth statistics for the last 24 hours
      const { data: authStats, error: statsError } = await supabase.rpc('get_auth_stats', {
        hours: 24
      });

      if (statsError) {
        console.error('Error fetching auth stats:', statsError);
        return null;
      }

      // Get active sessions count
      const { count: sessionCount, error: sessionError } = await supabase
        .from('auth.sessions')
        .select('*', { count: 'exact', head: true })
        .gt('expires_at', new Date().toISOString());

      if (sessionError) {
        console.error('Error counting sessions:', sessionError);
      }

      // Get recent auth errors
      const { data: recentErrors, error: errorError } = await supabase
        .from('auth.audit_log')
        .select('*')
        .eq('status', 'error')
        .gte('created_at', new Date(Date.now() - 3600000).toISOString())
        .order('created_at', { ascending: false })
        .limit(10);

      if (errorError) {
        console.error('Error fetching auth errors:', errorError);
      }

      return {
        stats: authStats,
        activeSessions: sessionCount || 0,
        recentErrors: recentErrors || []
      };
    } catch (error) {
      console.error('Failed to get auth metrics:', error);
      return null;
    }
  }

  /**
   * Check for security issues
   */
  async checkSecurity() {
    const issues = [];

    // Check for RLS policies
    const { data: tables, error: tablesError } = await supabase.rpc('check_rls_status');

    if (!tablesError && tables) {
      const unprotectedTables = tables.filter((t: any) => !t.rls_enabled);
      if (unprotectedTables.length > 0) {
        issues.push({
          level: 'critical',
          message: `Tables without RLS: ${unprotectedTables.map((t: any) => t.table_name).join(', ')}`
        });
      }
    }

    // Check for suspicious login patterns
    const { data: suspiciousLogins } = await supabase.rpc('detect_suspicious_logins', {
      threshold: 5,
      minutes: 10
    });

    if (suspiciousLogins && suspiciousLogins.length > 0) {
      issues.push({
        level: 'warning',
        message: `Suspicious login attempts detected from: ${suspiciousLogins.map((l: any) => l.ip_address).join(', ')}`
      });
    }

    return issues;
  }

  /**
   * Generate monitoring report
   */
  async generateReport() {
    console.log('\n📊 Authentication Monitoring Report');
    console.log('=====================================\n');

    const metrics = await this.getAuthMetrics();
    const securityIssues = await this.checkSecurity();

    if (metrics) {
      console.log('📈 Metrics (Last 24 Hours)');
      console.log('---------------------------');
      if (metrics.stats) {
        console.log(`• Total login attempts: ${metrics.stats.total_attempts || 0}`);
        console.log(`• Successful logins: ${metrics.stats.successful_logins || 0}`);
        console.log(`• Failed logins: ${metrics.stats.failed_logins || 0}`);
        console.log(`• Success rate: ${metrics.stats.success_rate || 0}%`);
      }
      console.log(`• Active sessions: ${metrics.activeSessions}`);

      if (metrics.recentErrors && metrics.recentErrors.length > 0) {
        console.log('\n❌ Recent Errors');
        console.log('----------------');
        metrics.recentErrors.slice(0, 5).forEach((error: any) => {
          console.log(`• ${error.created_at}: ${error.error_message || 'Unknown error'}`);
        });
      }
    }

    if (securityIssues && securityIssues.length > 0) {
      console.log('\n⚠️  Security Issues');
      console.log('-------------------');
      securityIssues.forEach(issue => {
        const icon = issue.level === 'critical' ? '🔴' : '🟡';
        console.log(`${icon} ${issue.message}`);
      });
    } else {
      console.log('\n✅ No security issues detected');
    }

    console.log('\n=====================================\n');
  }

  /**
   * Start continuous monitoring
   */
  async startMonitoring(intervalMinutes = 5) {
    console.log(`🔍 Starting auth monitoring (checking every ${intervalMinutes} minutes)...`);

    // Initial report
    await this.generateReport();

    // Set up interval
    setInterval(async () => {
      await this.generateReport();
    }, intervalMinutes * 60 * 1000);
  }
}

// CLI interface
const command = process.argv[2];
const monitor = new AuthMonitor();

switch (command) {
  case 'report':
    monitor.generateReport().then(() => process.exit(0));
    break;
  case 'monitor':
    const interval = parseInt(process.argv[3] || '5');
    monitor.startMonitoring(interval);
    break;
  case 'security':
    monitor.checkSecurity().then(issues => {
      console.log(JSON.stringify(issues, null, 2));
      process.exit(issues.length > 0 ? 1 : 0);
    });
    break;
  default:
    console.log('Usage:');
    console.log('  npm run auth:monitor report   - Generate one-time report');
    console.log('  npm run auth:monitor monitor [interval] - Start continuous monitoring');
    console.log('  npm run auth:monitor security - Check security issues');
    process.exit(0);
}

// Export for use in other scripts
export { AuthMonitor };