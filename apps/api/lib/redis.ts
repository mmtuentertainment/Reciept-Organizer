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

// OAuth state data type
export interface OAuthStateData {
  sessionId: string;
  provider: 'quickbooks' | 'xero';
  timestamp: number;
}

// PKCE verifier data type
export interface PKCEData {
  verifier: string;
  sessionId: string;
}

// Token response from Redis with expiry check
export interface StoredTokenData {
  accessToken: string;
  realmId?: string;
  tenantId?: string;
  expiresAt: number;
  expired?: boolean;
  refreshToken?: string;
}

// Store OAuth tokens with proper TTL
export async function storeTokens(
  provider: 'quickbooks' | 'xero',
  sessionId: string,
  tokens: TokenData
): Promise<void> {
  const key = `tokens:${provider}:${sessionId}`;
  const ttl = tokens.expiresIn || 3600; // Default 1 hour
  
  // Store main token data with expiry
  // Upstash automatically serializes objects, no need for JSON.stringify
  await redis.setex(key, ttl, {
    accessToken: tokens.accessToken,
    realmId: tokens.realmId,
    tenantId: tokens.tenantId,
    expiresAt: Date.now() + (ttl * 1000),
  });
  
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
export async function getTokens(provider: string, sessionId: string): Promise<StoredTokenData | null> {
  const key = `tokens:${provider}:${sessionId}`;
  const tokens = await redis.get<StoredTokenData>(key);
  
  if (!tokens) {
    return null;
  }
  
  // Check if token is expired
  if (tokens.expiresAt && tokens.expiresAt < Date.now()) {
    // Try to refresh
    const refreshToken = await redis.get<string>(`refresh:${provider}:${sessionId}`);
    if (refreshToken) {
      return {
        ...tokens,
        expired: true,
        refreshToken: refreshToken,
      };
    }
    return null;
  }
  
  return tokens;
}

// Get refresh token
export async function getRefreshToken(provider: string, sessionId: string): Promise<string | null> {
  const key = `refresh:${provider}:${sessionId}`;
  return await redis.get<string>(key);
}

// Store OAuth state for verification
export async function storeOAuthState(state: string, data: OAuthStateData): Promise<void> {
  // Store with 30 minute TTL for OAuth flow completion (increased from 10)
  // Upstash automatically serializes objects, no need for JSON.stringify
  await redis.setex(`state:${state}`, 1800, data);
  console.log(`Stored OAuth state: ${state} with data:`, data);
}

// Verify and retrieve OAuth state
export async function verifyOAuthState(state: string): Promise<OAuthStateData | null> {
  console.log(`Verifying OAuth state: ${state}`);
  const data = await redis.get<OAuthStateData>(`state:${state}`);
  if (!data) {
    console.error(`State not found or expired: ${state}`);
    return null;
  }
  
  console.log(`State verified successfully: ${state}`);
  // Delete state after retrieval (one-time use)
  await redis.del(`state:${state}`);
  
  // Upstash Redis automatically deserializes JSON, no need to parse
  return data;
}

// Store PKCE verifier for Xero
export async function storePKCEVerifier(state: string, verifier: string, sessionId: string): Promise<void> {
  // Upstash automatically serializes objects
  await redis.setex(
    `pkce:${state}`,
    600, // 10 minutes
    { verifier, sessionId }
  );
}

// Get and delete PKCE verifier
export async function getPKCEVerifier(state: string): Promise<PKCEData | null> {
  const data = await redis.get<PKCEData>(`pkce:${state}`);
  if (!data) {
    return null;
  }
  
  // Delete after retrieval
  await redis.del(`pkce:${state}`);
  
  // Upstash automatically deserializes
  return data;
}