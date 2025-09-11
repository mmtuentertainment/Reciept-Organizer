# Tech Stack

```poml
DOCUMENT_METADATA:
  type: "technology_specification"
  purpose: "Comprehensive technology stack for Receipt Organizer MVP"
  scope: "Complete frontend, backend, and tooling stack"
  decision_framework: "Evidence-based technology selection"
  last_updated: "2025-01-10"
  revision: "2.0 - Updated to reflect implemented architecture"
  
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
  hybrid_language_strategy:
    original_plan: "Dart everywhere (frontend + backend services)"
    implemented_approach: "Flutter frontend + Next.js API backend"
    rationale_for_change: |
      - OAuth 2.0 flows require robust server-side handling
      - Next.js/Vercel provides superior OAuth integration
      - JavaScript ecosystem offers mature accounting API SDKs
      - Vercel Edge Functions ideal for stateless API endpoints
    benefit: "Best tool for each layer - Flutter for mobile, Next.js for web APIs"
    tradeoff: "Two language ecosystems to maintain"
    
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
    local_processing:
      name: "On-device Services (Dart)"
      version: "Within Flutter App"
      purpose: "OCR, image processing, local data management"
      rationale: "Core offline functionality remains on-device"
      
    api_gateway:
      name: "Next.js API"
      version: "15.5.2"
      runtime: "Node.js with Vercel Edge"
      purpose: "OAuth flows, CSV validation, accounting integrations"
      rationale: "Superior OAuth handling, mature ecosystem for web APIs"
      
    api_style:
      name: "RESTful + Local Services Hybrid"
      pattern: "Local-first with cloud enhancement"
      rationale: "Core features work offline, cloud features enhance experience"
  
  data_layer:
    database:
      name: "SQLite via sqflite"
      version: "2.3+"
      rationale: "Proven mobile database, works offline, good Flutter support"
      
    reactive_layer:
      name: "Riverpod State Management"
      version: "2.4+"
      rationale: "Reactive updates for UI, replaces planned RxDB with simpler solution"
      
    settings_persistence:
      name: "Hive"
      version: "2.2+"
      rationale: "Lightweight key-value storage for app settings and preferences"
      
    storage:
      name: "Device File System"
      version: "N/A"
      rationale: "Direct device storage with path_provider package"
      
    authentication:
      name: "OAuth 2.0 for Integrations"
      implementation: "Jose (JWT) on Next.js"
      version: "6.1.0"
      rationale: "QuickBooks/Xero OAuth integration, secure token management"
```

### Complete Technology Matrix

| Category | Technology | Version | Purpose | Rationale |
|----------|------------|---------|---------|-----------|
| Frontend Language | Dart | 3.2+ | Mobile app development language | Native Flutter language, strong typing, excellent mobile performance |
| Frontend Framework | Flutter | 3.24.0+ | Cross-platform mobile UI framework | Superior camera integration, consistent UI across platforms, proven OCR plugin support |
| UI Component Library | Material 3 + Custom | Latest | Design system implementation | Material for platform conventions, custom components for receipt-specific UI |
| State Management | Riverpod | 2.4+ | Reactive state management | More modern than BLoC, better DevTools, compile-safe, easier testing |
| Backend (Local) | Dart Services | 3.2+ | On-device processing | OCR, image processing within Flutter app |
| Backend (API) | Next.js | 15.5.2 | Cloud integrations | OAuth flows, CSV validation, accounting APIs |
| API Runtime | Vercel Edge | Latest | Serverless functions | Scalable, stateless API endpoints |
| API Style | REST + Local Hybrid | - | Dual architecture | Local services for offline, REST for integrations |
| Database | SQLite via sqflite | 2.3+ | Local data persistence | Proven mobile database, works offline, good Flutter support |
| Settings Store | Hive | 2.2+ | Key-value storage | Lightweight settings and preferences storage |
| State Management | Riverpod | 2.4+ | Reactive state layer | Replaces RxDB, simpler reactive updates |
| File Storage | Device File System | - | Image storage | Direct device storage with path_provider package |
| Authentication | OAuth 2.0 (Jose) | 6.1.0 | Integration auth | QuickBooks/Xero OAuth, JWT token management |
| Rate Limiting | Upstash Redis | 1.35.3 | API protection | Prevent abuse of cloud endpoints |

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