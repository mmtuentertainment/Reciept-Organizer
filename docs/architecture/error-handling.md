# Error Handling

### Auth Error Categories

```typescript
enum AuthErrorType {
  NETWORK_ERROR = 'NETWORK_ERROR',           // Retry with backoff
  INVALID_CREDENTIALS = 'INVALID_CREDENTIALS', // Show error, allow retry
  SESSION_EXPIRED = 'SESSION_EXPIRED',       // Auto-refresh
  RATE_LIMITED = 'RATE_LIMITED',             // Show cooldown timer
  SERVER_ERROR = 'SERVER_ERROR',             // Show maintenance message
  INVALID_TOKEN = 'INVALID_TOKEN',           // Force re-login
}

class AuthErrorHandler {
  handle(error: AuthError): AuthErrorResponse {
    switch(error.type) {
      case AuthErrorType.NETWORK_ERROR:
        return {
          retry: true,
          backoff: this.calculateBackoff(error.attempts),
          message: 'Connection issue. Retrying...'
        };
      case AuthErrorType.INVALID_CREDENTIALS:
        return {
          retry: false,
          message: 'Invalid email or password',
          action: 'SHOW_LOGIN_FORM'
        };
      // ... handle other cases
    }
  }
}
```
