import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import { UserMenu } from '@/components/user-menu'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Camera, FileText, Upload, TrendingUp } from 'lucide-react'
import Link from 'next/link'

export default async function DashboardPage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    redirect('/auth/login')
  }

  // Fetch user statistics
  const { data: receipts } = await supabase
    .from('receipts')
    .select('id, total_amount, date')
    .eq('user_id', user.id)
    .is('deleted_at', null)

  const totalReceipts = receipts?.length || 0
  const totalAmount = receipts?.reduce((sum, r) => sum + (Number(r.total_amount) || 0), 0) || 0
  const thisMonthReceipts = receipts?.filter(r => {
    const receiptDate = new Date(r.date)
    const now = new Date()
    return receiptDate.getMonth() === now.getMonth() &&
           receiptDate.getFullYear() === now.getFullYear()
  }).length || 0

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      {/* Header */}
      <header className="bg-white dark:bg-gray-800 shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center">
              <h1 className="text-xl font-semibold">Receipt Organizer</h1>
            </div>
            <UserMenu />
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-8">
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
            Welcome back, {user.user_metadata?.full_name || 'User'}!
          </h2>
          <p className="text-gray-600 dark:text-gray-400 mt-1">
            Here's your receipt overview
          </p>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Total Receipts</CardTitle>
              <FileText className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{totalReceipts}</div>
              <p className="text-xs text-muted-foreground">All time</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Total Expenses</CardTitle>
              <TrendingUp className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">${totalAmount.toFixed(2)}</div>
              <p className="text-xs text-muted-foreground">All time</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">This Month</CardTitle>
              <FileText className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{thisMonthReceipts}</div>
              <p className="text-xs text-muted-foreground">Receipts added</p>
            </CardContent>
          </Card>
        </div>

        {/* Quick Actions */}
        <Card>
          <CardHeader>
            <CardTitle>Quick Actions</CardTitle>
            <CardDescription>
              Get started with managing your receipts
            </CardDescription>
          </CardHeader>
          <CardContent className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <Link href="/capture">
              <Button className="w-full" size="lg">
                <Camera className="mr-2 h-5 w-5" />
                Capture Receipt
              </Button>
            </Link>
            <Link href="/upload">
              <Button className="w-full" size="lg" variant="outline">
                <Upload className="mr-2 h-5 w-5" />
                Upload Receipt
              </Button>
            </Link>
            <Link href="/receipts">
              <Button className="w-full" size="lg" variant="outline">
                <FileText className="mr-2 h-5 w-5" />
                View All Receipts
              </Button>
            </Link>
          </CardContent>
        </Card>
      </main>
    </div>
  )
}