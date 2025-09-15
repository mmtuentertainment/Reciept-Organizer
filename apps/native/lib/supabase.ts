import 'react-native-url-polyfill/auto'
import { createClient } from '@supabase/supabase-js'
import * as SecureStore from 'expo-secure-store'
import { Platform } from 'react-native'

// These MUST be set in your .env.local file - NEVER hardcode them
const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY!

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error(
    'Missing Supabase environment variables. Please create a .env.local file with EXPO_PUBLIC_SUPABASE_URL and EXPO_PUBLIC_SUPABASE_ANON_KEY'
  )
}

// Custom storage adapter for Expo SecureStore
const ExpoSecureStoreAdapter = {
  getItem: async (key: string) => {
    if (Platform.OS === 'web') {
      try {
        return window.localStorage.getItem(key)
      } catch {
        return null
      }
    }
    return SecureStore.getItemAsync(key)
  },
  setItem: async (key: string, value: string) => {
    if (Platform.OS === 'web') {
      try {
        window.localStorage.setItem(key, value)
      } catch {}
      return
    }
    return SecureStore.setItemAsync(key, value)
  },
  removeItem: async (key: string) => {
    if (Platform.OS === 'web') {
      try {
        window.localStorage.removeItem(key)
      } catch {}
      return
    }
    return SecureStore.deleteItemAsync(key)
  },
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    storage: ExpoSecureStoreAdapter,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
})