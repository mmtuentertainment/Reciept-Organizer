/**
 * Google Vision API OCR Service
 * Extracts text from receipt images and parses key information
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

export interface OCRServiceConfig {
  apiKey: string
  maxRetries?: number
  timeout?: number
}

export class OCRService {
  private apiKey: string
  private maxRetries: number
  private timeout: number
  private baseUrl = 'https://vision.googleapis.com/v1/images:annotate'

  constructor(config: OCRServiceConfig) {
    this.apiKey = config.apiKey
    this.maxRetries = config.maxRetries || 2
    this.timeout = config.timeout || 30000
  }

  async processReceiptImage(imageUrl: string): Promise<ReceiptOCRData> {
    const startTime = Date.now()

    try {
      // Convert image URL to base64 for Google Vision API
      const base64Image = await this.imageUrlToBase64(imageUrl)

      // Call Google Vision API
      const ocrResponse = await this.callVisionAPI(base64Image)

      // Extract and parse text
      const extractedText = ocrResponse.responses[0]?.fullTextAnnotation?.text || ''

      if (!extractedText) {
        return {
          confidence: 0,
          raw_text: '',
          processing_time_ms: Date.now() - startTime
        }
      }

      // Parse receipt data from extracted text
      const parsedData = this.parseReceiptText(extractedText)

      return {
        ...parsedData,
        raw_text: extractedText,
        processing_time_ms: Date.now() - startTime
      }

    } catch (error) {
      console.error('OCR processing failed:', error)
      return {
        confidence: 0,
        raw_text: '',
        processing_time_ms: Date.now() - startTime
      }
    }
  }

  private async imageUrlToBase64(imageUrl: string): Promise<string> {
    try {
      const response = await fetch(imageUrl)
      if (!response.ok) {
        throw new Error(`Failed to fetch image: ${response.statusText}`)
      }

      const arrayBuffer = await response.arrayBuffer()
      const base64 = Buffer.from(arrayBuffer).toString('base64')
      return base64
    } catch (error) {
      throw new Error(`Image conversion failed: ${error}`)
    }
  }

  private async callVisionAPI(base64Image: string, attempt = 1): Promise<any> {
    try {
      const requestBody = {
        requests: [{
          image: {
            content: base64Image
          },
          features: [
            { type: 'TEXT_DETECTION', maxResults: 1 },
            { type: 'DOCUMENT_TEXT_DETECTION', maxResults: 1 }
          ],
          imageContext: {
            languageHints: ['en'] // English language hint for better accuracy
          }
        }]
      }

      const response = await fetch(`${this.baseUrl}?key=${this.apiKey}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(requestBody),
        signal: AbortSignal.timeout(this.timeout)
      })

      if (!response.ok) {
        const errorText = await response.text()
        throw new Error(`Vision API error: ${response.status} - ${errorText}`)
      }

      const data = await response.json()

      if (data.responses[0]?.error) {
        throw new Error(`Vision API response error: ${data.responses[0].error.message}`)
      }

      return data

    } catch (error) {
      if (attempt < this.maxRetries) {
        console.warn(`OCR attempt ${attempt} failed, retrying...`, error)
        await this.delay(1000 * attempt) // Exponential backoff
        return this.callVisionAPI(base64Image, attempt + 1)
      }
      throw error
    }
  }

  private parseReceiptText(text: string): Omit<ReceiptOCRData, 'raw_text' | 'processing_time_ms'> {
    const lines = text.split('\n').map(line => line.trim()).filter(line => line.length > 0)

    let vendor_name = ''
    let total_amount = 0
    let receipt_date = ''
    let tax_amount = 0
    let tip_amount = 0
    let payment_method = ''

    // Confidence calculation based on successful extractions
    let confidence = 0

    // Extract vendor name (usually first meaningful line)
    for (const line of lines.slice(0, 5)) { // Check first 5 lines
      if (this.isLikelyVendorName(line)) {
        vendor_name = this.cleanVendorName(line)
        confidence += 25
        break
      }
    }

    // Extract total amount - look for common patterns
    const totalPatterns = [
      /(?:total|amount|sum|balance)\s*:?\s*\$?(\d+\.?\d*)/i,
      /\$(\d+\.\d{2})\s*(?:total|amount|sum)/i,
      /(\d+\.\d{2})\s*(?:total|amount|sum)/i,
      /^(?:total|amount|sum)\s+\$?(\d+\.\d{2})$/im
    ]

    for (const line of lines) {
      for (const pattern of totalPatterns) {
        const match = line.match(pattern)
        if (match && parseFloat(match[1]) > 0) {
          const amount = parseFloat(match[1])
          if (amount > total_amount) { // Take the largest reasonable amount
            total_amount = amount
            confidence += 30
          }
        }
      }
    }

    // Extract date
    const datePatterns = [
      /(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})/,
      /(\d{4})[\/\-](\d{1,2})[\/\-](\d{1,2})/,
      /(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\s+(\d{1,2}),?\s+(\d{2,4})/i
    ]

    for (const line of lines) {
      for (const pattern of datePatterns) {
        const match = line.match(pattern)
        if (match) {
          receipt_date = this.normalizeDate(match)
          if (receipt_date) {
            confidence += 20
            break
          }
        }
      }
      if (receipt_date) break
    }

    // Extract tax amount
    const taxPatterns = [
      /(?:tax|hst|gst|vat|sales\s+tax)\s*:?\s*\$?(\d+\.?\d*)/i
    ]

    for (const line of lines) {
      for (const pattern of taxPatterns) {
        const match = line.match(pattern)
        if (match) {
          tax_amount = parseFloat(match[1])
          confidence += 10
          break
        }
      }
    }

    // Extract tip amount
    const tipPatterns = [
      /(?:tip|gratuity)\s*:?\s*\$?(\d+\.?\d*)/i
    ]

    for (const line of lines) {
      for (const pattern of tipPatterns) {
        const match = line.match(pattern)
        if (match) {
          tip_amount = parseFloat(match[1])
          confidence += 5
          break
        }
      }
    }

    // Detect payment method
    const paymentKeywords = {
      'card': /(?:card|visa|mastercard|amex|discover|\*{4}|\d{4})/i,
      'cash': /cash/i,
      'digital': /(?:paypal|venmo|zelle|apple\s+pay|google\s+pay)/i
    }

    for (const line of lines) {
      for (const [method, pattern] of Object.entries(paymentKeywords)) {
        if (pattern.test(line)) {
          payment_method = method
          confidence += 10
          break
        }
      }
      if (payment_method) break
    }

    // Ensure confidence is reasonable
    confidence = Math.min(confidence, 95) // Cap at 95%

    return {
      vendor_name: vendor_name || undefined,
      total_amount: total_amount || undefined,
      receipt_date: receipt_date || undefined,
      tax_amount: tax_amount || undefined,
      tip_amount: tip_amount || undefined,
      payment_method: payment_method || undefined,
      confidence
    }
  }

  private isLikelyVendorName(line: string): boolean {
    // Skip common non-vendor patterns
    const skipPatterns = [
      /^\d+$/, // Pure numbers
      /^[\/\-\*#]+$/, // Symbols only
      /receipt|invoice|order|date|time/i,
      /^\$?\d+\.?\d*$/, // Amounts
      /^(mon|tue|wed|thu|fri|sat|sun)/i // Days
    ]

    for (const pattern of skipPatterns) {
      if (pattern.test(line)) return false
    }

    // Positive indicators for vendor names
    return line.length >= 3 &&
           line.length <= 50 &&
           /[a-zA-Z]/.test(line) &&
           !line.includes('...')
  }

  private cleanVendorName(name: string): string {
    return name
      .replace(/[^\w\s&'-]/g, '') // Remove special chars except &, ', -
      .replace(/\s+/g, ' ') // Normalize whitespace
      .trim()
      .slice(0, 100) // Limit length
  }

  private normalizeDate(match: RegExpMatchArray): string {
    try {
      const [, p1, p2, p3] = match

      // Handle different date formats
      if (p1.length === 4) {
        // YYYY-MM-DD format
        return `${p1}-${p2.padStart(2, '0')}-${p3.padStart(2, '0')}`
      } else if (isNaN(Number(p1))) {
        // Month name format
        const monthNames = ['jan','feb','mar','apr','may','jun',
                          'jul','aug','sep','oct','nov','dec']
        const monthIndex = monthNames.indexOf(p1.toLowerCase()) + 1
        if (monthIndex > 0) {
          const year = p3.length === 2 ? `20${p3}` : p3
          return `${year}-${monthIndex.toString().padStart(2, '0')}-${p2.padStart(2, '0')}`
        }
      } else {
        // MM/DD/YYYY or DD/MM/YYYY format - assume MM/DD
        const year = p3.length === 2 ? `20${p3}` : p3
        return `${year}-${p1.padStart(2, '0')}-${p2.padStart(2, '0')}`
      }
    } catch (error) {
      console.warn('Date parsing failed:', error)
    }
    return ''
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms))
  }

  // Utility method to get usage statistics
  async getUsageStats(): Promise<{ quotaUsed: number; quotaLimit: number }> {
    // Google Vision API doesn't provide real-time quota info via API
    // This would need to be tracked separately or checked in Google Cloud Console
    return {
      quotaUsed: 0, // Would need to track this in your app
      quotaLimit: 1000 // Free tier limit
    }
  }
}

// Factory function for easy instantiation
export function createOCRService(): OCRService {
  const apiKey = process.env.GOOGLE_VISION_API_KEY

  if (!apiKey) {
    throw new Error('GOOGLE_VISION_API_KEY environment variable is required')
  }

  return new OCRService({
    apiKey,
    maxRetries: 3,
    timeout: 30000
  })
}