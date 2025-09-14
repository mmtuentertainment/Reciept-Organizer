"use client"

import * as React from "react"
import {
  ColumnDef,
  ColumnFiltersState,
  flexRender,
  getCoreRowModel,
  getFilteredRowModel,
  getPaginationRowModel,
  getSortedRowModel,
  SortingState,
  useReactTable,
  VisibilityState,
} from "@tanstack/react-table"
import { ArrowUpDown, ChevronDown, MoreHorizontal, Eye, Edit, Trash2, Receipt } from "lucide-react"
import { format } from "date-fns"

import { Button } from "@/components/ui/button"
import { Checkbox } from "@/components/ui/checkbox"
import {
  DropdownMenu,
  DropdownMenuCheckboxItem,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"

export interface Receipt {
  id: string
  vendor_name: string
  total_amount: number
  receipt_date: string
  category_id?: string
  category?: {
    id: string
    name: string
    color: string
    icon: string
  }
  payment_method: string
  business_purpose?: string
  notes?: string
  tags?: string[]
  image_url?: string
  thumbnail_url?: string
  ocr_confidence?: number
  needs_review: boolean
  sync_status: string
  is_processed: boolean
  created_at: string
  updated_at: string
}

interface ReceiptsDataTableProps {
  data: Receipt[]
  onView?: (receipt: Receipt) => void
  onEdit?: (receipt: Receipt) => void
  onDelete?: (receipts: Receipt[]) => void
  onReprocess?: (receipt: Receipt) => void
}

export function ReceiptsDataTable({
  data,
  onView,
  onEdit,
  onDelete,
  onReprocess
}: ReceiptsDataTableProps) {
  const [sorting, setSorting] = React.useState<SortingState>([
    { id: "receipt_date", desc: true } // Most recent first by default
  ])
  const [columnFilters, setColumnFilters] = React.useState<ColumnFiltersState>([])
  const [columnVisibility, setColumnVisibility] = React.useState<VisibilityState>({})
  const [rowSelection, setRowSelection] = React.useState({})

  const getConfidenceBadgeVariant = (confidence?: number) => {
    if (!confidence) return "secondary"
    if (confidence >= 80) return "default"
    if (confidence >= 60) return "secondary"
    return "destructive"
  }

  const getConfidenceLabel = (confidence?: number) => {
    if (!confidence) return "Not Processed"
    if (confidence >= 80) return "High Confidence"
    if (confidence >= 60) return "Medium Confidence"
    return "Needs Review"
  }

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD",
    }).format(amount)
  }

  const formatDate = (dateString: string) => {
    try {
      return format(new Date(dateString), "MMM dd, yyyy")
    } catch {
      return dateString
    }
  }

  const columns: ColumnDef<Receipt>[] = [
    {
      id: "select",
      header: ({ table }) => (
        <Checkbox
          checked={
            table.getIsAllPageRowsSelected() ||
            (table.getIsSomePageRowsSelected() && "indeterminate")
          }
          onCheckedChange={(value) => table.toggleAllPageRowsSelected(!!value)}
          aria-label="Select all"
        />
      ),
      cell: ({ row }) => (
        <Checkbox
          checked={row.getIsSelected()}
          onCheckedChange={(value) => row.toggleSelected(!!value)}
          aria-label="Select row"
        />
      ),
      enableSorting: false,
      enableHiding: false,
    },
    {
      id: "thumbnail",
      header: "Image",
      cell: ({ row }) => {
        const receipt = row.original
        const imageUrl = receipt.thumbnail_url || receipt.image_url

        return (
          <div className="w-12 h-12 rounded-lg border overflow-hidden bg-gray-100 flex items-center justify-center">
            {imageUrl ? (
              <img
                src={imageUrl}
                alt="Receipt thumbnail"
                className="w-full h-full object-cover"
                onError={(e) => {
                  // Fallback to icon if image fails to load
                  e.currentTarget.style.display = 'none'
                  e.currentTarget.parentElement!.innerHTML = '<Receipt className="w-6 h-6 text-gray-400" />'
                }}
              />
            ) : (
              <Receipt className="w-6 h-6 text-gray-400" />
            )}
          </div>
        )
      },
      enableSorting: false,
    },
    {
      accessorKey: "vendor_name",
      header: ({ column }) => {
        return (
          <Button
            variant="ghost"
            onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
          >
            Vendor
            <ArrowUpDown className="ml-2 h-4 w-4" />
          </Button>
        )
      },
      cell: ({ row }) => {
        const receipt = row.original
        return (
          <div>
            <div className="font-medium">{receipt.vendor_name || "Unknown Vendor"}</div>
            {receipt.business_purpose && (
              <div className="text-sm text-muted-foreground truncate max-w-[200px]">
                {receipt.business_purpose}
              </div>
            )}
          </div>
        )
      },
    },
    {
      accessorKey: "total_amount",
      header: ({ column }) => {
        return (
          <Button
            variant="ghost"
            onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
            className="justify-end"
          >
            Amount
            <ArrowUpDown className="ml-2 h-4 w-4" />
          </Button>
        )
      },
      cell: ({ row }) => {
        const amount = row.getValue("total_amount") as number
        return (
          <div className="text-right font-medium">
            {formatCurrency(amount)}
          </div>
        )
      },
    },
    {
      accessorKey: "receipt_date",
      header: ({ column }) => {
        return (
          <Button
            variant="ghost"
            onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
          >
            Date
            <ArrowUpDown className="ml-2 h-4 w-4" />
          </Button>
        )
      },
      cell: ({ row }) => {
        const dateString = row.getValue("receipt_date") as string
        return formatDate(dateString)
      },
    },
    {
      accessorKey: "category",
      header: "Category",
      cell: ({ row }) => {
        const receipt = row.original
        const category = receipt.category

        if (!category) {
          return <Badge variant="outline">Uncategorized</Badge>
        }

        return (
          <Badge variant="outline" className="flex items-center gap-1 w-fit">
            <div
              className="w-2 h-2 rounded-full"
              style={{ backgroundColor: category.color }}
            />
            {category.name}
          </Badge>
        )
      },
      filterFn: (row, id, value) => {
        const category = row.original.category
        return value.includes(category?.name || "uncategorized")
      },
    },
    {
      accessorKey: "payment_method",
      header: "Payment",
      cell: ({ row }) => {
        const method = row.getValue("payment_method") as string
        const methodLabels: { [key: string]: string } = {
          cash: "Cash",
          card: "Card",
          digital: "Digital"
        }
        return (
          <Badge variant="secondary">
            {methodLabels[method] || method}
          </Badge>
        )
      },
    },
    {
      id: "confidence",
      header: "OCR Status",
      cell: ({ row }) => {
        const receipt = row.original
        const confidence = receipt.ocr_confidence

        return (
          <Badge variant={getConfidenceBadgeVariant(confidence)}>
            {getConfidenceLabel(confidence)}
            {confidence && ` (${Math.round(confidence)}%)`}
          </Badge>
        )
      },
    },
    {
      id: "tags",
      header: "Tags",
      cell: ({ row }) => {
        const receipt = row.original
        const tags = receipt.tags

        if (!tags || tags.length === 0) {
          return <span className="text-muted-foreground">—</span>
        }

        return (
          <div className="flex flex-wrap gap-1 max-w-[150px]">
            {tags.slice(0, 2).map((tag) => (
              <Badge key={tag} variant="outline" className="text-xs">
                {tag}
              </Badge>
            ))}
            {tags.length > 2 && (
              <Badge variant="outline" className="text-xs">
                +{tags.length - 2}
              </Badge>
            )}
          </div>
        )
      },
    },
    {
      id: "actions",
      enableHiding: false,
      cell: ({ row }) => {
        const receipt = row.original

        return (
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" className="h-8 w-8 p-0">
                <span className="sr-only">Open menu</span>
                <MoreHorizontal className="h-4 w-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuLabel>Actions</DropdownMenuLabel>
              <DropdownMenuItem
                onClick={() => onView?.(receipt)}
              >
                <Eye className="mr-2 h-4 w-4" />
                View Details
              </DropdownMenuItem>
              <DropdownMenuItem
                onClick={() => onEdit?.(receipt)}
              >
                <Edit className="mr-2 h-4 w-4" />
                Edit Receipt
              </DropdownMenuItem>
              {receipt.needs_review && onReprocess && (
                <DropdownMenuItem
                  onClick={() => onReprocess(receipt)}
                >
                  <Receipt className="mr-2 h-4 w-4" />
                  Reprocess OCR
                </DropdownMenuItem>
              )}
              <DropdownMenuSeparator />
              <DropdownMenuItem
                onClick={() => navigator.clipboard.writeText(receipt.id)}
              >
                Copy Receipt ID
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem
                onClick={() => onDelete?.([receipt])}
                className="text-destructive focus:text-destructive"
              >
                <Trash2 className="mr-2 h-4 w-4" />
                Delete Receipt
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        )
      },
    },
  ]

  const table = useReactTable({
    data,
    columns,
    onSortingChange: setSorting,
    onColumnFiltersChange: setColumnFilters,
    getCoreRowModel: getCoreRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    onColumnVisibilityChange: setColumnVisibility,
    onRowSelectionChange: setRowSelection,
    state: {
      sorting,
      columnFilters,
      columnVisibility,
      rowSelection,
    },
    initialState: {
      pagination: {
        pageSize: 10,
      },
    },
  })

  const selectedReceipts = table.getFilteredSelectedRowModel().rows.map(row => row.original)

  return (
    <div className="w-full space-y-4">
      {/* Filters and Actions */}
      <div className="flex items-center justify-between">
        <div className="flex flex-1 items-center space-x-2">
          <Input
            placeholder="Search vendors..."
            value={(table.getColumn("vendor_name")?.getFilterValue() as string) ?? ""}
            onChange={(event) =>
              table.getColumn("vendor_name")?.setFilterValue(event.target.value)
            }
            className="h-8 w-[150px] lg:w-[250px]"
          />
        </div>

        <div className="flex items-center space-x-2">
          {selectedReceipts.length > 0 && (
            <Button
              variant="destructive"
              size="sm"
              onClick={() => onDelete?.(selectedReceipts)}
            >
              <Trash2 className="mr-2 h-4 w-4" />
              Delete Selected ({selectedReceipts.length})
            </Button>
          )}

          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" size="sm">
                Columns <ChevronDown className="ml-2 h-4 w-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              {table
                .getAllColumns()
                .filter((column) => column.getCanHide())
                .map((column) => {
                  return (
                    <DropdownMenuCheckboxItem
                      key={column.id}
                      className="capitalize"
                      checked={column.getIsVisible()}
                      onCheckedChange={(value) =>
                        column.toggleVisibility(!!value)
                      }
                    >
                      {column.id}
                    </DropdownMenuCheckboxItem>
                  )
                })}
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>

      {/* Data Table */}
      <div className="rounded-md border">
        <Table>
          <TableHeader>
            {table.getHeaderGroups().map((headerGroup) => (
              <TableRow key={headerGroup.id}>
                {headerGroup.headers.map((header) => {
                  return (
                    <TableHead key={header.id}>
                      {header.isPlaceholder
                        ? null
                        : flexRender(
                            header.column.columnDef.header,
                            header.getContext()
                          )}
                    </TableHead>
                  )
                })}
              </TableRow>
            ))}
          </TableHeader>
          <TableBody>
            {table.getRowModel().rows?.length ? (
              table.getRowModel().rows.map((row) => (
                <TableRow
                  key={row.id}
                  data-state={row.getIsSelected() && "selected"}
                  className="cursor-pointer hover:bg-muted/50"
                  onClick={() => onView?.(row.original)}
                >
                  {row.getVisibleCells().map((cell) => (
                    <TableCell key={cell.id}>
                      {flexRender(
                        cell.column.columnDef.cell,
                        cell.getContext()
                      )}
                    </TableCell>
                  ))}
                </TableRow>
              ))
            ) : (
              <TableRow>
                <TableCell
                  colSpan={columns.length}
                  className="h-24 text-center"
                >
                  <div className="flex flex-col items-center justify-center space-y-2">
                    <Receipt className="h-12 w-12 text-muted-foreground" />
                    <div className="text-lg font-medium">No receipts found</div>
                    <div className="text-sm text-muted-foreground">
                      Start by capturing your first receipt!
                    </div>
                  </div>
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>

      {/* Pagination */}
      <div className="flex items-center justify-between space-x-2 py-4">
        <div className="flex-1 text-sm text-muted-foreground">
          {table.getFilteredSelectedRowModel().rows.length} of{" "}
          {table.getFilteredRowModel().rows.length} row(s) selected.
        </div>
        <div className="flex items-center space-x-6 lg:space-x-8">
          <div className="flex items-center space-x-2">
            <p className="text-sm font-medium">Rows per page</p>
            <select
              value={table.getState().pagination.pageSize}
              onChange={(e) => table.setPageSize(Number(e.target.value))}
              className="h-8 w-[70px] rounded-md border border-input bg-background px-3 py-1 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
            >
              {[10, 20, 30, 40, 50].map((pageSize) => (
                <option key={pageSize} value={pageSize}>
                  {pageSize}
                </option>
              ))}
            </select>
          </div>
          <div className="flex w-[100px] items-center justify-center text-sm font-medium">
            Page {table.getState().pagination.pageIndex + 1} of{" "}
            {table.getPageCount()}
          </div>
          <div className="flex items-center space-x-2">
            <Button
              variant="outline"
              className="hidden h-8 w-8 p-0 lg:flex"
              onClick={() => table.setPageIndex(0)}
              disabled={!table.getCanPreviousPage()}
            >
              <span className="sr-only">Go to first page</span>
              <div className="h-4 w-4">⇤</div>
            </Button>
            <Button
              variant="outline"
              className="h-8 w-8 p-0"
              onClick={() => table.previousPage()}
              disabled={!table.getCanPreviousPage()}
            >
              <span className="sr-only">Go to previous page</span>
              <div className="h-4 w-4">←</div>
            </Button>
            <Button
              variant="outline"
              className="h-8 w-8 p-0"
              onClick={() => table.nextPage()}
              disabled={!table.getCanNextPage()}
            >
              <span className="sr-only">Go to next page</span>
              <div className="h-4 w-4">→</div>
            </Button>
            <Button
              variant="outline"
              className="hidden h-8 w-8 p-0 lg:flex"
              onClick={() => table.setPageIndex(table.getPageCount() - 1)}
              disabled={!table.getCanNextPage()}
            >
              <span className="sr-only">Go to last page</span>
              <div className="h-4 w-4">⇥</div>
            </Button>
          </div>
        </div>
      </div>
    </div>
  )
}