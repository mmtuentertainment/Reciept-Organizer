/**
 * Feature Flag System
 * Manages feature toggles for safe rollout and rollback
 */

import { createClient } from '@supabase/supabase-js';

// Initialize Supabase client
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL || '',
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || ''
);

export interface FeatureFlag {
  name: string;
  value: any;
  active: boolean;
  created_at: string;
  updated_at: string;
}

export class FeatureFlags {
  private static flags = new Map<string, any>();
  private static initialized = false;
  private static subscription: any;

  /**
   * Initialize feature flags from database
   */
  static async initialize() {
    if (this.initialized) return;

    try {
      // Load all active flags
      const { data, error } = await supabase
        .from('feature_flags')
        .select('*')
        .eq('active', true);

      if (error) {
        console.error('Failed to load feature flags:', error);
        // Fall back to environment defaults
        this.loadEnvironmentDefaults();
      } else if (data) {
        data.forEach((flag: FeatureFlag) => {
          this.flags.set(flag.name, this.parseValue(flag.value));
        });
      }

      // Subscribe to real-time updates
      this.subscription = supabase
        .channel('feature_flags_changes')
        .on('postgres_changes', {
          event: '*',
          schema: 'public',
          table: 'feature_flags'
        }, (payload) => {
          if (payload.eventType === 'DELETE') {
            this.flags.delete(payload.old.name);
          } else if (payload.new) {
            const flag = payload.new as FeatureFlag;
            if (flag.active) {
              this.flags.set(flag.name, this.parseValue(flag.value));
            } else {
              this.flags.delete(flag.name);
            }
          }
        })
        .subscribe();

      this.initialized = true;
    } catch (error) {
      console.error('Feature flags initialization error:', error);
      this.loadEnvironmentDefaults();
    }
  }

  /**
   * Load default flags from environment
   */
  private static loadEnvironmentDefaults() {
    this.flags.set('auth_enabled', process.env.AUTH_ENABLED === 'true');
    this.flags.set('auth_bypass', process.env.AUTH_BYPASS_MODE === 'true');
    this.flags.set('auth_rollout_percentage', parseInt(process.env.AUTH_ROLLOUT_PERCENTAGE || '0'));
    this.flags.set('test_mode', process.env.NODE_ENV === 'test');
  }

  /**
   * Parse JSON value from database
   */
  private static parseValue(value: any): any {
    if (typeof value === 'string') {
      try {
        return JSON.parse(value);
      } catch {
        // If not JSON, return as string
        return value;
      }
    }
    return value;
  }

  /**
   * Check if a feature is enabled
   */
  static isEnabled(flag: string): boolean {
    if (!this.initialized) {
      console.warn('Feature flags not initialized, using defaults');
      this.loadEnvironmentDefaults();
    }
    return this.flags.get(flag) === true || this.flags.get(flag) === 'true';
  }

  /**
   * Get a feature flag value
   */
  static getValue(flag: string): any {
    if (!this.initialized) {
      console.warn('Feature flags not initialized, using defaults');
      this.loadEnvironmentDefaults();
    }
    return this.flags.get(flag);
  }

  /**
   * Set a feature flag (updates database)
   */
  static async setFlag(flag: string, value: any) {
    try {
      const { error } = await supabase
        .from('feature_flags')
        .upsert({
          name: flag,
          value: JSON.stringify(value),
          active: true,
          updated_at: new Date().toISOString()
        });

      if (error) {
        console.error(`Failed to set flag ${flag}:`, error);
        return false;
      }

      // Update local cache immediately
      this.flags.set(flag, value);
      return true;
    } catch (error) {
      console.error(`Error setting flag ${flag}:`, error);
      return false;
    }
  }

  /**
   * Check if user is in rollout percentage
   */
  static isUserInRollout(userId: string): boolean {
    const percentage = this.getValue('auth_rollout_percentage') || 0;
    if (percentage === 0) return false;
    if (percentage >= 100) return true;

    // Simple hash-based rollout
    const hash = this.hashCode(userId);
    const bucket = Math.abs(hash) % 100;
    return bucket < percentage;
  }

  /**
   * Simple hash function for rollout
   */
  private static hashCode(str: string): number {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32-bit integer
    }
    return hash;
  }

  /**
   * Clean up subscriptions
   */
  static async cleanup() {
    if (this.subscription) {
      await this.subscription.unsubscribe();
      this.subscription = null;
    }
    this.initialized = false;
    this.flags.clear();
  }

  /**
   * Get all flags (for debugging)
   */
  static getAllFlags(): Record<string, any> {
    const result: Record<string, any> = {};
    this.flags.forEach((value, key) => {
      result[key] = value;
    });
    return result;
  }
}

// Auto-initialize in browser environment
if (typeof window !== 'undefined') {
  FeatureFlags.initialize();
}

// Export for use in auth flows
export const shouldBypassAuth = (): boolean => {
  return FeatureFlags.isEnabled('auth_bypass') || !FeatureFlags.isEnabled('auth_enabled');
};

export const isAuthEnabled = (): boolean => {
  return FeatureFlags.isEnabled('auth_enabled') && !FeatureFlags.isEnabled('auth_bypass');
};

export const getAuthMode = (): 'enabled' | 'bypass' | 'test' => {
  if (FeatureFlags.isEnabled('test_mode')) return 'test';
  if (FeatureFlags.isEnabled('auth_bypass')) return 'bypass';
  if (FeatureFlags.isEnabled('auth_enabled')) return 'enabled';
  return 'bypass'; // Default to bypass for safety
};