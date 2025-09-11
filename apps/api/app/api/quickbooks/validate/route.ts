import { NextRequest, NextResponse } from 'next/server';
import { getTokens } from '@/lib/redis';
import { verifySessionToken } from '@/lib/jwt';
import { rateLimit, rateLimitResponse } from '@/lib/ratelimit';
import { validateRequest, receiptsValidationSchema, ValidationError } from '@/lib/validation';

interface Receipt {
  merchantName?: string | null;
  date?: string | null;
  totalAmount?: number | null;
  taxAmount?: number | null;
}

interface ValidationIssue {
  id: string;
  field: string;
  message: string;
  severity: 'error' | 'warning' | 'info';
  suggestedFix?: string;
  actualValue?: any;
  expectedValue?: any;
}

// POST - Validate receipts for QuickBooks
export async function POST(request: NextRequest) {
  try {
    // Apply rate limiting
    const { success, remaining, reset } = await rateLimit(request, 'validation');
    const rateLimitError = rateLimitResponse(success, remaining, reset);
    if (rateLimitError) return rateLimitError;
    // Get session from header
    const authorization = request.headers.get('Authorization');
    const sessionToken = authorization?.replace('Bearer ', '') || '';
    
    // Verify session
    const session = await verifySessionToken(sessionToken);
    if (!session) {
      return NextResponse.json(
        { success: false, error: 'Invalid or expired session' },
        { status: 401 }
      );
    }
    
    const { sessionId } = session;
    
    // Validate request body
    let validatedData;
    try {
      const body = await request.json();
      validatedData = await validateRequest(body, receiptsValidationSchema);
    } catch (error) {
      if (error instanceof ValidationError) {
        return NextResponse.json(
          { success: false, error: 'Invalid request', issues: error.issues },
          { status: 400 }
        );
      }
      throw error;
    }
    
    const { receipts } = validatedData;
    
    if (!Array.isArray(receipts) || receipts.length === 0) {
      return NextResponse.json({
        isValid: false,
        errors: [{
          id: 'EMPTY_LIST',
          field: 'receipts',
          message: 'No receipts to validate',
          severity: 'error' as const,
        }],
        warnings: [],
        info: [],
      });
    }
    
    // Get tokens from Redis (if available)
    const tokens = await getTokens('quickbooks', sessionId);
    
    const errors: ValidationIssue[] = [];
    const warnings: ValidationIssue[] = [];
    const info: ValidationIssue[] = [];
    
    // Local validation (always performed)
    receipts.forEach((receipt: Receipt, index: number) => {
      // Required fields validation
      if (!receipt.merchantName || receipt.merchantName.trim() === '') {
        errors.push({
          id: 'QB_MISSING_MERCHANT',
          field: 'merchantName',
          message: `Receipt ${index + 1}: Missing merchant name`,
          severity: 'error',
          suggestedFix: 'Add a merchant name to this receipt',
        });
      }
      
      if (!receipt.date) {
        errors.push({
          id: 'QB_MISSING_DATE',
          field: 'date',
          message: `Receipt ${index + 1}: Missing date`,
          severity: 'error',
          suggestedFix: 'Add a date to this receipt',
        });
      }
      
      if (!receipt.totalAmount || receipt.totalAmount <= 0) {
        errors.push({
          id: 'QB_INVALID_AMOUNT',
          field: 'totalAmount',
          message: `Receipt ${index + 1}: Invalid total amount`,
          severity: 'error',
          actualValue: receipt.totalAmount,
          suggestedFix: 'Add a valid positive amount',
        });
      }
      
      // QuickBooks specific validations
      if (receipt.date) {
        const date = new Date(receipt.date);
        const now = new Date();
        
        // Future dates not allowed
        if (date > now) {
          errors.push({
            id: 'QB_FUTURE_DATE',
            field: 'date',
            message: `Receipt ${index + 1}: Future dates not allowed`,
            severity: 'error',
            actualValue: receipt.date,
          });
        }
        
        // Warn about old dates
        const twoYearsAgo = new Date();
        twoYearsAgo.setFullYear(twoYearsAgo.getFullYear() - 2);
        if (date < twoYearsAgo) {
          warnings.push({
            id: 'QB_OLD_DATE',
            field: 'date',
            message: `Receipt ${index + 1}: Date is more than 2 years old`,
            severity: 'warning',
            actualValue: receipt.date,
          });
        }
      }
      
      // Check for duplicates
      const duplicates = receipts.filter((r: Receipt, i: number) => 
        i !== index &&
        r.merchantName === receipt.merchantName &&
        r.totalAmount === receipt.totalAmount &&
        r.date === receipt.date
      );
      
      if (duplicates.length > 0) {
        warnings.push({
          id: 'QB_POSSIBLE_DUPLICATE',
          field: 'receipt',
          message: `Receipt ${index + 1}: Possible duplicate transaction`,
          severity: 'warning',
        });
      }
    });
    
    // API validation (if authenticated)
    if (tokens && tokens.accessToken && !tokens.expired) {
      try {
        // Test QuickBooks API connection
        const companyResponse = await fetch(
          `https://sandbox-quickbooks.api.intuit.com/v3/company/${tokens.realmId}/companyinfo/${tokens.realmId}`,
          {
            headers: {
              'Authorization': `Bearer ${tokens.accessToken}`,
              'Accept': 'application/json',
            },
          }
        );
        
        if (companyResponse.ok) {
          info.push({
            id: 'QB_API_VALIDATED',
            field: 'system',
            message: 'Validated against live QuickBooks API',
            severity: 'info',
          });
        } else if (companyResponse.status === 401) {
          warnings.push({
            id: 'QB_TOKEN_EXPIRED',
            field: 'auth',
            message: 'QuickBooks token may be expired. Please re-authenticate.',
            severity: 'warning',
          });
        }
      } catch (apiError) {
        warnings.push({
          id: 'QB_API_ERROR',
          field: 'system',
          message: 'Could not validate with QuickBooks API',
          severity: 'warning',
        });
      }
    } else if (!tokens) {
      info.push({
        id: 'QB_NOT_AUTHENTICATED',
        field: 'auth',
        message: 'Not authenticated with QuickBooks. Using local validation only.',
        severity: 'info',
      });
    }
    
    const response = NextResponse.json({
      isValid: errors.length === 0,
      errors,
      warnings,
      info,
      metadata: {
        format: 'quickbooks',
        receiptCount: receipts.length,
        validatedAt: new Date().toISOString(),
        apiValidation: tokens && !tokens.expired,
      },
    });
    
    // Add cache headers - cache successful validations for 5 minutes
    if (errors.length === 0) {
      response.headers.set('Cache-Control', 'private, max-age=300, stale-while-revalidate=60');
    } else {
      // Don't cache validation errors
      response.headers.set('Cache-Control', 'no-cache, no-store, must-revalidate');
    }
    
    return response;
  } catch (error) {
    console.error('QuickBooks validation error:', error);
    return NextResponse.json(
      { 
        success: false,
        error: 'Validation failed',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}