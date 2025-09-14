import 'react-native-url-polyfill/auto'
import { createClient } from '@supabase/supabase-js'
import * as SecureStore from 'expo-secure-store'
import { Platform } from 'react-native'

const supabaseUrl = 'https://xbadaalqaeszooyxuoac.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhiYWRhYWxxYWVzem9veXh1b2FjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc3ODE1MzAsImV4cCI6MjA3MzM1NzUzMH0.PY-aQ6bjYUPaTL2o2twviFf5AJTSYR0gyKUkQb08OGc'

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