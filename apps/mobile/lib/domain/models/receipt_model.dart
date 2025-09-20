import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/receipt_id.dart';
import '../value_objects/money.dart';
import '../value_objects/category.dart';
import '../entities/receipt_status.dart';
import '../entities/receipt_item.dart';

part 'receipt_model.freezed.dart';
part 'receipt_model.g.dart';

/// Domain model for Receipt - Single source of truth
///
/// This is the ONLY receipt model used in business logic.
/// Data layer models are converted to/from this model via mappers.
@freezed
class ReceiptModel with _$ReceiptModel {
  const ReceiptModel._();

  const factory ReceiptModel({
    /// Unique identifier - always required
    required ReceiptId id,

    /// Creation timestamp - always required
    required DateTime createdAt,

    /// Processing status - always required
    required ReceiptStatus status,

    /// Image storage location - always required
    required String imagePath,

    /// Last modification timestamp
    required DateTime updatedAt,

    // ===== BUSINESS DATA - Nullable when truly unknown =====

    /// Merchant/vendor name from receipt
    String? merchant,

    /// Total amount including tax
    Money? totalAmount,

    /// Tax amount
    Money? taxAmount,

    /// Date on the receipt (not capture date)
    DateTime? purchaseDate,

    /// Business category
    Category? category,

    /// Payment method used
    PaymentMethod? paymentMethod,

    /// User notes
    String? notes,

    /// Business purpose/justification
    String? businessPurpose,

    /// Line items from receipt
    @Default([]) List<ReceiptItem> items,

    /// User-defined tags for organization
    @Default([]) List<String> tags,

    /// Whether this is marked as favorite
    @Default(false) bool isFavorite,

    /// Batch ID if part of batch capture
    String? batchId,

    /// OCR confidence score (0.0 to 1.0)
    double? ocrConfidence,

    /// Raw OCR text for reference
    String? ocrRawText,

    /// Error message if status is error
    String? errorMessage,

    /// Cloud storage URL if synced
    String? cloudStorageUrl,

    /// Whether this needs manual review
    @Default(false) bool needsReview,
  }) = _ReceiptModel;

  factory ReceiptModel.fromJson(Map<String, dynamic> json) =>
      _$ReceiptModelFromJson(json);

  /// Create a new receipt with minimal required data
  factory ReceiptModel.create({
    required String imagePath,
    String? batchId,
  }) {
    final now = DateTime.now();
    return ReceiptModel(
      id: ReceiptId.generate(),
      createdAt: now,
      updatedAt: now,
      status: ReceiptStatus.pending,
      imagePath: imagePath,
      batchId: batchId,
    );
  }

  /// Check if receipt has been processed
  bool get isProcessed => status == ReceiptStatus.processed;

  /// Check if receipt has an error
  bool get hasError => status == ReceiptStatus.error;

  /// Check if receipt is ready for use
  bool get isReady => status == ReceiptStatus.processed && !needsReview;

  /// Get display-friendly merchant name
  String get displayMerchant => merchant ?? 'Unknown Vendor';

  /// Get display-friendly amount
  String get displayAmount {
    if (totalAmount == null) return '--';
    return totalAmount!.display;
  }

  /// Get display-friendly date
  String get displayDate {
    final date = purchaseDate ?? createdAt;
    return '${date.month}/${date.day}/${date.year}';
  }

  /// Check if receipt has complete data
  bool get hasCompleteData {
    return merchant != null &&
           totalAmount != null &&
           purchaseDate != null &&
           category != null;
  }
}