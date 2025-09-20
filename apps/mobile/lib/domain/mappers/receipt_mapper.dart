import '../../data/models/receipt.dart' as data;
import '../models/receipt_model.dart';
import '../value_objects/receipt_id.dart';
import '../value_objects/money.dart';
import '../value_objects/category.dart';
import '../entities/receipt_status.dart' as domain;

/// Maps between domain and data layer receipt models
class ReceiptMapper {
  /// Convert data model to domain model
  static ReceiptModel toDomain(data.Receipt dataReceipt) {
    return ReceiptModel(
      id: ReceiptId.fromString(dataReceipt.id),
      createdAt: dataReceipt.createdAt ?? dataReceipt.capturedAt,
      updatedAt: dataReceipt.updatedAt ?? dataReceipt.lastModified,
      status: _mapStatus(dataReceipt.status),
      imagePath: dataReceipt.imageUri,

      // Optional fields
      merchant: dataReceipt.vendorName,
      totalAmount: dataReceipt.totalAmount != null
          ? Money.from(dataReceipt.totalAmount!, Currency.usd)
          : null,
      taxAmount: dataReceipt.taxAmount != null
          ? Money.from(dataReceipt.taxAmount!, Currency.usd)
          : null,
      purchaseDate: dataReceipt.receiptDate,
      category: dataReceipt.categoryId != null
          ? _mapCategory(dataReceipt.categoryId!)
          : null,
      paymentMethod: dataReceipt.paymentMethod != null
          ? _mapPaymentMethod(dataReceipt.paymentMethod!)
          : null,
      notes: dataReceipt.notes,
      tags: dataReceipt.tags ?? [],

      // OCR fields
      ocrConfidence: dataReceipt.ocrConfidence,
      ocrRawText: dataReceipt.ocrRawText,

      // Processing flags
      needsReview: dataReceipt.needsReview ?? false,

      // Business fields
      businessPurpose: dataReceipt.businessPurpose,

      // Other fields
      batchId: dataReceipt.batchId,
      cloudStorageUrl: dataReceipt.imageUrl,

      // Items - empty for now until we implement line items
      items: [],
    );
  }

  /// Convert domain model to data model
  static data.Receipt toData(ReceiptModel domainReceipt) {
    return data.Receipt(
      id: domainReceipt.id.value,
      capturedAt: domainReceipt.createdAt,
      createdAt: domainReceipt.createdAt,
      updatedAt: domainReceipt.updatedAt,
      lastModified: domainReceipt.updatedAt,
      status: _mapStatusToData(domainReceipt.status),

      // Vendor/merchant
      vendorName: domainReceipt.merchant,

      // Amounts
      totalAmount: domainReceipt.totalAmount?.amount,
      taxAmount: domainReceipt.taxAmount?.amount,
      tipAmount: null, // Not in domain model
      currency: domainReceipt.totalAmount?.currency.code ?? 'USD',

      // Receipt details
      receiptDate: domainReceipt.purchaseDate,
      categoryId: domainReceipt.category?.type.name,
      subcategory: domainReceipt.category?.subcategory,
      paymentMethod: domainReceipt.paymentMethod?.name,
      notes: domainReceipt.notes,
      tags: domainReceipt.tags.isNotEmpty ? domainReceipt.tags : null,

      // Storage
      imageUri: domainReceipt.imagePath,
      thumbnailUri: null, // Not in domain model
      imageUrl: domainReceipt.imagePath, // Duplicate for compatibility

      // OCR
      ocrConfidence: domainReceipt.ocrConfidence,
      ocrRawText: domainReceipt.ocrRawText,

      // Processing flags
      isProcessed: domainReceipt.isProcessed,
      needsReview: domainReceipt.needsReview,

      // Business
      businessPurpose: domainReceipt.businessPurpose,

      // Metadata
      batchId: domainReceipt.batchId,
      userId: null, // Not in domain model
      metadata: null, // Not in domain model

      // Sync status (not in domain model)
      syncStatus: 'synced',
    );
  }

  /// Map data status to domain status
  static domain.ReceiptStatus _mapStatus(data.ReceiptStatus dataStatus) {
    switch (dataStatus) {
      case data.ReceiptStatus.pending:
        return domain.ReceiptStatus.pending;
      case data.ReceiptStatus.captured:
        return domain.ReceiptStatus.captured;
      case data.ReceiptStatus.processing:
        return domain.ReceiptStatus.processing;
      case data.ReceiptStatus.ready:
        return domain.ReceiptStatus.processed;
      case data.ReceiptStatus.exported:
        return domain.ReceiptStatus.exported;
      case data.ReceiptStatus.error:
        return domain.ReceiptStatus.error;
    }
  }

  /// Map domain status to data status
  static data.ReceiptStatus _mapStatusToData(domain.ReceiptStatus domainStatus) {
    switch (domainStatus) {
      case domain.ReceiptStatus.pending:
        return data.ReceiptStatus.pending;
      case domain.ReceiptStatus.captured:
        return data.ReceiptStatus.captured;
      case domain.ReceiptStatus.processing:
        return data.ReceiptStatus.processing;
      case domain.ReceiptStatus.processed:
        return data.ReceiptStatus.ready;
      case domain.ReceiptStatus.reviewed:
        return data.ReceiptStatus.ready;
      case domain.ReceiptStatus.exported:
        return data.ReceiptStatus.exported;
      case domain.ReceiptStatus.error:
        return data.ReceiptStatus.error;
      case domain.ReceiptStatus.deleted:
      case domain.ReceiptStatus.archived:
        return data.ReceiptStatus.error;
    }
  }

  /// Map category string to domain Category
  static Category _mapCategory(String categoryId) {
    // Try to parse as CategoryType enum
    try {
      final type = CategoryType.values.firstWhere(
        (t) => t.name == categoryId,
        orElse: () => CategoryType.other,
      );
      return Category(type: type);
    } catch (_) {
      // If not a valid enum value, treat as custom category
      return Category(type: CategoryType.other, subcategory: categoryId);
    }
  }

  /// Map payment method string to domain PaymentMethod
  static domain.PaymentMethod _mapPaymentMethod(String method) {
    // Normalize the string
    final normalized = method.toLowerCase().replaceAll('_', '').replaceAll('-', '');

    if (normalized.contains('cash')) return domain.PaymentMethod.cash;
    if (normalized.contains('credit')) return domain.PaymentMethod.creditCard;
    if (normalized.contains('debit')) return domain.PaymentMethod.debitCard;
    if (normalized.contains('check') || normalized.contains('cheque')) {
      return domain.PaymentMethod.check;
    }
    if (normalized.contains('paypal')) return domain.PaymentMethod.paypal;
    if (normalized.contains('venmo')) return domain.PaymentMethod.venmo;
    if (normalized.contains('apple') || normalized.contains('google')) {
      return domain.PaymentMethod.digitalWallet;
    }
    if (normalized.contains('crypto') || normalized.contains('bitcoin')) {
      return domain.PaymentMethod.crypto;
    }
    if (normalized.contains('transfer') || normalized.contains('wire')) {
      return domain.PaymentMethod.bankTransfer;
    }

    return domain.PaymentMethod.other;
  }

  /// Batch convert data models to domain models
  static List<ReceiptModel> toDomainList(List<data.Receipt> dataReceipts) {
    return dataReceipts.map(toDomain).toList();
  }

  /// Batch convert domain models to data models
  static List<data.Receipt> toDataList(List<ReceiptModel> domainReceipts) {
    return domainReceipts.map(toData).toList();
  }
}