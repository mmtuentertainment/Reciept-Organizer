#!/bin/bash

# Test script for GET endpoints
# Usage: ./test-get-endpoints.sh

API_URL="http://localhost:3001"

echo "🧪 Testing Receipt GET Endpoints"
echo "================================="
echo ""

# Test 1: GET list of receipts
echo "Test 1: GET /api/receipts - List all receipts"
echo "---------------------------------------------"
curl -s -X GET "$API_URL/api/receipts" | jq '.'
echo ""

# Test 2: GET list with limit
echo "Test 2: GET /api/receipts?limit=2 - List with limit"
echo "---------------------------------------------------"
curl -s -X GET "$API_URL/api/receipts?limit=2" | jq '.'
echo ""

# Test 3: GET specific receipt (sample data)
echo "Test 3: GET /api/receipts/rcpt_sample001 - Get sample receipt"
echo "------------------------------------------------------------"
curl -s -X GET "$API_URL/api/receipts/rcpt_sample001" | jq '.'
echo ""

# Test 4: GET non-existent receipt
echo "Test 4: GET /api/receipts/rcpt_nonexistent - Should return 404"
echo "--------------------------------------------------------------"
curl -s -X GET "$API_URL/api/receipts/rcpt_nonexistent" \
  -w "\nHTTP Status: %{http_code}\n"
echo ""

# Test 5: Create a new receipt and then retrieve it
echo "Test 5: Create new receipt and retrieve it"
echo "------------------------------------------"
echo "Creating receipt..."
RESPONSE=$(curl -s -X POST "$API_URL/api/receipts" \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: test-create-$(date +%s)" \
  -d '{
    "source": "url",
    "url": "https://example.com/test-receipt.jpg",
    "metadata": {
      "test": "get-endpoint-test",
      "timestamp": "'$(date -Iseconds)'"
    }
  }')

echo "POST Response:"
echo "$RESPONSE" | jq '.'

# Extract Location header
LOCATION=$(curl -s -I -X POST "$API_URL/api/receipts" \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: test-location-$(date +%s)" \
  -d '{"source": "url", "url": "https://example.com/test.jpg"}' \
  2>/dev/null | grep -i "^location:" | cut -d' ' -f2 | tr -d '\r')

if [ ! -z "$LOCATION" ]; then
  echo ""
  echo "Location header: $LOCATION"
  echo "Fetching receipt from Location..."

  # Wait a moment for processing
  sleep 1

  RECEIPT_URL="$API_URL$LOCATION"
  echo "GET $RECEIPT_URL"
  curl -s -X GET "$RECEIPT_URL" | jq '.'
else
  echo "No Location header found"
fi
echo ""

# Test 6: Test pagination
echo "Test 6: Test pagination with cursor"
echo "-----------------------------------"
echo "First page (limit=2):"
PAGE1=$(curl -s -X GET "$API_URL/api/receipts?limit=2")
echo "$PAGE1" | jq '.'

CURSOR=$(echo "$PAGE1" | jq -r '.nextCursor')
if [ "$CURSOR" != "null" ]; then
  echo ""
  echo "Next page using cursor=$CURSOR:"
  curl -s -X GET "$API_URL/api/receipts?cursor=$CURSOR&limit=2" | jq '.'
else
  echo "No next cursor available"
fi
echo ""

# Test 7: Check processing status changes
echo "Test 7: Check receipt status changes over time"
echo "----------------------------------------------"
echo "Creating a new receipt..."
NEW_RECEIPT=$(curl -s -X POST "$API_URL/api/receipts" \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: test-status-$(date +%s%N)" \
  -d '{"source": "url", "url": "https://example.com/status-test.jpg"}')

# Extract receipt ID from Location header
RECEIPT_ID=$(curl -s -I -X POST "$API_URL/api/receipts" \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: test-extract-$(date +%s%N)" \
  -d '{"source": "url", "url": "https://example.com/test.jpg"}' \
  2>/dev/null | grep -i "^location:" | sed 's/.*\/receipts\///' | tr -d '\r')

if [ ! -z "$RECEIPT_ID" ]; then
  echo "Created receipt ID: $RECEIPT_ID"
  echo ""

  for i in {1..3}; do
    echo "Check $i (after ${i} seconds):"
    sleep 1
    STATUS=$(curl -s -X GET "$API_URL/api/receipts/$RECEIPT_ID" | jq -r '.status')
    echo "  Status: $STATUS"

    if [ "$STATUS" = "ready" ]; then
      echo "  Receipt processing complete!"
      break
    fi
  done

  echo ""
  echo "Final receipt data:"
  curl -s -X GET "$API_URL/api/receipts/$RECEIPT_ID" | jq '.'
fi
echo ""

# Test 8: Check headers
echo "Test 8: Check response headers"
echo "------------------------------"
echo "Checking headers for GET /api/receipts..."
curl -I -s -X GET "$API_URL/api/receipts" | grep -E "^(X-Total-Count|Cache-Control|Content-Type):"
echo ""

echo "Checking headers for GET /api/receipts/rcpt_sample001..."
curl -I -s -X GET "$API_URL/api/receipts/rcpt_sample001" | grep -E "^(ETag|Cache-Control|Content-Type):"
echo ""

echo "================================="
echo "✅ GET endpoint tests completed!"
echo ""