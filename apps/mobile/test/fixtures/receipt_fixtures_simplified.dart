import 'package:receipt_organizer/data/models/receipt.dart';
import 'package:uuid/uuid.dart';

/// Simplified test fixture data for receipts
///
/// Provides standard test receipts using only fields that exist in the current Receipt model.
class ReceiptFixtures {
  static const _uuid = Uuid();

  /// A complete receipt with all available fields populated
  static Receipt complete() {
    return Receipt(
      id: _uuid.v4(),
      imageUri: '/test/receipts/complete.jpg',
      capturedAt: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
      vendorName: 'Walmart Supercenter',
      totalAmount: 156.78,
      taxAmount: 12.34,
      receiptDate: DateTime.now().subtract(const Duration(days: 1)),
      categoryId: 'groceries',
      paymentMethod: 'credit_card',
      notes: 'Weekly grocery shopping',
      tags: ['groceries', 'essentials', 'weekly'],
      status: ReceiptStatus.ready,
      syncStatus: 'synced',
      ocrRawText: 'WALMART SUPERCENTER\\n123 Main St\\nTotal: \$156.78',
      ocrConfidence: 0.95,
      metadata: {
        'vendor': 'Walmart Supercenter',
        'total': '156.78',
        'tax': '12.34',
        'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
      batchId: 'batch-001',
      lastModified: DateTime.now(),
    );
  }

  /// A minimal receipt with only required fields
  static Receipt minimal() {
    return Receipt(
      id: _uuid.v4(),
      imageUri: '/test/receipts/minimal.jpg',
      capturedAt: DateTime.now(),
      status: ReceiptStatus.pending,
      lastModified: DateTime.now(),
    );
  }

  /// A receipt that's in processing state
  static Receipt processing() {
    return Receipt(
      id: _uuid.v4(),
      imageUri: '/test/receipts/processing.jpg',
      capturedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      status: ReceiptStatus.processing,
      ocrRawText: 'Processing...',
      ocrConfidence: 0.0,
      metadata: {},
      lastModified: DateTime.now(),
    );
  }

  /// A receipt with OCR error
  static Receipt withOcrError() {
    return Receipt(
      id: _uuid.v4(),
      imageUri: '/test/receipts/error.jpg',
      capturedAt: DateTime.now().subtract(const Duration(hours: 1)),
      status: ReceiptStatus.error,
      syncStatus: 'error',
      lastModified: DateTime.now(),
    );
  }

  /// A gas station receipt
  static Receipt gasStation() {
    return Receipt(
      id: _uuid.v4(),
      imageUri: '/test/receipts/gas.jpg',
      capturedAt: DateTime.now().subtract(const Duration(days: 2)),
      vendorName: 'Shell Gas Station',
      totalAmount: 45.00,
      receiptDate: DateTime.now().subtract(const Duration(days: 2)),
      categoryId: 'transportation',
      paymentMethod: 'debit_card',
      notes: 'Gas for work commute',
      status: ReceiptStatus.ready,
      lastModified: DateTime.now(),
    );
  }

  /// A restaurant receipt
  static Receipt restaurant() {
    return Receipt(
      id: _uuid.v4(),
      imageUri: '/test/receipts/restaurant.jpg',
      capturedAt: DateTime.now().subtract(const Duration(days: 3)),
      vendorName: 'The Olive Garden',
      totalAmount: 67.50,
      taxAmount: 5.50,
      receiptDate: DateTime.now().subtract(const Duration(days: 3)),
      categoryId: 'dining',
      paymentMethod: 'credit_card',
      notes: 'Business lunch with client',
      tags: ['business', 'lunch', 'client-meeting'],
      status: ReceiptStatus.ready,
      lastModified: DateTime.now(),
    );
  }

  /// Generate a batch of receipts
  static List<Receipt> batch({
    int count = 5,
    String? batchId,
    DateTime? capturedAt,
  }) {
    final id = batchId ?? _uuid.v4();
    final time = capturedAt ?? DateTime.now();
    final receipts = <Receipt>[];

    for (int i = 0; i < count; i++) {
      receipts.add(
        ReceiptBuilder()
            .withBatchId(id)
            .withCapturedAt(time.add(Duration(seconds: i)))
            .withVendor('Store ${i + 1}')
            .withAmount((i + 1) * 25.0)
            .build(),
      );
    }

    return receipts;
  }
}

/// Simplified builder pattern for creating custom receipts
class ReceiptBuilder {
  static const _uuid = Uuid();

  String? _id;
  String? _imageUri;
  DateTime? _capturedAt;
  DateTime? _createdAt;
  DateTime? _updatedAt;
  String? _vendorName;
  double? _totalAmount;
  double? _taxAmount;
  DateTime? _receiptDate;
  String? _categoryId;
  String? _paymentMethod;
  String? _notes;
  List<String>? _tags;
  ReceiptStatus? _status;
  String? _syncStatus;
  String? _ocrRawText;
  double? _ocrConfidence;
  Map<String, dynamic>? _metadata;
  String? _batchId;

  ReceiptBuilder withId(String id) {
    _id = id;
    return this;
  }

  ReceiptBuilder withImageUri(String uri) {
    _imageUri = uri;
    return this;
  }

  ReceiptBuilder withCapturedAt(DateTime date) {
    _capturedAt = date;
    return this;
  }

  ReceiptBuilder withDate(DateTime date) {
    _receiptDate = date;
    return this;
  }

  ReceiptBuilder withVendor(String vendor) {
    _vendorName = vendor;
    return this;
  }

  ReceiptBuilder withAmount(double amount) {
    _totalAmount = amount;
    return this;
  }

  ReceiptBuilder withTax(double tax) {
    _taxAmount = tax;
    return this;
  }

  ReceiptBuilder withCategory(String category) {
    _categoryId = category;
    return this;
  }

  ReceiptBuilder withPaymentMethod(String method) {
    _paymentMethod = method;
    return this;
  }

  ReceiptBuilder withNotes(String notes) {
    _notes = notes;
    return this;
  }

  ReceiptBuilder withTags(List<String> tags) {
    _tags = tags;
    return this;
  }

  ReceiptBuilder withStatus(ReceiptStatus status) {
    _status = status;
    return this;
  }

  ReceiptBuilder withSyncStatus(String status) {
    _syncStatus = status;
    return this;
  }

  ReceiptBuilder withOcrText(String text, double confidence) {
    _ocrRawText = text;
    _ocrConfidence = confidence;
    return this;
  }

  ReceiptBuilder withMetadata(Map<String, dynamic> metadata) {
    _metadata = metadata;
    return this;
  }

  ReceiptBuilder withBatchId(String batchId) {
    _batchId = batchId;
    return this;
  }

  Receipt build() {
    final now = DateTime.now();
    return Receipt(
      id: _id ?? _uuid.v4(),
      imageUri: _imageUri ?? '/test/receipt.jpg',
      capturedAt: _capturedAt ?? now,
      createdAt: _createdAt ?? now,
      updatedAt: _updatedAt,
      vendorName: _vendorName,
      totalAmount: _totalAmount,
      taxAmount: _taxAmount,
      receiptDate: _receiptDate,
      categoryId: _categoryId,
      paymentMethod: _paymentMethod,
      notes: _notes,
      tags: _tags,
      status: _status ?? ReceiptStatus.ready,
      syncStatus: _syncStatus ?? 'pending',
      ocrRawText: _ocrRawText,
      ocrConfidence: _ocrConfidence,
      metadata: _metadata,
      batchId: _batchId,
      lastModified: now,
    );
  }
}