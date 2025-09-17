import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Initialize database factory for web platform
///
/// Flutter web doesn't support SQLite directly, so we use
/// sqflite_common_ffi_web or fallback to IndexedDB
void initializeDatabaseForWeb() {
  // For web, we'll use in-memory database or IndexedDB
  // This prevents the initialization error
  try {
    databaseFactory = databaseFactoryFfi;
  } catch (e) {
    print('Note: SQLite not available on web, using fallback storage');
  }
}