# Receipt Organizer API

## Overview
This is a minimal, contract-first REST API for receipt processing built with Next.js 15.5 App Router, implementing RFC9457 Problem Details for errors and OpenAPI 3.1 specification.

## Features
- ✅ **OpenAPI 3.1 Contract-First Design** - API defined in `openapi.yaml`
- ✅ **RFC9457 Problem Details** - Standardized error responses
- ✅ **Idempotency Support** - Safe request retries with `Idempotency-Key` header
- ✅ **Rate Limiting** - 60 requests/minute with `Retry-After` header
- ✅ **Multiple Upload Methods** - URL or base64 image/PDF upload
- ✅ **TypeScript Type Safety** - Full type checking
- ✅ **CI/CD Integration** - Automated testing with GitHub Actions

## Quick Start

```bash
# Install dependencies
npm ci

# Run development server
npm run dev

# Run tests (in another terminal)
./test-receipts-api.sh
```

## API Endpoints

### POST /api/receipts
Create a receipt ingestion job.

**Headers:**
- `Content-Type: application/json`
- `Idempotency-Key: <unique-key>` (required, 8-128 chars)

**Request Body (URL upload):**
```json
{
  "source": "url",
  "url": "https://example.com/receipt.jpg",
  "metadata": { "any": "data" }
}
```

**Request Body (Base64 upload):**
```json
{
  "source": "base64",
  "contentType": "image/jpeg",
  "data": "<base64-encoded-data>",
  "metadata": { "any": "data" }
}
```

**Response (202 Accepted):**
```json
{
  "jobId": "job_abc123",
  "deduped": false
}
```

**Response (409 Conflict - Duplicate):**
```json
{
  "jobId": "job_abc123",
  "deduped": true
}
```

**Error Response (RFC9457):**
```json
{
  "type": "https://example.com/problems/rate-limit",
  "title": "Too Many Requests",
  "status": 429,
  "detail": "Rate limit exceeded. Please retry later."
}
```

## Development Notes

### Current Implementation
- **In-Memory Storage**: Idempotency cache and rate limiting use in-memory Maps (dev-only)
- **No Authentication**: JWT integration prepared but not implemented
- **Async Processing**: Returns job ID for tracking, actual processing not implemented

### Production TODOs
1. Replace in-memory cache with Redis/Upstash (KV_REST_API_URL already configured)
2. Implement JWT authentication using existing `lib/jwt.ts`
3. Add actual OCR processing with Supabase job queue
4. Implement GET endpoints for receipt retrieval
5. Add CORS middleware for production domains
6. Add database persistence for receipts

### Testing

Run the included test script:
```bash
./test-receipts-api.sh
```

Or use curl directly:
```bash
curl -X POST http://localhost:3001/api/receipts \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: test-123" \
  -d '{
    "source": "url",
    "url": "https://example.com/receipt.jpg"
  }'
```

### CI/CD

The API is automatically validated in CI:
- TypeScript compilation check
- OpenAPI spec validation with Spectral
- Test execution (when tests are added to package.json)

See `.github/workflows/security.yml` for the `api-validation` job.

## Architecture Decisions

1. **Next.js 15 App Router**: Modern React Server Components architecture
2. **RFC9457 Problem Details**: Industry-standard error format (replaced RFC7807)
3. **OpenAPI 3.1**: Latest specification with better JSON Schema support
4. **Idempotency Keys**: Prevent duplicate processing, 24-hour expiration
5. **Rate Limiting**: Simple sliding window, 60 req/min per IP
6. **TypeScript**: Full type safety with discriminated unions

## File Structure
```
apps/api/
├── openapi.yaml                    # OpenAPI 3.1 specification
├── .spectral.yaml                   # Spectral linting config
├── app/api/receipts/
│   └── route.ts                     # POST /receipts handler
├── lib/
│   └── problem.ts                   # RFC9457 helper
├── test-receipts-api.sh             # Test script
└── README-RECEIPTS-API.md           # This file
```

## References
- [RFC 9457: Problem Details for HTTP APIs](https://www.rfc-editor.org/rfc/rfc9457.html)
- [OpenAPI 3.1 Specification](https://spec.openapis.org/oas/v3.1.0)
- [Next.js 15 App Router](https://nextjs.org/docs/app)
- [Idempotency Keys Best Practices](https://brandur.org/idempotency-keys)