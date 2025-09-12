'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase'
import { mockAuth } from '@/lib/auth-mock'
import { User } from '@supabase/supabase-js'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { 
  Receipt, 
  Upload, 
  Download, 
  Search,
  Calendar,
  DollarSign,
  BarChart3,
  Settings,
  LogOut,
  Plus,
  Eye,
  Edit2,
  Trash2,
  Menu,
  FileText,
  CheckCircle,
  AlertCircle,
  Clock,
  TrendingUp,
  TrendingDown,
  MoreHorizontal,
  Home,
  Filter,
  CreditCard,
  Users,
  Activity,
  X,
  Bell,
  HelpCircle,
  ChevronDown,
  FolderOpen,
  Archive,
  Star,
  RefreshCw,
  FileDown,
  Share2,
  Camera
} from 'lucide-react'

// shadcn components
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Checkbox } from '@/components/ui/checkbox'
import { Progress } from '@/components/ui/progress'
import { Separator } from '@/components/ui/separator'

interface ReceiptData {
  id: string
  merchant_name: string
  amount: number
  date: string
  category: string
  status: 'pending' | 'processed' | 'verified'
  image_url?: string
  confidence_score?: number
  tags?: string[]
}

export default function DashboardPage() {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)
  const [selectedReceipts, setSelectedReceipts] = useState<string[]>([])
  const [searchQuery, setSearchQuery] = useState('')
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false)
  const router = useRouter()
  const supabase = createClient()

  // Mock data for demonstration
  const [receipts] = useState<ReceiptData[]>([
    { 
      id: '1', 
      merchant_name: 'Starbucks Coffee', 
      amount: 15.75, 
      date: '2025-01-10', 
      category: 'Food & Dining',
      status: 'verified',
      confidence_score: 98,
      tags: ['business', 'client-meeting']
    },
    { 
      id: '2', 
      merchant_name: 'Office Depot', 
      amount: 127.50, 
      date: '2025-01-09', 
      category: 'Office Supplies',
      status: 'processed',
      confidence_score: 95,
      tags: ['tax-deductible']
    },
    { 
      id: '3', 
      merchant_name: 'Shell Gas Station', 
      amount: 45.00, 
      date: '2025-01-08', 
      category: 'Transportation',
      status: 'pending',
      confidence_score: 92,
      tags: ['business-travel']
    },
    { 
      id: '4', 
      merchant_name: 'Amazon', 
      amount: 89.99, 
      date: '2025-01-07', 
      category: 'Shopping',
      status: 'verified',
      confidence_score: 100,
      tags: ['personal']
    },
    { 
      id: '5', 
      merchant_name: 'Walmart', 
      amount: 234.56, 
      date: '2025-01-06', 
      category: 'Groceries',
      status: 'verified',
      confidence_score: 97,
      tags: ['household']
    },
    { 
      id: '6', 
      merchant_name: 'Best Buy', 
      amount: 599.99, 
      date: '2025-01-05', 
      category: 'Electronics',
      status: 'processed',
      confidence_score: 94,
      tags: ['business', 'equipment']
    }
  ])

  useEffect(() => {
    checkUser()
  }, [])

  const checkUser = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (user) {
        setUser(user)
      } else {
        const mockUser = mockAuth.getUser()
        if (mockUser) {
          setUser(mockUser as any)
        } else {
          router.push('/login')
        }
      }
    } catch (error) {
      const mockUser = mockAuth.getUser()
      if (mockUser) {
        setUser(mockUser as any)
      } else {
        router.push('/login')
      }
    } finally {
      setLoading(false)
    }
  }

  const handleLogout = async () => {
    await supabase.auth.signOut()
    await mockAuth.signOut()
    router.push('/')
  }

  const stats = {
    total: receipts.length,
    thisMonth: receipts.filter(r => r.date.startsWith('2025-01')).length,
    totalAmount: receipts.reduce((sum, r) => sum + r.amount, 0),
    pending: receipts.filter(r => r.status === 'pending').length,
    avgAmount: receipts.reduce((sum, r) => sum + r.amount, 0) / receipts.length,
    growth: 12.5
  }

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Top Navigation Bar */}
      <nav className="bg-white border-b border-gray-200 fixed w-full top-0 z-50">
        <div className="px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex items-center">
              <Button
                variant="ghost"
                size="icon"
                onClick={() => setSidebarCollapsed(!sidebarCollapsed)}
                className="mr-4"
              >
                <Menu className="h-5 w-5" />
              </Button>
              <div className="flex items-center">
                <div className="h-8 w-8 rounded-lg bg-gradient-to-br from-primary to-purple-600 flex items-center justify-center">
                  <Receipt className="h-5 w-5 text-white" />
                </div>
                <span className="ml-3 text-xl font-bold">Receipt Organizer</span>
              </div>
            </div>

            <div className="flex items-center gap-2">
              <Button variant="ghost" size="icon">
                <Bell className="h-5 w-5" />
              </Button>
              <Button variant="ghost" size="icon">
                <HelpCircle className="h-5 w-5" />
              </Button>
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button variant="ghost" className="flex items-center gap-2">
                    <Avatar className="h-8 w-8">
                      <AvatarFallback className="bg-gradient-to-br from-primary to-purple-600 text-white">
                        {user?.email?.[0].toUpperCase() || 'U'}
                      </AvatarFallback>
                    </Avatar>
                    <span className="hidden md:block">{user?.email?.split('@')[0] || 'User'}</span>
                    <ChevronDown className="h-4 w-4" />
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end" className="w-56">
                  <DropdownMenuLabel>My Account</DropdownMenuLabel>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem>
                    <Settings className="mr-2 h-4 w-4" />
                    Settings
                  </DropdownMenuItem>
                  <DropdownMenuItem>
                    <CreditCard className="mr-2 h-4 w-4" />
                    Billing
                  </DropdownMenuItem>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem onClick={handleLogout} className="text-red-600">
                    <LogOut className="mr-2 h-4 w-4" />
                    Log out
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            </div>
          </div>
        </div>
      </nav>

      <div className="flex pt-16">
        {/* Collapsible Sidebar */}
        <aside className={`${sidebarCollapsed ? 'w-16' : 'w-64'} bg-white border-r border-gray-200 min-h-screen transition-all duration-300 fixed left-0 top-16 bottom-0 overflow-y-auto z-40`}>
          <nav className="p-4 space-y-2">
            <Link href="/dashboard" className="flex items-center gap-3 px-3 py-2 rounded-lg bg-primary/10 text-primary">
              <Home className="h-5 w-5" />
              {!sidebarCollapsed && <span className="font-medium">Dashboard</span>}
            </Link>
            <Link href="/dashboard/receipts" className="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-600 hover:bg-gray-100">
              <Receipt className="h-5 w-5" />
              {!sidebarCollapsed && <span>All Receipts</span>}
            </Link>
            <Link href="/dashboard/upload" className="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-600 hover:bg-gray-100">
              <Upload className="h-5 w-5" />
              {!sidebarCollapsed && <span>Upload</span>}
            </Link>
            <Link href="/dashboard/export" className="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-600 hover:bg-gray-100">
              <Download className="h-5 w-5" />
              {!sidebarCollapsed && <span>Export</span>}
            </Link>
            <Link href="/dashboard/analytics" className="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-600 hover:bg-gray-100">
              <BarChart3 className="h-5 w-5" />
              {!sidebarCollapsed && <span>Analytics</span>}
            </Link>
            <Separator className="my-4" />
            <Link href="/dashboard/folders" className="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-600 hover:bg-gray-100">
              <FolderOpen className="h-5 w-5" />
              {!sidebarCollapsed && <span>Folders</span>}
            </Link>
            <Link href="/dashboard/archive" className="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-600 hover:bg-gray-100">
              <Archive className="h-5 w-5" />
              {!sidebarCollapsed && <span>Archive</span>}
            </Link>
          </nav>
        </aside>

        {/* Main Content Area - Full Width */}
        <main className={`flex-1 ${sidebarCollapsed ? 'ml-16' : 'ml-64'} transition-all duration-300`}>
          <div className="p-6 lg:p-8">
            {/* Page Header with Actions */}
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-8">
              <div>
                <h1 className="text-3xl font-bold tracking-tight">Dashboard</h1>
                <p className="text-muted-foreground mt-1">
                  Welcome back! Here's your receipt overview for January 2025
                </p>
              </div>
              <div className="flex gap-2">
                <Button variant="outline" size="sm">
                  <RefreshCw className="mr-2 h-4 w-4" />
                  Sync
                </Button>
                <Button variant="outline" size="sm">
                  <FileDown className="mr-2 h-4 w-4" />
                  Export
                </Button>
                <Button size="sm">
                  <Plus className="mr-2 h-4 w-4" />
                  New Receipt
                </Button>
              </div>
            </div>

            {/* Stats Cards - Full Width Grid */}
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 xl:grid-cols-6 gap-4 mb-8">
              <Card className="hover:shadow-lg transition-shadow cursor-pointer">
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">Total Receipts</CardTitle>
                  <FileText className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{stats.total}</div>
                  <p className="text-xs text-muted-foreground">
                    <span className="text-green-600 inline-flex items-center">
                      <TrendingUp className="h-3 w-3 mr-1" />
                      {stats.growth}%
                    </span>
                    {' '}from last month
                  </p>
                </CardContent>
              </Card>

              <Card className="hover:shadow-lg transition-shadow cursor-pointer">
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">This Month</CardTitle>
                  <Calendar className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{stats.thisMonth}</div>
                  <p className="text-xs text-muted-foreground">
                    {stats.pending} pending review
                  </p>
                </CardContent>
              </Card>

              <Card className="hover:shadow-lg transition-shadow cursor-pointer">
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">Total Expenses</CardTitle>
                  <DollarSign className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">${stats.totalAmount.toFixed(2)}</div>
                  <p className="text-xs text-muted-foreground">
                    Avg. ${stats.avgAmount.toFixed(2)}
                  </p>
                </CardContent>
              </Card>

              <Card className="hover:shadow-lg transition-shadow cursor-pointer">
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">Pending</CardTitle>
                  <Clock className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{stats.pending}</div>
                  <p className="text-xs text-muted-foreground">
                    Needs review
                  </p>
                </CardContent>
              </Card>

              <Card className="hover:shadow-lg transition-shadow cursor-pointer">
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">Categories</CardTitle>
                  <FolderOpen className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">5</div>
                  <p className="text-xs text-muted-foreground">
                    Active categories
                  </p>
                </CardContent>
              </Card>

              <Card className="hover:shadow-lg transition-shadow cursor-pointer">
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">OCR Accuracy</CardTitle>
                  <Activity className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">96.5%</div>
                  <Progress value={96.5} className="mt-2" />
                </CardContent>
              </Card>
            </div>

            {/* Quick Action Buttons */}
            <div className="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-6 gap-3 mb-8">
              <Button variant="outline" className="h-24 flex-col gap-2">
                <Upload className="h-6 w-6" />
                <span className="text-xs">Upload Receipt</span>
              </Button>
              <Button variant="outline" className="h-24 flex-col gap-2">
                <Camera className="h-6 w-6" />
                <span className="text-xs">Take Photo</span>
              </Button>
              <Button variant="outline" className="h-24 flex-col gap-2">
                <FileDown className="h-6 w-6" />
                <span className="text-xs">Export CSV</span>
              </Button>
              <Button variant="outline" className="h-24 flex-col gap-2">
                <BarChart3 className="h-6 w-6" />
                <span className="text-xs">View Reports</span>
              </Button>
              <Button variant="outline" className="h-24 flex-col gap-2">
                <Share2 className="h-6 w-6" />
                <span className="text-xs">Share</span>
              </Button>
              <Button variant="outline" className="h-24 flex-col gap-2">
                <Settings className="h-6 w-6" />
                <span className="text-xs">Settings</span>
              </Button>
            </div>

            {/* Main Content Tabs */}
            <Tabs defaultValue="recent" className="space-y-4">
              <div className="flex justify-between items-center">
                <TabsList>
                  <TabsTrigger value="recent">Recent Receipts</TabsTrigger>
                  <TabsTrigger value="pending">Pending Review</TabsTrigger>
                  <TabsTrigger value="starred">Starred</TabsTrigger>
                  <TabsTrigger value="insights">Insights</TabsTrigger>
                </TabsList>

                <div className="flex items-center gap-2">
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                    <Input
                      placeholder="Search receipts..."
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      className="pl-10 w-[300px]"
                    />
                  </div>
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="outline">
                        <Filter className="mr-2 h-4 w-4" />
                        Filter
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end" className="w-56">
                      <DropdownMenuLabel>Filter by</DropdownMenuLabel>
                      <DropdownMenuSeparator />
                      <DropdownMenuItem>All Status</DropdownMenuItem>
                      <DropdownMenuItem>Verified</DropdownMenuItem>
                      <DropdownMenuItem>Processed</DropdownMenuItem>
                      <DropdownMenuItem>Pending</DropdownMenuItem>
                      <DropdownMenuSeparator />
                      <DropdownMenuItem>All Categories</DropdownMenuItem>
                      <DropdownMenuItem>Food & Dining</DropdownMenuItem>
                      <DropdownMenuItem>Office Supplies</DropdownMenuItem>
                      <DropdownMenuItem>Transportation</DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </div>
              </div>

              <TabsContent value="recent">
                <Card>
                  <CardHeader>
                    <div className="flex justify-between items-center">
                      <div>
                        <CardTitle>Recent Receipts</CardTitle>
                        <CardDescription>
                          Your latest uploaded and processed receipts
                        </CardDescription>
                      </div>
                      <Button variant="outline" size="sm">
                        <Eye className="mr-2 h-4 w-4" />
                        View All
                      </Button>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <div className="rounded-lg border">
                      <Table>
                        <TableHeader>
                          <TableRow>
                            <TableHead className="w-[30px]">
                              <Checkbox />
                            </TableHead>
                            <TableHead>Merchant</TableHead>
                            <TableHead>Category</TableHead>
                            <TableHead>Tags</TableHead>
                            <TableHead>Date</TableHead>
                            <TableHead className="text-right">Amount</TableHead>
                            <TableHead>Status</TableHead>
                            <TableHead>Confidence</TableHead>
                            <TableHead className="text-center">Actions</TableHead>
                          </TableRow>
                        </TableHeader>
                        <TableBody>
                          {receipts.map((receipt) => (
                            <TableRow key={receipt.id} className="hover:bg-gray-50">
                              <TableCell>
                                <Checkbox 
                                  checked={selectedReceipts.includes(receipt.id)}
                                  onCheckedChange={(checked) => {
                                    if (checked) {
                                      setSelectedReceipts([...selectedReceipts, receipt.id])
                                    } else {
                                      setSelectedReceipts(selectedReceipts.filter(id => id !== receipt.id))
                                    }
                                  }}
                                />
                              </TableCell>
                              <TableCell className="font-medium">{receipt.merchant_name}</TableCell>
                              <TableCell>
                                <Badge variant="secondary">{receipt.category}</Badge>
                              </TableCell>
                              <TableCell>
                                <div className="flex gap-1">
                                  {receipt.tags?.map(tag => (
                                    <Badge key={tag} variant="outline" className="text-xs">
                                      {tag}
                                    </Badge>
                                  ))}
                                </div>
                              </TableCell>
                              <TableCell>{receipt.date}</TableCell>
                              <TableCell className="text-right font-medium">${receipt.amount.toFixed(2)}</TableCell>
                              <TableCell>
                                <Badge variant={
                                  receipt.status === 'verified' ? 'default' :
                                  receipt.status === 'processed' ? 'secondary' : 'outline'
                                }>
                                  {receipt.status === 'verified' && <CheckCircle className="mr-1 h-3 w-3" />}
                                  {receipt.status === 'processed' && <Clock className="mr-1 h-3 w-3" />}
                                  {receipt.status === 'pending' && <AlertCircle className="mr-1 h-3 w-3" />}
                                  {receipt.status}
                                </Badge>
                              </TableCell>
                              <TableCell>
                                <div className="flex items-center gap-2">
                                  <Progress value={receipt.confidence_score} className="w-[60px]" />
                                  <span className="text-sm text-muted-foreground">{receipt.confidence_score}%</span>
                                </div>
                              </TableCell>
                              <TableCell>
                                <div className="flex items-center justify-center gap-1">
                                  <Button variant="ghost" size="icon" className="h-8 w-8">
                                    <Eye className="h-4 w-4" />
                                  </Button>
                                  <Button variant="ghost" size="icon" className="h-8 w-8">
                                    <Edit2 className="h-4 w-4" />
                                  </Button>
                                  <Button variant="ghost" size="icon" className="h-8 w-8">
                                    <Star className="h-4 w-4" />
                                  </Button>
                                  <DropdownMenu>
                                    <DropdownMenuTrigger asChild>
                                      <Button variant="ghost" size="icon" className="h-8 w-8">
                                        <MoreHorizontal className="h-4 w-4" />
                                      </Button>
                                    </DropdownMenuTrigger>
                                    <DropdownMenuContent align="end">
                                      <DropdownMenuItem>
                                        <Download className="mr-2 h-4 w-4" />
                                        Download
                                      </DropdownMenuItem>
                                      <DropdownMenuItem>
                                        <Share2 className="mr-2 h-4 w-4" />
                                        Share
                                      </DropdownMenuItem>
                                      <DropdownMenuItem>
                                        <Archive className="mr-2 h-4 w-4" />
                                        Archive
                                      </DropdownMenuItem>
                                      <DropdownMenuSeparator />
                                      <DropdownMenuItem className="text-red-600">
                                        <Trash2 className="mr-2 h-4 w-4" />
                                        Delete
                                      </DropdownMenuItem>
                                    </DropdownMenuContent>
                                  </DropdownMenu>
                                </div>
                              </TableCell>
                            </TableRow>
                          ))}
                        </TableBody>
                      </Table>
                    </div>
                    
                    {/* Bulk Actions Bar */}
                    {selectedReceipts.length > 0 && (
                      <div className="mt-4 p-4 bg-gray-50 rounded-lg flex items-center justify-between">
                        <span className="text-sm text-muted-foreground">
                          {selectedReceipts.length} item{selectedReceipts.length !== 1 ? 's' : ''} selected
                        </span>
                        <div className="flex gap-2">
                          <Button variant="outline" size="sm">
                            <Download className="mr-2 h-4 w-4" />
                            Export Selected
                          </Button>
                          <Button variant="outline" size="sm">
                            <Archive className="mr-2 h-4 w-4" />
                            Archive
                          </Button>
                          <Button variant="outline" size="sm" className="text-red-600">
                            <Trash2 className="mr-2 h-4 w-4" />
                            Delete
                          </Button>
                        </div>
                      </div>
                    )}
                  </CardContent>
                </Card>
              </TabsContent>

              <TabsContent value="pending">
                <Card>
                  <CardHeader>
                    <CardTitle>Pending Review</CardTitle>
                    <CardDescription>
                      Receipts that need your attention
                    </CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="text-center py-8">
                      <AlertCircle className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
                      <p className="text-muted-foreground">1 receipt pending review</p>
                      <Button className="mt-4">Review Now</Button>
                    </div>
                  </CardContent>
                </Card>
              </TabsContent>

              <TabsContent value="starred">
                <Card>
                  <CardHeader>
                    <CardTitle>Starred Receipts</CardTitle>
                    <CardDescription>
                      Your important receipts
                    </CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="text-center py-8">
                      <Star className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
                      <p className="text-muted-foreground">No starred receipts yet</p>
                      <p className="text-sm text-muted-foreground mt-2">Star important receipts for quick access</p>
                    </div>
                  </CardContent>
                </Card>
              </TabsContent>

              <TabsContent value="insights">
                <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
                  <Card>
                    <CardHeader>
                      <CardTitle>Top Categories</CardTitle>
                      <CardDescription>This month's spending breakdown</CardDescription>
                    </CardHeader>
                    <CardContent>
                      <div className="space-y-4">
                        <div>
                          <div className="flex items-center justify-between mb-1">
                            <span className="text-sm font-medium">Food & Dining</span>
                            <span className="text-sm text-muted-foreground">$450.75</span>
                          </div>
                          <Progress value={35} />
                        </div>
                        <div>
                          <div className="flex items-center justify-between mb-1">
                            <span className="text-sm font-medium">Office Supplies</span>
                            <span className="text-sm text-muted-foreground">$327.50</span>
                          </div>
                          <Progress value={25} />
                        </div>
                        <div>
                          <div className="flex items-center justify-between mb-1">
                            <span className="text-sm font-medium">Transportation</span>
                            <span className="text-sm text-muted-foreground">$245.00</span>
                          </div>
                          <Progress value={20} />
                        </div>
                      </div>
                    </CardContent>
                  </Card>

                  <Card>
                    <CardHeader>
                      <CardTitle>Recent Activity</CardTitle>
                      <CardDescription>Your latest actions</CardDescription>
                    </CardHeader>
                    <CardContent>
                      <div className="space-y-4">
                        <div className="flex items-center gap-3">
                          <div className="h-8 w-8 rounded-full bg-green-100 flex items-center justify-center">
                            <CheckCircle className="h-4 w-4 text-green-600" />
                          </div>
                          <div className="flex-1">
                            <p className="text-sm font-medium">Receipt verified</p>
                            <p className="text-xs text-muted-foreground">2 hours ago</p>
                          </div>
                        </div>
                        <div className="flex items-center gap-3">
                          <div className="h-8 w-8 rounded-full bg-blue-100 flex items-center justify-center">
                            <Upload className="h-4 w-4 text-blue-600" />
                          </div>
                          <div className="flex-1">
                            <p className="text-sm font-medium">3 receipts uploaded</p>
                            <p className="text-xs text-muted-foreground">5 hours ago</p>
                          </div>
                        </div>
                        <div className="flex items-center gap-3">
                          <div className="h-8 w-8 rounded-full bg-purple-100 flex items-center justify-center">
                            <Download className="h-4 w-4 text-purple-600" />
                          </div>
                          <div className="flex-1">
                            <p className="text-sm font-medium">Monthly export completed</p>
                            <p className="text-xs text-muted-foreground">Yesterday</p>
                          </div>
                        </div>
                      </div>
                    </CardContent>
                  </Card>

                  <Card>
                    <CardHeader>
                      <CardTitle>Quick Stats</CardTitle>
                      <CardDescription>Performance metrics</CardDescription>
                    </CardHeader>
                    <CardContent>
                      <div className="space-y-4">
                        <div className="flex justify-between items-center">
                          <span className="text-sm">Processing Speed</span>
                          <Badge>2.3s avg</Badge>
                        </div>
                        <div className="flex justify-between items-center">
                          <span className="text-sm">Success Rate</span>
                          <Badge variant="secondary">99.2%</Badge>
                        </div>
                        <div className="flex justify-between items-center">
                          <span className="text-sm">Storage Used</span>
                          <Badge variant="outline">124 MB</Badge>
                        </div>
                        <div className="flex justify-between items-center">
                          <span className="text-sm">API Calls</span>
                          <Badge variant="outline">1,234</Badge>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                </div>
              </TabsContent>
            </Tabs>
          </div>
        </main>
      </div>
    </div>
  )
}