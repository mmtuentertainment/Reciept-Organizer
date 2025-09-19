import 'dart:convert';

import 'package:receipt_organizer/core/repositories/interfaces/i_receipt_repository.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:drift/drift.dart';
import '../../database/app_database.dart';

/// Receipt repository implementation using Drift database
/// Works on ALL platforms: Mobile (SQLite) and Web (IndexedDB)
class ReceiptRepository implements IReceiptRepository {
  late final AppDatabase _database;

  // Singleton pattern
  static ReceiptRepository? _instance;

  factory ReceiptRepository() {
    _instance ??= ReceiptRepository._internal();
    return _instance!;
  }

  ReceiptRepository._internal() {
    _database = AppDatabase();
  }

  /// Constructor for testing with custom database
  ReceiptRepository.withDatabase(AppDatabase database) {
    _database = database;
  }

  @override
  Future<List<Receipt>> getAllReceipts() async {
    final entities = await _database.getAllReceipts();
    return entities.map(_entityToModel).toList();
  }

  @override
  Future<Receipt?> getReceiptById(String id) async {
    final entity = await _database.getReceiptById(id);
    return entity != null ? _entityToModel(entity) : null;
  }

  @override
  Future<List<Receipt>> getReceiptsByBatchId(String batchId) async {
    final entities = await _database.getReceiptsByBatchId(batchId);
    return entities.map(_entityToModel).toList();
  }

  @override
  Future<List<Receipt>> getReceiptsByDateRange(DateTime start, DateTime end) async {
    final entities = await _database.getReceiptsByDateRange(start, end);
    return entities.map(_entityToModel).toList();
  }

  @override
  Future<Receipt> createReceipt(Receipt receipt) async {
    final companion = _modelToCompanion(receipt);
    await _database.createReceipt(companion);
    return receipt;
  }

  @override
  Future<void> updateReceipt(Receipt receipt) async {
    final companion = _modelToCompanion(receipt);
    await _database.updateReceipt(companion, receipt.id);
  }

  @override
  Future<void> deleteReceipt(String id) async {
    await _database.deleteReceipt(id);
  }

  @override
  Future<void> deleteReceipts(List<String> ids) async {
    await _database.deleteReceipts(ids);
  }

  @override
  Future<int> getReceiptCount() async {
    return _database.getReceiptCount();
  }

  @override
  Future<List<Receipt>> getReceiptsPaginated(int offset, int limit) async {
    final entities = await _database.getReceiptsPaginated(offset, limit);
    return entities.map(_entityToModel).toList();
  }

  @override
  Future<List<Receipt>> searchReceipts(String query) async {
    final entities = await _database.searchReceipts(query);
    return entities.map(_entityToModel).toList();
  }

  /// Additional methods for enhanced functionality

  Future<List<Receipt>> getReceiptsByStatus(ReceiptStatus status) async {
    final entities = await _database.getReceiptsByStatus(status.name);
    return entities.map(_entityToModel).toList();
  }

  /// Clear all data (useful for testing)
  Future<void> clearAllData() async {
    return _database.clearAllData();
  }

  /// Get database statistics
  Future<Map<String, dynamic>> getStats() async {
    return _database.getStats();
  }

  /// Convert database entity to model
  Receipt _entityToModel(ReceiptEntity entity) {
    // Parse tags from JSON array
    List<String>? tags;
    if (entity.tags != null) {
      try {
        tags = List<String>.from(jsonDecode(entity.tags!));
      } catch (e) {
        print('Failed to parse tags: $e');
      }
    }

    // Parse metadata
    Map<String, dynamic>? metadata;
    if (entity.metadata != null) {
      try {
        metadata = jsonDecode(entity.metadata!) as Map<String, dynamic>;
      } catch (e) {
        print('Failed to parse metadata: $e');
      }
    }

    return Receipt(
      id: entity.id,
      userId: entity.userId,
      imageUri: entity.imageUri,
      thumbnailUri: entity.thumbnailUri,
      capturedAt: entity.capturedAt,
      status: ReceiptStatus.values.firstWhere(
        (e) => e.name == entity.status,
        orElse: () => ReceiptStatus.captured,
      ),
      batchId: entity.batchId,
      lastModified: entity.lastModified,
      notes: entity.notes,
      vendorName: entity.vendorName,
      receiptDate: entity.receiptDate,
      totalAmount: entity.totalAmount,
      taxAmount: entity.taxAmount,
      tipAmount: entity.tipAmount,
      currency: entity.currency,
      categoryId: entity.categoryId,
      subcategory: entity.subcategory,
      paymentMethod: entity.paymentMethod,
      ocrConfidence: entity.ocrConfidence,
      ocrRawText: entity.ocrRawText,
      isProcessed: entity.isProcessed,
      needsReview: entity.needsReview,
      imageUrl: entity.imageUrl,
      businessPurpose: entity.businessPurpose,
      tags: tags,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncStatus: entity.syncStatus,
      lastSyncAt: entity.lastSyncAt,
      metadata: metadata,
    );
  }

  /// Convert model to database companion
  ReceiptsCompanion _modelToCompanion(Receipt receipt) {
    // Convert tags to JSON array
    String? tagsJson;
    if (receipt.tags != null && receipt.tags!.isNotEmpty) {
      tagsJson = jsonEncode(receipt.tags);
    }

    // Convert metadata to JSON
    String? metadataJson;
    if (receipt.metadata != null) {
      metadataJson = jsonEncode(receipt.metadata);
    }

    return ReceiptsCompanion(
      id: Value(receipt.id),
      userId: Value(receipt.userId),
      imageUri: Value(receipt.imageUri),
      thumbnailUri: Value(receipt.thumbnailUri),
      capturedAt: Value(receipt.capturedAt),
      status: Value(receipt.status.name),
      batchId: Value(receipt.batchId),
      lastModified: Value(receipt.lastModified),
      notes: Value(receipt.notes),
      vendorName: Value(receipt.vendorName),
      receiptDate: Value(receipt.receiptDate),
      totalAmount: Value(receipt.totalAmount),
      taxAmount: Value(receipt.taxAmount),
      tipAmount: Value(receipt.tipAmount),
      currency: Value(receipt.currency ?? 'USD'),
      categoryId: Value(receipt.categoryId),
      subcategory: Value(receipt.subcategory),
      paymentMethod: Value(receipt.paymentMethod),
      ocrConfidence: Value(receipt.ocrConfidence),
      ocrRawText: Value(receipt.ocrRawText),
      ocrResultsJson: Value.absent(),
      isProcessed: Value(receipt.isProcessed ?? false),
      needsReview: Value(receipt.needsReview ?? false),
      imageUrl: Value(receipt.imageUrl ?? receipt.imageUri),
      businessPurpose: Value(receipt.businessPurpose),
      tags: Value(tagsJson),
      createdAt: Value(receipt.createdAt ?? DateTime.now()),
      updatedAt: Value(receipt.updatedAt ?? DateTime.now()),
      syncStatus: Value(receipt.syncStatus),
      lastSyncAt: Value(receipt.lastSyncAt),
      metadata: Value(metadataJson),
    );
  }
}