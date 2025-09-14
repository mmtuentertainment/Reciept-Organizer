/**
 * Mobile Receipt Upload Service
 * Handles file upload to Supabase Storage + OCR processing + database insertion
 */

import { createClient } from '../supabase'
import { OCRService, createOCRService, ReceiptOCRData } from './ocr-service'

export interface ReceiptUploadResult {
  success: boolean
  receiptId?: string
  imageUrl?: string
  thumbnailUrl?: string
  ocrData?: ReceiptOCRData
  error?: string
}

export interface ReceiptUploadOptions {
  autoOCR?: boolean
  categoryId?: string
  businessPurpose?: string
  notes?: string
  tags?: string[]
}

export interface ImageAsset {
  uri: string
  fileName?: string
  type?: string
  fileSize?: number
}

export class ReceiptUploadService {
  private supabase = createClient()
  private ocrService: OCRService | null = null

  constructor() {
    try {
      this.ocrService = createOCRService()
    } catch (error) {
      console.warn('OCR service not available:', error)
    }
  }

  async uploadReceiptImage(
    imageAsset: ImageAsset,
    userId: string,
    options: ReceiptUploadOptions = {}
  ): Promise<ReceiptUploadResult> {
    try {
      // Step 1: Validate image
      const validation = this.validateImage(imageAsset)
      if (!validation.isValid) {
        return { success: false, error: validation.error }
      }

      // Step 2: Upload image to Supabase Storage
      const uploadResult = await this.uploadToStorage(imageAsset, userId)
      if (!uploadResult.success) {
        return uploadResult
      }

      // Step 3: Create thumbnail (optional for mobile, can be done later)
      const thumbnailResult = await this.createAndUploadThumbnail(imageAsset, userId)

      // Step 4: Process with OCR (if enabled and available)
      let ocrData: ReceiptOCRData | undefined
      if (options.autoOCR !== false && this.ocrService) {
        try {
          // Use original image URI for OCR on mobile
          ocrData = await this.ocrService.processReceiptImage(imageAsset.uri)
        } catch (error) {
          console.warn('OCR processing failed, continuing without OCR:', error)
        }
      }

      // Step 5: Save receipt to database
      const receiptData = {
        user_id: userId,
        vendor_name: ocrData?.vendor_name || '',
        merchant_name: ocrData?.vendor_name || '', // For backward compatibility
        total_amount: ocrData?.total_amount || 0,
        receipt_date: ocrData?.receipt_date || new Date().toISOString().split('T')[0],
        date: ocrData?.receipt_date || new Date().toISOString().split('T')[0], // Backward compatibility
        tax_amount: ocrData?.tax_amount || 0,
        tip_amount: ocrData?.tip_amount || 0,
        payment_method: ocrData?.payment_method || 'card',
        currency: 'USD',
        image_url: uploadResult.imageUrl,
        image_storage_path: uploadResult.storagePath,
        thumbnail_url: thumbnailResult.success ? thumbnailResult.imageUrl : null,
        ocr_confidence: ocrData?.confidence || null,
        ocr_engine: 'google_vision',
        ocr_raw_text: ocrData?.raw_text || null,
        needs_review: (ocrData?.confidence || 0) < 70, // Flag low confidence for review
        category_id: options.categoryId || null,
        business_purpose: options.businessPurpose || null,
        notes: options.notes || null,
        tags: options.tags || null,
        sync_status: 'synced',
        is_processed: !!ocrData,
        metadata: {
          upload_timestamp: new Date().toISOString(),
          file_size: imageAsset.fileSize || null,
          file_type: imageAsset.type || 'image/jpeg',
          ocr_processing_time_ms: ocrData?.processing_time_ms || null,
          thumbnail_created: thumbnailResult.success,
          platform: 'mobile'
        }
      }

      const { data: receipt, error: dbError } = await this.supabase
        .from('receipts')
        .insert([receiptData])
        .select()
        .single()

      if (dbError) {
        // Cleanup uploaded files if database insert fails
        await this.cleanupFiles(uploadResult.storagePath, thumbnailResult.storagePath)
        return { success: false, error: `Database error: ${dbError.message}` }
      }

      return {
        success: true,
        receiptId: receipt.id,
        imageUrl: uploadResult.imageUrl,
        thumbnailUrl: thumbnailResult.imageUrl,
        ocrData
      }

    } catch (error) {
      console.error('Receipt upload failed:', error)
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Upload failed'
      }
    }
  }

  private validateImage(imageAsset: ImageAsset): { isValid: boolean; error?: string } {
    // Check if URI exists
    if (!imageAsset.uri) {
      return {
        isValid: false,
        error: 'No image selected'
      }
    }

    // Check file size if available (10MB limit)
    if (imageAsset.fileSize) {
      const maxSize = 10 * 1024 * 1024 // 10MB
      if (imageAsset.fileSize > maxSize) {
        return {
          isValid: false,
          error: 'File size too large. Maximum 10MB allowed.'
        }
      }
    }

    // Check file type if available
    if (imageAsset.type) {
      const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/heic']
      if (!allowedTypes.includes(imageAsset.type.toLowerCase())) {
        return {
          isValid: false,
          error: 'Invalid file type. Please select a JPEG, PNG, WebP, or HEIC image.'
        }
      }
    }

    return { isValid: true }
  }

  private async uploadToStorage(
    imageAsset: ImageAsset,
    userId: string
  ): Promise<{ success: boolean; imageUrl?: string; storagePath?: string; error?: string }> {
    try {
      // Generate unique filename
      const timestamp = Date.now()
      const random = Math.random().toString(36).substring(7)
      const extension = this.getFileExtension(imageAsset)
      const fileName = `${timestamp}-${random}.${extension}`
      const storagePath = `${userId}/receipts/${fileName}`

      // For React Native/Expo, we need to create a File-like object or use FormData
      const formData = new FormData()

      // Create file object for upload
      const fileObject = {
        uri: imageAsset.uri,
        type: imageAsset.type || 'image/jpeg',
        name: imageAsset.fileName || fileName,
      } as any

      formData.append('file', fileObject)

      // Upload to Supabase Storage
      const { data, error } = await this.supabase.storage
        .from('receipts')
        .upload(storagePath, fileObject, {
          cacheControl: '3600',
          upsert: false,
          contentType: imageAsset.type || 'image/jpeg'
        })

      if (error) {
        return { success: false, error: `Storage upload failed: ${error.message}` }
      }

      // Get public URL
      const { data: { publicUrl } } = this.supabase.storage
        .from('receipts')
        .getPublicUrl(storagePath)

      return {
        success: true,
        imageUrl: publicUrl,
        storagePath
      }

    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Storage upload failed'
      }
    }
  }

  private async createAndUploadThumbnail(
    imageAsset: ImageAsset,
    userId: string
  ): Promise<{ success: boolean; imageUrl?: string; storagePath?: string }> {
    try {
      // For mobile, we can skip thumbnail creation for now
      // or implement using expo-image-manipulator
      console.log('Thumbnail creation skipped for mobile - can be implemented with expo-image-manipulator')
      return { success: false }

    } catch (error) {
      console.warn('Thumbnail creation failed:', error)
      return { success: false }
    }
  }

  private getFileExtension(imageAsset: ImageAsset): string {
    if (imageAsset.fileName) {
      const parts = imageAsset.fileName.split('.')
      if (parts.length > 1) {
        return parts[parts.length - 1].toLowerCase()
      }
    }

    if (imageAsset.type) {
      const typeMap: { [key: string]: string } = {
        'image/jpeg': 'jpg',
        'image/png': 'png',
        'image/webp': 'webp',
        'image/heic': 'heic'
      }
      return typeMap[imageAsset.type.toLowerCase()] || 'jpg'
    }

    return 'jpg' // Default
  }

  private async cleanupFiles(...storagePaths: (string | undefined)[]): Promise<void> {
    for (const path of storagePaths) {
      if (path) {
        try {
          await this.supabase.storage.from('receipts').remove([path])
        } catch (error) {
          console.warn(`Failed to cleanup file ${path}:`, error)
        }
      }
    }
  }

  // Utility method to update receipt data after manual editing
  async updateReceiptData(
    receiptId: string,
    updates: {
      vendor_name?: string
      total_amount?: number
      receipt_date?: string
      category_id?: string
      business_purpose?: string
      notes?: string
      tags?: string[]
      needs_review?: boolean
    }
  ): Promise<{ success: boolean; error?: string }> {
    try {
      const { error } = await this.supabase
        .from('receipts')
        .update({
          ...updates,
          updated_at: new Date().toISOString()
        })
        .eq('id', receiptId)

      if (error) {
        return { success: false, error: error.message }
      }

      return { success: true }
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Update failed'
      }
    }
  }

  // Method to reprocess OCR for a receipt
  async reprocessOCR(receiptId: string): Promise<{ success: boolean; ocrData?: ReceiptOCRData; error?: string }> {
    if (!this.ocrService) {
      return { success: false, error: 'OCR service not available' }
    }

    try {
      // Get receipt with image URL
      const { data: receipt, error } = await this.supabase
        .from('receipts')
        .select('id, image_url')
        .eq('id', receiptId)
        .single()

      if (error || !receipt?.image_url) {
        return { success: false, error: 'Receipt not found or no image URL' }
      }

      // Reprocess with OCR
      const ocrData = await this.ocrService.processReceiptImage(receipt.image_url)

      // Update receipt with new OCR data
      const updateResult = await this.updateReceiptData(receiptId, {
        vendor_name: ocrData.vendor_name || undefined,
        total_amount: ocrData.total_amount || undefined,
        receipt_date: ocrData.receipt_date || undefined,
        needs_review: (ocrData.confidence || 0) < 70
      })

      if (!updateResult.success) {
        return { success: false, error: updateResult.error }
      }

      return { success: true, ocrData }

    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'OCR reprocessing failed'
      }
    }
  }
}