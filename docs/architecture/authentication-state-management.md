# Authentication State Management

### Unified Auth State Machine

```
┌──────────┐      ┌──────────┐      ┌──────────┐
│  INIT    │─────▶│ LOADING  │─────▶│  READY   │
└──────────┘      └──────────┘      └──────────┘
                        │                  │
                        ▼                  ▼
                  ┌──────────┐      ┌──────────┐
                  │  ERROR   │      │  AUTHED  │
                  └──────────┘      └──────────┘
                                          │
                                          ▼
                                    ┌──────────┐
                                    │ EXPIRED  │
                                    └──────────┘
```

### State Definitions

| State | Description | Triggers | Actions |
|-------|-------------|----------|---------|
| INIT | Application starting | App launch | Check stored session |
| LOADING | Validating session | Token validation | Show loading UI |
| READY | No valid session | Failed validation | Show login UI |
| AUTHED | Valid session active | Successful auth | Enable app features |
| EXPIRED | Session needs refresh | Token expiry | Auto-refresh attempt |
| ERROR | Auth system failure | Network/system error | Show error UI |

### Platform-Specific State Management

#### Flutter (Riverpod)

```dart
// auth_state_provider.dart
@riverpod
class AuthState extends _$AuthState {
  @override
  FutureOr<AuthStatus> build() async {
    // Initialize from secure storage
    final stored = await secureStorage.read(key: 'session');
    if (stored != null) {
      return _validateAndRefresh(stored);
    }
    return AuthStatus.ready;
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      await _persistSession(response.session);
      state = AsyncValue.data(AuthStatus.authenticated);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
```

#### Next.js (Server Components + Context)

```typescript
// auth-context.tsx
export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check cookies for existing session
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (event === 'SIGNED_IN' || event === 'TOKEN_REFRESHED') {
          await fetch('/api/auth/session', {
            method: 'POST',
            body: JSON.stringify({ session }),
          });
        }
        setSession(session);
        setLoading(false);
      }
    );
    return () => subscription.unsubscribe();
  }, []);

  return (
    <AuthContext.Provider value={{ session, loading }}>
      {children}
    </AuthContext.Provider>
  );
};
```

#### React Native (Expo SecureStore)

```typescript
// useAuth.ts
export const useAuth = () => {
  const [session, setSession] = useState<Session | null>(null);

  const persistSession = async (session: Session) => {
    await SecureStore.setItemAsync('supabase.auth.token', JSON.stringify(session));
  };

  const loadSession = async () => {
    const stored = await SecureStore.getItemAsync('supabase.auth.token');
    if (stored) {
      const session = JSON.parse(stored);
      if (isExpired(session)) {
        return refreshSession(session.refresh_token);
      }
      return session;
    }
    return null;
  };

  return { session, signIn, signOut, loading };
};
```
