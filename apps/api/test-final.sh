#!/bin/bash

echo "=== Final API Tests ==="
echo ""

# Test 1: List receipts
echo "1. GET /api/receipts"
curl -s http://localhost:3001/api/receipts | python3 -m json.tool | head -20
echo ""

# Test 2: Get specific receipt
echo "2. GET /api/receipts/rcpt_sample001"
curl -s http://localhost:3001/api/receipts/rcpt_sample001 | python3 -m json.tool | head -15
echo ""

# Test 3: 404 test
echo "3. GET /api/receipts/rcpt_nonexistent (should be 404)"
curl -s -w "\nHTTP Status: %{http_code}\n" http://localhost:3001/api/receipts/rcpt_nonexistent
echo ""

# Test 4: Create and retrieve
echo "4. Create new receipt"
TIMESTAMP=$(date +%s%N)
RESPONSE=$(curl -s -X POST http://localhost:3001/api/receipts \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: final-test-$TIMESTAMP" \
  -d '{"source": "url", "url": "https://example.com/final-test.jpg", "metadata": {"test": "final"}}')

echo "Response: $RESPONSE"
echo ""

# Extract receipt ID from Location header
echo "5. Getting receipt ID from Location header"
LOCATION=$(curl -sI -X POST http://localhost:3001/api/receipts \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: final-loc-$TIMESTAMP-2" \
  -d '{"source": "url", "url": "https://example.com/test.jpg"}' | grep -i location | cut -d' ' -f2 | tr -d '\r')

echo "Location: $LOCATION"
RECEIPT_ID=$(echo "$LOCATION" | sed 's/.*\///')
echo "Receipt ID: $RECEIPT_ID"
echo ""

# Check status
echo "6. Checking receipt status after 2 seconds"
sleep 2
curl -s "http://localhost:3001/api/receipts/$RECEIPT_ID" | python3 -m json.tool | grep -E '"(id|status|total)"'
echo ""

echo "7. Waiting 3 more seconds for processing"
sleep 3
curl -s "http://localhost:3001/api/receipts/$RECEIPT_ID" | python3 -m json.tool | grep -E '"(id|status|total|vendor)"'
echo ""

echo "=== Tests Complete ==="