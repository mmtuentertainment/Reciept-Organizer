import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:receipt_organizer/domain/models/receipt_model.dart';
import 'package:receipt_organizer/domain/value_objects/receipt_id.dart';
import 'package:receipt_organizer/domain/value_objects/money.dart';
import 'package:receipt_organizer/domain/value_objects/category.dart';
import 'package:receipt_organizer/domain/entities/receipt_status.dart';
import 'package:receipt_organizer/domain/core/result.dart';
import 'package:receipt_organizer/domain/core/failures.dart' as failures;
import 'package:receipt_organizer/domain/repositories/i_receipt_repository.dart';
import '../factories/receipt_factory.dart';
import '../factories/receipt_item_factory.dart';
import '../factories/base_factory.dart';
import '../fixtures/test_data_constants.dart';
import '../matchers/custom_matchers.dart';
import '../helpers/test_helpers.dart';
import '../helpers/widget_test_utils.dart';
import '../fakes/fake_receipt_repository_domain.dart';
import 'test_environment.dart';

/// Comprehensive validation test for the test infrastructure
///
/// This test ensures all components of our Phase 5 test infrastructure
/// work correctly together and follow 2025 best practices.
void main() {
  group('Test Infrastructure Validation', () {
    // ============================================================================
    // TEST ENVIRONMENT VALIDATION
    // ============================================================================

    group('Test Environment', () {
      test('detects test mode correctly', () {
        expect(TestEnvironment.isTestMode, isTrue,
            reason: 'Should detect Flutter test environment');
      });

      test('provides build configuration', () {
        expect(TestEnvironment.buildMode, equals(BuildMode.test));
        expect(TestEnvironment.isDebugMode, isFalse);
        expect(TestEnvironment.isProfileMode, isFalse);
        expect(TestEnvironment.isReleaseMode, isFalse);
      });

      test('configures Supabase bypass correctly', () {
        expect(TestEnvironment.shouldBypassSupabase, isTrue,
            reason: 'Should bypass Supabase in unit tests');
      });

      test('provides mock URLs when bypassing', () {
        expect(TestEnvironment.supabaseUrl, equals(TestEnvironment.mockSupabaseUrl));
        expect(TestEnvironment.supabaseAnonKey, equals(TestEnvironment.mockAnonKey));
      });

      test('respects integration test flag', () {
        // Simulate integration test
        TestEnvironment.setIntegrationTest(true);
        expect(TestEnvironment.shouldBypassSupabase, isFalse);

        // Reset
        TestEnvironment.setIntegrationTest(false);
      });
    });

    // ============================================================================
    // TEST DATA CONSTANTS VALIDATION
    // ============================================================================

    group('Test Data Constants', () {
      test('provides consistent test user data', () {
        expect(TestDataConstants.testUserEmail, isNotEmpty);
        expect(TestDataConstants.testUserId, matches(TestDataConstants.uuidPattern));
        expect(TestDataConstants.testUserPassword, contains(RegExp(r'[!@#]')));
      });

      test('provides valid receipt IDs', () {
        expect(TestDataConstants.testReceiptId1, isNotEmpty);
        expect(TestDataConstants.testReceiptId2, isNotEmpty);
        expect(TestDataConstants.testReceiptId3, isNotEmpty);
        expect(TestDataConstants.testReceiptId1, isNot(equals(TestDataConstants.testReceiptId2)));
      });

      test('provides merchant names', () {
        expect(TestDataConstants.allMerchants, isNotEmpty);
        expect(TestDataConstants.merchantWalmart, contains('Walmart'));
        expect(TestDataConstants.getRandomMerchant(0), isIn(TestDataConstants.allMerchants));
      });

      test('provides test amounts', () {
        expect(TestDataConstants.amount15678, equals(156.78));
        expect(TestDataConstants.getTestAmount(0), isPositive);
      });

      test('provides valid dates', () {
        expect(TestDataConstants.testDate2024Jan01.year, equals(2024));
        expect(TestDataConstants.testDateYesterday.isBefore(DateTime.now()), isTrue);
      });

      test('generates mock data correctly', () {
        final mockIds = TestDataConstants.getMockReceiptIds(5);
        expect(mockIds.length, equals(5));
        expect(mockIds.toSet().length, equals(5), reason: 'IDs should be unique');
      });
    });

    // ============================================================================
    // FACTORY VALIDATION
    // ============================================================================

    group('Receipt Factory', () {
      late ReceiptFactory factory;

      setUp(() {
        factory = ReceiptFactory();
      });

      test('creates valid receipts with defaults', () {
        final receipt = factory.create();
        expect(receipt, isValidReceipt());
        expect(receipt.id, isValidReceiptId());
        expect(receipt.status, isA<ReceiptStatus>());
      });

      test('creates batch of unique receipts', () {
        final receipts = factory.createBatch(10);
        expect(receipts.length, equals(10));

        final ids = receipts.map((r) => r.id.value).toSet();
        expect(ids.length, equals(10), reason: 'All receipts should have unique IDs');
      });

      test('creates specialized receipt types', () {
        final grocery = factory.createGroceryReceipt();
        expect(grocery.category?.type, equals(CategoryType.groceries));
        expect(grocery.items, isNotEmpty);

        final restaurant = factory.createRestaurantReceipt();
        expect(restaurant.category?.type, equals(CategoryType.dining));
        expect(restaurant.notes, contains('Tip'));

        final gas = factory.createGasStationReceipt();
        expect(gas.category?.type, equals(CategoryType.transportation));
        expect(gas.merchant, contains('Shell'));
      });

      test('creates receipts with specific status', () {
        final error = factory.createErrorReceipt();
        expect(error, hasReceiptStatus(ReceiptStatus.error));
        expect(error.errorMessage, isNotNull);

        final pending = factory.createPendingReceipt();
        expect(pending, hasReceiptStatus(ReceiptStatus.pending));
        expect(pending.totalAmount, isNull);
      });

      test('creates receipts with relationships', () {
        final batchId = 'test_batch_001';
        final batch = factory.createBatchWithRelationships(
          batchId: batchId,
          count: 3,
        );

        expect(batch.length, equals(3));
        expect(batch.every((r) => r.batchId == batchId), isTrue);
      });

      test('creates date range receipts', () {
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 1, 31);
        final receipts = factory.createDateRangeReceipts(
          startDate: start,
          endDate: end,
          count: 10,
        );

        expect(receipts.length, equals(10));
        for (final receipt in receipts) {
          expect(receipt.purchaseDate, isNotNull);
          expect(receipt.purchaseDate!.isAfter(start.subtract(const Duration(days: 1))), isTrue);
          expect(receipt.purchaseDate!.isBefore(end.add(const Duration(days: 1))), isTrue);
        }
      });

      test('creates complete receipt with all fields', () {
        final complete = factory.createComplete();
        expect(complete, hasCompleteData());
        expect(complete.merchant, isNotNull);
        expect(complete.totalAmount, isNotNull);
        expect(complete.items, isNotEmpty);
        expect(complete.tags, isNotEmpty);
        expect(complete.ocrRawText, isNotNull);
      });

      test('creates minimal receipt', () {
        final minimal = factory.createMinimal();
        expect(minimal.id, isValidReceiptId());
        expect(minimal.imagePath, isNotEmpty);
        expect(minimal.status, equals(ReceiptStatus.pending));
      });
    });

    group('Receipt Item Factory', () {
      late ReceiptItemFactory itemFactory;

      setUp(() {
        itemFactory = ReceiptItemFactory();
      });

      test('creates valid items', () {
        final item = itemFactory.create();
        expect(item.name, isNotEmpty);
        expect(item.totalPrice, isNotNull);
      });

      test('creates grocery items', () {
        final items = itemFactory.createGroceryItems(5);
        expect(items.length, equals(5));
        expect(items.every((i) => i.category != null), isTrue);
      });

      test('creates restaurant items', () {
        final items = itemFactory.createRestaurantItems(3);
        expect(items.length, equals(3));
        expect(items.every((i) => i.unit == 'each'), isTrue);
      });

      test('creates items with discount', () {
        final item = itemFactory.createWithDiscount(discountPercentage: 0.25);
        expect(item.discount, isNotNull);
        expect(item.notes, contains('25%'));
      });

      test('creates bulk items', () {
        final item = itemFactory.createBulkItem(weight: 2.5, pricePerUnit: 3.99);
        expect(item.quantity, equals(2.5));
        expect(item.unit, equals('lb'));
        expect(item.unitPrice?.amount, equals(3.99));
      });
    });

    // ============================================================================
    // CUSTOM MATCHERS VALIDATION
    // ============================================================================

    group('Custom Matchers', () {
      late ReceiptFactory factory;

      setUp(() {
        factory = ReceiptFactory();
      });

      test('receipt matchers work correctly', () {
        final receipt = factory.create();
        expect(receipt, isValidReceipt());

        final processed = factory.create(overrides: {
          'status': ReceiptStatus.processed,
          'totalAmount': Money.from(99.99, Currency.usd),
          'merchant': 'Test Store',
        });
        expect(processed, isProcessedReceipt());
        expect(processed, hasReceiptStatus(ReceiptStatus.processed));
        expect(processed, hasAmount(99.99));
        expect(processed, hasMerchant('Test Store'));

        final needsReviewReceipt = factory.create(overrides: {'needsReview': true});
        expect(needsReviewReceipt, needsReview());
      });

      test('value object matchers work correctly', () {
        final id = ReceiptId.generate();
        expect(id, isValidReceiptId());

        final money = Money.from(50.00, Currency.usd);
        expect(money, isMoney(amount: 50.00, currency: Currency.usd));
        expect(money, isMoneyBetween(25, 75));
      });

      test('result matchers work correctly', () {
        final success = Result<int, String>.success(42);
        expect(success, isSuccess<int, String>());
        expect(success, hasSuccessValue<int, String>(42));

        final failure = Result<int, failures.Failure>.failure(
          const failures.Failure.validation(
            message: 'Test error',
            errors: {'field': ['error message']},
          ),
        );
        expect(failure, isFailure<int, failures.Failure>());
        expect(failure, hasFailure<failures.ValidationFailure>());
      });

      test('collection matchers work correctly', () {
        final receipts = factory.createDateRangeReceipts(
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
          count: 5,
        );

        // Sort by date ascending
        receipts.sort((a, b) =>
          (a.purchaseDate ?? a.createdAt).compareTo(b.purchaseDate ?? b.createdAt));
        expect(receipts, isInDateOrder(ascending: true));

        // Test unique items
        final uniqueList = [1, 2, 3, 4, 5];
        expect(uniqueList, hasUniqueItems<int>());
      });

      test('async matchers work correctly', () async {
        final future = Future.value(42);
        await expectLater(future, completion(42));

        final delayedFuture = Future.delayed(
          const Duration(milliseconds: 100),
          () => 'result',
        );
        await expectLater(delayedFuture, completion('result'));
      });
    });

    // ============================================================================
    // FAKE REPOSITORY VALIDATION
    // ============================================================================

    group('Fake Receipt Repository', () {
      late FakeReceiptRepositoryDomain repository;

      setUp(() {
        repository = FakeReceiptRepositoryDomain();
      });

      test('implements all repository methods', () {
        expect(repository is IReceiptRepository, isTrue);
      });

      test('create operation works', () async {
        final receipt = ReceiptFactory().create();
        final result = await repository.create(receipt);

        expect(result, isSuccess<ReceiptModel, Failure>());
        expect(result.successOrNull, equals(receipt));
      });

      test('update operation works', () async {
        final receipt = ReceiptFactory().create();
        await repository.create(receipt);

        final updated = receipt.copyWith(merchant: 'Updated Store');
        final result = await repository.update(updated);

        expect(result, isSuccess<ReceiptModel, Failure>());
        expect(result.successOrNull?.merchant, equals('Updated Store'));
      });

      test('delete operation works', () async {
        final receipt = ReceiptFactory().create();
        await repository.create(receipt);

        final deleteResult = await repository.delete(receipt.id);
        expect(deleteResult, isSuccess<void, Failure>());

        final getResult = await repository.getById(receipt.id);
        expect(getResult, isFailure<ReceiptModel, Failure>());
      });

      test('watchAll emits initial state', () async {
        final receipts = ReceiptFactory().createBatch(3);
        for (final receipt in receipts) {
          await repository.create(receipt);
        }

        final stream = repository.watchAll();
        final firstEmission = await stream.first;

        expect(firstEmission, isSuccess<List<ReceiptModel>, Failure>());
        expect(firstEmission.successOrNull?.length, equals(3));
      });

      test('search functionality works', () async {
        await repository.create(
          ReceiptFactory().create(overrides: {'merchant': 'Walmart'}),
        );
        await repository.create(
          ReceiptFactory().create(overrides: {'merchant': 'Target'}),
        );

        final results = await repository.search('Walmart');
        expect(results, isSuccess<List<ReceiptModel>, Failure>());
        expect(results.successOrNull?.length, equals(1));
        expect(results.successOrNull?.first.merchant, equals('Walmart'));
      });

      test('filter by status works', () async {
        await repository.create(
          ReceiptFactory().create(overrides: {'status': ReceiptStatus.processed}),
        );
        await repository.create(
          ReceiptFactory().create(overrides: {'status': ReceiptStatus.pending}),
        );

        final results = await repository.filterByStatus(ReceiptStatus.processed);
        expect(results, isSuccess<List<ReceiptModel>, Failure>());
        expect(results.successOrNull?.length, equals(1));
        expect(results.successOrNull?.first.status, equals(ReceiptStatus.processed));
      });

      test('batch operations work', () async {
        final receipts = ReceiptFactory().createBatch(5);
        final results = await repository.batchCreate(receipts);

        expect(results, isSuccess<List<ReceiptModel>, Failure>());
        expect(results.successOrNull?.length, equals(5));

        final allReceipts = await repository.getAll();
        expect(allReceipts.successOrNull?.length, equals(5));
      });

      test('error simulation works', () async {
        repository.setShouldFail(true);

        final result = await repository.create(ReceiptFactory().create());
        expect(result, isFailure<ReceiptModel, failures.Failure>());
        expect(result.failureOrNull?.message, contains('Simulated failure'));
      });
    });

    // ============================================================================
    // TEST HELPERS VALIDATION
    // ============================================================================

    group('Test Helpers', () {
      testWidgets('createTestableWidget works', (tester) async {
        final widget = createTestableWidget(
          child: const Text('Test Widget'),
        );

        await tester.pumpWidget(widget);
        expect(find.text('Test Widget'), findsOneWidget);
      });

      testWidgets('pumpAndSettleWithTimeout prevents hanging', (tester) async {
        // Create a widget that never settles
        await tester.pumpWidget(
          MaterialApp(
            home: StreamBuilder(
              stream: Stream.periodic(const Duration(milliseconds: 50)),
              builder: (context, snapshot) => Text('Count: ${snapshot.data}'),
            ),
          ),
        );

        // Should not hang
        await pumpAndSettleWithTimeout(tester, timeout: const Duration(seconds: 1));
        expect(find.textContaining('Count:'), findsOneWidget);
      });

      test('generateTestImageData creates valid data', () {
        final imageData = generateTestImageData(
          width: 50,
          height: 50,
          color: Colors.red,
        );

        expect(imageData, isNotEmpty);
        expect(imageData.length, equals(50 * 50 * 4)); // RGBA channels
      });

      testWidgets('FakeAuthProvider works', (tester) async {
        final authProvider = FakeAuthProvider();

        expect(authProvider.isAuthenticated, isFalse);

        await authProvider.signIn(
          TestDataConstants.testUserEmail,
          TestDataConstants.testUserPassword,
        );

        expect(authProvider.isAuthenticated, isTrue);
        expect(authProvider.userEmail, equals(TestDataConstants.testUserEmail));
      });
    });

    // ============================================================================
    // WIDGET TEST UTILITIES VALIDATION
    // ============================================================================

    group('Widget Test Utilities', () {
      testWidgets('TestProviderScope sets up providers', (tester) async {
        await tester.pumpWidget(
          const TestProviderScope(
            child: Text('Test'),
          ),
        );

        expect(find.text('Test'), findsOneWidget);
      });

      testWidgets('ReceiptFinders work correctly', (tester) async {
        final receipt = ReceiptFactory().create();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListTile(
                key: Key('receipt_card_${receipt.id.value}'),
                title: Text(receipt.merchant ?? 'Unknown'),
              ),
              floatingActionButton: const FloatingActionButton(
                onPressed: null,
                child: Icon(Icons.add),
              ),
            ),
          ),
        );

        expect(ReceiptFinders.receiptCard(receipt), findsOneWidget);
        expect(ReceiptFinders.addReceiptButton(), findsOneWidget);
      });

      testWidgets('InteractionHelper performs actions', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {},
                  ),
                ],
              ),
              body: const Center(child: Text('Content')),
            ),
          ),
        );

        final helper = InteractionHelper(tester);
        await helper.openSearch();
        // Would continue with more interaction tests
      });
    });

    // ============================================================================
    // INTEGRATION TEST
    // ============================================================================

    group('Full Infrastructure Integration', () {
      testWidgets('complete test flow works', (tester) async {
        // 1. Setup environment
        setupTestEnvironment();

        // 2. Create test data using factories with specific merchants
        final factory = ReceiptFactory();
        final receipts = [
          factory.create(overrides: {'merchant': 'Walmart'}),
          factory.create(overrides: {'merchant': 'Target'}),
          factory.create(overrides: {'merchant': 'Costco'}),
        ];

        // 3. Setup fake repository
        final repository = FakeReceiptRepositoryDomain();
        for (final receipt in receipts) {
          await repository.create(receipt);
        }

        // 4. Create testable widget
        final widget = createTestableWidget(
          receiptRepository: repository,
          child: Material(
            child: ListView(
              children: receipts.map((r) => ListTile(
                key: Key('receipt_${r.id.value}'),
                title: Text(r.merchant ?? 'Unknown'),
                subtitle: Text(r.totalAmount?.formatted ?? '\$0.00'),
              )).toList(),
            ),
          ),
        );

        // 5. Pump widget and verify
        await tester.pumpWidget(widget);

        // 6. Use custom matchers - verify known merchants
        expect(find.text('Walmart'), findsOneWidget);
        expect(find.text('Target'), findsOneWidget);
        expect(find.text('Costco'), findsOneWidget);

        // 7. Cleanup
        teardownTestEnvironment();
      });

      test('all test infrastructure components integrate correctly', () {
        // Test that all components work together
        final environment = TestEnvironment.isTestMode;
        final constants = TestDataConstants.testReceiptId1;
        final factory = ReceiptFactory();
        final repository = FakeReceiptRepositoryDomain();

        expect(environment, isTrue);
        expect(constants, isNotEmpty);
        expect(factory.create(), isValidReceipt());
        expect(repository is IReceiptRepository, isTrue);
      });
    });
  });
}