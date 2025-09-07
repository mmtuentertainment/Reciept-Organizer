import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

/// Helper class for setting up test databases
class TestDatabaseHelper {
  static bool _initialized = false;

  /// Initialize sqflite_ffi for testing
  /// This allows tests to run without requiring native SQLite libraries
  static void initialize() {
    if (_initialized) return;
    
    // Initialize FFI
    sqfliteFfiInit();
    
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
    
    _initialized = true;
  }

  /// Get an in-memory database path for testing
  static String get inMemoryPath => inMemoryDatabasePath;

  /// Create a test database with a unique name
  static Future<Database> createTestDatabase([String? name]) async {
    initialize();
    
    // Use in-memory database for faster tests and no cleanup needed
    final dbPath = name != null ? name : inMemoryPath;
    
    // Delete any existing database with this name
    if (dbPath != inMemoryPath) {
      await deleteDatabase(dbPath);
    }
    
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        // Create the receipts table
        await db.execute('''
          CREATE TABLE receipts (
            id TEXT PRIMARY KEY,
            imageUri TEXT NOT NULL,
            thumbnailUri TEXT,
            capturedAt TEXT NOT NULL,
            status TEXT NOT NULL,
            batchId TEXT,
            notes TEXT,
            lastModified TEXT NOT NULL,
            merchantName TEXT,
            receiptDate TEXT,
            totalAmount REAL,
            taxAmount REAL,
            ocrConfidence REAL,
            processingDuration INTEGER,
            errorMessage TEXT
          )
        ''');
        
        // Create indexes
        await db.execute(
          'CREATE INDEX idx_batch_id ON receipts (batchId)',
        );
        await db.execute(
          'CREATE INDEX idx_receipt_date ON receipts (receiptDate)',
        );
      },
    );
  }
}

/// Mock database factory for unit tests that don't need actual SQL
class MockDatabaseFactory {
  static Database createMockDatabase() {
    // This would return a mock database instance
    // For now, we'll use the real in-memory database
    throw UnimplementedError('Use TestDatabaseHelper.createTestDatabase() instead');
  }
}