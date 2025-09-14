# Story 1.4: Native (React Native) Authentication Implementation

## Story Overview
**ID**: STORY-1.4
**Epic**: Phase 2 - Authentication & User Management
**Priority**: P1 - High
**Risk Level**: Medium (Platform differences iOS/Android)
**Estimated Points**: 8

**As a** native mobile app user,
**I want** to authenticate in the React Native app,
**so that** I have secure access on iOS and Android.

## Business Value
- Enables native mobile app authentication
- Provides platform-specific optimizations
- Leverages device security features
- Completes mobile platform coverage

## Acceptance Criteria

### 1. Auth Screens with NativeWind
- [ ] Create login screen with NativeWind styling
- [ ] Create signup screen matching design system
- [ ] Implement form validation
- [ ] Add loading states and animations
- [ ] Support safe area insets

### 2. Expo SecureStore Integration
- [ ] Configure Expo SecureStore for tokens
- [ ] Implement encrypted storage
- [ ] Handle keychain/keystore access
- [ ] Support biometric protection
- [ ] Clear storage on logout

### 3. Supabase JS Client
- [ ] Install and configure @supabase/supabase-js
- [ ] Initialize client with proper config
- [ ] Implement auth state management
- [ ] Handle deep links for email verification
- [ ] Configure OAuth redirects

### 4. Session State Management
- [ ] Implement React Context for auth state
- [ ] Create auth hooks for components
- [ ] Handle token refresh automatically
- [ ] Manage 2-hour inactivity timeout
- [ ] Sync state across app screens

### 5. Platform-Specific Auth
- [ ] iOS: Keychain integration
- [ ] Android: Keystore integration
- [ ] Handle Face ID/Touch ID permissions
- [ ] Support Android biometric prompt
- [ ] Implement platform-specific UI adjustments

## Technical Implementation

### Package Installation
```json
// package.json
{
  "dependencies": {
    "@supabase/supabase-js": "^2.38.0",
    "expo-secure-store": "~12.5.0",
    "expo-local-authentication": "~13.6.0",
    "expo-linking": "~5.0.2",
    "nativewind": "^2.0.0"
  }
}
```

### Supabase Client Setup
```typescript
// src/lib/supabase.ts
import { createClient } from '@supabase/supabase-js';
import * as SecureStore from 'expo-secure-store';
import { Platform } from 'react-native';

const ExpoSecureStoreAdapter = {
  getItem: async (key: string) => {
    if (Platform.OS === 'web') {
      return localStorage.getItem(key);
    }
    return await SecureStore.getItemAsync(key);
  },
  setItem: async (key: string, value: string) => {
    if (Platform.OS === 'web') {
      localStorage.setItem(key, value);
    } else {
      await SecureStore.setItemAsync(key, value, {
        keychainAccessible: SecureStore.WHEN_UNLOCKED_THIS_DEVICE_ONLY,
      });
    }
  },
  removeItem: async (key: string) => {
    if (Platform.OS === 'web') {
      localStorage.removeItem(key);
    } else {
      await SecureStore.deleteItemAsync(key);
    }
  },
};

export const supabase = createClient(
  process.env.EXPO_PUBLIC_SUPABASE_URL!,
  process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY!,
  {
    auth: {
      storage: ExpoSecureStoreAdapter,
      autoRefreshToken: true,
      persistSession: true,
      detectSessionInUrl: false,
    },
  }
);
```

### Auth Context Provider
```tsx
// src/contexts/AuthContext.tsx
import React, { createContext, useContext, useEffect, useState } from 'react';
import { Session, User } from '@supabase/supabase-js';
import { supabase } from '../lib/supabase';
import { InactivityMonitor } from '../services/InactivityMonitor';

interface AuthContextType {
  user: User | null;
  session: Session | null;
  loading: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signUp: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);

  // Inactivity monitor (2 hours for mobile)
  const inactivityMonitor = new InactivityMonitor({
    timeoutMinutes: 120,
    warningMinutes: 115,
    onTimeout: () => signOut(),
    onWarning: () => showTimeoutWarning(),
  });

  useEffect(() => {
    // Get initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setUser(session?.user ?? null);
      setLoading(false);

      if (session) {
        inactivityMonitor.start();
      }
    });

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (_event, session) => {
        setSession(session);
        setUser(session?.user ?? null);

        if (session) {
          inactivityMonitor.reset();
        } else {
          inactivityMonitor.stop();
        }
      }
    );

    return () => {
      subscription.unsubscribe();
      inactivityMonitor.stop();
    };
  }, []);

  const signIn = async (email: string, password: string) => {
    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) throw error;
  };

  const signUp = async (email: string, password: string) => {
    const { error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        emailRedirectTo: 'receiptorganizer://auth/callback',
      },
    });

    if (error) throw error;
  };

  const signOut = async () => {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
    inactivityMonitor.stop();
  };

  return (
    <AuthContext.Provider value={{
      user,
      session,
      loading,
      signIn,
      signUp,
      signOut,
    }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};
```

### Login Screen with NativeWind
```tsx
// src/screens/auth/LoginScreen.tsx
import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useAuth } from '../../contexts/AuthContext';

export function LoginScreen({ navigation }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const { signIn } = useAuth();

  const handleLogin = async () => {
    if (!email || !password) {
      Alert.alert('Error', 'Please fill in all fields');
      return;
    }

    setLoading(true);
    try {
      await signIn(email, password);
      // Navigation handled by auth state change
    } catch (error) {
      Alert.alert('Error', error.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <SafeAreaView className="flex-1 bg-white dark:bg-gray-900">
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        className="flex-1"
      >
        <View className="flex-1 justify-center px-6">
          {/* Logo */}
          <View className="items-center mb-12">
            <View className="w-20 h-20 bg-blue-500 rounded-2xl items-center justify-center">
              <Text className="text-white text-3xl">📱</Text>
            </View>
            <Text className="text-2xl font-bold mt-4 text-gray-900 dark:text-white">
              Receipt Organizer
            </Text>
          </View>

          {/* Form */}
          <View className="space-y-4">
            <View>
              <Text className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Email
              </Text>
              <TextInput
                className="w-full px-4 py-3 bg-gray-100 dark:bg-gray-800 rounded-lg text-gray-900 dark:text-white"
                placeholder="you@example.com"
                placeholderTextColor="#9CA3AF"
                keyboardType="email-address"
                autoCapitalize="none"
                value={email}
                onChangeText={setEmail}
                editable={!loading}
              />
            </View>

            <View>
              <Text className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Password
              </Text>
              <TextInput
                className="w-full px-4 py-3 bg-gray-100 dark:bg-gray-800 rounded-lg text-gray-900 dark:text-white"
                placeholder="••••••••"
                placeholderTextColor="#9CA3AF"
                secureTextEntry
                value={password}
                onChangeText={setPassword}
                editable={!loading}
              />
            </View>

            <TouchableOpacity
              className={`w-full py-3 rounded-lg ${
                loading
                  ? 'bg-gray-400'
                  : 'bg-blue-500 active:bg-blue-600'
              }`}
              onPress={handleLogin}
              disabled={loading}
            >
              {loading ? (
                <ActivityIndicator color="white" />
              ) : (
                <Text className="text-white text-center font-semibold">
                  Sign In
                </Text>
              )}
            </TouchableOpacity>

            <TouchableOpacity
              onPress={() => navigation.navigate('SignUp')}
              disabled={loading}
            >
              <Text className="text-center text-blue-500 dark:text-blue-400">
                Don't have an account? Sign up
              </Text>
            </TouchableOpacity>
          </View>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}
```

### Platform-Specific Security
```typescript
// src/services/BiometricAuth.ts
import * as LocalAuthentication from 'expo-local-authentication';
import * as SecureStore from 'expo-secure-store';
import { Platform } from 'react-native';

export class BiometricAuth {
  static async isAvailable(): Promise<boolean> {
    const hasHardware = await LocalAuthentication.hasHardwareAsync();
    const isEnrolled = await LocalAuthentication.isEnrolledAsync();
    return hasHardware && isEnrolled;
  }

  static async authenticate(): Promise<boolean> {
    const result = await LocalAuthentication.authenticateAsync({
      promptMessage: 'Authenticate to access your receipts',
      fallbackLabel: 'Use Passcode',
      cancelLabel: 'Cancel',
      disableDeviceFallback: false,
    });

    return result.success;
  }

  static async saveCredentials(email: string, token: string) {
    if (Platform.OS === 'ios') {
      await SecureStore.setItemAsync('user_email', email, {
        keychainAccessible: SecureStore.WHEN_PASSCODE_SET_THIS_DEVICE_ONLY,
        keychainService: 'com.receiptorganizer.auth',
      });
    } else {
      // Android Keystore
      await SecureStore.setItemAsync('user_email', email, {
        keychainAccessible: SecureStore.WHEN_UNLOCKED,
        requireAuthentication: true,
      });
    }
  }
}
```

## Integration Verification

### IV1: Tab Navigation Functions
```typescript
// Test navigation with auth
test('Tab navigation works with auth state', async () => {
  const { getByTestId } = render(<AuthenticatedApp />);

  fireEvent.press(getByTestId('receipts-tab'));
  expect(getByTestId('receipts-screen')).toBeTruthy();

  fireEvent.press(getByTestId('settings-tab'));
  expect(getByTestId('settings-screen')).toBeTruthy();
});
```

### IV2: Expo SDK 52 Compatibility
```bash
# Verify Expo SDK version
expo doctor

# Check for compatibility issues
npx expo-doctor@latest

# Expected: No critical issues with SDK 52
```

### IV3: Build Process
```bash
# iOS build
eas build --platform ios --profile preview

# Android build
eas build --platform android --profile preview

# Verify builds complete successfully
```

## Definition of Done
- [ ] Auth screens created with NativeWind
- [ ] Expo SecureStore configured and working
- [ ] Supabase client integrated
- [ ] Session management with Context API
- [ ] Platform-specific auth working (iOS/Android)
- [ ] 2-hour timeout implemented
- [ ] Existing navigation preserved
- [ ] Tests written and passing

## Dependencies
- Stories 1.0-1.3 complete
- Expo SDK 52 configured
- React Native environment setup
- EAS Build configured

## Risks & Mitigation
| Risk | Impact | Mitigation |
|------|--------|------------|
| Keychain/Keystore issues | High | Extensive platform testing |
| Deep linking conflicts | Medium | Proper scheme configuration |
| Expo SDK breaking changes | Medium | Lock versions, test thoroughly |

## Follow-up Stories
- Story 1.5: Google OAuth Integration
- Story 1.7: Biometric Authentication
- Story 1.6: User Profile Management

## Notes
- Test on both iOS and Android devices
- Consider implementing app-specific PIN
- Monitor crash reports for platform-specific issues