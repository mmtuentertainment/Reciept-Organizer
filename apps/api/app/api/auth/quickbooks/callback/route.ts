import { NextRequest, NextResponse } from 'next/server';
import { verifyOAuthState, storeTokens } from '@/lib/redis';
import { createSessionToken } from '@/lib/jwt';

// POST - Handle QuickBooks OAuth callback
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { code, state, realmId } = body;
    
    // Verify state parameter
    const stateData = await verifyOAuthState(state);
    if (!stateData) {
      return NextResponse.json(
        { success: false, error: 'Invalid or expired state parameter' },
        { status: 400 }
      );
    }
    
    const { sessionId } = stateData;
    
    // Exchange authorization code for tokens
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
        grant_type: 'authorization_code',
        code: code,
        redirect_uri: process.env.QB_REDIRECT_URI!,
      }),
    });
    
    if (!tokenResponse.ok) {
      const errorText = await tokenResponse.text();
      console.error('Token exchange failed:', errorText);
      return NextResponse.json(
        { 
          success: false,
          error: 'Failed to exchange code for tokens',
          details: errorText
        },
        { status: 400 }
      );
    }
    
    const tokens = await tokenResponse.json();
    
    // Store tokens in Redis
    await storeTokens('quickbooks', sessionId, {
      accessToken: tokens.access_token,
      refreshToken: tokens.refresh_token,
      expiresIn: tokens.expires_in || 3600,
      realmId: realmId,
    });
    
    // Create authenticated session token
    const sessionToken = await createSessionToken({
      sessionId,
      provider: 'quickbooks',
      authenticated: true,
    });
    
    // Return success with deep link for Flutter
    return NextResponse.json({
      success: true,
      sessionId,
      sessionToken,
      realmId,
      deepLink: `${process.env.FLUTTER_APP_SCHEME}://oauth/success?session=${sessionId}&provider=quickbooks`,
      expiresIn: tokens.expires_in,
    });
  } catch (error) {
    console.error('QuickBooks callback error:', error);
    return NextResponse.json(
      { 
        success: false,
        error: 'OAuth callback processing failed',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}

// GET - Handle browser redirect (for web-based callback)
export async function GET(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams;
  const code = searchParams.get('code');
  const state = searchParams.get('state');
  const realmId = searchParams.get('realmId');
  const error = searchParams.get('error');
  
  // If there's an error from QuickBooks
  if (error) {
    return new NextResponse(
      `
      <html>
        <body>
          <h1>Authentication Failed</h1>
          <p>Error: ${error}</p>
          <p>Please close this window and try again.</p>
        </body>
      </html>
      `,
      { 
        status: 400,
        headers: { 'Content-Type': 'text/html' }
      }
    );
  }
  
  // Process the callback by calling our POST endpoint
  const response = await fetch(new URL('/api/auth/quickbooks/callback', request.url), {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ code, state, realmId }),
  });
  
  const result = await response.json();
  
  if (result.success) {
    // Redirect to Flutter app via deep link
    return NextResponse.redirect(result.deepLink);
  } else {
    return new NextResponse(
      `
      <html>
        <body>
          <h1>Authentication Failed</h1>
          <p>${result.error}</p>
          <p>Please close this window and try again.</p>
        </body>
      </html>
      `,
      { 
        status: 400,
        headers: { 'Content-Type': 'text/html' }
      }
    );
  }
}