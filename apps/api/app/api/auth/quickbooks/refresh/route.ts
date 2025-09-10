import { NextRequest, NextResponse } from 'next/server';
import { getRefreshToken, storeTokens } from '@/lib/redis';
import { verifySessionToken } from '@/lib/jwt';

// POST - Refresh QuickBooks access token
export async function POST(request: NextRequest) {
  try {
    // Get session from header or body
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
    
    // Get refresh token from Redis
    const refreshToken = await getRefreshToken('quickbooks', sessionId);
    if (!refreshToken) {
      return NextResponse.json(
        { success: false, error: 'No refresh token available' },
        { status: 401 }
      );
    }
    
    // Exchange refresh token for new access token
    const tokenUrl = 'https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer';
    const credentials = Buffer.from(
      `${process.env.QB_CLIENT_ID}:${process.env.QB_CLIENT_SECRET}`
    ).toString('base64');
    
    const tokenResponse = await fetch(tokenUrl, {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': `Basic ${credentials}`,
      },
      body: new URLSearchParams({
        grant_type: 'refresh_token',
        refresh_token: refreshToken,
      }),
    });
    
    if (!tokenResponse.ok) {
      const errorText = await tokenResponse.text();
      console.error('Token refresh failed:', errorText);
      return NextResponse.json(
        { 
          success: false,
          error: 'Failed to refresh token',
          details: errorText
        },
        { status: 400 }
      );
    }
    
    const tokens = await tokenResponse.json();
    
    // Store new tokens
    await storeTokens('quickbooks', sessionId, {
      accessToken: tokens.access_token,
      refreshToken: tokens.refresh_token,
      expiresIn: tokens.expires_in || 3600,
    });
    
    return NextResponse.json({
      success: true,
      expiresIn: tokens.expires_in,
      message: 'Token refreshed successfully',
    });
  } catch (error) {
    console.error('QuickBooks refresh error:', error);
    return NextResponse.json(
      { 
        success: false,
        error: 'Token refresh failed',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}