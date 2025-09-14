import React, { createContext, useContext, useEffect, useState, useCallback } from 'react';
import { Session, User, AuthChangeEvent } from '@supabase/supabase-js';
import { supabase } from '../supabase';
import { OfflineAuthService } from '../services/offlineAuthService';
import { useInactivityMonitor } from '../services/inactivityMonitor';
import { Alert } from 'react-native';

interface AuthContextType {
  session: Session | null;
  user: User | null;
  isLoading: boolean;
  isOffline: boolean;
  signIn: (email: string, password: string) => Promise<{ error: Error | null }>;
  signUp: (email: string, password: string) => Promise<{ error: Error | null }>;
  signOut: () => Promise<void>;
  refreshSession: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [session, setSession] = useState<Session | null>(null);
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isOffline, setIsOffline] = useState(false);

  // Handle sign out (including inactivity timeout)
  const signOut = useCallback(async () => {
    try {
      const isOnline = await OfflineAuthService.isOnline();
      if (isOnline) {
        await supabase.auth.signOut();
      }
    } catch (error) {
      console.error('Error signing out:', error);
    } finally {
      // Always clear local state and cache
      await OfflineAuthService.clearCache();
      setSession(null);
      setUser(null);
      setIsOffline(false);
    }
  }, []);

  // Set up inactivity monitoring (2 hours for mobile)
  useInactivityMonitor({
    timeout: 2 * 60 * 60 * 1000, // 2 hours in milliseconds
    onTimeout: () => {
      Alert.alert(
        'Session Expired',
        'You have been signed out due to inactivity.',
        [{ text: 'OK', onPress: signOut }]
      );
    },
    enabled: !!session,
  });

  // Initialize auth state
  useEffect(() => {
    const initializeAuth = async () => {
      try {
        // Check if online
        const isOnline = await OfflineAuthService.isOnline();
        setIsOffline(!isOnline);

        if (isOnline) {
          // Get session from Supabase
          const { data: { session } } = await supabase.auth.getSession();
          if (session) {
            setSession(session);
            setUser(session.user);
            // Cache for offline use
            await OfflineAuthService.cacheSession(session);
          }
        } else {
          // Try to use cached session
          const cachedSession = await OfflineAuthService.getCachedSession();
          if (cachedSession) {
            setSession(cachedSession);
            setUser(cachedSession.user);
          }
        }
      } catch (error) {
        console.error('Error initializing auth:', error);
      } finally {
        setIsLoading(false);
      }
    };

    initializeAuth();

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event: AuthChangeEvent, session: Session | null) => {
        setSession(session);
        setUser(session?.user ?? null);

        if (session) {
          // Cache session for offline use
          await OfflineAuthService.cacheSession(session);
        }

        if (event === 'SIGNED_OUT') {
          await OfflineAuthService.clearCache();
        }
      }
    );

    return () => {
      subscription.unsubscribe();
    };
  }, []);

  // Sign in function with offline support
  const signIn = async (email: string, password: string) => {
    try {
      const isOnline = await OfflineAuthService.isOnline();

      if (isOnline) {
        // Online authentication
        const { data, error } = await supabase.auth.signInWithPassword({
          email,
          password,
        });

        if (error) {
          return { error };
        }

        if (data.session) {
          // Cache credentials for offline use
          await OfflineAuthService.cacheCredentials(email, password);
          await OfflineAuthService.cacheSession(data.session);
          setIsOffline(false);
        }

        return { error: null };
      } else {
        // Offline authentication
        const isValid = await OfflineAuthService.verifyOfflineCredentials(email, password);

        if (isValid) {
          const cachedSession = await OfflineAuthService.getCachedSession();
          if (cachedSession) {
            setSession(cachedSession);
            setUser(cachedSession.user);
            setIsOffline(true);
            return { error: null };
          } else {
            return { error: new Error('Offline session expired. Please connect to internet.') };
          }
        } else {
          return { error: new Error('Invalid offline credentials') };
        }
      }
    } catch (error) {
      return { error: error as Error };
    }
  };

  // Sign up function
  const signUp = async (email: string, password: string) => {
    try {
      const isOnline = await OfflineAuthService.isOnline();

      if (!isOnline) {
        return { error: new Error('Network connection required for sign up') };
      }

      const { data, error } = await supabase.auth.signUp({
        email,
        password,
      });

      if (error) {
        return { error };
      }

      if (data.session) {
        // Cache credentials for offline use
        await OfflineAuthService.cacheCredentials(email, password);
        await OfflineAuthService.cacheSession(data.session);
      }

      return { error: null };
    } catch (error) {
      return { error: error as Error };
    }
  };

  // Refresh session
  const refreshSession = async () => {
    try {
      const isOnline = await OfflineAuthService.isOnline();

      if (isOnline) {
        const { data, error } = await supabase.auth.refreshSession();
        if (data.session && !error) {
          await OfflineAuthService.cacheSession(data.session);
        }
      }
    } catch (error) {
      console.error('Error refreshing session:', error);
    }
  };

  const value = {
    session,
    user,
    isLoading,
    isOffline,
    signIn,
    signUp,
    signOut,
    refreshSession,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}