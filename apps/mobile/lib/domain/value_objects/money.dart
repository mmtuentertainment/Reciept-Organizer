import 'package:equatable/equatable.dart';

/// Currency enumeration
enum Currency {
  usd('USD', '\$', 2),
  eur('EUR', '€', 2),
  gbp('GBP', '£', 2),
  jpy('JPY', '¥', 0),
  cad('CAD', 'C\$', 2),
  aud('AUD', 'A\$', 2);

  final String code;
  final String symbol;
  final int decimalPlaces;

  const Currency(this.code, this.symbol, this.decimalPlaces);

  /// Format amount with currency symbol
  String format(double amount) {
    final formatted = amount.toStringAsFixed(decimalPlaces);
    return '$symbol$formatted';
  }
}

/// Value object representing money with currency
///
/// NEVER use double directly for money in domain logic!
/// This ensures precision and prevents floating point errors.
class Money extends Equatable {
  /// Amount stored in smallest currency unit (cents for USD)
  final int minorUnits;

  /// Currency of this money
  final Currency currency;

  const Money._({
    required this.minorUnits,
    required this.currency,
  });

  /// Create from major units (dollars, euros, etc.)
  factory Money.from(double amount, [Currency currency = Currency.usd]) {
    final multiplier = _getMultiplier(currency.decimalPlaces);
    final minorUnits = (amount * multiplier).round();
    return Money._(minorUnits: minorUnits, currency: currency);
  }

  /// Create from minor units (cents, pence, etc.)
  factory Money.fromMinorUnits(int minorUnits, [Currency currency = Currency.usd]) {
    return Money._(minorUnits: minorUnits, currency: currency);
  }

  /// Create zero money
  factory Money.zero([Currency currency = Currency.usd]) {
    return Money._(minorUnits: 0, currency: currency);
  }

  /// Parse from string (e.g., "12.34", "$12.34", "12,34")
  factory Money.parse(String value, [Currency currency = Currency.usd]) {
    // Remove currency symbols and spaces
    String cleaned = value.replaceAll(RegExp(r'[^\d.,\-]'), '');

    // Handle European format (comma as decimal separator)
    if (cleaned.contains(',') && !cleaned.contains('.')) {
      cleaned = cleaned.replaceAll(',', '.');
    } else if (cleaned.contains(',') && cleaned.contains('.')) {
      // Remove thousands separator
      cleaned = cleaned.replaceAll(',', '');
    }

    final amount = double.tryParse(cleaned) ?? 0.0;
    return Money.from(amount, currency);
  }

  /// Get amount in major units (dollars, euros, etc.)
  double get amount {
    final divisor = _getMultiplier(currency.decimalPlaces);
    return minorUnits / divisor;
  }

  /// Get display string with currency symbol
  String get display => currency.format(amount);

  /// Alias for display - formatted string with currency symbol
  String get formatted => display;

  /// Get display string without currency symbol
  String get displayAmount => amount.toStringAsFixed(currency.decimalPlaces);

  /// Get currency symbol
  String get symbol => currency.symbol;

  /// Check if zero
  bool get isZero => minorUnits == 0;

  /// Check if negative
  bool get isNegative => minorUnits < 0;

  /// Check if positive
  bool get isPositive => minorUnits > 0;

  /// Add two money values (must be same currency)
  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money._(
      minorUnits: minorUnits + other.minorUnits,
      currency: currency,
    );
  }

  /// Subtract two money values (must be same currency)
  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money._(
      minorUnits: minorUnits - other.minorUnits,
      currency: currency,
    );
  }

  /// Multiply by a scalar
  Money operator *(num multiplier) {
    return Money._(
      minorUnits: (minorUnits * multiplier).round(),
      currency: currency,
    );
  }

  /// Divide by a scalar
  Money operator /(num divisor) {
    if (divisor == 0) {
      throw ArgumentError('Cannot divide by zero');
    }
    return Money._(
      minorUnits: (minorUnits / divisor).round(),
      currency: currency,
    );
  }

  /// Compare money values
  bool operator >(Money other) {
    _assertSameCurrency(other);
    return minorUnits > other.minorUnits;
  }

  bool operator <(Money other) {
    _assertSameCurrency(other);
    return minorUnits < other.minorUnits;
  }

  bool operator >=(Money other) {
    _assertSameCurrency(other);
    return minorUnits >= other.minorUnits;
  }

  bool operator <=(Money other) {
    _assertSameCurrency(other);
    return minorUnits <= other.minorUnits;
  }

  /// Negate the amount
  Money operator -() {
    return Money._(minorUnits: -minorUnits, currency: currency);
  }

  /// Get absolute value
  Money abs() {
    return Money._(minorUnits: minorUnits.abs(), currency: currency);
  }

  /// Round to nearest major unit
  Money round() {
    final divisor = _getMultiplier(currency.decimalPlaces);
    final rounded = (minorUnits / divisor).round() * divisor;
    return Money._(minorUnits: rounded, currency: currency);
  }

  void _assertSameCurrency(Money other) {
    if (currency != other.currency) {
      throw ArgumentError(
        'Cannot perform operation on different currencies: '
        '${currency.code} and ${other.currency.code}',
      );
    }
  }

  static int _getMultiplier(int decimalPlaces) {
    int multiplier = 1;
    for (int i = 0; i < decimalPlaces; i++) {
      multiplier *= 10;
    }
    return multiplier;
  }

  @override
  List<Object?> get props => [minorUnits, currency];

  @override
  String toString() => display;

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'amount': amount,
    'currency': currency.code,
  };

  /// Create from JSON
  factory Money.fromJson(Map<String, dynamic> json) {
    final amount = (json['amount'] as num).toDouble();
    final currencyCode = json['currency'] as String? ?? 'USD';
    final currency = Currency.values.firstWhere(
      (c) => c.code == currencyCode,
      orElse: () => Currency.usd,
    );
    return Money.from(amount, currency);
  }
}