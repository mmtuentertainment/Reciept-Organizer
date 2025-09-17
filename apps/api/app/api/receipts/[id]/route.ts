import { NextRequest, NextResponse } from "next/server";
import { problemJSON, ProblemTypes } from "@/lib/problem";
import { getReceiptById } from "@/lib/receipt-store";

/**
 * GET /api/receipts/{id} - Get a specific receipt by ID
 */
export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
): Promise<Response> {
  const { id: receiptId } = await params;

  // Validate receipt ID format
  if (!receiptId || !/^rcpt_[a-zA-Z0-9_]+$/.test(receiptId)) {
    return problemJSON({
      type: ProblemTypes.BAD_REQUEST,
      title: "Invalid Receipt ID",
      status: 400,
      detail: "Receipt ID must match the format 'rcpt_[alphanumeric]'",
      instance: `/api/receipts/${receiptId}`
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

  // Retrieve receipt from store
  const receipt = getReceiptById(receiptId);

  if (!receipt) {
    return problemJSON({
      type: ProblemTypes.NOT_FOUND,
      title: "Receipt Not Found",
      status: 404,
      detail: `Receipt with ID '${receiptId}' was not found`,
      instance: `/api/receipts/${receiptId}`
    });
  }

  // Transform to API response format (exclude internal fields)
  const responseData = {
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
  };

  return NextResponse.json(responseData, {
    status: 200,
    headers: {
      "Cache-Control": receipt.status === "ready"
        ? "public, max-age=3600" // Cache completed receipts for 1 hour
        : "no-cache", // Don't cache processing/failed receipts
      "ETag": `"${receipt.updatedAt}"` // Use updatedAt as ETag
    }
  });
}

/**
 * DELETE /api/receipts/{id} - Delete a receipt (not in OpenAPI spec, but useful)
 */
export async function DELETE(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
): Promise<Response> {
  const { id: receiptId } = await params;

  // Validate receipt ID format
  if (!receiptId || !/^rcpt_[a-zA-Z0-9_]+$/.test(receiptId)) {
    return problemJSON({
      type: ProblemTypes.BAD_REQUEST,
      title: "Invalid Receipt ID",
      status: 400,
      detail: "Receipt ID must match the format 'rcpt_[alphanumeric]'",
      instance: `/api/receipts/${receiptId}`
    });
  }

  // TODO: Add authentication/authorization
  // Only allow deletion by the owner or admin

  const receipt = getReceiptById(receiptId);

  if (!receipt) {
    return problemJSON({
      type: ProblemTypes.NOT_FOUND,
      title: "Receipt Not Found",
      status: 404,
      detail: `Receipt with ID '${receiptId}' was not found`,
      instance: `/api/receipts/${receiptId}`
    });
  }

  // In production, would mark as deleted in database rather than hard delete
  // For now, return method not allowed since it's not in the spec
  return problemJSON({
    type: "https://example.com/problems/method-not-allowed",
    title: "Method Not Allowed",
    status: 405,
    detail: "DELETE method is not currently supported for receipts",
    instance: `/api/receipts/${receiptId}`
  });
}

// Force dynamic rendering
export const dynamic = "force-dynamic";