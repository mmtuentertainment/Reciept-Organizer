# Supabase Setup Guide

## Security Note
The keys in the code are **DEFAULT LOCAL DEVELOPMENT KEYS** that come with every Supabase local installation. They are:
- **PUBLIC** and documented in Supabase docs
- **SAFE** for local development only
- **NOT REAL SECRETS**

For production, you MUST use environment variables.

## Local Development Setup

1. **Install Supabase CLI**:
```bash
# macOS/Linux
brew install supabase/tap/supabase

# Or using npm
npm install -g supabase
```

2. **Start Local Supabase**:
```bash
cd infrastructure/supabase
supabase start
```

This will give you:
- API URL: `http://localhost:54321`
- Anon Key: (the default local key)
- Service Key: (for admin operations)

3. **Run Migrations**:
```bash
supabase db push
```

## Production Setup

1. **Create Supabase Project**:
   - Go to https://supabase.com
   - Create new project
   - Save your project URL and anon key

2. **Configure Environment Variables**:
```bash
# Copy the example file
cp apps/mobile/.env.example apps/mobile/.env

# Edit with your values
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

3. **Run Flutter with Environment Variables**:
```bash
flutter run --dart-define-from-file=.env
```

Or for builds:
```bash
flutter build apk --dart-define-from-file=.env
```

## Security Best Practices

1. **Never commit .env files** - Already in .gitignore
2. **Use Row Level Security (RLS)** - Already configured in migrations
3. **Rotate keys regularly** in production
4. **Use service keys only on backend** - Never in mobile apps
5. **Enable 2FA** on your Supabase account

## Migration Management

```bash
# Create new migration
supabase migration new migration_name

# Apply migrations
supabase db push

# Reset database (dev only!)
supabase db reset
```

## Environment Variables

### Required for Production:
- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Public anon key (safe to use in client apps)

### Never Use in Client Apps:
- `SUPABASE_SERVICE_KEY`: Admin key (backend only!)
- Database connection strings
- JWT secrets