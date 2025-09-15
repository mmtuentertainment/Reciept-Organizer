'use client'

import { useState, useMemo } from 'react'
import { format } from 'date-fns'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { Button } from '@/components/ui/button'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Search, Calendar, Receipt, Filter, Eye, Edit, Trash2 } from 'lucide-react'

interface Receipt {
  id: string
  user_id: string
  merchant: string | null
  receipt_date: string | null
  total: number | null
  tax: number | null
  category: string | null
  payment_method: string | null
  notes: string | null
  image_url: string | null
  ocr_confidence: number | null
  status: string
  created_at: string
  updated_at: string | null
}

interface ReceiptsListProps {
  receipts: Receipt[]
}

export function ReceiptsList({ receipts: initialReceipts }: ReceiptsListProps) {
  const [searchQuery, setSearchQuery] = useState('')
  const [categoryFilter, setCategoryFilter] = useState('all')
  const [viewMode, setViewMode] = useState<'grid' | 'table'>('grid')

  // Filter receipts based on search and category
  const filteredReceipts = useMemo(() => {
    let filtered = initialReceipts

    // Apply search filter
    if (searchQuery) {
      filtered = filtered.filter((receipt) =>
        receipt.merchant?.toLowerCase().includes(searchQuery.toLowerCase())
      )
    }

    // Apply category filter
    if (categoryFilter !== 'all') {
      filtered = filtered.filter((receipt) => receipt.category === categoryFilter)
    }

    return filtered
  }, [initialReceipts, searchQuery, categoryFilter])

  // Get unique categories for filter
  const categories = useMemo(() => {
    const cats = new Set(initialReceipts.map((r) => r.category).filter(Boolean))
    return Array.from(cats) as string[]
  }, [initialReceipts])

  const formatCurrency = (amount: number | null) => {
    if (amount === null) return 'N/A'
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount)
  }

  const getConfidenceBadge = (confidence: number | null) => {
    if (confidence === null) return null
    if (confidence >= 0.9) {
      return <Badge className="bg-green-100 text-green-800">High</Badge>
    }
    if (confidence >= 0.7) {
      return <Badge className="bg-yellow-100 text-yellow-800">Medium</Badge>
    }
    return <Badge className="bg-red-100 text-red-800">Low</Badge>
  }

  return (
    <div className="space-y-4">
      {/* Search and Filter Bar */}
      <Card>
        <CardContent className="pt-6">
          <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
            <div className="flex flex-1 gap-2">
              <div className="relative flex-1 max-w-md">
                <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  placeholder="Search by merchant..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="pl-9"
                />
              </div>
              <Select value={categoryFilter} onValueChange={setCategoryFilter}>
                <SelectTrigger className="w-[180px]">
                  <Filter className="mr-2 h-4 w-4" />
                  <SelectValue placeholder="Category" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Categories</SelectItem>
                  {categories.map((cat) => (
                    <SelectItem key={cat} value={cat}>
                      {cat}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="flex gap-2">
              <Button
                variant={viewMode === 'grid' ? 'default' : 'outline'}
                size="sm"
                onClick={() => setViewMode('grid')}
              >
                Grid
              </Button>
              <Button
                variant={viewMode === 'table' ? 'default' : 'outline'}
                size="sm"
                onClick={() => setViewMode('table')}
              >
                Table
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Results Summary */}
      <div className="flex items-center justify-between">
        <p className="text-sm text-muted-foreground">
          Showing {filteredReceipts.length} of {initialReceipts.length} receipts
        </p>
      </div>

      {/* Receipts Display */}
      {filteredReceipts.length === 0 ? (
        <Card>
          <CardContent className="flex flex-col items-center justify-center py-12">
            <Receipt className="h-12 w-12 text-muted-foreground mb-4" />
            <p className="text-lg font-medium">No receipts found</p>
            <p className="text-sm text-muted-foreground">
              {searchQuery || categoryFilter !== 'all'
                ? 'Try adjusting your filters'
                : 'Add your first receipt to get started'}
            </p>
          </CardContent>
        </Card>
      ) : viewMode === 'grid' ? (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {filteredReceipts.map((receipt) => (
            <Card key={receipt.id} className="hover:shadow-lg transition-shadow">
              <CardHeader className="pb-3">
                <div className="flex items-start justify-between">
                  <div className="space-y-1">
                    <CardTitle className="text-base">
                      {receipt.merchant || 'Unknown Merchant'}
                    </CardTitle>
                    <CardDescription>
                      {receipt.receipt_date
                        ? format(new Date(receipt.receipt_date), 'MMM d, yyyy')
                        : 'No date'}
                    </CardDescription>
                  </div>
                  {getConfidenceBadge(receipt.ocr_confidence)}
                </div>
              </CardHeader>
              <CardContent>
                <div className="space-y-2">
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-muted-foreground">Total</span>
                    <span className="text-lg font-semibold text-green-600">
                      {formatCurrency(receipt.total)}
                    </span>
                  </div>
                  {receipt.tax !== null && (
                    <div className="flex justify-between items-center">
                      <span className="text-sm text-muted-foreground">Tax</span>
                      <span className="text-sm">{formatCurrency(receipt.tax)}</span>
                    </div>
                  )}
                  {receipt.category && (
                    <Badge variant="secondary" className="mt-2">
                      {receipt.category}
                    </Badge>
                  )}
                </div>
                <div className="flex gap-2 mt-4">
                  <Button variant="ghost" size="sm" className="flex-1">
                    <Eye className="mr-2 h-3 w-3" />
                    View
                  </Button>
                  <Button variant="ghost" size="sm" className="flex-1">
                    <Edit className="mr-2 h-3 w-3" />
                    Edit
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      ) : (
        <Card>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Date</TableHead>
                <TableHead>Merchant</TableHead>
                <TableHead>Category</TableHead>
                <TableHead className="text-right">Total</TableHead>
                <TableHead className="text-right">Tax</TableHead>
                <TableHead>Confidence</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredReceipts.map((receipt) => (
                <TableRow key={receipt.id}>
                  <TableCell>
                    {receipt.receipt_date
                      ? format(new Date(receipt.receipt_date), 'MMM d, yyyy')
                      : 'N/A'}
                  </TableCell>
                  <TableCell className="font-medium">
                    {receipt.merchant || 'Unknown'}
                  </TableCell>
                  <TableCell>
                    {receipt.category ? (
                      <Badge variant="secondary">{receipt.category}</Badge>
                    ) : (
                      'N/A'
                    )}
                  </TableCell>
                  <TableCell className="text-right font-semibold text-green-600">
                    {formatCurrency(receipt.total)}
                  </TableCell>
                  <TableCell className="text-right">
                    {formatCurrency(receipt.tax)}
                  </TableCell>
                  <TableCell>{getConfidenceBadge(receipt.ocr_confidence)}</TableCell>
                  <TableCell className="text-right">
                    <div className="flex justify-end gap-1">
                      <Button variant="ghost" size="sm">
                        <Eye className="h-4 w-4" />
                      </Button>
                      <Button variant="ghost" size="sm">
                        <Edit className="h-4 w-4" />
                      </Button>
                      <Button variant="ghost" size="sm">
                        <Trash2 className="h-4 w-4" />
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </Card>
      )}
    </div>
  )
}