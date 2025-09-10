# 🚀 Production Deployment Guide

## Quick Deploy Command
```bash
cd /home/matt/FINAPP/Receipt\ Organizer/apps/api
vercel --prod
```

## 📋 Environment Variables for Vercel Dashboard

Copy these EXACT values to your Vercel project settings:

```env
# QuickBooks OAuth (Your Developer Credentials)
QB_CLIENT_ID=<YOUR_QB_CLIENT_ID_FROM_DEVELOPER_DASHBOARD>
QB_CLIENT_SECRET=<YOUR_QB_CLIENT_SECRET_FROM_DEVELOPER_DASHBOARD>
QB_REDIRECT_URI=https://YOUR-PROJECT.vercel.app/api/auth/quickbooks/callback

# Xero OAuth (Your Developer Credentials)
XERO_CLIENT_ID=<YOUR_XERO_CLIENT_ID_FROM_DEVELOPER_PORTAL>
XERO_REDIRECT_URI=https://YOUR-PROJECT.vercel.app/api/auth/xero/callback

# Upstash Redis (Your Instance)
KV_REST_API_URL=<YOUR_UPSTASH_REDIS_URL>
KV_REST_API_TOKEN=<YOUR_UPSTASH_REST_API_TOKEN>
KV_REST_API_READ_ONLY_TOKEN=<YOUR_UPSTASH_READ_ONLY_TOKEN>

# JWT Secret (Generate with: openssl rand -base64 32)
JWT_SECRET=<GENERATE_NEW_SECRET_WITH_OPENSSL>

# App Configuration
FLUTTER_APP_SCHEME=receiptorganizer
NEXT_PUBLIC_APP_URL=https://YOUR-PROJECT.vercel.app
```

## 🔄 Update OAuth Apps

### QuickBooks Developer Dashboard
1. Go to: https://developer.intuit.com/app/developer/dashboard
2. Select your app
3. Update Redirect URI to: `https://YOUR-PROJECT.vercel.app/api/auth/quickbooks/callback`
4. Save changes

### Xero Developer Portal
1. Go to: https://developer.xero.com/myapps
2. Select your app
3. Update Redirect URI to: `https://YOUR-PROJECT.vercel.app/api/auth/xero/callback`
4. Save changes

## 📱 Update Flutter App

### 1. Update API Base URLs

Edit `/home/matt/FINAPP/Receipt Organizer/apps/mobile/lib/features/export/services/quickbooks_api_service.dart`:
```dart
// Line 15 - Update to your Vercel URL
static const String _baseUrl = 'https://YOUR-PROJECT.vercel.app';
```

Edit `/home/matt/FINAPP/Receipt Organizer/apps/mobile/lib/features/export/services/xero_api_service.dart`:
```dart
// Line 15 - Update to your Vercel URL
static const String _baseUrl = 'https://YOUR-PROJECT.vercel.app';
```

### 2. Rebuild Flutter App
```bash
cd /home/matt/FINAPP/Receipt\ Organizer/apps/mobile
flutter pub get
flutter build apk  # For Android
flutter build ios  # For iOS
```

## ✅ Verification Checklist

After deployment, verify everything works:

- [ ] Vercel deployment successful
- [ ] Environment variables set in Vercel dashboard
- [ ] QuickBooks redirect URI updated
- [ ] Xero redirect URI updated
- [ ] Flutter app base URLs updated
- [ ] Test QuickBooks OAuth flow
- [ ] Test Xero OAuth flow
- [ ] Test receipt validation

## 🔍 Test Production Endpoints

Once deployed, test with:

```bash
# Update test script with production URL
curl https://YOUR-PROJECT.vercel.app/api/auth/quickbooks
curl https://YOUR-PROJECT.vercel.app/api/auth/xero
```

## ⚠️ IMPORTANT SECURITY NOTES

1. **NEVER commit real credentials** - Always use placeholders in documentation
2. **Replace YOUR-PROJECT** with your actual Vercel project URL
3. **Generate JWT_SECRET** securely: `openssl rand -base64 32`
4. **Store all secrets in Vercel Dashboard** - Never in code or documentation
5. **Rotate credentials regularly** - Especially if exposed

## 🆘 Troubleshooting

### OAuth callback fails
- Ensure redirect URIs match EXACTLY (including https://)
- Check Vercel logs: `vercel logs`

### Validation returns 401
- Verify JWT_SECRET matches in Vercel env vars
- Check session token expiration

### Redis connection issues
- Verify Upstash credentials in Vercel dashboard
- Check Redis dashboard at: https://console.upstash.com

## 📊 Monitor Usage

- **Vercel Dashboard**: https://vercel.com/dashboard
- **Upstash Console**: https://console.upstash.com
- **QuickBooks API**: Check rate limits in developer dashboard
- **Xero API**: Monitor 5,000 daily call limit

---
Last Updated: 2025-09-10
