# Story 1.6: User Profile Management

## Story Overview
**ID**: STORY-1.6
**Epic**: Phase 2 - Authentication & User Management
**Priority**: P2 - Medium
**Risk Level**: Low
**Estimated Points**: 5

**As an** authenticated user,
**I want** to manage my profile information,
**so that** I can personalize my account.

## Business Value
- Enhances user engagement and ownership
- Enables future personalization features
- Supports user identification in multi-user scenarios
- Provides foundation for social features

## Acceptance Criteria

### 1. Profile Screens
- [ ] Web: Create /settings/profile page with shadcn
- [ ] Flutter: Create profile screen with Material 3
- [ ] React Native: Create profile screen with NativeWind
- [ ] Consistent UX across all platforms
- [ ] Responsive design for various screen sizes

### 2. Editable Fields
- [ ] Username (unique, alphanumeric + underscore)
- [ ] Full name (optional)
- [ ] Website URL (optional, validated)
- [ ] Bio/Description (optional, 500 char limit)
- [ ] Display preferences (theme, language)

### 3. Avatar Upload
- [ ] Upload to Supabase Storage
- [ ] 5MB size limit enforcement
- [ ] Image format validation (jpg, png, webp)
- [ ] Automatic resizing to 200x200
- [ ] Default avatar generation from initials

### 4. Data Synchronization
- [ ] Real-time sync across platforms
- [ ] Optimistic UI updates
- [ ] Conflict resolution for concurrent edits
- [ ] Offline editing with sync queue
- [ ] Cache invalidation on updates

### 5. UI Components
- [ ] Use shadcn components for web via MCP
- [ ] Loading states during save
- [ ] Success/error notifications
- [ ] Form validation feedback
- [ ] Unsaved changes warning

## Technical Implementation

### Database Schema Update
```sql
-- Via mcp__supabase__apply_migration
-- Migration: 003_enhance_profiles.sql

ALTER TABLE profiles
ADD COLUMN bio TEXT CHECK (char_length(bio) <= 500),
ADD COLUMN theme VARCHAR(20) DEFAULT 'system',
ADD COLUMN language VARCHAR(10) DEFAULT 'en',
ADD COLUMN avatar_updated_at TIMESTAMPTZ;

-- Create storage bucket for avatars
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true);

-- RLS policy for avatar uploads
CREATE POLICY "Users can upload own avatar"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can update own avatar"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Avatars are publicly viewable"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');
```

### Web Implementation with shadcn
```typescript
// Get shadcn components
// mcp__shadcn__get_add_command_for_items([
//   "@shadcn/form",
//   "@shadcn/input",
//   "@shadcn/textarea",
//   "@shadcn/avatar",
//   "@shadcn/button",
//   "@shadcn/toast"
// ])

// app/settings/profile/page.tsx
import { createClient } from '@/lib/supabase/server';
import { ProfileForm } from '@/components/settings/profile-form';

export default async function ProfilePage() {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();

  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single();

  return (
    <div className="container max-w-2xl py-8">
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold">Profile Settings</h1>
          <p className="text-muted-foreground">
            Manage your account information and preferences
          </p>
        </div>

        <ProfileForm profile={profile} />
      </div>
    </div>
  );
}

// components/settings/profile-form.tsx
'use client';

import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { createClient } from '@/lib/supabase/client';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { useToast } from '@/components/ui/use-toast';

const profileSchema = z.object({
  username: z.string()
    .min(3, 'Username must be at least 3 characters')
    .max(30, 'Username must be less than 30 characters')
    .regex(/^[a-zA-Z0-9_]+$/, 'Username can only contain letters, numbers, and underscores'),
  full_name: z.string().max(100).optional(),
  website: z.string().url().optional().or(z.literal('')),
  bio: z.string().max(500).optional(),
});

export function ProfileForm({ profile }) {
  const [loading, setLoading] = useState(false);
  const [avatarUrl, setAvatarUrl] = useState(profile?.avatar_url);
  const { toast } = useToast();
  const supabase = createClient();

  const form = useForm({
    resolver: zodResolver(profileSchema),
    defaultValues: {
      username: profile?.username || '',
      full_name: profile?.full_name || '',
      website: profile?.website || '',
      bio: profile?.bio || '',
    },
  });

  const uploadAvatar = async (file: File) => {
    if (file.size > 5 * 1024 * 1024) {
      toast({
        title: 'Error',
        description: 'Avatar must be less than 5MB',
        variant: 'destructive',
      });
      return;
    }

    const fileExt = file.name.split('.').pop();
    const fileName = `${profile.id}/avatar.${fileExt}`;

    const { error: uploadError } = await supabase.storage
      .from('avatars')
      .upload(fileName, file, { upsert: true });

    if (uploadError) {
      toast({
        title: 'Upload failed',
        description: uploadError.message,
        variant: 'destructive',
      });
      return;
    }

    const { data: { publicUrl } } = supabase.storage
      .from('avatars')
      .getPublicUrl(fileName);

    setAvatarUrl(publicUrl);

    await supabase
      .from('profiles')
      .update({
        avatar_url: publicUrl,
        avatar_updated_at: new Date().toISOString(),
      })
      .eq('id', profile.id);

    toast({
      title: 'Success',
      description: 'Avatar updated successfully',
    });
  };

  const onSubmit = async (values: z.infer<typeof profileSchema>) => {
    setLoading(true);

    const { error } = await supabase
      .from('profiles')
      .update({
        ...values,
        updated_at: new Date().toISOString(),
      })
      .eq('id', profile.id);

    setLoading(false);

    if (error) {
      toast({
        title: 'Error',
        description: error.message,
        variant: 'destructive',
      });
    } else {
      toast({
        title: 'Success',
        description: 'Profile updated successfully',
      });
    }
  };

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
        {/* Avatar Upload */}
        <div className="flex items-center gap-6">
          <Avatar className="h-20 w-20">
            <AvatarImage src={avatarUrl} />
            <AvatarFallback>
              {profile?.full_name?.charAt(0) || profile?.email?.charAt(0)}
            </AvatarFallback>
          </Avatar>

          <div>
            <Label htmlFor="avatar">
              <Button type="button" variant="outline" asChild>
                <span>Change Avatar</span>
              </Button>
            </Label>
            <Input
              id="avatar"
              type="file"
              accept="image/*"
              className="hidden"
              onChange={(e) => {
                const file = e.target.files?.[0];
                if (file) uploadAvatar(file);
              }}
            />
            <p className="text-sm text-muted-foreground mt-1">
              JPG, PNG or WebP. Max 5MB.
            </p>
          </div>
        </div>

        {/* Form Fields */}
        <FormField
          control={form.control}
          name="username"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Username</FormLabel>
              <FormControl>
                <Input {...field} />
              </FormControl>
              <FormDescription>
                Your unique username across the platform
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />

        {/* Additional fields... */}

        <Button type="submit" disabled={loading}>
          {loading ? 'Saving...' : 'Save Changes'}
        </Button>
      </form>
    </Form>
  );
}
```

### Flutter Profile Screen
```dart
// lib/features/profile/screens/profile_screen.dart
class ProfileScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _websiteController = TextEditingController();
  final _bioController = TextEditingController();
  File? _avatarFile;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ref.read(profileServiceProvider).getProfile();
    if (profile != null) {
      _usernameController.text = profile.username ?? '';
      _fullNameController.text = profile.fullName ?? '';
      _websiteController.text = profile.website ?? '';
      _bioController.text = profile.bio ?? '';
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() => _avatarFile = File(image.path));
      await _uploadAvatar();
    }
  }

  Future<void> _uploadAvatar() async {
    if (_avatarFile == null) return;

    final bytes = await _avatarFile!.readAsBytes();
    if (bytes.length > 5 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Avatar must be less than 5MB')),
      );
      return;
    }

    final response = await ref.read(profileServiceProvider).uploadAvatar(
      _avatarFile!,
    );

    if (response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Avatar updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Settings'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _saveProfile,
            child: Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Avatar Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _avatarFile != null
                        ? FileImage(_avatarFile!)
                        : profile?.avatarUrl != null
                            ? NetworkImage(profile!.avatarUrl!)
                            : null,
                    child: _avatarFile == null && profile?.avatarUrl == null
                        ? Text(
                            profile?.fullName?.substring(0, 1) ?? 'U',
                            style: TextStyle(fontSize: 32),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton.filled(
                      onPressed: _pickAvatar,
                      icon: Icon(Icons.camera_alt, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Username Field
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
                helperText: 'Letters, numbers, and underscores only',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Username is required';
                }
                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                  return 'Invalid username format';
                }
                return null;
              },
            ),

            // Additional fields...
          ],
        ),
      ),
    );
  }
}
```

## Integration Verification

### IV1: Receipt Storage Unaffected
```sql
-- Via mcp__supabase__execute_sql
SELECT
  pg_size_pretty(pg_database_size('postgres')) as db_size,
  pg_size_pretty(pg_total_relation_size('receipts')) as receipts_size,
  pg_size_pretty(pg_total_relation_size('profiles')) as profiles_size;
-- Verify profiles table growth is reasonable
```

### IV2: Profile Changes Don't Break Auth
```typescript
test('Profile updates preserve auth session', async () => {
  const session = await signIn('test@example.com', 'password');

  await updateProfile({ username: 'newusername' });

  const { data: { session: newSession } } = await supabase.auth.getSession();
  expect(newSession).toBeDefined();
  expect(newSession.user.id).toBe(session.user.id);
});
```

### IV3: Image Upload Performance
```typescript
// Measure upload time
const startTime = Date.now();
await uploadAvatar(testFile); // 5MB file
const uploadTime = Date.now() - startTime;

expect(uploadTime).toBeLessThan(5000); // < 5 seconds
```

## Definition of Done
- [ ] Profile screens created on all platforms
- [ ] All fields editable and validated
- [ ] Avatar upload working with size limits
- [ ] Data syncs across platforms
- [ ] shadcn components integrated for web
- [ ] Loading states and notifications working
- [ ] Tests written and passing

## Dependencies
- Stories 1.0-1.2 complete (auth infrastructure)
- Supabase Storage bucket configured
- shadcn/ui components available
- Image processing libraries

## Risks & Mitigation
| Risk | Impact | Mitigation |
|------|--------|------------|
| Storage costs | Low | Implement quotas, cleanup old avatars |
| Username conflicts | Medium | Unique constraint, availability check |
| Large avatar uploads | Low | Client-side compression |

## Follow-up Stories
- Future: Social features (follow users)
- Future: Privacy settings
- Future: Account deletion

## Notes
- Consider CDN for avatar delivery
- Implement avatar caching strategy
- Monitor storage usage via MCP