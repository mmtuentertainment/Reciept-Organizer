import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:receipt_organizer/core/services/supabase_service.dart';
import 'package:receipt_organizer/features/receipts/providers/receipts_provider.dart';
import 'package:receipt_organizer/features/categories/providers/category_provider.dart';
import 'package:receipt_organizer/features/settings/providers/settings_provider.dart';
import 'package:receipt_organizer/features/capture/providers/provider_initializer.dart';
import 'package:receipt_organizer/features/export/presentation/providers/export_provider.dart';
import 'package:receipt_organizer/core/providers/repository_providers.dart';
import 'package:receipt_organizer/core/providers/service_providers.dart';
import 'package:receipt_organizer/data/repositories/receipt_repository.dart';
import 'package:receipt_organizer/data/repositories/settings_repository.dart';
import 'package:receipt_organizer/data/models/receipt.dart' as data_models;
import 'package:receipt_organizer/core/models/receipt.dart' as core_models;
import 'package:receipt_organizer/data/models/category.dart';
import 'package:receipt_organizer/domain/services/interfaces/i_sync_service.dart';
import 'package:receipt_organizer/core/repositories/interfaces/i_receipt_repository.dart';

/// Simple mock Supabase client that does nothing
class MockSupabaseClient extends Mock implements SupabaseClient {}

/// Mock Receipt Repository
class MockReceiptRepository extends Mock implements IReceiptRepository {
  final List<data_models.Receipt> _receipts = [];

  @override
  Future<List<data_models.Receipt>> getAllReceipts() async => _receipts;

  @override
  Future<data_models.Receipt?> getReceiptById(String id) async {
    try {
      return _receipts.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<data_models.Receipt> createReceipt(data_models.Receipt receipt) async {
    _receipts.add(receipt);
    return receipt;
  }

  @override
  Future<void> updateReceipt(data_models.Receipt receipt) async {
    final index = _receipts.indexWhere((r) => r.id == receipt.id);
    if (index != -1) _receipts[index] = receipt;
  }

  @override
  Future<void> deleteReceipt(String id) async {
    _receipts.removeWhere((r) => r.id == id);
  }

  @override
  Future<void> clearAllData() async {
    _receipts.clear();
  }

  @override
  Future<List<data_models.Receipt>> searchReceipts(String query) async {
    if (query.isEmpty) return _receipts;
    return _receipts.where((r) =>
      (r.vendorName?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
      (r.notes?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }
}

/// Mock Settings Repository
class MockSettingsRepository extends Mock implements SettingsRepository {}

/// Default test categories
final defaultTestCategories = [
  Category(
    id: '1',
    userId: 'test-user-123',
    name: 'Food & Dining',
    icon: '🍔',
    color: '#FF5722',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '2',
    userId: 'test-user-123',
    name: 'Transportation',
    icon: '🚗',
    color: '#2196F3',
    createdAt: DateTime.now(),
  ),
  Category(
    id: '3',
    userId: 'test-user-123',
    name: 'Shopping',
    icon: '🛍️',
    color: '#9C27B0',
    createdAt: DateTime.now(),
  ),
];

/// Comprehensive mock provider overrides for testing
final mockSupabaseOverrides = [
  // Mock Supabase client - prevents any real network calls
  supabaseClientProvider.overrideWithValue(null), // Return null to disable Supabase

  // Mock receipts provider - returns empty list
  receiptsProvider.overrideWith((ref) async => <core_models.Receipt>[]),

  // Mock categories providers
  userCategoriesProvider.overrideWith((ref) async => defaultTestCategories),
  categorySearchProvider.overrideWith((ref, query) async {
    if (query.isEmpty) return defaultTestCategories;
    return defaultTestCategories
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }),
  categoryByIdProvider.overrideWith((ref, id) async {
    try {
      return defaultTestCategories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }),

  // Mock repository providers
  receiptRepositoryProvider.overrideWith((ref) async => MockReceiptRepository()),
  settingsRepositoryProvider.overrideWith((ref) async => MockSettingsRepository()),
  exportReceiptRepositoryProvider.overrideWith((ref) async => MockReceiptRepository()),

  // Mock initialization providers
  appInitializationProvider.overrideWith((ref) async {}),

  // Mock sync status provider
  syncStatusProvider.overrideWith((ref) => Stream.value(SyncStatus.idle)),
];