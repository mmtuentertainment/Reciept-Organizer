import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:receipt_organizer/domain/models/receipt_model.dart';
import 'package:receipt_organizer/domain/repositories/i_receipt_repository.dart';
import 'package:receipt_organizer/presentation/providers/receipt_provider.dart';
import 'package:receipt_organizer/presentation/providers/export_provider.dart';
import 'package:receipt_organizer/presentation/providers/search_provider.dart';
import 'package:receipt_organizer/presentation/providers/filter_provider.dart';
import 'package:receipt_organizer/presentation/providers/settings_provider.dart';
import '../fakes/fake_receipt_repository_domain.dart';
import '../factories/receipt_factory.dart';

/// Widget test utilities for Receipt Organizer
///
/// Provides specialized helpers for testing UI components and screens
/// with proper provider setup and navigation handling.

// ============================================================================
// PROVIDER SETUP UTILITIES
// ============================================================================

/// Creates a comprehensive provider setup for testing
class TestProviderScope extends StatelessWidget {
  final Widget child;
  final IReceiptRepository? receiptRepository;
  final ReceiptProvider? receiptProvider;
  final ExportProvider? exportProvider;
  final SearchProvider? searchProvider;
  final FilterProvider? filterProvider;
  final SettingsProvider? settingsProvider;
  final List<NavigatorObserver>? navigatorObservers;
  final GlobalKey<NavigatorState>? navigatorKey;

  const TestProviderScope({
    Key? key,
    required this.child,
    this.receiptRepository,
    this.receiptProvider,
    this.exportProvider,
    this.searchProvider,
    this.filterProvider,
    this.settingsProvider,
    this.navigatorObservers,
    this.navigatorKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repo = receiptRepository ?? FakeReceiptRepositoryDomain();

    return MultiProvider(
      providers: [
        Provider<IReceiptRepository>.value(value: repo),
        ChangeNotifierProvider<ReceiptProvider>(
          create: (_) => receiptProvider ?? ReceiptProvider(repo),
        ),
        ChangeNotifierProvider<ExportProvider>(
          create: (_) => exportProvider ?? ExportProvider(),
        ),
        ChangeNotifierProvider<SearchProvider>(
          create: (_) => searchProvider ?? SearchProvider(),
        ),
        ChangeNotifierProvider<FilterProvider>(
          create: (_) => filterProvider ?? FilterProvider(),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => settingsProvider ?? SettingsProvider(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: navigatorObservers ?? [],
        home: Material(child: child),
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    // Define test routes here if needed
    switch (settings.name) {
      case '/details':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Text('Receipt Details')),
          settings: settings,
        );
      case '/capture':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Text('Capture Receipt')),
          settings: settings,
        );
      case '/export':
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Text('Export Receipts')),
          settings: settings,
        );
      default:
        return null;
    }
  }
}

// ============================================================================
// SCREEN TEST HELPERS
// ============================================================================

/// Helper for testing screen navigation
class NavigationTestHelper {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final List<NavigatorObserver> observers = [];
  final MockNavigatorObserver mockObserver = MockNavigatorObserver();

  NavigationTestHelper() {
    observers.add(mockObserver);
  }

  /// Verifies navigation to a specific route
  void verifyNavigationTo(String routeName) {
    verify(() => mockObserver.didPush(any(), any()));
    final Route? pushedRoute = navigatorKey.currentState?.widget.pages?.last as Route?;
    expect(pushedRoute?.settings.name, equals(routeName));
  }

  /// Verifies navigation back
  void verifyNavigationBack() {
    verify(() => mockObserver.didPop(any(), any()));
  }

  /// Gets the current route
  String? get currentRoute {
    return navigatorKey.currentState?.widget.pages?.last.name;
  }
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// ============================================================================
// FINDER HELPERS
// ============================================================================

/// Extended finder utilities for Receipt Organizer widgets
class ReceiptFinders {
  /// Finds a receipt card by its model
  static Finder receiptCard(ReceiptModel receipt) {
    return find.byKey(Key('receipt_card_${receipt.id.value}'));
  }

  /// Finds a receipt tile by merchant name
  static Finder receiptByMerchant(String merchant) {
    return find.descendant(
      of: find.byType(ListTile),
      matching: find.text(merchant),
    );
  }

  /// Finds the add receipt FAB
  static Finder addReceiptButton() {
    return find.byType(FloatingActionButton);
  }

  /// Finds the search bar
  static Finder searchBar() {
    return find.byType(TextField).first;
  }

  /// Finds filter chips
  static Finder filterChip(String label) {
    return find.descendant(
      of: find.byType(FilterChip),
      matching: find.text(label),
    );
  }

  /// Finds sort option
  static Finder sortOption(String option) {
    return find.descendant(
      of: find.byType(PopupMenuItem),
      matching: find.text(option),
    );
  }

  /// Finds empty state widget
  static Finder emptyState() {
    return find.text('No receipts found');
  }

  /// Finds loading indicator
  static Finder loadingIndicator() {
    return find.byType(CircularProgressIndicator);
  }

  /// Finds error message
  static Finder errorMessage(String message) {
    return find.text(message);
  }

  /// Finds success snackbar
  static Finder successSnackBar() {
    return find.descendant(
      of: find.byType(SnackBar),
      matching: find.byIcon(Icons.check_circle),
    );
  }
}

// ============================================================================
// INTERACTION HELPERS
// ============================================================================

/// Helper class for common widget interactions
class InteractionHelper {
  final WidgetTester tester;

  InteractionHelper(this.tester);

  /// Opens the drawer
  Future<void> openDrawer() async {
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
  }

  /// Closes the drawer
  Future<void> closeDrawer() async {
    // Swipe from right to left to close drawer
    await tester.dragFrom(const Offset(50, 200), const Offset(-250, 0));
    await tester.pumpAndSettle();
  }

  /// Opens the search bar
  Future<void> openSearch() async {
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
  }

  /// Types in search field
  Future<void> searchFor(String query) async {
    await openSearch();
    await tester.enterText(ReceiptFinders.searchBar(), query);
    await tester.pump(const Duration(milliseconds: 500)); // Debounce delay
  }

  /// Selects a filter
  Future<void> selectFilter(String filterLabel) async {
    await tester.tap(ReceiptFinders.filterChip(filterLabel));
    await tester.pumpAndSettle();
  }

  /// Sorts receipts
  Future<void> sortBy(String sortOption) async {
    await tester.tap(find.byIcon(Icons.sort));
    await tester.pumpAndSettle();
    await tester.tap(ReceiptFinders.sortOption(sortOption));
    await tester.pumpAndSettle();
  }

  /// Deletes a receipt with swipe
  Future<void> deleteReceiptBySwipe(ReceiptModel receipt) async {
    final finder = ReceiptFinders.receiptCard(receipt);
    await tester.drag(finder, const Offset(-300, 0));
    await tester.pumpAndSettle();
  }

  /// Long presses on a receipt
  Future<void> selectReceipt(ReceiptModel receipt) async {
    await tester.longPress(ReceiptFinders.receiptCard(receipt));
    await tester.pumpAndSettle();
  }

  /// Selects multiple receipts
  Future<void> selectMultipleReceipts(List<ReceiptModel> receipts) async {
    for (final receipt in receipts) {
      await selectReceipt(receipt);
    }
  }

  /// Performs bulk action
  Future<void> performBulkAction(String action) async {
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text(action));
    await tester.pumpAndSettle();
  }

  /// Refreshes the list with pull-to-refresh
  Future<void> pullToRefresh() async {
    await tester.drag(
      find.byType(RefreshIndicator),
      const Offset(0, 300),
    );
    await tester.pumpAndSettle();
  }

  /// Scrolls to load more items
  Future<void> scrollToLoadMore() async {
    await tester.drag(
      find.byType(ListView),
      const Offset(0, -500),
    );
    await tester.pump();
  }

  /// Takes a screenshot (for golden tests)
  Future<void> takeScreenshot(String name) async {
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('screenshots/$name.png'),
    );
  }
}

// ============================================================================
// ANIMATION TEST HELPERS
// ============================================================================

/// Helper for testing animations
class AnimationTestHelper {
  final WidgetTester tester;

  AnimationTestHelper(this.tester);

  /// Waits for fade transition to complete
  Future<void> waitForFadeTransition() async {
    await tester.pump(); // Start animation
    await tester.pump(const Duration(milliseconds: 150)); // Mid animation
    await tester.pump(const Duration(milliseconds: 150)); // Complete animation
  }

  /// Waits for slide transition
  Future<void> waitForSlideTransition() async {
    await tester.pump(); // Start
    await tester.pump(const Duration(milliseconds: 100)); // 33%
    await tester.pump(const Duration(milliseconds: 100)); // 66%
    await tester.pump(const Duration(milliseconds: 100)); // Complete
  }

  /// Tests hero animation
  Future<void> testHeroAnimation(Finder fromWidget, Finder toScreen) async {
    await tester.tap(fromWidget);
    await tester.pump(); // Start hero animation
    await tester.pump(const Duration(milliseconds: 150)); // Mid animation
    await tester.pump(const Duration(milliseconds: 150)); // Complete
    expect(toScreen, findsOneWidget);
  }

  /// Verifies animation controller state
  void verifyAnimationState(AnimationController controller, {
    required bool isCompleted,
    required bool isDismissed,
    required bool isAnimating,
  }) {
    if (isCompleted) expect(controller.isCompleted, isTrue);
    if (isDismissed) expect(controller.isDismissed, isTrue);
    if (isAnimating) expect(controller.isAnimating, isTrue);
  }
}

// ============================================================================
// STATE VERIFICATION HELPERS
// ============================================================================

/// Helper for verifying widget states
class StateVerificationHelper {
  final WidgetTester tester;

  StateVerificationHelper(this.tester);

  /// Verifies loading state
  void verifyLoadingState() {
    expect(ReceiptFinders.loadingIndicator(), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
  }

  /// Verifies empty state
  void verifyEmptyState({String? message}) {
    expect(ReceiptFinders.emptyState(), findsOneWidget);
    if (message != null) {
      expect(find.text(message), findsOneWidget);
    }
  }

  /// Verifies error state
  void verifyErrorState(String errorMessage) {
    expect(ReceiptFinders.errorMessage(errorMessage), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  }

  /// Verifies success state with receipts
  void verifyReceiptsList(List<ReceiptModel> receipts) {
    expect(find.byType(ListView), findsOneWidget);
    for (final receipt in receipts) {
      if (receipt.merchant != null) {
        expect(find.text(receipt.merchant!), findsOneWidget);
      }
    }
  }

  /// Verifies search results
  void verifySearchResults(String query, int expectedCount) {
    expect(find.text('$expectedCount results for "$query"'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(expectedCount));
  }

  /// Verifies filter is applied
  void verifyFilterApplied(String filterName) {
    final filterChip = tester.widget<FilterChip>(
      ReceiptFinders.filterChip(filterName),
    );
    expect(filterChip.selected, isTrue);
  }

  /// Verifies sort order
  void verifySortOrder(List<String> expectedOrder) {
    final tiles = tester.widgetList<ListTile>(find.byType(ListTile));
    final actualOrder = tiles
        .map((tile) => (tile.title as Text?)?.data)
        .where((text) => text != null)
        .toList();

    expect(actualOrder, equals(expectedOrder));
  }
}

// ============================================================================
// MOCK DATA GENERATORS
// ============================================================================

/// Generates mock data for widget tests
class MockDataGenerator {
  static final ReceiptFactory _factory = ReceiptFactory();

  /// Creates a list of receipts for testing list views
  static List<ReceiptModel> generateReceiptList({
    int count = 10,
    bool includeErrors = false,
    bool includePending = false,
  }) {
    final receipts = <ReceiptModel>[];

    // Add regular receipts
    receipts.addAll(_factory.createBatch(count - 2));

    // Add special status receipts
    if (includeErrors) {
      receipts.add(_factory.createErrorReceipt());
    }
    if (includePending) {
      receipts.add(_factory.createPendingReceipt());
    }

    return receipts;
  }

  /// Creates receipts for pagination testing
  static List<List<ReceiptModel>> generatePaginatedReceipts({
    int pageSize = 20,
    int pageCount = 3,
  }) {
    return List.generate(
      pageCount,
      (page) => _factory.createBatch(pageSize),
    );
  }

  /// Creates receipts for date range testing
  static List<ReceiptModel> generateDateRangeReceipts({
    required DateTime startDate,
    required DateTime endDate,
    int count = 30,
  }) {
    return _factory.createDateRangeReceipts(
      startDate: startDate,
      endDate: endDate,
      count: count,
    );
  }

  /// Creates receipts with specific categories
  static Map<String, List<ReceiptModel>> generateCategorizedReceipts() {
    return {
      'Groceries': List.generate(5, (_) => _factory.createGroceryReceipt()),
      'Dining': List.generate(3, (_) => _factory.createRestaurantReceipt()),
      'Transportation': List.generate(2, (_) => _factory.createGasStationReceipt()),
    };
  }
}

// ============================================================================
// PERFORMANCE MONITORING
// ============================================================================

/// Monitors widget performance during tests
class PerformanceMonitor {
  final WidgetTester tester;
  final Map<String, List<Duration>> _metrics = {};

  PerformanceMonitor(this.tester);

  /// Starts timing an operation
  Stopwatch startTimer(String operation) {
    return Stopwatch()..start();
  }

  /// Records the duration of an operation
  void recordDuration(String operation, Stopwatch timer) {
    timer.stop();
    _metrics.putIfAbsent(operation, () => []).add(timer.elapsed);
  }

  /// Gets average duration for an operation
  Duration? getAverageDuration(String operation) {
    final durations = _metrics[operation];
    if (durations == null || durations.isEmpty) return null;

    final total = durations.reduce((a, b) => a + b);
    return total ~/ durations.length;
  }

  /// Prints performance report
  void printReport() {
    print('\n=== Performance Report ===');
    _metrics.forEach((operation, durations) {
      final avg = getAverageDuration(operation);
      final max = durations.reduce((a, b) => a > b ? a : b);
      final min = durations.reduce((a, b) => a < b ? a : b);

      print('$operation:');
      print('  Average: ${avg?.inMilliseconds}ms');
      print('  Min: ${min.inMilliseconds}ms');
      print('  Max: ${max.inMilliseconds}ms');
    });
    print('========================\n');
  }

  /// Verifies performance meets requirements
  void verifyPerformance({
    required Map<String, Duration> requirements,
  }) {
    requirements.forEach((operation, maxDuration) {
      final avg = getAverageDuration(operation);
      if (avg != null) {
        expect(
          avg,
          lessThanOrEqualTo(maxDuration),
          reason: '$operation average ${avg.inMilliseconds}ms exceeds '
              'requirement of ${maxDuration.inMilliseconds}ms',
        );
      }
    });
  }
}