import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/core/providers/service_providers.dart';
import 'package:receipt_organizer/domain/services/interfaces/i_auth_service.dart';
import 'package:receipt_organizer/domain/services/interfaces/i_sync_service.dart';
import 'package:receipt_organizer/infrastructure/services/mock_auth_service.dart';
import 'package:receipt_organizer/infrastructure/services/mock_sync_service.dart';
import 'package:receipt_organizer/core/models/receipt.dart';
import 'package:receipt_organizer/test/fixtures/real_data_loader.dart';

void main() {
  group('Service Infrastructure Tests', () {
    late ProviderContainer container;
    
    setUp(() {
      container = ProviderContainer();
    });
    
    tearDown(() {
      container.dispose();
    });
    
    group('Auth Service', () {
      test('should provide mock auth service in development', () {
        final authService = container.read(authServiceProvider);
        
        expect(authService, isA<IAuthService>());
        expect(authService, isA<MockAuthService>());
      });
      
      test('should handle sign up flow', () async {
        final authService = container.read(authServiceProvider);
        
        final result = await authService.signUp(
          email: 'newuser@test.com',
          password: 'password123',
        );
        
        expect(result.success, true);
        expect(result.userId, isNotNull);
        expect(result.email, 'newuser@test.com');
        expect(authService.isAuthenticated, true);
      });
      
      test('should handle sign in flow', () async {
        final authService = container.read(authServiceProvider);
        
        // First sign up
        await authService.signUp(
          email: 'testuser@example.com',
          password: 'testpass123',
        );
        
        // Sign out
        await authService.signOut();
        expect(authService.isAuthenticated, false);
        
        // Sign in again
        final result = await authService.signInWithPassword(
          email: 'testuser@example.com',
          password: 'testpass123',
        );
        
        expect(result.success, true);
        expect(authService.isAuthenticated, true);
      });
      
      test('should handle anonymous sign in', () async {
        final authService = container.read(authServiceProvider);
        
        final result = await authService.signInAnonymously();
        
        expect(result.success, true);
        expect(result.userId, isNotNull);
        expect(result.email, isNull);
        expect(authService.isAuthenticated, true);
      });
      
      test('should provide auth state stream', () async {
        final authService = container.read(authServiceProvider);
        
        // Listen to auth state changes
        final states = <AuthState>[];
        authService.authStateStream.listen(states.add);
        
        // Trigger state changes
        await authService.signInAnonymously();
        await Future.delayed(const Duration(milliseconds: 100));
        await authService.signOut();
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(states, contains(AuthState.loading));
        expect(states, contains(AuthState.authenticated));
        expect(states, contains(AuthState.unauthenticated));
      });
    });
    
    group('Sync Service', () {
      test('should provide mock sync service in development', () {
        final syncService = container.read(syncServiceProvider);
        
        expect(syncService, isA<ISyncService>());
        expect(syncService, isA<MockSyncService>());
      });
      
      test('should sync single receipt', () async {
        final syncService = container.read(syncServiceProvider);
        
        final receipt = RealDataLoader.generateRealisticReceipt(
          merchantOverride: 'Walmart',
        );
        
        await syncService.syncReceipt(receipt);
        
        final hasPending = await syncService.hasPendingChanges;
        expect(hasPending, true); // Local changes exist
        
        final lastSync = await syncService.lastSyncTime;
        expect(lastSync, isNotNull);
      });
      
      test('should sync multiple receipts', () async {
        final syncService = container.read(syncServiceProvider);
        
        final receipts = [
          RealDataLoader.generateRealisticReceipt(merchantOverride: 'Target'),
          RealDataLoader.generateRealisticReceipt(merchantOverride: 'Costco'),
          RealDataLoader.generateRealisticReceipt(merchantOverride: 'Home Depot'),
        ];
        
        await syncService.syncReceipts(receipts);
        
        final hasPending = await syncService.hasPendingChanges;
        expect(hasPending, true);
      });
      
      test('should perform full sync', () async {
        final syncService = container.read(syncServiceProvider) as MockSyncService;
        
        // Add some remote receipts
        syncService.addRemoteReceipt(
          RealDataLoader.generateRealisticReceipt(merchantOverride: 'CVS Pharmacy'),
        );
        syncService.addRemoteReceipt(
          RealDataLoader.generateRealisticReceipt(merchantOverride: 'Walgreens'),
        );
        
        // Add local receipts
        await syncService.syncReceipt(
          RealDataLoader.generateRealisticReceipt(merchantOverride: 'Starbucks'),
        );
        
        // Perform sync
        final result = await syncService.performSync();
        
        expect(result.isSuccess, true);
        expect(result.itemsPushed, greaterThan(0));
        expect(result.itemsPulled, greaterThan(0));
        expect(result.errors, isEmpty);
      });
      
      test('should provide sync status stream', () async {
        final syncService = container.read(syncServiceProvider);
        
        // Listen to sync status changes
        final statuses = <SyncStatus>[];
        syncService.syncStatusStream.listen(statuses.add);
        
        // Trigger sync
        await syncService.syncReceipt(
          RealDataLoader.generateRealisticReceipt(merchantOverride: 'Amazon.com'),
        );
        await Future.delayed(const Duration(milliseconds: 200));
        
        expect(statuses, contains(SyncStatus.syncing));
        expect(statuses, contains(SyncStatus.idle));
      });
    });
    
    group('Provider Integration', () {
      test('should provide current user info when authenticated', () async {
        final authService = container.read(authServiceProvider);
        
        // Initially no user
        var currentUser = container.read(currentUserProvider);
        expect(currentUser, isNull);
        
        // Sign in
        await authService.signInWithPassword(
          email: 'test@example.com',
          password: 'password123',
        );
        
        // Refresh container to get updated provider
        container.invalidate(currentUserProvider);
        currentUser = container.read(currentUserProvider);
        
        expect(currentUser, isNotNull);
        expect(currentUser!.email, 'test@example.com');
        expect(currentUser.id, isNotEmpty);
      });
      
      test('should handle environment switching', () {
        final environment = container.read(environmentProvider);
        
        // Default is development
        expect(environment, AppEnvironment.development);
        
        // Services should be mock in development
        final authService = container.read(authServiceProvider);
        final syncService = container.read(syncServiceProvider);
        
        expect(authService, isA<MockAuthService>());
        expect(syncService, isA<MockSyncService>());
      });
    });
  });
}