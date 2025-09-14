/**
 * Mobile Receipts List Component
 * React Native component for displaying and managing receipts
 */

import React, { useState, useEffect } from 'react'
import { Alert, RefreshControl, FlatList } from 'react-native'
import {
  VStack,
  HStack,
  Box,
  Text,
  Button,
  ButtonText,
  Card,
  Badge,
  BadgeText,
  Input,
  InputField,
  Select,
  SelectTrigger,
  SelectInput,
  SelectItem,
  Spinner,
  Image,
  Pressable,
} from '@gluestack-ui/themed'
import { Search, Filter, Receipt, Calendar, DollarSign, Eye, Edit, Trash2 } from 'lucide-react-native'
import { createClient } from '../lib/supabase'

interface Receipt {
  id: string
  vendor_name: string
  total_amount: number
  receipt_date: string
  category_id?: string
  category?: {
    id: string
    name: string
    color: string
    icon: string
  }
  payment_method: string
  business_purpose?: string
  notes?: string
  tags?: string[]
  image_url?: string
  thumbnail_url?: string
  ocr_confidence?: number
  needs_review: boolean
  sync_status: string
  is_processed: boolean
  created_at: string
  updated_at: string
}

interface ReceiptsListProps {
  onReceiptPress?: (receipt: Receipt) => void
  onReceiptEdit?: (receipt: Receipt) => void
  onReceiptDelete?: (receipt: Receipt) => void
}

export function ReceiptsList({ onReceiptPress, onReceiptEdit, onReceiptDelete }: ReceiptsListProps) {
  const supabase = createClient()

  const [receipts, setReceipts] = useState<Receipt[]>([])
  const [filteredReceipts, setFilteredReceipts] = useState<Receipt[]>([])
  const [loading, setLoading] = useState(true)
  const [refreshing, setRefreshing] = useState(false)
  const [searchQuery, setSearchQuery] = useState('')
  const [categoryFilter, setCategoryFilter] = useState('all')
  const [categories, setCategories] = useState<any[]>([])

  useEffect(() => {
    loadData()
  }, [])

  useEffect(() => {
    filterReceipts()
  }, [receipts, searchQuery, categoryFilter])

  const loadData = async () => {
    try {
      setLoading(true)
      await Promise.all([loadReceipts(), loadCategories()])
    } catch (error) {
      console.error('Error loading data:', error)
      Alert.alert('Error', 'Failed to load receipts')
    } finally {
      setLoading(false)
    }
  }

  const loadReceipts = async () => {
    try {
      const { data: { user }, error: authError } = await supabase.auth.getUser()
      if (authError || !user) {
        throw new Error('Not authenticated')
      }

      const { data: receipts, error: receiptsError } = await supabase
        .from('receipts')
        .select(`
          *,
          category:categories(
            id,
            name,
            color,
            icon
          )
        `)
        .eq('user_id', user.id)
        .order('receipt_date', { ascending: false })

      if (receiptsError) throw receiptsError

      setReceipts(receipts || [])
    } catch (error) {
      console.error('Error loading receipts:', error)
      throw error
    }
  }

  const loadCategories = async () => {
    try {
      const { data: categories, error } = await supabase
        .from('categories')
        .select('*')
        .order('name')

      if (error) throw error

      setCategories(categories || [])
    } catch (error) {
      console.error('Error loading categories:', error)
      throw error
    }
  }

  const filterReceipts = () => {
    let filtered = receipts

    // Apply search filter
    if (searchQuery) {
      filtered = filtered.filter((receipt) =>
        receipt.vendor_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        receipt.business_purpose?.toLowerCase().includes(searchQuery.toLowerCase()) ||
        receipt.notes?.toLowerCase().includes(searchQuery.toLowerCase())
      )
    }

    // Apply category filter
    if (categoryFilter !== 'all') {
      filtered = filtered.filter((receipt) =>
        receipt.category?.name === categoryFilter
      )
    }

    setFilteredReceipts(filtered)
  }

  const onRefresh = async () => {
    setRefreshing(true)
    try {
      await loadData()
    } finally {
      setRefreshing(false)
    }
  }

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount)
  }

  const formatDate = (dateString: string) => {
    try {
      return new Date(dateString).toLocaleDateString('en-US', {
        month: 'short',
        day: 'numeric',
        year: 'numeric'
      })
    } catch {
      return dateString
    }
  }

  const getConfidenceBadgeVariant = (confidence?: number) => {
    if (!confidence) return 'outline'
    if (confidence >= 80) return 'solid'
    if (confidence >= 60) return 'outline'
    return 'solid'
  }

  const getConfidenceLabel = (confidence?: number) => {
    if (!confidence) return 'Not Processed'
    if (confidence >= 80) return 'High'
    if (confidence >= 60) return 'Medium'
    return 'Needs Review'
  }

  const getConfidenceColor = (confidence?: number) => {
    if (!confidence) return '$gray500'
    if (confidence >= 80) return '$green600'
    if (confidence >= 60) return '$yellow600'
    return '$red600'
  }

  const handleReceiptPress = (receipt: Receipt) => {
    if (onReceiptPress) {
      onReceiptPress(receipt)
    } else {
      // Default action - show receipt details
      Alert.alert(
        receipt.vendor_name || 'Receipt',
        `Amount: ${formatCurrency(receipt.total_amount)}\nDate: ${formatDate(receipt.receipt_date)}${
          receipt.business_purpose ? `\nPurpose: ${receipt.business_purpose}` : ''
        }`,
        [
          { text: 'View', onPress: () => console.log('View receipt:', receipt.id) },
          { text: 'Edit', onPress: () => onReceiptEdit?.(receipt) },
          { text: 'Delete', onPress: () => handleDeleteReceipt(receipt), style: 'destructive' },
          { text: 'Cancel', style: 'cancel' }
        ]
      )
    }
  }

  const handleDeleteReceipt = (receipt: Receipt) => {
    Alert.alert(
      'Delete Receipt',
      `Are you sure you want to delete the receipt from ${receipt.vendor_name}?`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: () => onReceiptDelete?.(receipt)
        }
      ]
    )
  }

  const renderReceiptItem = ({ item: receipt }: { item: Receipt }) => {
    const imageUrl = receipt.thumbnail_url || receipt.image_url

    return (
      <Pressable onPress={() => handleReceiptPress(receipt)} className="mb-3">
        <Card className="p-4" variant="elevated">
          <HStack space="md">
            {/* Thumbnail */}
            <Box className="w-16 h-16 rounded-lg border overflow-hidden bg-gray-100 items-center justify-center">
              {imageUrl ? (
                <Image
                  source={{ uri: imageUrl }}
                  className="w-full h-full"
                  resizeMode="cover"
                  alt="Receipt thumbnail"
                />
              ) : (
                <Receipt size={24} className="text-gray-400" />
              )}
            </Box>

            {/* Receipt Details */}
            <VStack space="xs" className="flex-1">
              <HStack className="items-center justify-between">
                <Text className="font-semibold text-base flex-1" numberOfLines={1}>
                  {receipt.vendor_name || 'Unknown Vendor'}
                </Text>
                <Text className="font-bold text-green-600">
                  {formatCurrency(receipt.total_amount)}
                </Text>
              </HStack>

              <HStack className="items-center justify-between">
                <Text className="text-sm text-gray-500">
                  {formatDate(receipt.receipt_date)}
                </Text>
                {receipt.category && (
                  <Badge variant="outline" className="items-center">
                    <Box
                      className="w-2 h-2 rounded-full mr-1"
                      style={{ backgroundColor: receipt.category.color }}
                    />
                    <BadgeText className="text-xs">{receipt.category.name}</BadgeText>
                  </Badge>
                )}
              </HStack>

              {receipt.business_purpose && (
                <Text className="text-sm text-gray-600" numberOfLines={2}>
                  {receipt.business_purpose}
                </Text>
              )}

              <HStack className="items-center justify-between">
                <Badge
                  action={receipt.ocr_confidence && receipt.ocr_confidence >= 80 ? 'success' :
                         receipt.ocr_confidence && receipt.ocr_confidence >= 60 ? 'warning' : 'error'}
                  variant="solid"
                  className="items-center"
                >
                  <BadgeText className="text-xs">
                    {getConfidenceLabel(receipt.ocr_confidence)}
                  </BadgeText>
                </Badge>

                {receipt.tags && receipt.tags.length > 0 && (
                  <HStack space="xs">
                    {receipt.tags.slice(0, 2).map((tag, index) => (
                      <Badge key={index} variant="outline">
                        <BadgeText className="text-xs">{tag}</BadgeText>
                      </Badge>
                    ))}
                    {receipt.tags.length > 2 && (
                      <Badge variant="outline">
                        <BadgeText className="text-xs">+{receipt.tags.length - 2}</BadgeText>
                      </Badge>
                    )}
                  </HStack>
                )}
              </HStack>
            </VStack>
          </HStack>
        </Card>
      </Pressable>
    )
  }

  const renderEmptyState = () => (
    <Box className="flex-1 items-center justify-center py-16">
      <Receipt size={48} className="text-gray-400 mb-4" />
      <Text className="text-lg font-medium text-gray-700 mb-2">No receipts found</Text>
      <Text className="text-sm text-gray-500 text-center">
        {searchQuery || categoryFilter !== 'all'
          ? 'Try adjusting your filters'
          : 'Add your first receipt to get started'}
      </Text>
    </Box>
  )

  if (loading) {
    return (
      <Box className="flex-1 items-center justify-center">
        <Spinner size="large" />
        <Text className="mt-4 text-gray-600">Loading receipts...</Text>
      </Box>
    )
  }

  return (
    <Box className="flex-1">
      {/* Search and Filter Header */}
      <VStack space="md" className="p-4 bg-white border-b border-gray-200">
        <HStack space="sm">
          <Box className="flex-1 relative">
            <Box className="absolute left-3 top-1/2 -translate-y-1/2 z-10">
              <Search size={16} className="text-gray-400" />
            </Box>
            <Input className="pl-10">
              <InputField
                placeholder="Search receipts..."
                value={searchQuery}
                onChangeText={setSearchQuery}
              />
            </Input>
          </Box>
          <Select
            selectedValue={categoryFilter}
            onValueChange={setCategoryFilter}
          >
            <SelectTrigger className="w-32">
              <Filter size={16} className="mr-2" />
              <SelectInput />
            </SelectTrigger>
            <SelectItem label="All" value="all" />
            {categories.map((category) => (
              <SelectItem key={category.id} label={category.name} value={category.name} />
            ))}
          </Select>
        </HStack>

        <Text className="text-sm text-gray-500">
          {filteredReceipts.length} of {receipts.length} receipts
        </Text>
      </VStack>

      {/* Receipts List */}
      <FlatList
        data={filteredReceipts}
        renderItem={renderReceiptItem}
        keyExtractor={(item) => item.id}
        contentContainerStyle={{
          padding: 16,
          flexGrow: 1
        }}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
        ListEmptyComponent={renderEmptyState}
        showsVerticalScrollIndicator={false}
      />
    </Box>
  )
}