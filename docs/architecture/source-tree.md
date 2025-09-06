# Source Tree

```poml
DOCUMENT_METADATA:
  type: "project_structure_specification"
  purpose: "Complete project organization and file structure"
  scope: "Flutter monorepo with feature-based organization"
  architectural_pattern: "Clean Architecture with feature modules"
  last_updated: "2025-01-06"
  
PROJECT_STRUCTURE_PHILOSOPHY:
  organization_principle: "Feature-based with clear architectural layers"
  scalability: "Easy to navigate and extend as project grows"
  separation_of_concerns: "Business logic, UI, and data clearly separated"
  team_productivity: "Intuitive structure for developers"
```

## Project Root Structure

```poml
ROOT_LEVEL_ORGANIZATION:
  approach: "Monorepo with clear package boundaries"
  tool: "Flutter workspace with shared packages"
  configuration: "Root-level configuration for entire project"
  
TOP_LEVEL_DIRECTORIES:
  apps: "Application entry points (mobile app)"
  packages: "Shared packages and libraries"
  tools: "Build scripts, utilities, validators"
  docs: "Documentation and architecture"
  infrastructure: "CI/CD, deployment scripts"
  config: "Project-wide configuration"
```

```
receipt-organizer/
├── .github/                           # CI/CD workflows and GitHub config
│   └── workflows/
│       ├── ci.yaml                   # Continuous integration
│       ├── release.yaml              # App store releases
│       └── test.yaml                 # Automated testing
│
├── apps/                              # Application packages
│   └── mobile/                        # Flutter mobile app
│       ├── android/                   # Android-specific code and config
│       ├── ios/                       # iOS-specific code and config
│       ├── lib/                       # Flutter application code
│       ├── test/                      # Test files
│       ├── assets/                    # Static assets (images, fonts)
│       ├── pubspec.yaml              # Flutter dependencies
│       └── README.md
│
├── packages/                          # Shared packages (future expansion)
│   ├── shared/                        # Shared utilities and models
│   └── ui_kit/                       # Reusable UI components (future)
│
├── tools/                             # Development tools and scripts
│   ├── csv_validators/               # CSV format validation tools
│   ├── build_scripts/                # Build automation scripts
│   └── test_data/                    # Test fixtures and mock data
│
├── infrastructure/                    # Development infrastructure
│   └── scripts/
│       ├── build_android.sh
│       ├── build_ios.sh
│       └── run_tests.sh
│
├── docs/                              # Documentation
│   ├── prd/                          # Product requirements (sharded)
│   ├── architecture/                 # Architecture documentation (sharded)
│   ├── stories/                      # User stories and epics
│   ├── qa/                           # QA documentation and test plans
│   └── guides/                       # Developer guides
│
├── .bmad-core/                       # BMAD development framework
│   ├── core-config.yaml             # Project configuration
│   ├── tasks/                        # Automated tasks
│   ├── templates/                    # Document templates
│   ├── checklists/                   # Quality checklists
│   └── data/                         # Project data and preferences
│
├── .env.example                       # Environment template
├── .gitignore                         # Git ignore rules
├── analysis_options.yaml              # Dart analysis rules
├── CLAUDE.md                          # AI development instructions
└── README.md                          # Project documentation
```

## Mobile App Structure (apps/mobile/lib/)

```poml
MOBILE_APP_ARCHITECTURE:
  pattern: "Clean Architecture with Feature Modules"
  layers: ["presentation", "application", "domain", "infrastructure"]
  organization: "Feature-first with shared components"
  
ARCHITECTURAL_LAYERS:
  presentation: "UI components, screens, state management"
  application: "Use cases, application services, DTOs"
  domain: "Business entities, domain services, interfaces" 
  infrastructure: "External services, repositories, data sources"
  
FEATURE_MODULE_STRUCTURE:
  approach: "Vertical slice architecture"
  benefits: ["Clear feature boundaries", "Easy to test", "Scalable"]
  pattern: "Each feature contains its own layers"
```

```
lib/
├── main.dart                          # App entry point and configuration
├── app/                               # App-level configuration
│   ├── app.dart                      # Main app widget
│   ├── router.dart                   # App routing configuration
│   ├── theme.dart                    # App theme and styling
│   └── config.dart                   # App configuration
│
├── core/                              # Core business logic and shared code
│   ├── models/                        # Domain models and entities
│   │   ├── receipt.dart              # Receipt entity
│   │   ├── processing_result.dart    # OCR processing result
│   │   ├── export_batch.dart         # CSV export batch
│   │   └── field_data.dart           # OCR field data with confidence
│   │
│   ├── services/                      # Core business services
│   │   ├── interfaces/               # Service contracts
│   │   │   ├── i_camera_service.dart
│   │   │   ├── i_ocr_service.dart
│   │   │   ├── i_storage_service.dart
│   │   │   └── i_export_service.dart
│   │   │
│   │   ├── camera_service.dart       # Camera operations
│   │   ├── ocr_service.dart         # OCR processing
│   │   ├── storage_service.dart     # Data persistence
│   │   ├── export_service.dart      # CSV export
│   │   └── image_service.dart       # Image processing
│   │
│   ├── repositories/                  # Data access repositories
│   │   ├── interfaces/
│   │   │   ├── i_receipt_repository.dart
│   │   │   └── i_settings_repository.dart
│   │   │
│   │   ├── receipt_repository.dart   # Receipt data access
│   │   ├── settings_repository.dart  # App settings
│   │   └── database_manager.dart     # Database configuration
│   │
│   ├── exceptions/                    # Custom exception types
│   │   ├── service_exception.dart    # Base service exception
│   │   ├── ocr_exception.dart       # OCR-specific exceptions
│   │   ├── camera_exception.dart    # Camera-specific exceptions
│   │   └── storage_exception.dart   # Storage-specific exceptions
│   │
│   └── utils/                         # Core utilities
│       ├── image_utils.dart          # Image processing utilities
│       ├── validation_utils.dart     # Data validation
│       ├── security_manager.dart     # Security utilities
│       └── performance_monitor.dart  # Performance tracking
│
├── features/                          # Feature modules
│   ├── capture/                      # Receipt capture feature
│   │   ├── presentation/
│   │   │   ├── providers/            # Riverpod providers
│   │   │   │   ├── camera_provider.dart
│   │   │   │   ├── capture_provider.dart
│   │   │   │   └── ocr_provider.dart
│   │   │   │
│   │   │   ├── screens/              # Feature screens
│   │   │   │   ├── capture_screen.dart
│   │   │   │   ├── preview_screen.dart
│   │   │   │   └── edit_screen.dart
│   │   │   │
│   │   │   └── widgets/              # Feature-specific widgets
│   │   │       ├── camera_preview.dart
│   │   │       ├── edge_detection_overlay.dart
│   │   │       ├── confidence_indicator.dart
│   │   │       └── field_editor.dart
│   │   │
│   │   ├── application/              # Use cases and application logic
│   │   │   ├── capture_receipt_use_case.dart
│   │   │   ├── process_ocr_use_case.dart
│   │   │   └── validate_fields_use_case.dart
│   │   │
│   │   └── domain/                   # Feature-specific domain logic
│   │       ├── capture_state.dart    # State models
│   │       └── capture_events.dart   # Event models
│   │
│   ├── receipts/                     # Receipt management feature
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   ├── receipt_list_provider.dart
│   │   │   │   └── receipt_detail_provider.dart
│   │   │   │
│   │   │   ├── screens/
│   │   │   │   ├── receipt_list_screen.dart
│   │   │   │   └── receipt_detail_screen.dart
│   │   │   │
│   │   │   └── widgets/
│   │   │       ├── receipt_card.dart
│   │   │       ├── receipt_thumbnail.dart
│   │   │       ├── confidence_badge.dart
│   │   │       └── field_display.dart
│   │   │
│   │   ├── application/
│   │   │   ├── get_receipts_use_case.dart
│   │   │   ├── update_receipt_use_case.dart
│   │   │   └── delete_receipt_use_case.dart
│   │   │
│   │   └── domain/
│   │       └── receipt_filters.dart   # Filter and search logic
│   │
│   └── export/                       # CSV export feature
│       ├── presentation/
│       │   ├── providers/
│       │   │   ├── export_provider.dart
│       │   │   └── validation_provider.dart
│       │   │
│       │   ├── screens/
│       │   │   ├── export_screen.dart
│       │   │   └── export_preview_screen.dart
│       │   │
│       │   └── widgets/
│       │       ├── export_settings.dart
│       │       ├── validation_summary.dart
│       │       ├── csv_preview.dart
│       │       └── date_range_picker.dart
│       │
│       ├── application/
│       │   ├── generate_csv_use_case.dart
│       │   ├── validate_export_use_case.dart
│       │   └── share_export_use_case.dart
│       │
│       └── domain/
│           ├── export_settings.dart   # Export configuration
│           ├── csv_templates.dart     # CSV format templates
│           └── validation_rules.dart  # Export validation rules
│
├── shared/                            # Shared components across features
│   ├── widgets/                       # Reusable UI components
│   │   ├── loading_button.dart       # Button with loading state
│   │   ├── error_boundary.dart       # Error handling wrapper
│   │   ├── confirm_dialog.dart       # Standardized dialogs
│   │   ├── progress_indicator.dart   # Step-by-step progress
│   │   └── empty_state.dart          # Empty state placeholders
│   │
│   ├── theme/                         # App theming and styles
│   │   ├── app_theme.dart           # Theme configuration
│   │   ├── colors.dart              # Color palette
│   │   ├── typography.dart          # Text styles
│   │   └── spacing.dart             # Layout spacing
│   │
│   ├── extensions/                    # Dart extensions
│   │   ├── date_extensions.dart      # Date utility extensions
│   │   ├── string_extensions.dart    # String utility extensions
│   │   └── context_extensions.dart   # BuildContext extensions
│   │
│   └── constants/                     # App-wide constants
│       ├── app_constants.dart       # General app constants
│       ├── image_constants.dart     # Image processing constants
│       └── export_constants.dart    # Export format constants
│
└── infrastructure/                    # External service implementations
    ├── database/                      # Database implementation
    │   ├── database_config.dart      # SQLite configuration
    │   ├── migrations/               # Database migrations
    │   │   ├── migration_v1.dart
    │   │   └── migration_v2.dart
    │   │
    │   └── tables/                   # Table definitions
    │       ├── receipts_table.dart
    │       ├── export_batches_table.dart
    │       └── app_settings_table.dart
    │
    ├── storage/                       # File system implementation
    │   ├── local_storage.dart        # Local file operations
    │   ├── image_storage.dart        # Image file management
    │   └── cache_manager.dart        # Cache implementation
    │
    ├── ocr/                          # OCR engine implementations
    │   ├── ml_kit_ocr.dart          # Google ML Kit implementation
    │   ├── tensorflow_ocr.dart      # TensorFlow Lite implementation
    │   └── ocr_factory.dart         # OCR engine factory
    │
    └── platform/                     # Platform-specific implementations
        ├── camera_platform.dart     # Camera platform interface
        ├── permissions.dart          # Permission handling
        └── device_info.dart          # Device information
```

## Test Structure

```poml
TEST_ORGANIZATION:
  approach: "Mirror source structure in test directory"
  types: ["unit", "widget", "integration"]
  coverage_target: "90%+ code coverage"
  
TEST_STRUCTURE_PATTERN:
  unit_tests: "test/unit/{feature}/{class}_test.dart"
  widget_tests: "test/widget/{feature}/{widget}_test.dart"
  integration_tests: "test/integration/{flow}_test.dart"
  test_utilities: "test/helpers/ and test/mocks/"
```

```
test/
├── unit/                              # Unit tests
│   ├── core/
│   │   ├── models/
│   │   │   ├── receipt_test.dart
│   │   │   └── processing_result_test.dart
│   │   │
│   │   ├── services/
│   │   │   ├── ocr_service_test.dart
│   │   │   ├── storage_service_test.dart
│   │   │   └── export_service_test.dart
│   │   │
│   │   └── repositories/
│   │       ├── receipt_repository_test.dart
│   │       └── settings_repository_test.dart
│   │
│   └── features/
│       ├── capture/
│       │   ├── capture_use_case_test.dart
│       │   └── ocr_provider_test.dart
│       │
│       └── export/
│           ├── csv_generation_test.dart
│           └── validation_test.dart
│
├── widget/                            # Widget tests
│   ├── features/
│   │   ├── capture/
│   │   │   ├── capture_screen_test.dart
│   │   │   ├── camera_preview_test.dart
│   │   │   └── confidence_indicator_test.dart
│   │   │
│   │   ├── receipts/
│   │   │   ├── receipt_card_test.dart
│   │   │   └── receipt_list_test.dart
│   │   │
│   │   └── export/
│   │       ├── export_screen_test.dart
│   │       └── csv_preview_test.dart
│   │
│   └── shared/
│       ├── loading_button_test.dart
│       ├── confirm_dialog_test.dart
│       └── error_boundary_test.dart
│
├── integration/                       # Integration tests
│   ├── capture_flow_test.dart        # End-to-end capture flow
│   ├── export_flow_test.dart         # End-to-end export flow
│   ├── receipt_management_test.dart   # Receipt CRUD operations
│   └── settings_test.dart            # Settings management
│
├── helpers/                           # Test utilities
│   ├── test_helpers.dart             # Common test utilities
│   ├── widget_tester_extensions.dart # Flutter test extensions
│   └── test_data_factory.dart        # Test data creation
│
└── mocks/                            # Mock implementations
    ├── mock_services.dart            # Service mocks
    ├── mock_repositories.dart        # Repository mocks
    └── mock_ocr_engines.dart         # OCR engine mocks
```

## File Naming Conventions

```poml
FILE_NAMING_STANDARDS:
  general_principle: "Descriptive, consistent, discoverable"
  case_convention: "snake_case for files, PascalCase for classes"
  suffix_patterns: "Consistent suffixes for different types"
  
NAMING_PATTERNS:
  screens: "{feature_name}_screen.dart"
  widgets: "{widget_purpose}.dart or {widget_name}_widget.dart"
  providers: "{feature_name}_provider.dart"
  services: "{service_name}_service.dart"
  repositories: "{entity_name}_repository.dart"
  models: "{entity_name}.dart"
  exceptions: "{category}_exception.dart"
  tests: "{original_file_name}_test.dart"
  use_cases: "{action_description}_use_case.dart"
  
ORGANIZATION_BENEFITS:
  developer_productivity: "Easy to find and understand file purpose"
  code_navigation: "IDE navigation and search optimization"
  maintenance: "Clear responsibility boundaries"
  testing: "Predictable test file locations"
  scalability: "Structure supports team growth"
```

## Configuration Files

```poml
CONFIGURATION_MANAGEMENT:
  approach: "Environment-specific configuration with sensible defaults"
  security: "No secrets in version control"
  validation: "Type-safe configuration objects"
  
CONFIGURATION_LOCATIONS:
  app_level: "apps/mobile/lib/app/config.dart"
  environment: "apps/mobile/.env.* files"
  build: "pubspec.yaml and platform-specific configs"
  analysis: "analysis_options.yaml"
  testing: "test configuration in each test file"
```

| File Type | Location | Purpose | Example |
|-----------|----------|---------|---------|
| App Configuration | `lib/app/config.dart` | Runtime app configuration | `AppConfig.ocrTimeout` |
| Environment Variables | `.env.local`, `.env.production` | Environment-specific settings | `OCR_CONFIDENCE_THRESHOLD=75` |
| Flutter Dependencies | `pubspec.yaml` | Package dependencies | `riverpod: ^2.4.0` |
| Dart Analysis | `analysis_options.yaml` | Code analysis rules | `prefer_const_constructors: error` |
| Database Schema | `infrastructure/database/` | Database table definitions | `receipts_table.dart` |
| CI/CD Configuration | `.github/workflows/` | Build and deployment | `ci.yaml`, `release.yaml` |
| Git Configuration | `.gitignore` | Version control exclusions | `*.env`, `build/` |