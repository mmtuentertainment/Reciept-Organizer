# Story 1.7: Biometric Authentication

## Story Overview
**ID**: STORY-1.7
**Epic**: Phase 2 - Authentication & User Management
**Priority**: P3 - Nice to have
**Risk Level**: Low (Optional enhancement)
**Estimated Points**: 5

**As a** mobile user,
**I want** to use fingerprint/face recognition,
**so that** I can quickly access the app securely.

## Business Value
- Improves user experience with quick access
- Enhances security without passwords
- Reduces friction for frequent users
- Leverages device security capabilities

## Acceptance Criteria

### 1. Biometric Prompt
- [ ] Show biometric option after first password login
- [ ] Display appropriate prompt for device type
- [ ] Handle user opt-in gracefully
- [ ] Store preference securely
- [ ] Show setup instructions if needed

### 2. Secure Credential Storage
- [ ] Store encrypted refresh token in keychain/keystore
- [ ] Link biometric unlock to stored credentials
- [ ] Clear credentials on logout
- [ ] Handle credential expiry
- [ ] Implement secure token refresh

### 3. Graceful Fallback
- [ ] Always allow password entry
- [ ] Handle biometric failures gracefully
- [ ] Provide PIN option as secondary fallback
- [ ] Show clear error messages
- [ ] Retry limits before requiring password

### 4. User Settings
- [ ] Enable/disable biometric auth in settings
- [ ] Show enrollment status
- [ ] Allow re-enrollment after changes
- [ ] Clear biometric data option
- [ ] Sync preference across devices

### 5. Platform Implementations
- [ ] iOS: Touch ID and Face ID support
- [ ] Android: Fingerprint and Face Unlock
- [ ] Web: WebAuthn for supported browsers
- [ ] Consistent UX across platforms
- [ ] Handle unsupported devices

## Technical Implementation

### Flutter Biometric Implementation
```dart
// lib/features/auth/services/biometric_service.dart
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (isAvailable && isDeviceSupported) {
        final biometrics = await _localAuth.getAvailableBiometrics();
        return biometrics.isNotEmpty;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<BiometricType?> getAvailableBiometric() async {
    final biometrics = await _localAuth.getAvailableBiometrics();

    if (biometrics.contains(BiometricType.face)) {
      return BiometricType.face;
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return BiometricType.fingerprint;
    } else if (biometrics.contains(BiometricType.strong)) {
      return BiometricType.strong;
    }
    return null;
  }

  Future<bool> authenticateWithBiometric() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your receipts',
        options: AuthenticationOptions(
          biometricOnly: false, // Allow PIN fallback
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        // Retrieve stored credentials
        final refreshToken = await _getStoredRefreshToken();
        if (refreshToken != null) {
          return await _refreshSession(refreshToken);
        }
      }
      return false;
    } catch (e) {
      print('Biometric auth error: $e');
      return false;
    }
  }

  Future<void> enableBiometric(String refreshToken) async {
    // Store refresh token securely with biometric protection
    await _storage.write(
      key: 'biometric_refresh_token',
      value: refreshToken,
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        sharedPreferencesName: 'biometric_prefs',
        requireAuthentication: true,
      ),
      iOptions: IOSOptions(
        accessibility: IOSAccessibility.unlocked_this_device,
        accountName: 'ReceiptOrganizer',
        requireAuthentication: true,
      ),
    );

    // Store preference
    await _storage.write(
      key: 'biometric_enabled',
      value: 'true',
    );
  }

  Future<void> disableBiometric() async {
    await _storage.delete(key: 'biometric_refresh_token');
    await _storage.write(key: 'biometric_enabled', value: 'false');
  }

  Future<String?> _getStoredRefreshToken() async {
    return await _storage.read(key: 'biometric_refresh_token');
  }

  Future<bool> _refreshSession(String refreshToken) async {
    try {
      final response = await Supabase.instance.client.auth.setSession(
        refreshToken,
      );
      return response.session != null;
    } catch (e) {
      // Token expired or invalid
      await disableBiometric();
      return false;
    }
  }
}
```

### React Native Implementation
```typescript
// src/services/BiometricAuthService.ts
import * as LocalAuthentication from 'expo-local-authentication';
import * as SecureStore from 'expo-secure-store';
import { supabase } from '../lib/supabase';

export class BiometricAuthService {
  static async isAvailable(): Promise<boolean> {
    const hasHardware = await LocalAuthentication.hasHardwareAsync();
    const supportedTypes = await LocalAuthentication.supportedAuthenticationTypesAsync();
    const isEnrolled = await LocalAuthentication.isEnrolledAsync();

    return hasHardware && supportedTypes.length > 0 && isEnrolled;
  }

  static async getBiometricType(): Promise<string> {
    const types = await LocalAuthentication.supportedAuthenticationTypesAsync();

    if (types.includes(LocalAuthentication.AuthenticationType.FACIAL_RECOGNITION)) {
      return 'Face ID';
    } else if (types.includes(LocalAuthentication.AuthenticationType.FINGERPRINT)) {
      return 'Touch ID';
    } else if (types.includes(LocalAuthentication.AuthenticationType.IRIS)) {
      return 'Iris Scanner';
    }
    return 'Biometric';
  }

  static async authenticate(): Promise<boolean> {
    const result = await LocalAuthentication.authenticateAsync({
      promptMessage: 'Authenticate to access Receipt Organizer',
      disableDeviceFallback: false,
      cancelLabel: 'Cancel',
      fallbackLabel: 'Use PIN',
    });

    if (result.success) {
      // Get stored refresh token
      const refreshToken = await SecureStore.getItemAsync(
        'biometric_refresh_token'
      );

      if (refreshToken) {
        try {
          const { data, error } = await supabase.auth.refreshSession({
            refresh_token: refreshToken,
          });

          if (data?.session) {
            return true;
          } else {
            // Token expired, clear biometric
            await this.disable();
            return false;
          }
        } catch (error) {
          console.error('Session refresh failed:', error);
          return false;
        }
      }
    }

    return false;
  }

  static async enable(refreshToken: string): Promise<void> {
    // Store refresh token with biometric protection
    await SecureStore.setItemAsync(
      'biometric_refresh_token',
      refreshToken,
      {
        requireAuthentication: true,
        authenticationPrompt: 'Authenticate to save credentials',
        keychainAccessible: SecureStore.WHEN_PASSCODE_SET_THIS_DEVICE_ONLY,
      }
    );

    await SecureStore.setItemAsync('biometric_enabled', 'true');
  }

  static async disable(): Promise<void> {
    await SecureStore.deleteItemAsync('biometric_refresh_token');
    await SecureStore.setItemAsync('biometric_enabled', 'false');
  }

  static async isEnabled(): Promise<boolean> {
    const enabled = await SecureStore.getItemAsync('biometric_enabled');
    return enabled === 'true';
  }
}
```

### Biometric Setup Flow
```tsx
// components/auth/BiometricSetup.tsx
export function BiometricSetup({ onComplete }: { onComplete: () => void }) {
  const [loading, setLoading] = useState(false);
  const [biometricType, setBiometricType] = useState<string>('');
  const { session } = useAuth();

  useEffect(() => {
    checkBiometric();
  }, []);

  const checkBiometric = async () => {
    const available = await BiometricAuthService.isAvailable();
    if (available) {
      const type = await BiometricAuthService.getBiometricType();
      setBiometricType(type);
    }
  };

  const handleEnable = async () => {
    setLoading(true);
    try {
      // Authenticate first to verify identity
      const authenticated = await LocalAuthentication.authenticateAsync({
        promptMessage: `Enable ${biometricType} for quick access?`,
      });

      if (authenticated.success && session?.refresh_token) {
        await BiometricAuthService.enable(session.refresh_token);
        Alert.alert(
          'Success',
          `${biometricType} authentication enabled!`,
          [{ text: 'OK', onPress: onComplete }]
        );
      }
    } catch (error) {
      Alert.alert('Error', 'Failed to enable biometric authentication');
    } finally {
      setLoading(false);
    }
  };

  const handleSkip = () => {
    onComplete();
  };

  if (!biometricType) {
    return null; // Don't show if not available
  }

  return (
    <View className="flex-1 justify-center p-6">
      <View className="items-center mb-8">
        <Icon name={biometricType === 'Face ID' ? 'face' : 'fingerprint'} size={64} />
      </View>

      <Text className="text-2xl font-bold text-center mb-4">
        Enable {biometricType}?
      </Text>

      <Text className="text-gray-600 text-center mb-8">
        Use {biometricType} for quick and secure access to your receipts.
        You can always use your password as a backup.
      </Text>

      <TouchableOpacity
        className="bg-blue-500 rounded-lg py-3 mb-3"
        onPress={handleEnable}
        disabled={loading}
      >
        <Text className="text-white text-center font-semibold">
          Enable {biometricType}
        </Text>
      </TouchableOpacity>

      <TouchableOpacity
        className="py-3"
        onPress={handleSkip}
        disabled={loading}
      >
        <Text className="text-gray-500 text-center">
          Skip for now
        </Text>
      </TouchableOpacity>
    </View>
  );
}
```

### Web WebAuthn Implementation
```typescript
// lib/auth/webauthn.ts
export class WebAuthnService {
  static isSupported(): boolean {
    return window?.PublicKeyCredential !== undefined &&
           navigator?.credentials !== undefined;
  }

  static async register(userId: string, email: string) {
    if (!this.isSupported()) {
      throw new Error('WebAuthn not supported');
    }

    const challenge = crypto.getRandomValues(new Uint8Array(32));

    const publicKeyCredentialCreationOptions: PublicKeyCredentialCreationOptions = {
      challenge,
      rp: {
        name: 'Receipt Organizer',
        id: window.location.hostname,
      },
      user: {
        id: new TextEncoder().encode(userId),
        name: email,
        displayName: email,
      },
      pubKeyCredParams: [
        { alg: -7, type: 'public-key' }, // ES256
        { alg: -257, type: 'public-key' }, // RS256
      ],
      authenticatorSelection: {
        authenticatorAttachment: 'platform',
        userVerification: 'required',
      },
      timeout: 60000,
      attestation: 'direct',
    };

    const credential = await navigator.credentials.create({
      publicKey: publicKeyCredentialCreationOptions,
    });

    // Store credential ID for future authentication
    await this.storeCredential(userId, credential.id);

    return credential;
  }

  static async authenticate(userId: string) {
    const credentialId = await this.getCredential(userId);
    const challenge = crypto.getRandomValues(new Uint8Array(32));

    const publicKeyCredentialRequestOptions: PublicKeyCredentialRequestOptions = {
      challenge,
      allowCredentials: [{
        id: credentialId,
        type: 'public-key',
      }],
      userVerification: 'required',
      timeout: 60000,
    };

    const assertion = await navigator.credentials.get({
      publicKey: publicKeyCredentialRequestOptions,
    });

    // Verify assertion on server
    return this.verifyAssertion(assertion);
  }
}
```

## Integration Verification

### IV1: Password Auth Remains Primary
```typescript
test('Password auth works when biometric fails', async () => {
  // Mock biometric failure
  jest.spyOn(BiometricAuthService, 'authenticate').mockResolvedValue(false);

  // Password should still work
  const result = await signInWithPassword('test@example.com', 'password');
  expect(result.session).toBeDefined();
});
```

### IV2: No User Lockout
```typescript
test('User not locked out after biometric failures', async () => {
  // Fail biometric 5 times
  for (let i = 0; i < 5; i++) {
    await BiometricAuthService.authenticate();
  }

  // Password should still work
  const result = await signInWithPassword('test@example.com', 'password');
  expect(result.session).toBeDefined();
});
```

### IV3: Settings Sync
```typescript
test('Biometric settings sync across app restarts', async () => {
  await BiometricAuthService.enable(refreshToken);

  // Restart app simulation
  await app.restart();

  const isEnabled = await BiometricAuthService.isEnabled();
  expect(isEnabled).toBe(true);
});
```

## Definition of Done
- [ ] Biometric prompt shown after first login
- [ ] Secure credential storage implemented
- [ ] Graceful fallback to password working
- [ ] User settings for biometric auth
- [ ] Platform-specific implementations complete
- [ ] Tests written and passing
- [ ] Documentation updated

## Dependencies
- Stories 1.3 and 1.4 (Mobile auth) complete
- Device with biometric hardware
- Platform-specific permissions configured
- Secure storage implementation

## Risks & Mitigation
| Risk | Impact | Mitigation |
|------|--------|------------|
| Biometric hardware issues | Low | Always provide password fallback |
| Token expiry while stored | Medium | Validate tokens before use |
| Privacy concerns | Low | Clear opt-in, easy disable |

## Follow-up Stories
- Future: Multi-device biometric sync
- Future: Backup authentication methods
- Future: Passkey support

## Notes
- Test on various devices with different biometric types
- Consider accessibility for users who cannot use biometrics
- Monitor success/failure rates via analytics