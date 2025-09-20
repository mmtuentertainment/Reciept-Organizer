import 'package:flutter/foundation.dart';
import 'package:receipt_organizer/domain/repositories/i_receipt_repository.dart';

/// Receipt provider stub
class ReceiptProvider extends ChangeNotifier {
  final IReceiptRepository _repository;

  ReceiptProvider(this._repository);
}