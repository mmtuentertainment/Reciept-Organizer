/**
 * API Route: /api/receipts/upload
 * Handles receipt image upload with OCR processing
 */

import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { ReceiptUploadService } from '@/lib/services/receipt-upload-service'

export async function POST(request: NextRequest) {
  try {
    // 🐛 DEBUG: API endpoint hit
    debugger; // This will pause execution in debugger
    console.log('📸 Receipt upload API called at:', new Date().toISOString())

    // Check authentication
    const supabase = await createClient()
    const { data: { user }, error: authError } = await supabase.auth.getUser()

    // 🐛 DEBUG: Check authentication result
    console.log('👤 User authentication:', { userId: user?.id, hasError: !!authError })

    if (authError || !user) {
      return NextResponse.json(
        { error: 'Authentication required' },
        { status: 401 }
      )
    }

    // Parse form data
    const formData = await request.formData()
    const file = formData.get('file') as File
    const categoryId = formData.get('categoryId') as string | null
    const businessPurpose = formData.get('businessPurpose') as string | null
    const notes = formData.get('notes') as string | null
    const tags = formData.get('tags') as string | null
    const autoOCR = formData.get('autoOCR') !== 'false' // Default to true

    if (!file) {
      return NextResponse.json(
        { error: 'No file provided' },
        { status: 400 }
      )
    }

    // Process upload
    const uploadService = new ReceiptUploadService()
    const result = await uploadService.uploadReceiptImage(file, user.id, {
      autoOCR,
      categoryId: categoryId || undefined,
      businessPurpose: businessPurpose || undefined,
      notes: notes || undefined,
      tags: tags ? tags.split(',').map(tag => tag.trim()) : undefined
    })

    if (!result.success) {
      return NextResponse.json(
        { error: result.error },
        { status: 500 }
      )
    }

    // Return success response
    return NextResponse.json({
      success: true,
      receiptId: result.receiptId,
      imageUrl: result.imageUrl,
      thumbnailUrl: result.thumbnailUrl,
      ocrData: result.ocrData
    })

  } catch (error) {
    console.error('Receipt upload API error:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

// Handle OPTIONS for CORS if needed
export async function OPTIONS(request: NextRequest) {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    },
  })
}