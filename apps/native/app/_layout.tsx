import "../global.css";
import { useEffect } from 'react';
import { Stack } from 'expo-router';
import { GluestackUIProvider } from '@gluestack-ui/themed';
import { config } from '@gluestack-ui/config';
import { AuthProvider, useAuth } from '../lib/contexts/AuthContext';
import { useRouter, useSegments } from 'expo-router';
import { View, ActivityIndicator } from 'react-native';

function RootLayoutNav() {
  const { session, isLoading, isOffline } = useAuth();
  const router = useRouter();
  const segments = useSegments();

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
    <Stack>
      <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
      <Stack.Screen name="auth" options={{ headerShown: false }} />
      {isOffline && (
        <Stack.Screen
          name="offline-banner"
          options={{
            presentation: 'transparentModal',
            headerShown: false
          }}
        />
      )}
    </Stack>
  );
}

export default function RootLayout() {
  return (
    <GluestackUIProvider config={config}>
      <AuthProvider>
        <RootLayoutNav />
      </AuthProvider>
    </GluestackUIProvider>
  );
}