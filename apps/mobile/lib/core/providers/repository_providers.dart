import 'package:riverpod_annotation/riverpod_annotation.dart';
// Temporarily disabled due to model mismatch
// import 'package:receipt_organizer/core/repositories/interfaces/i_receipt_repository.dart';
import 'package:receipt_organizer/data/repositories/receipt_repository.dart';

part 'repository_providers.g.dart';

/// Provider for ReceiptRepository instance
/// NOTE: Currently returns concrete ReceiptRepository due to model mismatch
/// TODO: Fix once Receipt models are consolidated
@riverpod
Future<ReceiptRepository> receiptRepository(ReceiptRepositoryRef ref) async {
  final repository = ReceiptRepository();
  // Initialize if needed
  return repository;
}