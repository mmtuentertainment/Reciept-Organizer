import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import { Button } from '@/components/ui/button'

export default async function DashboardPage() {
  const supabase = await createClient()

  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    redirect('/login')
  }
  return (
    <div className="flex min-h-screen flex-col">
      <header className="border-b">
        <div className="flex h-16 items-center px-4">
          <h1 className="text-xl font-semibold">Receipt Organizer Dashboard</h1>
          <div className="ml-auto flex items-center gap-4">
            <span className="text-sm text-muted-foreground">{user.email}</span>
            <form action="/auth/signout" method="post">
              <Button variant="outline" type="submit">
                Sign Out
              </Button>
            </form>
          </div>
        </div>
      </header>
      <main className="flex-1 p-8">
        <div className="mx-auto max-w-7xl">
          <h2 className="text-2xl font-bold tracking-tight">Welcome back!</h2>
          <p className="text-muted-foreground mt-2">
            Your receipt management dashboard is being set up.
          </p>

          <div className="mt-8 grid gap-4 md:grid-cols-2 lg:grid-cols-4">
            <div className="rounded-lg border p-6">
              <h3 className="font-semibold">Total Receipts</h3>
              <p className="text-3xl font-bold">0</p>
            </div>
            <div className="rounded-lg border p-6">
              <h3 className="font-semibold">This Month</h3>
              <p className="text-3xl font-bold">$0</p>
            </div>
            <div className="rounded-lg border p-6">
              <h3 className="font-semibold">Categories</h3>
              <p className="text-3xl font-bold">0</p>
            </div>
            <div className="rounded-lg border p-6">
              <h3 className="font-semibold">Pending</h3>
              <p className="text-3xl font-bold">0</p>
            </div>
          </div>

          <div className="mt-8 grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            <a
              href="/receipts"
              className="rounded-lg border p-6 hover:bg-accent transition-colors cursor-pointer"
            >
              <h3 className="font-semibold">📄 View Receipts</h3>
              <p className="mt-2 text-sm text-muted-foreground">
                Browse and manage your receipt collection
              </p>
            </a>
            <div className="rounded-lg border p-6 opacity-50">
              <h3 className="font-semibold">📸 Capture Receipt</h3>
              <p className="mt-2 text-sm text-muted-foreground">
                Coming soon: Capture receipts with your camera
              </p>
            </div>
            <div className="rounded-lg border p-6 opacity-50">
              <h3 className="font-semibold">📊 Export Data</h3>
              <p className="mt-2 text-sm text-muted-foreground">
                Coming soon: Export to CSV for accounting
              </p>
            </div>
          </div>
        </div>
      </main>
    </div>
  )
}