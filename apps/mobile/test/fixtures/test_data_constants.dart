import 'package:receipt_organizer/domain/value_objects/money.dart';
import 'package:receipt_organizer/domain/value_objects/category.dart';
import 'package:receipt_organizer/domain/entities/receipt_status.dart';

/// Comprehensive test data constants for Receipt Organizer tests
///
/// These constants provide consistent, predictable test data across all test suites.
/// Following 2025 best practices for test data organization and maintainability.
class TestDataConstants {
  // Prevent instantiation
  TestDataConstants._();

  // ============================================================================
  // USER TEST DATA
  // ============================================================================

  static const testUserEmail = 'test.user@example.com';
  static const testUserPassword = 'Test123!@#';
  static const testUserId = '550e8400-e29b-41d4-a716-446655440000';
  static const testUserName = 'Test User';
  static const testUserPhone = '+1234567890';

  static const adminUserEmail = 'admin@example.com';
  static const adminUserId = '550e8400-e29b-41d4-a716-446655440001';

  static const Map<String, dynamic> testUserJson = {
    'id': testUserId,
    'email': testUserEmail,
    'name': testUserName,
    'phone': testUserPhone,
    'created_at': '2024-01-01T00:00:00Z',
    'updated_at': '2024-01-01T00:00:00Z',
  };

  // ============================================================================
  // RECEIPT TEST DATA
  // ============================================================================

  // Receipt IDs
  static const testReceiptId1 = '550e8400-e29b-41d4-a716-446655440100';
  static const testReceiptId2 = '550e8400-e29b-41d4-a716-446655440101';
  static const testReceiptId3 = '550e8400-e29b-41d4-a716-446655440102';

  // Merchant names
  static const merchantWalmart = 'Walmart Supercenter';
  static const merchantTarget = 'Target';
  static const merchantCostco = 'Costco Wholesale';
  static const merchantAmazon = 'Amazon.com';
  static const merchantStarbucks = 'Starbucks Coffee';
  static const merchantMcDonalds = 'McDonald\'s';
  static const merchantShell = 'Shell Gas Station';
  static const merchantWholeFoods = 'Whole Foods Market';

  static const List<String> allMerchants = [
    merchantWalmart,
    merchantTarget,
    merchantCostco,
    merchantAmazon,
    merchantStarbucks,
    merchantMcDonalds,
    merchantShell,
    merchantWholeFoods,
  ];

  // Common amounts
  static const amount999 = 9.99;
  static const amount2499 = 24.99;
  static const amount4999 = 49.99;
  static const amount9999 = 99.99;
  static const amount15678 = 156.78;
  static const amount24532 = 245.32;
  static const amount99999 = 999.99;

  // Tax amounts
  static const tax099 = 0.99;
  static const tax249 = 2.49;
  static const tax499 = 4.99;
  static const tax999 = 9.99;
  static const tax1234 = 12.34;

  // Image paths
  static const testImagePath1 = '/test/receipts/receipt_001.jpg';
  static const testImagePath2 = '/test/receipts/receipt_002.jpg';
  static const testImagePath3 = '/test/receipts/receipt_003.jpg';
  static const testThumbnailPath1 = '/test/receipts/thumb_001.jpg';
  static const testCloudUrl1 = 'https://storage.test/receipts/receipt_001.jpg';

  // ============================================================================
  // DATES AND TIMES
  // ============================================================================

  static final testDate2024Jan01 = DateTime(2024, 1, 1, 10, 0, 0);
  static final testDate2024Jan15 = DateTime(2024, 1, 15, 14, 30, 0);
  static final testDate2024Feb01 = DateTime(2024, 2, 1, 9, 15, 0);
  static final testDate2024Mar01 = DateTime(2024, 3, 1, 16, 45, 0);
  static final testDateToday = DateTime.now();
  static final testDateYesterday = DateTime.now().subtract(const Duration(days: 1));
  static final testDateLastWeek = DateTime.now().subtract(const Duration(days: 7));
  static final testDateLastMonth = DateTime.now().subtract(const Duration(days: 30));
  static final testDateLastYear = DateTime.now().subtract(const Duration(days: 365));

  // ============================================================================
  // CATEGORY TEST DATA
  // ============================================================================

  static const categoryGroceries = CategoryType.groceries;
  static const categoryDining = CategoryType.dining;
  static const categoryTransportation = CategoryType.transportation;
  static const categoryShopping = CategoryType.shopping;
  static const categoryUtilities = CategoryType.utilities;
  static const categoryHealthcare = CategoryType.healthcare;
  static const categoryEntertainment = CategoryType.entertainment;
  static const categoryBusiness = CategoryType.business;
  static const categoryOther = CategoryType.other;

  static const List<CategoryType> allCategories = CategoryType.values;

  // ============================================================================
  // PAYMENT METHODS
  // ============================================================================

  static const paymentCash = PaymentMethod.cash;
  static const paymentCreditCard = PaymentMethod.creditCard;
  static const paymentDebitCard = PaymentMethod.debitCard;
  static const paymentPayPal = PaymentMethod.paypal;
  static const paymentVenmo = PaymentMethod.venmo;
  static const paymentDigitalWallet = PaymentMethod.digitalWallet;

  // ============================================================================
  // RECEIPT STATUS
  // ============================================================================

  static const statusPending = ReceiptStatus.pending;
  static const statusCaptured = ReceiptStatus.captured;
  static const statusProcessing = ReceiptStatus.processing;
  static const statusProcessed = ReceiptStatus.processed;
  static const statusReviewed = ReceiptStatus.reviewed;
  static const statusError = ReceiptStatus.error;

  // ============================================================================
  // TAGS AND NOTES
  // ============================================================================

  static const List<String> commonTags = [
    'business',
    'personal',
    'tax-deductible',
    'reimbursable',
    'urgent',
    'monthly',
    'recurring',
    'one-time',
  ];

  static const String sampleNotes = 'This is a test receipt for unit testing purposes.';
  static const String longNotes = '''
This is a much longer note that contains multiple lines of text.
It might be used to test how the application handles longer text content.
Including special characters: !@#\$%^&*()_+-=[]{}|;':",.<>?/
And even emojis: 🧾 📱 💰
This ensures our text handling is robust.
''';

  // ============================================================================
  // BATCH AND PAGINATION DATA
  // ============================================================================

  static const testBatchId1 = '550e8400-e29b-41d4-a716-446655440200';
  static const testBatchId2 = '550e8400-e29b-41d4-a716-446655440201';

  static const defaultPageSize = 20;
  static const smallPageSize = 5;
  static const largePageSize = 100;

  // ============================================================================
  // ERROR MESSAGES
  // ============================================================================

  static const errorNetworkTimeout = 'Network request timed out';
  static const errorAuthFailed = 'Authentication failed';
  static const errorInvalidInput = 'Invalid input provided';
  static const errorNotFound = 'Resource not found';
  static const errorPermissionDenied = 'Permission denied';
  static const errorProcessingFailed = 'Receipt processing failed';
  static const errorOCRFailed = 'OCR extraction failed';
  static const errorStorageFull = 'Storage quota exceeded';

  // ============================================================================
  // OCR TEST DATA
  // ============================================================================

  static const String ocrRawTextWalmart = '''
WALMART SUPERCENTER
123 MAIN ST
ANYTOWN, ST 12345
(555) 123-4567

GROCERY        24.99
GROCERY        12.50
PHARMACY       45.00
ELECTRONICS    99.99

SUBTOTAL      182.48
TAX            12.34
TOTAL         194.82

VISA ****1234
AUTH: 123456
''';

  static const String ocrRawTextStarbucks = '''
STARBUCKS COFFEE
456 COFFEE AVE

VENTI LATTE     5.75
BANANA BREAD    3.50

SUBTOTAL        9.25
TAX             0.74
TOTAL          9.99

CASH           10.00
CHANGE          0.01
''';

  static const double ocrHighConfidence = 0.95;
  static const double ocrMediumConfidence = 0.75;
  static const double ocrLowConfidence = 0.50;

  // ============================================================================
  // ITEM/LINE ITEM TEST DATA
  // ============================================================================

  static const Map<String, dynamic> testItem1 = {
    'name': 'Milk 2% Gallon',
    'quantity': 2,
    'unit': 'gallon',
    'unit_price': 3.99,
    'total_price': 7.98,
    'category': 'dairy',
    'sku': 'MLK-2PCT-GAL',
  };

  static const Map<String, dynamic> testItem2 = {
    'name': 'Bread Whole Wheat',
    'quantity': 1,
    'unit': 'loaf',
    'unit_price': 2.49,
    'total_price': 2.49,
    'category': 'bakery',
    'sku': 'BRD-WW-LOAF',
  };

  static const Map<String, dynamic> testItem3 = {
    'name': 'Organic Apples',
    'quantity': 3.5,
    'unit': 'lb',
    'unit_price': 1.99,
    'total_price': 6.97,
    'category': 'produce',
    'sku': 'APL-ORG-LB',
  };

  // ============================================================================
  // API RESPONSE DATA
  // ============================================================================

  static const Map<String, dynamic> successApiResponse = {
    'success': true,
    'message': 'Operation completed successfully',
    'data': null,
    'timestamp': '2024-01-01T00:00:00Z',
  };

  static const Map<String, dynamic> errorApiResponse = {
    'success': false,
    'message': 'Operation failed',
    'error': {
      'code': 'TEST_ERROR',
      'details': 'This is a test error response',
    },
    'timestamp': '2024-01-01T00:00:00Z',
  };

  // ============================================================================
  // EXPORT DATA
  // ============================================================================

  static const String csvHeader = 'Date,Merchant,Amount,Tax,Category,Payment,Notes';
  static const String csvRow1 = '2024-01-01,Walmart,156.78,12.34,Groceries,Credit Card,Weekly shopping';
  static const String csvRow2 = '2024-01-02,Starbucks,9.99,0.99,Dining,Cash,Morning coffee';

  static const exportFormatCSV = 'csv';
  static const exportFormatJSON = 'json';
  static const exportFormatPDF = 'pdf';
  static const exportFormatExcel = 'xlsx';

  // ============================================================================
  // PERFORMANCE THRESHOLDS
  // ============================================================================

  static const Duration maxLoadTime = Duration(milliseconds: 300);
  static const Duration maxSearchTime = Duration(milliseconds: 100);
  static const Duration maxSaveTime = Duration(milliseconds: 500);
  static const Duration maxOCRTime = Duration(seconds: 5);
  static const Duration maxExportTime = Duration(seconds: 10);

  // ============================================================================
  // VALIDATION PATTERNS
  // ============================================================================

  static final RegExp emailPattern = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  static final RegExp phonePattern = RegExp(
    r'^\+?1?\d{9,15}$',
  );

  static final RegExp uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  static final RegExp amountPattern = RegExp(
    r'^\d+\.?\d{0,2}$',
  );

  // ============================================================================
  // MOCK DATA SETS
  // ============================================================================

  /// Get a list of mock receipt IDs
  static List<String> getMockReceiptIds(int count) {
    return List.generate(
      count,
      (index) => '550e8400-e29b-41d4-a716-44665544${index.toString().padLeft(4, '0')}',
    );
  }

  /// Get a random merchant name
  static String getRandomMerchant(int seed) {
    return allMerchants[seed % allMerchants.length];
  }

  /// Get a random category
  static CategoryType getRandomCategory(int seed) {
    return allCategories[seed % allCategories.length];
  }

  /// Get test amount based on index
  static double getTestAmount(int index) {
    final amounts = [amount999, amount2499, amount4999, amount9999, amount15678];
    return amounts[index % amounts.length];
  }

  /// Generate consistent test data for a given seed
  static Map<String, dynamic> generateSeededData(int seed) {
    return {
      'id': getMockReceiptIds(1).first,
      'merchant': getRandomMerchant(seed),
      'amount': getTestAmount(seed),
      'category': getRandomCategory(seed).name,
      'date': testDateToday.subtract(Duration(days: seed)),
      'status': ReceiptStatus.values[seed % ReceiptStatus.values.length].name,
    };
  }
}