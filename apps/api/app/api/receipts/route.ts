import { NextRequest, NextResponse } from "next/server";
import { problemJSON, ProblemTypes } from "@/lib/problem";
import { createReceiptFromJob, listReceipts } from "@/lib/receipt-store";

// Dev-only in-memory stores (replace with Redis/DB in production)
const idempotencyCache = new Map<string, { jobId: string; receiptId?: string; timestamp: number }>();
const rateLimitBuckets = new Map<string, { count: number; resetAt: number }>();

// Configuration
const RATE_LIMIT_WINDOW_MS = 60_000; // 1 minute
const RATE_LIMIT_MAX_REQUESTS = 60; // 60 requests per minute
const IDEMPOTENCY_KEY_TTL_MS = 24 * 60 * 60 * 1000; // 24 hours

// Type definitions matching OpenAPI schema
type ReceiptUploadByUrl = {
  source: "url";
  url: string;
  metadata?: Record<string, unknown>;
};

type ReceiptUploadByBase64 = {
  source: "base64";
  contentType: "image/jpeg" | "image/png" | "image/webp" | "application/pdf";
  data: string;
  metadata?: Record<string, unknown>;
};

type ReceiptUpload = ReceiptUploadByUrl | ReceiptUploadByBase64;

/**
 * Type guard for URL upload
 */
function isUploadByUrl(upload: unknown): upload is ReceiptUploadByUrl {
  return (
    typeof upload === "object" &&
    upload !== null &&
    "source" in upload &&
    upload.source === "url" &&
    "url" in upload &&
    typeof upload.url === "string"
  );
}

/**
 * Type guard for base64 upload
 */
function isUploadByBase64(upload: unknown): upload is ReceiptUploadByBase64 {
  const validContentTypes = ["image/jpeg", "image/png", "image/webp", "application/pdf"];
  return (
    typeof upload === "object" &&
    upload !== null &&
    "source" in upload &&
    upload.source === "base64" &&
    "contentType" in upload &&
    typeof upload.contentType === "string" &&
    validContentTypes.includes(upload.contentType) &&
    "data" in upload &&
    typeof upload.data === "string"
  );
}

/**
 * Check rate limit for a given key
 */
function checkRateLimit(key: string): { allowed: boolean; retryAfter?: number } {
  const now = Date.now();
  const bucket = rateLimitBuckets.get(key);

  if (!bucket || now > bucket.resetAt) {
    // New window or expired window
    rateLimitBuckets.set(key, {
      count: 1,
      resetAt: now + RATE_LIMIT_WINDOW_MS,
    });
    return { allowed: true };
  }

  if (bucket.count >= RATE_LIMIT_MAX_REQUESTS) {
    // Rate limit exceeded
    const retryAfterMs = bucket.resetAt - now;
    const retryAfterSeconds = Math.ceil(retryAfterMs / 1000);
    return { allowed: false, retryAfter: retryAfterSeconds };
  }

  // Increment counter
  bucket.count++;
  rateLimitBuckets.set(key, bucket);
  return { allowed: true };
}

/**
 * Clean expired idempotency keys periodically
 */
function cleanupIdempotencyCache(): void {
  const now = Date.now();
  for (const [key, value] of idempotencyCache.entries()) {
    if (now - value.timestamp > IDEMPOTENCY_KEY_TTL_MS) {
      idempotencyCache.delete(key);
    }
  }
}

/**
 * Generate a job ID
 */
function generateJobId(): string {
  return `job_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 9)}`;
}

/**
 * GET /api/receipts - List receipts with pagination
 */
export async function GET(req: NextRequest): Promise<Response> {
  // Parse query parameters
  const { searchParams } = new URL(req.url);
  const cursor = searchParams.get("cursor") || undefined;
  const limitParam = searchParams.get("limit");
  const limit = limitParam ? parseInt(limitParam, 10) : 20;

  // Validate limit
  if (limitParam && (isNaN(limit) || limit < 1 || limit > 100)) {
    return problemJSON({
      type: ProblemTypes.BAD_REQUEST,
      title: "Invalid Limit Parameter",
      status: 400,
      detail: "Limit must be a number between 1 and 100"
    });
  }

  // TODO: Add authentication/authorization
  // const authHeader = req.headers.get("authorization");
  // if (!authHeader) {
  //   return problemJSON({
  //     type: ProblemTypes.UNAUTHORIZED,
  //     title: "Unauthorized",
  //     status: 401,
  //     detail: "Authentication required"
  //   });
  // }

  // Get receipts from store
  const result = listReceipts({ cursor, limit });

  // Transform to API response format
  const response = {
    items: result.items.map(receipt => ({
      id: receipt.id,
      createdAt: receipt.createdAt,
      updatedAt: receipt.updatedAt,
      status: receipt.status,
      total: receipt.total,
      currency: receipt.currency,
      vendor: receipt.vendor,
      date: receipt.date,
      category: receipt.category,
      items: receipt.items,
      extractedData: receipt.extractedData,
      metadata: receipt.metadata
    })),
    nextCursor: result.nextCursor,
    hasMore: result.hasMore,
    totalCount: result.totalCount
  };

  return NextResponse.json(response, {
    status: 200,
    headers: {
      "Cache-Control": "no-cache", // Don't cache list responses
      "X-Total-Count": String(result.totalCount) // Include total count in header
    }
  });
}

/**
 * POST /api/receipts - Create a receipt ingestion job
 */
export async function POST(req: NextRequest): Promise<Response> {
  // Rate limiting
  const clientId = req.headers.get("x-forwarded-for") ??
                   req.headers.get("x-real-ip") ??
                   "anonymous";
  const rateLimitResult = checkRateLimit(clientId);

  if (!rateLimitResult.allowed) {
    const response = problemJSON({
      type: ProblemTypes.RATE_LIMIT,
      title: "Too Many Requests",
      status: 429,
      detail: "Rate limit exceeded. Please retry later.",
    });

    // Add Retry-After header
    return new Response(response.body, {
      status: response.status,
      headers: {
        ...Object.fromEntries(response.headers),
        "Retry-After": String(rateLimitResult.retryAfter),
      },
    });
  }

  // Check Idempotency-Key header
  const idempotencyKey = req.headers.get("idempotency-key");

  if (!idempotencyKey) {
    return problemJSON({
      type: ProblemTypes.IDEMPOTENCY_REQUIRED,
      title: "Idempotency-Key Required",
      status: 400,
      detail: "The Idempotency-Key header is required for this operation.",
    });
  }

  // Validate Idempotency-Key format
  if (idempotencyKey.length < 8 || idempotencyKey.length > 128) {
    return problemJSON({
      type: ProblemTypes.BAD_REQUEST,
      title: "Invalid Idempotency-Key",
      status: 400,
      detail: "Idempotency-Key must be between 8 and 128 characters.",
    });
  }

  if (!/^[a-zA-Z0-9_-]+$/.test(idempotencyKey)) {
    return problemJSON({
      type: ProblemTypes.BAD_REQUEST,
      title: "Invalid Idempotency-Key Format",
      status: 400,
      detail: "Idempotency-Key must contain only alphanumeric characters, hyphens, and underscores.",
    });
  }

  // Check for idempotency replay
  const cachedResult = idempotencyCache.get(idempotencyKey);
  if (cachedResult) {
    // Return the same response (409 with deduped flag)
    return new Response(
      JSON.stringify({
        jobId: cachedResult.jobId,
        deduped: true,
      }),
      {
        status: 409,
        headers: {
          "Content-Type": "application/json",
          "Cache-Control": "no-cache",
        },
      }
    );
  }

  // Parse and validate request body
  let body: unknown;
  try {
    body = await req.json();
  } catch (error) {
    return problemJSON({
      type: ProblemTypes.INVALID_JSON,
      title: "Invalid JSON",
      status: 400,
      detail: "The request body contains invalid JSON.",
    });
  }

  // Validate against OpenAPI schema
  if (!isUploadByUrl(body) && !isUploadByBase64(body)) {
    return problemJSON({
      type: ProblemTypes.INVALID_INPUT,
      title: "Invalid Request Body",
      status: 400,
      detail: 'Request body must match one of: {"source":"url","url":"..."} or {"source":"base64","contentType":"...","data":"..."}',
    });
  }

  // Additional validation for URL uploads
  if (isUploadByUrl(body)) {
    try {
      const url = new URL(body.url);
      if (!["http:", "https:"].includes(url.protocol)) {
        return problemJSON({
          type: ProblemTypes.INVALID_INPUT,
          title: "Invalid URL Protocol",
          status: 400,
          detail: "URL must use HTTP or HTTPS protocol.",
        });
      }
    } catch (error) {
      return problemJSON({
        type: ProblemTypes.INVALID_INPUT,
        title: "Invalid URL",
        status: 400,
        detail: "The provided URL is not valid.",
      });
    }
  }

  // Additional validation for base64 uploads
  if (isUploadByBase64(body)) {
    // Check if base64 data is valid
    const base64Regex = /^[A-Za-z0-9+/]*={0,2}$/;
    if (!base64Regex.test(body.data)) {
      return problemJSON({
        type: ProblemTypes.INVALID_INPUT,
        title: "Invalid Base64 Data",
        status: 400,
        detail: "The provided data is not valid base64.",
      });
    }

    // Check data size (e.g., 10MB limit)
    const estimatedSizeBytes = (body.data.length * 3) / 4;
    const maxSizeBytes = 10 * 1024 * 1024; // 10MB
    if (estimatedSizeBytes > maxSizeBytes) {
      return problemJSON({
        type: ProblemTypes.INVALID_INPUT,
        title: "File Too Large",
        status: 400,
        detail: `File size exceeds maximum allowed size of ${maxSizeBytes / (1024 * 1024)}MB.`,
      });
    }
  }

  // TODO: Add authentication/authorization checks here
  // const authHeader = req.headers.get("authorization");
  // if (!authHeader) { return unauthorized response }

  // Generate job ID
  const jobId = generateJobId();

  // Create receipt in store (simulates async processing)
  const uploadData = body as ReceiptUpload;
  const receipt = createReceiptFromJob(jobId, {
    source: uploadData.source,
    ...(isUploadByUrl(uploadData) && { url: uploadData.url }),
    ...(isUploadByBase64(uploadData) && {
      contentType: uploadData.contentType,
      data: uploadData.data
    }),
    metadata: (uploadData as any).metadata
  });

  // Cache for idempotency with receipt ID
  idempotencyCache.set(idempotencyKey, {
    jobId,
    receiptId: receipt.id,
    timestamp: Date.now(),
  });

  // Clean up old idempotency keys periodically (every 100 requests)
  if (Math.random() < 0.01) {
    cleanupIdempotencyCache();
  }

  // Return 202 Accepted
  return new Response(
    JSON.stringify({
      jobId,
      deduped: false,
    }),
    {
      status: 202,
      headers: {
        "Content-Type": "application/json",
        "Cache-Control": "no-cache",
        "Location": `/api/receipts/${receipt.id}`, // Location of the receipt resource
      },
    }
  );
}

// Force dynamic rendering (disable static optimization)
export const dynamic = "force-dynamic";