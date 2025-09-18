import 'package:drift/web/worker.dart';
import '../lib/database/app_database.dart';

/// Web worker for Drift database operations
/// Runs database queries in background to prevent UI blocking
void main() {
  // Start the Drift web worker
  driftWorkerMain(() {
    return AppDatabase();
  });
}