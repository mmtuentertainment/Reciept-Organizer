/**
 * Capture Tab Screen
 * Main screen for receipt capture functionality with full OCR and camera support
 */

import React from 'react'
import { SafeAreaView } from 'react-native-safe-area-context'
import { Box } from '@gluestack-ui/themed'
import { ReceiptCapture } from '../../components/ReceiptCapture'
import { router } from 'expo-router'

export default function CaptureScreen() {
  const handleCaptureSuccess = (receiptId: string) => {
    console.log('Receipt captured successfully:', receiptId)
    // Navigate to receipts list or home screen
    router.push('/(tabs)/')
  }

  const handleCaptureCancel = () => {
    // Navigate back to home screen
    router.push('/(tabs)/')
  }

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: '#f8f9fa' }}>
      <Box className="flex-1">
        <ReceiptCapture
          onSuccess={handleCaptureSuccess}
          onCancel={handleCaptureCancel}
        />
      </Box>
    </SafeAreaView>
  )
}