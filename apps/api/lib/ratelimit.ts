import { Ratelimit } from '@upstash/ratelimit';
import { redis } from './redis';
import { NextRequest, NextResponse } from 'next/server';

// Create different rate limiters for different endpoints
export const rateLimiters = {
  // Auth endpoints - more restrictive
  auth: new Ratelimit({
    redis,
    limiter: Ratelimit.slidingWindow(5, '1 m'), // 5 requests per minute
    analytics: true,
    prefix: 'rl:auth',
  }),
  
  // Validation endpoints - moderate
  validation: new Ratelimit({
    redis,
    limiter: Ratelimit.slidingWindow(20, '1 m'), // 20 requests per minute
    analytics: true,
    prefix: 'rl:validation',
  }),
  
  // General API - more permissive
  api: new Ratelimit({
    redis,
    limiter: Ratelimit.slidingWindow(60, '1 m'), // 60 requests per minute
    analytics: true,
    prefix: 'rl:api',
  }),
};

// Helper function to apply rate limiting
export async function rateLimit(
  request: NextRequest,
  limiterType: 'auth' | 'validation' | 'api' = 'api'
): Promise<{ success: boolean; remaining?: number; reset?: number }> {
  // Get identifier - prefer session ID, fall back to IP
  const sessionId = request.headers.get('x-session-id');
  const forwarded = request.headers.get('x-forwarded-for');
  const ip = forwarded ? forwarded.split(',')[0] : 'unknown';
  const identifier = sessionId || ip;
  
  const limiter = rateLimiters[limiterType];
  const { success, limit, reset, remaining } = await limiter.limit(identifier);
  
  return {
    success,
    remaining,
    reset,
  };
}

// Middleware helper for rate limiting responses
export function rateLimitResponse(
  success: boolean,
  remaining?: number,
  reset?: number
): NextResponse | null {
  if (!success) {
    return NextResponse.json(
      {
        error: 'Too many requests',
        message: 'You have exceeded the rate limit. Please try again later.',
        retryAfter: reset ? new Date(reset).toISOString() : undefined,
      },
      {
        status: 429,
        headers: {
          'X-RateLimit-Limit': '60',
          'X-RateLimit-Remaining': remaining?.toString() || '0',
          'X-RateLimit-Reset': reset?.toString() || '',
          'Retry-After': reset ? Math.floor((reset - Date.now()) / 1000).toString() : '60',
        },
      }
    );
  }
  return null;
}