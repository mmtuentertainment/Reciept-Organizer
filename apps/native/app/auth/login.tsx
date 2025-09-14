import { useState, useEffect } from 'react';
import { View, Text, Alert, ScrollView, Pressable } from 'react-native';
import { Link, router } from 'expo-router';
import { useAuth } from '../../lib/contexts/AuthContext';
import { OfflineAuthService } from '../../lib/services/offlineAuthService';
import {
  Button,
  ButtonText,
  Input,
  InputField,
  VStack,
  Heading,
  Card
} from '@gluestack-ui/themed';

export default function LoginScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [isOfflineMode, setIsOfflineMode] = useState(false);
  const { signIn, isOffline } = useAuth();

  useEffect(() => {
    checkOfflineMode();
  }, []);

  async function checkOfflineMode() {
    const isOnline = await OfflineAuthService.isOnline();
    if (!isOnline) {
      const hasOfflineAuth = await OfflineAuthService.isOfflineModeAvailable();
      setIsOfflineMode(!isOnline && hasOfflineAuth);
    }
  }

  async function signInWithEmail() {
    setLoading(true);
    const { error } = await signIn(email, password);

    if (error) {
      Alert.alert('Error', error.message);
    } else {
      if (isOffline) {
        Alert.alert('Offline Mode', 'Signed in offline. Data will sync when online.');
      }
      router.replace('/');
    }
    setLoading(false);
  }

  return (
    <ScrollView className="flex-1 bg-background">
      <View className="flex-1 px-4 pt-20">
        <Card className="p-6 bg-white rounded-lg">
          <VStack space="xl">
            <VStack space="sm">
              <Heading size="xl">Welcome Back</Heading>
              <Text className="text-muted-foreground">
                {isOfflineMode
                  ? 'Sign in offline to access cached receipts'
                  : 'Sign in to manage your receipts'}
              </Text>
            </VStack>

            {isOfflineMode && (
              <View className="p-3 bg-orange-100 rounded-lg border border-orange-300">
                <View className="flex-row items-center">
                  <Text className="text-orange-600 font-medium">⚠️ Offline Mode</Text>
                </View>
                <Text className="text-orange-600 text-sm mt-1">
                  Limited functionality available
                </Text>
              </View>
            )}

            <VStack space="md">
              <VStack space="xs">
                <Text className="text-sm font-medium">Email</Text>
                <Input variant="outline" size="md">
                  <InputField
                    placeholder="email@example.com"
                    value={email}
                    onChangeText={setEmail}
                    autoCapitalize="none"
                    keyboardType="email-address"
                  />
                </Input>
              </VStack>

              <VStack space="xs">
                <Text className="text-sm font-medium">Password</Text>
                <Input variant="outline" size="md">
                  <InputField
                    placeholder="Enter your password"
                    value={password}
                    onChangeText={setPassword}
                    secureTextEntry
                  />
                </Input>
              </VStack>
            </VStack>

            <Button
              size="lg"
              variant="solid"
              action="primary"
              isDisabled={loading}
              onPress={signInWithEmail}
            >
              <ButtonText>{loading ? 'Signing in...' : 'Sign In'}</ButtonText>
            </Button>

            <View className="flex-row justify-center">
              <Text className="text-muted-foreground">Don't have an account? </Text>
              <Link href="/auth/register" asChild>
                <Pressable>
                  <Text className="text-primary font-medium">Sign Up</Text>
                </Pressable>
              </Link>
            </View>
          </VStack>
        </Card>
      </View>
    </ScrollView>
  );
}