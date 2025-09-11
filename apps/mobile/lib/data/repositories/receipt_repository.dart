// Temporarily removed interface until model mismatch is resolved
// import 'package:receipt_organizer/core/repositories/interfaces/i_receipt_repository.dart';
import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:receipt_organizer/core/models/audit_log.dart';
import 'package:receipt_organizer/domain/services/ocr_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class ReceiptRepository { // implements IReceiptRepository {
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
  Future<List<Receipt>> getAllReceipts({bool excludeDeleted = true}) async {
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
  Future<List<Receipt>> getReceiptsByDateRange(
    DateTime start,
    DateTime end, {
    bool excludeDeleted = true,
  }) async {
    final db = await database;
    
    // Format dates to match the stored format (MM/DD/YYYY)
    // final startStr = _formatDateForQuery(start);
    // final endStr = _formatDateForQuery(end);
    
    // Query with date range comparison
    // Note: This uses string comparison, which works for MM/DD/YYYY format
    // For better performance with large datasets, consider storing dates in ISO format
    final maps = await db.rawQuery('''
      SELECT * FROM $_tableName 
      WHERE receiptDate IS NOT NULL 
        AND receiptDate != ''
        AND (
          -- Handle MM/DD/YYYY format
          CASE 
            WHEN receiptDate LIKE '__/__/____' THEN
              substr(receiptDate, 7, 4) || substr(receiptDate, 1, 2) || substr(receiptDate, 4, 2)
            ELSE receiptDate
          END
        ) BETWEEN ? AND ?
      ORDER BY receiptDate DESC
    ''', [
      _formatDateForSqlComparison(start),
      _formatDateForSqlComparison(end),
    ]);
    
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
  Future<int> getReceiptCount({bool excludeDeleted = true}) async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName')
    );
    
    return count ?? 0;
  }

  @override
  Future<List<Receipt>> getReceiptsPaginated(
    int offset,
    int limit, {
    bool excludeDeleted = true,
  }) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      orderBy: 'capturedAt DESC',
      offset: offset,
      limit: limit,
    );
    
    return maps.map((map) => _mapToReceipt(map)).toList();
  }

  /// Format date for display and storage (MM/DD/YYYY)
//   String _formatDateForQuery(DateTime date) {
//     return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
//   }

  /// Format date for SQL comparison (YYYYMMDD)
  String _formatDateForSqlComparison(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
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
    );

    // Reconstruct OCR results from stored fields
    if (map['merchantName'] != null || map['receiptDate'] != null || 
        map['totalAmount'] != null || map['taxAmount'] != null) {
      final ocrResults = ProcessingResult(
        merchant: map['merchantName'] != null 
            ? FieldData(
                value: map['merchantName'],
                confidence: map['overallConfidence'] ?? 95.0,
                originalText: map['merchantName'],
              )
            : null,
        date: map['receiptDate'] != null
            ? FieldData(
                value: map['receiptDate'],
                confidence: map['overallConfidence'] ?? 95.0,
                originalText: map['receiptDate'],
              )
            : null,
        total: map['totalAmount'] != null
            ? FieldData(
                value: map['totalAmount'],
                confidence: map['overallConfidence'] ?? 95.0,
                originalText: map['totalAmount'].toString(),
              )
            : null,
        tax: map['taxAmount'] != null
            ? FieldData(
                value: map['taxAmount'],
                confidence: map['overallConfidence'] ?? 95.0,
                originalText: map['taxAmount'].toString(),
              )
            : null,
        overallConfidence: map['overallConfidence'] ?? 95.0,
        processingDurationMs: 500, // Default value since we don't store this
      );
      
      return receipt.copyWith(ocrResults: ocrResults);
    }
    
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
      'merchantName': receipt.merchantName,
      'receiptDate': receipt.receiptDate,
      'totalAmount': receipt.totalAmount,
      'taxAmount': receipt.taxAmount,
      'overallConfidence': receipt.overallConfidence,
      // In a real implementation, we'd serialize OCR results to JSON
      'ocrResultsJson': receipt.ocrResults != null ? jsonEncode({}) : null,
    };
  }

  // Additional methods required by IReceiptRepository

  @override
  Future<List<Receipt>> getReceiptsByUserId(
    String userId, {
    bool excludeDeleted = true,
  }) async {
    // For now, return all receipts as we don't have user-based filtering yet
    return getAllReceipts();
  }

  @override
  Future<void> softDelete(List<String> ids, String userId) async {
    // For now, use the existing delete functionality
    // In a real implementation, we'd set a deletedAt timestamp
    await deleteReceipts(ids);
  }

  @override
  Future<void> restore(List<String> ids, String userId) async {
    // Not implemented yet - would clear deletedAt timestamp
    // For now, this is a no-op
  }

  @override
  Future<void> permanentDelete(List<String> ids, String userId) async {
    // Use the existing delete functionality
    await deleteReceipts(ids);
  }

  @override
  Future<List<Receipt>> getExpiredSoftDeletes(int daysOld) async {
    // Not implemented yet - would query for receipts with old deletedAt
    return [];
  }

  @override
  Future<void> logAudit(AuditLog auditLog) async {
    // Not implemented yet - would write to audit log table
    // For now, this is a no-op
  }

  @override
  Future<List<AuditLog>> getAuditLogs(String userId, {int? limit}) async {
    // Not implemented yet - would query audit log table
    return [];
  }
}