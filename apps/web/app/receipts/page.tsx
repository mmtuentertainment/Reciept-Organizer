'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { ReceiptsDataTable } from '@/components/receipts/receipts-data-table'
import { ReceiptCapture } from '@/components/receipts/receipt-capture'
import { Button } from '@/components/ui/button'
import { Dialog, DialogContent, DialogTrigger } from '@/components/ui/dialog'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { Loader2, PlusCircle, FileDown, AlertCircle } from 'lucide-react'
import { ReceiptUploadService } from '@/lib/services/receipt-upload-service'
import type { Receipt } from '@/components/receipts/receipts-data-table'

export default function ReceiptsPage() {
  const router = useRouter()
  const supabase = createClient()
  const uploadService = new ReceiptUploadService()

  const [user, setUser] = useState<any>(null)
  const [receipts, setReceipts] = useState<Receipt[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [showCaptureDialog, setShowCaptureDialog] = useState(false)

  useEffect(() => {
    checkUser()
  }, [])

  const checkUser = async () => {
    try {
      const { data: { user }, error: authError } = await supabase.auth.getUser()

      if (authError || !user) {
        router.push('/login')
        return
      }

      setUser(user)
      await loadReceipts(user.id)
    } catch (error) {
      console.error('Error checking user:', error)
      router.push('/login')
    }
  }

  const loadReceipts = async (userId: string) => {
    try {
      setLoading(true)
      setError(null)

      // Fetch receipts with category relationship
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
        .eq('user_id', userId)
        .order('receipt_date', { ascending: false })

      if (receiptsError) {
        throw receiptsError
      }

      setReceipts(receipts || [])
    } catch (error) {
      console.error('Error loading receipts:', error)
      setError(error instanceof Error ? error.message : 'Failed to load receipts')
    } finally {
      setLoading(false)
    }
  }

  const handleCaptureSuccess = (receiptId: string) => {
    console.log('Receipt captured successfully:', receiptId)
    setShowCaptureDialog(false)
    // Reload receipts to show the new one
    if (user) {
      loadReceipts(user.id)
    }
  }

  const handleCaptureCancel = () => {
    setShowCaptureDialog(false)
  }

  const handleViewReceipt = (receipt: Receipt) => {
    console.log('View receipt:', receipt.id)
    // TODO: Navigate to receipt detail page or show modal
  }

  const handleEditReceipt = (receipt: Receipt) => {
    console.log('Edit receipt:', receipt.id)
    // TODO: Open edit dialog or navigate to edit page
  }

  const handleDeleteReceipts = async (receiptsToDelete: Receipt[]) => {
    if (!confirm(`Are you sure you want to delete ${receiptsToDelete.length} receipt(s)?`)) {
      return
    }

    try {
      const receiptIds = receiptsToDelete.map(r => r.id)

      const { error } = await supabase
        .from('receipts')
        .delete()
        .in('id', receiptIds)

      if (error) throw error

      // Reload receipts
      if (user) {
        await loadReceipts(user.id)
      }
    } catch (error) {
      console.error('Error deleting receipts:', error)
      alert('Failed to delete receipts')
    }
  }

  const handleReprocessOCR = async (receipt: Receipt) => {
    try {
      const result = await uploadService.reprocessOCR(receipt.id)

      if (!result.success) {
        throw new Error(result.error || 'OCR reprocessing failed')
      }

      // Reload receipts to show updated OCR data
      if (user) {
        await loadReceipts(user.id)
      }

      alert('OCR reprocessing completed successfully!')
    } catch (error) {
      console.error('Error reprocessing OCR:', error)
      alert('Failed to reprocess OCR')
    }
  }

  const handleExportCSV = () => {
    // TODO: Implement CSV export functionality
    console.log('Export CSV not implemented yet')
    alert('CSV export functionality coming soon!')
  }

  const handleSignOut = async () => {
    await supabase.auth.signOut()
    router.push('/login')
  }

  if (loading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="flex items-center space-x-2">
          <Loader2 className="h-6 w-6 animate-spin" />
          <span>Loading receipts...</span>
        </div>
      </div>
    )
  }

  return (
    <div className="flex min-h-screen flex-col">
      <header className="border-b bg-background">
        <div className="flex h-16 items-center px-4">
          <h1 className="text-xl font-semibold">My Receipts</h1>
          <div className="ml-auto flex items-center gap-4">
            <span className="text-sm text-muted-foreground">{user?.email}</span>
            <Button variant="outline" size="sm" onClick={handleSignOut}>
              Sign Out
            </Button>
          </div>
        </div>
      </header>

      <main className="flex-1">
        <div className="container mx-auto py-6">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h2 className="text-2xl font-bold tracking-tight">Receipts</h2>
              <p className="text-muted-foreground">
                Manage and organize your receipts with OCR processing
              </p>
            </div>
            <div className="flex gap-2">
              <Button variant="outline" size="sm" onClick={handleExportCSV}>
                <FileDown className="mr-2 h-4 w-4" />
                Export CSV
              </Button>
              <Dialog open={showCaptureDialog} onOpenChange={setShowCaptureDialog}>
                <DialogTrigger asChild>
                  <Button size="sm">
                    <PlusCircle className="mr-2 h-4 w-4" />
                    Add Receipt
                  </Button>
                </DialogTrigger>
                <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
                  <ReceiptCapture
                    onSuccess={handleCaptureSuccess}
                    onCancel={handleCaptureCancel}
                  />
                </DialogContent>
              </Dialog>
            </div>
          </div>

          {error ? (
            <Alert variant="destructive" className="mb-6">
              <AlertCircle className="h-4 w-4" />
              <AlertDescription>
                Error loading receipts: {error}
              </AlertDescription>
            </Alert>
          ) : (
            <ReceiptsDataTable
              data={receipts}
              onView={handleViewReceipt}
              onEdit={handleEditReceipt}
              onDelete={handleDeleteReceipts}
              onReprocess={handleReprocessOCR}
            />
          )}
        </div>
      </main>
    </div>
  )
}