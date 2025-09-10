import { NextRequest, NextResponse } from 'next/server';
import { getPKCEVerifier, storeTokens } from '@/lib/redis';
import { createSessionToken } from '@/lib/jwt';

// POST - Handle Xero OAuth callback
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { code, state } = body;
    
    // Verify state and get PKCE verifier
    const pkceData = await getPKCEVerifier(state);
    if (!pkceData) {
      return NextResponse.json(
        { success: false, error: 'Invalid or expired state parameter' },
        { status: 400 }
      );
    }
    
    const { verifier, sessionId } = pkceData;
    
    // Exchange authorization code for tokens using PKCE
    const tokenUrl = 'https://identity.xero.com/connect/token';
    
    const tokenResponse = await fetch(tokenUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'authorization_code',
        client_id: process.env.XERO_CLIENT_ID!,
        code: code,
        redirect_uri: process.env.XERO_REDIRECT_URI!,
        code_verifier: verifier,
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
    
    // Get tenant information from Xero
    const connectionsResponse = await fetch('https://api.xero.com/connections', {
      headers: {
        'Authorization': `Bearer ${tokens.access_token}`,
        'Content-Type': 'application/json',
      },
    });
    
    let tenantId = null;
    if (connectionsResponse.ok) {
      const connections = await connectionsResponse.json();
      if (connections.length > 0) {
        tenantId = connections[0].tenantId;
      }
    }
    
    // Store tokens in Redis
    await storeTokens('xero', sessionId, {
      accessToken: tokens.access_token,
      refreshToken: tokens.refresh_token,
      expiresIn: tokens.expires_in || 1800, // Xero tokens expire in 30 minutes
      tenantId: tenantId,
    });
    
    // Create authenticated session token
    const sessionToken = await createSessionToken({
      sessionId,
      provider: 'xero',
      authenticated: true,
    });
    
    // Return success with deep link for Flutter
    return NextResponse.json({
      success: true,
      sessionId,
      sessionToken,
      tenantId,
      deepLink: `${process.env.FLUTTER_APP_SCHEME}://oauth/success?session=${sessionId}&provider=xero`,
      expiresIn: tokens.expires_in,
    });
  } catch (error) {
    console.error('Xero callback error:', error);
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
  const error = searchParams.get('error');
  
  // If there's an error from Xero
  if (error) {
    const errorDescription = searchParams.get('error_description');
    return new NextResponse(
      `
      <html>
        <body>
          <h1>Authentication Failed</h1>
          <p>Error: ${error}</p>
          <p>${errorDescription || 'Please close this window and try again.'}</p>
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
  const response = await fetch(new URL('/api/auth/xero/callback', request.url), {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ code, state }),
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