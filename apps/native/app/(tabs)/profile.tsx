import { useState, useEffect } from 'react';
import { View, Text, ScrollView, Alert } from 'react-native';
import { router } from 'expo-router';
import { supabase } from '../../lib/supabase';
import {
  VStack,
  HStack,
  Card,
  Heading,
  Button,
  ButtonText,
  Avatar,
  AvatarFallbackText,
  Badge,
  BadgeText,
  Divider,
} from '@gluestack-ui/themed';

interface UserProfile {
  email: string;
  created_at: string;
}

interface Stats {
  totalReceipts: number;
  totalAmount: number;
  pendingReceipts: number;
  validatedReceipts: number;
}

export default function ProfileScreen() {
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [stats, setStats] = useState<Stats>({
    totalReceipts: 0,
    totalAmount: 0,
    pendingReceipts: 0,
    validatedReceipts: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadProfile();
    loadStats();
  }, []);

  async function loadProfile() {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (user) {
        setProfile({
          email: user.email || '',
          created_at: user.created_at,
        });
      }
    } catch (error) {
      console.error('Error loading profile:', error);
    } finally {
      setLoading(false);
    }
  }

  async function loadStats() {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      const { data: receipts, error } = await supabase
        .from('receipts')
        .select('amount, status')
        .eq('user_id', user.id);

      if (error) throw error;

      if (receipts) {
        const totalAmount = receipts.reduce((sum, r) => sum + (r.amount || 0), 0);
        const pendingReceipts = receipts.filter(r => r.status === 'pending').length;
        const validatedReceipts = receipts.filter(r => r.status === 'validated').length;

        setStats({
          totalReceipts: receipts.length,
          totalAmount,
          pendingReceipts,
          validatedReceipts,
        });
      }
    } catch (error) {
      console.error('Error loading stats:', error);
    }
  }

  async function handleSignOut() {
    Alert.alert(
      'Sign Out',
      'Are you sure you want to sign out?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Sign Out',
          style: 'destructive',
          onPress: async () => {
            const { error } = await supabase.auth.signOut();
            if (error) {
              Alert.alert('Error', error.message);
            } else {
              router.replace('/auth/login');
            }
          },
        },
      ]
    );
  }

  if (loading) {
    return (
      <View className="flex-1 items-center justify-center">
        <Text>Loading profile...</Text>
      </View>
    );
  }

  return (
    <ScrollView className="flex-1 bg-background">
      <View className="p-4">
        <Card className="p-6 bg-white mb-4">
          <VStack space="lg" className="items-center">
            <Avatar size="xl">
              <AvatarFallbackText>
                {profile?.email?.charAt(0).toUpperCase() || 'U'}
              </AvatarFallbackText>
            </Avatar>

            <VStack space="xs" className="items-center">
              <Heading size="md">{profile?.email}</Heading>
              <Text className="text-sm text-muted-foreground">
                Member since {profile?.created_at ? new Date(profile.created_at).toLocaleDateString() : 'Unknown'}
              </Text>
            </VStack>
          </VStack>
        </Card>

        <Card className="p-6 bg-white mb-4">
          <VStack space="lg">
            <Heading size="md">Statistics</Heading>
            <Divider />

            <VStack space="md">
              <HStack className="justify-between items-center">
                <Text className="text-muted-foreground">Total Receipts</Text>
                <Badge action="secondary" size="md">
                  <BadgeText>{stats.totalReceipts}</BadgeText>
                </Badge>
              </HStack>

              <HStack className="justify-between items-center">
                <Text className="text-muted-foreground">Total Amount</Text>
                <Text className="font-semibold text-lg">
                  ${stats.totalAmount.toFixed(2)}
                </Text>
              </HStack>

              <HStack className="justify-between items-center">
                <Text className="text-muted-foreground">Pending</Text>
                <Badge action="warning" size="md">
                  <BadgeText>{stats.pendingReceipts}</BadgeText>
                </Badge>
              </HStack>

              <HStack className="justify-between items-center">
                <Text className="text-muted-foreground">Validated</Text>
                <Badge action="success" size="md">
                  <BadgeText>{stats.validatedReceipts}</BadgeText>
                </Badge>
              </HStack>
            </VStack>
          </VStack>
        </Card>

        <Card className="p-6 bg-white mb-4">
          <VStack space="lg">
            <Heading size="md">Settings</Heading>
            <Divider />

            <VStack space="md">
              <Button
                size="md"
                variant="outline"
                action="secondary"
                onPress={() => Alert.alert('Coming Soon', 'Export functionality will be available soon!')}
              >
                <ButtonText>Export Receipts (CSV)</ButtonText>
              </Button>

              <Button
                size="md"
                variant="outline"
                action="secondary"
                onPress={() => Alert.alert('Coming Soon', 'Settings will be available soon!')}
              >
                <ButtonText>App Settings</ButtonText>
              </Button>

              <Button
                size="md"
                variant="outline"
                action="secondary"
                onPress={() => Alert.alert('Coming Soon', 'Help center will be available soon!')}
              >
                <ButtonText>Help & Support</ButtonText>
              </Button>
            </VStack>
          </VStack>
        </Card>

        <Card className="p-6 bg-white">
          <VStack space="md">
            <Button
              size="lg"
              variant="solid"
              action="negative"
              onPress={handleSignOut}
            >
              <ButtonText>Sign Out</ButtonText>
            </Button>

            <Text className="text-xs text-center text-muted-foreground">
              Version 1.0.0
            </Text>
          </VStack>
        </Card>
      </View>
    </ScrollView>
  );
}