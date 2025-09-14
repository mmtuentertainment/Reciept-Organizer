/**
 * Mobile Receipt Capture Component
 * React Native component for capturing receipts with camera or photo library
 */

import React, { useState, useEffect } from 'react'
import { Alert, Platform } from 'react-native'
import * as ImagePicker from 'expo-image-picker'
import {
  VStack,
  HStack,
  Box,
  Text,
  Button,
  ButtonText,
  Input,
  InputField,
  Select,
  SelectTrigger,
  SelectInput,
  SelectItem,
  Card,
  Textarea,
  TextareaInput,
  Badge,
  BadgeText,
  Progress,
  ProgressFilledTrack,
  Spinner,
  AlertCircle,
  CheckCircle,
  Camera,
  Upload,
  XCircle,
  Image,
} from '@gluestack-ui/themed'
import { createClient } from '../lib/supabase'
import { ReceiptUploadService, ImageAsset } from '../lib/services/receipt-upload-service'

interface ReceiptCaptureProps {
  onSuccess?: (receiptId: string) => void
  onCancel?: () => void
}

interface Category {
  id: string
  name: string
  color: string
  icon: string
}

export function ReceiptCapture({ onSuccess, onCancel }: ReceiptCaptureProps) {
  const supabase = createClient()
  const uploadService = new ReceiptUploadService()

  // State management
  const [isUploading, setIsUploading] = useState(false)
  const [uploadProgress, setUploadProgress] = useState(0)
  const [selectedImage, setSelectedImage] = useState<ImageAsset | null>(null)
  const [ocrResult, setOcrResult] = useState<any>(null)
  const [categories, setCategories] = useState<Category[]>([])
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState(false)

  // Form data
  const [formData, setFormData] = useState({
    vendor_name: '',
    total_amount: '',
    receipt_date: new Date().toISOString().split('T')[0],
    category_id: '',
    payment_method: 'card',
    business_purpose: '',
    notes: '',
    tags: ''
  })

  // Load categories on component mount
  useEffect(() => {
    loadCategories()
    requestPermissions()
  }, [])

  const requestPermissions = async () => {
    if (Platform.OS !== 'web') {
      const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync()
      if (status !== 'granted') {
        Alert.alert(
          'Permission Required',
          'Camera roll access is needed to select receipt images.',
          [{ text: 'OK' }]
        )
      }

      const cameraStatus = await ImagePicker.requestCameraPermissionsAsync()
      if (cameraStatus.status !== 'granted') {
        console.warn('Camera permission not granted')
      }
    }
  }

  const loadCategories = async () => {
    try {
      const { data, error } = await supabase
        .from('categories')
        .select('id, name, color, icon')
        .order('name')

      if (error) throw error
      setCategories(data || [])
    } catch (error) {
      console.warn('Failed to load categories:', error)
    }
  }

  const showImagePicker = () => {
    Alert.alert(
      'Select Image',
      'Choose how you would like to add a receipt image:',
      [
        { text: 'Camera', onPress: takePhoto },
        { text: 'Photo Library', onPress: pickImage },
        { text: 'Cancel', style: 'cancel' }
      ],
      { cancelable: true }
    )
  }

  const takePhoto = async () => {
    try {
      const result = await ImagePicker.launchCameraAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        aspect: [3, 4],
        quality: 0.8,
        exif: false,
      })

      if (!result.canceled && result.assets[0]) {
        const asset = result.assets[0]
        handleImageSelected({
          uri: asset.uri,
          fileName: asset.fileName || `receipt_${Date.now()}.jpg`,
          type: asset.type || 'image/jpeg',
          fileSize: asset.fileSize,
        })
      }
    } catch (error) {
      console.error('Error taking photo:', error)
      setError('Failed to take photo')
    }
  }

  const pickImage = async () => {
    try {
      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        aspect: [3, 4],
        quality: 0.8,
        exif: false,
      })

      if (!result.canceled && result.assets[0]) {
        const asset = result.assets[0]
        handleImageSelected({
          uri: asset.uri,
          fileName: asset.fileName || `receipt_${Date.now()}.jpg`,
          type: asset.type || 'image/jpeg',
          fileSize: asset.fileSize,
        })
      }
    } catch (error) {
      console.error('Error picking image:', error)
      setError('Failed to select image')
    }
  }

  const handleImageSelected = async (imageAsset: ImageAsset) => {
    setSelectedImage(imageAsset)
    setError(null)
    setIsUploading(true)
    setUploadProgress(0)

    try {
      // Get current user
      const { data: { user }, error: authError } = await supabase.auth.getUser()
      if (authError || !user) {
        throw new Error('Authentication required')
      }

      // Simulate progress for UX
      const progressInterval = setInterval(() => {
        setUploadProgress(prev => Math.min(prev + 10, 90))
      }, 200)

      // Process upload
      const result = await uploadService.uploadReceiptImage(imageAsset, user.id, {
        autoOCR: true,
        categoryId: formData.category_id || undefined,
        businessPurpose: formData.business_purpose || undefined,
        notes: formData.notes || undefined,
        tags: formData.tags ? formData.tags.split(',').map(tag => tag.trim()) : undefined
      })

      clearInterval(progressInterval)
      setUploadProgress(100)

      if (!result.success) {
        throw new Error(result.error || 'Upload failed')
      }

      // Success! Update UI with OCR results
      setOcrResult(result.ocrData)
      setSuccess(true)

      // Pre-fill form with OCR data
      if (result.ocrData) {
        setFormData(prev => ({
          ...prev,
          vendor_name: result.ocrData?.vendor_name || prev.vendor_name,
          total_amount: result.ocrData?.total_amount?.toString() || prev.total_amount,
          receipt_date: result.ocrData?.receipt_date || prev.receipt_date,
          payment_method: result.ocrData?.payment_method || prev.payment_method
        }))
      }

      // Call success callback
      if (onSuccess && result.receiptId) {
        setTimeout(() => onSuccess(result.receiptId!), 1500)
      }

    } catch (error) {
      setError(error instanceof Error ? error.message : 'Upload failed')
      setUploadProgress(0)
    } finally {
      setIsUploading(false)
    }
  }

  const resetCapture = () => {
    setSelectedImage(null)
    setOcrResult(null)
    setSuccess(false)
    setError(null)
    setUploadProgress(0)
    setFormData({
      vendor_name: '',
      total_amount: '',
      receipt_date: new Date().toISOString().split('T')[0],
      category_id: '',
      payment_method: 'card',
      business_purpose: '',
      notes: '',
      tags: ''
    })
  }

  const updateFormField = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }))
  }

  const getConfidenceColor = (confidence: number) => {
    if (confidence >= 80) return '$green600'
    if (confidence >= 60) return '$yellow600'
    return '$red600'
  }

  const getConfidenceLabel = (confidence: number) => {
    if (confidence >= 80) return 'High Confidence'
    if (confidence >= 60) return 'Medium Confidence'
    return 'Low Confidence - Review Needed'
  }

  return (
    <Box className="flex-1 p-4">
      <Card className="flex-1" variant="elevated">
        <VStack space="lg" className="p-6">
          {/* Header */}
          <HStack space="sm" className="items-center">
            <Camera size={20} />
            <Text className="text-lg font-semibold">Add New Receipt</Text>
            {success && (
              <Badge action="success" variant="solid">
                <CheckCircle size={12} />
                <BadgeText className="ml-1">Uploaded Successfully</BadgeText>
              </Badge>
            )}
          </HStack>

          {/* Image Capture Section */}
          {!selectedImage ? (
            <VStack space="md" className="items-center py-8">
              <Box className="w-16 h-16 bg-gray-100 rounded-full items-center justify-center">
                <Upload size={24} className="text-gray-600" />
              </Box>

              <VStack space="sm" className="items-center">
                <Text className="text-lg font-medium">Capture Receipt</Text>
                <Text className="text-sm text-gray-500 text-center">
                  Take a photo of your receipt or select from your photo library
                </Text>
              </VStack>

              <Button
                onPress={showImagePicker}
                disabled={isUploading}
                className="mt-4"
              >
                <HStack space="sm" className="items-center">
                  <Camera size={16} />
                  <ButtonText>
                    {isUploading ? 'Processing...' : 'Add Receipt'}
                  </ButtonText>
                </HStack>
              </Button>

              <Text className="text-xs text-gray-400 text-center">
                Supports: JPEG, PNG, WebP, HEIC (Max 10MB)
              </Text>
            </VStack>
          ) : (
            <VStack space="md">
              {/* Selected Image Preview */}
              <Box className="relative">
                <Image
                  source={{ uri: selectedImage.uri }}
                  className="w-full h-48 rounded-lg"
                  resizeMode="contain"
                  alt="Receipt preview"
                />
                <Button
                  size="sm"
                  action="negative"
                  className="absolute top-2 right-2"
                  onPress={resetCapture}
                >
                  <XCircle size={16} />
                </Button>
              </Box>

              {/* OCR Results Summary */}
              {ocrResult && (
                <Box className="p-3 bg-blue-50 rounded-lg border border-blue-200">
                  <HStack className="items-center justify-between">
                    <HStack space="sm" className="items-center">
                      <AlertCircle size={16} className="text-blue-600" />
                      <Text className="text-sm">OCR Processing Complete</Text>
                    </HStack>
                    <Badge
                      variant="outline"
                      action={ocrResult.confidence >= 80 ? 'success' : ocrResult.confidence >= 60 ? 'warning' : 'error'}
                    >
                      <BadgeText style={{ color: getConfidenceColor(ocrResult.confidence) }}>
                        {getConfidenceLabel(ocrResult.confidence)} ({Math.round(ocrResult.confidence)}%)
                      </BadgeText>
                    </Badge>
                  </HStack>
                </Box>
              )}
            </VStack>
          )}

          {/* Upload Progress */}
          {isUploading && (
            <VStack space="sm">
              <HStack className="justify-between">
                <Text className="text-sm">Processing receipt...</Text>
                <Text className="text-sm">{uploadProgress}%</Text>
              </HStack>
              <Progress value={uploadProgress} className="w-full">
                <ProgressFilledTrack />
              </Progress>
            </VStack>
          )}

          {/* Error Display */}
          {error && (
            <Box className="p-3 bg-red-50 rounded-lg border border-red-200">
              <HStack space="sm" className="items-center">
                <XCircle size={16} className="text-red-600" />
                <Text className="text-sm text-red-600">{error}</Text>
              </HStack>
            </Box>
          )}

          {/* Form Fields - Pre-filled from OCR */}
          {(selectedImage || Object.values(formData).some(v => v)) && (
            <VStack space="md" className="border-t pt-4">
              <Text className="text-lg font-medium">Receipt Details</Text>

              <VStack space="md">
                {/* Vendor Name */}
                <VStack space="xs">
                  <Text className="text-sm font-medium">Vendor Name *</Text>
                  <Input>
                    <InputField
                      value={formData.vendor_name}
                      onChangeText={(value) => updateFormField('vendor_name', value)}
                      placeholder="e.g., Starbucks, Amazon, etc."
                      editable={!success}
                    />
                  </Input>
                </VStack>

                {/* Total Amount */}
                <VStack space="xs">
                  <Text className="text-sm font-medium">Total Amount *</Text>
                  <Input>
                    <InputField
                      value={formData.total_amount}
                      onChangeText={(value) => updateFormField('total_amount', value)}
                      placeholder="0.00"
                      keyboardType="decimal-pad"
                      editable={!success}
                    />
                  </Input>
                </VStack>

                {/* Receipt Date */}
                <VStack space="xs">
                  <Text className="text-sm font-medium">Receipt Date *</Text>
                  <Input>
                    <InputField
                      value={formData.receipt_date}
                      onChangeText={(value) => updateFormField('receipt_date', value)}
                      placeholder="YYYY-MM-DD"
                      editable={!success}
                    />
                  </Input>
                </VStack>

                {/* Category */}
                <VStack space="xs">
                  <Text className="text-sm font-medium">Category</Text>
                  <Select
                    selectedValue={formData.category_id}
                    onValueChange={(value) => updateFormField('category_id', value)}
                    isDisabled={success}
                  >
                    <SelectTrigger>
                      <SelectInput placeholder="Select category" />
                    </SelectTrigger>
                    {categories.map((category) => (
                      <SelectItem key={category.id} label={category.name} value={category.id} />
                    ))}
                  </Select>
                </VStack>

                {/* Payment Method */}
                <VStack space="xs">
                  <Text className="text-sm font-medium">Payment Method</Text>
                  <Select
                    selectedValue={formData.payment_method}
                    onValueChange={(value) => updateFormField('payment_method', value)}
                    isDisabled={success}
                  >
                    <SelectTrigger>
                      <SelectInput />
                    </SelectTrigger>
                    <SelectItem label="Cash" value="cash" />
                    <SelectItem label="Credit/Debit Card" value="card" />
                    <SelectItem label="Digital Payment" value="digital" />
                  </Select>
                </VStack>

                {/* Tags */}
                <VStack space="xs">
                  <Text className="text-sm font-medium">Tags</Text>
                  <Input>
                    <InputField
                      value={formData.tags}
                      onChangeText={(value) => updateFormField('tags', value)}
                      placeholder="business, travel, meeting (comma-separated)"
                      editable={!success}
                    />
                  </Input>
                </VStack>

                {/* Business Purpose */}
                <VStack space="xs">
                  <Text className="text-sm font-medium">Business Purpose</Text>
                  <Textarea>
                    <TextareaInput
                      value={formData.business_purpose}
                      onChangeText={(value) => updateFormField('business_purpose', value)}
                      placeholder="Brief description of business purpose..."
                      editable={!success}
                    />
                  </Textarea>
                </VStack>

                {/* Notes */}
                <VStack space="xs">
                  <Text className="text-sm font-medium">Notes</Text>
                  <Textarea>
                    <TextareaInput
                      value={formData.notes}
                      onChangeText={(value) => updateFormField('notes', value)}
                      placeholder="Additional notes..."
                      editable={!success}
                    />
                  </Textarea>
                </VStack>
              </VStack>
            </VStack>
          )}

          {/* Action Buttons */}
          {selectedImage && (
            <HStack className="justify-between pt-4 border-t">
              <Button
                variant="outline"
                onPress={onCancel}
                disabled={isUploading}
              >
                <ButtonText>{success ? 'Close' : 'Cancel'}</ButtonText>
              </Button>

              {success ? (
                <Button>
                  <HStack space="sm" className="items-center">
                    <CheckCircle size={16} />
                    <ButtonText>View All Receipts</ButtonText>
                  </HStack>
                </Button>
              ) : (
                <Button
                  disabled={!selectedImage || isUploading}
                >
                  <ButtonText>Done</ButtonText>
                </Button>
              )}
            </HStack>
          )}
        </VStack>
      </Card>
    </Box>
  )
}