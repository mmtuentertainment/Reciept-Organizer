import 'dart:convert';
import 'package:drift/drift.dart';
import '../models/queue_entry.dart';
import '../../database/app_database.dart';

/// Database service for request queue persistence
///
/// Uses Drift database (works on all platforms including web)
class QueueDatabaseService {
  static final QueueDatabaseService _instance = QueueDatabaseService._internal();
  factory QueueDatabaseService() => _instance;
  QueueDatabaseService._internal();

  final AppDatabase _database = AppDatabase();

  /// Insert queue entry
  Future<int> insert(QueueEntry entry) async {
    final companion = QueueEntriesCompanion(
      id: Value(entry.id),
      endpoint: Value(entry.endpoint),
      method: Value(entry.method),
      headers: Value(json.encode(entry.headers)),
      body: entry.body != null ? Value(json.encode(entry.body)) : const Value.absent(),
      createdAt: Value(entry.createdAt),
      lastAttemptAt: entry.lastAttemptAt != null ? Value(entry.lastAttemptAt!) : const Value.absent(),
      retryCount: Value(entry.retryCount),
      maxRetries: Value(entry.maxRetries),
      status: Value(entry.status.name),
      errorMessage: entry.errorMessage != null ? Value(entry.errorMessage!) : const Value.absent(),
      feature: entry.feature != null ? Value(entry.feature!) : const Value.absent(),
      userId: entry.userId != null ? Value(entry.userId!) : const Value.absent(),
    );
    return await _database.insertQueueEntry(companion);
  }

  /// Get all pending entries
  Future<List<QueueEntry>> getPending() async {
    final entities = await _database.getPendingQueueEntries();
    return entities.map(_entityToModel).toList();
  }

  /// Get entries for a specific feature
  Future<List<QueueEntry>> getByFeature(String feature) async {
    final entities = await _database.getQueueEntriesByFeature(feature);
    return entities.map(_entityToModel).toList();
  }

  /// Update entry
  Future<int> update(QueueEntry entry) async {
    final companion = QueueEntriesCompanion(
      endpoint: Value(entry.endpoint),
      method: Value(entry.method),
      headers: Value(json.encode(entry.headers)),
      body: entry.body != null ? Value(json.encode(entry.body)) : const Value.absent(),
      lastAttemptAt: entry.lastAttemptAt != null ? Value(entry.lastAttemptAt!) : const Value.absent(),
      retryCount: Value(entry.retryCount),
      maxRetries: Value(entry.maxRetries),
      status: Value(entry.status.name),
      errorMessage: entry.errorMessage != null ? Value(entry.errorMessage!) : const Value.absent(),
      feature: entry.feature != null ? Value(entry.feature!) : const Value.absent(),
      userId: entry.userId != null ? Value(entry.userId!) : const Value.absent(),
    );
    final success = await _database.updateQueueEntry(companion, entry.id);
    return success ? 1 : 0;
  }

  /// Delete entry
  Future<int> delete(String id) async {
    return await _database.deleteQueueEntry(id);
  }

  /// Delete all completed entries
  Future<int> deleteCompleted() async {
    return await _database.deleteCompletedQueueEntries();
  }

  /// Get entry count
  Future<int> getCount() async {
    return await _database.getQueueSize();
  }

  /// Close database
  Future<void> close() async {
    // Database is managed by AppDatabase singleton
    // No need to close it here as it's shared
  }

  /// Get queue size
  Future<int> getQueueSize() async {
    return await _database.getQueueSize();
  }

  /// Get pending entries
  Future<List<QueueEntry>> getPendingEntries() async {
    final entities = await _database.getPendingQueueEntries();
    return entities.map(_entityToModel).toList();
  }

  /// Clear all entries
  Future<void> clearAll() async {
    await _database.clearAllQueueEntries();
  }

  /// Delete old completed entries
  Future<void> deleteOldCompleted() async {
    await _database.deleteOldCompletedQueueEntries();
  }

  /// Convert database entity to model
  QueueEntry _entityToModel(QueueEntryEntity entity) {
    return QueueEntry(
      id: entity.id,
      endpoint: entity.endpoint,
      method: entity.method,
      headers: entity.headers.isNotEmpty
          ? Map<String, dynamic>.from(json.decode(entity.headers))
          : {},
      body: entity.body != null
          ? Map<String, dynamic>.from(json.decode(entity.body!))
          : null,
      createdAt: entity.createdAt,
      lastAttemptAt: entity.lastAttemptAt,
      retryCount: entity.retryCount,
      maxRetries: entity.maxRetries,
      status: QueueEntryStatus.values.firstWhere(
        (s) => s.name == entity.status,
        orElse: () => QueueEntryStatus.pending,
      ),
      errorMessage: entity.errorMessage,
      feature: entity.feature,
      userId: entity.userId,
    );
  }
}