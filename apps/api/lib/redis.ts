import { Redis } from '@upstash/redis';

// Initialize Redis client
export const redis = new Redis({
  url: process.env.KV_REST_API_URL!,
  token: process.env.KV_REST_API_TOKEN!,
});

// Token storage types
export interface TokenData {
  accessToken: string;
  refreshToken?: string;
  expiresIn?: number;
  realmId?: string; // QuickBooks specific
  tenantId?: string; // Xero specific
}

// Store OAuth tokens with proper TTL
export async function storeTokens(
  provider: 'quickbooks' | 'xero',
  sessionId: string,
  tokens: TokenData
) {
  const key = `tokens:${provider}:${sessionId}`;
  const ttl = tokens.expiresIn || 3600; // Default 1 hour
  
  // Store main token data with expiry
  await redis.setex(key, ttl, JSON.stringify({
    accessToken: tokens.accessToken,
    realmId: tokens.realmId,
    tenantId: tokens.tenantId,
    expiresAt: Date.now() + (ttl * 1000),
  }));
  
  // Store refresh token separately with longer TTL (30 days)
  if (tokens.refreshToken) {
    await redis.setex(
      `refresh:${provider}:${sessionId}`,
      30 * 24 * 60 * 60,
      tokens.refreshToken
    );
  }
  
  // Store realm/tenant ID for longer period (90 days)
  if (tokens.realmId) {
    await redis.setex(
      `realm:quickbooks:${sessionId}`,
      90 * 24 * 60 * 60,
      tokens.realmId
    );
  }
  
  if (tokens.tenantId) {
    await redis.setex(
      `tenant:xero:${sessionId}`,
      90 * 24 * 60 * 60,
      tokens.tenantId
    );
  }
}

// Retrieve OAuth tokens
export async function getTokens(provider: string, sessionId: string) {
  const key = `tokens:${provider}:${sessionId}`;
  const data = await redis.get(key);
  
  if (!data) {
    return null;
  }
  
  const tokens = JSON.parse(data as string);
  
  // Check if token is expired
  if (tokens.expiresAt && tokens.expiresAt < Date.now()) {
    // Try to refresh
    const refreshToken = await redis.get(`refresh:${provider}:${sessionId}`);
    if (refreshToken) {
      return {
        ...tokens,
        expired: true,
        refreshToken: refreshToken as string,
      };
    }
    return null;
  }
  
  return tokens;
}

// Get refresh token
export async function getRefreshToken(provider: string, sessionId: string) {
  const key = `refresh:${provider}:${sessionId}`;
  return await redis.get(key) as string | null;
}

// Store OAuth state for verification
export async function storeOAuthState(state: string, data: any) {
  // Store with 30 minute TTL for OAuth flow completion (increased from 10)
  await redis.setex(`state:${state}`, 1800, JSON.stringify(data));
  console.log(`Stored OAuth state: ${state} with data:`, data);
}

// Verify and retrieve OAuth state
export async function verifyOAuthState(state: string) {
  console.log(`Verifying OAuth state: ${state}`);
  const data = await redis.get(`state:${state}`);
  if (!data) {
    console.error(`State not found or expired: ${state}`);
    return null;
  }
  
  console.log(`State verified successfully: ${state}`);
  // Delete state after retrieval (one-time use)
  await redis.del(`state:${state}`);
  
  return JSON.parse(data as string);
}

// Store PKCE verifier for Xero
export async function storePKCEVerifier(state: string, verifier: string, sessionId: string) {
  await redis.setex(
    `pkce:${state}`,
    600, // 10 minutes
    JSON.stringify({ verifier, sessionId })
  );
}

// Get and delete PKCE verifier
export async function getPKCEVerifier(state: string) {
  const data = await redis.get(`pkce:${state}`);
  if (!data) {
    return null;
  }
  
  // Delete after retrieval
  await redis.del(`pkce:${state}`);
  
  return JSON.parse(data as string);
}