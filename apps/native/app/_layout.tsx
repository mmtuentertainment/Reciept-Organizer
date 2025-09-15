import "../global.css";
import { useEffect } from 'react';
import { Stack } from 'expo-router';
import { GluestackUIProvider } from '@gluestack-ui/themed';
import { config } from '@gluestack-ui/config';
import { supabase } from '../lib/supabase';
import { Session } from '@supabase/supabase-js';
import { useRouter, useSegments } from 'expo-router';
import { View, ActivityIndicator } from 'react-native';
import { useState } from 'react';

export default function RootLayout() {
  const [session, setSession] = useState<Session | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const router = useRouter();
  const segments = useSegments();

  useEffect(() => {
    // Check initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setIsLoading(false);
    });

    // Listen for auth changes
    const { data: authListener } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
    });

    return () => {
      authListener.subscription.unsubscribe();
    };
  }, []);

  useEffect(() => {
    if (!isLoading) {
      const inAuthGroup = segments[0] === 'auth';

      if (!session && !inAuthGroup) {
        // Redirect to login if not authenticated
        router.replace('/auth/login');
      } else if (session && inAuthGroup) {
        // Redirect to home if authenticated
        router.replace('/');
      }
    }
  }, [session, segments, isLoading]);

  if (isLoading) {
    return (
      <View className="flex-1 items-center justify-center">
        <ActivityIndicator size="large" color="#0000ff" />
      </View>
    );
  }

  return (
    <GluestackUIProvider config={config}>
      <Stack>
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
        <Stack.Screen name="auth" options={{ headerShown: false }} />
      </Stack>
    </GluestackUIProvider>
  );
}