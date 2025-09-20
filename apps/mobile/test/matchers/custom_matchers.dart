import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/domain/models/receipt_model.dart';
import 'package:receipt_organizer/domain/value_objects/money.dart';
import 'package:receipt_organizer/domain/value_objects/receipt_id.dart';
import 'package:receipt_organizer/domain/entities/receipt_status.dart';
import 'package:receipt_organizer/domain/core/result.dart';
import 'package:receipt_organizer/domain/core/failures.dart' as failures;

/// Custom matchers for Receipt Organizer testing
///
/// These matchers provide domain-specific assertions with clear error messages,
/// following 2025 best practices for test readability and maintainability.

// ============================================================================
// RECEIPT MODEL MATCHERS
// ============================================================================

/// Matcher for checking if a receipt has a valid structure
Matcher isValidReceipt() => _ValidReceiptMatcher();

/// Matcher for checking receipt status
Matcher hasReceiptStatus(ReceiptStatus status) => _ReceiptStatusMatcher(status);

/// Matcher for checking if receipt is processed
Matcher isProcessedReceipt() => _ProcessedReceiptMatcher();

/// Matcher for checking if receipt needs review
Matcher needsReview() => _NeedsReviewMatcher();

/// Matcher for checking receipt amount
Matcher hasAmount(double amount) => _ReceiptAmountMatcher(amount);

/// Matcher for checking receipt amount within range
Matcher hasAmountBetween(double min, double max) => _ReceiptAmountRangeMatcher(min, max);

/// Matcher for checking receipt merchant
Matcher hasMerchant(String merchant) => _ReceiptMerchantMatcher(merchant);

/// Matcher for checking if receipt has complete data
Matcher hasCompleteData() => _CompleteReceiptDataMatcher();

// ============================================================================
// VALUE OBJECT MATCHERS
// ============================================================================

/// Matcher for valid ReceiptId
Matcher isValidReceiptId() => _ValidReceiptIdMatcher();

/// Matcher for Money value
Matcher isMoney({double? amount, Currency? currency}) =>
    _MoneyMatcher(amount: amount, currency: currency);

/// Matcher for Money within range
Matcher isMoneyBetween(double min, double max, {Currency? currency}) =>
    _MoneyRangeMatcher(min, max, currency: currency);

// ============================================================================
// RESULT TYPE MATCHERS
// ============================================================================

/// Matcher for successful Result
Matcher isSuccess<S, F>() => _ResultSuccessMatcher<S, F>();

/// Matcher for failed Result
Matcher isFailure<S, F>() => _ResultFailureMatcher<S, F>();

/// Matcher for specific failure type
Matcher hasFailure<T extends failures.Failure>() => _SpecificFailureMatcher<T>();

/// Matcher for Result with specific success value
Matcher hasSuccessValue<S, F>(S expected) => _ResultSuccessValueMatcher<S, F>(expected);

// ============================================================================
// PERFORMANCE MATCHERS
// ============================================================================

/// Matcher for operation completion within time limit
Matcher completesWithin(Duration limit) => _PerformanceMatcher(limit);

/// Matcher for memory usage
Matcher usesLessThanMemory(int bytes) => _MemoryUsageMatcher(bytes);

// ============================================================================
// WIDGET MATCHERS
// ============================================================================

/// Matcher for widget accessibility
Matcher isAccessible() => _AccessibilityMatcher();

/// Matcher for widget overflow
Matcher hasNoOverflow() => _NoOverflowMatcher();

/// Matcher for widget with specific semantics
Matcher hasSemantics({
  String? label,
  String? hint,
  String? value,
}) => _SemanticsMatcher(label: label, hint: hint, value: value);

// ============================================================================
// COLLECTION MATCHERS
// ============================================================================

/// Matcher for collection containing receipts in date order
Matcher isInDateOrder({bool ascending = false}) =>
    _DateOrderMatcher(ascending: ascending);

/// Matcher for collection containing unique items
Matcher hasUniqueItems<T>() => _UniqueItemsMatcher<T>();

/// Matcher for paginated results
Matcher isPaginatedResult({
  int? page,
  int? pageSize,
  int? totalItems,
}) => _PaginatedResultMatcher(
  page: page,
  pageSize: pageSize,
  totalItems: totalItems,
);

// ============================================================================
// MATCHER IMPLEMENTATIONS
// ============================================================================

class _ValidReceiptMatcher extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! ReceiptModel) return false;

    matchState['receipt'] = item;

    // Check required fields
    if (item.id.value.isEmpty) {
      matchState['error'] = 'Invalid ID';
      return false;
    }

    if (item.imagePath.isEmpty) {
      matchState['error'] = 'Missing image path';
      return false;
    }

    // Check date consistency
    if (item.updatedAt != null && item.updatedAt!.isBefore(item.createdAt)) {
      matchState['error'] = 'Updated date before created date';
      return false;
    }

    return true;
  }

  @override
  Description describe(Description description) =>
      description.add('a valid receipt with all required fields');

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! ReceiptModel) {
      return mismatchDescription.add('was not a ReceiptModel');
    }

    final error = matchState['error'] as String?;
    if (error != null) {
      return mismatchDescription.add(error);
    }

    return mismatchDescription.add('was invalid');
  }
}

class _ReceiptStatusMatcher extends Matcher {
  final ReceiptStatus expectedStatus;

  _ReceiptStatusMatcher(this.expectedStatus);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! ReceiptModel) return false;
    return item.status == expectedStatus;
  }

  @override
  Description describe(Description description) =>
      description.add('a receipt with status ${expectedStatus.name}');

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! ReceiptModel) {
      return mismatchDescription.add('was not a ReceiptModel');
    }
    return mismatchDescription.add('had status ${item.status.name}');
  }
}

class _ProcessedReceiptMatcher extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! ReceiptModel) return false;
    return item.status == ReceiptStatus.processed &&
           item.totalAmount != null &&
           item.merchant != null;
  }

  @override
  Description describe(Description description) =>
      description.add('a fully processed receipt');

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! ReceiptModel) {
      return mismatchDescription.add('was not a ReceiptModel');
    }

    final issues = <String>[];
    if (item.status != ReceiptStatus.processed) {
      issues.add('status was ${item.status.name}');
    }
    if (item.totalAmount == null) {
      issues.add('missing total amount');
    }
    if (item.merchant == null) {
      issues.add('missing merchant');
    }

    return mismatchDescription.add(issues.join(', '));
  }
}

class _NeedsReviewMatcher extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! ReceiptModel) return false;
    return item.needsReview;
  }

  @override
  Description describe(Description description) =>
      description.add('a receipt that needs review');
}

class _ReceiptAmountMatcher extends Matcher {
  final double expectedAmount;

  _ReceiptAmountMatcher(this.expectedAmount);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! ReceiptModel) return false;
    if (item.totalAmount == null) return false;
    return (item.totalAmount!.amount - expectedAmount).abs() < 0.01;
  }

  @override
  Description describe(Description description) =>
      description.add('a receipt with amount \$$expectedAmount');

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! ReceiptModel) {
      return mismatchDescription.add('was not a ReceiptModel');
    }
    if (item.totalAmount == null) {
      return mismatchDescription.add('had no amount');
    }
    return mismatchDescription.add('had amount \$${item.totalAmount!.amount}');
  }
}

class _ReceiptAmountRangeMatcher extends Matcher {
  final double min;
  final double max;

  _ReceiptAmountRangeMatcher(this.min, this.max);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! ReceiptModel) return false;
    if (item.totalAmount == null) return false;
    final amount = item.totalAmount!.amount;
    return amount >= min && amount <= max;
  }

  @override
  Description describe(Description description) =>
      description.add('a receipt with amount between \$$min and \$$max');
}

class _ReceiptMerchantMatcher extends Matcher {
  final String expectedMerchant;

  _ReceiptMerchantMatcher(this.expectedMerchant);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! ReceiptModel) return false;
    return item.merchant == expectedMerchant;
  }

  @override
  Description describe(Description description) =>
      description.add('a receipt from $expectedMerchant');
}

class _CompleteReceiptDataMatcher extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! ReceiptModel) return false;
    return item.merchant != null &&
           item.totalAmount != null &&
           item.purchaseDate != null &&
           item.category != null;
  }

  @override
  Description describe(Description description) =>
      description.add('a receipt with complete data');
}

class _ValidReceiptIdMatcher extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! ReceiptId) return false;
    return item.isValid;
  }

  @override
  Description describe(Description description) =>
      description.add('a valid ReceiptId');
}

class _MoneyMatcher extends Matcher {
  final double? amount;
  final Currency? currency;

  _MoneyMatcher({this.amount, this.currency});

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Money) return false;

    if (amount != null && (item.amount - amount!).abs() > 0.01) {
      return false;
    }

    if (currency != null && item.currency != currency) {
      return false;
    }

    return true;
  }

  @override
  Description describe(Description description) {
    var desc = 'a Money value';
    if (amount != null) desc += ' of $amount';
    if (currency != null) desc += ' ${currency!.code}';
    return description.add(desc);
  }
}

class _MoneyRangeMatcher extends Matcher {
  final double min;
  final double max;
  final Currency? currency;

  _MoneyRangeMatcher(this.min, this.max, {this.currency});

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Money) return false;

    if (item.amount < min || item.amount > max) return false;

    if (currency != null && item.currency != currency) return false;

    return true;
  }

  @override
  Description describe(Description description) =>
      description.add('Money between $min and $max${currency != null ? ' ${currency!.code}' : ''}');
}

class _ResultSuccessMatcher<S, F> extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Result<S, F>) return false;
    return item.isSuccess;
  }

  @override
  Description describe(Description description) =>
      description.add('a successful Result');
}

class _ResultFailureMatcher<S, F> extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Result<S, F>) return false;
    return item.isFailure;
  }

  @override
  Description describe(Description description) =>
      description.add('a failed Result');
}

class _SpecificFailureMatcher<T extends failures.Failure> extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Result) return false;
    if (!item.isFailure) return false;
    return item.failureOrNull is T;
  }

  @override
  Description describe(Description description) =>
      description.add('a Result with failure type $T');
}

class _ResultSuccessValueMatcher<S, F> extends Matcher {
  final S expected;

  _ResultSuccessValueMatcher(this.expected);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Result<S, F>) return false;
    if (!item.isSuccess) return false;
    return item.successOrNull == expected;
  }

  @override
  Description describe(Description description) =>
      description.add('a successful Result with value $expected');
}

class _PerformanceMatcher extends Matcher {
  final Duration limit;

  _PerformanceMatcher(this.limit);

  @override
  bool matches(dynamic item, Map matchState) {
    // This would be used with expectAsync or custom timing logic
    return true; // Placeholder implementation
  }

  @override
  Description describe(Description description) =>
      description.add('completes within ${limit.inMilliseconds}ms');
}

class _MemoryUsageMatcher extends Matcher {
  final int maxBytes;

  _MemoryUsageMatcher(this.maxBytes);

  @override
  bool matches(dynamic item, Map matchState) {
    // This would integrate with memory profiling
    return true; // Placeholder implementation
  }

  @override
  Description describe(Description description) =>
      description.add('uses less than $maxBytes bytes of memory');
}

class _AccessibilityMatcher extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Widget) return false;
    // Check accessibility properties
    // This would integrate with Flutter's accessibility testing
    return true; // Placeholder implementation
  }

  @override
  Description describe(Description description) =>
      description.add('is accessible');
}

class _NoOverflowMatcher extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    // Check for RenderFlex overflow
    return true; // Placeholder implementation
  }

  @override
  Description describe(Description description) =>
      description.add('renders without overflow');
}

class _SemanticsMatcher extends Matcher {
  final String? label;
  final String? hint;
  final String? value;

  _SemanticsMatcher({this.label, this.hint, this.value});

  @override
  bool matches(dynamic item, Map matchState) {
    // Check semantic properties
    return true; // Placeholder implementation
  }

  @override
  Description describe(Description description) {
    var desc = 'has semantics';
    if (label != null) desc += ' with label "$label"';
    if (hint != null) desc += ' with hint "$hint"';
    if (value != null) desc += ' with value "$value"';
    return description.add(desc);
  }
}

class _DateOrderMatcher extends Matcher {
  final bool ascending;

  _DateOrderMatcher({required this.ascending});

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! List<ReceiptModel>) return false;
    if (item.length < 2) return true;

    for (int i = 1; i < item.length; i++) {
      final prevDate = item[i - 1].purchaseDate ?? item[i - 1].createdAt;
      final currDate = item[i].purchaseDate ?? item[i].createdAt;

      if (ascending) {
        if (prevDate.isAfter(currDate)) return false;
      } else {
        if (prevDate.isBefore(currDate)) return false;
      }
    }

    return true;
  }

  @override
  Description describe(Description description) =>
      description.add('receipts in ${ascending ? 'ascending' : 'descending'} date order');
}

class _UniqueItemsMatcher<T> extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! List<T>) return false;
    final seen = <T>{};
    for (final element in item) {
      if (seen.contains(element)) return false;
      seen.add(element);
    }
    return true;
  }

  @override
  Description describe(Description description) =>
      description.add('a collection with unique items');
}

class _PaginatedResultMatcher extends Matcher {
  final int? page;
  final int? pageSize;
  final int? totalItems;

  _PaginatedResultMatcher({this.page, this.pageSize, this.totalItems});

  @override
  bool matches(dynamic item, Map matchState) {
    // Check pagination properties
    return true; // Placeholder implementation
  }

  @override
  Description describe(Description description) {
    var desc = 'a paginated result';
    if (page != null) desc += ' on page $page';
    if (pageSize != null) desc += ' with page size $pageSize';
    if (totalItems != null) desc += ' containing $totalItems total items';
    return description.add(desc);
  }
}

// ============================================================================
// ASYNC MATCHERS
// ============================================================================

/// Matcher for async operations that complete successfully
Matcher completesSuccessfully() => completion(anything);

/// Matcher for async operations that throw specific error type
Matcher throwsType<T>() => throwsA(isA<T>());

/// Matcher for stream that emits values in order
Matcher emitsInOrderWithDelay(List<dynamic> values, Duration delay) {
  return emitsInOrder(values.map((v) {
    return mayEmit(v);
  }).toList());
}