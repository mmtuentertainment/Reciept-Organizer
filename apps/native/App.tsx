import "./global.css";
import { StatusBar } from 'expo-status-bar';
import { Text, View, ScrollView, Pressable } from 'react-native';
import { GluestackUIProvider, Button, ButtonText, Input, InputField, Box, Heading, VStack, HStack, Card } from '@gluestack-ui/themed';
import { config } from '@gluestack-ui/config';

export default function App() {
  return (
    <GluestackUIProvider config={config}>
      <View className="flex-1 bg-background">
        <StatusBar style="auto" />

        {/* Header with NativeWind styling */}
        <View className="bg-primary px-4 pt-12 pb-4">
          <Text className="text-2xl font-bold text-white">Receipt Organizer</Text>
          <Text className="text-sm text-gray-200 mt-1">Native Mobile App</Text>
        </View>

        <ScrollView className="flex-1 p-4">
          {/* Gluestack Card with NativeWind utilities */}
          <Card className="mb-4 p-4 bg-white rounded-lg shadow-sm">
            <VStack space="md">
              <Heading size="lg">Welcome Back!</Heading>
              <Text className="text-muted-foreground">
                Sign in to manage your receipts
              </Text>
            </VStack>
          </Card>

          {/* Login Form using Gluestack components */}
          <VStack space="lg" className="bg-card p-4 rounded-lg">
            <VStack space="sm">
              <Text className="text-sm font-medium">Email</Text>
              <Input variant="outline" size="md">
                <InputField placeholder="Enter your email" />
              </Input>
            </VStack>

            <VStack space="sm">
              <Text className="text-sm font-medium">Password</Text>
              <Input variant="outline" size="md">
                <InputField placeholder="Enter your password" type="password" />
              </Input>
            </VStack>

            {/* Gluestack Button with custom styling */}
            <Button
              size="md"
              variant="solid"
              action="primary"
              className="mt-4"
            >
              <ButtonText>Sign In</ButtonText>
            </Button>

            {/* NativeWind styled button */}
            <Pressable className="bg-secondary p-3 rounded-md items-center mt-2">
              <Text className="text-secondary-foreground font-medium">
                Create Account
              </Text>
            </Pressable>
          </VStack>

          {/* Feature Cards */}
          <View className="mt-6">
            <Text className="text-lg font-semibold mb-3">Features</Text>

            <View className="space-y-3">
              {['Capture Receipts', 'Organize & Search', 'Export to CSV'].map((feature, idx) => (
                <Pressable
                  key={idx}
                  className="bg-accent p-4 rounded-lg flex-row items-center"
                >
                  <View className="w-10 h-10 bg-primary/10 rounded-full items-center justify-center mr-3">
                    <Text className="text-primary font-bold">{idx + 1}</Text>
                  </View>
                  <Text className="text-accent-foreground flex-1">{feature}</Text>
                </Pressable>
              ))}
            </View>
          </View>
        </ScrollView>
      </View>
    </GluestackUIProvider>
  );
}
