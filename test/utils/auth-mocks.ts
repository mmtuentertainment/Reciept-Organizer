/**
 * Auth Mock Utilities for Testing
 * Provides mock authentication states and utilities for testing
 */

import { Session, User } from '@supabase/supabase-js';

// Mock user data
export const mockAuthUser: User = {
  id: 'test-user-1',
  aud: 'authenticated',
  role: 'authenticated',
  email: 'test@example.com',
  email_confirmed_at: '2024-01-01T00:00:00Z',
  phone: '',
  confirmation_sent_at: '2024-01-01T00:00:00Z',
  confirmed_at: '2024-01-01T00:00:00Z',
  recovery_sent_at: '',
  last_sign_in_at: '2024-01-01T00:00:00Z',
  app_metadata: {
    provider: 'email',
    providers: ['email']
  },
  user_metadata: {
    full_name: 'Test User',
    username: 'testuser1'
  },
  identities: [],
  created_at: '2024-01-01T00:00:00Z',
  updated_at: '2024-01-01T00:00:00Z'
};

export const mockAdminUser: User = {
  ...mockAuthUser,
  id: 'admin-user-1',
  email: 'admin@example.com',
  role: 'admin',
  user_metadata: {
    full_name: 'Admin User',
    username: 'adminuser'
  }
};

// Mock session
export const mockSession: Session = {
  access_token: 'mock-access-token-xyz',
  refresh_token: 'mock-refresh-token-abc',
  expires_in: 3600,
  expires_at: Date.now() / 1000 + 3600,
  token_type: 'bearer',
  user: mockAuthUser
};

export const mockExpiredSession: Session = {
  ...mockSession,
  expires_at: Date.now() / 1000 - 3600 // Expired 1 hour ago
};

// Mock Supabase client
export const createMockSupabaseClient = () => {
  return {
    auth: {
      getSession: jest.fn().mockResolvedValue({
        data: { session: mockSession },
        error: null
      }),
      getUser: jest.fn().mockResolvedValue({
        data: { user: mockAuthUser },
        error: null
      }),
      signInWithPassword: jest.fn().mockResolvedValue({
        data: { session: mockSession, user: mockAuthUser },
        error: null
      }),
      signUp: jest.fn().mockResolvedValue({
        data: { session: mockSession, user: mockAuthUser },
        error: null
      }),
      signOut: jest.fn().mockResolvedValue({
        error: null
      }),
      refreshSession: jest.fn().mockResolvedValue({
        data: { session: mockSession },
        error: null
      }),
      onAuthStateChange: jest.fn().mockReturnValue({
        data: {
          subscription: {
            unsubscribe: jest.fn()
          }
        }
      }),
      setSession: jest.fn().mockResolvedValue({
        data: { session: mockSession },
        error: null
      })
    },
    from: jest.fn(() => ({
      select: jest.fn().mockReturnThis(),
      insert: jest.fn().mockReturnThis(),
      update: jest.fn().mockReturnThis(),
      delete: jest.fn().mockReturnThis(),
      eq: jest.fn().mockReturnThis(),
      single: jest.fn().mockResolvedValue({
        data: {},
        error: null
      }),
      order: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis()
    })),
    storage: {
      from: jest.fn(() => ({
        upload: jest.fn().mockResolvedValue({
          data: { path: 'test/path' },
          error: null
        }),
        getPublicUrl: jest.fn().mockReturnValue({
          data: { publicUrl: 'https://test.storage.url/file' }
        })
      }))
    },
    channel: jest.fn(() => ({
      on: jest.fn().mockReturnThis(),
      subscribe: jest.fn().mockReturnThis()
    }))
  };
};

// Test helper to setup auth mocks
export const setupAuthMocks = () => {
  const mockClient = createMockSupabaseClient();

  // Mock the Supabase module
  jest.mock('@supabase/supabase-js', () => ({
    createClient: jest.fn(() => mockClient)
  }));

  return mockClient;
};

// Helper to simulate auth state changes
export class AuthStateSimulator {
  private listeners: Array<(session: Session | null) => void> = [];

  onAuthStateChange(callback: (session: Session | null) => void) {
    this.listeners.push(callback);
    return {
      data: {
        subscription: {
          unsubscribe: () => {
            const index = this.listeners.indexOf(callback);
            if (index > -1) {
              this.listeners.splice(index, 1);
            }
          }
        }
      }
    };
  }

  simulateSignIn(user: User = mockAuthUser) {
    const session = { ...mockSession, user };
    this.listeners.forEach(listener => listener(session));
  }

  simulateSignOut() {
    this.listeners.forEach(listener => listener(null));
  }

  simulateSessionExpiry() {
    const expiredSession = { ...mockSession, expires_at: Date.now() / 1000 - 1 };
    this.listeners.forEach(listener => listener(expiredSession));
  }

  simulateTokenRefresh() {
    const refreshedSession = {
      ...mockSession,
      access_token: 'new-access-token',
      expires_at: Date.now() / 1000 + 3600
    };
    this.listeners.forEach(listener => listener(refreshedSession));
  }
}

// Test data generators
export const generateTestUser = (override: Partial<User> = {}): User => {
  const id = `test-user-${Date.now()}`;
  return {
    ...mockAuthUser,
    id,
    email: `${id}@example.com`,
    ...override
  };
};

export const generateTestSession = (user: User = mockAuthUser): Session => {
  return {
    ...mockSession,
    user,
    access_token: `mock-token-${Date.now()}`,
    expires_at: Date.now() / 1000 + 3600
  };
};

// Feature flag mock
export const mockFeatureFlags = {
  auth_enabled: false,
  auth_bypass: true,
  auth_rollout_percentage: 0
};

export const setupFeatureFlagMocks = () => {
  jest.mock('../lib/feature-flags', () => ({
    FeatureFlags: {
      isEnabled: jest.fn((flag: string) => mockFeatureFlags[flag] || false),
      getValue: jest.fn((flag: string) => mockFeatureFlags[flag]),
      setFlag: jest.fn((flag: string, value: any) => {
        mockFeatureFlags[flag] = value;
      })
    }
  }));
};