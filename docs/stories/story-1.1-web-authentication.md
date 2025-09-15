# Story 1.1: Web Authentication Enhancement

## Story Overview
**ID**: STORY-1.1
**Epic**: Phase 2 - Authentication & User Management
**Priority**: P0 - Critical
**Risk Level**: Low (Web platform is most stable)
**Estimated Points**: 8

**As a** web user,
**I want** to log in and sign up through the Next.js app,
**so that** my receipts are securely associated with my account.

## Business Value
- Establishes foundation for multi-user support
- Enables secure data isolation per user
- Provides basis for premium features and user-specific settings
- Web implementation serves as reference for mobile platforms

## Acceptance Criteria

### 1. Login/Signup Pages
- [ ] Create /auth/login route with shadcn/ui form
- [ ] Create /auth/signup route with shadcn/ui form
- [ ] Implement email validation
- [ ] Add password strength indicator
- [ ] Include "Remember me" checkbox
- [ ] Add terms acceptance for signup

### 2. Supabase Auth Integration
- [ ] Configure Supabase client with cookie storage
- [ ] Implement signIn with email/password
- [ ] Implement signUp with email confirmation
- [ ] Add session refresh logic
- [ ] Configure 30-minute timeout for web

### 3. Password Reset Flow
- [ ] Create /auth/forgot-password page
- [ ] Implement password reset email trigger
- [ ] Create /auth/reset-password page
- [ ] Validate reset tokens
- [ ] Show success confirmation

### 4. Session Persistence
- [ ] Implement HttpOnly secure cookies
- [ ] Add CSRF protection
- [ ] Ensure session syncs across tabs
- [ ] Handle session expiry gracefully
- [ ] Implement "Stay logged in" option

### 5. User Menu Integration
- [ ] Add avatar/initial display to header
- [ ] Create dropdown with profile, settings, logout
- [ ] Show user email in menu
- [ ] Add loading states during auth operations
- [ ] Implement logout confirmation

## Technical Implementation

### shadcn/ui Components Setup
```bash
# Install required shadcn components via MCP
mcp__shadcn__get_add_command_for_items([
  "@shadcn/form",
  "@shadcn/input",
  "@shadcn/button",
  "@shadcn/card",
  "@shadcn/dropdown-menu",
  "@shadcn/avatar",
  "@shadcn/alert",
  "@shadcn/toast"
])
```

### Login Page Implementation
```typescript
// app/auth/login/page.tsx
import { createClient } from '@/lib/supabase/server';
import { LoginForm } from '@/components/auth/login-form';

export default function LoginPage() {
  return (
    <div className="flex min-h-screen items-center justify-center">
      <Card className="w-full max-w-md">
        <CardHeader>
          <CardTitle>Welcome Back</CardTitle>
          <CardDescription>
            Sign in to access your receipts
          </CardDescription>
        </CardHeader>
        <CardContent>
          <LoginForm />
        </CardContent>
        <CardFooter>
          <p className="text-sm text-muted-foreground">
            Don't have an account?{' '}
            <Link href="/auth/signup" className="text-primary">
              Sign up
            </Link>
          </p>
        </CardFooter>
      </Card>
    </div>
  );
}
```

### Server-Side Auth Handler
```typescript
// app/api/auth/login/route.ts
import { createClient } from '@/lib/supabase/server';
import { cookies } from 'next/headers';

export async function POST(request: Request) {
  const { email, password, rememberMe } = await request.json();
  const supabase = createClient();

  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) {
    return Response.json({ error: error.message }, { status: 401 });
  }

  // Set cookie with appropriate expiry
  const cookieStore = cookies();
  const maxAge = rememberMe ? 60 * 60 * 24 * 7 : 60 * 30; // 7 days or 30 min

  cookieStore.set('sb-access-token', data.session.access_token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    maxAge
  });

  return Response.json({ user: data.user });
}
```

### Session Management Middleware
```typescript
// middleware.ts
import { createMiddlewareClient } from '@supabase/auth-helpers-nextjs';
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export async function middleware(req: NextRequest) {
  const res = NextResponse.next();
  const supabase = createMiddlewareClient({ req, res });

  const { data: { session } } = await supabase.auth.getSession();

  // Protected routes
  const protectedPaths = ['/dashboard', '/receipts', '/settings'];
  const isProtected = protectedPaths.some(path =>
    req.nextUrl.pathname.startsWith(path)
  );

  if (isProtected && !session) {
    return NextResponse.redirect(new URL('/auth/login', req.url));
  }

  // Check for timeout (30 minutes)
  if (session) {
    const lastActivity = req.cookies.get('last-activity')?.value;
    const now = Date.now();

    if (lastActivity && now - parseInt(lastActivity) > 30 * 60 * 1000) {
      await supabase.auth.signOut();
      return NextResponse.redirect(new URL('/auth/login?timeout=true', req.url));
    }

    res.cookies.set('last-activity', now.toString());
  }

  return res;
}
```

### User Menu Component
```typescript
// components/layout/user-menu.tsx
import { createClient } from '@/lib/supabase/client';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';

export function UserMenu({ user }: { user: User }) {
  const supabase = createClient();

  const handleLogout = async () => {
    if (confirm('Are you sure you want to log out?')) {
      await supabase.auth.signOut();
      window.location.href = '/auth/login';
    }
  };

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" className="relative h-8 w-8 rounded-full">
          <Avatar className="h-8 w-8">
            <AvatarImage src={user.avatar_url} />
            <AvatarFallback>
              {user.email?.charAt(0).toUpperCase()}
            </AvatarFallback>
          </Avatar>
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent className="w-56" align="end" forceMount>
        <DropdownMenuItem className="font-normal">
          <div className="flex flex-col space-y-1">
            <p className="text-sm font-medium">{user.full_name}</p>
            <p className="text-xs text-muted-foreground">{user.email}</p>
          </div>
        </DropdownMenuItem>
        <DropdownMenuSeparator />
        <DropdownMenuItem asChild>
          <Link href="/settings/profile">Profile</Link>
        </DropdownMenuItem>
        <DropdownMenuItem asChild>
          <Link href="/settings">Settings</Link>
        </DropdownMenuItem>
        <DropdownMenuSeparator />
        <DropdownMenuItem onClick={handleLogout}>
          Log out
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
```

## Integration Verification

### IV1: Existing Features Remain Functional
```typescript
// Run existing feature tests
npm run test:e2e -- --grep "dashboard|receipts|export"
// All tests should pass
```

### IV2: Cookie-Based Auth with SSR
```typescript
// Test server-side rendering with auth
const response = await fetch('/api/receipts', {
  headers: { Cookie: 'sb-access-token=...' }
});
expect(response.status).toBe(200);
```

### IV3: Performance Metrics
```bash
# Measure page load with auth
npm run lighthouse -- --only-categories=performance

# Target metrics:
# - First Contentful Paint: < 1.5s
# - Time to Interactive: < 2s
# - Total Blocking Time: < 300ms
```

## Definition of Done
- [ ] All auth pages created and styled with shadcn/ui
- [ ] Supabase auth fully integrated with cookies
- [ ] Password reset flow working end-to-end
- [ ] Session management with 30-minute timeout
- [ ] User menu integrated into header
- [ ] All existing features still working
- [ ] Performance targets met
- [ ] Unit tests written (>80% coverage)
- [ ] E2E tests for auth flows

## Dependencies
- Story 1.0 (Testing Infrastructure) must be complete
- shadcn/ui components available via MCP
- Supabase project configured
- Next.js 14+ with App Router

## Risks & Mitigation
| Risk | Impact | Mitigation |
|------|--------|------------|
| Cookie security issues | High | Use HttpOnly, Secure, SameSite |
| Session sync problems | Medium | Implement broadcast channel API |
| Performance degradation | Low | Lazy load auth components |

## Follow-up Stories
- Story 1.2: Database RLS and Migration Setup
- Story 1.3: Mobile (Flutter) Authentication
- Story 1.5: Google OAuth Integration

## Notes
- Consider implementing rate limiting for auth endpoints
- Monitor failed login attempts via MCP logs
- Plan for email verification in future iteration