import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:receipt_organizer/core/repositories/interfaces/i_receipt_repository.dart';
import 'package:receipt_organizer/data/repositories/receipt_repository.dart';

part 'repository_providers.g.dart';

/// Provider for ReceiptRepository instance
@riverpod
Future<IReceiptRepository> receiptRepository(ReceiptRepositoryRef ref) async {
  final repository = ReceiptRepository();
  // Initialize if needed
  return repository;
}