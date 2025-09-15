# Security Configuration

## ⚠️ CRITICAL: Environment Variables Required

This application requires environment variables for all sensitive configuration. **NEVER hardcode credentials in source code!**

## Setting Up Environment Variables

### React Native (Expo)
1. Copy `apps/native/.env.example` to `apps/native/.env.local`
2. Fill in your actual values
3. **NEVER commit `.env.local` to version control**

```bash
# Required environment variables:
EXPO_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
EXPO_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
EXPO_PUBLIC_GOOGLE_VISION_API_KEY=your-google-api-key-here
```

### Flutter
Use `--dart-define` flags when building or running:

```bash
# Development
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=GOOGLE_VISION_API_KEY=your-api-key

# Production Build
flutter build apk \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=GOOGLE_VISION_API_KEY=your-api-key
```

### Next.js Web App
1. Copy `apps/web/.env.example` to `apps/web/.env.local`
2. Fill in your actual values
3. **NEVER commit `.env.local` to version control**

## Security Best Practices

### 1. API Keys
- **Google Vision API Key**: Keep secret, regenerate if exposed
- **Supabase Anon Key**: While designed to be public (RLS-protected), still use env vars
- **Service Keys**: NEVER commit service/admin keys

### 2. Git Security
- All `.env` files are in `.gitignore`
- Review commits before pushing
- Use `git secrets` or similar tools

### 3. If Keys Are Exposed
1. **Immediately** regenerate the exposed keys
2. Update all environments with new keys
3. Review access logs for unauthorized use
4. Consider using `git filter-branch` to remove from history

### 4. Supabase Row Level Security (RLS)
- All tables have RLS policies enabled
- Users can only access their own data
- Anonymous users have limited access
- Admin operations require service key (never expose)

## Reporting Security Issues

If you discover a security vulnerability, please:
1. **DO NOT** create a public issue
2. Email security concerns to the maintainers
3. Allow time for a patch before disclosure

## Validation

The app will fail fast if environment variables are missing:
- React Native: Error thrown in `lib/supabase.ts`
- Flutter: Exception in `SupabaseConfig.initialize()`
- Next.js: Build-time validation

This ensures credentials are never accidentally hardcoded.