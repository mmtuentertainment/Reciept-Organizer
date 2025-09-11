import { NextRequest, NextResponse } from 'next/server';
import { getTokens } from '@/lib/redis';
import { verifySessionToken } from '@/lib/jwt';

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

// POST - Validate receipts for Xero
export async function POST(request: NextRequest) {
  try {
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
    const { receipts } = await request.json();
    
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
    const tokens = await getTokens('xero', sessionId);
    
    const errors: ValidationIssue[] = [];
    const warnings: ValidationIssue[] = [];
    const info: ValidationIssue[] = [];
    
    // Local validation (always performed)
    receipts.forEach((receipt: Receipt, index: number) => {
      // Required fields validation
      if (!receipt.merchantName || receipt.merchantName.trim() === '') {
        errors.push({
          id: 'XERO_MISSING_CONTACT',
          field: 'merchantName',
          message: `Receipt ${index + 1}: Xero requires ContactName field`,
          severity: 'error',
          suggestedFix: 'Merchant name will be used as ContactName',
        });
      }
      
      if (!receipt.date) {
        errors.push({
          id: 'XERO_MISSING_DATE',
          field: 'date',
          message: `Receipt ${index + 1}: Date is required`,
          severity: 'error',
          suggestedFix: 'Add a date to this receipt',
        });
      }
      
      if (!receipt.totalAmount || receipt.totalAmount <= 0) {
        errors.push({
          id: 'XERO_INVALID_AMOUNT',
          field: 'totalAmount',
          message: `Receipt ${index + 1}: Xero requires positive amounts`,
          severity: 'error',
          actualValue: receipt.totalAmount,
          suggestedFix: 'Add a valid positive amount',
        });
      }
      
      // Xero specific validations
      if (receipt.taxAmount && receipt.totalAmount) {
        if (receipt.taxAmount > receipt.totalAmount) {
          errors.push({
            id: 'XERO_TAX_EXCEEDS_TOTAL',
            field: 'taxAmount',
            message: `Receipt ${index + 1}: Tax amount exceeds total amount`,
            severity: 'error',
            actualValue: receipt.taxAmount,
            expectedValue: `<= ${receipt.totalAmount}`,
          });
        }
      }
      
      if (receipt.date) {
        const date = new Date(receipt.date);
        const year = date.getFullYear();
        
        if (year < 1900 || year > 2100) {
          errors.push({
            id: 'XERO_INVALID_DATE_RANGE',
            field: 'date',
            message: `Receipt ${index + 1}: Date year must be between 1900 and 2100`,
            severity: 'error',
            actualValue: year,
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
          id: 'XERO_POSSIBLE_DUPLICATE',
          field: 'receipt',
          message: `Receipt ${index + 1}: Possible duplicate transaction`,
          severity: 'warning',
        });
      }
    });
    
    // API validation (if authenticated)
    if (tokens && tokens.accessToken && !tokens.expired) {
      try {
        // Test Xero API connection
        const orgResponse = await fetch(
          'https://api.xero.com/api.xro/2.0/Organisation',
          {
            headers: {
              'Authorization': `Bearer ${tokens.accessToken}`,
              'xero-tenant-id': tokens.tenantId || '',
              'Accept': 'application/json',
            },
          }
        );
        
        if (orgResponse.ok) {
          info.push({
            id: 'XERO_API_VALIDATED',
            field: 'system',
            message: 'Validated against live Xero API',
            severity: 'info',
          });
        } else if (orgResponse.status === 401) {
          warnings.push({
            id: 'XERO_TOKEN_EXPIRED',
            field: 'auth',
            message: 'Xero token may be expired. Please re-authenticate.',
            severity: 'warning',
          });
        }
      } catch (apiError) {
        warnings.push({
          id: 'XERO_API_ERROR',
          field: 'system',
          message: 'Could not validate with Xero API',
          severity: 'warning',
        });
      }
    } else if (!tokens) {
      info.push({
        id: 'XERO_NOT_AUTHENTICATED',
        field: 'auth',
        message: 'Not authenticated with Xero. Using local validation only.',
        severity: 'info',
      });
    }
    
    const response = NextResponse.json({
      isValid: errors.length === 0,
      errors,
      warnings,
      info,
      metadata: {
        format: 'xero',
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
    console.error('Xero validation error:', error);
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