# Tech Stack

```poml
DOCUMENT_METADATA:
  type: "technology_specification"
  purpose: "Comprehensive technology stack for Receipt Organizer MVP"
  scope: "Complete frontend, backend, and tooling stack"
  decision_framework: "Evidence-based technology selection"
  last_updated: "2025-01-06"
  
TECH_STACK_PHILOSOPHY:
  approach: "Boring technology where possible, exciting where necessary"
  constraints: ["offline_first", "mobile_native", "single_language_preference"]
  optimization_targets: ["development_speed", "user_experience", "maintenance_burden"]
  team_context: "Small team, full-stack development"
```

## Technology Decision Matrix

```poml
TECHNOLOGY_SELECTION_CRITERIA:
  primary_factors:
    - "Offline-first capability"
    - "Mobile performance optimization"
    - "Flutter ecosystem maturity"
    - "Team productivity impact"
    - "Long-term maintainability"
  
  evaluation_framework:
    must_have: "Core requirements that cannot be compromised"
    should_have: "Important features that provide significant value"
    nice_to_have: "Features that would be beneficial but not critical"
    
DECISION_RATIONALE:
  single_language_strategy:
    choice: "Dart everywhere (frontend + backend services)"
    benefit: "No context switching, consistent tooling, shared types"
    tradeoff: "Limited to Flutter/Dart ecosystem"
    
  offline_first_architecture:
    choice: "All processing on-device"
    benefit: "Zero network dependency, instant responsiveness"
    tradeoff: "Higher device resource usage, limited cloud features"
    
  flutter_over_alternatives:
    choice: "Flutter vs React Native vs Native"
    benefit: "Superior camera integration, consistent cross-platform UI"
    tradeoff: "Dart learning curve, smaller talent pool"
```

## Core Technology Stack

```poml
TECHNOLOGY_MATRIX:
  frontend_layer:
    language: 
      name: "Dart"
      version: "3.2+"
      rationale: "Native Flutter language, strong typing, excellent mobile performance"
      
    framework:
      name: "Flutter"
      version: "3.24.0+"
      rationale: "Superior camera integration, consistent UI across platforms, proven OCR plugin support"
      
    ui_system:
      name: "Material 3 + Custom Components"
      version: "Latest"
      rationale: "Material for platform conventions, custom components for receipt-specific UI"
      
    state_management:
      name: "Riverpod"
      version: "2.4+"
      rationale: "More modern than BLoC, better DevTools, compile-safe, easier testing"
  
  backend_layer:
    language:
      name: "Dart"
      version: "3.2+"
      rationale: "Same language as frontend, no context switching for small team"
      
    architecture:
      name: "On-device Services"
      version: "N/A"
      rationale: "No backend server in MVP, all processing on-device"
      
    api_style:
      name: "Local Service Interfaces"
      version: "N/A"
      rationale: "Direct service calls, no network API in MVP"
  
  data_layer:
    database:
      name: "SQLite via sqflite"
      version: "2.3+"
      rationale: "Proven mobile database, works offline, good Flutter support"
      
    reactive_layer:
      name: "RxDB"
      version: "0.5+"
      rationale: "Reactive updates for UI, offline-first design"
      
    storage:
      name: "Device File System"
      version: "N/A"
      rationale: "Direct device storage with path_provider package"
      
    authentication:
      name: "Local Only"
      version: "N/A"
      rationale: "Single-device usage, no user accounts in MVP"
```

### Complete Technology Matrix

| Category | Technology | Version | Purpose | Rationale |
|----------|------------|---------|---------|-----------|
| Frontend Language | Dart | 3.2+ | Mobile app development language | Native Flutter language, strong typing, excellent mobile performance |
| Frontend Framework | Flutter | 3.24.0+ | Cross-platform mobile UI framework | Superior camera integration, consistent UI across platforms, proven OCR plugin support |
| UI Component Library | Material 3 + Custom | Latest | Design system implementation | Material for platform conventions, custom components for receipt-specific UI |
| State Management | Riverpod | 2.4+ | Reactive state management | More modern than BLoC, better DevTools, compile-safe, easier testing |
| Backend Language | Dart | 3.2+ | Service layer implementation | Same language as frontend, no context switching for small team |
| Backend Framework | N/A (On-device) | - | Local processing only | No backend server in MVP, all processing on-device |
| API Style | Local Services | - | Internal service interfaces | Direct service calls, no network API in MVP |
| Database | SQLite via sqflite | 2.3+ | Local data persistence | Proven mobile database, works offline, good Flutter support |
| Cache | In-Memory + RxDB | rxdb 0.5+ | Reactive caching layer | Reactive updates for UI, offline-first design |
| File Storage | Device File System | - | Image storage | Direct device storage with path_provider package |
| Authentication | Local Only | - | No auth in MVP | Single-device usage, no user accounts in MVP |

## Specialized Processing Stack

```poml
PROCESSING_TECHNOLOGIES:
  ocr_stack:
    primary_engine:
      name: "Google ML Kit"
      version: "1.0+"
      purpose: "Text recognition"
      rationale: "Best on-device accuracy, 89-92% on receipts"
      
    fallback_engine:
      name: "TensorFlow Lite"
      version: "2.14+"
      purpose: "Backup OCR"
      rationale: "Fallback when ML Kit unavailable"
      
    preprocessing:
      name: "OpenCV for Flutter"
      version: "Latest"
      purpose: "Image preprocessing, edge detection"
      rationale: "Industry standard computer vision library"
  
  camera_integration:
    camera_plugin:
      name: "camera"
      version: "0.10+"
      purpose: "Camera integration"
      rationale: "Official Flutter camera package"
      
    image_processing:
      name: "image"
      version: "4.0+"
      purpose: "Image manipulation"
      rationale: "Compression, rotation, preprocessing"
      
    edge_detection:
      name: "Custom OpenCV Integration"
      version: "N/A"
      purpose: "Receipt boundary detection"
      rationale: "Receipt-specific edge detection algorithms"
  
  export_system:
    csv_generation:
      name: "csv"
      version: "5.0+"
      purpose: "Export functionality"
      rationale: "Simple, reliable CSV generation"
      
    validation:
      name: "Custom Validators"
      version: "N/A"
      purpose: "QuickBooks/Xero format compliance"
      rationale: "Ensure accounting software compatibility"
```

## Development and Testing Stack

```poml
DEVELOPMENT_STACK:
  testing_framework:
    unit_testing:
      name: "Flutter Test"
      version: "SDK"
      purpose: "Widget and unit testing"
      rationale: "Built-in Flutter testing framework"
      
    integration_testing:
      name: "Integration Test"
      version: "SDK"  
      purpose: "Full flow testing"
      rationale: "Flutter's official integration testing package"
      
    mocking:
      name: "Mockito"
      version: "5.4+"
      purpose: "Mock generation for testing"
      rationale: "Code generation for type-safe mocks"
  
  build_and_deployment:
    build_tool:
      name: "Flutter SDK"
      version: "3.24.0+"
      purpose: "Build and compilation"
      rationale: "Official Flutter toolchain"
      
    bundler:
      name: "Flutter Build"
      version: "SDK"
      purpose: "App bundling"
      rationale: "Built into Flutter for iOS/Android"
      
    ci_cd:
      name: "GitHub Actions"
      version: "Latest"
      purpose: "Automated builds and tests"
      rationale: "Free for public repos, good Flutter support"
  
  monitoring_and_debugging:
    crash_reporting:
      name: "Sentry"
      version: "7.0+"
      purpose: "Crash reporting only"
      rationale: "Minimal monitoring for MVP, privacy-compliant"
      
    logging:
      name: "Logger package"
      version: "2.0+"
      purpose: "Local debug logging"
      rationale: "Simple local logging, no cloud transmission"
      
    performance:
      name: "Flutter DevTools"
      version: "SDK"
      purpose: "Performance profiling"
      rationale: "Built-in performance analysis tools"
```

## Critical Dependencies

```poml
CRITICAL_FLUTTER_PACKAGES:
  essential_packages:
    - name: "camera"
      version: "0.10+"
      criticality: "essential"
      purpose: "Receipt capture"
      fallback: "Manual image upload"
      
    - name: "google_ml_kit"
      version: "1.0+"
      criticality: "essential" 
      purpose: "OCR processing"
      fallback: "TensorFlow Lite engine"
      
    - name: "sqflite"
      version: "2.3+"
      criticality: "essential"
      purpose: "Data persistence"
      fallback: "File-based storage"
      
    - name: "riverpod"
      version: "2.4+"
      criticality: "essential"
      purpose: "State management"
      fallback: "Built-in setState patterns"
      
    - name: "path_provider"
      version: "2.0+"
      criticality: "essential"
      purpose: "File system access"
      fallback: "Hard-coded paths (not recommended)"
  
  important_packages:
    - name: "go_router"
      version: "13.0+"
      criticality: "important"
      purpose: "Navigation"
      fallback: "Navigator 1.0"
      
    - name: "image"
      version: "4.0+"
      criticality: "important"
      purpose: "Image processing"
      fallback: "Basic Flutter image handling"
      
    - name: "csv"
      version: "5.0+"
      criticality: "important"
      purpose: "Export generation"
      fallback: "Manual CSV string building"
      
    - name: "share_plus"
      version: "7.0+"
      criticality: "important"
      purpose: "File sharing"
      fallback: "Save to device only"
```

## Platform-Specific Considerations

```poml
PLATFORM_REQUIREMENTS:
  ios_specific:
    minimum_version: "iOS 13.0"
    required_permissions: ["Camera", "Photo Library"]
    signing: "Development team provisioning profile"
    distribution: "App Store Connect"
    considerations: ["Privacy info.plist entries", "Camera usage descriptions"]
    
  android_specific:
    minimum_api: "API 21 (Android 5.0)"
    target_api: "API 34 (Android 14)"
    required_permissions: ["Camera", "Storage"]
    distribution: "Google Play Store"
    considerations: ["Runtime permissions", "Scoped storage compliance"]
    
  flutter_version_requirements:
    minimum_flutter: "3.24.0"
    minimum_dart: "3.2.0"
    channel: "Stable"
    reasoning: "Latest stable features, bug fixes, performance improvements"
```

## Technology Upgrade Path

```poml
UPGRADE_STRATEGY:
  current_mvp_stack: "Optimized for rapid development and deployment"
  post_mvp_considerations:
    - "Cloud sync capabilities (Firebase/Supabase)"
    - "Advanced ML models for better OCR accuracy"
    - "Web admin interface (Flutter Web)"
    - "API layer for multi-device sync"
    - "Advanced analytics and monitoring"
    
  technical_debt_management:
    approach: "Incremental improvements with each release"
    monitoring: "Track performance metrics and user feedback"
    refactoring: "Planned refactoring cycles"
    dependencies: "Regular dependency updates and security patches"
    
ARCHITECTURAL_FLEXIBILITY:
  current_decisions_allow_for:
    - "Adding cloud backend without major refactoring"
    - "Implementing web version using same Flutter codebase"
    - "Scaling to multiple OCR engines"
    - "Adding new export formats without core changes"
    
  potential_future_migrations:
    - "Repository pattern enables database switching"
    - "Service interfaces allow backend implementation changes"
    - "Riverpod state management scales to complex app states"
    - "Modular architecture supports feature additions"
```