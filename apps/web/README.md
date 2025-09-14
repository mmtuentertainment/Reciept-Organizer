# Receipt Organizer - Web Application

## 🔐 Authentication Setup

This Next.js application uses Supabase for authentication and user management.

### Prerequisites

- Node.js 18+
- npm or yarn
- Supabase account and project

### Environment Configuration

1. **Copy the environment template:**
   ```bash
   cp .env.local.example .env.local
   ```

2. **Configure your Supabase credentials:**

   Edit `.env.local` with your Supabase project details:

   ```env
   # Required: Your Supabase project URL
   NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co

   # Required: Your Supabase anonymous key (safe for browser)
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here

   # Optional: Session configuration
   NEXT_PUBLIC_SESSION_TIMEOUT_MINUTES=30
   NEXT_PUBLIC_SESSION_WARNING_MINUTES=5
   ```

3. **For production deployment, also set:**
   ```env
   # Server-side only (keep secret)
   SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here
   ```

### Getting Supabase Credentials

1. Go to your [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project
3. Navigate to Settings → API
4. Copy:
   - `URL` → `NEXT_PUBLIC_SUPABASE_URL`
   - `anon public` key → `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `service_role` key → `SUPABASE_SERVICE_ROLE_KEY` (production only)

### Database Setup

The application automatically creates required tables and policies on first user signup:

- `user_profiles` - Extended user information
- `categories` - Default expense categories
- `user_preferences` - User settings
- `feature_flags` - Feature toggle system

### Running the Application

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Run development server:**
   ```bash
   npm run dev
   ```

   The app will be available at http://localhost:3002

3. **Build for production:**
   ```bash
   npm run build
   npm start
   ```

## 🚀 Features

### Authentication Flows

- **Sign Up**: Email/password registration with email verification
- **Sign In**: Secure login with session management
- **Password Reset**: Email-based password recovery
- **Session Management**: Automatic session refresh and expiry handling
- **Protected Routes**: Middleware-based route protection

### Security Features

- Password strength validation (8+ chars, mixed case, numbers, special chars)
- Secure session cookies with httpOnly flag
- Row Level Security (RLS) policies in database
- Automatic session timeout with warning
- CSRF protection via Supabase

### User Interface

- Modern UI with shadcn/ui components
- Dark mode support
- Responsive design
- Real-time form validation
- Loading states and error handling
- Toast notifications for user feedback

## 📁 Project Structure

```
apps/web/
├── app/
│   ├── auth/          # Authentication pages
│   │   ├── login/
│   │   ├── signup/
│   │   ├── reset-password/
│   │   └── verify-email/
│   ├── dashboard/     # Protected user dashboard
│   └── layout.tsx     # Root layout
├── components/
│   ├── ui/           # shadcn/ui components
│   └── user-menu.tsx # User profile dropdown
├── lib/
│   └── supabase/     # Supabase client utilities
│       ├── client.ts  # Browser client
│       └── server.ts  # Server client
└── middleware.ts      # Route protection

```

## 🧪 Testing Authentication

### Manual Testing Checklist

1. **Sign Up Flow:**
   - [ ] Create account with valid email
   - [ ] Verify password strength indicator works
   - [ ] Check email verification sent
   - [ ] Confirm profile and categories created

2. **Sign In Flow:**
   - [ ] Login with valid credentials
   - [ ] Verify redirect to dashboard
   - [ ] Check session persistence
   - [ ] Test invalid credentials handling

3. **Password Reset:**
   - [ ] Request password reset
   - [ ] Verify email received
   - [ ] Complete reset flow
   - [ ] Login with new password

4. **Protected Routes:**
   - [ ] Access /dashboard without login (should redirect)
   - [ ] Access /auth/login when logged in (should redirect to dashboard)
   - [ ] Verify middleware protection works

### Test Accounts

For development, you can use test email addresses:
- Format: `test+{unique}@example.com`
- Example: `test+user1@example.com`

## 🔧 Troubleshooting

### Common Issues

1. **"Invalid API key" error:**
   - Verify your Supabase keys in `.env.local`
   - Ensure you're using the correct project URL

2. **Email verification not working:**
   - Check Supabase email settings in Dashboard → Authentication → Email Templates
   - Verify SMTP configuration for production

3. **Session not persisting:**
   - Check cookies are enabled in browser
   - Verify middleware.ts is properly configured
   - Ensure NEXT_PUBLIC_SUPABASE_URL uses https in production

4. **Build errors with Tailwind:**
   - Run `npm install` to ensure all dependencies are installed
   - Check `tailwind.config.ts` for proper configuration

## 🚦 Feature Flags

The application includes a feature flag system for safe rollbacks:

```typescript
// Check if a feature is enabled
const authEnabled = await supabase
  .from('feature_flags')
  .select('enabled')
  .eq('flag_name', 'auth_enabled')
  .single()
```

Available flags:
- `auth_enabled` - Toggle authentication system
- `auth_bypass_mode` - Skip auth for testing
- `auth_session_timeout` - Enable session timeout warnings

## 📝 Environment Variables Reference

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `NEXT_PUBLIC_SUPABASE_URL` | Yes | Your Supabase project URL | `https://abc.supabase.co` |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Yes | Public anonymous key | `eyJ...` |
| `SUPABASE_SERVICE_ROLE_KEY` | Production | Service role key (server-side only) | `eyJ...` |
| `NEXT_PUBLIC_SESSION_TIMEOUT_MINUTES` | No | Session timeout in minutes | `30` |
| `NEXT_PUBLIC_SESSION_WARNING_MINUTES` | No | Warning before timeout | `5` |

## 🔗 Related Documentation

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Next.js App Router](https://nextjs.org/docs/app)
- [shadcn/ui Components](https://ui.shadcn.com)
- [Supabase SSR Guide](https://supabase.com/docs/guides/auth/server-side-rendering)

## 📞 Support

For issues or questions:
1. Check the [Troubleshooting](#-troubleshooting) section
2. Review [Supabase Auth docs](https://supabase.com/docs/guides/auth)
3. Create an issue in the repository

---

*Last updated: January 2025*