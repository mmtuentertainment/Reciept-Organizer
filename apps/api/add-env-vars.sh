#!/bin/bash

echo "Adding environment variables to Vercel..."
echo ""
echo "Make sure you're logged in to Vercel CLI first!"
echo ""

# Add each environment variable
vercel env add QB_CLIENT_ID production < <(echo "***REMOVED***")
vercel env add QB_CLIENT_SECRET production < <(echo "***REMOVED***")
vercel env add QB_REDIRECT_URI production < <(echo "https://receipt-organizer-api.vercel.app/api/auth/quickbooks/callback")
vercel env add XERO_CLIENT_ID production < <(echo "***REMOVED***")
vercel env add XERO_REDIRECT_URI production < <(echo "https://receipt-organizer-api.vercel.app/api/auth/xero/callback")
vercel env add KV_REST_API_URL production < <(echo "https://star-finch-11621.upstash.io")
vercel env add KV_REST_API_TOKEN production < <(echo "***REMOVED***")
vercel env add KV_REST_API_READ_ONLY_TOKEN production < <(echo "***REMOVED***")
vercel env add JWT_SECRET production < <(echo "***REMOVED***")
vercel env add FLUTTER_APP_SCHEME production < <(echo "receiptorganizer")
vercel env add NEXT_PUBLIC_APP_URL production < <(echo "https://receipt-organizer-api.vercel.app")

echo ""
echo "Environment variables added!"
echo "Now run: vercel --prod to redeploy"