'use client'

import { useState, useRef } from 'react'
import { useRouter } from 'next/navigation'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Badge } from '@/components/ui/badge'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { Loader2, Upload, Camera, CheckCircle, XCircle, AlertCircle } from 'lucide-react'
import { createClient } from '@/lib/supabase/client'

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
  const router = useRouter()
  const supabase = createClient()

  // State management
  const [isUploading, setIsUploading] = useState(false)
  const [uploadProgress, setUploadProgress] = useState(0)
  const [uploadedImage, setUploadedImage] = useState<string | null>(null)
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

  const fileInputRef = useRef<HTMLInputElement>(null)

  // Load categories on component mount
  useState(() => {
    loadCategories()
  })

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

  const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (file) {
      handleFileUpload(file)
    }
  }

  const handleFileUpload = async (file: File) => {
    // 🐛 DEBUG: Client-side file upload started
    debugger; // This will pause execution in browser DevTools
    console.log('🔄 Client: Starting file upload', {
      fileName: file.name,
      fileSize: file.size,
      fileType: file.type
    })

    setIsUploading(true)
    setError(null)
    setUploadProgress(0)

    try {
      // Create form data
      const uploadFormData = new FormData()
      uploadFormData.append('file', file)
      uploadFormData.append('autoOCR', 'true')

      // 🐛 DEBUG: Form data preparation
      console.log('📝 Client: Form data prepared', {
        hasFile: uploadFormData.has('file'),
        categoryId: formData.category_id,
        autoOCR: true
      })
      if (formData.category_id) uploadFormData.append('categoryId', formData.category_id)
      if (formData.business_purpose) uploadFormData.append('businessPurpose', formData.business_purpose)
      if (formData.notes) uploadFormData.append('notes', formData.notes)
      if (formData.tags) uploadFormData.append('tags', formData.tags)

      // Simulate progress for UX
      const progressInterval = setInterval(() => {
        setUploadProgress(prev => Math.min(prev + 10, 90))
      }, 200)

      // Upload to API
      const response = await fetch('/api/receipts/upload', {
        method: 'POST',
        body: uploadFormData
      })

      clearInterval(progressInterval)
      setUploadProgress(100)

      const result = await response.json()

      if (!response.ok) {
        throw new Error(result.error || 'Upload failed')
      }

      // Success! Update UI with OCR results
      setUploadedImage(result.imageUrl)
      setOcrResult(result.ocrData)
      setSuccess(true)

      // Pre-fill form with OCR data
      if (result.ocrData) {
        setFormData(prev => ({
          ...prev,
          vendor_name: result.ocrData.vendor_name || prev.vendor_name,
          total_amount: result.ocrData.total_amount?.toString() || prev.total_amount,
          receipt_date: result.ocrData.receipt_date || prev.receipt_date,
          payment_method: result.ocrData.payment_method || prev.payment_method
        }))
      }

      // Call success callback
      if (onSuccess && result.receiptId) {
        setTimeout(() => onSuccess(result.receiptId), 1500)
      }

    } catch (error) {
      setError(error instanceof Error ? error.message : 'Upload failed')
      setUploadProgress(0)
    } finally {
      setIsUploading(false)
    }
  }

  const handleDrop = (event: React.DragEvent) => {
    event.preventDefault()
    const files = event.dataTransfer.files
    if (files.length > 0) {
      handleFileUpload(files[0])
    }
  }

  const handleDragOver = (event: React.DragEvent) => {
    event.preventDefault()
  }

  const updateFormField = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }))
  }

  const getConfidenceColor = (confidence: number) => {
    if (confidence >= 80) return 'text-green-600'
    if (confidence >= 60) return 'text-yellow-600'
    return 'text-red-600'
  }

  const getConfidenceLabel = (confidence: number) => {
    if (confidence >= 80) return 'High Confidence'
    if (confidence >= 60) return 'Medium Confidence'
    return 'Low Confidence - Review Needed'
  }

  return (
    <Card className="w-full max-w-4xl mx-auto">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Camera className="h-5 w-5" />
          Add New Receipt
          {success && (
            <Badge variant="default" className="bg-green-100 text-green-800">
              <CheckCircle className="h-3 w-3 mr-1" />
              Uploaded Successfully
            </Badge>
          )}
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-6">
        {/* Upload Area */}
        <div className="space-y-4">
          {!uploadedImage ? (
            <div
              className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center hover:border-gray-400 transition-colors"
              onDrop={handleDrop}
              onDragOver={handleDragOver}
            >
              <div className="space-y-4">
                <div className="mx-auto w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center">
                  <Upload className="h-6 w-6 text-gray-600" />
                </div>

                <div>
                  <h3 className="text-lg font-medium">Upload Receipt Image</h3>
                  <p className="text-sm text-gray-500 mt-1">
                    Drag and drop your receipt image here, or click to browse
                  </p>
                </div>

                <Button
                  variant="outline"
                  onClick={() => fileInputRef.current?.click()}
                  disabled={isUploading}
                  className="mx-auto"
                >
                  {isUploading ? (
                    <>
                      <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                      Processing...
                    </>
                  ) : (
                    <>
                      <Upload className="h-4 w-4 mr-2" />
                      Choose File
                    </>
                  )}
                </Button>

                <p className="text-xs text-gray-400">
                  Supports: JPEG, PNG, WebP, HEIC (Max 10MB)
                </p>
              </div>

              <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                className="hidden"
                onChange={handleFileSelect}
              />
            </div>
          ) : (
            <div className="space-y-4">
              <div className="relative">
                <img
                  src={uploadedImage}
                  alt="Uploaded receipt"
                  className="w-full max-h-64 object-contain rounded-lg border"
                />
                <Button
                  variant="destructive"
                  size="sm"
                  className="absolute top-2 right-2"
                  onClick={() => {
                    setUploadedImage(null)
                    setOcrResult(null)
                    setSuccess(false)
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
                  }}
                >
                  <XCircle className="h-4 w-4" />
                </Button>
              </div>

              {/* OCR Results Summary */}
              {ocrResult && (
                <Alert>
                  <AlertCircle className="h-4 w-4" />
                  <AlertDescription>
                    <div className="flex items-center justify-between">
                      <span>
                        OCR Processing Complete
                      </span>
                      <Badge
                        variant="outline"
                        className={getConfidenceColor(ocrResult.confidence)}
                      >
                        {getConfidenceLabel(ocrResult.confidence)} ({Math.round(ocrResult.confidence)}%)
                      </Badge>
                    </div>
                  </AlertDescription>
                </Alert>
              )}
            </div>
          )}

          {/* Upload Progress */}
          {isUploading && (
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span>Processing receipt...</span>
                <span>{uploadProgress}%</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div
                  className="bg-blue-600 h-2 rounded-full transition-all duration-300"
                  style={{ width: `${uploadProgress}%` }}
                />
              </div>
            </div>
          )}

          {/* Error Display */}
          {error && (
            <Alert variant="destructive">
              <XCircle className="h-4 w-4" />
              <AlertDescription>{error}</AlertDescription>
            </Alert>
          )}
        </div>

        {/* Form Fields - Pre-filled from OCR */}
        {(uploadedImage || Object.values(formData).some(v => v)) && (
          <div className="space-y-6">
            <div className="border-t pt-6">
              <h3 className="text-lg font-medium mb-4">Receipt Details</h3>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="vendor">Vendor Name *</Label>
                  <Input
                    id="vendor"
                    value={formData.vendor_name}
                    onChange={(e) => updateFormField('vendor_name', e.target.value)}
                    placeholder="e.g., Starbucks, Amazon, etc."
                    disabled={success}
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="amount">Total Amount *</Label>
                  <Input
                    id="amount"
                    type="number"
                    step="0.01"
                    value={formData.total_amount}
                    onChange={(e) => updateFormField('total_amount', e.target.value)}
                    placeholder="0.00"
                    disabled={success}
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="date">Receipt Date *</Label>
                  <Input
                    id="date"
                    type="date"
                    value={formData.receipt_date}
                    onChange={(e) => updateFormField('receipt_date', e.target.value)}
                    disabled={success}
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="category">Category</Label>
                  <Select
                    value={formData.category_id}
                    onValueChange={(value) => updateFormField('category_id', value)}
                    disabled={success}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select category" />
                    </SelectTrigger>
                    <SelectContent>
                      {categories.map((category) => (
                        <SelectItem key={category.id} value={category.id}>
                          <div className="flex items-center gap-2">
                            <div
                              className="w-3 h-3 rounded-full"
                              style={{ backgroundColor: category.color }}
                            />
                            {category.name}
                          </div>
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="payment">Payment Method</Label>
                  <Select
                    value={formData.payment_method}
                    onValueChange={(value) => updateFormField('payment_method', value)}
                    disabled={success}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="cash">Cash</SelectItem>
                      <SelectItem value="card">Credit/Debit Card</SelectItem>
                      <SelectItem value="digital">Digital Payment</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="tags">Tags</Label>
                  <Input
                    id="tags"
                    value={formData.tags}
                    onChange={(e) => updateFormField('tags', e.target.value)}
                    placeholder="business, travel, meeting (comma-separated)"
                    disabled={success}
                  />
                </div>

                <div className="md:col-span-2 space-y-2">
                  <Label htmlFor="purpose">Business Purpose</Label>
                  <Textarea
                    id="purpose"
                    value={formData.business_purpose}
                    onChange={(e) => updateFormField('business_purpose', e.target.value)}
                    placeholder="Brief description of business purpose..."
                    disabled={success}
                  />
                </div>

                <div className="md:col-span-2 space-y-2">
                  <Label htmlFor="notes">Notes</Label>
                  <Textarea
                    id="notes"
                    value={formData.notes}
                    onChange={(e) => updateFormField('notes', e.target.value)}
                    placeholder="Additional notes..."
                    disabled={success}
                  />
                </div>
              </div>
            </div>

            {/* Action Buttons */}
            <div className="flex justify-between pt-4 border-t">
              <Button variant="outline" onClick={onCancel} disabled={isUploading}>
                {success ? 'Close' : 'Cancel'}
              </Button>

              {success ? (
                <Button onClick={() => router.push('/receipts')}>
                  <CheckCircle className="h-4 w-4 mr-2" />
                  View All Receipts
                </Button>
              ) : (
                <Button
                  disabled={!uploadedImage || isUploading}
                  onClick={() => router.push('/receipts')}
                >
                  Done
                </Button>
              )}
            </div>
          </div>
        )}
      </CardContent>
    </Card>
  )
}