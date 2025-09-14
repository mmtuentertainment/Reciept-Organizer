import { AppState, AppStateStatus } from 'react-native';
import { useEffect, useRef, useCallback } from 'react';

export interface InactivityMonitorOptions {
  timeout: number; // in milliseconds
  onTimeout: () => void;
  enabled?: boolean;
}

export class InactivityMonitor {
  private timer: NodeJS.Timeout | null = null;
  private lastActivity: Date = new Date();
  private isActive: boolean = true;
  private appStateSubscription: any = null;

  constructor(
    private timeout: number,
    private onTimeout: () => void
  ) {
    this.startMonitoring();
  }

  /**
   * Start monitoring for inactivity
   */
  private startMonitoring(): void {
    // Monitor app state changes
    this.appStateSubscription = AppState.addEventListener(
      'change',
      this.handleAppStateChange.bind(this)
    );

    this.startTimer();
  }

  /**
   * Handle app state changes
   */
  private handleAppStateChange(nextAppState: AppStateStatus): void {
    if (nextAppState === 'active') {
      // App came to foreground
      const inactiveTime = Date.now() - this.lastActivity.getTime();

      if (inactiveTime >= this.timeout) {
        // User was away too long
        this.isActive = false;
        this.onTimeout();
      } else {
        // Resume monitoring
        this.resume();
      }
    } else if (nextAppState === 'background' || nextAppState === 'inactive') {
      // App went to background
      this.lastActivity = new Date();
      this.stopTimer();
    }
  }

  /**
   * Start or restart the inactivity timer
   */
  startTimer(): void {
    this.stopTimer();
    this.lastActivity = new Date();
    this.isActive = true;

    this.timer = setTimeout(() => {
      if (this.isActive) {
        this.isActive = false;
        this.onTimeout();
      }
    }, this.timeout);
  }

  /**
   * Reset the timer on user activity
   */
  resetTimer(): void {
    if (this.isActive) {
      this.startTimer();
    }
  }

  /**
   * Stop the timer
   */
  stopTimer(): void {
    if (this.timer) {
      clearTimeout(this.timer);
      this.timer = null;
    }
    this.isActive = false;
  }

  /**
   * Resume monitoring after being paused
   */
  resume(): void {
    if (!this.isActive) {
      this.isActive = true;
      this.startTimer();
    }
  }

  /**
   * Get time since last activity
   */
  getTimeSinceLastActivity(): number {
    return Date.now() - this.lastActivity.getTime();
  }

  /**
   * Check if currently monitoring
   */
  getIsActive(): boolean {
    return this.isActive;
  }

  /**
   * Clean up resources
   */
  dispose(): void {
    this.stopTimer();
    if (this.appStateSubscription) {
      this.appStateSubscription.remove();
      this.appStateSubscription = null;
    }
  }
}

/**
 * React hook for inactivity monitoring
 */
export function useInactivityMonitor(options: InactivityMonitorOptions) {
  const monitorRef = useRef<InactivityMonitor | null>(null);

  const resetTimer = useCallback(() => {
    if (monitorRef.current) {
      monitorRef.current.resetTimer();
    }
  }, []);

  useEffect(() => {
    if (options.enabled !== false) {
      monitorRef.current = new InactivityMonitor(options.timeout, options.onTimeout);

      return () => {
        if (monitorRef.current) {
          monitorRef.current.dispose();
          monitorRef.current = null;
        }
      };
    }
  }, [options.timeout, options.onTimeout, options.enabled]);

  return { resetTimer };
}