/**
 * Mobile OCR Service
 * Handles receipt image processing using Google Vision API
 */

export interface ReceiptOCRData {
  vendor_name?: string
  total_amount?: number
  receipt_date?: string
  tax_amount?: number
  tip_amount?: number
  payment_method?: string
  confidence: number
  raw_text: string
  processing_time_ms?: number
}

export interface OCRService {
  processReceiptImage(imageUri: string): Promise<ReceiptOCRData>
}

class GoogleVisionOCRService implements OCRService {
  private apiKey: string

  constructor(apiKey: string) {
    this.apiKey = apiKey
  }

  async processReceiptImage(imageUri: string): Promise<ReceiptOCRData> {
    const startTime = Date.now()

    try {
      // Convert image to base64
      const base64Image = await this.convertImageToBase64(imageUri)

      // Call Google Vision API
      const response = await fetch(
        `https://vision.googleapis.com/v1/images:annotate?key=${this.apiKey}`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            requests: [{
              image: {
                content: base64Image
              },
              features: [
                { type: 'TEXT_DETECTION', maxResults: 1 }
              ]
            }]
          })
        }
      )

      if (!response.ok) {
        throw new Error(`Google Vision API error: ${response.status}`)
      }

      const result = await response.json()
      const textAnnotations = result.responses[0]?.textAnnotations

      if (!textAnnotations || textAnnotations.length === 0) {
        throw new Error('No text detected in image')
      }

      const rawText = textAnnotations[0].description
      const processingTime = Date.now() - startTime

      // Parse receipt data from text
      const parsedData = this.parseReceiptText(rawText)

      return {
        ...parsedData,
        raw_text: rawText,
        processing_time_ms: processingTime
      }

    } catch (error) {
      console.error('OCR processing failed:', error)
      throw error
    }
  }

  private async convertImageToBase64(imageUri: string): Promise<string> {
    try {
      // For Expo, we can use FileSystem to read the image
      const FileSystem = await import('expo-file-system')
      const base64 = await FileSystem.readAsStringAsync(imageUri, {
        encoding: FileSystem.EncodingType.Base64,
      })
      return base64
    } catch (error) {
      // Fallback for web or other environments
      const response = await fetch(imageUri)
      const blob = await response.blob()
      return new Promise((resolve, reject) => {
        const reader = new FileReader()
        reader.onloadend = () => {
          const base64 = (reader.result as string).split(',')[1]
          resolve(base64)
        }
        reader.onerror = reject
        reader.readAsDataURL(blob)
      })
    }
  }

  private parseReceiptText(text: string): Omit<ReceiptOCRData, 'raw_text' | 'processing_time_ms'> {
    const lines = text.split('\n').map(line => line.trim()).filter(line => line.length > 0)

    // Initialize result
    const result: Omit<ReceiptOCRData, 'raw_text' | 'processing_time_ms'> = {
      confidence: 75 // Base confidence for successful OCR
    }

    // Patterns for parsing
    const patterns = {
      amount: /\$?(\d+\.?\d*)/g,
      date: /(\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4})/g,
      total: /(?:total|amount|sum|subtotal)\s*:?\s*\$?(\d+\.?\d*)/gi,
      tax: /(?:tax|hst|gst|pst)\s*:?\s*\$?(\d+\.?\d*)/gi,
      tip: /(?:tip|gratuity)\s*:?\s*\$?(\d+\.?\d*)/gi,
    }

    // Extract vendor name (usually first few meaningful lines)
    const vendorCandidates = lines.slice(0, 5).filter(line =>
      line.length > 2 &&
      !line.match(/^\d/) &&
      !line.includes('$') &&
      !line.match(/\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4}/)
    )

    if (vendorCandidates.length > 0) {
      result.vendor_name = vendorCandidates[0]
      result.confidence += 10
    }

    // Extract total amount
    const totalMatches = [...text.matchAll(patterns.total)]
    if (totalMatches.length > 0) {
      const amount = parseFloat(totalMatches[totalMatches.length - 1][1])
      if (!isNaN(amount) && amount > 0) {
        result.total_amount = amount
        result.confidence += 15
      }
    } else {
      // Fallback: look for largest amount
      const amounts = [...text.matchAll(patterns.amount)]
        .map(match => parseFloat(match[1]))
        .filter(amount => !isNaN(amount) && amount > 0)
        .sort((a, b) => b - a)

      if (amounts.length > 0) {
        result.total_amount = amounts[0]
        result.confidence += 5
      }
    }

    // Extract tax
    const taxMatches = [...text.matchAll(patterns.tax)]
    if (taxMatches.length > 0) {
      const tax = parseFloat(taxMatches[0][1])
      if (!isNaN(tax) && tax >= 0) {
        result.tax_amount = tax
        result.confidence += 5
      }
    }

    // Extract tip
    const tipMatches = [...text.matchAll(patterns.tip)]
    if (tipMatches.length > 0) {
      const tip = parseFloat(tipMatches[0][1])
      if (!isNaN(tip) && tip >= 0) {
        result.tip_amount = tip
        result.confidence += 5
      }
    }

    // Extract date
    const dateMatches = [...text.matchAll(patterns.date)]
    if (dateMatches.length > 0) {
      const dateStr = dateMatches[0][1]
      const date = this.parseDate(dateStr)
      if (date) {
        result.receipt_date = date
        result.confidence += 10
      }
    }

    // Detect payment method from text
    const lowerText = text.toLowerCase()
    if (lowerText.includes('cash')) {
      result.payment_method = 'cash'
    } else if (lowerText.includes('card') || lowerText.includes('visa') || lowerText.includes('mastercard') || lowerText.includes('amex')) {
      result.payment_method = 'card'
    } else if (lowerText.includes('apple pay') || lowerText.includes('google pay') || lowerText.includes('paypal')) {
      result.payment_method = 'digital'
    } else {
      result.payment_method = 'card' // Default assumption
    }

    // Ensure confidence is within bounds
    result.confidence = Math.min(Math.max(result.confidence, 0), 100)

    return result
  }

  private parseDate(dateStr: string): string | undefined {
    try {
      // Handle various date formats
      const formats = [
        // MM/DD/YYYY or MM-DD-YYYY or MM.DD.YYYY
        /^(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{4})$/,
        // MM/DD/YY or MM-DD-YY or MM.DD.YY
        /^(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{2})$/,
        // DD/MM/YYYY or DD-MM-YYYY or DD.MM.YYYY
        /^(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{4})$/,
      ]

      for (const format of formats) {
        const match = dateStr.match(format)
        if (match) {
          let [_, part1, part2, part3] = match
          let year = parseInt(part3)

          // Handle 2-digit years
          if (year < 100) {
            year += year > 50 ? 1900 : 2000
          }

          // Assume MM/DD/YYYY format first
          let month = parseInt(part1)
          let day = parseInt(part2)

          // If month > 12, try DD/MM/YYYY
          if (month > 12) {
            month = parseInt(part2)
            day = parseInt(part1)
          }

          // Validate date
          if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
            const date = new Date(year, month - 1, day)
            return date.toISOString().split('T')[0]
          }
        }
      }
    } catch (error) {
      console.warn('Date parsing failed:', error)
    }

    return undefined
  }
}

export function createOCRService(): OCRService {
  // Use environment variable for API key
  const apiKey = process.env.EXPO_PUBLIC_GOOGLE_VISION_API_KEY

  if (!apiKey) {
    throw new Error('Google Vision API key not configured. Set EXPO_PUBLIC_GOOGLE_VISION_API_KEY environment variable.')
  }

  return new GoogleVisionOCRService(apiKey)
}