import { NextRequest, NextResponse } from 'next/server';
import { nanoid } from 'nanoid';
import { createHash, randomBytes } from 'crypto';
import { storePKCEVerifier } from '@/lib/redis';
import { createSessionToken } from '@/lib/jwt';

// GET - Initiate Xero PKCE OAuth flow
export async function GET(request: NextRequest) {
  try {
    // Generate unique state and session ID
    const state = nanoid();
    const sessionId = nanoid();
    
    // Generate PKCE challenge (for public client security)
    const codeVerifier = randomBytes(32).toString('base64url');
    const codeChallenge = createHash('sha256')
      .update(codeVerifier)
      .digest('base64url');
    
    // Store PKCE verifier and session info for later verification
    await storePKCEVerifier(state, codeVerifier, sessionId);
    
    // Build Xero OAuth URL with PKCE
    const params = new URLSearchParams({
      response_type: 'code',
      client_id: process.env.XERO_CLIENT_ID!,
      redirect_uri: process.env.XERO_REDIRECT_URI!,
      scope: 'accounting.transactions accounting.contacts accounting.settings offline_access',
      state: state,
      code_challenge: codeChallenge,
      code_challenge_method: 'S256',
    });
    
    const authUrl = `https://login.xero.com/identity/connect/authorize?${params}`;
    
    // Create session token for Flutter app
    const sessionToken = await createSessionToken({
      sessionId,
      provider: 'xero',
      authenticated: false,
    });
    
    // Return auth URL and session info
    return NextResponse.json({
      success: true,
      authUrl,
      sessionId,
      sessionToken,
      state,
      deepLink: `${process.env.FLUTTER_APP_SCHEME}://oauth/init?session=${sessionId}&provider=xero`,
    });
  } catch (error) {
    console.error('Xero OAuth initiation error:', error);
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