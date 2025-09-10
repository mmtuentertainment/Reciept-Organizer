import { NextResponse } from 'next/server';

export async function GET() {
  return NextResponse.json({
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
}