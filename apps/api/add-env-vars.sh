#!/bin/bash

echo "Adding environment variables to Vercel..."
echo ""
echo "Make sure you're logged in to Vercel CLI first!"
echo ""

# Add each environment variable
vercel env add QB_CLIENT_ID production < <(echo "ABHeXjfhxPZWmMVLLKNFQ5BkThuwSmT8SeRkx1bJsX3Zcn5djW")
vercel env add QB_CLIENT_SECRET production < <(echo "IZD9kUK4lpRMnzIW3vQZXLE85TJkqtvJZVfoNQib")
vercel env add QB_REDIRECT_URI production < <(echo "https://receipt-organizer-api.vercel.app/api/auth/quickbooks/callback")
vercel env add XERO_CLIENT_ID production < <(echo "F7E48B5BA8CC43F9AA035C7803EB1504")
vercel env add XERO_REDIRECT_URI production < <(echo "https://receipt-organizer-api.vercel.app/api/auth/xero/callback")
vercel env add KV_REST_API_URL production < <(echo "https://star-finch-11621.upstash.io")
vercel env add KV_REST_API_TOKEN production < <(echo "AS1lAAIncDE2ZjE1N2JlNzkxYWQ0Y2ViODQ5MjU3ZmQ3N2VmMjViM3AxMTE2MjE")
vercel env add KV_REST_API_READ_ONLY_TOKEN production < <(echo "Ai1lAAIgcDHbgDmJm85yRFfMfwb3y9YnWszlW8J02MUJ67CzY4Kr1Q")
vercel env add JWT_SECRET production < <(echo "MJOyqf/tBV6d8DQQELZpXscd1vEasvZ/NDMes2cTEUQ=")
vercel env add FLUTTER_APP_SCHEME production < <(echo "receiptorganizer")
vercel env add NEXT_PUBLIC_APP_URL production < <(echo "https://receipt-organizer-api.vercel.app")

echo ""
echo "Environment variables added!"
echo "Now run: vercel --prod to redeploy"