# Data Models

```poml
SECTION_METADATA:
  type: "data_specification"
  section_number: 4
  focus: "Core business entities and their relationships"
  design_principles: ["immutable_where_possible", "confidence_tracking", "audit_trail"]

DATA_MODEL_ARCHITECTURE:
  approach: "Domain-driven design with confidence scoring"
  core_entities: ["Receipt", "ProcessingResult", "ExportBatch"]
  confidence_tracking: "All OCR results include confidence scores"
  versioning: "Optimistic locking for concurrent updates"
  audit_trail: "Full history of manual edits and corrections"
```

## 4.1 Receipt Model

```poml
RECEIPT_ENTITY:
  purpose: "Core entity representing a captured and processed receipt with extracted data fields and confidence scores"
  lifecycle: "captured -> processing -> ready -> exported"
  storage: "Primary table with denormalized OCR results for query performance"
  
KEY_ATTRIBUTES:
  identity:
    id: "String (UUID) - Unique identifier"
    version: "number - Optimistic locking version"
  
  content:
    imageUri: "String - Local file path to receipt image"
    thumbnailUri: "String - Compressed preview image path"
    ocrResults: "ProcessingResult - Extracted data with confidence"
  
  metadata:
    capturedAt: "DateTime - When photo was taken"
    lastModified: "DateTime - Last edit timestamp"
    status: "ReceiptStatus - Processing state"
    notes: "string? - User notes"
    isDeleted: "boolean - Soft delete flag"
  
  processing_info:
    metadata: "ReceiptMetadata - Device and app information"
```

**Purpose:** Core entity representing a captured and processed receipt with extracted data fields and confidence scores

**Key Attributes:**
- id: String (UUID) - Unique identifier
- imageUri: String - Local file path to receipt image
- thumbnailUri: String - Compressed preview image path
- capturedAt: DateTime - When photo was taken
- status: ReceiptStatus - Processing state
- ocrResults: ProcessingResult - Extracted data with confidence
- metadata: ReceiptMetadata - Device and app information
- lastModified: DateTime - Last edit timestamp

**TypeScript Interface:**
```typescript
interface Receipt {
  id: string;
  imageUri: string;
  thumbnailUri: string;
  capturedAt: DateTime;
  status: ReceiptStatus;
  ocrResults: ProcessingResult;
  metadata: ReceiptMetadata;
  lastModified: DateTime;
  notes?: string;
  isDeleted: boolean;
  version: number; // For optimistic locking
}

enum ReceiptStatus {
  CAPTURED = 'captured',
  PROCESSING = 'processing',
  READY = 'ready',
  EXPORTED = 'exported',
  ERROR = 'error'
}
```

```poml
RECEIPT_RELATIONSHIPS:
  processing_result:
    type: "has_one"
    entity: "ProcessingResult"
    storage: "embedded"
  
  export_batches:
    type: "belongs_to_many"
    entity: "ExportBatch"
    junction: "export_batch_receipts"
```

**Relationships:**
- Has one ProcessingResult (embedded)
- Belongs to many ExportBatch (via junction table)

## 4.2 ProcessingResult Model

```poml
PROCESSING_RESULT_ENTITY:
  purpose: "Contains OCR-extracted data for the four core fields with confidence scores and correction history"
  field_count: 4
  core_fields: ["merchant", "date", "total", "tax"]
  confidence_range: "0-100"
  
CONFIDENCE_SCORING:
  overall_calculation: "Weighted average of field confidences"
  weighting: 
    total: 40  # Most critical field
    date: 30   # Important for accounting
    merchant: 20  # Useful for categorization
    tax: 10    # Nice to have but often missing
  
CORRECTION_TRACKING:
  original_value_preservation: "Always keep OCR original"
  edit_flagging: "Mark fields as manually edited"
  correction_history: "Full audit trail of changes"
```

**Purpose:** Contains OCR-extracted data for the four core fields with confidence scores and correction history

**TypeScript Interface:**
```typescript
interface ProcessingResult {
  merchant: FieldData;
  date: FieldData;
  total: FieldData;
  tax: FieldData;
  overallConfidence: number;
  processingEngine: 'ml_kit' | 'tensorflow_lite' | 'manual';
  processingDurationMs: number;
  corrections: CorrectionHistory[];
}

interface FieldData {
  value: string | number | Date;
  confidence: number; // 0-100
  boundingBox?: BoundingBox; // OCR location in image
  isManuallyEdited: boolean;
  originalValue?: string; // Pre-edit value
  validationStatus: 'valid' | 'warning' | 'error';
  validationMessage?: string;
}
```

```poml
FIELD_DATA_VALIDATION:
  merchant:
    type: "string"
    validation: "non-empty, reasonable length"
    normalization: "Basic cleaning, common abbreviations"
  
  date:
    type: "Date"
    validation: "Valid date, reasonable range (past 2 years to today)"
    formats: ["MM/DD/YYYY", "DD/MM/YYYY", "YYYY-MM-DD"]
  
  total:
    type: "number"
    validation: "Positive number, reasonable range ($0.01 to $9999)"
    formatting: "2 decimal places"
  
  tax:
    type: "number" 
    validation: "Non-negative, less than or equal to total"
    formatting: "2 decimal places"
```

## 4.3 ExportBatch Model

```poml
EXPORT_BATCH_ENTITY:
  purpose: "Represents a collection of receipts exported together as a CSV file with validation results"
  export_formats: ["quickbooks", "xero", "generic"]
  validation_approach: "Pre-flight validation before CSV generation"
  
BATCH_PROCESSING:
  size_limits: "Up to 1000 receipts per batch"
  validation_rules: "Format-specific requirements"
  error_handling: "Detailed validation reporting"
  
STATUS_FLOW:
  states: ["pending", "validating", "generating", "complete", "failed"]
  validation_stage: "Check all receipts meet format requirements"
  generation_stage: "Create CSV content with proper formatting"
```

**Purpose:** Represents a collection of receipts exported together as a CSV file with validation results

**TypeScript Interface:**
```typescript
interface ExportBatch {
  id: string;
  createdAt: DateTime;
  receiptIds: string[];
  format: ExportFormat;
  dateRange: DateRange;
  validationResults: ValidationResult;
  csvContent?: string; // Stored temporarily
  fileName: string;
  status: ExportStatus;
  exportPath?: string; // Where file was saved
}

enum ExportFormat {
  QUICKBOOKS = 'quickbooks',
  XERO = 'xero', 
  GENERIC = 'generic'
}
```

```poml
EXPORT_FORMAT_SPECIFICATIONS:
  quickbooks:
    required_fields: ["Date", "Amount", "Vendor", "Account"]
    date_format: "MM/dd/yyyy"
    amount_format: "0.00"
    encoding: "UTF-8"
  
  xero:
    required_fields: ["Date", "Amount", "Reference", "Description"]
    date_format: "dd/MM/yyyy"
    amount_format: "0.00"
    encoding: "UTF-8"
  
  generic:
    required_fields: ["Date", "Total", "Merchant", "Tax"]
    date_format: "YYYY-MM-DD"
    amount_format: "0.00"
    encoding: "UTF-8"

VALIDATION_RULES:
  pre_export_checks:
    - "All required fields present"
    - "Valid data types"
    - "Date ranges reasonable"
    - "Currency amounts valid"
    - "No duplicate receipts"
  
  format_compliance:
    - "CSV structure matches template"
    - "Headers correctly formatted"
    - "Character encoding compatible"
    - "File size within limits"
```