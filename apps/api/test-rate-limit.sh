#!/bin/bash

echo "Testing rate limiting (60 req/min)..."
echo "Sending 70 rapid requests..."

for i in {1..70}; do
  curl -s -o /dev/null -w "%{http_code} " \
    -X POST http://localhost:3001/api/receipts \
    -H "Content-Type: application/json" \
    -H "Idempotency-Key: rate-test-$i" \
    -d '{"source": "url", "url": "https://example.com/rate.jpg"}' &
done

wait
echo ""
echo "Done. Check for 429 status codes above."
