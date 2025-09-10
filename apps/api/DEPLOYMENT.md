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
QB_CLIENT_ID=ABHeXjfhxPZWmMVLLKNFQ5BkThuwSmT8SeRkx1bJsX3Zcn5djW
QB_CLIENT_SECRET=IZD9kUK4lpRMnzIW3vQZXLE85TJkqtvJZVfoNQib
QB_REDIRECT_URI=https://YOUR-PROJECT.vercel.app/api/auth/quickbooks/callback

# Xero OAuth (Your Developer Credentials)
XERO_CLIENT_ID=F7E48B5BA8CC43F9AA035C7803EB1504
XERO_REDIRECT_URI=https://YOUR-PROJECT.vercel.app/api/auth/xero/callback

# Upstash Redis (Your Instance)
KV_REST_API_URL=https://star-finch-11621.upstash.io
KV_REST_API_TOKEN=AS1lAAIncDE2ZjE1N2JlNzkxYWQ0Y2ViODQ5MjU3ZmQ3N2VmMjViM3AxMTE2MjE
KV_REST_API_READ_ONLY_TOKEN=Ai1lAAIgcDHbgDmJm85yRFfMfwb3y9YnWszlW8J02MUJ67CzY4Kr1Q

# JWT Secret (PRODUCTION - Generated Securely)
JWT_SECRET=MJOyqf/tBV6d8DQQELZpXscd1vEasvZ/NDMes2cTEUQ=

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

## ⚠️ IMPORTANT NOTES

1. **Replace YOUR-PROJECT** with your actual Vercel project URL
2. **JWT_SECRET** is production-ready (generated with openssl)
3. **Upstash Redis** is already connected with your credentials
4. **OAuth credentials** are your actual developer account credentials

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
JWT Secret Generated: MJOyqf/tBV6d8DQQELZpXscd1vEasvZ/NDMes2cTEUQ=