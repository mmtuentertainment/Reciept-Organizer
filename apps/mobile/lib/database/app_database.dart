import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import '../data/models/receipt.dart' as models;

part 'app_database.g.dart';

/// Complete receipts table with all 26 fields from data model
@DataClassName('ReceiptEntity')
class Receipts extends Table {
  // Primary key
  TextColumn get id => text()();

  // User association
  TextColumn get userId => text().nullable()();

  // Core image data
  TextColumn get imageUri => text()();
  TextColumn get thumbnailUri => text().nullable()();
  TextColumn get imageUrl => text().nullable()();

  // Timestamps
  DateTimeColumn get capturedAt => dateTime()();
  DateTimeColumn get lastModified => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // Status and processing
  TextColumn get status => text()();
  BoolColumn get isProcessed => boolean().withDefault(const Constant(false))();
  BoolColumn get needsReview => boolean().withDefault(const Constant(false))();

  // Batch processing
  TextColumn get batchId => text().nullable()();

  // Receipt core data
  TextColumn get vendorName => text().nullable()();
  DateTimeColumn get receiptDate => dateTime().nullable()();

  // Financial amounts
  RealColumn get totalAmount => real().nullable()();
  RealColumn get taxAmount => real().nullable()();
  RealColumn get tipAmount => real().nullable()();
  TextColumn get currency => text().withDefault(const Constant('USD'))();

  // Categorization
  TextColumn get categoryId => text().nullable()();
  TextColumn get subcategory => text().nullable()();
  TextColumn get paymentMethod => text().nullable()();

  // OCR data
  RealColumn get ocrConfidence => real().nullable()();
  TextColumn get ocrRawText => text().nullable()();
  TextColumn get ocrResultsJson => text().nullable()();

  // Business data
  TextColumn get businessPurpose => text().nullable()();
  TextColumn get notes => text().nullable()();

  // Tags stored as JSON array string
  TextColumn get tags => text().nullable()();

  // Sync tracking
  TextColumn get syncStatus => text().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // Metadata JSON for extensibility
  TextColumn get metadata => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Queue entries table for offline request persistence
@DataClassName('QueueEntryEntity')
class QueueEntries extends Table {
  // Primary key
  TextColumn get id => text()();

  // Request details
  TextColumn get endpoint => text()();
  TextColumn get method => text()();
  TextColumn get headers => text().withDefault(const Constant('{}'))();
  TextColumn get body => text().nullable()();

  // Timestamps
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();

  // Retry configuration
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  IntColumn get maxRetries => integer().withDefault(const Constant(3))();

  // Status tracking
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get errorMessage => text().nullable()();

  // Feature tracking
  TextColumn get feature => text().nullable()();
  TextColumn get userId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Main database class that works on ALL platforms
@DriftDatabase(tables: [Receipts, QueueEntries])
class AppDatabase extends _$AppDatabase {
  // Singleton pattern for database
  static AppDatabase? _instance;

  factory AppDatabase() {
    _instance ??= AppDatabase._internal();
    return _instance!;
  }

  AppDatabase._internal() : super(_openConnection());

  /// Constructor for testing with custom database
  @visibleForTesting
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 2;

  /// Opens connection for ALL platforms automatically
  static QueryExecutor _openConnection() {
    // drift_flutter handles ALL platforms!
    return driftDatabase(name: 'receipts_db');
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();

      // Create indexes for receipts table
      await customStatement('CREATE INDEX IF NOT EXISTS idx_receipt_date ON receipts(receipt_date)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_batch_id ON receipts(batch_id)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_status ON receipts(status)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_vendor_name ON receipts(vendor_name)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_captured_at ON receipts(captured_at)');

      // Create indexes for queue_entries table
      await customStatement('CREATE INDEX IF NOT EXISTS idx_queue_status ON queue_entries(status)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_queue_created ON queue_entries(created_at)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_queue_feature ON queue_entries(feature)');
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Add queue_entries table in version 2
        await m.createTable(queueEntries);

        // Create indexes for new table
        await customStatement('CREATE INDEX IF NOT EXISTS idx_queue_status ON queue_entries(status)');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_queue_created ON queue_entries(created_at)');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_queue_feature ON queue_entries(feature)');
      }
    },
  );

  // DAO Methods directly in database class

  Future<List<ReceiptEntity>> getAllReceipts() async {
    final query = select(receipts)..orderBy([(t) => OrderingTerm.desc(t.capturedAt)]);
    return query.get();
  }

  Future<ReceiptEntity?> getReceiptById(String id) async {
    final query = select(receipts)..where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<List<ReceiptEntity>> getReceiptsByBatchId(String batchId) async {
    final query = select(receipts)
      ..where((t) => t.batchId.equals(batchId))
      ..orderBy([(t) => OrderingTerm.desc(t.capturedAt)]);
    return query.get();
  }

  Future<List<ReceiptEntity>> getReceiptsByDateRange(DateTime start, DateTime end) async {
    final adjustedEnd = end.add(const Duration(days: 1));
    final query = select(receipts)
      ..where((t) => t.receiptDate.isBetweenValues(start, adjustedEnd))
      ..orderBy([(t) => OrderingTerm.desc(t.receiptDate)]);
    return query.get();
  }

  Future<int> createReceipt(Insertable<ReceiptEntity> companion) async {
    return into(receipts).insert(companion);
  }

  Future<bool> updateReceipt(Insertable<ReceiptEntity> companion, String id) async {
    final result = await (update(receipts)..where((t) => t.id.equals(id))).write(companion);
    return result > 0;
  }

  Future<int> deleteReceipt(String id) async {
    return (delete(receipts)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteReceipts(List<String> ids) async {
    if (ids.isEmpty) return;
    await batch((batch) {
      for (final id in ids) {
        batch.deleteWhere(receipts, (t) => t.id.equals(id));
      }
    });
  }

  Future<int> getReceiptCount() async {
    final countExp = receipts.id.count();
    final query = selectOnly(receipts)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  Future<List<ReceiptEntity>> getReceiptsPaginated(int offset, int limit) async {
    final query = select(receipts)
      ..orderBy([(t) => OrderingTerm.desc(t.capturedAt)])
      ..limit(limit, offset: offset);
    return query.get();
  }

  Future<List<ReceiptEntity>> searchReceipts(String searchQuery) async {
    if (searchQuery.isEmpty) return getAllReceipts();

    final pattern = '%$searchQuery%';
    final query = select(receipts)
      ..where((t) =>
        t.vendorName.like(pattern) |
        t.notes.like(pattern) |
        t.businessPurpose.like(pattern)
      )
      ..orderBy([(t) => OrderingTerm.desc(t.capturedAt)]);
    return query.get();
  }

  Future<List<ReceiptEntity>> getReceiptsByStatus(String status) async {
    final query = select(receipts)
      ..where((t) => t.status.equals(status))
      ..orderBy([(t) => OrderingTerm.desc(t.capturedAt)]);
    return query.get();
  }

  Future<void> clearAllData() async {
    await delete(receipts).go();
  }

  Future<Map<String, dynamic>> getStats() async {
    final totalReceipts = await getReceiptCount();
    return {
      'totalReceipts': totalReceipts,
      'schemaVersion': schemaVersion,
      'platform': kIsWeb ? 'web' : 'native',
    };
  }

  // Queue Entry DAO Methods

  Future<int> insertQueueEntry(Insertable<QueueEntryEntity> companion) async {
    return into(queueEntries).insert(companion);
  }

  Future<List<QueueEntryEntity>> getPendingQueueEntries() async {
    final query = select(queueEntries)
      ..where((t) => t.status.equals('pending') | t.status.equals('processing'))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.get();
  }

  Future<List<QueueEntryEntity>> getQueueEntriesByFeature(String feature) async {
    final query = select(queueEntries)
      ..where((t) => t.feature.equals(feature))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.get();
  }

  Future<bool> updateQueueEntry(Insertable<QueueEntryEntity> companion, String id) async {
    final result = await (update(queueEntries)..where((t) => t.id.equals(id))).write(companion);
    return result > 0;
  }

  Future<int> deleteQueueEntry(String id) async {
    return (delete(queueEntries)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteCompletedQueueEntries() async {
    return (delete(queueEntries)..where((t) => t.status.equals('completed'))).go();
  }

  Future<int> deleteOldCompletedQueueEntries({Duration olderThan = const Duration(days: 7)}) async {
    final cutoffDate = DateTime.now().subtract(olderThan);
    return (delete(queueEntries)
      ..where((t) => t.status.equals('completed') & t.createdAt.isSmallerOrEqualValue(cutoffDate)))
      .go();
  }

  Future<int> getQueueSize() async {
    final countExp = queueEntries.id.count();
    final query = selectOnly(queueEntries)
      ..addColumns([countExp])
      ..where(queueEntries.status.isIn(['pending', 'processing']));
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  Future<void> clearAllQueueEntries() async {
    await delete(queueEntries).go();
  }
}