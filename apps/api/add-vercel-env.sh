#!/bin/bash

echo "Adding environment variables to Vercel..."
echo "You'll need to paste each value when prompted"
echo ""

# Add for all environments (development, preview, production)
echo "1. Adding JWT_SECRET..."
vercel env add JWT_SECRET

echo "2. Adding QB_CLIENT_ID..."
vercel env add QB_CLIENT_ID

echo "3. Adding QB_CLIENT_SECRET..."
vercel env add QB_CLIENT_SECRET

echo "4. Adding QB_REDIRECT_URI (use: https://receipt-organizer-api.vercel.app/api/auth/quickbooks/callback)..."
vercel env add QB_REDIRECT_URI

echo "5. Adding KV_REST_API_URL..."
vercel env add KV_REST_API_URL

echo "6. Adding KV_REST_API_TOKEN..."
vercel env add KV_REST_API_TOKEN

echo "7. Adding XERO_CLIENT_ID (optional, press Enter to skip)..."
vercel env add XERO_CLIENT_ID

echo "8. Adding XERO_CLIENT_SECRET (optional, press Enter to skip)..."
vercel env add XERO_CLIENT_SECRET

echo ""
echo "Done! Now deploy with: vercel --prod"