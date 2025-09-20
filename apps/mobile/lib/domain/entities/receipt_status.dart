/// Receipt processing status enumeration
enum ReceiptStatus {
  /// Just captured, awaiting processing
  pending('Pending', 'Awaiting processing'),

  /// Image captured but not yet processed
  captured('Captured', 'Image captured'),

  /// Currently being processed (OCR, extraction)
  processing('Processing', 'Extracting data'),

  /// Successfully processed and ready
  processed('Processed', 'Ready to use'),

  /// Manually reviewed and verified
  reviewed('Reviewed', 'Manually reviewed'),

  /// Error during processing
  error('Error', 'Processing failed'),

  /// Exported to external system
  exported('Exported', 'Sent to external system'),

  /// Marked as deleted
  deleted('Deleted', 'Marked for deletion'),

  /// Archived/inactive
  archived('Archived', 'No longer active');

  final String displayName;
  final String description;

  const ReceiptStatus(this.displayName, this.description);

  /// Check if receipt can be edited
  bool get canEdit => this != archived;

  /// Check if receipt is in final state
  bool get isFinal => this == processed || this == reviewed || this == archived;

  /// Check if receipt needs attention
  bool get needsAttention => this == error || this == pending;
}

/// Payment method enumeration
enum PaymentMethod {
  cash('Cash', '💵'),
  creditCard('Credit Card', '💳'),
  debitCard('Debit Card', '💳'),
  check('Check', '📝'),
  bankTransfer('Bank Transfer', '🏦'),
  digitalWallet('Digital Wallet', '📱'),
  paypal('PayPal', '💰'),
  venmo('Venmo', '📲'),
  crypto('Cryptocurrency', '₿'),
  other('Other', '💸');

  final String displayName;
  final String icon;

  const PaymentMethod(this.displayName, this.icon);

  /// Parse from string
  static PaymentMethod fromString(String? value) {
    if (value == null) return PaymentMethod.other;

    final normalized = value.toLowerCase().replaceAll(RegExp(r'[_\s-]'), '');

    // Handle common variations
    switch (normalized) {
      case 'cash':
        return PaymentMethod.cash;
      case 'credit':
      case 'creditcard':
      case 'cc':
        return PaymentMethod.creditCard;
      case 'debit':
      case 'debitcard':
      case 'dc':
        return PaymentMethod.debitCard;
      case 'check':
      case 'cheque':
        return PaymentMethod.check;
      case 'banktransfer':
      case 'transfer':
      case 'wire':
        return PaymentMethod.bankTransfer;
      case 'digitalwallet':
      case 'applepay':
      case 'googlepay':
      case 'samsungpay':
        return PaymentMethod.digitalWallet;
      case 'paypal':
        return PaymentMethod.paypal;
      case 'venmo':
        return PaymentMethod.venmo;
      case 'crypto':
      case 'bitcoin':
      case 'cryptocurrency':
        return PaymentMethod.crypto;
      default:
        return PaymentMethod.other;
    }
  }
}