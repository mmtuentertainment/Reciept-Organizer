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
  return await new SignJWT(payload as any)
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime('24h')
    .sign(secret);
}

export async function verifySessionToken(token: string): Promise<SessionPayload | null> {
  try {
    const { payload } = await jwtVerify(token, secret);
    return payload as SessionPayload;
  } catch (error) {
    return null;
  }
}