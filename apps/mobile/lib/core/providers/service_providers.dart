import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/interfaces/i_sync_service.dart';
import '../../domain/services/interfaces/i_auth_service.dart';
import '../../infrastructure/services/mock_sync_service.dart';
import '../../infrastructure/services/mock_auth_service.dart';

// Export auth providers to avoid duplication
export '../../features/auth/providers/auth_provider.dart'
  show authStateProvider, currentUserProvider, isAuthenticatedProvider;

/// Environment configuration provider
final environmentProvider = Provider<AppEnvironment>((ref) {
  // In production, this would read from environment variables or build config
  const environment = String.fromEnvironment('APP_ENV', defaultValue: 'development');
  
  switch (environment) {
    case 'production':
      return AppEnvironment.production;
    case 'staging':
      return AppEnvironment.staging;
    default:
      return AppEnvironment.development;
  }
});

/// Sync service provider - switches between mock and real based on environment
final syncServiceProvider = Provider<ISyncService>((ref) {
  final environment = ref.watch(environmentProvider);
  
  switch (environment) {
    case AppEnvironment.production:
    case AppEnvironment.staging:
      // TODO: Return SupabaseSyncService when implemented
      // final supabase = ref.watch(supabaseClientProvider);
      // if (supabase != null) {
      //   return SupabaseSyncService(supabase);
      // }
      return MockSyncService(); // Fallback to mock for now
      
    case AppEnvironment.development:
      return MockSyncService();
  }
});

/// Auth service provider - switches between mock and real based on environment
final authServiceProvider = Provider<IAuthService>((ref) {
  final environment = ref.watch(environmentProvider);
  
  switch (environment) {
    case AppEnvironment.production:
    case AppEnvironment.staging:
      // TODO: Return SupabaseAuthService when implemented
      // final supabase = ref.watch(supabaseClientProvider);
      // if (supabase != null) {
      //   return SupabaseAuthService(supabase);
      // }
      return MockAuthService(); // Fallback to mock for now
      
    case AppEnvironment.development:
      return MockAuthService();
  }
});

/// Sync status provider - provides current sync status
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.syncStatusStream;
});

/// Environment configuration
enum AppEnvironment {
  development,
  staging,
  production,
}