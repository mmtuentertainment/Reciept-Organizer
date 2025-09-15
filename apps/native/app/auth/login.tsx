import { useState } from 'react';
import { View, Text, Alert, ScrollView, Pressable } from 'react-native';
import { Link, router } from 'expo-router';
import { useAuth } from '../../lib/contexts/AuthContext';
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
  const { signIn, isOffline } = useAuth();

  async function signInWithEmail() {
    if (!email || !password) {
      Alert.alert('Error', 'Please enter email and password');
      return;
    }

    setLoading(true);
    const { error } = await signIn(email, password);

    if (error) {
      Alert.alert('Error', error.message);
    } else {
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
                Sign in to manage your receipts
              </Text>
              {isOffline && (
                <View className="bg-yellow-100 p-2 rounded">
                  <Text className="text-yellow-800 text-sm">
                    Offline mode - Using cached credentials
                  </Text>
                </View>
              )}
            </VStack>

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