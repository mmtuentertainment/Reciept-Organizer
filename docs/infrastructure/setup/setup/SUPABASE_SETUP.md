# Supabase Setup Guide for Receipt Organizer

## Prerequisites
- Supabase account (already created ✅)
- Vercel account (already created ✅)
- Flutter development environment
- Node.js 18+ for API development

## Step 1: Create Supabase Project

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Click "New Project"
3. Configure project:
   - **Name**: `receipt-organizer-dev` (or your preference)
   - **Database Password**: Generate a strong password and save it securely
   - **Region**: Choose closest to your users
   - **Pricing Plan**: Free tier is fine for development

4. Wait for project provisioning (~2 minutes)

## Step 2: Configure Database Schema

1. In Supabase Dashboard, go to **SQL Editor**
2. Create a new query
3. Copy and paste the contents of `/infrastructure/supabase/schema.sql`
4. Click **Run** to create all tables, indexes, and RLS policies
5. Verify tables created in **Table Editor**

## Step 3: Setup Storage Buckets

1. Go to **Storage** in Supabase Dashboard
2. Go to **SQL Editor** again
3. Copy and paste contents of `/infrastructure/supabase/storage.sql`
4. Click **Run** to create storage buckets and policies
5. Verify buckets in **Storage** section:
   - `receipts` - For receipt images
   - `thumbnails` - For image thumbnails
   - `exports` - For CSV export files

## Step 4: Configure Authentication

1. Go to **Authentication** → **Providers**
2. Enable **Email** provider:
   - Enable email confirmations (recommended)
   - Configure email templates if desired

3. Enable **Google** OAuth (optional):
   - Get OAuth credentials from [Google Cloud Console](https://console.cloud.google.com)
   - Add authorized redirect URLs:
     ```
     https://your-project-id.supabase.co/auth/v1/callback
     io.supabase.receiptorganizer://login-callback/
     ```

4. Enable **Apple** OAuth (optional for iOS):
   - Configure in Apple Developer Console
   - Add Service ID and keys

## Step 5: Get API Keys

1. Go to **Settings** → **API**
2. Copy these values to your `.env.local`:
   - **Project URL**: `SUPABASE_URL`
   - **Anon/Public Key**: `SUPABASE_ANON_KEY`
   - **Service Role Key**: `SUPABASE_SERVICE_KEY` (keep very secure!)

## Step 6: Configure Flutter App

1. Add Supabase dependencies to `pubspec.yaml`:
   ```yaml
   dependencies:
     supabase_flutter: ^2.10.0
     flutter_dotenv: ^6.0.0
   ```

2. Create environment file `.env.local`:
   ```bash
   cd apps/mobile
   cp .env.example .env.local  # or create new file
   ```

3. Edit `.env.local` with your Supabase credentials:
   ```env
   # Supabase Configuration
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   # IMPORTANT: Never commit the service key to git - only use in server-side code
   
   # API Configuration (for Next.js backend)
   API_BASE_URL=https://your-api.vercel.app
   
   # Environment
   ENVIRONMENT=development
   
   # Feature Flags
   ENABLE_CLOUD_SYNC=true
   ENABLE_REALTIME=true
   ```

4. Initialize Supabase in `main.dart`:
   ```dart
   import 'package:flutter/material.dart';
   import 'package:supabase_flutter/supabase_flutter.dart';
   import 'package:flutter_dotenv/flutter_dotenv.dart';
   
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     
     // Initialize Supabase
     try {
       // Load environment variables
       await dotenv.load(fileName: '.env.local');
       
       // Initialize Supabase with credentials
       await Supabase.initialize(
         url: dotenv.env['SUPABASE_URL'] ?? 'fallback-url',
         anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'fallback-key',
         authOptions: const FlutterAuthClientOptions(
           authFlowType: AuthFlowType.pkce,
           autoRefreshToken: true,
         ),
       );
       print('✅ Supabase initialized successfully');
     } catch (e) {
       print('⚠️ Failed to initialize Supabase: $e');
       // Continue without Supabase for local-only mode
     }
     
     runApp(const MyApp());
   }
   ```

5. Create Supabase service wrapper at `lib/core/services/supabase_service.dart`:
   ```dart
   import 'package:supabase_flutter/supabase_flutter.dart';
   import 'package:flutter/foundation.dart';
   
   class SupabaseService {
     static SupabaseService? _instance;
     
     SupabaseService._();
     
     static SupabaseService get instance {
       _instance ??= SupabaseService._();
       return _instance!;
     }
     
     // Get the Supabase client instance
     SupabaseClient get client => Supabase.instance.client;
     
     // Check if user is authenticated
     bool get isAuthenticated => client.auth.currentUser != null;
     
     // Get current user
     User? get currentUser => client.auth.currentUser;
     
     // Additional methods for auth, CRUD, real-time subscriptions...
   }
   ```

## Step 7: Configure Vercel API

1. Go to your Next.js API directory:
   ```bash
   cd apps/api
   ```

2. Create `.env.local`:
   ```env
   NEXT_PUBLIC_SUPABASE_URL=https://your-project-id.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
   SUPABASE_SERVICE_KEY=your-service-key
   ```

3. Deploy to Vercel:
   ```bash
   vercel --prod
   ```

4. Add environment variables in Vercel Dashboard:
   - Go to Project Settings → Environment Variables
   - Add all variables from `.env.local`

## Step 8: Test the Setup

### Test Database Connection
```sql
-- In SQL Editor
SELECT * FROM public.user_profiles;
```

### Test Storage
1. Go to Storage → receipts bucket
2. Try uploading a test image
3. Check if RLS policies work

### Test Auth
1. In Flutter app, try:
   ```dart
   // Get the service instance
   final supabaseService = SupabaseService.instance;
   
   // Sign up a new user
   final response = await supabaseService.signUpWithEmail(
     email: 'test@example.com',
     password: 'TestPassword123!',
   );
   
   // Or sign in an existing user
   final signInResponse = await supabaseService.signInWithEmail(
     email: 'test@example.com',
     password: 'TestPassword123!',
   );
   
   // Check authentication status
   if (supabaseService.isAuthenticated) {
     print('User is logged in: ${supabaseService.currentUser?.email}');
   }
   ```

### Test Realtime (Optional)
1. Open two SQL Editor tabs
2. In one, subscribe to changes:
   ```sql
   -- This would be done in Flutter, but you can test in SQL Editor
   SELECT * FROM public.receipts WHERE user_id = 'your-user-id';
   ```
3. In another, insert a receipt
4. Verify realtime update

## Step 9: Migration from SQLite (Optional)

If you have existing SQLite data:

1. Export SQLite data to JSON format
2. Use migration function:
   ```sql
   SELECT * FROM import_receipts_from_json(
     'user-uuid'::UUID,
     'your-json-data'::JSONB
   );
   ```

## Step 10: Setup Monitoring

1. Go to **Reports** in Supabase Dashboard
2. Monitor:
   - Database performance
   - Storage usage
   - Auth events
   - API usage

## Environment Variables Summary

### Flutter App (`.env.local`)
```env
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=xxx
API_BASE_URL=https://your-api.vercel.app
```

### Next.js API (`.env.local`)
```env
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=xxx
SUPABASE_SERVICE_KEY=xxx
```

## Troubleshooting

### Connection Issues
- Check if project is running (not paused)
- Verify API keys are correct
- Check network/firewall settings

### RLS Policy Issues
- Ensure user is authenticated
- Check policy definitions
- Use service role key for admin operations

### Storage Issues
- Verify bucket policies
- Check file size limits
- Ensure correct MIME types

## Next Steps

1. ✅ Setup development projects in Supabase and Vercel
2. ✅ Configure environment variables for both platforms
3. ✅ Create PostgreSQL schema in Supabase (T2.1)
4. ✅ Setup storage buckets for receipt images (T2.1)
5. ✅ Configure authentication providers (T2.2)
6. ✅ Deploy Next.js API to Vercel (T2.3)
7. ✅ Setup real-time subscriptions (T2.4)
8. ✅ Implement Riverpod providers for sync
9. ✅ Add presence tracking for multi-device awareness
10. ⏭️ Implement user authentication flow
11. ⏭️ Add receipt upload to Supabase storage
12. ⏭️ Enable offline-to-online sync

## Real-time Sync Implementation

### Riverpod Providers

The app includes comprehensive real-time synchronization:

1. **RealtimeSyncProvider** (`lib/features/receipts/providers/realtime_sync_provider.dart`)
   - Manages real-time receipt synchronization
   - Handles INSERT, UPDATE, DELETE events
   - Tracks sync status and pending changes
   - Provides force sync capability

2. **PresenceProvider** (`lib/features/receipts/providers/presence_provider.dart`)
   - Tracks active devices and users
   - Shows device platform and last seen time
   - Enables multi-device awareness

3. **SyncStatusWidget** (`lib/features/receipts/widgets/sync_status_widget.dart`)
   - Visual sync status indicator
   - Shows connection state and active devices
   - Quick actions for reconnect and force sync

### Using Real-time Features

```dart
// In your widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Auto-initialize sync
    ref.watch(realtimeSyncInitializerProvider);
    ref.watch(presenceInitializerProvider);
    
    // Get sync state
    final syncState = ref.watch(realtimeSyncProvider);
    
    if (syncState.isConnected) {
      // Show online features
    }
  }
}
```

## Security Best Practices

1. **Never expose service keys**:
   - Service keys should only be used server-side
   - Never commit them to git
   - Never use in Flutter app

2. **Use Row Level Security (RLS)**:
   - All tables have RLS policies enabled
   - Users can only access their own data
   - Admin operations require service role

3. **Environment Variables**:
   - Keep all keys in `.env.local`
   - Add to `.gitignore`
   - Use different keys for dev/prod

4. **Authentication**:
   - Always check `isAuthenticated` before operations
   - Handle auth errors gracefully
   - Implement proper session management

## Production Checklist

- [ ] Create separate Supabase project for production
- [ ] Enable email verification for auth
- [ ] Configure custom SMTP for emails
- [ ] Set up database backups
- [ ] Configure rate limiting
- [ ] Enable query performance monitoring
- [ ] Set up error tracking (Sentry)
- [ ] Configure CDN for storage
- [ ] Review and tighten RLS policies
- [ ] Enable SSL enforcement
- [ ] Set up monitoring alerts
- [ ] Document API rate limits

## Resources

- [Supabase Docs](https://supabase.com/docs)
- [Supabase Flutter Guide](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
- [RLS Policies Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Storage Guide](https://supabase.com/docs/guides/storage)
- [Realtime Guide](https://supabase.com/docs/guides/realtime)
- [Production Checklist](https://supabase.com/docs/guides/platform/going-into-prod)
