/// Test Module Definitions
/// 
/// Breaks the 571 tests into manageable modules that can be run independently
/// This prevents timeouts and makes debugging easier

class TestModule {
  final String name;
  final String description;
  final List<String> testPaths;
  final int estimatedTests;
  final Duration timeout;

  const TestModule({
    required this.name,
    required this.description,
    required this.testPaths,
    required this.estimatedTests,
    this.timeout = const Duration(minutes: 2),
  });
}

class TestModules {
  // Module 1: Core Models and Data (50 tests)
  static const coreModule = TestModule(
    name: 'core',
    description: 'Core models, data layers, and repositories',
    testPaths: [
      'test/unit/core/',
      'test/unit/data/',
      'test/contracts/',
    ],
    estimatedTests: 50,
  );

  // Module 2: Domain Services (60 tests)
  static const domainModule = TestModule(
    name: 'domain',
    description: 'Business logic and domain services',
    testPaths: [
      'test/unit/domain/',
      'test/services/',
    ],
    estimatedTests: 60,
  );

  // Module 3: Mock Infrastructure (10 tests)
  static const mocksModule = TestModule(
    name: 'mocks',
    description: 'Mock implementations and test infrastructure',
    testPaths: [
      'test/mocks/',
      'test/helpers/',
    ],
    estimatedTests: 10,
    timeout: Duration(seconds: 30),
  );

  // Module 4: Capture Feature (80 tests)
  static const captureModule = TestModule(
    name: 'capture',
    description: 'Photo capture, OCR, and batch processing',
    testPaths: [
      'test/widget/capture/',
      'test/unit/features/capture/',
      'test/unit/capture/',
    ],
    estimatedTests: 80,
  );

  // Module 5: Receipt Management (70 tests)
  static const receiptsModule = TestModule(
    name: 'receipts',
    description: 'Receipt list, details, and management',
    testPaths: [
      'test/widget/receipts/',
      'test/unit/features/receipts/',
    ],
    estimatedTests: 70,
  );

  // Module 6: Export Feature (60 tests)
  static const exportModule = TestModule(
    name: 'export',
    description: 'CSV export, date ranges, and validation',
    testPaths: [
      'test/widget/export/',
      'test/unit/features/export/',
      'test/unit/export/',
    ],
    estimatedTests: 60,
  );

  // Module 7: Settings (30 tests)
  static const settingsModule = TestModule(
    name: 'settings',
    description: 'App settings and preferences',
    testPaths: [
      'test/widget/settings/',
      'test/features/settings/',
      'test/unit/data/repositories/settings',
    ],
    estimatedTests: 30,
  );

  // Module 8: Integration Tests (100 tests)
  static const integrationModule = TestModule(
    name: 'integration',
    description: 'End-to-end feature workflows',
    testPaths: [
      'test/integration/',
    ],
    estimatedTests: 100,
    timeout: Duration(minutes: 5),
  );

  // Module 9: Performance Tests (20 tests)
  static const performanceModule = TestModule(
    name: 'performance',
    description: 'Performance and load testing',
    testPaths: [
      'test/performance/',
    ],
    estimatedTests: 20,
    timeout: Duration(minutes: 3),
  );

  // Module 10: Widget Components (91 tests)
  static const widgetsModule = TestModule(
    name: 'widgets',
    description: 'Shared UI components and widgets',
    testPaths: [
      'test/widgets/',
      'test/widget/shared/',
    ],
    estimatedTests: 91,
  );

  // All modules in execution order
  static const List<TestModule> allModules = [
    mocksModule,        // Run first - smallest and most fundamental
    coreModule,         // Core infrastructure
    domainModule,       // Business logic
    widgetsModule,      // UI components
    settingsModule,     // Settings feature
    captureModule,      // Capture feature
    receiptsModule,     // Receipt management
    exportModule,       // Export feature
    integrationModule,  // Integration tests
    performanceModule,  // Performance tests
  ];

  // Get total estimated tests
  static int get totalTests {
    return allModules.fold(0, (sum, module) => sum + module.estimatedTests);
  }

  // Find module by name
  static TestModule? findModule(String name) {
    try {
      return allModules.firstWhere((m) => m.name == name);
    } catch (_) {
      return null;
    }
  }

  // Get modules that are likely to pass
  static List<TestModule> get stableModules => [
    mocksModule,
    coreModule,
    settingsModule,
  ];

  // Get modules that need fixing
  static List<TestModule> get unstableModules => [
    captureModule,
    integrationModule,
    performanceModule,
  ];
}