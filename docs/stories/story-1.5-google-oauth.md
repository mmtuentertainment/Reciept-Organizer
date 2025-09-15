# Story 1.5: Google OAuth Integration

## Story Overview
**ID**: STORY-1.5
**Epic**: Phase 2 - Authentication & User Management
**Priority**: P2 - Medium
**Risk Level**: Medium (Third-party dependency)
**Estimated Points**: 5

**As a** user,
**I want** to sign in with my Google account,
**so that** I can authenticate quickly without remembering another password.

## Business Value
- Reduces friction in signup process
- Leverages trusted authentication provider
- Improves conversion rates
- Reduces password reset support requests

## Acceptance Criteria

### 1. Google OAuth Configuration
- [ ] Configure OAuth in Supabase dashboard
- [ ] Set up Google Cloud Console project
- [ ] Configure OAuth consent screen
- [ ] Add redirect URLs for all platforms
- [ ] Obtain and secure client credentials

### 2. OAuth Flow Implementation
- [ ] Web: Implement redirect-based flow
- [ ] Flutter: Implement PKCE flow
- [ ] React Native: Implement app-based flow
- [ ] Handle OAuth callbacks properly
- [ ] Implement error handling for denied access

### 3. PKCE Security
- [ ] Generate code verifier and challenge
- [ ] Implement secure state parameter
- [ ] Validate OAuth responses
- [ ] Prevent CSRF attacks
- [ ] Handle token exchange securely

### 4. Account Linking
- [ ] Link OAuth to existing email accounts
- [ ] Handle duplicate email scenarios
- [ ] Merge account data if requested
- [ ] Preserve user preferences
- [ ] Update profile with Google data

### 5. Error Handling
- [ ] Handle network failures gracefully
- [ ] Show clear error messages
- [ ] Provide fallback to email/password
- [ ] Log OAuth failures for debugging
- [ ] Implement retry mechanism

## Technical Implementation

### Supabase OAuth Configuration
```typescript
// Via Supabase Dashboard or CLI
const oauthConfig = {
  provider: 'google',
  client_id: process.env.GOOGLE_CLIENT_ID,
  secret: process.env.GOOGLE_CLIENT_SECRET, // Stored securely in env vars
  redirect_urls: [
    'https://app.receiptorganizer.com/auth/callback',
    'receiptorganizer://auth/callback',
    'com.receiptorganizer://auth/callback'
  ],
  scopes: ['email', 'profile']
};
```

### Web Implementation (Next.js)
```typescript
// app/auth/google/route.ts
import { createClient } from '@/lib/supabase/server';

export async function GET(request: Request) {
  const requestUrl = new URL(request.url);
  const supabase = createClient();

  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: 'google',
    options: {
      redirectTo: `${requestUrl.origin}/auth/callback`,
      scopes: 'email profile',
      queryParams: {
        access_type: 'offline',
        prompt: 'consent',
      },
    },
  });

  if (error) {
    return Response.redirect(`${requestUrl.origin}/auth/error`);
  }

  return Response.redirect(data.url);
}

// app/auth/callback/route.ts
export async function GET(request: Request) {
  const requestUrl = new URL(request.url);
  const code = requestUrl.searchParams.get('code');

  if (code) {
    const supabase = createClient();
    await supabase.auth.exchangeCodeForSession(code);
  }

  return Response.redirect(`${requestUrl.origin}/dashboard`);
}
```

### Flutter Implementation with PKCE
```dart
// lib/features/auth/services/google_auth_service.dart
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleAuthService {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final _supabase = Supabase.instance.client;

  Future<AuthResponse> signInWithGoogle() async {
    try {
      // Generate PKCE parameters
      final codeVerifier = _generateCodeVerifier();
      final codeChallenge = _generateCodeChallenge(codeVerifier);

      // Initiate OAuth flow with PKCE
      final result = await _appAuth.authorize(
        AuthorizationRequest(
          'google',
          'com.receiptorganizer://auth/callback',
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
            tokenEndpoint: 'https://oauth2.googleapis.com/token',
          ),
          scopes: ['openid', 'email', 'profile'],
          additionalParameters: {
            'code_challenge': codeChallenge,
            'code_challenge_method': 'S256',
          },
        ),
      );

      if (result != null) {
        // Exchange authorization code for tokens
        final tokenResult = await _appAuth.token(
          TokenRequest(
            'google',
            'com.receiptorganizer://auth/callback',
            authorizationCode: result.authorizationCode,
            codeVerifier: codeVerifier,
            serviceConfiguration: AuthorizationServiceConfiguration(
              authorizationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
              tokenEndpoint: 'https://oauth2.googleapis.com/token',
            ),
          ),
        );

        // Sign in to Supabase with the ID token
        final response = await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: tokenResult!.idToken!,
          accessToken: tokenResult.accessToken,
        );

        return AuthResponse.success(response.session!);
      }

      return AuthResponse.error('OAuth flow cancelled');
    } catch (e) {
      return AuthResponse.error(e.toString());
    }
  }

  String _generateCodeVerifier() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }
}
```

### React Native Implementation
```typescript
// src/services/GoogleAuthService.ts
import * as WebBrowser from 'expo-web-browser';
import * as AuthSession from 'expo-auth-session';
import { supabase } from '../lib/supabase';

WebBrowser.maybeCompleteAuthSession();

export class GoogleAuthService {
  private discovery = AuthSession.useAutoDiscovery(
    'https://accounts.google.com'
  );

  async signInWithGoogle() {
    const redirectUri = AuthSession.makeRedirectUri({
      scheme: 'com.receiptorganizer',
      path: 'auth/callback',
    });

    const request = new AuthSession.AuthRequest({
      clientId: process.env.EXPO_PUBLIC_GOOGLE_CLIENT_ID!,
      scopes: ['openid', 'email', 'profile'],
      redirectUri,
      responseType: AuthSession.ResponseType.Code,
      codeChallenge: AuthSession.AuthRequest.PKCE.codeChallenge(),
      codeChallengeMethod: AuthSession.CodeChallengeMethod.S256,
    });

    const result = await request.promptAsync(this.discovery);

    if (result.type === 'success') {
      const { code } = result.params;

      // Exchange code for session
      const { data, error } = await supabase.auth.exchangeCodeForSession(code);

      if (error) throw error;
      return data.session;
    }

    throw new Error('Authentication cancelled');
  }
}
```

### Account Linking Logic
```typescript
// lib/auth/account-linking.ts
export async function linkGoogleAccount(
  googleEmail: string,
  googleId: string,
  existingUserId?: string
) {
  // Check if email already exists
  const { data: existingUser } = await supabase
    .from('profiles')
    .select('id, email')
    .eq('email', googleEmail)
    .single();

  if (existingUser && existingUser.id !== existingUserId) {
    // Email exists with different account
    return {
      action: 'LINK_REQUIRED',
      message: 'This email is already associated with another account',
      existingUserId: existingUser.id,
    };
  }

  if (existingUserId) {
    // Update existing account with Google data
    await supabase
      .from('profiles')
      .update({
        google_id: googleId,
        oauth_provider: 'google',
        updated_at: new Date().toISOString(),
      })
      .eq('id', existingUserId);

    return { action: 'LINKED', userId: existingUserId };
  }

  // Create new account
  return { action: 'CREATED', userId: googleId };
}
```

### Error Handling Component
```tsx
// components/auth/OAuthError.tsx
export function OAuthError({ error, onRetry, onFallback }) {
  const getErrorMessage = (error: string) => {
    switch (error) {
      case 'access_denied':
        return 'You denied access to your Google account';
      case 'network_error':
        return 'Network error. Please check your connection';
      case 'invalid_request':
        return 'Invalid authentication request';
      default:
        return 'Authentication failed. Please try again';
    }
  };

  return (
    <Alert variant="destructive">
      <AlertCircle className="h-4 w-4" />
      <AlertTitle>Authentication Error</AlertTitle>
      <AlertDescription>
        {getErrorMessage(error)}
      </AlertDescription>
      <div className="mt-4 flex gap-2">
        <Button onClick={onRetry} variant="outline">
          Try Again
        </Button>
        <Button onClick={onFallback}>
          Use Email/Password
        </Button>
      </div>
    </Alert>
  );
}
```

## Integration Verification

### IV1: Email/Password Still Works
```typescript
test('Email auth works alongside OAuth', async () => {
  const { data: emailAuth } = await supabase.auth.signInWithPassword({
    email: 'test@example.com',
    password: 'password123',
  });
  expect(emailAuth.session).toBeDefined();
});
```

### IV2: No Duplicate Accounts
```sql
-- Via mcp__supabase__execute_sql
SELECT email, COUNT(*) as count
FROM profiles
GROUP BY email
HAVING COUNT(*) > 1;
-- Should return 0 rows
```

### IV3: Platform Transitions
```typescript
// Test cross-platform session
test('OAuth session works across platforms', async () => {
  // Sign in on web
  const webSession = await signInWithGoogleWeb();

  // Use same session on mobile
  const mobileClient = createClient({ session: webSession });
  const { data } = await mobileClient.from('receipts').select();

  expect(data).toBeDefined();
});
```

## Definition of Done
- [ ] Google OAuth configured in Supabase
- [ ] OAuth implemented on all platforms
- [ ] PKCE security implemented
- [ ] Account linking working properly
- [ ] Error handling comprehensive
- [ ] Tests written and passing
- [ ] Documentation updated

## Dependencies
- Stories 1.0-1.4 complete
- Google Cloud Console access
- OAuth credentials configured
- Platform-specific OAuth libraries

## Risks & Mitigation
| Risk | Impact | Mitigation |
|------|--------|------------|
| Google API changes | High | Monitor deprecation notices |
| OAuth consent rejection | Medium | Clear privacy policy, minimal scopes |
| Account linking conflicts | Medium | Clear user communication |

## Follow-up Stories
- Story 1.6: User Profile Management
- Future: Add more OAuth providers (Apple, GitHub)

## Notes
- Consider implementing Apple Sign In for iOS
- Monitor OAuth success rates
- Plan for OAuth token refresh strategy