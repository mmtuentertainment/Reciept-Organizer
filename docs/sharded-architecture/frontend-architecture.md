# Frontend Architecture

```poml
SECTION_METADATA:
  type: "frontend_specification"
  section_number: 10
  focus: "Flutter application structure and patterns"
  state_management: "Riverpod with reactive streams"
  
FRONTEND_ARCHITECTURE:
  framework: "Flutter 3.24+"
  language: "Dart 3.2+"
  state_management: "Riverpod 2.4+"
  navigation: "go_router"
  design_system: "Material 3 with custom receipt-specific components"
  testing: "Widget tests + Integration tests"
```

## 10.1 Component Architecture

```poml
COMPONENT_ORGANIZATION:
  architectural_pattern: "Feature-based organization with shared components"
  separation_of_concerns: "Presentation, Business Logic, Data layers"
  reusability: "Shared widgets and utilities across features"
  
DIRECTORY_STRUCTURE:
  core: "Business logic, models, services, repositories"
  features: "Feature-specific providers, widgets, screens"
  shared: "Reusable components, theme, utilities"
  main: "App entry point and configuration"
```

#### Component Organization
```
lib/
├── core/                           # Business logic layer
│   ├── models/                     # Data models
│   ├── services/                   # Service interfaces
│   └── repositories/               # Data repositories
│
├── features/                       # Feature modules
│   ├── capture/
│   │   ├── providers/             # Riverpod providers
│   │   ├── widgets/               # Feature widgets
│   │   └── screens/               # Feature screens
│   ├── receipts/
│   └── export/
│
├── shared/                        # Shared components
│   ├── widgets/                   # Reusable widgets
│   ├── theme/                     # App theming
│   └── utils/                     # Utilities
│
└── main.dart                      # App entry point
```

```poml
FEATURE_MODULES:
  capture_feature:
    responsibility: "Camera capture, edge detection, image processing"
    screens: ["CaptureScreen", "PreviewScreen", "EditScreen"]
    widgets: ["CameraPreview", "EdgeDetectionOverlay", "ConfidenceIndicator"]
    providers: ["cameraStateProvider", "captureProvider", "ocrProvider"]
  
  receipts_feature:
    responsibility: "Receipt management, listing, editing"
    screens: ["ReceiptListScreen", "ReceiptDetailScreen"]
    widgets: ["ReceiptCard", "FieldEditor", "ConfidenceScore"]
    providers: ["receiptListProvider", "receiptDetailProvider"]
  
  export_feature:
    responsibility: "CSV export, validation, sharing"
    screens: ["ExportScreen", "PreviewScreen"]
    widgets: ["ExportSettings", "ValidationSummary", "CSVPreview"]
    providers: ["exportProvider", "validationProvider"]
```

## 10.2 State Management Architecture

```poml
STATE_MANAGEMENT_DESIGN:
  pattern: "Riverpod with AsyncNotifiers"
  benefits: ["Compile-time safety", "Better DevTools", "Easier testing"]
  reactive_updates: "Automatic UI rebuilds on state changes"
  error_handling: "Built-in error states and recovery"
  
PROVIDER_HIERARCHY:
  global_providers: ["settingsProvider", "storageProvider"]
  feature_providers: ["receiptListProvider", "captureProvider", "exportProvider"]
  derived_providers: ["filteredReceiptsProvider", "exportStatsProvider"]
  
STATE_STRUCTURE:
  immutable_state: "All state objects immutable with copyWith patterns"
  error_states: "Explicit error handling in AsyncValue wrappers"
  loading_states: "Built-in loading indicators"
  optimistic_updates: "Immediate UI updates with rollback on failure"
```

#### State Structure
```dart
// Global app state structure using Riverpod
@riverpod
class ReceiptList extends _$ReceiptList {
  @override
  Future<List<Receipt>> build() async {
    final repository = ref.watch(receiptRepositoryProvider);
    return repository.getAllReceipts();
  }
  
  Future<void> addReceipt(Receipt receipt) async {
    final repository = ref.read(receiptRepositoryProvider);
    await repository.create(receipt);
    ref.invalidateSelf(); // Trigger rebuild
  }
  
  Future<void> updateReceipt(String id, Map<String, dynamic> updates) async {
    final repository = ref.read(receiptRepositoryProvider);
    await repository.update(id, updates);
    ref.invalidateSelf();
  }
}
```

```poml
RIVERPOD_PATTERNS:
  asyncnotifier_pattern:
    purpose: "Handle async operations with proper loading/error states"
    example: "ReceiptList, ExportBatch, OCRProcessing"
  
  provider_pattern:
    purpose: "Simple value providers for configuration"
    example: "settingsProvider, themeProvider"
  
  futureprovider_pattern:
    purpose: "One-time async operations"
    example: "deviceInfoProvider, permissionsProvider"
  
  streamprovider_pattern:
    purpose: "Reactive data streams"
    example: "receiptStreamProvider (RxDB integration)"
  
  statenotifier_pattern:
    purpose: "Complex state machines"
    example: "cameraStateProvider, exportStateProvider"
```

## 10.3 Routing Architecture

```poml
ROUTING_DESIGN:
  package: "go_router"
  pattern: "Declarative routing with type-safe navigation"
  deep_linking: "Support for app state restoration"
  guards: "Authentication and permission checks"
  
ROUTE_STRUCTURE:
  root_routes: ["/capture", "/receipts", "/export", "/settings"]
  nested_routes: ["capture/preview", "receipts/:id", "export/preview"]
  modal_routes: ["settings/about", "help", "error"]
  
NAVIGATION_FLOW:
  primary_flow: "capture -> preview -> edit -> receipts"
  export_flow: "receipts -> export -> preview -> share"
  settings_flow: "settings -> categories -> individual setting"
```

```dart
// App routing using go_router
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/capture',
    routes: [
      GoRoute(
        path: '/capture',
        name: 'capture',
        builder: (context, state) => const CaptureScreen(),
        routes: [
          GoRoute(
            path: 'preview',
            name: 'preview',
            builder: (context, state) => PreviewScreen(
              image: state.extra as Uint8List,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/receipts',
        name: 'receipts',
        builder: (context, state) => const ReceiptListScreen(),
      ),
      GoRoute(
        path: '/export',
        name: 'export',
        builder: (context, state) => const ExportScreen(),
      ),
    ],
  );
});
```

```poml
UI_ARCHITECTURE:
  design_system: "Material 3 with custom receipt-specific components"
  responsive_design: "Adaptive layouts for different screen sizes"
  accessibility: "Full accessibility support with semantic labels"
  theming: "Light/dark theme support with user preference"
  
CUSTOM_COMPONENTS:
  receipt_specific:
    - "ReceiptCard: Receipt list item with thumbnail and metadata"
    - "FieldEditor: OCR field editing with confidence display"
    - "ConfidenceIndicator: Visual confidence score representation"
    - "EdgeDetectionOverlay: Camera preview with detected edges"
    - "CSVPreview: Export preview with scrollable table"
  
  reusable_components:
    - "LoadingButton: Button with loading state"
    - "ErrorBoundary: Error handling wrapper"
    - "ConfirmDialog: Standardized confirmation dialogs"
    - "DateRangePicker: Custom date range selection"
    - "ProgressIndicator: Step-by-step progress tracking"

PERFORMANCE_CONSIDERATIONS:
  widget_optimization:
    - "Use const constructors where possible"
    - "Implement shouldRebuild for expensive widgets"
    - "Image caching for receipt thumbnails"
    - "ListView.builder for large receipt lists"
  
  memory_management:
    - "Dispose controllers and streams in dispose()"
    - "Use weak references for callbacks"
    - "Compress images for UI display"
    - "Lazy loading of receipt details"
  
  rendering_performance:
    - "Avoid unnecessary rebuilds with Riverpod selectors"
    - "Use RepaintBoundary for expensive widgets"
    - "Optimize animations with AnimatedBuilder"
    - "Implement custom painters for complex UI elements"
```