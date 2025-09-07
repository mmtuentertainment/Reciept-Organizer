# API Specification

```poml
SECTION_METADATA:
  type: "service_interfaces"
  section_number: 5
  focus: "Internal service contracts for on-device processing"
  paradigm: "Service-oriented architecture without network APIs"

API_ARCHITECTURE:
  paradigm: "Local service interfaces"
  network_apis: false
  communication: "Direct method calls"
  async_pattern: "Future-based with Stream support"
  error_handling: "Typed exceptions"
```

## Internal Service Interfaces

Since the Receipt Organizer MVP operates entirely on-device without network APIs, this section documents the **internal service interfaces** that define contracts between application layers.

```poml
SERVICE_INTERFACE_DESIGN:
  principles:
    - "Clear separation of concerns"
    - "Testable through mocking"
    - "Future-based async operations"
    - "Typed error handling"
    - "Resource lifecycle management"
  
  patterns:
    - "Repository pattern for data access"
    - "Service layer for business logic"
    - "Factory pattern for service creation"
    - "Observer pattern for reactive updates"
```

## 5.1 Core Service Interfaces

```poml
CAMERA_SERVICE_INTERFACE:
  responsibility: "Receipt capture with edge detection and preprocessing"
  key_operations: ["initialize", "capture", "detect_edges", "apply_crop", "dispose"]
  resource_management: "Camera resource lifecycle"
  performance_requirements: ["<2s initialization", "<500ms capture", "30fps preview"]
```

#### ICameraService
```dart
abstract class ICameraService {
  /// Initialize camera with receipt-optimized settings
  Future<void> initialize();
  
  /// Capture receipt photo with edge detection
  Future<CaptureResult> captureReceipt();
  
  /// Get camera preview stream for viewfinder
  Stream<CameraFrame> getPreviewStream();
  
  /// Apply edge detection overlay
  Future<EdgeDetectionResult> detectEdges(CameraFrame frame);
  
  /// Manual crop adjustment
  Future<Uint8List> applyCrop(Uint8List image, CropBounds bounds);
  
  /// Release camera resources
  Future<void> dispose();
}
```

```poml
OCR_SERVICE_INTERFACE:
  responsibility: "Text extraction with confidence scoring and fallback engines"
  key_operations: ["process_receipt", "extract_field", "preprocess_image", "validate_result"]
  engines: ["Google ML Kit", "TensorFlow Lite"]
  performance_requirements: ["<5s processing", "89-92% accuracy", "<25MB memory spike"]
  fallback_strategy: "Automatic engine switching on failure"
```

#### IOCRService
```dart
abstract class IOCRService {
  /// Process receipt image and extract fields
  Future<ProcessingResult> processReceipt(
    Uint8List imageData, {
    OCREngine engine = OCREngine.auto,
  });
  
  /// Extract specific field with enhanced processing
  Future<FieldData> extractField(
    Uint8List imageData,
    FieldType fieldType,
    BoundingBox? hint,
  );
  
  /// Preprocess image for better OCR
  Future<Uint8List> preprocessImage(
    Uint8List imageData,
    PreprocessingOptions options,
  );
  
  /// Get available OCR engines
  Future<List<OCREngine>> getAvailableEngines();
  
  /// Validate OCR result quality
  Future<ValidationResult> validateResult(ProcessingResult result);
}
```

```poml
STORAGE_SERVICE_INTERFACE:
  responsibility: "Local data persistence with reactive queries"
  key_operations: ["save", "query", "update", "delete", "stats"]
  data_layer: "SQLite with RxDB reactive layer"
  performance_requirements: ["<50ms single operations", "<500ms batch operations"]
  reactive_updates: "Stream-based data changes"
```

#### IStorageService
```dart
abstract class IStorageService {
  /// Save receipt to local database
  Future<Receipt> saveReceipt(Receipt receipt);
  
  /// Retrieve receipt by ID
  Future<Receipt?> getReceipt(String id);
  
  /// Query receipts with filters
  Stream<List<Receipt>> queryReceipts({
    DateRange? dateRange,
    ReceiptStatus? status,
    String? searchTerm,
    int? limit,
    int? offset,
  });
  
  /// Update receipt fields
  Future<Receipt> updateReceipt(
    String id,
    Map<String, dynamic> updates,
  );
  
  /// Soft delete receipt
  Future<void> deleteReceipt(String id);
  
  /// Get storage statistics
  Future<StorageStats> getStorageStats();
}
```

```poml
EXPORT_SERVICE_INTERFACE:
  responsibility: "CSV generation with format-specific validation"
  key_operations: ["validate", "generate_csv", "export_to_file", "preview"]
  supported_formats: ["QuickBooks", "Xero", "Generic"]
  performance_requirements: ["<3s for 100 receipts", "<10s for 1000 receipts"]
  validation_approach: "Pre-flight validation with detailed error reporting"
```

#### IExportService
```dart
abstract class IExportService {
  /// Validate receipts for export
  Future<ValidationResult> validateForExport(
    List<String> receiptIds,
    ExportFormat format,
  );
  
  /// Generate CSV content
  Future<String> generateCSV(
    List<Receipt> receipts,
    ExportFormat format,
  );
  
  /// Export receipts to file
  Future<ExportResult> exportToFile(
    List<String> receiptIds,
    ExportFormat format,
    String? customPath,
  );
  
  /// Get export templates
  Future<List<ExportTemplate>> getTemplates();
  
  /// Preview CSV output
  Future<CSVPreview> previewExport(
    List<String> receiptIds,
    ExportFormat format,
  );
}
```

```poml
SERVICE_ERROR_HANDLING:
  exception_hierarchy:
    base: "ServiceException"
    camera: "CameraServiceException"
    ocr: "OCRServiceException"
    storage: "StorageServiceException"
    export: "ExportServiceException"
  
  error_codes:
    camera: ["CAMERA_3001", "CAMERA_3002", "CAMERA_3003"]
    ocr: ["OCR_1001", "OCR_1002", "OCR_1003"]
    storage: ["STORAGE_2001", "STORAGE_2002", "STORAGE_2003"]
    export: ["EXPORT_4001", "EXPORT_4002", "EXPORT_4003"]
  
  recovery_strategies:
    camera: "Fallback to manual capture mode"
    ocr: "Switch to fallback engine or manual entry"
    storage: "Retry with exponential backoff"
    export: "Fix validation errors and retry"
```