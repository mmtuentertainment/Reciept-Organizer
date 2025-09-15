import { useState } from 'react';
import { View, Text, Alert, ScrollView, Pressable } from 'react-native';
import { Link, router } from 'expo-router';
import { supabase } from '../../lib/supabase';
import { validatePassword } from '../../lib/validators/password';
import {
  Button,
  ButtonText,
  Input,
  InputField,
  VStack,
  Heading,
  Card,
  HStack
} from '@gluestack-ui/themed';
interface PasswordRequirementProps {
  met: boolean;
  text: string;
}

function PasswordRequirement({ met, text }: PasswordRequirementProps) {
  return (
    <HStack space="xs" className="items-center">
      <Text className={met ? 'text-green-600 font-bold' : 'text-red-500 font-bold'}>
        {met ? '✓' : '✗'}
      </Text>
      <Text className={`text-xs ${met ? 'text-green-600' : 'text-muted-foreground'}`}>
        {text}
      </Text>
    </HStack>
  );
}

export default function RegisterScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const passwordValidation = validatePassword(password);

  async function signUpWithEmail() {
    if (password !== confirmPassword) {
      Alert.alert('Error', 'Passwords do not match');
      return;
    }

    const passwordValidation = validatePassword(password);
    if (!passwordValidation.isValid) {
      Alert.alert('Invalid Password', passwordValidation.errors.join('\n'));
      return;
    }

    setLoading(true);
    const { error } = await supabase.auth.signUp({
      email: email,
      password: password,
    });

    if (error) {
      Alert.alert('Error', error.message);
    } else {
      Alert.alert(
        'Success! Check Your Email',
        'We\'ve sent you a confirmation link. Please check your email to verify your account before signing in.',
        [{ text: 'OK', onPress: () => router.replace('/auth/login') }]
      );
    }
    setLoading(false);
  }

  return (
    <ScrollView className="flex-1 bg-background">
      <View className="flex-1 px-4 pt-20">
        <Card className="p-6 bg-white rounded-lg">
          <VStack space="xl">
            <VStack space="sm">
              <Heading size="xl">Create Account</Heading>
              <Text className="text-muted-foreground">
                Sign up to start managing your receipts
              </Text>
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
                    placeholder="Create a password"
                    value={password}
                    onChangeText={setPassword}
                    secureTextEntry
                  />
                </Input>

                {password.length > 0 && (
                  <VStack space="xs" className="mt-2">
                    <Text className="text-xs text-muted-foreground mb-1">Password Requirements:</Text>
                    <PasswordRequirement
                      met={passwordValidation.requirements.minLength}
                      text="At least 8 characters"
                    />
                    <PasswordRequirement
                      met={passwordValidation.requirements.hasUppercase}
                      text="One uppercase letter"
                    />
                    <PasswordRequirement
                      met={passwordValidation.requirements.hasLowercase}
                      text="One lowercase letter"
                    />
                    <PasswordRequirement
                      met={passwordValidation.requirements.hasNumber}
                      text="One number"
                    />
                    <PasswordRequirement
                      met={passwordValidation.requirements.hasSpecialChar}
                      text="One special character"
                    />
                  </VStack>
                )}
              </VStack>

              <VStack space="xs">
                <Text className="text-sm font-medium">Confirm Password</Text>
                <Input variant="outline" size="md">
                  <InputField
                    placeholder="Confirm your password"
                    value={confirmPassword}
                    onChangeText={setConfirmPassword}
                    secureTextEntry
                  />
                </Input>
              </VStack>
            </VStack>

            <Button
              size="lg"
              variant="solid"
              action="primary"
              isDisabled={loading || !passwordValidation.isValid || password !== confirmPassword}
              onPress={signUpWithEmail}
            >
              <ButtonText>{loading ? 'Creating Account...' : 'Sign Up'}</ButtonText>
            </Button>

            <View className="flex-row justify-center">
              <Text className="text-muted-foreground">Already have an account? </Text>
              <Link href="/auth/login" asChild>
                <Pressable>
                  <Text className="text-primary font-medium">Sign In</Text>
                </Pressable>
              </Link>
            </View>
          </VStack>
        </Card>
      </View>
    </ScrollView>
  );
}