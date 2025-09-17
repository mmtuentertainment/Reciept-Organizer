/**
 * In-memory receipt store for development
 * Replace with Supabase/database in production
 */

export interface StoredReceipt {
  id: string;
  jobId: string;
  createdAt: string;
  updatedAt: string;
  status: "processing" | "ready" | "failed";
  total: number | null;
  currency: string | null;
  vendor: string | null;
  date: string | null;
  category: string | null;
  items: Array<{
    description?: string;
    quantity?: number;
    unitPrice?: number;
    lineTotal?: number;
  }>;
  extractedData?: Record<string, unknown>;
  metadata?: Record<string, unknown>;
  uploadSource: "url" | "base64";
  uploadUrl?: string;
  uploadContentType?: string;
}

// In-memory storage (dev only)
const receipts = new Map<string, StoredReceipt>();
const jobToReceiptMap = new Map<string, string>(); // jobId -> receiptId

// Sample data for testing
function generateSampleReceipts(): void {
  const samples: StoredReceipt[] = [
    {
      id: "rcpt_sample001",
      jobId: "job_sample001",
      createdAt: new Date(Date.now() - 86400000).toISOString(), // 1 day ago
      updatedAt: new Date(Date.now() - 86400000).toISOString(),
      status: "ready",
      total: 42.99,
      currency: "USD",
      vendor: "Coffee Shop",
      date: "2025-09-15",
      category: "Food & Dining",
      items: [
        {
          description: "Latte",
          quantity: 2,
          unitPrice: 4.50,
          lineTotal: 9.00
        },
        {
          description: "Sandwich",
          quantity: 1,
          unitPrice: 12.99,
          lineTotal: 12.99
        },
        {
          description: "Cookie",
          quantity: 3,
          unitPrice: 2.00,
          lineTotal: 6.00
        }
      ],
      extractedData: {
        ocrConfidence: 0.95,
        processingTime: 1234
      },
      metadata: {
        source: "sample",
        demoData: true
      },
      uploadSource: "url",
      uploadUrl: "https://example.com/receipts/sample001.jpg"
    },
    {
      id: "rcpt_sample002",
      jobId: "job_sample002",
      createdAt: new Date(Date.now() - 172800000).toISOString(), // 2 days ago
      updatedAt: new Date(Date.now() - 172800000).toISOString(),
      status: "ready",
      total: 125.50,
      currency: "USD",
      vendor: "Electronics Store",
      date: "2025-09-14",
      category: "Electronics",
      items: [
        {
          description: "USB Cable",
          quantity: 2,
          unitPrice: 15.00,
          lineTotal: 30.00
        },
        {
          description: "Phone Case",
          quantity: 1,
          unitPrice: 45.50,
          lineTotal: 45.50
        },
        {
          description: "Screen Protector",
          quantity: 1,
          unitPrice: 25.00,
          lineTotal: 25.00
        }
      ],
      extractedData: {
        ocrConfidence: 0.98,
        processingTime: 987
      },
      metadata: {
        source: "sample",
        demoData: true
      },
      uploadSource: "base64",
      uploadContentType: "image/jpeg"
    },
    {
      id: "rcpt_sample003",
      jobId: "job_sample003",
      createdAt: new Date(Date.now() - 3600000).toISOString(), // 1 hour ago
      updatedAt: new Date(Date.now() - 3600000).toISOString(),
      status: "processing",
      total: null,
      currency: null,
      vendor: null,
      date: null,
      category: null,
      items: [],
      metadata: {
        source: "sample",
        demoData: true
      },
      uploadSource: "url",
      uploadUrl: "https://example.com/receipts/sample003.pdf"
    },
    {
      id: "rcpt_sample004",
      jobId: "job_sample004",
      createdAt: new Date(Date.now() - 7200000).toISOString(), // 2 hours ago
      updatedAt: new Date(Date.now() - 7200000).toISOString(),
      status: "failed",
      total: null,
      currency: null,
      vendor: null,
      date: null,
      category: null,
      items: [],
      extractedData: {
        error: "OCR_FAILED",
        errorMessage: "Unable to extract text from image"
      },
      metadata: {
        source: "sample",
        demoData: true
      },
      uploadSource: "url",
      uploadUrl: "https://example.com/receipts/corrupted.jpg"
    }
  ];

  // Add samples to store
  samples.forEach(receipt => {
    receipts.set(receipt.id, receipt);
    jobToReceiptMap.set(receipt.jobId, receipt.id);
  });
}

// Initialize with sample data
if (receipts.size === 0) {
  generateSampleReceipts();
}

/**
 * Create a new receipt from a job
 */
export function createReceiptFromJob(
  jobId: string,
  uploadData: {
    source: "url" | "base64";
    url?: string;
    contentType?: string;
    data?: string;
    metadata?: Record<string, unknown>;
  }
): StoredReceipt {
  const receiptId = `rcpt_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 9)}`;
  const now = new Date().toISOString();

  const receipt: StoredReceipt = {
    id: receiptId,
    jobId,
    createdAt: now,
    updatedAt: now,
    status: "processing",
    total: null,
    currency: null,
    vendor: null,
    date: null,
    category: null,
    items: [],
    metadata: uploadData.metadata,
    uploadSource: uploadData.source,
    ...(uploadData.source === "url" && { uploadUrl: uploadData.url }),
    ...(uploadData.source === "base64" && { uploadContentType: uploadData.contentType })
  };

  receipts.set(receiptId, receipt);
  jobToReceiptMap.set(jobId, receiptId);

  // Simulate async processing (update status after delay)
  setTimeout(() => {
    const stored = receipts.get(receiptId);
    if (stored && stored.status === "processing") {
      // Simulate successful processing with mock data
      stored.status = "ready";
      stored.updatedAt = new Date().toISOString();
      stored.total = Math.random() * 200 + 10; // Random amount 10-210
      stored.currency = "USD";
      stored.vendor = `Vendor ${Math.floor(Math.random() * 100)}`;
      stored.date = new Date().toISOString().split('T')[0];
      stored.category = ["Food", "Electronics", "Office", "Travel"][Math.floor(Math.random() * 4)];
      stored.items = [
        {
          description: "Item 1",
          quantity: 1,
          unitPrice: stored.total * 0.6,
          lineTotal: stored.total * 0.6
        },
        {
          description: "Item 2",
          quantity: 1,
          unitPrice: stored.total * 0.4,
          lineTotal: stored.total * 0.4
        }
      ];
      receipts.set(receiptId, stored);
    }
  }, 3000 + Math.random() * 2000); // Process in 3-5 seconds

  return receipt;
}

/**
 * Get receipt by ID
 */
export function getReceiptById(id: string): StoredReceipt | null {
  return receipts.get(id) || null;
}

/**
 * Get receipt by job ID
 */
export function getReceiptByJobId(jobId: string): StoredReceipt | null {
  const receiptId = jobToReceiptMap.get(jobId);
  if (!receiptId) return null;
  return receipts.get(receiptId) || null;
}

/**
 * List receipts with pagination
 */
export function listReceipts(options?: {
  cursor?: string;
  limit?: number;
}): {
  items: StoredReceipt[];
  nextCursor: string | null;
  hasMore: boolean;
  totalCount: number;
} {
  const limit = Math.min(options?.limit || 20, 100);
  const allReceipts = Array.from(receipts.values()).sort(
    (a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
  );

  let startIndex = 0;
  if (options?.cursor) {
    // Simple cursor implementation using receipt ID
    const cursorIndex = allReceipts.findIndex(r => r.id === options.cursor);
    if (cursorIndex !== -1) {
      startIndex = cursorIndex + 1;
    }
  }

  const items = allReceipts.slice(startIndex, startIndex + limit);
  const hasMore = startIndex + limit < allReceipts.length;
  const nextCursor = hasMore ? items[items.length - 1]?.id : null;

  return {
    items,
    nextCursor,
    hasMore,
    totalCount: allReceipts.length
  };
}

/**
 * Get statistics about stored receipts (for debugging)
 */
export function getStats(): {
  totalReceipts: number;
  byStatus: Record<string, number>;
  totalJobs: number;
} {
  const byStatus: Record<string, number> = {
    processing: 0,
    ready: 0,
    failed: 0
  };

  receipts.forEach(receipt => {
    byStatus[receipt.status]++;
  });

  return {
    totalReceipts: receipts.size,
    byStatus,
    totalJobs: jobToReceiptMap.size
  };
}