import 'package:receipt_organizer/core/repositories/interfaces/i_receipt_repository.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class ReceiptRepository implements IReceiptRepository {
  static const String _tableName = 'receipts';
  static const String _databaseName = 'receipt_organizer.db';
  static const int _databaseVersion = 1;
  
  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        imageUri TEXT NOT NULL,
        thumbnailUri TEXT,
        capturedAt TEXT NOT NULL,
        status TEXT NOT NULL,
        batchId TEXT,
        lastModified TEXT NOT NULL,
        notes TEXT,
        merchantName TEXT,
        receiptDate TEXT,
        totalAmount REAL,
        taxAmount REAL,
        overallConfidence REAL,
        ocrResultsJson TEXT
      )
    ''');

    // Create index on receiptDate for performance (PERF-001)
    await db.execute('''
      CREATE INDEX idx_receipt_date ON $_tableName (receiptDate)
    ''');
    
    // Create index on batchId for batch queries
    await db.execute('''
      CREATE INDEX idx_batch_id ON $_tableName (batchId)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future migrations here
  }

  @override
  Future<List<Receipt>> getAllReceipts() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'capturedAt DESC');
    
    return maps.map((map) => _mapToReceipt(map)).toList();
  }

  @override
  Future<Receipt?> getReceiptById(String id) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return _mapToReceipt(maps.first);
  }

  @override
  Future<List<Receipt>> getReceiptsByBatchId(String batchId) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'batchId = ?',
      whereArgs: [batchId],
      orderBy: 'capturedAt DESC',
    );
    
    return maps.map((map) => _mapToReceipt(map)).toList();
  }

  @override
  Future<List<Receipt>> getReceiptsByDateRange(DateTime start, DateTime end) async {
    final db = await database;

    // Since we now store dates as ISO8601 strings, we can use simple string comparison
    // ISO8601 format (YYYY-MM-DDTHH:MM:SS.sss) sorts correctly as strings
    final startStr = start.toIso8601String();
    final endStr = end.add(const Duration(days: 1)).toIso8601String(); // Add 1 day to include the end date fully

    final maps = await db.query(
      _tableName,
      where: 'receiptDate IS NOT NULL AND receiptDate >= ? AND receiptDate < ?',
      whereArgs: [startStr, endStr],
      orderBy: 'receiptDate DESC',
    );

    return maps.map((map) => _mapToReceipt(map)).toList();
  }

  @override
  Future<Receipt> createReceipt(Receipt receipt) async {
    final db = await database;
    final map = _receiptToMap(receipt);
    
    await db.insert(_tableName, map);
    return receipt;
  }

  @override
  Future<void> updateReceipt(Receipt receipt) async {
    final db = await database;
    final map = _receiptToMap(receipt);
    
    await db.update(
      _tableName,
      map,
      where: 'id = ?',
      whereArgs: [receipt.id],
    );
  }

  @override
  Future<void> deleteReceipt(String id) async {
    final db = await database;
    
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteReceipts(List<String> ids) async {
    if (ids.isEmpty) return;
    
    final db = await database;
    final batch = db.batch();
    
    for (final id in ids) {
      batch.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    }
    
    await batch.commit(noResult: true);
  }

  @override
  Future<int> getReceiptCount() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName')
    );
    
    return count ?? 0;
  }

  @override
  Future<List<Receipt>> getReceiptsPaginated(int offset, int limit) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      orderBy: 'capturedAt DESC',
      offset: offset,
      limit: limit,
    );
    
    return maps.map((map) => _mapToReceipt(map)).toList();
  }


  /// Convert database map to Receipt object
  Receipt _mapToReceipt(Map<String, dynamic> map) {
    final receipt = Receipt(
      id: map['id'],
      imageUri: map['imageUri'],
      thumbnailUri: map['thumbnailUri'],
      capturedAt: DateTime.parse(map['capturedAt']),
      status: ReceiptStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReceiptStatus.captured,
      ),
      batchId: map['batchId'],
      lastModified: DateTime.parse(map['lastModified']),
      notes: map['notes'],
      vendorName: map['merchantName'],  // Map DB field to model field
      receiptDate: map['receiptDate'] != null
          ? (map['receiptDate'] is String && map['receiptDate'].contains('T')
              ? DateTime.parse(map['receiptDate'])
              : map['receiptDate'])
          : null,
      totalAmount: map['totalAmount'],
      taxAmount: map['taxAmount'],
      ocrConfidence: map['overallConfidence'],  // Map DB field to model field
    );

    // If we have OCR results stored, we'd reconstruct them here
    // For now, returning the basic receipt without OCR results

    return receipt;
  }

  /// Convert Receipt object to database map
  Map<String, dynamic> _receiptToMap(Receipt receipt) {
    return {
      'id': receipt.id,
      'imageUri': receipt.imageUri,
      'thumbnailUri': receipt.thumbnailUri,
      'capturedAt': receipt.capturedAt.toIso8601String(),
      'status': receipt.status.name,
      'batchId': receipt.batchId,
      'lastModified': receipt.lastModified.toIso8601String(),
      'notes': receipt.notes,
      'merchantName': receipt.vendorName,  // Map model field to DB field
      'receiptDate': receipt.receiptDate is DateTime
          ? (receipt.receiptDate as DateTime).toIso8601String()
          : receipt.receiptDate,
      'totalAmount': receipt.totalAmount,
      'taxAmount': receipt.taxAmount,
      'overallConfidence': receipt.ocrConfidence,  // Map model field to DB field
      // In a real implementation, we'd serialize OCR results to JSON
      'ocrResultsJson': receipt.ocrResults != null ? jsonEncode({}) : null,
    };
  }
}