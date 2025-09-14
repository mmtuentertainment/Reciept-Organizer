import { Tabs } from 'expo-router';
import { Text, View } from 'react-native';

export default function TabLayout() {
  return (
    <Tabs
      screenOptions={{
        tabBarActiveTintColor: '#1e3a8a',
        tabBarInactiveTintColor: '#6b7280',
        tabBarStyle: {
          backgroundColor: '#ffffff',
          borderTopWidth: 1,
          borderTopColor: '#e5e7eb',
        },
        headerStyle: {
          backgroundColor: '#1e3a8a',
        },
        headerTintColor: '#fff',
        headerTitleStyle: {
          fontWeight: 'bold',
        },
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: 'Receipts',
          tabBarLabel: 'Receipts',
          tabBarIcon: ({ color, size }) => (
            <View className="items-center justify-center">
              <Text style={{ color, fontSize: size }}>📄</Text>
            </View>
          ),
        }}
      />
      <Tabs.Screen
        name="capture"
        options={{
          title: 'Capture',
          tabBarLabel: 'Capture',
          tabBarIcon: ({ color, size }) => (
            <View className="items-center justify-center">
              <Text style={{ color, fontSize: size }}>📸</Text>
            </View>
          ),
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Profile',
          tabBarLabel: 'Profile',
          tabBarIcon: ({ color, size }) => (
            <View className="items-center justify-center">
              <Text style={{ color, fontSize: size }}>👤</Text>
            </View>
          ),
        }}
      />
    </Tabs>
  );
}