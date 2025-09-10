#!/bin/bash

echo "=========================================="
echo "Testing Production OAuth Endpoints"
echo "=========================================="
echo ""

BASE_URL="https://receipt-organizer-api.vercel.app"

echo "1. Testing QuickBooks OAuth endpoint..."
echo "   URL: $BASE_URL/api/auth/quickbooks"
echo ""
QB_RESPONSE=$(curl -s "$BASE_URL/api/auth/quickbooks")
echo "Response: $QB_RESPONSE" | head -c 200
echo "..."
echo ""

echo "2. Testing Xero OAuth endpoint..."
echo "   URL: $BASE_URL/api/auth/xero"
echo ""
XERO_RESPONSE=$(curl -s "$BASE_URL/api/auth/xero")
echo "Response: $XERO_RESPONSE" | head -c 200
echo "..."
echo ""

echo "3. Testing validation endpoints (without auth)..."
TEST_RECEIPT='{"receipts":[{"merchantName":"Test Store","date":"2025-01-10","totalAmount":100,"taxAmount":10}]}'

echo "   QuickBooks validation..."
QB_VAL=$(curl -s -X POST "$BASE_URL/api/quickbooks/validate" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer test-token" \
  -d "$TEST_RECEIPT")
echo "   Response: $QB_VAL" | head -c 150
echo ""

echo "   Xero validation..."
XERO_VAL=$(curl -s -X POST "$BASE_URL/api/xero/validate" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer test-token" \
  -d "$TEST_RECEIPT")
echo "   Response: $XERO_VAL" | head -c 150
echo ""

echo "=========================================="
echo "OAuth Test URLs (try in browser):"
echo "=========================================="
echo ""
echo "QuickBooks OAuth Flow:"
echo "$BASE_URL/api/auth/quickbooks"
echo ""
echo "Xero OAuth Flow:"
echo "$BASE_URL/api/auth/xero"
echo ""
echo "Homepage:"
echo "$BASE_URL"
echo ""