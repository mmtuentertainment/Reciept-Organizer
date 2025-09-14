import { useState, useEffect } from 'react';
import { View, Text, FlatList, RefreshControl, Pressable } from 'react-native';
import { supabase } from '../../lib/supabase';
import {
  VStack,
  HStack,
  Card,
  Heading,
  Badge,
  BadgeText,
  Input,
  InputField,
  Select,
  SelectTrigger,
  SelectInput,
  SelectPortal,
  SelectBackdrop,
  SelectContent,
  SelectDragIndicatorWrapper,
  SelectDragIndicator,
  SelectItem,
} from '@gluestack-ui/themed';

interface Receipt {
  id: string;
  merchant_name: string;
  amount: number;
  date: string;
  category: string;
  status: 'pending' | 'validated' | 'error';
  created_at: string;
}

export default function ReceiptsScreen() {
  const [receipts, setReceipts] = useState<Receipt[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [filteredReceipts, setFilteredReceipts] = useState<Receipt[]>([]);

  const categories = ['all', 'food', 'transport', 'shopping', 'utilities', 'other'];

  useEffect(() => {
    fetchReceipts();
  }, []);

  useEffect(() => {
    filterReceipts();
  }, [receipts, searchQuery, selectedCategory]);

  async function fetchReceipts() {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      const { data, error } = await supabase
        .from('receipts')
        .select('*')
        .eq('user_id', user.id)
        .order('date', { ascending: false });

      if (error) throw error;
      setReceipts(data || []);
    } catch (error) {
      console.error('Error fetching receipts:', error);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }

  function filterReceipts() {
    let filtered = receipts;

    if (searchQuery) {
      filtered = filtered.filter(receipt =>
        receipt.merchant_name.toLowerCase().includes(searchQuery.toLowerCase())
      );
    }

    if (selectedCategory !== 'all') {
      filtered = filtered.filter(receipt => receipt.category === selectedCategory);
    }

    setFilteredReceipts(filtered);
  }

  const onRefresh = () => {
    setRefreshing(true);
    fetchReceipts();
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'validated': return 'success';
      case 'error': return 'error';
      default: return 'warning';
    }
  };

  const renderReceipt = ({ item }: { item: Receipt }) => (
    <Card className="p-4 mb-3 bg-white">
      <VStack space="sm">
        <HStack className="justify-between items-start">
          <VStack className="flex-1">
            <Heading size="sm">{item.merchant_name}</Heading>
            <Text className="text-muted-foreground text-sm">
              {new Date(item.date).toLocaleDateString()}
            </Text>
          </VStack>
          <VStack className="items-end">
            <Text className="text-lg font-semibold">
              ${item.amount.toFixed(2)}
            </Text>
            <Badge action={getStatusColor(item.status)} size="sm">
              <BadgeText>{item.status}</BadgeText>
            </Badge>
          </VStack>
        </HStack>
        <HStack className="justify-between items-center">
          <Badge action="secondary" size="sm">
            <BadgeText>{item.category}</BadgeText>
          </Badge>
          <Text className="text-xs text-muted-foreground">
            ID: {item.id.slice(0, 8)}
          </Text>
        </HStack>
      </VStack>
    </Card>
  );

  if (loading) {
    return (
      <View className="flex-1 items-center justify-center">
        <Text>Loading receipts...</Text>
      </View>
    );
  }

  return (
    <View className="flex-1 bg-background">
      <VStack className="p-4" space="md">
        <Input variant="outline" size="md">
          <InputField
            placeholder="Search by merchant..."
            value={searchQuery}
            onChangeText={setSearchQuery}
          />
        </Input>

        <Select selectedValue={selectedCategory} onValueChange={setSelectedCategory}>
          <SelectTrigger variant="outline" size="md">
            <SelectInput placeholder="Select category" />
          </SelectTrigger>
          <SelectPortal>
            <SelectBackdrop />
            <SelectContent>
              <SelectDragIndicatorWrapper>
                <SelectDragIndicator />
              </SelectDragIndicatorWrapper>
              {categories.map((category) => (
                <SelectItem key={category} label={category} value={category} />
              ))}
            </SelectContent>
          </SelectPortal>
        </Select>

        <HStack className="justify-between items-center">
          <Text className="text-sm text-muted-foreground">
            {filteredReceipts.length} receipts found
          </Text>
          <Text className="text-sm text-muted-foreground">
            Total: ${filteredReceipts.reduce((sum, r) => sum + r.amount, 0).toFixed(2)}
          </Text>
        </HStack>
      </VStack>

      <FlatList
        data={filteredReceipts}
        renderItem={renderReceipt}
        keyExtractor={(item) => item.id}
        contentContainerStyle={{ paddingHorizontal: 16, paddingBottom: 20 }}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
        ListEmptyComponent={
          <View className="flex-1 items-center justify-center p-8">
            <Text className="text-muted-foreground text-center">
              No receipts found. Start by capturing your first receipt!
            </Text>
          </View>
        }
      />
    </View>
  );
}