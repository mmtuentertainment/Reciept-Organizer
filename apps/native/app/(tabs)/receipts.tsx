/**
 * Receipts Tab Screen
 * Main screen for viewing and managing receipts on mobile
 */

import React from 'react'
import { SafeAreaView } from 'react-native-safe-area-context'
import { Box } from '@gluestack-ui/themed'
import { ReceiptsList } from '../../components/ReceiptsList'
import { router } from 'expo-router'

export default function ReceiptsScreen() {
  const handleReceiptPress = (receipt: any) => {
    console.log('Receipt pressed:', receipt.id)
    // TODO: Navigate to receipt detail screen
    // router.push(`/receipts/${receipt.id}`)
  }

  const handleReceiptEdit = (receipt: any) => {
    console.log('Edit receipt:', receipt.id)
    // TODO: Navigate to edit screen or open edit modal
    // router.push(`/receipts/${receipt.id}/edit`)
  }

  const handleReceiptDelete = (receipt: any) => {
    console.log('Delete receipt:', receipt.id)
    // TODO: Implement delete functionality
  }

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: '#f8f9fa' }}>
      <Box className="flex-1">
        <ReceiptsList
          onReceiptPress={handleReceiptPress}
          onReceiptEdit={handleReceiptEdit}
          onReceiptDelete={handleReceiptDelete}
        />
      </Box>
    </SafeAreaView>
  )
}