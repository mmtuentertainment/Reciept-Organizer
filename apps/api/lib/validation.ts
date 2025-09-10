import { z } from 'zod';

// Receipt validation schema
export const receiptSchema = z.object({
  merchantName: z.string().min(1).max(255).optional().nullable(),
  date: z.string().datetime().optional().nullable(),
  totalAmount: z.number().positive().optional().nullable(),
  taxAmount: z.number().min(0).optional().nullable(),
});

// Batch receipts validation
export const receiptsValidationSchema = z.object({
  receipts: z.array(receiptSchema).min(1).max(100),
});

// OAuth callback validation
export const oauthCallbackSchema = z.object({
  code: z.string().min(1),
  state: z.string().min(1),
  realmId: z.string().optional(),
});

// Session validation
export const sessionSchema = z.object({
  sessionId: z.string().uuid(),
  provider: z.enum(['quickbooks', 'xero']).optional(),
});

// Input sanitization helper
export function sanitizeInput(input: string): string {
  // Remove potential XSS/injection characters
  return input
    .replace(/[<>]/g, '') // Remove HTML tags
    .replace(/javascript:/gi, '') // Remove javascript: protocol
    .replace(/on\w+=/gi, '') // Remove event handlers
    .trim();
}

// Validate and sanitize merchant name
export function validateMerchantName(name: string): string {
  const sanitized = sanitizeInput(name);
  if (sanitized.length === 0) {
    throw new Error('Merchant name cannot be empty');
  }
  if (sanitized.length > 255) {
    throw new Error('Merchant name too long');
  }
  return sanitized;
}

// Validate date format
export function validateDate(date: string): string {
  const parsed = new Date(date);
  if (isNaN(parsed.getTime())) {
    throw new Error('Invalid date format');
  }
  
  // Check if date is not in future
  if (parsed > new Date()) {
    throw new Error('Date cannot be in the future');
  }
  
  // Check if date is not too old (e.g., 10 years)
  const tenYearsAgo = new Date();
  tenYearsAgo.setFullYear(tenYearsAgo.getFullYear() - 10);
  if (parsed < tenYearsAgo) {
    throw new Error('Date is too old (more than 10 years)');
  }
  
  return parsed.toISOString();
}

// Validate amount
export function validateAmount(amount: number): number {
  if (amount <= 0) {
    throw new Error('Amount must be positive');
  }
  if (amount > 1000000) {
    throw new Error('Amount exceeds maximum allowed');
  }
  // Round to 2 decimal places
  return Math.round(amount * 100) / 100;
}

// Generic validation wrapper
export async function validateRequest<T>(
  data: unknown,
  schema: z.ZodSchema<T>
): Promise<T> {
  try {
    return await schema.parseAsync(data);
  } catch (error) {
    if (error instanceof z.ZodError) {
      const issues = error.issues.map(e => ({
        field: e.path.join('.'),
        message: e.message,
      }));
      throw new ValidationError('Validation failed', issues);
    }
    throw error;
  }
}

// Custom validation error class
export class ValidationError extends Error {
  constructor(
    message: string,
    public issues: Array<{ field: string; message: string }>
  ) {
    super(message);
    this.name = 'ValidationError';
  }
}