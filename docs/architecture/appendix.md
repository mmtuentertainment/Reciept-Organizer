# Appendix

### A. Platform-Specific Dependencies

#### Flutter
```yaml
dependencies:
  supabase_flutter: ^2.0.0
  flutter_secure_storage: ^9.0.0
  local_auth: ^2.1.0
  flutter_riverpod: ^2.4.0
```

#### Next.js
```json
{
  "dependencies": {
    "@supabase/ssr": "^0.1.0",
    "@supabase/supabase-js": "^2.39.0",
    "jose": "^5.2.0"
  }
}
```

#### React Native
```json
{
  "dependencies": {
    "@supabase/supabase-js": "^2.39.0",
    "expo-secure-store": "^12.8.0",
    "expo-local-authentication": "^13.8.0"
  }
}
```

### B. Configuration Templates

#### Environment Variables
```bash
# Supabase
SUPABASE_URL=https://xbadaalqaeszooyxuoac.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ... # Server-side only

# OAuth
GOOGLE_CLIENT_ID=<your-client-id-here>
GOOGLE_CLIENT_SECRET=<your-secret-here> # Server-side only

# Session Configuration
SESSION_TIMEOUT_WEB=1800        # 30 minutes
SESSION_TIMEOUT_MOBILE=7200     # 2 hours
SESSION_WARNING_BUFFER=300      # 5 minutes

# Security
ENABLE_BIOMETRIC=true
ENFORCE_MFA=false
MAX_LOGIN_ATTEMPTS=5
```

### C. Common Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Token refresh loop | Clock skew | Sync device time |
| Biometric not working | Permission denied | Request permission explicitly |
| Session lost on refresh | Cookie settings | Set SameSite=Lax |
| OAuth redirect fails | Wrong callback URL | Update Supabase dashboard |
| RLS blocking access | Missing user_id | Ensure migrations ran |
