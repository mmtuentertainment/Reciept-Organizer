import { NextRequest, NextResponse } from 'next/server';
import { verifyOAuthState, storeTokens } from '@/lib/redis';
import { createSessionToken } from '@/lib/jwt';

type OAuthCallbackSuccess = {
  success: true;
  sessionId: string;
  sessionToken: string;
  realmId: string;
  deepLink: string;
  expiresIn: number;
  status: number;
};

type OAuthCallbackError = {
  success: false;
  error: string;
  details?: string;
  status: number;
};

type OAuthCallbackResult = OAuthCallbackSuccess | OAuthCallbackError;

// Shared logic for processing OAuth callback
async function processOAuthCallback(code: string, state: string, realmId: string): Promise<OAuthCallbackResult> {
  // Log minimal info for debugging without exposing sensitive data
  console.log('Processing OAuth callback');
  
  // Verify state parameter
  const stateData = await verifyOAuthState(state);
  if (!stateData) {
    console.error('State verification failed for:', state);
    return {
      success: false,
      error: 'Invalid or expired state parameter. Please try logging in again.',
      status: 400
    };
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
  
  // Read response body once
  const responseText = await tokenResponse.text();
  // Token response received
  
  if (!tokenResponse.ok) {
    console.error('Token exchange failed with status:', tokenResponse.status);
    
    // Try to parse error response
    let errorMessage = 'Failed to exchange code for tokens';
    try {
      const errorJson = JSON.parse(responseText);
      errorMessage = errorJson.error_description || errorJson.error || errorMessage;
    } catch {
      // If not JSON, use raw text
      errorMessage = responseText || errorMessage;
    }
    
    return {
      success: false,
      error: errorMessage,
      details: `Token exchange failed with status ${tokenResponse.status}`,
      status: 400
    };
  }
  
  let tokens;
  try {
    tokens = JSON.parse(responseText);
  } catch (parseError) {
    console.error('Failed to parse token response as JSON');
    return {
      success: false,
      error: 'Invalid response from QuickBooks token endpoint',
      details: 'The authorization server returned an invalid response format',
      status: 500
    };
  }
  // Store tokens in Redis
  
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
  
  // OAuth callback processed successfully
  
  // Return success with deep link for Flutter
  return {
    success: true,
    sessionId,
    sessionToken,
    realmId,
    deepLink: `${process.env.FLUTTER_APP_SCHEME}://oauth/success?session=${sessionId}&provider=quickbooks`,
    expiresIn: tokens.expires_in,
    status: 200
  };
}
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
  
  // GET callback received
  
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