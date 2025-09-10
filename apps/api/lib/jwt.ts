import { SignJWT, jwtVerify } from 'jose';

// Ensure JWT_SECRET is set in production
if (!process.env.JWT_SECRET) {
  throw new Error('JWT_SECRET environment variable is required');
}

const secret = new TextEncoder().encode(process.env.JWT_SECRET);

export interface SessionPayload {
  sessionId: string;
  provider?: string;
  authenticated?: boolean;
  exp?: number;
  [key: string]: any; // Allow additional properties for JWT compatibility
}

export async function createSessionToken(payload: SessionPayload): Promise<string> {
  // Convert to plain object for SignJWT
  const jwtPayload = {
    sessionId: payload.sessionId,
    provider: payload.provider,
    authenticated: payload.authenticated,
  };
  
  return await new SignJWT(jwtPayload)
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime('24h')
    .sign(secret);
}

export async function verifySessionToken(token: string): Promise<SessionPayload | null> {
  try {
    const { payload } = await jwtVerify(token, secret);
    // Extract our custom fields from the JWT payload
    return {
      sessionId: payload.sessionId as string,
      provider: payload.provider as string | undefined,
      authenticated: payload.authenticated as boolean | undefined,
      exp: payload.exp as number | undefined,
    };
  } catch (error) {
    return null;
  }
}