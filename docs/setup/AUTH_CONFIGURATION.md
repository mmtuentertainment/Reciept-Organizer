# Authentication Configuration Guide

## ✅ What's Already Done

1. **Flutter App Implementation**:
   - Login screen (`lib/features/auth/screens/login_screen.dart`)
   - Sign up screen (`lib/features/auth/screens/signup_screen.dart`)
   - Auth provider with state management (`lib/features/auth/providers/auth_provider.dart`)
   - Auth guard for protected routes (`lib/features/auth/widgets/auth_guard.dart`)
   - User menu in home screen with sign out
   - Integration with main app

2. **Database Schema**:
   - `user_profiles` table created
   - RLS policies configured
   - Auth triggers set up

## 📋 Required: Configure in Supabase Dashboard

### Step 1: Enable Email Authentication

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project: `yxpkogyljbvbkipiephe`
3. Navigate to **Authentication** → **Providers**
4. Click on **Email** provider
5. Configure these settings:
   ```
   ✅ Enable Email provider
   ✅ Confirm email (recommended for production)
   ☐ Secure email change (optional)
   ☐ Secure password change (optional)
   ```
6. Click **Save**

### Step 2: Configure Email Templates (Optional but Recommended)

1. Go to **Authentication** → **Email Templates**
2. Customize these templates:
   - **Confirm signup**: Email sent to verify new accounts
   - **Reset password**: Email for password recovery
   - **Magic Link**: For passwordless login (if enabled)

3. Example confirmation template:
   ```html
   <h2>Welcome to Receipt Organizer!</h2>
   <p>Thanks for signing up. Please confirm your email:</p>
   <p><a href="{{ .ConfirmationURL }}">Confirm Email</a></p>
   ```

### Step 3: Configure Authentication Settings

1. Go to **Authentication** → **Settings**
2. Configure these options:
   ```
   Site URL: http://localhost:3000 (for development)
   Redirect URLs: 
   - http://localhost:3000/*
   - io.supabase.receiptorganizer://login-callback/
   - com.receiptorganizer.app://login-callback/
   
   JWT Expiry: 3600 (1 hour)
   Auto-confirm Users: OFF (for production)
   ```

### Step 4: Enable Google OAuth (Optional)

1. Get OAuth credentials from [Google Cloud Console](https://console.cloud.google.com):
   - Create a new project or select existing
   - Enable Google+ API
   - Create OAuth 2.0 credentials
   - Add authorized redirect URIs:
     ```
     https://yxpkogyljbvbkipiephe.supabase.co/auth/v1/callback
     ```

2. In Supabase Dashboard:
   - Go to **Authentication** → **Providers**
   - Click on **Google**
   - Enable the provider
   - Add your Client ID and Client Secret
   - Save

### Step 5: Test Authentication Flow

1. **Test Sign Up**:
   ```dart
   // In Flutter debug console or test file
   final service = SupabaseService.instance;
   await service.signUpWithEmail(
     email: 'test@example.com',
     password: 'TestPassword123!',
   );
   ```

2. **Check Email**: 
   - Look for confirmation email
   - Click the confirmation link

3. **Test Sign In**:
   ```dart
   await service.signInWithEmail(
     email: 'test@example.com',
     password: 'TestPassword123!',
   );
   ```

## 🧪 Testing in the App

1. **Run the Flutter app**:
   ```bash
   cd apps/mobile
   flutter run
   ```

2. **Test Sign Up Flow**:
   - Tap "Sign Up" on login screen
   - Fill in the form with valid data
   - Submit and check for confirmation email
   - Verify email shows in Supabase Dashboard under **Authentication** → **Users**

3. **Test Sign In Flow**:
   - Enter credentials on login screen
   - Should navigate to home screen on success
   - Check user avatar/initial in app bar

4. **Test Sign Out**:
   - Click user avatar in app bar
   - Select "Sign Out"
   - Should return to login screen

5. **Test Offline Mode**:
   - On login screen, tap "Skip for now (Offline Mode)"
   - Should access app without authentication
   - Real-time sync will be disabled

## 🔒 Security Checklist

- [ ] Email confirmation enabled for production
- [ ] Strong password requirements enforced
- [ ] Rate limiting configured
- [ ] RLS policies tested and working
- [ ] Service role key NOT exposed in client
- [ ] Redirect URLs properly configured
- [ ] JWT expiry set appropriately

## 🐛 Troubleshooting

### "Email not confirmed" error
- Check spam folder for confirmation email
- Resend confirmation from Supabase Dashboard
- Temporarily enable auto-confirm for testing

### "Invalid login credentials"
- Verify email is confirmed
- Check password meets requirements
- Ensure user exists in dashboard

### OAuth redirect issues
- Verify redirect URLs in both Google Console and Supabase
- Check URL scheme for mobile apps
- Ensure proper deep linking configuration

## 📱 Mobile-Specific Setup

### iOS (info.plist)
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>io.supabase.receiptorganizer</string>
    </array>
  </dict>
</array>
```

### Android (AndroidManifest.xml)
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="io.supabase.receiptorganizer" />
</intent-filter>
```

## ✅ Next Steps

After configuring authentication:

1. **Enable providers in dashboard** (Email is minimum requirement)
2. **Test the complete auth flow**
3. **Configure email templates** for better UX
4. **Set up OAuth providers** if desired
5. **Test on actual devices** (iOS/Android)
6. **Configure production URLs** before deployment

## 📚 Resources

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Flutter Supabase Auth Guide](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [OAuth Setup Guide](https://supabase.com/docs/guides/auth/social-login)
- [RLS with Auth](https://supabase.com/docs/guides/auth/row-level-security)