# Security Architecture

### Token Storage Strategy

| Platform | Storage Method | Security Level | Notes |
|----------|---------------|----------------|-------|
| Flutter Web | Secure Storage (AES) | High | Encrypted localStorage |
| Next.js | HttpOnly Cookies | Very High | CSRF protected |
| iOS | Keychain Services | Very High | Hardware encrypted |
| Android | Android Keystore | Very High | Hardware backed |

### OAuth 2.0 + PKCE Flow

```
User         App          Supabase        Google
 │            │               │              │
 ├─Click──────▶              │              │
 │            ├─Generate──────▶              │
 │            │  PKCE         │              │
 │            │  Challenge    │              │
 │            ├─Redirect──────┼─────────────▶
 │◀───────────┼──────────────┼──────────────┤
 │            │              │   Auth Screen │
 ├─Authorize──┼──────────────┼─────────────▶
 │            │              │◀─────Code─────┤
 │◀─Redirect──┤              │              │
 │            ├─Exchange─────▶              │
 │            │  Code+Verifier│              │
 │            │◀──JWT────────┤              │
 │            ├─Store Token   │              │
 │◀─Success───┤              │              │
```

### Biometric Authentication Flow

```dart
// biometric_auth.dart
class BiometricAuth {
  static Future<bool> authenticate() async {
    final LocalAuthentication auth = LocalAuthentication();

    // Check availability
    final bool canCheckBiometrics = await auth.canCheckBiometrics;
    if (!canCheckBiometrics) return false;

    // Authenticate
    final bool didAuthenticate = await auth.authenticate(
      localizedReason: 'Authenticate to access your receipts',
      options: const AuthenticationOptions(
        biometricOnly: false, // Allow PIN fallback
        stickyAuth: true,
      ),
    );

    if (didAuthenticate) {
      // Retrieve stored credentials
      final credentials = await SecureStorage.read('biometric_session');
      return await refreshSession(credentials);
    }
    return false;
  }
}
```
