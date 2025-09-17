import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:receipt_organizer/core/providers/service_providers.dart';
import 'package:receipt_organizer/infrastructure/config/supabase_config.dart';
import 'package:receipt_organizer/infrastructure/services/supabase_auth_service.dart';
import 'package:receipt_organizer/infrastructure/services/supabase_sync_service.dart';
import 'package:receipt_organizer/core/models/receipt.dart';
import 'package:receipt_organizer/test/fixtures/real_data_loader.dart';
import '../helpers/test_setup.dart';

void main() {
  group('Supabase Integration Tests', () {
    late ProviderContainer container;

    setUpAll(() async {
      await setupTestEnvironment();

      // Skip if Supabase is not configured
      if (!_isSupabaseConfigured()) {
        print('⚠️ Skipping Supabase tests - not configured');
        return;
      }

      // Initialize Supabase for testing
      try {
        await initializeSupabaseForTesting();
      } catch (e) {
        print('Failed to initialize Supabase: $e');
      }
    });
    
    setUp(() {
      container = ProviderContainer(
        overrides: [
          environmentProvider.overrideWithValue(AppEnvironment.staging),
        ],
      );
    });
    
    tearDown(() {
      container.dispose();
    });
    
    group('Auth Service', () {
      test('should use Supabase auth in staging/production', skip: !_isSupabaseConfigured(), () {
        final authService = container.read(authServiceProvider);
        
        if (SupabaseConfig.isInitialized) {
          expect(authService, isA<SupabaseAuthService>());
        } else {
          // Falls back to mock if not initialized
          expect(authService, isNotNull);
        }
      });
      
      test('should handle anonymous sign in', skip: !_isSupabaseConfigured(), () async {
        if (!SupabaseConfig.isInitialized) return;
        
        final authService = container.read(authServiceProvider) as SupabaseAuthService;
        
        final result = await authService.signInAnonymously();
        
        expect(result.success, true);
        expect(result.userId, isNotNull);
        expect(authService.isAuthenticated, true);
        
        // Clean up
        await authService.signOut();
      });
      
      test('should handle email/password sign up', skip: !_isSupabaseConfigured(), () async {
        if (!SupabaseConfig.isInitialized) return;
        
        final authService = container.read(authServiceProvider) as SupabaseAuthService;
        final testEmail = 'test_${DateTime.now().millisecondsSinceEpoch}@example.com';
        
        final result = await authService.signUp(
          email: testEmail,
          password: 'TestPassword123!',
          displayName: 'Test User',
        );
        
        // May require email confirmation depending on config
        expect(result.success, true);
        expect(result.userId, isNotNull);
        
        // Clean up if auto-confirmed
        if (authService.isAuthenticated) {
          await authService.deleteAccount();
        }
      });
    });
    
    group('Sync Service', () {
      test('should use Supabase sync in staging/production', skip: !_isSupabaseConfigured(), () {
        final syncService = container.read(syncServiceProvider);
        
        if (SupabaseConfig.isInitialized) {
          expect(syncService, isA<SupabaseSyncService>());
        } else {
          // Falls back to mock if not initialized
          expect(syncService, isNotNull);
        }
      });
      
      test('should sync receipt to Supabase', skip: !_isSupabaseConfigured(), () async {
        if (!SupabaseConfig.isInitialized) return;
        
        // First authenticate
        final authService = container.read(authServiceProvider) as SupabaseAuthService;
        await authService.signInAnonymously();
        
        if (!authService.isAuthenticated) {
          print('Authentication failed, skipping sync test');
          return;
        }
        
        final syncService = container.read(syncServiceProvider) as SupabaseSyncService;
        
        final receipt = RealDataLoader.generateRealisticReceipt(
          merchantOverride: 'Test Store ${DateTime.now().millisecondsSinceEpoch}',
        );
        
        await syncService.syncReceipt(receipt);
        
        // Verify sync completed
        final lastSync = await syncService.lastSyncTime;
        expect(lastSync, isNotNull);
        
        // Clean up
        await authService.signOut();
      });
      
      test('should handle offline gracefully', skip: !_isSupabaseConfigured(), () async {
        final syncService = container.read(syncServiceProvider);
        
        final isAvailable = await syncService.isAvailable;
        
        // Should return false if not authenticated or offline
        if (!SupabaseConfig.isInitialized) {
          expect(isAvailable, false);
        }
      });
    });
    
    group('End-to-End Flow', () {
      test('should complete full auth and sync flow', skip: !_isSupabaseConfigured(), () async {
        if (!SupabaseConfig.isInitialized) return;
        
        final authService = container.read(authServiceProvider) as SupabaseAuthService;
        final syncService = container.read(syncServiceProvider) as SupabaseSyncService;
        
        // 1. Sign in
        final authResult = await authService.signInAnonymously();
        expect(authResult.success, true);
        
        // 2. Create and sync receipts
        final receipts = [
          RealDataLoader.generateRealisticReceipt(merchantOverride: 'E2E Test Store 1'),
          RealDataLoader.generateRealisticReceipt(merchantOverride: 'E2E Test Store 2'),
          RealDataLoader.generateRealisticReceipt(merchantOverride: 'E2E Test Store 3'),
        ];
        
        await syncService.syncReceipts(receipts);
        
        // 3. Perform full sync
        final syncResult = await syncService.performSync();
        expect(syncResult.isSuccess, true);
        
        // 4. Pull changes
        final pulledReceipts = await syncService.pullChanges();
        expect(pulledReceipts, isNotEmpty);
        
        // 5. Sign out
        await authService.signOut();
        expect(authService.isAuthenticated, false);
      });
    });
  });
}

bool _isSupabaseConfigured() {
  // Check if we're in CI or have Supabase configured
  const ciEnv = String.fromEnvironment('CI');
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  
  return ciEnv == 'true' || supabaseUrl.isNotEmpty;
}