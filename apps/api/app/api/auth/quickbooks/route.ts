import { NextRequest, NextResponse } from 'next/server';
import { nanoid } from 'nanoid';
import { storeOAuthState } from '@/lib/redis';
import { createSessionToken } from '@/lib/jwt';

// GET - Initiate QuickBooks OAuth flow
export async function GET(request: NextRequest) {
  try {
    // Generate unique state and session ID
    const state = nanoid();
    const sessionId = nanoid();
    
    // Store state for verification (30 min TTL as updated in redis.ts)
    console.log('Storing OAuth state:', { state, sessionId });
    await storeOAuthState(state, {
      sessionId,
      provider: 'quickbooks',
      timestamp: Date.now(),
    });
    
    // Build QuickBooks OAuth URL
    const params = new URLSearchParams({
      client_id: process.env.QB_CLIENT_ID!,
      scope: 'com.intuit.quickbooks.accounting',
      redirect_uri: process.env.QB_REDIRECT_URI!,
      response_type: 'code',
      state: state,
    });
    
    const authUrl = `https://appcenter.intuit.com/connect/oauth2?${params}`;
    
    console.log('Generated auth URL with redirect URI:', process.env.QB_REDIRECT_URI);
    
    // Create session token for Flutter app
    const sessionToken = await createSessionToken({
      sessionId,
      provider: 'quickbooks',
      authenticated: false,
    });
    
    // Return auth URL and session info
    return NextResponse.json({
      success: true,
      authUrl,
      sessionId,
      sessionToken,
      state,
      deepLink: `${process.env.FLUTTER_APP_SCHEME}://oauth/init?session=${sessionId}&provider=quickbooks`,
    });
  } catch (error) {
    console.error('QuickBooks OAuth initiation error:', error);
    return NextResponse.json(
      { 
        success: false,
        error: 'Failed to initiate OAuth flow',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}