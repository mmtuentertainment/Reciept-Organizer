import 'package:faker/faker.dart';
import 'package:receipt_organizer/domain/models/receipt_model.dart';
import 'package:receipt_organizer/domain/value_objects/receipt_id.dart';
import 'package:receipt_organizer/domain/value_objects/money.dart' as money;
import 'package:receipt_organizer/domain/value_objects/category.dart';
import 'package:receipt_organizer/domain/entities/receipt_status.dart';
import 'package:receipt_organizer/domain/entities/receipt_item.dart';
import '../fixtures/test_data_constants.dart';
import 'base_factory.dart';
import 'receipt_item_factory.dart';

/// Advanced Receipt Factory for generating test data
///
/// Implements 2025 best practices with smart relationships,
/// realistic data generation, and builder pattern integration.
class ReceiptFactory extends BaseFactory<ReceiptModel> {
  static final _faker = Faker();
  static int _sequenceCounter = 0;

  /// Item factory for generating line items
  final ReceiptItemFactory _itemFactory = ReceiptItemFactory();

  // ============================================================================
  // CORE FACTORY METHODS
  // ============================================================================

  @override
  Map<String, dynamic> generateDefaults() {
    _sequenceCounter++;
    final now = DateTime.now();
    final receiptDate = _faker.date.dateTime(
      minYear: now.year - 1,
      maxYear: now.year,
    );

    // Generate realistic merchant name
    final merchant = _generateMerchantName();

    // Generate realistic amount based on merchant type
    final amount = _generateAmountForMerchant(merchant);

    // Select appropriate category based on merchant
    final category = _selectCategoryForMerchant(merchant);

    // Generate appropriate payment method
    final paymentMethod = _selectPaymentMethod(amount);

    return {
      'id': ReceiptId.generate(),
      'createdAt': receiptDate,
      'updatedAt': now,
      'status': ReceiptStatus.processed,
      'imagePath': '/receipts/${_faker.guid.guid()}.jpg',
      'merchant': merchant,
      'totalAmount': money.Money.from(amount, money.Currency.usd),
      'taxAmount': money.Money.from(amount * 0.08, money.Currency.usd), // 8% tax
      'purchaseDate': receiptDate,
      'category': Category(type: category),
      'paymentMethod': paymentMethod,
      'notes': _faker.lorem.sentence(),
      'businessPurpose': _faker.randomGenerator.boolean() ? _faker.lorem.sentence() : null,
      'items': [], // Items added separately if needed
      'tags': _generateTags(category),
      'isFavorite': _faker.randomGenerator.decimal() < 0.2,
      'batchId': null,
      'ocrConfidence': _faker.randomGenerator.decimal(min: 0.7, scale: 0.95),
      'ocrRawText': _generateOcrText(merchant, amount),
      'cloudStorageUrl': _faker.randomGenerator.boolean()
          ? 'https://storage.example.com/receipts/${_faker.guid.guid()}.jpg'
          : null,
      'needsReview': _faker.randomGenerator.decimal() < 0.1,
    };
  }

  @override
  ReceiptModel fromMap(Map<String, dynamic> data) {
    return ReceiptModel(
      id: data['id'] as ReceiptId,
      createdAt: data['createdAt'] as DateTime,
      updatedAt: data['updatedAt'] as DateTime? ?? data['createdAt'] as DateTime,
      status: data['status'] as ReceiptStatus,
      imagePath: data['imagePath'] as String,
      merchant: data['merchant'] as String?,
      totalAmount: data['totalAmount'] as money.Money?,
      taxAmount: data['taxAmount'] as money.Money?,
      purchaseDate: data['purchaseDate'] as DateTime?,
      category: data['category'] as Category?,
      paymentMethod: data['paymentMethod'] as PaymentMethod?,
      notes: data['notes'] as String?,
      businessPurpose: data['businessPurpose'] as String?,
      items: (data['items'] as List?)?.cast<ReceiptItem>() ?? [],
      tags: data['tags'] as List<String>? ?? [],
      isFavorite: data['isFavorite'] as bool? ?? false,
      batchId: data['batchId'] as String?,
      ocrConfidence: data['ocrConfidence'] as double?,
      ocrRawText: data['ocrRawText'] as String?,
      errorMessage: data['errorMessage'] as String?,
      cloudStorageUrl: data['cloudStorageUrl'] as String?,
      needsReview: data['needsReview'] as bool? ?? false,
    );
  }

  // ============================================================================
  // SPECIALIZED CREATION METHODS
  // ============================================================================

  /// Create a grocery store receipt
  ReceiptModel createGroceryReceipt({
    int itemCount = 5,
    Map<String, dynamic>? overrides,
  }) {
    final items = _itemFactory.createGroceryItems(itemCount);
    final total = items.fold<double>(
      0,
      (sum, item) => sum + (item.totalPrice?.amount ?? 0),
    );

    final defaults = {
      'merchant': TestDataConstants.getRandomMerchant(_sequenceCounter),
      'category': Category(type: CategoryType.groceries),
      'items': items,
      'totalAmount': money.Money.from(total * 1.08, money.Currency.usd), // Include tax
      'taxAmount': money.Money.from(total * 0.08, money.Currency.usd),
      'tags': ['groceries', 'weekly-shopping'],
    };

    return create(overrides: {...defaults, ...?overrides});
  }

  /// Create a restaurant receipt
  ReceiptModel createRestaurantReceipt({
    double tipPercentage = 0.18,
    Map<String, dynamic>? overrides,
  }) {
    final subtotal = _faker.randomGenerator.decimal(min: 20, scale: 150);
    final tax = subtotal * 0.08;
    final tip = subtotal * tipPercentage;
    final total = subtotal + tax + tip;

    final defaults = {
      'merchant': _generateRestaurantName(),
      'category': Category(type: CategoryType.dining),
      'totalAmount': money.Money.from(total, money.Currency.usd),
      'taxAmount': money.Money.from(tax, money.Currency.usd),
      'notes': 'Tip: \$${tip.toStringAsFixed(2)}',
      'tags': ['dining', 'restaurant'],
      'paymentMethod': PaymentMethod.creditCard,
    };

    return create(overrides: {...defaults, ...?overrides});
  }

  /// Create a gas station receipt
  ReceiptModel createGasStationReceipt({
    double gallons = 12.5,
    double pricePerGallon = 3.50,
    Map<String, dynamic>? overrides,
  }) {
    final total = gallons * pricePerGallon;

    final defaults = {
      'merchant': 'Shell Gas Station',
      'category': Category(type: CategoryType.transportation),
      'totalAmount': money.Money.from(total, money.Currency.usd),
      'notes': '${gallons}gal @ \$${pricePerGallon}/gal',
      'tags': ['gas', 'transportation', 'auto'],
      'paymentMethod': PaymentMethod.creditCard,
    };

    return create(overrides: {...defaults, ...?overrides});
  }

  /// Create a receipt with error status
  ReceiptModel createErrorReceipt({
    String? errorMessage,
    Map<String, dynamic>? overrides,
  }) {
    final defaults = {
      'status': ReceiptStatus.error,
      'errorMessage': errorMessage ?? 'OCR processing failed',
      'ocrConfidence': 0.3,
      'needsReview': true,
      'totalAmount': null,
      'merchant': null,
    };

    return create(overrides: {...defaults, ...?overrides});
  }

  /// Create a pending receipt
  ReceiptModel createPendingReceipt({Map<String, dynamic>? overrides}) {
    final defaults = {
      'status': ReceiptStatus.pending,
      'totalAmount': null,
      'merchant': null,
      'ocrRawText': null,
      'ocrConfidence': null,
    };

    return create(overrides: {...defaults, ...?overrides});
  }

  /// Create a batch of receipts with relationships
  List<ReceiptModel> createBatchWithRelationships({
    required String batchId,
    required int count,
    Map<String, dynamic>? sharedOverrides,
  }) {
    final captureTime = DateTime.now();

    return List.generate(count, (index) {
      final defaults = {
        'batchId': batchId,
        'createdAt': captureTime.add(Duration(seconds: index)),
        'imagePath': '/batch/$batchId/receipt_${index.toString().padLeft(3, '0')}.jpg',
      };

      return create(overrides: {...defaults, ...?sharedOverrides});
    });
  }

  /// Create receipts for date range testing
  List<ReceiptModel> createDateRangeReceipts({
    required DateTime startDate,
    required DateTime endDate,
    required int count,
  }) {
    final daysDiff = endDate.difference(startDate).inDays;

    return List.generate(count, (index) {
      final daysOffset = (daysDiff * index / count).round();
      final receiptDate = startDate.add(Duration(days: daysOffset));

      return create(overrides: {
        'purchaseDate': receiptDate,
        'createdAt': receiptDate,
      });
    });
  }

  /// Create receipts with specific total amounts
  ReceiptModel createWithAmount(double amount, {Map<String, dynamic>? overrides}) {
    final tax = amount * 0.08;
    final subtotal = amount - tax;

    final defaults = {
      'totalAmount': money.Money.from(amount, money.Currency.usd),
      'taxAmount': money.Money.from(tax, money.Currency.usd),
    };

    return create(overrides: {...defaults, ...?overrides});
  }

  /// Create a fully populated receipt with all fields
  ReceiptModel createComplete({Map<String, dynamic>? overrides}) {
    final items = _itemFactory.createBatch(5);
    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + (item.totalPrice?.amount ?? 0),
    );
    final tax = subtotal * 0.08;
    final total = subtotal + tax;

    final defaults = {
      'merchant': TestDataConstants.merchantWalmart,
      'totalAmount': money.Money.from(total, money.Currency.usd),
      'taxAmount': money.Money.from(tax, money.Currency.usd),
      'purchaseDate': DateTime.now().subtract(const Duration(days: 1)),
      'category': Category(type: CategoryType.groceries),
      'paymentMethod': PaymentMethod.creditCard,
      'notes': 'Complete test receipt with all fields',
      'businessPurpose': 'Office supplies for Q1',
      'items': items,
      'tags': ['complete', 'test', 'all-fields'],
      'isFavorite': true,
      'ocrConfidence': 0.95,
      'ocrRawText': TestDataConstants.ocrRawTextWalmart,
      'cloudStorageUrl': 'https://storage.example.com/receipts/complete.jpg',
      'needsReview': false,
    };

    return create(overrides: {...defaults, ...?overrides});
  }

  /// Create minimal receipt with only required fields
  ReceiptModel createMinimal({Map<String, dynamic>? overrides}) {
    return ReceiptModel(
      id: ReceiptId.generate(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: ReceiptStatus.pending,
      imagePath: '/receipts/minimal.jpg',
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  String _generateMerchantName() {
    final merchants = [
      ...TestDataConstants.allMerchants,
      '${_faker.company.name()} Store',
      '${_faker.company.name()} Market',
      '${_faker.company.name()} Shop',
    ];

    return merchants[_faker.randomGenerator.integer(merchants.length)];
  }

  String _generateRestaurantName() {
    final types = ['Cafe', 'Bistro', 'Kitchen', 'Grill', 'Restaurant', 'Diner'];
    return '${_faker.company.name()} ${types[_faker.randomGenerator.integer(types.length)]}';
  }

  double _generateAmountForMerchant(String merchant) {
    if (merchant.toLowerCase().contains('walmart') ||
        merchant.toLowerCase().contains('costco')) {
      return _faker.randomGenerator.decimal(min: 50, scale: 300);
    } else if (merchant.toLowerCase().contains('starbucks') ||
               merchant.toLowerCase().contains('coffee')) {
      return _faker.randomGenerator.decimal(min: 3, scale: 20);
    } else if (merchant.toLowerCase().contains('gas') ||
               merchant.toLowerCase().contains('shell')) {
      return _faker.randomGenerator.decimal(min: 20, scale: 80);
    } else {
      return _faker.randomGenerator.decimal(min: 10, scale: 150);
    }
  }

  CategoryType _selectCategoryForMerchant(String merchant) {
    final lowerMerchant = merchant.toLowerCase();

    if (lowerMerchant.contains('walmart') ||
        lowerMerchant.contains('costco') ||
        lowerMerchant.contains('market') ||
        lowerMerchant.contains('foods')) {
      return CategoryType.groceries;
    } else if (lowerMerchant.contains('restaurant') ||
               lowerMerchant.contains('cafe') ||
               lowerMerchant.contains('bistro') ||
               lowerMerchant.contains('starbucks')) {
      return CategoryType.dining;
    } else if (lowerMerchant.contains('gas') ||
               lowerMerchant.contains('shell') ||
               lowerMerchant.contains('uber')) {
      return CategoryType.transportation;
    } else if (lowerMerchant.contains('target') ||
               lowerMerchant.contains('amazon')) {
      return CategoryType.shopping;
    } else {
      return CategoryType.other;
    }
  }

  PaymentMethod _selectPaymentMethod(double amount) {
    if (amount < 20) {
      return _faker.randomGenerator.element([
        PaymentMethod.cash,
        PaymentMethod.debitCard,
      ]);
    } else if (amount > 500) {
      return PaymentMethod.creditCard;
    } else {
      return _faker.randomGenerator.element([
        PaymentMethod.creditCard,
        PaymentMethod.debitCard,
        PaymentMethod.digitalWallet,
      ]);
    }
  }

  List<String> _generateTags(CategoryType category) {
    final baseTags = [category.name];

    if (_faker.randomGenerator.decimal() < 0.5) {
      baseTags.add('business');
    }
    if (_faker.randomGenerator.decimal() < 0.3) {
      baseTags.add('tax-deductible');
    }
    if (_faker.randomGenerator.decimal() < 0.2) {
      baseTags.add('reimbursable');
    }

    return baseTags;
  }

  String _generateOcrText(String merchant, double amount) {
    return '''
$merchant
${_faker.address.streetAddress()}
${_faker.address.city()}, ${_faker.address.state()} ${_faker.address.zipCode()}

Date: ${DateTime.now().toString().substring(0, 10)}
Time: ${_faker.date.time()}

SUBTOTAL: \$${(amount * 0.92).toStringAsFixed(2)}
TAX: \$${(amount * 0.08).toStringAsFixed(2)}
TOTAL: \$${amount.toStringAsFixed(2)}

Thank you for your business!
''';
  }
}