import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ReceiptRecord {
  final String id;
  final String imagePath;
  final String? thumbnailPath;
  final DateTime capturedAt;
  final String? merchant;
  final DateTime? date;
  final double? total;
  final double? tax;
  final double confidence;
  final String? rawOcrText;
  final String? notes;

  ReceiptRecord({
    required this.id,
    required this.imagePath,
    this.thumbnailPath,
    required this.capturedAt,
    this.merchant,
    this.date,
    this.total,
    this.tax,
    required this.confidence,
    this.rawOcrText,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'thumbnailPath': thumbnailPath,
      'capturedAt': capturedAt.millisecondsSinceEpoch,
      'merchant': merchant,
      'date': date?.millisecondsSinceEpoch,
      'total': total,
      'tax': tax,
      'confidence': confidence,
      'rawOcrText': rawOcrText,
      'notes': notes,
    };
  }

  static ReceiptRecord fromMap(Map<String, dynamic> map) {
    return ReceiptRecord(
      id: map['id'],
      imagePath: map['imagePath'],
      thumbnailPath: map['thumbnailPath'],
      capturedAt: DateTime.fromMillisecondsSinceEpoch(map['capturedAt']),
      merchant: map['merchant'],
      date: map['date'] != null ? DateTime.fromMillisecondsSinceEpoch(map['date']) : null,
      total: map['total'],
      tax: map['tax'],
      confidence: map['confidence'],
      rawOcrText: map['rawOcrText'],
      notes: map['notes'],
    );
  }
}

class ReceiptStorageService {
  static const String _dbName = 'receipts.db';
  static const int _dbVersion = 1;
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final fullPath = path.join(dbPath, _dbName);

    return await openDatabase(
      fullPath,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE receipts(
            id TEXT PRIMARY KEY,
            imagePath TEXT NOT NULL,
            thumbnailPath TEXT,
            capturedAt INTEGER NOT NULL,
            merchant TEXT,
            date INTEGER,
            total REAL,
            tax REAL,
            confidence REAL NOT NULL,
            rawOcrText TEXT,
            notes TEXT
          )
        ''');

        // Create index on date for performance
        await db.execute('CREATE INDEX idx_receipt_date ON receipts(date)');
      },
    );
  }

  Future<String> saveReceipt({
    required String imagePath,
    String? thumbnailPath,
    String? merchant,
    DateTime? date,
    double? total,
    double? tax,
    double confidence = 0.0,
    String? rawOcrText,
    String? notes,
  }) async {
    final db = await database;
    final id = const Uuid().v4();

    final record = ReceiptRecord(
      id: id,
      imagePath: imagePath,
      thumbnailPath: thumbnailPath,
      capturedAt: DateTime.now(),
      merchant: merchant,
      date: date,
      total: total,
      tax: tax,
      confidence: confidence,
      rawOcrText: rawOcrText,
      notes: notes,
    );

    await db.insert('receipts', record.toMap());
    return id;
  }

  Future<List<ReceiptRecord>> getAllReceipts() async {
    final db = await database;
    final maps = await db.query('receipts', orderBy: 'capturedAt DESC');
    return maps.map((map) => ReceiptRecord.fromMap(map)).toList();
  }

  Future<List<ReceiptRecord>> searchReceipts(String searchTerm) async {
    if (searchTerm.isEmpty) {
      return getAllReceipts();
    }

    final db = await database;
    final searchPattern = '%${searchTerm.toLowerCase()}%';

    final maps = await db.query(
      'receipts',
      where: '''
        LOWER(merchant) LIKE ? OR
        LOWER(notes) LIKE ? OR
        LOWER(rawOcrText) LIKE ?
      ''',
      whereArgs: [searchPattern, searchPattern, searchPattern],
      orderBy: 'capturedAt DESC',
    );

    return maps.map((map) => ReceiptRecord.fromMap(map)).toList();
  }

  Future<ReceiptRecord?> getReceipt(String id) async {
    final db = await database;
    final maps = await db.query('receipts', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return ReceiptRecord.fromMap(maps.first);
  }

  Future<void> deleteReceipt(String id) async {
    final db = await database;

    // Get receipt to delete files
    final receipt = await getReceipt(id);
    if (receipt != null) {
      // Delete image files
      try {
        if (await File(receipt.imagePath).exists()) {
          await File(receipt.imagePath).delete();
        }
        if (receipt.thumbnailPath != null && await File(receipt.thumbnailPath).exists()) {
          await File(receipt.thumbnailPath).delete();
        }
      } catch (_) {
        // Ignore file deletion errors
      }
    }

    // Delete database record
    await db.delete('receipts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> cleanupOrphanedImages() async {
    final db = await database;
    final receipts = await getAllReceipts();
    final validPaths = <String>{};

    for (final receipt in receipts) {
      validPaths.add(receipt.imagePath);
      if (receipt.thumbnailPath != null) {
        validPaths.add(receipt.thumbnailPath);
      }
    }

    // Check receipts directory
    final appDir = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory(path.join(appDir.path, 'receipts'));

    if (await receiptsDir.exists()) {
      await for (final file in receiptsDir.list(recursive: true)) {
        if (file is File && !validPaths.contains(file.path)) {
          try {
            await file.delete();
          } catch (_) {
            // Ignore deletion errors
          }
        }
      }
    }
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}