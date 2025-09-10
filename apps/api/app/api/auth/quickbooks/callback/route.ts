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
  console.log('Processing OAuth callback - state:', state, 'code:', code?.substring(0, 10) + '...', 'realmId:', realmId);
  
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
  
  console.log('Exchanging code for tokens...');
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
  console.log('Token response status:', tokenResponse.status);
  
  if (!tokenResponse.ok) {
    console.error('Token exchange failed:', {
      status: tokenResponse.status,
      error: responseText,
      redirectUri: process.env.QB_REDIRECT_URI,
      hasClientId: !!process.env.QB_CLIENT_ID,
      hasClientSecret: !!process.env.QB_CLIENT_SECRET
    });
    
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
    console.log('Token response received, attempting to parse...');
    tokens = JSON.parse(responseText);
  } catch (parseError) {
    console.error('Failed to parse token response as JSON:', parseError);
    console.error('Response text was:', responseText);
    return {
      success: false,
      error: 'Invalid response from QuickBooks token endpoint',
      details: 'The authorization server returned an invalid response format',
      status: 500
    };
  }
  console.log('Tokens parsed successfully, storing in Redis...');
  
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
  
  console.log('OAuth callback processed successfully');
  
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
    
    const result = await processOAuthCallback(code, state, realmId);
    
    return NextResponse.json(
      result,
      { status: result.status }
    );
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
  
  console.log('GET callback received:', {
    code: code ? 'present' : 'missing',
    state: state ? 'present' : 'missing',
    realmId: realmId ? 'present' : 'missing',
    error: error,
    url: request.url
  });
  
  // If there's an error from QuickBooks
  if (error) {
    const errorDescription = searchParams.get('error_description');
    return new NextResponse(
      `
      <html>
        <head>
          <title>Authentication Failed</title>
          <style>
            body { font-family: system-ui, -apple-system, sans-serif; padding: 2rem; text-align: center; }
            h1 { color: #dc2626; }
            .error-details { background: #fef2f2; border: 1px solid #fecaca; padding: 1rem; border-radius: 0.5rem; margin: 2rem auto; max-width: 600px; }
          </style>
        </head>
        <body>
          <h1>Authentication Failed</h1>
          <div class="error-details">
            <p><strong>Error from QuickBooks:</strong> ${error}</p>
            ${errorDescription ? `<p>${errorDescription}</p>` : ''}
            <p>Please close this window and try again.</p>
          </div>
        </body>
      </html>
      `,
      { 
        status: 400,
        headers: { 'Content-Type': 'text/html' }
      }
    );
  }
  
  // Check required parameters
  if (!code || !state) {
    console.error('Missing required parameters:', { code: !!code, state: !!state });
    return new NextResponse(
      `
      <html>
        <head>
          <title>Authentication Failed</title>
          <style>
            body { font-family: system-ui, -apple-system, sans-serif; padding: 2rem; text-align: center; }
            h1 { color: #dc2626; }
            .error-details { background: #fef2f2; border: 1px solid #fecaca; padding: 1rem; border-radius: 0.5rem; margin: 2rem auto; max-width: 600px; }
          </style>
        </head>
        <body>
          <h1>Authentication Failed</h1>
          <div class="error-details">
            <p><strong>Error:</strong> Missing required parameters</p>
            <p>The OAuth callback is missing required information.</p>
            <p>Please try logging in again.</p>
          </div>
        </body>
      </html>
      `,
      { 
        status: 400,
        headers: { 'Content-Type': 'text/html' }
      }
    );
  }
  
  // Process the callback directly (avoid internal HTTP request)
  try {
    const result = await processOAuthCallback(code, state, realmId || '');
  
  if (result.success) {
    // Redirect to success page instead of deep link
    const successUrl = new URL('/oauth/success', request.url);
    successUrl.searchParams.set('provider', 'quickbooks');
    successUrl.searchParams.set('session', result.sessionId);
    return NextResponse.redirect(successUrl);
  } else {
    console.error('OAuth callback failed with result:', result);
    return new NextResponse(
      `
      <html>
        <head>
          <title>Authentication Failed</title>
          <style>
            body { font-family: system-ui, -apple-system, sans-serif; padding: 2rem; text-align: center; }
            h1 { color: #dc2626; }
            .error-details { background: #fef2f2; border: 1px solid #fecaca; padding: 1rem; border-radius: 0.5rem; margin: 2rem auto; max-width: 600px; }
            .retry-btn { background: #3b82f6; color: white; padding: 0.75rem 1.5rem; border: none; border-radius: 0.375rem; cursor: pointer; text-decoration: none; display: inline-block; margin-top: 1rem; }
          </style>
        </head>
        <body>
          <h1>Authentication Failed</h1>
          <div class="error-details">
            <p><strong>Error:</strong> ${result.error}</p>
            ${result.details ? `<p><strong>Details:</strong> ${result.details}</p>` : ''}
            <p>This usually happens when:</p>
            <ul style="text-align: left;">
              <li>The authorization code has expired</li>
              <li>The OAuth state doesn't match</li>
              <li>The redirect URI doesn't match exactly</li>
            </ul>
          </div>
          <a href="/quickbooks" class="retry-btn">Try Again</a>
        </body>
      </html>
      `,
      { 
        status: result.status || 400,
        headers: { 'Content-Type': 'text/html' }
      }
    );
  }
  } catch (error) {
    console.error('Callback processing error:', error);
    let errorMessage = 'Unknown error occurred';
    let errorDetails = '';
    
    if (error instanceof Error) {
      errorMessage = error.message;
    } else if (typeof error === 'object' && error !== null) {
      // Handle result object with error property
      const err = error as any;
      if (err.error) {
        errorMessage = err.error;
        errorDetails = err.details || '';
      } else {
        errorMessage = JSON.stringify(error);
      }
    } else {
      errorMessage = String(error);
    }
    
    return new NextResponse(
      `
      <html>
        <head>
          <title>Authentication Failed</title>
          <style>
            body { font-family: system-ui, -apple-system, sans-serif; padding: 2rem; text-align: center; }
            h1 { color: #dc2626; }
            .error-details { background: #fef2f2; border: 1px solid #fecaca; padding: 1rem; border-radius: 0.5rem; margin: 2rem auto; max-width: 600px; }
            .retry-btn { background: #3b82f6; color: white; padding: 0.75rem 1.5rem; border: none; border-radius: 0.375rem; cursor: pointer; text-decoration: none; display: inline-block; margin-top: 1rem; }
          </style>
        </head>
        <body>
          <h1>Authentication Failed</h1>
          <div class="error-details">
            <p><strong>Error:</strong> ${errorMessage}</p>
            ${errorDetails ? `<p><strong>Details:</strong> ${errorDetails}</p>` : ''}
            <p>This usually happens when:</p>
            <ul style="text-align: left;">
              <li>The authorization code has expired</li>
              <li>The OAuth state doesn't match</li>
              <li>The redirect URI doesn't match exactly</li>
            </ul>
          </div>
          <a href="/quickbooks" class="retry-btn">Try Again</a>
        </body>
      </html>
      `,
      { 
        status: 500,
        headers: { 'Content-Type': 'text/html' }
      }
    );
  }
}