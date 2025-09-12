import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/queue_entry.dart';

/// Database service for request queue persistence
/// 
/// EXPERIMENT: Phase 3 - Queue persistence layer
/// Uses SQLite to store failed requests for later retry
class QueueDatabaseService {
  static final QueueDatabaseService _instance = QueueDatabaseService._internal();
  factory QueueDatabaseService() => _instance;
  QueueDatabaseService._internal();
  
  static Database? _database;
  
  /// Database name
  static const String _databaseName = 'request_queue.db';
  static const int _databaseVersion = 1;
  
  /// Table and column names
  static const String tableName = 'queue_entries';
  static const String columnId = 'id';
  static const String columnEndpoint = 'endpoint';
  static const String columnMethod = 'method';
  static const String columnHeaders = 'headers';
  static const String columnBody = 'body';
  static const String columnCreatedAt = 'created_at';
  static const String columnLastAttemptAt = 'last_attempt_at';
  static const String columnRetryCount = 'retry_count';
  static const String columnMaxRetries = 'max_retries';
  static const String columnErrorMessage = 'error_message';
  static const String columnStatus = 'status';
  static const String columnFeature = 'feature';
  static const String columnUserId = 'user_id';
  
  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  /// Initialize database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }
  
  /// Create database schema
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId TEXT PRIMARY KEY,
        $columnEndpoint TEXT NOT NULL,
        $columnMethod TEXT NOT NULL,
        $columnHeaders TEXT NOT NULL,
        $columnBody TEXT,
        $columnCreatedAt INTEGER NOT NULL,
        $columnLastAttemptAt INTEGER,
        $columnRetryCount INTEGER NOT NULL,
        $columnMaxRetries INTEGER NOT NULL,
        $columnErrorMessage TEXT,
        $columnStatus TEXT NOT NULL,
        $columnFeature TEXT,
        $columnUserId TEXT
      )
    ''');
    
    // Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_status ON $tableName ($columnStatus)
    ''');
    
    await db.execute('''
      CREATE INDEX idx_created_at ON $tableName ($columnCreatedAt)
    ''');
  }
  
  /// Insert a new queue entry
  Future<void> insert(QueueEntry entry) async {
    final db = await database;
    await db.insert(
      tableName,
      _toMap(entry),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  /// Get all pending entries
  Future<List<QueueEntry>> getPendingEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnStatus = ?',
      whereArgs: ['pending'],
      orderBy: '$columnCreatedAt ASC',
    );
    
    return maps.map((map) => _fromMap(map)).toList();
  }
  
  /// Get entry by ID
  Future<QueueEntry?> getById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }
  
  /// Update entry
  Future<void> update(QueueEntry entry) async {
    final db = await database;
    await db.update(
      tableName,
      _toMap(entry),
      where: '$columnId = ?',
      whereArgs: [entry.id],
    );
  }
  
  /// Delete entry
  Future<void> delete(String id) async {
    final db = await database;
    await db.delete(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
  
  /// Delete completed entries older than specified duration
  Future<int> deleteOldCompleted({Duration age = const Duration(days: 7)}) async {
    final db = await database;
    final cutoff = DateTime.now().subtract(age).millisecondsSinceEpoch;
    
    return await db.delete(
      tableName,
      where: '$columnStatus = ? AND $columnCreatedAt < ?',
      whereArgs: ['completed', cutoff],
    );
  }
  
  /// Get queue size
  Future<int> getQueueSize() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName WHERE $columnStatus = ?', ['pending']);
    return Sqflite.firstIntValue(result) ?? 0;
  }
  
  /// Clear all entries (for testing/debugging)
  Future<void> clearAll() async {
    final db = await database;
    await db.delete(tableName);
  }
  
  /// Convert QueueEntry to Map for database
  Map<String, dynamic> _toMap(QueueEntry entry) {
    return {
      columnId: entry.id,
      columnEndpoint: entry.endpoint,
      columnMethod: entry.method,
      columnHeaders: json.encode(entry.headers),
      columnBody: entry.body != null ? json.encode(entry.body) : null,
      columnCreatedAt: entry.createdAt.millisecondsSinceEpoch,
      columnLastAttemptAt: entry.lastAttemptAt?.millisecondsSinceEpoch,
      columnRetryCount: entry.retryCount,
      columnMaxRetries: entry.maxRetries,
      columnErrorMessage: entry.errorMessage,
      columnStatus: entry.status.name,
      columnFeature: entry.feature,
      columnUserId: entry.userId,
    };
  }
  
  /// Convert Map from database to QueueEntry
  QueueEntry _fromMap(Map<String, dynamic> map) {
    return QueueEntry(
      id: map[columnId] as String,
      endpoint: map[columnEndpoint] as String,
      method: map[columnMethod] as String,
      headers: json.decode(map[columnHeaders] as String) as Map<String, dynamic>,
      body: map[columnBody] != null 
        ? json.decode(map[columnBody] as String) as Map<String, dynamic>
        : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map[columnCreatedAt] as int),
      lastAttemptAt: map[columnLastAttemptAt] != null
        ? DateTime.fromMillisecondsSinceEpoch(map[columnLastAttemptAt] as int)
        : null,
      retryCount: map[columnRetryCount] as int,
      maxRetries: map[columnMaxRetries] as int,
      errorMessage: map[columnErrorMessage] as String?,
      status: QueueEntryStatus.values.firstWhere(
        (e) => e.name == map[columnStatus],
        orElse: () => QueueEntryStatus.pending,
      ),
      feature: map[columnFeature] as String?,
      userId: map[columnUserId] as String?,
    );
  }
}