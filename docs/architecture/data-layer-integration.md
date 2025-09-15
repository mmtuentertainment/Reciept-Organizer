# Data Layer Integration

### RLS Policy Implementation

```sql
-- User isolation for receipts
CREATE POLICY "Users can only see own receipts" ON receipts
  FOR ALL USING (auth.uid() = user_id);

-- Profile access
CREATE POLICY "Users can view all profiles" ON profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Storage access
CREATE POLICY "Avatar images are publicly accessible" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload own avatar" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
```

### User Context Propagation

```typescript
// middleware.ts (Next.js)
export async function middleware(req: NextRequest) {
  const res = NextResponse.next();
  const supabase = createServerClient(req, res);

  const { data: { session } } = await supabase.auth.getSession();

  if (!session && protectedRoutes.includes(req.nextUrl.pathname)) {
    return NextResponse.redirect(new URL('/login', req.url));
  }

  // Add user context to headers for downstream services
  if (session) {
    res.headers.set('X-User-Id', session.user.id);
    res.headers.set('X-User-Email', session.user.email || '');
  }

  return res;
}
```
