# Session Management

### Token Refresh Strategy

```typescript
class TokenRefreshManager {
  private refreshTimer: NodeJS.Timeout | null = null;

  scheduleRefresh(session: Session) {
    // Clear existing timer
    if (this.refreshTimer) clearTimeout(this.refreshTimer);

    // Calculate refresh time (5 minutes before expiry)
    const expiresAt = session.expires_at || 0;
    const refreshAt = expiresAt - (5 * 60 * 1000);
    const delay = refreshAt - Date.now();

    if (delay > 0) {
      this.refreshTimer = setTimeout(async () => {
        try {
          const { data, error } = await supabase.auth.refreshSession();
          if (!error && data.session) {
            this.scheduleRefresh(data.session);
            await this.persistSession(data.session);
          }
        } catch (error) {
          // Handle refresh failure
          this.handleRefreshError(error);
        }
      }, delay);
    }
  }
}
```

### Inactivity Timeout Implementation

```typescript
class InactivityMonitor {
  private lastActivity: Date = new Date();
  private warningTimer: NodeJS.Timeout | null = null;
  private logoutTimer: NodeJS.Timeout | null = null;

  constructor(
    private warningMinutes: number,
    private timeoutMinutes: number
  ) {}

  resetTimers() {
    this.lastActivity = new Date();

    // Clear existing timers
    if (this.warningTimer) clearTimeout(this.warningTimer);
    if (this.logoutTimer) clearTimeout(this.logoutTimer);

    // Set warning timer
    this.warningTimer = setTimeout(() => {
      this.showWarning();
    }, this.warningMinutes * 60 * 1000);

    // Set logout timer
    this.logoutTimer = setTimeout(() => {
      this.forceLogout();
    }, this.timeoutMinutes * 60 * 1000);
  }

  extendSession() {
    this.resetTimers();
    // Dismiss warning UI
  }
}

// Platform-specific instances
const webMonitor = new InactivityMonitor(25, 30);      // 25 min warning, 30 min logout
const mobileMonitor = new InactivityMonitor(115, 120); // 115 min warning, 120 min logout
```
