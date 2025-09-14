import * as SecureStore from 'expo-secure-store';
import * as Crypto from 'expo-crypto';
import NetInfo from '@react-native-community/netinfo';
import { Session, User } from '@supabase/supabase-js';

const CACHED_CREDENTIALS_KEY = 'offline_auth_credentials';
const CACHED_SESSION_KEY = 'offline_auth_session';
const LAST_SYNC_KEY = 'offline_auth_last_sync';

export class OfflineAuthService {
  /**
   * Cache user credentials securely for offline authentication
   */
  static async cacheCredentials(email: string, password: string): Promise<void> {
    try {
      const passwordHash = await Crypto.digestStringAsync(
        Crypto.CryptoDigestAlgorithm.SHA256,
        password
      );

      const credentials = JSON.stringify({
        email,
        passwordHash,
        cachedAt: new Date().toISOString(),
      });

      await SecureStore.setItemAsync(CACHED_CREDENTIALS_KEY, credentials);
    } catch (error) {
      console.error('Error caching credentials:', error);
    }
  }

  /**
   * Cache session for offline access
   */
  static async cacheSession(session: Session): Promise<void> {
    try {
      const sessionData = JSON.stringify({
        access_token: session.access_token,
        refresh_token: session.refresh_token,
        expires_at: session.expires_at,
        user: session.user,
        cachedAt: new Date().toISOString(),
      });

      await SecureStore.setItemAsync(CACHED_SESSION_KEY, sessionData);
    } catch (error) {
      console.error('Error caching session:', error);
    }
  }

  /**
   * Verify offline credentials
   */
  static async verifyOfflineCredentials(
    email: string,
    password: string
  ): Promise<boolean> {
    try {
      const cachedData = await SecureStore.getItemAsync(CACHED_CREDENTIALS_KEY);
      if (!cachedData) return false;

      const credentials = JSON.parse(cachedData);
      const passwordHash = await Crypto.digestStringAsync(
        Crypto.CryptoDigestAlgorithm.SHA256,
        password
      );

      return credentials.email === email && credentials.passwordHash === passwordHash;
    } catch (error) {
      console.error('Error verifying offline credentials:', error);
      return false;
    }
  }

  /**
   * Get cached session for offline mode
   */
  static async getCachedSession(): Promise<Session | null> {
    try {
      const sessionData = await SecureStore.getItemAsync(CACHED_SESSION_KEY);
      if (!sessionData) return null;

      const data = JSON.parse(sessionData);

      // Check if session is expired
      if (this.isSessionExpired(data.expires_at)) {
        return null;
      }

      // Reconstruct session from cached data
      return {
        access_token: data.access_token,
        refresh_token: data.refresh_token,
        expires_at: data.expires_at,
        expires_in: data.expires_at - Math.floor(Date.now() / 1000),
        token_type: 'bearer',
        user: data.user as User,
      };
    } catch (error) {
      console.error('Error getting cached session:', error);
      return null;
    }
  }

  /**
   * Clear all cached authentication data
   */
  static async clearCache(): Promise<void> {
    try {
      await SecureStore.deleteItemAsync(CACHED_CREDENTIALS_KEY);
      await SecureStore.deleteItemAsync(CACHED_SESSION_KEY);
      await SecureStore.deleteItemAsync(LAST_SYNC_KEY);
    } catch (error) {
      console.error('Error clearing cache:', error);
    }
  }

  /**
   * Check if offline mode is available
   */
  static async isOfflineModeAvailable(): Promise<boolean> {
    try {
      const credentials = await SecureStore.getItemAsync(CACHED_CREDENTIALS_KEY);
      const session = await SecureStore.getItemAsync(CACHED_SESSION_KEY);
      return credentials !== null && session !== null;
    } catch {
      return false;
    }
  }

  /**
   * Check network connectivity
   */
  static async isOnline(): Promise<boolean> {
    const netInfo = await NetInfo.fetch();
    return netInfo.isConnected === true && netInfo.isInternetReachable !== false;
  }

  /**
   * Update last sync timestamp
   */
  static async updateLastSync(): Promise<void> {
    try {
      await SecureStore.setItemAsync(LAST_SYNC_KEY, new Date().toISOString());
    } catch (error) {
      console.error('Error updating last sync:', error);
    }
  }

  /**
   * Get last sync timestamp
   */
  static async getLastSync(): Promise<Date | null> {
    try {
      const timestamp = await SecureStore.getItemAsync(LAST_SYNC_KEY);
      return timestamp ? new Date(timestamp) : null;
    } catch {
      return null;
    }
  }

  /**
   * Check if data needs sync (older than 24 hours)
   */
  static async needsSync(): Promise<boolean> {
    const lastSync = await this.getLastSync();
    if (!lastSync) return true;

    const hoursSinceSync = (Date.now() - lastSync.getTime()) / (1000 * 60 * 60);
    return hoursSinceSync > 24;
  }

  /**
   * Check if session is expired
   */
  private static isSessionExpired(expiresAt?: number): boolean {
    if (!expiresAt) return true;

    // Add 5 minute buffer before actual expiry
    const bufferTime = Date.now() / 1000 + 5 * 60;
    return bufferTime > expiresAt;
  }
}