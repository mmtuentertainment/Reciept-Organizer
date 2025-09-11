import { NextResponse } from 'next/server';

export async function GET() {
  const response = NextResponse.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    environment: {
      hasQuickBooksConfig: !!(process.env.QB_CLIENT_ID && process.env.QB_CLIENT_SECRET),
      hasXeroConfig: !!process.env.XERO_CLIENT_ID,
      hasRedisConfig: !!(process.env.KV_REST_API_URL && process.env.KV_REST_API_TOKEN),
      hasJWTSecret: !!process.env.JWT_SECRET,
      nodeEnv: process.env.NODE_ENV,
    },
  });
  
  // Cache health check for 1 minute
  response.headers.set('Cache-Control', 'public, max-age=60, stale-while-revalidate=30');
  
  return response;
}