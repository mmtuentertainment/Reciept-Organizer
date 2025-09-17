#!/bin/bash

# Test script for Receipt Organizer API
# Usage: ./test-receipts-api.sh

API_URL="http://localhost:3001"

echo "🧪 Testing Receipt Organizer API"
echo "================================="
echo ""

# Test 1: POST receipt with URL
echo "Test 1: Creating receipt from URL"
echo "---------------------------------"
curl -X POST "$API_URL/api/receipts" \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: test-$(date +%s)-url" \
  -d '{
    "source": "url",
    "url": "https://example.com/receipt.jpg",
    "metadata": {
      "uploadedBy": "test-script"
    }
  }' \
  -w "\nHTTP Status: %{http_code}\n" \
  -v 2>&1 | grep -E "(HTTP/|{|})|\<|\>"

echo ""
echo ""

# Test 2: POST receipt with base64 image
echo "Test 2: Creating receipt from base64 data"
echo "-----------------------------------------"
# Sample 1x1 transparent PNG in base64
BASE64_IMG="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
curl -X POST "$API_URL/api/receipts" \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: test-$(date +%s)-base64" \
  -d "{
    \"source\": \"base64\",
    \"contentType\": \"image/png\",
    \"data\": \"$BASE64_IMG\",
    \"metadata\": {
      \"uploadedBy\": \"test-script\"
    }
  }" \
  -w "\nHTTP Status: %{http_code}\n" \
  -s

echo ""
echo ""

# Test 3: Duplicate request (idempotency test)
echo "Test 3: Testing idempotency (same key)"
echo "--------------------------------------"
IDEM_KEY="test-idempotency-$(date +%s)"

echo "First request:"
curl -X POST "$API_URL/api/receipts" \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: $IDEM_KEY" \
  -d '{
    "source": "url",
    "url": "https://example.com/receipt.jpg"
  }' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s

echo ""
echo "Second request with same Idempotency-Key (should return 409):"
curl -X POST "$API_URL/api/receipts" \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: $IDEM_KEY" \
  -d '{
    "source": "url",
    "url": "https://example.com/receipt.jpg"
  }' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s

echo ""
echo ""

# Test 4: Missing Idempotency-Key (should fail)
echo "Test 4: Missing Idempotency-Key (should return 400)"
echo "---------------------------------------------------"
curl -X POST "$API_URL/api/receipts" \
  -H "Content-Type: application/json" \
  -d '{
    "source": "url",
    "url": "https://example.com/receipt.jpg"
  }' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s

echo ""
echo ""

# Test 5: Invalid request body
echo "Test 5: Invalid request body (should return 400)"
echo "------------------------------------------------"
curl -X POST "$API_URL/api/receipts" \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: test-$(date +%s)-invalid" \
  -d '{
    "invalidField": "test"
  }' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s

echo ""
echo ""

# Test 6: Rate limiting (rapid requests)
echo "Test 6: Rate limiting test (61 rapid requests, should trigger 429)"
echo "------------------------------------------------------------------"
echo "Sending 61 requests rapidly..."

for i in {1..61}; do
  response=$(curl -X POST "$API_URL/api/receipts" \
    -H "Content-Type: application/json" \
    -H "Idempotency-Key: test-ratelimit-$i-$(date +%s)" \
    -d '{
      "source": "url",
      "url": "https://example.com/receipt.jpg"
    }' \
    -w "%{http_code}" \
    -o /dev/null \
    -s 2>&1)

  if [ "$response" = "429" ]; then
    echo "✓ Rate limit triggered on request #$i (HTTP 429)"
    break
  elif [ $i -eq 61 ]; then
    echo "⚠ Rate limit not triggered after 61 requests"
  fi
done

echo ""
echo "================================="
echo "✅ API tests completed!"
echo ""
echo "Note: Start the API server with 'npm run dev' before running tests"