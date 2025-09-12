'use client'

import { useState } from 'react'
import Link from 'next/link'
import { 
  Download, 
  Calendar,
  FileText,
  Filter,
  Check,
  AlertCircle,
  ArrowLeft,
  ChevronDown,
  FileSpreadsheet,
  Package,
  Settings,
  Eye,
  Loader2
} from 'lucide-react'

interface ExportSettings {
  dateRange: 'all' | 'thisMonth' | 'lastMonth' | 'thisYear' | 'custom'
  startDate?: string
  endDate?: string
  format: 'quickbooks' | 'xero' | 'standard'
  categories: string[]
  includeImages: boolean
  groupByMerchant: boolean
}

export default function ExportPage() {
  const [settings, setSettings] = useState<ExportSettings>({
    dateRange: 'thisMonth',
    format: 'standard',
    categories: [],
    includeImages: false,
    groupByMerchant: false
  })
  const [isExporting, setIsExporting] = useState(false)
  const [showPreview, setShowPreview] = useState(false)
  const [exportHistory] = useState([
    { id: 1, date: '2025-01-10', format: 'QuickBooks', receipts: 42, size: '124 KB' },
    { id: 2, date: '2025-01-05', format: 'Standard CSV', receipts: 28, size: '89 KB' },
    { id: 3, date: '2024-12-31', format: 'Xero', receipts: 156, size: '412 KB' }
  ])

  const categories = [
    'Food & Dining',
    'Transportation',
    'Office Supplies',
    'Shopping',
    'Entertainment',
    'Travel',
    'Utilities',
    'Other'
  ]

  const handleExport = async () => {
    setIsExporting(true)
    // Simulate export process
    await new Promise(resolve => setTimeout(resolve, 2000))
    setIsExporting(false)
    
    // In a real app, this would trigger a download
    alert('Export completed! File downloaded.')
  }

  const getDateRangeText = () => {
    switch (settings.dateRange) {
      case 'all':
        return 'All time'
      case 'thisMonth':
        return 'This month'
      case 'lastMonth':
        return 'Last month'
      case 'thisYear':
        return 'This year'
      case 'custom':
        return `${settings.startDate} to ${settings.endDate}`
      default:
        return 'Select period'
    }
  }

  const previewData = [
    { date: '2025-01-10', merchant: 'Starbucks', amount: 15.75, category: 'Food & Dining' },
    { date: '2025-01-09', merchant: 'Office Depot', amount: 127.50, category: 'Office Supplies' },
    { date: '2025-01-08', merchant: 'Shell', amount: 45.00, category: 'Transportation' }
  ]

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center">
              <Link 
                href="/dashboard" 
                className="flex items-center text-gray-600 hover:text-blue-600 transition mr-4"
              >
                <ArrowLeft className="w-5 h-5 mr-2" />
                Back to Dashboard
              </Link>
            </div>
            <h1 className="text-xl font-semibold text-gray-800">Export Receipts</h1>
            <div className="w-32"></div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Export Settings */}
          <div className="lg:col-span-2 space-y-6">
            {/* Date Range */}
            <div className="bg-white rounded-xl shadow-sm p-6">
              <h2 className="text-lg font-semibold text-gray-800 mb-4 flex items-center">
                <Calendar className="w-5 h-5 mr-2 text-blue-600" />
                Date Range
              </h2>
              
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-4">
                {(['all', 'thisMonth', 'lastMonth', 'thisYear'] as const).map(range => (
                  <button
                    key={range}
                    onClick={() => setSettings({ ...settings, dateRange: range })}
                    className={`px-4 py-2 rounded-lg border-2 transition ${
                      settings.dateRange === range
                        ? 'border-blue-600 bg-blue-50 text-blue-600'
                        : 'border-gray-200 hover:border-gray-300'
                    }`}
                  >
                    {range === 'all' && 'All Time'}
                    {range === 'thisMonth' && 'This Month'}
                    {range === 'lastMonth' && 'Last Month'}
                    {range === 'thisYear' && 'This Year'}
                  </button>
                ))}
              </div>

              {/* Custom Date Range */}
              <div className="flex items-center space-x-4">
                <button
                  onClick={() => setSettings({ ...settings, dateRange: 'custom' })}
                  className={`px-4 py-2 rounded-lg border-2 transition ${
                    settings.dateRange === 'custom'
                      ? 'border-blue-600 bg-blue-50 text-blue-600'
                      : 'border-gray-200 hover:border-gray-300'
                  }`}
                >
                  Custom Range
                </button>
                
                {settings.dateRange === 'custom' && (
                  <>
                    <input
                      type="date"
                      value={settings.startDate}
                      onChange={(e) => setSettings({ ...settings, startDate: e.target.value })}
                      className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                    <span className="text-gray-500">to</span>
                    <input
                      type="date"
                      value={settings.endDate}
                      onChange={(e) => setSettings({ ...settings, endDate: e.target.value })}
                      className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                  </>
                )}
              </div>
            </div>

            {/* Export Format */}
            <div className="bg-white rounded-xl shadow-sm p-6">
              <h2 className="text-lg font-semibold text-gray-800 mb-4 flex items-center">
                <FileSpreadsheet className="w-5 h-5 mr-2 text-blue-600" />
                Export Format
              </h2>
              
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div
                  onClick={() => setSettings({ ...settings, format: 'quickbooks' })}
                  className={`p-4 rounded-lg border-2 cursor-pointer transition ${
                    settings.format === 'quickbooks'
                      ? 'border-blue-600 bg-blue-50'
                      : 'border-gray-200 hover:border-gray-300'
                  }`}
                >
                  <div className="flex items-center justify-between mb-2">
                    <Package className="w-8 h-8 text-green-600" />
                    {settings.format === 'quickbooks' && (
                      <Check className="w-5 h-5 text-blue-600" />
                    )}
                  </div>
                  <h3 className="font-semibold text-gray-800">QuickBooks</h3>
                  <p className="text-sm text-gray-600 mt-1">
                    Optimized for QuickBooks import
                  </p>
                </div>

                <div
                  onClick={() => setSettings({ ...settings, format: 'xero' })}
                  className={`p-4 rounded-lg border-2 cursor-pointer transition ${
                    settings.format === 'xero'
                      ? 'border-blue-600 bg-blue-50'
                      : 'border-gray-200 hover:border-gray-300'
                  }`}
                >
                  <div className="flex items-center justify-between mb-2">
                    <Package className="w-8 h-8 text-blue-600" />
                    {settings.format === 'xero' && (
                      <Check className="w-5 h-5 text-blue-600" />
                    )}
                  </div>
                  <h3 className="font-semibold text-gray-800">Xero</h3>
                  <p className="text-sm text-gray-600 mt-1">
                    Compatible with Xero accounting
                  </p>
                </div>

                <div
                  onClick={() => setSettings({ ...settings, format: 'standard' })}
                  className={`p-4 rounded-lg border-2 cursor-pointer transition ${
                    settings.format === 'standard'
                      ? 'border-blue-600 bg-blue-50'
                      : 'border-gray-200 hover:border-gray-300'
                  }`}
                >
                  <div className="flex items-center justify-between mb-2">
                    <FileText className="w-8 h-8 text-purple-600" />
                    {settings.format === 'standard' && (
                      <Check className="w-5 h-5 text-blue-600" />
                    )}
                  </div>
                  <h3 className="font-semibold text-gray-800">Standard CSV</h3>
                  <p className="text-sm text-gray-600 mt-1">
                    Universal CSV format
                  </p>
                </div>
              </div>
            </div>

            {/* Categories Filter */}
            <div className="bg-white rounded-xl shadow-sm p-6">
              <h2 className="text-lg font-semibold text-gray-800 mb-4 flex items-center">
                <Filter className="w-5 h-5 mr-2 text-blue-600" />
                Categories
              </h2>
              
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                {categories.map(category => (
                  <label key={category} className="flex items-center space-x-2 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={settings.categories.includes(category)}
                      onChange={(e) => {
                        if (e.target.checked) {
                          setSettings({ 
                            ...settings, 
                            categories: [...settings.categories, category] 
                          })
                        } else {
                          setSettings({ 
                            ...settings, 
                            categories: settings.categories.filter(c => c !== category) 
                          })
                        }
                      }}
                      className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                    />
                    <span className="text-sm text-gray-700">{category}</span>
                  </label>
                ))}
              </div>
              
              <div className="mt-4 text-sm text-gray-500">
                {settings.categories.length === 0 
                  ? 'All categories selected' 
                  : `${settings.categories.length} categories selected`}
              </div>
            </div>

            {/* Additional Options */}
            <div className="bg-white rounded-xl shadow-sm p-6">
              <h2 className="text-lg font-semibold text-gray-800 mb-4 flex items-center">
                <Settings className="w-5 h-5 mr-2 text-blue-600" />
                Additional Options
              </h2>
              
              <div className="space-y-3">
                <label className="flex items-center justify-between cursor-pointer">
                  <span className="text-gray-700">Include receipt images</span>
                  <input
                    type="checkbox"
                    checked={settings.includeImages}
                    onChange={(e) => setSettings({ ...settings, includeImages: e.target.checked })}
                    className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                </label>
                
                <label className="flex items-center justify-between cursor-pointer">
                  <span className="text-gray-700">Group by merchant</span>
                  <input
                    type="checkbox"
                    checked={settings.groupByMerchant}
                    onChange={(e) => setSettings({ ...settings, groupByMerchant: e.target.checked })}
                    className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                </label>
              </div>
            </div>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Export Summary */}
            <div className="bg-white rounded-xl shadow-sm p-6">
              <h3 className="text-lg font-semibold text-gray-800 mb-4">Export Summary</h3>
              
              <div className="space-y-3 mb-6">
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600">Date Range:</span>
                  <span className="font-medium text-gray-800">{getDateRangeText()}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600">Format:</span>
                  <span className="font-medium text-gray-800 capitalize">{settings.format}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600">Estimated Receipts:</span>
                  <span className="font-medium text-gray-800">42</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600">File Size:</span>
                  <span className="font-medium text-gray-800">~124 KB</span>
                </div>
              </div>

              <div className="space-y-3">
                <button
                  onClick={() => setShowPreview(!showPreview)}
                  className="w-full flex items-center justify-center space-x-2 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition"
                >
                  <Eye className="w-4 h-4" />
                  <span>Preview Data</span>
                </button>
                
                <button
                  onClick={handleExport}
                  disabled={isExporting}
                  className="w-full flex items-center justify-center space-x-2 bg-gradient-to-r from-blue-600 to-purple-600 text-white px-4 py-3 rounded-lg font-semibold hover:shadow-lg transition disabled:opacity-50"
                >
                  {isExporting ? (
                    <>
                      <Loader2 className="w-5 h-5 animate-spin" />
                      <span>Exporting...</span>
                    </>
                  ) : (
                    <>
                      <Download className="w-5 h-5" />
                      <span>Export Now</span>
                    </>
                  )}
                </button>
              </div>
            </div>

            {/* Export History */}
            <div className="bg-white rounded-xl shadow-sm p-6">
              <h3 className="text-lg font-semibold text-gray-800 mb-4">Recent Exports</h3>
              
              <div className="space-y-3">
                {exportHistory.map(export_ => (
                  <div key={export_.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                    <div>
                      <p className="text-sm font-medium text-gray-800">{export_.format}</p>
                      <p className="text-xs text-gray-500">
                        {export_.date} • {export_.receipts} receipts
                      </p>
                    </div>
                    <button className="text-blue-600 hover:text-blue-700">
                      <Download className="w-4 h-4" />
                    </button>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* Preview Modal */}
        {showPreview && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-xl max-w-4xl w-full max-h-[80vh] overflow-hidden">
              <div className="p-6 border-b border-gray-200 flex items-center justify-between">
                <h3 className="text-lg font-semibold text-gray-800">Data Preview</h3>
                <button
                  onClick={() => setShowPreview(false)}
                  className="p-1 hover:bg-gray-100 rounded"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>
              
              <div className="p-6 overflow-auto">
                <table className="min-w-full">
                  <thead>
                    <tr className="border-b border-gray-200">
                      <th className="text-left py-2 px-4 text-sm font-medium text-gray-700">Date</th>
                      <th className="text-left py-2 px-4 text-sm font-medium text-gray-700">Merchant</th>
                      <th className="text-left py-2 px-4 text-sm font-medium text-gray-700">Amount</th>
                      <th className="text-left py-2 px-4 text-sm font-medium text-gray-700">Category</th>
                    </tr>
                  </thead>
                  <tbody>
                    {previewData.map((row, index) => (
                      <tr key={index} className="border-b border-gray-100">
                        <td className="py-2 px-4 text-sm text-gray-600">{row.date}</td>
                        <td className="py-2 px-4 text-sm text-gray-900">{row.merchant}</td>
                        <td className="py-2 px-4 text-sm text-gray-900">${row.amount.toFixed(2)}</td>
                        <td className="py-2 px-4 text-sm text-gray-600">{row.category}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
                
                <div className="mt-4 p-3 bg-blue-50 rounded-lg">
                  <p className="text-sm text-blue-800">
                    <AlertCircle className="w-4 h-4 inline mr-1" />
                    This is a preview of the first few rows. The actual export will contain all selected receipts.
                  </p>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}