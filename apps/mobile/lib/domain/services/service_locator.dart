import 'package:receipt_organizer/domain/interfaces/i_receipt_repository.dart';
import 'package:receipt_organizer/domain/interfaces/i_image_storage_service.dart';
import 'package:receipt_organizer/domain/interfaces/i_sync_service.dart';
import 'package:receipt_organizer/domain/interfaces/i_auth_service.dart';
import 'package:receipt_organizer/infrastructure/mocks/mock_receipt_repository.dart';
import 'package:receipt_organizer/infrastructure/mocks/mock_image_storage_service.dart';
import 'package:receipt_organizer/infrastructure/mocks/mock_sync_service.dart';
import 'package:receipt_organizer/infrastructure/mocks/mock_auth_service.dart';

/// Service locator for dependency injection and interface instantiation.
/// 
/// This class manages the creation and lifecycle of service implementations,
/// allowing easy switching between mock, local, and cloud implementations.
/// 
/// Usage:
/// ```dart
/// // Initialize at app startup
/// await ServiceLocator.initialize(
///   environment: Environment.production,
///   useMocks: false,
/// );
/// 
/// // Get service instances
/// final repository = ServiceLocator.instance.receiptRepository;
/// final storage = ServiceLocator.instance.imageStorage;
/// ```
class ServiceLocator {
  static ServiceLocator? _instance;
  
  /// Singleton instance of the service locator
  static ServiceLocator get instance {
    if (_instance == null) {
      throw StateError(
        'ServiceLocator not initialized. Call ServiceLocator.initialize() first.',
      );
    }
    return _instance!;
  }
  
  /// Optional singleton access that returns null if not initialized
  static ServiceLocator? get instanceOrNull => _instance;
  
  // Service instances
  late final IReceiptRepository _receiptRepository;
  late final IImageStorageService _imageStorage;
  late final ISyncService _syncService;
  late final IAuthService _authService;
  
  // Configuration
  final ServiceEnvironment environment;
  final bool useMocks;
  final ServiceConfig? config;
  
  ServiceLocator._({
    required this.environment,
    required this.useMocks,
    this.config,
  });
  
  /// Initialize the service locator with specified configuration.
  /// 
  /// [environment] The deployment environment (local, staging, production).
  /// [useMocks] Whether to use mock implementations (for testing).
  /// [config] Optional service configuration overrides.
  /// 
  /// This must be called once at app startup before using any services.
  static Future<void> initialize({
    required ServiceEnvironment environment,
    bool useMocks = false,
    ServiceConfig? config,
  }) async {
    if (_instance != null) {
      throw StateError('ServiceLocator already initialized');
    }
    
    _instance = ServiceLocator._(
      environment: environment,
      useMocks: useMocks,
      config: config,
    );
    
    await _instance!._initializeServices();
  }
  
  /// Reset the service locator (useful for testing).
  /// 
  /// WARNING: This will dispose all service instances.
  /// Only use in test environments.
  static Future<void> reset() async {
    if (_instance != null) {
      await _instance!._disposeServices();
      _instance = null;
    }
  }
  
  /// Initialize all service implementations based on configuration
  Future<void> _initializeServices() async {
    if (useMocks) {
      _initializeMockServices();
    } else {
      await _initializeRealServices();
    }
  }
  
  /// Initialize mock service implementations (for testing)
  void _initializeMockServices() {
    // Import statements would normally be at top of file
    // For now, using dynamic imports in the implementation
    _receiptRepository = MockReceiptRepository();
    _imageStorage = MockImageStorageService();
    _syncService = MockSyncService();
    _authService = MockAuthService();
  }
  
  /// Initialize real service implementations based on environment
  Future<void> _initializeRealServices() async {
    switch (environment) {
      case ServiceEnvironment.local:
        await _initializeLocalServices();
        break;
      case ServiceEnvironment.cloud:
        await _initializeCloudServices();
        break;
      case ServiceEnvironment.hybrid:
        await _initializeHybridServices();
        break;
    }
  }
  
  /// Initialize local-only service implementations (SQLite + file system)
  Future<void> _initializeLocalServices() async {
    // These implementations will be created/refactored in subsequent stories
    // For now, throw an error indicating they're not ready
    throw UnimplementedError(
      'Local service implementations pending refactoring to use new interfaces.',
    );
  }
  
  /// Initialize cloud-only service implementations (Supabase)
  Future<void> _initializeCloudServices() async {
    // These will be implemented in Track 2 (Cloud Infrastructure)
    throw UnimplementedError(
      'Cloud services not yet implemented. See Track 2 stories.',
    );
  }
  
  /// Initialize hybrid service implementations (local + cloud with sync)
  Future<void> _initializeHybridServices() async {
    // These will be implemented in Track 3 (Feature Implementation)
    throw UnimplementedError(
      'Hybrid services not yet implemented. See Track 3 stories.',
    );
  }
  
  /// Dispose all service instances
  Future<void> _disposeServices() async {
    // Add cleanup logic here when services have dispose methods
  }
  
  /// Get the receipt repository instance
  IReceiptRepository get receiptRepository => _receiptRepository;
  
  /// Get the image storage service instance
  IImageStorageService get imageStorage => _imageStorage;
  
  /// Get the sync service instance
  ISyncService get syncService => _syncService;
  
  /// Get the auth service instance
  IAuthService get authService => _authService;
  
  /// Check if services are initialized
  static bool get isInitialized => _instance != null;
  
  /// Get current environment
  static ServiceEnvironment? get currentEnvironment => _instance?.environment;
  
  /// Check if using mock services
  static bool get isUsingMocks => _instance?.useMocks ?? false;
}

/// Service deployment environment
enum ServiceEnvironment {
  /// Local-only with SQLite and file system
  local,
  
  /// Cloud-only with Supabase
  cloud,
  
  /// Hybrid with local storage and cloud sync
  hybrid,
}

/// Service configuration
class ServiceConfig {
  /// Base URL for API endpoints
  final String? apiBaseUrl;
  
  /// Supabase configuration
  final SupabaseConfig? supabase;
  
  /// Local storage configuration
  final LocalStorageConfig? localStorage;
  
  /// Sync configuration
  final SyncServiceConfig? sync;
  
  /// Auth configuration
  final AuthServiceConfig? auth;
  
  const ServiceConfig({
    this.apiBaseUrl,
    this.supabase,
    this.localStorage,
    this.sync,
    this.auth,
  });
}

/// Supabase configuration
class SupabaseConfig {
  final String url;
  final String anonKey;
  final String? serviceKey;
  
  const SupabaseConfig({
    required this.url,
    required this.anonKey,
    this.serviceKey,
  });
}

/// Local storage configuration
class LocalStorageConfig {
  final String? databasePath;
  final String? imagePath;
  final int? maxCacheSize;
  
  const LocalStorageConfig({
    this.databasePath,
    this.imagePath,
    this.maxCacheSize,
  });
}

/// Sync service configuration
class SyncServiceConfig {
  final Duration syncInterval;
  final bool autoSync;
  final int maxRetries;
  
  const SyncServiceConfig({
    this.syncInterval = const Duration(minutes: 5),
    this.autoSync = true,
    this.maxRetries = 3,
  });
}

/// Auth service configuration
class AuthServiceConfig {
  final bool enableAnonymous;
  final bool enableGoogle;
  final bool enableApple;
  final Duration tokenRefreshBuffer;
  
  const AuthServiceConfig({
    this.enableAnonymous = true,
    this.enableGoogle = true,
    this.enableApple = true,
    this.tokenRefreshBuffer = const Duration(minutes: 5),
  });
}

/// Factory for creating service instances with specific configurations
class ServiceFactory {
  /// Create a receipt repository with the specified implementation
  static IReceiptRepository createReceiptRepository(
    RepositoryImplementation implementation,
  ) {
    switch (implementation) {
      case RepositoryImplementation.mock:
        throw UnimplementedError('Mock repository in T1.2');
      case RepositoryImplementation.sqlite:
        throw UnimplementedError('SQLite repository refactoring pending');
      case RepositoryImplementation.supabase:
        throw UnimplementedError('Supabase repository in Track 2');
      case RepositoryImplementation.hybrid:
        throw UnimplementedError('Hybrid repository in Track 3');
    }
  }
  
  /// Create an image storage service with the specified implementation
  static IImageStorageService createImageStorage(
    StorageImplementation implementation,
  ) {
    switch (implementation) {
      case StorageImplementation.mock:
        throw UnimplementedError('Mock storage in T1.2');
      case StorageImplementation.fileSystem:
        throw UnimplementedError('File system storage refactoring pending');
      case StorageImplementation.supabase:
        throw UnimplementedError('Supabase storage in Track 2');
      case StorageImplementation.hybrid:
        throw UnimplementedError('Hybrid storage in Track 3');
    }
  }
  
  /// Create a sync service with the specified implementation
  static ISyncService createSyncService(
    SyncImplementation implementation,
  ) {
    switch (implementation) {
      case SyncImplementation.mock:
        throw UnimplementedError('Mock sync in T1.2');
      case SyncImplementation.disabled:
        throw UnimplementedError('Disabled sync for local-only mode');
      case SyncImplementation.supabase:
        throw UnimplementedError('Supabase realtime in Track 2');
      case SyncImplementation.custom:
        throw UnimplementedError('Custom sync in Track 3');
    }
  }
  
  /// Create an auth service with the specified implementation
  static IAuthService createAuthService(
    AuthImplementation implementation,
  ) {
    switch (implementation) {
      case AuthImplementation.mock:
        throw UnimplementedError('Mock auth in T1.2');
      case AuthImplementation.local:
        throw UnimplementedError('Local auth for single-user mode');
      case AuthImplementation.supabase:
        throw UnimplementedError('Supabase auth in Track 2');
      case AuthImplementation.custom:
        throw UnimplementedError('Custom auth in Track 3');
    }
  }
}

/// Repository implementation types
enum RepositoryImplementation {
  mock,
  sqlite,
  supabase,
  hybrid,
}

/// Storage implementation types
enum StorageImplementation {
  mock,
  fileSystem,
  supabase,
  hybrid,
}

/// Sync implementation types
enum SyncImplementation {
  mock,
  disabled,
  supabase,
  custom,
}

/// Auth implementation types
enum AuthImplementation {
  mock,
  local,
  supabase,
  custom,
}