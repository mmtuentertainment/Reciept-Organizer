# Coding Standards

```poml
DOCUMENT_METADATA:
  type: "development_standards"
  purpose: "Comprehensive coding standards for Receipt Organizer MVP"
  scope: "Fullstack Flutter development with Dart"
  enforcement: "Automated via analysis_options.yaml and CI/CD"
  last_updated: "2025-01-06"
  
STANDARDS_PHILOSOPHY:
  approach: "Consistency over individual preference"
  automation: "Tooling enforces standards where possible"
  readability: "Code is read more than written"
  maintainability: "Future developers should understand intent"
  performance: "Mobile-first optimization mindset"
```

## Critical Fullstack Rules

```poml
CRITICAL_RULES:
  architecture_boundaries:
    - rule: "Type Sharing"
      description: "Always define shared types in `/packages/shared` and import from there"
      enforcement: "Never duplicate type definitions"
      rationale: "Single source of truth for data contracts"
    
    - rule: "API Calls"
      description: "Never make direct HTTP calls - always use service layer interfaces" 
      enforcement: "All network communication through service contracts"
      rationale: "Testability and abstraction"
    
    - rule: "Environment Variables"
      description: "Access only through `AppConfig` objects, never `process.env` or `dotenv` directly"
      enforcement: "Configuration abstraction layer required"
      rationale: "Type safety and validation"
  
  error_handling:
    - rule: "Service Error Handling"
      description: "All service methods must use try-catch and throw typed exceptions"
      enforcement: "Use exceptions from `/core/exceptions`"
      rationale: "Consistent error reporting and recovery"
    
    - rule: "State Updates"
      description: "Never mutate state directly - use Riverpod notifiers with `copyWith` patterns"
      enforcement: "Immutable state objects only"
      rationale: "Predictable state management"
  
  data_access:
    - rule: "Database Access"
      description: "Only repositories can access database - services must use repository interfaces"
      enforcement: "Repository pattern abstraction"
      rationale: "Clean architecture separation"
    
    - rule: "Image Handling"
      description: "Always compress images before storage using `ImageService.compressImage()`"
      enforcement: "No direct image storage without compression"
      rationale: "Mobile storage optimization"
  
  resource_management:
    - rule: "Memory Management"
      description: "Dispose all controllers, streams, and listeners in widget `dispose()` methods"
      enforcement: "Required for all StatefulWidgets"
      rationale: "Prevent memory leaks"
    
    - rule: "File Paths"
      description: "Always validate paths with `SecurityManager.isValidPath()` before file operations"
      enforcement: "Security validation required"
      rationale: "Prevent directory traversal attacks"
```

## Naming Conventions

```poml
NAMING_CONVENTIONS:
  consistency_principle: "Consistent naming reduces cognitive load"
  flutter_alignment: "Follow Flutter framework conventions"
  business_context: "Names should reflect business domain"
  
NAMING_MATRIX:
  components:
    pattern: "PascalCase"
    example: "ReceiptCard.dart"
    rationale: "Flutter widget convention"
  
  services:
    frontend: "PascalCase with 'Service'"
    backend: "PascalCase with 'Service'"
    example: "OCRService.dart"
    rationale: "Clear service identification"
  
  repositories:
    pattern: "PascalCase with 'Repository'"
    example: "ReceiptRepository.dart"
    rationale: "Data access layer identification"
  
  providers:
    pattern: "camelCase with 'Provider'"
    example: "receiptListProvider"
    rationale: "Riverpod convention"
  
  methods:
    pattern: "camelCase"
    example: "processReceipt()"
    rationale: "Dart language convention"
  
  constants:
    pattern: "SCREAMING_SNAKE_CASE"
    example: "MAX_IMAGE_SIZE"
    rationale: "Global constant identification"
  
  database_tables:
    pattern: "snake_case"
    example: "receipt_history"
    rationale: "SQL convention"
  
  test_files:
    pattern: "snake_case_test.dart"
    example: "ocr_service_test.dart"
    rationale: "Test file identification"
```

| Element | Frontend | Backend | Example |
|---------|----------|---------|---------|
| Components | PascalCase | - | `ReceiptCard.dart` |
| Services | PascalCase with "Service" | PascalCase with "Service" | `OCRService.dart` |
| Repositories | PascalCase with "Repository" | PascalCase with "Repository" | `ReceiptRepository.dart` |
| Providers | camelCase with "Provider" | - | `receiptListProvider` |
| Methods | camelCase | camelCase | `processReceipt()` |
| Constants | SCREAMING_SNAKE_CASE | SCREAMING_SNAKE_CASE | `MAX_IMAGE_SIZE` |
| Database Tables | - | snake_case | `receipt_history` |
| Test Files | snake_case_test.dart | snake_case_test.dart | `ocr_service_test.dart` |

## Code Organization

```poml
CODE_ORGANIZATION:
  architectural_layers:
    presentation: "UI components, screens, widgets"
    business: "Use cases, business logic, state management"
    data: "Repositories, data sources, models"
    infrastructure: "External services, device APIs, storage"
  
  feature_organization:
    pattern: "Feature folders with internal layering"
    structure: "features/{feature_name}/{presentation,business,data}"
    shared: "Common components in shared/ directory"
    
IMPORT_ORGANIZATION:
  order:
    1: "Dart/Flutter framework imports"
    2: "Third-party package imports" 
    3: "Internal app imports"
    4: "Relative imports"
  
  grouping: "Separate groups with blank lines"
  sorting: "Alphabetical within each group"
```

```dart
// Import organization example
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../../../core/models/receipt.dart';
import '../../../shared/utils/image_utils.dart';

import 'camera_state.dart';
```

## Documentation Standards

```poml
DOCUMENTATION_STANDARDS:
  dart_docs: "Use /// for public API documentation"
  inline_comments: "Explain WHY, not WHAT"
  complex_logic: "Document algorithms and business rules"
  public_apis: "All public methods and classes documented"
  
DOCUMENTATION_PATTERNS:
  class_documentation:
    - "Purpose and responsibility"
    - "Key dependencies"
    - "Usage examples for complex APIs"
    - "Performance considerations"
  
  method_documentation:
    - "Brief description of purpose"
    - "Parameter descriptions"
    - "Return value description"
    - "Throws documentation"
    - "Usage examples for complex methods"
```

```dart
/// Processes receipt images using OCR engines with fallback strategy.
/// 
/// This service handles the complete OCR workflow including image preprocessing,
/// text extraction, field parsing, and confidence scoring. It automatically
/// falls back to TensorFlow Lite if Google ML Kit fails.
/// 
/// Performance: Targets <5s processing time for typical receipts.
/// Memory: Uses up to 25MB additional memory during processing.
/// 
/// Example:
/// ```dart
/// final result = await ocrService.processReceipt(
///   imageData,
///   engine: OCREngine.auto,
/// );
/// ```
class OCRService implements IOCRService {
  /// Processes a receipt image and extracts the four core fields.
  /// 
  /// [imageData] The receipt image as compressed bytes
  /// [engine] OCR engine preference (auto, ml_kit, tensorflow_lite)
  /// 
  /// Returns [ProcessingResult] with field data and confidence scores.
  /// 
  /// Throws [OCRServiceException] if all OCR engines fail.
  /// Throws [ImageProcessingException] if image preprocessing fails.
  @override
  Future<ProcessingResult> processReceipt(
    Uint8List imageData, {
    OCREngine engine = OCREngine.auto,
  }) async {
    // Implementation details...
  }
}
```

## Testing Standards

```poml
TESTING_STANDARDS:
  coverage_target: "90%+ code coverage"
  test_types: ["unit", "widget", "integration"]
  naming: "Descriptive test names that explain expected behavior"
  structure: "Given-When-Then pattern where applicable"
  
TEST_ORGANIZATION:
  unit_tests: "test/unit/{feature}/{class}_test.dart"
  widget_tests: "test/widget/{feature}/{widget}_test.dart"
  integration_tests: "test/integration/{flow}_test.dart"
  
MOCK_STRATEGY:
  approach: "Mock external dependencies, not internal logic"
  tool: "mockito for generated mocks"
  verification: "Verify interactions for side effects"
```

```dart
// Test example following standards
group('OCRService', () {
  late OCRService ocrService;
  late MockMLKitTextRecognizer mockMLKit;
  late MockImageProcessor mockImageProcessor;

  setUp(() {
    mockMLKit = MockMLKitTextRecognizer();
    mockImageProcessor = MockImageProcessor();
    ocrService = OCRService(
      mlKitRecognizer: mockMLKit,
      imageProcessor: mockImageProcessor,
    );
  });

  group('processReceipt', () {
    test('should extract fields with high confidence when ML Kit succeeds', () async {
      // Given
      final testImage = Uint8List.fromList([1, 2, 3]);
      final expectedText = 'Costco\n2024-01-15\nTotal: \$45.67\nTax: \$3.42';
      
      when(mockImageProcessor.preprocess(any))
          .thenAnswer((_) async => testImage);
      when(mockMLKit.processImage(any))
          .thenAnswer((_) async => RecognizedText([
            TextBlock(text: expectedText, rect: Rect.zero, lines: [])
          ]));

      // When
      final result = await ocrService.processReceipt(testImage);

      // Then
      expect(result.merchant.value, equals('Costco'));
      expect(result.merchant.confidence, greaterThan(80));
      expect(result.total.value, equals(45.67));
      expect(result.processingEngine, equals('ml_kit'));
    });
  });
});
```

## Performance Standards

```poml
PERFORMANCE_STANDARDS:
  mobile_first: "All performance targets optimized for mobile devices"
  memory_conscious: "Minimize memory allocation in hot paths"
  battery_efficient: "Avoid unnecessary background processing"
  
PERFORMANCE_TARGETS:
  app_startup:
    cold_start: "< 3s to first interactive"
    warm_start: "< 1s to restored state"
    memory_usage: "< 50MB baseline"
  
  ocr_processing:
    simple_receipt: "< 3s processing time"
    complex_receipt: "< 5s processing time"
    memory_spike: "< 25MB additional during processing"
    accuracy_target: ">= 89% field extraction"
  
  ui_responsiveness:
    frame_rate: ">= 60 FPS during normal usage"
    input_latency: "< 16ms touch response"
    scroll_performance: "Smooth scrolling in receipt lists"
  
OPTIMIZATION_TECHNIQUES:
  widget_optimization:
    - "Use const constructors where possible"
    - "Implement RepaintBoundary for expensive widgets" 
    - "Avoid rebuilds with proper Riverpod selectors"
    - "Use ListView.builder for dynamic lists"
  
  memory_optimization:
    - "Dispose controllers, streams, subscriptions"
    - "Use weak references for callbacks"
    - "Compress images before storage/display"
    - "Cache thumbnails with LRU eviction"
  
  computation_optimization:
    - "Offload heavy work to isolates when possible"
    - "Use compute() for CPU-intensive operations"
    - "Implement lazy loading patterns"
    - "Cache expensive computation results"
```

## Security Standards

```poml
SECURITY_STANDARDS:
  data_protection: "Protect user receipt data and PII"
  local_security: "Secure on-device storage and processing"
  input_validation: "Validate all user inputs and file operations"
  
SECURITY_REQUIREMENTS:
  input_validation:
    - "Sanitize all text inputs before processing"
    - "Validate file paths before file operations"
    - "Check image file headers for validity"
    - "Limit file sizes and types accepted"
  
  data_storage:
    - "Store sensitive data in secure device storage"
    - "Use SQLCipher for database encryption (optional)"
    - "Never log sensitive information"
    - "Implement secure file deletion"
  
  error_handling:
    - "Never expose internal system details in errors"
    - "Log security events appropriately" 
    - "Implement rate limiting for expensive operations"
    - "Graceful degradation on security failures"
```

```dart
// Security validation example
class SecurityManager {
  static const List<String> _allowedImageTypes = ['jpg', 'jpeg', 'png'];
  static const int _maxImageSize = 10 * 1024 * 1024; // 10MB
  
  /// Validates that a file path is safe for file operations
  static bool isValidPath(String path) {
    // Check for directory traversal
    if (path.contains('..') || path.contains('~')) {
      return false;
    }
    
    // Ensure path is within app directory
    final appDir = getApplicationDocumentsDirectory();
    return path.startsWith(appDir.path);
  }
  
  /// Validates image file before processing
  static Future<bool> isValidImage(Uint8List imageData) async {
    // Check file size
    if (imageData.length > _maxImageSize) {
      return false;
    }
    
    // Check file header for valid image format
    return _validateImageHeader(imageData);
  }
}
```