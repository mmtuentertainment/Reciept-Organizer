'use client'

import { useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { 
  Upload, 
  Camera, 
  FileText, 
  X, 
  Check,
  AlertCircle,
  ArrowLeft,
  Image,
  Loader2,
  ChevronRight,
  Eye,
  Edit2,
  RotateCw,
  Plus,
  FileImage,
  Info,
  Sparkles,
  CheckCircle2
} from 'lucide-react'

// shadcn components
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardHeader, CardTitle, CardFooter } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'
import { Progress } from '@/components/ui/progress'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbPage,
  BreadcrumbSeparator,
} from '@/components/ui/breadcrumb'
import { Separator } from '@/components/ui/separator'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'

interface FilePreview {
  id: string
  file: File
  preview: string
  status: 'pending' | 'processing' | 'completed' | 'error'
  extractedData?: {
    merchant: string
    amount: string
    date: string
    category: string
    confidence: number
  }
}

export default function UploadPage() {
  const [files, setFiles] = useState<FilePreview[]>([])
  const [isDragging, setIsDragging] = useState(false)
  const [currentStep, setCurrentStep] = useState(1)
  const [processingAll, setProcessingAll] = useState(false)
  const router = useRouter()

  const handleDragOver = useCallback((e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(true)
  }, [])

  const handleDragLeave = useCallback((e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(false)
  }, [])

  const handleDrop = useCallback((e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(false)
    
    const droppedFiles = Array.from(e.dataTransfer.files)
    handleFiles(droppedFiles)
  }, [])

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files) {
      const selectedFiles = Array.from(e.target.files)
      handleFiles(selectedFiles)
    }
  }

  const handleFiles = (newFiles: File[]) => {
    const imageFiles = newFiles.filter(file => file.type.startsWith('image/'))
    
    const filePreviews: FilePreview[] = imageFiles.map(file => ({
      id: Math.random().toString(36).substr(2, 9),
      file,
      preview: URL.createObjectURL(file),
      status: 'pending' as const
    }))

    setFiles(prev => [...prev, ...filePreviews])
    if (filePreviews.length > 0) {
      setCurrentStep(2)
    }
  }

  const removeFile = (id: string) => {
    setFiles(prev => {
      const file = prev.find(f => f.id === id)
      if (file) {
        URL.revokeObjectURL(file.preview)
      }
      return prev.filter(f => f.id !== id)
    })
  }

  const processFiles = async () => {
    setProcessingAll(true)
    setCurrentStep(3)

    // Simulate OCR processing for each file
    for (let i = 0; i < files.length; i++) {
      const file = files[i]
      if (file.status === 'pending') {
        setFiles(prev => prev.map(f => 
          f.id === file.id ? { ...f, status: 'processing' as const } : f
        ))

        // Simulate OCR delay
        await new Promise(resolve => setTimeout(resolve, 2000))

        // Mock extracted data
        const mockData = {
          merchant: ['Starbucks', 'Target', 'Walmart', 'Amazon', 'Best Buy'][Math.floor(Math.random() * 5)],
          amount: (Math.random() * 200 + 10).toFixed(2),
          date: new Date(Date.now() - Math.random() * 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
          category: ['Food & Dining', 'Shopping', 'Transportation', 'Office Supplies'][Math.floor(Math.random() * 4)],
          confidence: Math.floor(Math.random() * 15 + 85)
        }

        setFiles(prev => prev.map(f => 
          f.id === file.id 
            ? { ...f, status: 'completed' as const, extractedData: mockData }
            : f
        ))
      }
    }

    setProcessingAll(false)
  }

  const saveReceipts = () => {
    // In a real app, this would save to the database
    router.push('/dashboard')
  }

  const allProcessed = files.length > 0 && files.every(f => f.status === 'completed')
  const hasFiles = files.length > 0

  const steps = [
    { number: 1, label: 'Upload', icon: Upload },
    { number: 2, label: 'Review', icon: Eye },
    { number: 3, label: 'Process', icon: Sparkles },
  ]

  return (
    <div className="flex h-screen overflow-hidden">
      {/* Sidebar - Reuse from dashboard */}
      <aside className="hidden w-64 overflow-y-auto bg-white border-r border-gray-200 lg:block">
        <div className="flex h-full flex-col">
          <div className="flex h-16 items-center gap-2 border-b px-6">
            <div className="flex items-center gap-2">
              <div className="h-8 w-8 rounded-lg bg-gradient-to-br from-primary to-purple-600 flex items-center justify-center">
                <FileText className="h-5 w-5 text-white" />
              </div>
              <span className="font-semibold">Receipt Organizer</span>
            </div>
          </div>
          <nav className="flex-1 space-y-1 px-3 py-4">
            <Link href="/dashboard" className="flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium text-gray-600 hover:bg-gray-50 hover:text-gray-900">
              <ArrowLeft className="h-4 w-4" />
              Back to Dashboard
            </Link>
          </nav>
        </div>
      </aside>

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Header */}
        <header className="h-16 border-b bg-white px-6 lg:px-8">
          <div className="flex h-full items-center justify-between">
            <div className="flex items-center gap-4">
              <Breadcrumb>
                <BreadcrumbList>
                  <BreadcrumbItem>
                    <BreadcrumbLink href="/">Home</BreadcrumbLink>
                  </BreadcrumbItem>
                  <BreadcrumbSeparator />
                  <BreadcrumbItem>
                    <BreadcrumbLink href="/dashboard">Dashboard</BreadcrumbLink>
                  </BreadcrumbItem>
                  <BreadcrumbSeparator />
                  <BreadcrumbItem>
                    <BreadcrumbPage>Upload Receipts</BreadcrumbPage>
                  </BreadcrumbItem>
                </BreadcrumbList>
              </Breadcrumb>
            </div>
          </div>
        </header>

        {/* Page Content */}
        <main className="flex-1 overflow-y-auto bg-gray-50/50 p-6 lg:p-8">
          <div className="mx-auto max-w-5xl space-y-8">
            {/* Page Title */}
            <div>
              <h1 className="text-3xl font-bold tracking-tight">Upload Receipts</h1>
              <p className="text-muted-foreground">
                Upload and process your receipts with AI-powered OCR extraction
              </p>
            </div>

            {/* Progress Steps */}
            <div className="flex items-center justify-between">
              {steps.map((step, index) => {
                const Icon = step.icon
                const isActive = currentStep === step.number
                const isCompleted = currentStep > step.number
                
                return (
                  <div key={step.number} className="flex items-center">
                    <div className={`flex items-center ${isActive || isCompleted ? 'text-primary' : 'text-gray-400'}`}>
                      <div className={`
                        w-10 h-10 rounded-full flex items-center justify-center border-2 transition-colors
                        ${isCompleted ? 'border-primary bg-primary text-white' : 
                          isActive ? 'border-primary bg-primary text-white' : 
                          'border-gray-300 bg-white'}
                      `}>
                        {isCompleted ? <Check className="w-5 h-5" /> : <Icon className="w-5 h-5" />}
                      </div>
                      <span className={`ml-3 font-medium ${isActive ? 'text-gray-900' : ''}`}>
                        {step.label}
                      </span>
                    </div>
                    {index < steps.length - 1 && (
                      <ChevronRight className="mx-4 text-gray-400" />
                    )}
                  </div>
                )
              })}
            </div>

            {/* Step Content */}
            {currentStep === 1 && (
              <Card>
                <CardHeader>
                  <CardTitle>Upload Your Receipts</CardTitle>
                  <CardDescription>
                    Drag and drop receipt images or click to browse
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div
                    onDragOver={handleDragOver}
                    onDragLeave={handleDragLeave}
                    onDrop={handleDrop}
                    className={`
                      border-2 border-dashed rounded-lg p-12 text-center transition-colors
                      ${isDragging 
                        ? 'border-primary bg-primary/5' 
                        : 'border-gray-300 hover:border-gray-400'}
                    `}
                  >
                    <Upload className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
                    <h3 className="text-lg font-semibold mb-2">
                      Drop your receipts here
                    </h3>
                    <p className="text-sm text-muted-foreground mb-4">
                      or click to browse from your device
                    </p>
                    
                    <input
                      type="file"
                      id="file-upload"
                      className="hidden"
                      multiple
                      accept="image/*"
                      onChange={handleFileSelect}
                    />
                    
                    <Button asChild>
                      <label htmlFor="file-upload" className="cursor-pointer">
                        <FileImage className="mr-2 h-4 w-4" />
                        Select Files
                      </label>
                    </Button>
                    
                    <div className="mt-6 flex items-center justify-center gap-6 text-xs text-muted-foreground">
                      <div className="flex items-center">
                        <CheckCircle2 className="w-4 h-4 mr-1 text-green-500" />
                        JPG, PNG, HEIC
                      </div>
                      <div className="flex items-center">
                        <CheckCircle2 className="w-4 h-4 mr-1 text-green-500" />
                        Multiple files
                      </div>
                      <div className="flex items-center">
                        <CheckCircle2 className="w-4 h-4 mr-1 text-green-500" />
                        Max 10MB each
                      </div>
                    </div>
                  </div>

                  <Alert className="mt-6">
                    <Info className="h-4 w-4" />
                    <AlertTitle>Tips for best results</AlertTitle>
                    <AlertDescription>
                      <ul className="mt-2 space-y-1 text-sm">
                        <li>• Ensure receipts are clearly visible and not blurry</li>
                        <li>• Avoid shadows and ensure good lighting</li>
                        <li>• Include the entire receipt in the frame</li>
                        <li>• Upload one receipt per image for better accuracy</li>
                      </ul>
                    </AlertDescription>
                  </Alert>
                </CardContent>
              </Card>
            )}

            {currentStep === 2 && (
              <Card>
                <CardHeader>
                  <CardTitle>Review Your Receipts</CardTitle>
                  <CardDescription>
                    {files.length} file{files.length !== 1 ? 's' : ''} selected for processing
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                    {files.map(file => (
                      <div key={file.id} className="relative group">
                        <div className="aspect-[3/4] rounded-lg overflow-hidden bg-gray-100">
                          <img
                            src={file.preview}
                            alt="Receipt preview"
                            className="w-full h-full object-cover"
                          />
                        </div>
                        <div className="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 transition-opacity rounded-lg flex items-center justify-center gap-2">
                          <Button size="icon" variant="secondary" className="h-8 w-8">
                            <Eye className="h-4 w-4" />
                          </Button>
                          <Button size="icon" variant="secondary" className="h-8 w-8">
                            <RotateCw className="h-4 w-4" />
                          </Button>
                          <Button 
                            size="icon" 
                            variant="secondary" 
                            className="h-8 w-8"
                            onClick={() => removeFile(file.id)}
                          >
                            <X className="h-4 w-4" />
                          </Button>
                        </div>
                        <div className="mt-2">
                          <p className="text-sm font-medium truncate">{file.file.name}</p>
                          <p className="text-xs text-muted-foreground">
                            {(file.file.size / 1024).toFixed(1)} KB
                          </p>
                        </div>
                      </div>
                    ))}
                    
                    <div className="aspect-[3/4] rounded-lg border-2 border-dashed border-gray-300 flex items-center justify-center">
                      <label htmlFor="file-upload-2" className="cursor-pointer text-center p-4">
                        <Plus className="h-8 w-8 text-muted-foreground mx-auto mb-2" />
                        <span className="text-sm text-muted-foreground">Add more</span>
                        <input
                          type="file"
                          id="file-upload-2"
                          className="hidden"
                          multiple
                          accept="image/*"
                          onChange={handleFileSelect}
                        />
                      </label>
                    </div>
                  </div>
                </CardContent>
                <CardFooter className="flex justify-between">
                  <Button variant="outline" onClick={() => setCurrentStep(1)}>
                    <ArrowLeft className="mr-2 h-4 w-4" />
                    Back
                  </Button>
                  <div className="space-x-2">
                    <Button
                      variant="outline"
                      onClick={() => {
                        setFiles([])
                        setCurrentStep(1)
                      }}
                    >
                      Cancel
                    </Button>
                    <Button onClick={processFiles}>
                      Process {files.length} Receipt{files.length !== 1 ? 's' : ''}
                      <ChevronRight className="ml-2 h-4 w-4" />
                    </Button>
                  </div>
                </CardFooter>
              </Card>
            )}

            {currentStep === 3 && (
              <div className="space-y-4">
                <Card>
                  <CardHeader>
                    <CardTitle>
                      {processingAll ? 'Processing Receipts...' : 'Review Extracted Data'}
                    </CardTitle>
                    <CardDescription>
                      {processingAll 
                        ? 'Using AI to extract information from your receipts' 
                        : 'Verify and edit the extracted information as needed'}
                    </CardDescription>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {files.map(file => (
                      <Card key={file.id}>
                        <CardContent className="pt-6">
                          <div className="flex gap-4">
                            <div className="w-24 h-32 rounded overflow-hidden bg-gray-100 flex-shrink-0">
                              <img
                                src={file.preview}
                                alt="Receipt"
                                className="w-full h-full object-cover"
                              />
                            </div>
                            
                            <div className="flex-1 space-y-4">
                              {file.status === 'processing' && (
                                <div className="flex items-center text-primary">
                                  <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                                  Processing with OCR...
                                </div>
                              )}
                              
                              {file.status === 'completed' && file.extractedData && (
                                <>
                                  <div className="flex items-center justify-between">
                                    <Badge variant="default">
                                      <CheckCircle2 className="mr-1 h-3 w-3" />
                                      Processed
                                    </Badge>
                                    <div className="flex items-center gap-2">
                                      <span className="text-sm text-muted-foreground">Confidence:</span>
                                      <div className="flex items-center gap-2">
                                        <Progress value={file.extractedData.confidence} className="w-20" />
                                        <span className="text-sm font-medium">{file.extractedData.confidence}%</span>
                                      </div>
                                    </div>
                                  </div>
                                  
                                  <div className="grid grid-cols-2 gap-4">
                                    <div className="space-y-2">
                                      <Label htmlFor={`merchant-${file.id}`}>Merchant</Label>
                                      <Input
                                        id={`merchant-${file.id}`}
                                        defaultValue={file.extractedData.merchant}
                                      />
                                    </div>
                                    <div className="space-y-2">
                                      <Label htmlFor={`amount-${file.id}`}>Amount</Label>
                                      <Input
                                        id={`amount-${file.id}`}
                                        defaultValue={`$${file.extractedData.amount}`}
                                      />
                                    </div>
                                    <div className="space-y-2">
                                      <Label htmlFor={`date-${file.id}`}>Date</Label>
                                      <Input
                                        id={`date-${file.id}`}
                                        type="date"
                                        defaultValue={file.extractedData.date}
                                      />
                                    </div>
                                    <div className="space-y-2">
                                      <Label htmlFor={`category-${file.id}`}>Category</Label>
                                      <Select defaultValue={file.extractedData.category}>
                                        <SelectTrigger id={`category-${file.id}`}>
                                          <SelectValue />
                                        </SelectTrigger>
                                        <SelectContent>
                                          <SelectItem value="Food & Dining">Food & Dining</SelectItem>
                                          <SelectItem value="Shopping">Shopping</SelectItem>
                                          <SelectItem value="Transportation">Transportation</SelectItem>
                                          <SelectItem value="Office Supplies">Office Supplies</SelectItem>
                                          <SelectItem value="Other">Other</SelectItem>
                                        </SelectContent>
                                      </Select>
                                    </div>
                                  </div>
                                </>
                              )}
                            </div>
                          </div>
                        </CardContent>
                      </Card>
                    ))}
                  </CardContent>
                </Card>

                {allProcessed && (
                  <Card>
                    <CardContent className="pt-6">
                      <div className="flex items-center justify-between">
                        <div>
                          <p className="font-medium">
                            {files.length} receipt{files.length !== 1 ? 's' : ''} ready to save
                          </p>
                          <p className="text-sm text-muted-foreground">
                            Review the extracted data above before saving
                          </p>
                        </div>
                        <div className="space-x-2">
                          <Button
                            variant="outline"
                            onClick={() => {
                              setFiles([])
                              setCurrentStep(1)
                            }}
                          >
                            Start Over
                          </Button>
                          <Button onClick={saveReceipts}>
                            <CheckCircle2 className="mr-2 h-4 w-4" />
                            Save All Receipts
                          </Button>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                )}
              </div>
            )}
          </div>
        </main>
      </div>
    </div>
  )
}