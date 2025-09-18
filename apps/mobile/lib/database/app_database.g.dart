// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ReceiptsTable extends Receipts
    with TableInfo<$ReceiptsTable, ReceiptEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceiptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUriMeta = const VerificationMeta(
    'imageUri',
  );
  @override
  late final GeneratedColumn<String> imageUri = GeneratedColumn<String>(
    'image_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailUriMeta = const VerificationMeta(
    'thumbnailUri',
  );
  @override
  late final GeneratedColumn<String> thumbnailUri = GeneratedColumn<String>(
    'thumbnail_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isProcessedMeta = const VerificationMeta(
    'isProcessed',
  );
  @override
  late final GeneratedColumn<bool> isProcessed = GeneratedColumn<bool>(
    'is_processed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_processed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _needsReviewMeta = const VerificationMeta(
    'needsReview',
  );
  @override
  late final GeneratedColumn<bool> needsReview = GeneratedColumn<bool>(
    'needs_review',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_review" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vendorNameMeta = const VerificationMeta(
    'vendorName',
  );
  @override
  late final GeneratedColumn<String> vendorName = GeneratedColumn<String>(
    'vendor_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptDateMeta = const VerificationMeta(
    'receiptDate',
  );
  @override
  late final GeneratedColumn<DateTime> receiptDate = GeneratedColumn<DateTime>(
    'receipt_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taxAmountMeta = const VerificationMeta(
    'taxAmount',
  );
  @override
  late final GeneratedColumn<double> taxAmount = GeneratedColumn<double>(
    'tax_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tipAmountMeta = const VerificationMeta(
    'tipAmount',
  );
  @override
  late final GeneratedColumn<double> tipAmount = GeneratedColumn<double>(
    'tip_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('USD'),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subcategoryMeta = const VerificationMeta(
    'subcategory',
  );
  @override
  late final GeneratedColumn<String> subcategory = GeneratedColumn<String>(
    'subcategory',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrConfidenceMeta = const VerificationMeta(
    'ocrConfidence',
  );
  @override
  late final GeneratedColumn<double> ocrConfidence = GeneratedColumn<double>(
    'ocr_confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrRawTextMeta = const VerificationMeta(
    'ocrRawText',
  );
  @override
  late final GeneratedColumn<String> ocrRawText = GeneratedColumn<String>(
    'ocr_raw_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrResultsJsonMeta = const VerificationMeta(
    'ocrResultsJson',
  );
  @override
  late final GeneratedColumn<String> ocrResultsJson = GeneratedColumn<String>(
    'ocr_results_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _businessPurposeMeta = const VerificationMeta(
    'businessPurpose',
  );
  @override
  late final GeneratedColumn<String> businessPurpose = GeneratedColumn<String>(
    'business_purpose',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    imageUri,
    thumbnailUri,
    imageUrl,
    capturedAt,
    lastModified,
    createdAt,
    updatedAt,
    status,
    isProcessed,
    needsReview,
    batchId,
    vendorName,
    receiptDate,
    totalAmount,
    taxAmount,
    tipAmount,
    currency,
    categoryId,
    subcategory,
    paymentMethod,
    ocrConfidence,
    ocrRawText,
    ocrResultsJson,
    businessPurpose,
    notes,
    tags,
    syncStatus,
    lastSyncAt,
    metadata,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receipts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReceiptEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('image_uri')) {
      context.handle(
        _imageUriMeta,
        imageUri.isAcceptableOrUnknown(data['image_uri']!, _imageUriMeta),
      );
    } else if (isInserting) {
      context.missing(_imageUriMeta);
    }
    if (data.containsKey('thumbnail_uri')) {
      context.handle(
        _thumbnailUriMeta,
        thumbnailUri.isAcceptableOrUnknown(
          data['thumbnail_uri']!,
          _thumbnailUriMeta,
        ),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('is_processed')) {
      context.handle(
        _isProcessedMeta,
        isProcessed.isAcceptableOrUnknown(
          data['is_processed']!,
          _isProcessedMeta,
        ),
      );
    }
    if (data.containsKey('needs_review')) {
      context.handle(
        _needsReviewMeta,
        needsReview.isAcceptableOrUnknown(
          data['needs_review']!,
          _needsReviewMeta,
        ),
      );
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    }
    if (data.containsKey('vendor_name')) {
      context.handle(
        _vendorNameMeta,
        vendorName.isAcceptableOrUnknown(data['vendor_name']!, _vendorNameMeta),
      );
    }
    if (data.containsKey('receipt_date')) {
      context.handle(
        _receiptDateMeta,
        receiptDate.isAcceptableOrUnknown(
          data['receipt_date']!,
          _receiptDateMeta,
        ),
      );
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    }
    if (data.containsKey('tax_amount')) {
      context.handle(
        _taxAmountMeta,
        taxAmount.isAcceptableOrUnknown(data['tax_amount']!, _taxAmountMeta),
      );
    }
    if (data.containsKey('tip_amount')) {
      context.handle(
        _tipAmountMeta,
        tipAmount.isAcceptableOrUnknown(data['tip_amount']!, _tipAmountMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('subcategory')) {
      context.handle(
        _subcategoryMeta,
        subcategory.isAcceptableOrUnknown(
          data['subcategory']!,
          _subcategoryMeta,
        ),
      );
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('ocr_confidence')) {
      context.handle(
        _ocrConfidenceMeta,
        ocrConfidence.isAcceptableOrUnknown(
          data['ocr_confidence']!,
          _ocrConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('ocr_raw_text')) {
      context.handle(
        _ocrRawTextMeta,
        ocrRawText.isAcceptableOrUnknown(
          data['ocr_raw_text']!,
          _ocrRawTextMeta,
        ),
      );
    }
    if (data.containsKey('ocr_results_json')) {
      context.handle(
        _ocrResultsJsonMeta,
        ocrResultsJson.isAcceptableOrUnknown(
          data['ocr_results_json']!,
          _ocrResultsJsonMeta,
        ),
      );
    }
    if (data.containsKey('business_purpose')) {
      context.handle(
        _businessPurposeMeta,
        businessPurpose.isAcceptableOrUnknown(
          data['business_purpose']!,
          _businessPurposeMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReceiptEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReceiptEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      imageUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_uri'],
      )!,
      thumbnailUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_uri'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      isProcessed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_processed'],
      )!,
      needsReview: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_review'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      ),
      vendorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vendor_name'],
      ),
      receiptDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}receipt_date'],
      ),
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      ),
      taxAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_amount'],
      ),
      tipAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tip_amount'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      subcategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subcategory'],
      ),
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      ),
      ocrConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ocr_confidence'],
      ),
      ocrRawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_raw_text'],
      ),
      ocrResultsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_results_json'],
      ),
      businessPurpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_purpose'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      ),
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      ),
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
    );
  }

  @override
  $ReceiptsTable createAlias(String alias) {
    return $ReceiptsTable(attachedDatabase, alias);
  }
}

class ReceiptEntity extends DataClass implements Insertable<ReceiptEntity> {
  final String id;
  final String? userId;
  final String imageUri;
  final String? thumbnailUri;
  final String? imageUrl;
  final DateTime capturedAt;
  final DateTime lastModified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;
  final bool isProcessed;
  final bool needsReview;
  final String? batchId;
  final String? vendorName;
  final DateTime? receiptDate;
  final double? totalAmount;
  final double? taxAmount;
  final double? tipAmount;
  final String currency;
  final String? categoryId;
  final String? subcategory;
  final String? paymentMethod;
  final double? ocrConfidence;
  final String? ocrRawText;
  final String? ocrResultsJson;
  final String? businessPurpose;
  final String? notes;
  final String? tags;
  final String? syncStatus;
  final DateTime? lastSyncAt;
  final String? metadata;
  const ReceiptEntity({
    required this.id,
    this.userId,
    required this.imageUri,
    this.thumbnailUri,
    this.imageUrl,
    required this.capturedAt,
    required this.lastModified,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.isProcessed,
    required this.needsReview,
    this.batchId,
    this.vendorName,
    this.receiptDate,
    this.totalAmount,
    this.taxAmount,
    this.tipAmount,
    required this.currency,
    this.categoryId,
    this.subcategory,
    this.paymentMethod,
    this.ocrConfidence,
    this.ocrRawText,
    this.ocrResultsJson,
    this.businessPurpose,
    this.notes,
    this.tags,
    this.syncStatus,
    this.lastSyncAt,
    this.metadata,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['image_uri'] = Variable<String>(imageUri);
    if (!nullToAbsent || thumbnailUri != null) {
      map['thumbnail_uri'] = Variable<String>(thumbnailUri);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['captured_at'] = Variable<DateTime>(capturedAt);
    map['last_modified'] = Variable<DateTime>(lastModified);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['status'] = Variable<String>(status);
    map['is_processed'] = Variable<bool>(isProcessed);
    map['needs_review'] = Variable<bool>(needsReview);
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<String>(batchId);
    }
    if (!nullToAbsent || vendorName != null) {
      map['vendor_name'] = Variable<String>(vendorName);
    }
    if (!nullToAbsent || receiptDate != null) {
      map['receipt_date'] = Variable<DateTime>(receiptDate);
    }
    if (!nullToAbsent || totalAmount != null) {
      map['total_amount'] = Variable<double>(totalAmount);
    }
    if (!nullToAbsent || taxAmount != null) {
      map['tax_amount'] = Variable<double>(taxAmount);
    }
    if (!nullToAbsent || tipAmount != null) {
      map['tip_amount'] = Variable<double>(tipAmount);
    }
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || subcategory != null) {
      map['subcategory'] = Variable<String>(subcategory);
    }
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(paymentMethod);
    }
    if (!nullToAbsent || ocrConfidence != null) {
      map['ocr_confidence'] = Variable<double>(ocrConfidence);
    }
    if (!nullToAbsent || ocrRawText != null) {
      map['ocr_raw_text'] = Variable<String>(ocrRawText);
    }
    if (!nullToAbsent || ocrResultsJson != null) {
      map['ocr_results_json'] = Variable<String>(ocrResultsJson);
    }
    if (!nullToAbsent || businessPurpose != null) {
      map['business_purpose'] = Variable<String>(businessPurpose);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    if (!nullToAbsent || syncStatus != null) {
      map['sync_status'] = Variable<String>(syncStatus);
    }
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    return map;
  }

  ReceiptsCompanion toCompanion(bool nullToAbsent) {
    return ReceiptsCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      imageUri: Value(imageUri),
      thumbnailUri: thumbnailUri == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUri),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      capturedAt: Value(capturedAt),
      lastModified: Value(lastModified),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      status: Value(status),
      isProcessed: Value(isProcessed),
      needsReview: Value(needsReview),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      vendorName: vendorName == null && nullToAbsent
          ? const Value.absent()
          : Value(vendorName),
      receiptDate: receiptDate == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptDate),
      totalAmount: totalAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(totalAmount),
      taxAmount: taxAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(taxAmount),
      tipAmount: tipAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(tipAmount),
      currency: Value(currency),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      subcategory: subcategory == null && nullToAbsent
          ? const Value.absent()
          : Value(subcategory),
      paymentMethod: paymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethod),
      ocrConfidence: ocrConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrConfidence),
      ocrRawText: ocrRawText == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrRawText),
      ocrResultsJson: ocrResultsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrResultsJson),
      businessPurpose: businessPurpose == null && nullToAbsent
          ? const Value.absent()
          : Value(businessPurpose),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      syncStatus: syncStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(syncStatus),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
    );
  }

  factory ReceiptEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReceiptEntity(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      imageUri: serializer.fromJson<String>(json['imageUri']),
      thumbnailUri: serializer.fromJson<String?>(json['thumbnailUri']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      status: serializer.fromJson<String>(json['status']),
      isProcessed: serializer.fromJson<bool>(json['isProcessed']),
      needsReview: serializer.fromJson<bool>(json['needsReview']),
      batchId: serializer.fromJson<String?>(json['batchId']),
      vendorName: serializer.fromJson<String?>(json['vendorName']),
      receiptDate: serializer.fromJson<DateTime?>(json['receiptDate']),
      totalAmount: serializer.fromJson<double?>(json['totalAmount']),
      taxAmount: serializer.fromJson<double?>(json['taxAmount']),
      tipAmount: serializer.fromJson<double?>(json['tipAmount']),
      currency: serializer.fromJson<String>(json['currency']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      subcategory: serializer.fromJson<String?>(json['subcategory']),
      paymentMethod: serializer.fromJson<String?>(json['paymentMethod']),
      ocrConfidence: serializer.fromJson<double?>(json['ocrConfidence']),
      ocrRawText: serializer.fromJson<String?>(json['ocrRawText']),
      ocrResultsJson: serializer.fromJson<String?>(json['ocrResultsJson']),
      businessPurpose: serializer.fromJson<String?>(json['businessPurpose']),
      notes: serializer.fromJson<String?>(json['notes']),
      tags: serializer.fromJson<String?>(json['tags']),
      syncStatus: serializer.fromJson<String?>(json['syncStatus']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      metadata: serializer.fromJson<String?>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'imageUri': serializer.toJson<String>(imageUri),
      'thumbnailUri': serializer.toJson<String?>(thumbnailUri),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'lastModified': serializer.toJson<DateTime>(lastModified),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'status': serializer.toJson<String>(status),
      'isProcessed': serializer.toJson<bool>(isProcessed),
      'needsReview': serializer.toJson<bool>(needsReview),
      'batchId': serializer.toJson<String?>(batchId),
      'vendorName': serializer.toJson<String?>(vendorName),
      'receiptDate': serializer.toJson<DateTime?>(receiptDate),
      'totalAmount': serializer.toJson<double?>(totalAmount),
      'taxAmount': serializer.toJson<double?>(taxAmount),
      'tipAmount': serializer.toJson<double?>(tipAmount),
      'currency': serializer.toJson<String>(currency),
      'categoryId': serializer.toJson<String?>(categoryId),
      'subcategory': serializer.toJson<String?>(subcategory),
      'paymentMethod': serializer.toJson<String?>(paymentMethod),
      'ocrConfidence': serializer.toJson<double?>(ocrConfidence),
      'ocrRawText': serializer.toJson<String?>(ocrRawText),
      'ocrResultsJson': serializer.toJson<String?>(ocrResultsJson),
      'businessPurpose': serializer.toJson<String?>(businessPurpose),
      'notes': serializer.toJson<String?>(notes),
      'tags': serializer.toJson<String?>(tags),
      'syncStatus': serializer.toJson<String?>(syncStatus),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'metadata': serializer.toJson<String?>(metadata),
    };
  }

  ReceiptEntity copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
    String? imageUri,
    Value<String?> thumbnailUri = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    DateTime? capturedAt,
    DateTime? lastModified,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    bool? isProcessed,
    bool? needsReview,
    Value<String?> batchId = const Value.absent(),
    Value<String?> vendorName = const Value.absent(),
    Value<DateTime?> receiptDate = const Value.absent(),
    Value<double?> totalAmount = const Value.absent(),
    Value<double?> taxAmount = const Value.absent(),
    Value<double?> tipAmount = const Value.absent(),
    String? currency,
    Value<String?> categoryId = const Value.absent(),
    Value<String?> subcategory = const Value.absent(),
    Value<String?> paymentMethod = const Value.absent(),
    Value<double?> ocrConfidence = const Value.absent(),
    Value<String?> ocrRawText = const Value.absent(),
    Value<String?> ocrResultsJson = const Value.absent(),
    Value<String?> businessPurpose = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> tags = const Value.absent(),
    Value<String?> syncStatus = const Value.absent(),
    Value<DateTime?> lastSyncAt = const Value.absent(),
    Value<String?> metadata = const Value.absent(),
  }) => ReceiptEntity(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    imageUri: imageUri ?? this.imageUri,
    thumbnailUri: thumbnailUri.present ? thumbnailUri.value : this.thumbnailUri,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    capturedAt: capturedAt ?? this.capturedAt,
    lastModified: lastModified ?? this.lastModified,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    status: status ?? this.status,
    isProcessed: isProcessed ?? this.isProcessed,
    needsReview: needsReview ?? this.needsReview,
    batchId: batchId.present ? batchId.value : this.batchId,
    vendorName: vendorName.present ? vendorName.value : this.vendorName,
    receiptDate: receiptDate.present ? receiptDate.value : this.receiptDate,
    totalAmount: totalAmount.present ? totalAmount.value : this.totalAmount,
    taxAmount: taxAmount.present ? taxAmount.value : this.taxAmount,
    tipAmount: tipAmount.present ? tipAmount.value : this.tipAmount,
    currency: currency ?? this.currency,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    subcategory: subcategory.present ? subcategory.value : this.subcategory,
    paymentMethod: paymentMethod.present
        ? paymentMethod.value
        : this.paymentMethod,
    ocrConfidence: ocrConfidence.present
        ? ocrConfidence.value
        : this.ocrConfidence,
    ocrRawText: ocrRawText.present ? ocrRawText.value : this.ocrRawText,
    ocrResultsJson: ocrResultsJson.present
        ? ocrResultsJson.value
        : this.ocrResultsJson,
    businessPurpose: businessPurpose.present
        ? businessPurpose.value
        : this.businessPurpose,
    notes: notes.present ? notes.value : this.notes,
    tags: tags.present ? tags.value : this.tags,
    syncStatus: syncStatus.present ? syncStatus.value : this.syncStatus,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
    metadata: metadata.present ? metadata.value : this.metadata,
  );
  ReceiptEntity copyWithCompanion(ReceiptsCompanion data) {
    return ReceiptEntity(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      imageUri: data.imageUri.present ? data.imageUri.value : this.imageUri,
      thumbnailUri: data.thumbnailUri.present
          ? data.thumbnailUri.value
          : this.thumbnailUri,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      status: data.status.present ? data.status.value : this.status,
      isProcessed: data.isProcessed.present
          ? data.isProcessed.value
          : this.isProcessed,
      needsReview: data.needsReview.present
          ? data.needsReview.value
          : this.needsReview,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      vendorName: data.vendorName.present
          ? data.vendorName.value
          : this.vendorName,
      receiptDate: data.receiptDate.present
          ? data.receiptDate.value
          : this.receiptDate,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      taxAmount: data.taxAmount.present ? data.taxAmount.value : this.taxAmount,
      tipAmount: data.tipAmount.present ? data.tipAmount.value : this.tipAmount,
      currency: data.currency.present ? data.currency.value : this.currency,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      subcategory: data.subcategory.present
          ? data.subcategory.value
          : this.subcategory,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      ocrConfidence: data.ocrConfidence.present
          ? data.ocrConfidence.value
          : this.ocrConfidence,
      ocrRawText: data.ocrRawText.present
          ? data.ocrRawText.value
          : this.ocrRawText,
      ocrResultsJson: data.ocrResultsJson.present
          ? data.ocrResultsJson.value
          : this.ocrResultsJson,
      businessPurpose: data.businessPurpose.present
          ? data.businessPurpose.value
          : this.businessPurpose,
      notes: data.notes.present ? data.notes.value : this.notes,
      tags: data.tags.present ? data.tags.value : this.tags,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptEntity(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('imageUri: $imageUri, ')
          ..write('thumbnailUri: $thumbnailUri, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('lastModified: $lastModified, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('status: $status, ')
          ..write('isProcessed: $isProcessed, ')
          ..write('needsReview: $needsReview, ')
          ..write('batchId: $batchId, ')
          ..write('vendorName: $vendorName, ')
          ..write('receiptDate: $receiptDate, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('tipAmount: $tipAmount, ')
          ..write('currency: $currency, ')
          ..write('categoryId: $categoryId, ')
          ..write('subcategory: $subcategory, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('ocrConfidence: $ocrConfidence, ')
          ..write('ocrRawText: $ocrRawText, ')
          ..write('ocrResultsJson: $ocrResultsJson, ')
          ..write('businessPurpose: $businessPurpose, ')
          ..write('notes: $notes, ')
          ..write('tags: $tags, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    userId,
    imageUri,
    thumbnailUri,
    imageUrl,
    capturedAt,
    lastModified,
    createdAt,
    updatedAt,
    status,
    isProcessed,
    needsReview,
    batchId,
    vendorName,
    receiptDate,
    totalAmount,
    taxAmount,
    tipAmount,
    currency,
    categoryId,
    subcategory,
    paymentMethod,
    ocrConfidence,
    ocrRawText,
    ocrResultsJson,
    businessPurpose,
    notes,
    tags,
    syncStatus,
    lastSyncAt,
    metadata,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReceiptEntity &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.imageUri == this.imageUri &&
          other.thumbnailUri == this.thumbnailUri &&
          other.imageUrl == this.imageUrl &&
          other.capturedAt == this.capturedAt &&
          other.lastModified == this.lastModified &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.status == this.status &&
          other.isProcessed == this.isProcessed &&
          other.needsReview == this.needsReview &&
          other.batchId == this.batchId &&
          other.vendorName == this.vendorName &&
          other.receiptDate == this.receiptDate &&
          other.totalAmount == this.totalAmount &&
          other.taxAmount == this.taxAmount &&
          other.tipAmount == this.tipAmount &&
          other.currency == this.currency &&
          other.categoryId == this.categoryId &&
          other.subcategory == this.subcategory &&
          other.paymentMethod == this.paymentMethod &&
          other.ocrConfidence == this.ocrConfidence &&
          other.ocrRawText == this.ocrRawText &&
          other.ocrResultsJson == this.ocrResultsJson &&
          other.businessPurpose == this.businessPurpose &&
          other.notes == this.notes &&
          other.tags == this.tags &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncAt == this.lastSyncAt &&
          other.metadata == this.metadata);
}

class ReceiptsCompanion extends UpdateCompanion<ReceiptEntity> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String> imageUri;
  final Value<String?> thumbnailUri;
  final Value<String?> imageUrl;
  final Value<DateTime> capturedAt;
  final Value<DateTime> lastModified;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> status;
  final Value<bool> isProcessed;
  final Value<bool> needsReview;
  final Value<String?> batchId;
  final Value<String?> vendorName;
  final Value<DateTime?> receiptDate;
  final Value<double?> totalAmount;
  final Value<double?> taxAmount;
  final Value<double?> tipAmount;
  final Value<String> currency;
  final Value<String?> categoryId;
  final Value<String?> subcategory;
  final Value<String?> paymentMethod;
  final Value<double?> ocrConfidence;
  final Value<String?> ocrRawText;
  final Value<String?> ocrResultsJson;
  final Value<String?> businessPurpose;
  final Value<String?> notes;
  final Value<String?> tags;
  final Value<String?> syncStatus;
  final Value<DateTime?> lastSyncAt;
  final Value<String?> metadata;
  final Value<int> rowid;
  const ReceiptsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.imageUri = const Value.absent(),
    this.thumbnailUri = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.isProcessed = const Value.absent(),
    this.needsReview = const Value.absent(),
    this.batchId = const Value.absent(),
    this.vendorName = const Value.absent(),
    this.receiptDate = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.tipAmount = const Value.absent(),
    this.currency = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.subcategory = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.ocrConfidence = const Value.absent(),
    this.ocrRawText = const Value.absent(),
    this.ocrResultsJson = const Value.absent(),
    this.businessPurpose = const Value.absent(),
    this.notes = const Value.absent(),
    this.tags = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReceiptsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String imageUri,
    this.thumbnailUri = const Value.absent(),
    this.imageUrl = const Value.absent(),
    required DateTime capturedAt,
    required DateTime lastModified,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String status,
    this.isProcessed = const Value.absent(),
    this.needsReview = const Value.absent(),
    this.batchId = const Value.absent(),
    this.vendorName = const Value.absent(),
    this.receiptDate = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.tipAmount = const Value.absent(),
    this.currency = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.subcategory = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.ocrConfidence = const Value.absent(),
    this.ocrRawText = const Value.absent(),
    this.ocrResultsJson = const Value.absent(),
    this.businessPurpose = const Value.absent(),
    this.notes = const Value.absent(),
    this.tags = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       imageUri = Value(imageUri),
       capturedAt = Value(capturedAt),
       lastModified = Value(lastModified),
       status = Value(status);
  static Insertable<ReceiptEntity> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? imageUri,
    Expression<String>? thumbnailUri,
    Expression<String>? imageUrl,
    Expression<DateTime>? capturedAt,
    Expression<DateTime>? lastModified,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? status,
    Expression<bool>? isProcessed,
    Expression<bool>? needsReview,
    Expression<String>? batchId,
    Expression<String>? vendorName,
    Expression<DateTime>? receiptDate,
    Expression<double>? totalAmount,
    Expression<double>? taxAmount,
    Expression<double>? tipAmount,
    Expression<String>? currency,
    Expression<String>? categoryId,
    Expression<String>? subcategory,
    Expression<String>? paymentMethod,
    Expression<double>? ocrConfidence,
    Expression<String>? ocrRawText,
    Expression<String>? ocrResultsJson,
    Expression<String>? businessPurpose,
    Expression<String>? notes,
    Expression<String>? tags,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncAt,
    Expression<String>? metadata,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (imageUri != null) 'image_uri': imageUri,
      if (thumbnailUri != null) 'thumbnail_uri': thumbnailUri,
      if (imageUrl != null) 'image_url': imageUrl,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (lastModified != null) 'last_modified': lastModified,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (status != null) 'status': status,
      if (isProcessed != null) 'is_processed': isProcessed,
      if (needsReview != null) 'needs_review': needsReview,
      if (batchId != null) 'batch_id': batchId,
      if (vendorName != null) 'vendor_name': vendorName,
      if (receiptDate != null) 'receipt_date': receiptDate,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (taxAmount != null) 'tax_amount': taxAmount,
      if (tipAmount != null) 'tip_amount': tipAmount,
      if (currency != null) 'currency': currency,
      if (categoryId != null) 'category_id': categoryId,
      if (subcategory != null) 'subcategory': subcategory,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (ocrConfidence != null) 'ocr_confidence': ocrConfidence,
      if (ocrRawText != null) 'ocr_raw_text': ocrRawText,
      if (ocrResultsJson != null) 'ocr_results_json': ocrResultsJson,
      if (businessPurpose != null) 'business_purpose': businessPurpose,
      if (notes != null) 'notes': notes,
      if (tags != null) 'tags': tags,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (metadata != null) 'metadata': metadata,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReceiptsCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String>? imageUri,
    Value<String?>? thumbnailUri,
    Value<String?>? imageUrl,
    Value<DateTime>? capturedAt,
    Value<DateTime>? lastModified,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? status,
    Value<bool>? isProcessed,
    Value<bool>? needsReview,
    Value<String?>? batchId,
    Value<String?>? vendorName,
    Value<DateTime?>? receiptDate,
    Value<double?>? totalAmount,
    Value<double?>? taxAmount,
    Value<double?>? tipAmount,
    Value<String>? currency,
    Value<String?>? categoryId,
    Value<String?>? subcategory,
    Value<String?>? paymentMethod,
    Value<double?>? ocrConfidence,
    Value<String?>? ocrRawText,
    Value<String?>? ocrResultsJson,
    Value<String?>? businessPurpose,
    Value<String?>? notes,
    Value<String?>? tags,
    Value<String?>? syncStatus,
    Value<DateTime?>? lastSyncAt,
    Value<String?>? metadata,
    Value<int>? rowid,
  }) {
    return ReceiptsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUri: imageUri ?? this.imageUri,
      thumbnailUri: thumbnailUri ?? this.thumbnailUri,
      imageUrl: imageUrl ?? this.imageUrl,
      capturedAt: capturedAt ?? this.capturedAt,
      lastModified: lastModified ?? this.lastModified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      isProcessed: isProcessed ?? this.isProcessed,
      needsReview: needsReview ?? this.needsReview,
      batchId: batchId ?? this.batchId,
      vendorName: vendorName ?? this.vendorName,
      receiptDate: receiptDate ?? this.receiptDate,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      tipAmount: tipAmount ?? this.tipAmount,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      subcategory: subcategory ?? this.subcategory,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      ocrConfidence: ocrConfidence ?? this.ocrConfidence,
      ocrRawText: ocrRawText ?? this.ocrRawText,
      ocrResultsJson: ocrResultsJson ?? this.ocrResultsJson,
      businessPurpose: businessPurpose ?? this.businessPurpose,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      metadata: metadata ?? this.metadata,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (imageUri.present) {
      map['image_uri'] = Variable<String>(imageUri.value);
    }
    if (thumbnailUri.present) {
      map['thumbnail_uri'] = Variable<String>(thumbnailUri.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isProcessed.present) {
      map['is_processed'] = Variable<bool>(isProcessed.value);
    }
    if (needsReview.present) {
      map['needs_review'] = Variable<bool>(needsReview.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (vendorName.present) {
      map['vendor_name'] = Variable<String>(vendorName.value);
    }
    if (receiptDate.present) {
      map['receipt_date'] = Variable<DateTime>(receiptDate.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (taxAmount.present) {
      map['tax_amount'] = Variable<double>(taxAmount.value);
    }
    if (tipAmount.present) {
      map['tip_amount'] = Variable<double>(tipAmount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (subcategory.present) {
      map['subcategory'] = Variable<String>(subcategory.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (ocrConfidence.present) {
      map['ocr_confidence'] = Variable<double>(ocrConfidence.value);
    }
    if (ocrRawText.present) {
      map['ocr_raw_text'] = Variable<String>(ocrRawText.value);
    }
    if (ocrResultsJson.present) {
      map['ocr_results_json'] = Variable<String>(ocrResultsJson.value);
    }
    if (businessPurpose.present) {
      map['business_purpose'] = Variable<String>(businessPurpose.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('imageUri: $imageUri, ')
          ..write('thumbnailUri: $thumbnailUri, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('lastModified: $lastModified, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('status: $status, ')
          ..write('isProcessed: $isProcessed, ')
          ..write('needsReview: $needsReview, ')
          ..write('batchId: $batchId, ')
          ..write('vendorName: $vendorName, ')
          ..write('receiptDate: $receiptDate, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('tipAmount: $tipAmount, ')
          ..write('currency: $currency, ')
          ..write('categoryId: $categoryId, ')
          ..write('subcategory: $subcategory, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('ocrConfidence: $ocrConfidence, ')
          ..write('ocrRawText: $ocrRawText, ')
          ..write('ocrResultsJson: $ocrResultsJson, ')
          ..write('businessPurpose: $businessPurpose, ')
          ..write('notes: $notes, ')
          ..write('tags: $tags, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('metadata: $metadata, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QueueEntriesTable extends QueueEntries
    with TableInfo<$QueueEntriesTable, QueueEntryEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endpointMeta = const VerificationMeta(
    'endpoint',
  );
  @override
  late final GeneratedColumn<String> endpoint = GeneratedColumn<String>(
    'endpoint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _headersMeta = const VerificationMeta(
    'headers',
  );
  @override
  late final GeneratedColumn<String> headers = GeneratedColumn<String>(
    'headers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxRetriesMeta = const VerificationMeta(
    'maxRetries',
  );
  @override
  late final GeneratedColumn<int> maxRetries = GeneratedColumn<int>(
    'max_retries',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _featureMeta = const VerificationMeta(
    'feature',
  );
  @override
  late final GeneratedColumn<String> feature = GeneratedColumn<String>(
    'feature',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    endpoint,
    method,
    headers,
    body,
    createdAt,
    lastAttemptAt,
    retryCount,
    maxRetries,
    status,
    errorMessage,
    feature,
    userId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueueEntryEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('endpoint')) {
      context.handle(
        _endpointMeta,
        endpoint.isAcceptableOrUnknown(data['endpoint']!, _endpointMeta),
      );
    } else if (isInserting) {
      context.missing(_endpointMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('headers')) {
      context.handle(
        _headersMeta,
        headers.isAcceptableOrUnknown(data['headers']!, _headersMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('max_retries')) {
      context.handle(
        _maxRetriesMeta,
        maxRetries.isAcceptableOrUnknown(data['max_retries']!, _maxRetriesMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('feature')) {
      context.handle(
        _featureMeta,
        feature.isAcceptableOrUnknown(data['feature']!, _featureMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueueEntryEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueEntryEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      endpoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endpoint'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      headers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}headers'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      maxRetries: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_retries'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      feature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feature'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
    );
  }

  @override
  $QueueEntriesTable createAlias(String alias) {
    return $QueueEntriesTable(attachedDatabase, alias);
  }
}

class QueueEntryEntity extends DataClass
    implements Insertable<QueueEntryEntity> {
  final String id;
  final String endpoint;
  final String method;
  final String headers;
  final String? body;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  final int retryCount;
  final int maxRetries;
  final String status;
  final String? errorMessage;
  final String? feature;
  final String? userId;
  const QueueEntryEntity({
    required this.id,
    required this.endpoint,
    required this.method,
    required this.headers,
    this.body,
    required this.createdAt,
    this.lastAttemptAt,
    required this.retryCount,
    required this.maxRetries,
    required this.status,
    this.errorMessage,
    this.feature,
    this.userId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['endpoint'] = Variable<String>(endpoint);
    map['method'] = Variable<String>(method);
    map['headers'] = Variable<String>(headers);
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    map['retry_count'] = Variable<int>(retryCount);
    map['max_retries'] = Variable<int>(maxRetries);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || feature != null) {
      map['feature'] = Variable<String>(feature);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    return map;
  }

  QueueEntriesCompanion toCompanion(bool nullToAbsent) {
    return QueueEntriesCompanion(
      id: Value(id),
      endpoint: Value(endpoint),
      method: Value(method),
      headers: Value(headers),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      createdAt: Value(createdAt),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      retryCount: Value(retryCount),
      maxRetries: Value(maxRetries),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      feature: feature == null && nullToAbsent
          ? const Value.absent()
          : Value(feature),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
    );
  }

  factory QueueEntryEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueEntryEntity(
      id: serializer.fromJson<String>(json['id']),
      endpoint: serializer.fromJson<String>(json['endpoint']),
      method: serializer.fromJson<String>(json['method']),
      headers: serializer.fromJson<String>(json['headers']),
      body: serializer.fromJson<String?>(json['body']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      maxRetries: serializer.fromJson<int>(json['maxRetries']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      feature: serializer.fromJson<String?>(json['feature']),
      userId: serializer.fromJson<String?>(json['userId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'endpoint': serializer.toJson<String>(endpoint),
      'method': serializer.toJson<String>(method),
      'headers': serializer.toJson<String>(headers),
      'body': serializer.toJson<String?>(body),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'maxRetries': serializer.toJson<int>(maxRetries),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'feature': serializer.toJson<String?>(feature),
      'userId': serializer.toJson<String?>(userId),
    };
  }

  QueueEntryEntity copyWith({
    String? id,
    String? endpoint,
    String? method,
    String? headers,
    Value<String?> body = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    int? retryCount,
    int? maxRetries,
    String? status,
    Value<String?> errorMessage = const Value.absent(),
    Value<String?> feature = const Value.absent(),
    Value<String?> userId = const Value.absent(),
  }) => QueueEntryEntity(
    id: id ?? this.id,
    endpoint: endpoint ?? this.endpoint,
    method: method ?? this.method,
    headers: headers ?? this.headers,
    body: body.present ? body.value : this.body,
    createdAt: createdAt ?? this.createdAt,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    retryCount: retryCount ?? this.retryCount,
    maxRetries: maxRetries ?? this.maxRetries,
    status: status ?? this.status,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    feature: feature.present ? feature.value : this.feature,
    userId: userId.present ? userId.value : this.userId,
  );
  QueueEntryEntity copyWithCompanion(QueueEntriesCompanion data) {
    return QueueEntryEntity(
      id: data.id.present ? data.id.value : this.id,
      endpoint: data.endpoint.present ? data.endpoint.value : this.endpoint,
      method: data.method.present ? data.method.value : this.method,
      headers: data.headers.present ? data.headers.value : this.headers,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      maxRetries: data.maxRetries.present
          ? data.maxRetries.value
          : this.maxRetries,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      feature: data.feature.present ? data.feature.value : this.feature,
      userId: data.userId.present ? data.userId.value : this.userId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueEntryEntity(')
          ..write('id: $id, ')
          ..write('endpoint: $endpoint, ')
          ..write('method: $method, ')
          ..write('headers: $headers, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('maxRetries: $maxRetries, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('feature: $feature, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    endpoint,
    method,
    headers,
    body,
    createdAt,
    lastAttemptAt,
    retryCount,
    maxRetries,
    status,
    errorMessage,
    feature,
    userId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueEntryEntity &&
          other.id == this.id &&
          other.endpoint == this.endpoint &&
          other.method == this.method &&
          other.headers == this.headers &&
          other.body == this.body &&
          other.createdAt == this.createdAt &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.retryCount == this.retryCount &&
          other.maxRetries == this.maxRetries &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage &&
          other.feature == this.feature &&
          other.userId == this.userId);
}

class QueueEntriesCompanion extends UpdateCompanion<QueueEntryEntity> {
  final Value<String> id;
  final Value<String> endpoint;
  final Value<String> method;
  final Value<String> headers;
  final Value<String?> body;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastAttemptAt;
  final Value<int> retryCount;
  final Value<int> maxRetries;
  final Value<String> status;
  final Value<String?> errorMessage;
  final Value<String?> feature;
  final Value<String?> userId;
  final Value<int> rowid;
  const QueueEntriesCompanion({
    this.id = const Value.absent(),
    this.endpoint = const Value.absent(),
    this.method = const Value.absent(),
    this.headers = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.maxRetries = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.feature = const Value.absent(),
    this.userId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QueueEntriesCompanion.insert({
    required String id,
    required String endpoint,
    required String method,
    this.headers = const Value.absent(),
    this.body = const Value.absent(),
    required DateTime createdAt,
    this.lastAttemptAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.maxRetries = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.feature = const Value.absent(),
    this.userId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       endpoint = Value(endpoint),
       method = Value(method),
       createdAt = Value(createdAt);
  static Insertable<QueueEntryEntity> custom({
    Expression<String>? id,
    Expression<String>? endpoint,
    Expression<String>? method,
    Expression<String>? headers,
    Expression<String>? body,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastAttemptAt,
    Expression<int>? retryCount,
    Expression<int>? maxRetries,
    Expression<String>? status,
    Expression<String>? errorMessage,
    Expression<String>? feature,
    Expression<String>? userId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (endpoint != null) 'endpoint': endpoint,
      if (method != null) 'method': method,
      if (headers != null) 'headers': headers,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (maxRetries != null) 'max_retries': maxRetries,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
      if (feature != null) 'feature': feature,
      if (userId != null) 'user_id': userId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QueueEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? endpoint,
    Value<String>? method,
    Value<String>? headers,
    Value<String?>? body,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastAttemptAt,
    Value<int>? retryCount,
    Value<int>? maxRetries,
    Value<String>? status,
    Value<String?>? errorMessage,
    Value<String?>? feature,
    Value<String?>? userId,
    Value<int>? rowid,
  }) {
    return QueueEntriesCompanion(
      id: id ?? this.id,
      endpoint: endpoint ?? this.endpoint,
      method: method ?? this.method,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      feature: feature ?? this.feature,
      userId: userId ?? this.userId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (endpoint.present) {
      map['endpoint'] = Variable<String>(endpoint.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (headers.present) {
      map['headers'] = Variable<String>(headers.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (maxRetries.present) {
      map['max_retries'] = Variable<int>(maxRetries.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (feature.present) {
      map['feature'] = Variable<String>(feature.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueEntriesCompanion(')
          ..write('id: $id, ')
          ..write('endpoint: $endpoint, ')
          ..write('method: $method, ')
          ..write('headers: $headers, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('maxRetries: $maxRetries, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('feature: $feature, ')
          ..write('userId: $userId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ReceiptsTable receipts = $ReceiptsTable(this);
  late final $QueueEntriesTable queueEntries = $QueueEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [receipts, queueEntries];
}

typedef $$ReceiptsTableCreateCompanionBuilder =
    ReceiptsCompanion Function({
      required String id,
      Value<String?> userId,
      required String imageUri,
      Value<String?> thumbnailUri,
      Value<String?> imageUrl,
      required DateTime capturedAt,
      required DateTime lastModified,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String status,
      Value<bool> isProcessed,
      Value<bool> needsReview,
      Value<String?> batchId,
      Value<String?> vendorName,
      Value<DateTime?> receiptDate,
      Value<double?> totalAmount,
      Value<double?> taxAmount,
      Value<double?> tipAmount,
      Value<String> currency,
      Value<String?> categoryId,
      Value<String?> subcategory,
      Value<String?> paymentMethod,
      Value<double?> ocrConfidence,
      Value<String?> ocrRawText,
      Value<String?> ocrResultsJson,
      Value<String?> businessPurpose,
      Value<String?> notes,
      Value<String?> tags,
      Value<String?> syncStatus,
      Value<DateTime?> lastSyncAt,
      Value<String?> metadata,
      Value<int> rowid,
    });
typedef $$ReceiptsTableUpdateCompanionBuilder =
    ReceiptsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String> imageUri,
      Value<String?> thumbnailUri,
      Value<String?> imageUrl,
      Value<DateTime> capturedAt,
      Value<DateTime> lastModified,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> status,
      Value<bool> isProcessed,
      Value<bool> needsReview,
      Value<String?> batchId,
      Value<String?> vendorName,
      Value<DateTime?> receiptDate,
      Value<double?> totalAmount,
      Value<double?> taxAmount,
      Value<double?> tipAmount,
      Value<String> currency,
      Value<String?> categoryId,
      Value<String?> subcategory,
      Value<String?> paymentMethod,
      Value<double?> ocrConfidence,
      Value<String?> ocrRawText,
      Value<String?> ocrResultsJson,
      Value<String?> businessPurpose,
      Value<String?> notes,
      Value<String?> tags,
      Value<String?> syncStatus,
      Value<DateTime?> lastSyncAt,
      Value<String?> metadata,
      Value<int> rowid,
    });

class $$ReceiptsTableFilterComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUri => $composableBuilder(
    column: $table.imageUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUri => $composableBuilder(
    column: $table.thumbnailUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isProcessed => $composableBuilder(
    column: $table.isProcessed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vendorName => $composableBuilder(
    column: $table.vendorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receiptDate => $composableBuilder(
    column: $table.receiptDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tipAmount => $composableBuilder(
    column: $table.tipAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ocrConfidence => $composableBuilder(
    column: $table.ocrConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrRawText => $composableBuilder(
    column: $table.ocrRawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrResultsJson => $composableBuilder(
    column: $table.ocrResultsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessPurpose => $composableBuilder(
    column: $table.businessPurpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReceiptsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUri => $composableBuilder(
    column: $table.imageUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUri => $composableBuilder(
    column: $table.thumbnailUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isProcessed => $composableBuilder(
    column: $table.isProcessed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vendorName => $composableBuilder(
    column: $table.vendorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receiptDate => $composableBuilder(
    column: $table.receiptDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tipAmount => $composableBuilder(
    column: $table.tipAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ocrConfidence => $composableBuilder(
    column: $table.ocrConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrRawText => $composableBuilder(
    column: $table.ocrRawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrResultsJson => $composableBuilder(
    column: $table.ocrResultsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessPurpose => $composableBuilder(
    column: $table.businessPurpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReceiptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get imageUri =>
      $composableBuilder(column: $table.imageUri, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUri => $composableBuilder(
    column: $table.thumbnailUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isProcessed => $composableBuilder(
    column: $table.isProcessed,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => column,
  );

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get vendorName => $composableBuilder(
    column: $table.vendorName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receiptDate => $composableBuilder(
    column: $table.receiptDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get taxAmount =>
      $composableBuilder(column: $table.taxAmount, builder: (column) => column);

  GeneratedColumn<double> get tipAmount =>
      $composableBuilder(column: $table.tipAmount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ocrConfidence => $composableBuilder(
    column: $table.ocrConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ocrRawText => $composableBuilder(
    column: $table.ocrRawText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ocrResultsJson => $composableBuilder(
    column: $table.ocrResultsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get businessPurpose => $composableBuilder(
    column: $table.businessPurpose,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);
}

class $$ReceiptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReceiptsTable,
          ReceiptEntity,
          $$ReceiptsTableFilterComposer,
          $$ReceiptsTableOrderingComposer,
          $$ReceiptsTableAnnotationComposer,
          $$ReceiptsTableCreateCompanionBuilder,
          $$ReceiptsTableUpdateCompanionBuilder,
          (
            ReceiptEntity,
            BaseReferences<_$AppDatabase, $ReceiptsTable, ReceiptEntity>,
          ),
          ReceiptEntity,
          PrefetchHooks Function()
        > {
  $$ReceiptsTableTableManager(_$AppDatabase db, $ReceiptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceiptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceiptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceiptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> imageUri = const Value.absent(),
                Value<String?> thumbnailUri = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isProcessed = const Value.absent(),
                Value<bool> needsReview = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                Value<String?> vendorName = const Value.absent(),
                Value<DateTime?> receiptDate = const Value.absent(),
                Value<double?> totalAmount = const Value.absent(),
                Value<double?> taxAmount = const Value.absent(),
                Value<double?> tipAmount = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> subcategory = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                Value<double?> ocrConfidence = const Value.absent(),
                Value<String?> ocrRawText = const Value.absent(),
                Value<String?> ocrResultsJson = const Value.absent(),
                Value<String?> businessPurpose = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String?> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReceiptsCompanion(
                id: id,
                userId: userId,
                imageUri: imageUri,
                thumbnailUri: thumbnailUri,
                imageUrl: imageUrl,
                capturedAt: capturedAt,
                lastModified: lastModified,
                createdAt: createdAt,
                updatedAt: updatedAt,
                status: status,
                isProcessed: isProcessed,
                needsReview: needsReview,
                batchId: batchId,
                vendorName: vendorName,
                receiptDate: receiptDate,
                totalAmount: totalAmount,
                taxAmount: taxAmount,
                tipAmount: tipAmount,
                currency: currency,
                categoryId: categoryId,
                subcategory: subcategory,
                paymentMethod: paymentMethod,
                ocrConfidence: ocrConfidence,
                ocrRawText: ocrRawText,
                ocrResultsJson: ocrResultsJson,
                businessPurpose: businessPurpose,
                notes: notes,
                tags: tags,
                syncStatus: syncStatus,
                lastSyncAt: lastSyncAt,
                metadata: metadata,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> userId = const Value.absent(),
                required String imageUri,
                Value<String?> thumbnailUri = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                required DateTime capturedAt,
                required DateTime lastModified,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String status,
                Value<bool> isProcessed = const Value.absent(),
                Value<bool> needsReview = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                Value<String?> vendorName = const Value.absent(),
                Value<DateTime?> receiptDate = const Value.absent(),
                Value<double?> totalAmount = const Value.absent(),
                Value<double?> taxAmount = const Value.absent(),
                Value<double?> tipAmount = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> subcategory = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                Value<double?> ocrConfidence = const Value.absent(),
                Value<String?> ocrRawText = const Value.absent(),
                Value<String?> ocrResultsJson = const Value.absent(),
                Value<String?> businessPurpose = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String?> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReceiptsCompanion.insert(
                id: id,
                userId: userId,
                imageUri: imageUri,
                thumbnailUri: thumbnailUri,
                imageUrl: imageUrl,
                capturedAt: capturedAt,
                lastModified: lastModified,
                createdAt: createdAt,
                updatedAt: updatedAt,
                status: status,
                isProcessed: isProcessed,
                needsReview: needsReview,
                batchId: batchId,
                vendorName: vendorName,
                receiptDate: receiptDate,
                totalAmount: totalAmount,
                taxAmount: taxAmount,
                tipAmount: tipAmount,
                currency: currency,
                categoryId: categoryId,
                subcategory: subcategory,
                paymentMethod: paymentMethod,
                ocrConfidence: ocrConfidence,
                ocrRawText: ocrRawText,
                ocrResultsJson: ocrResultsJson,
                businessPurpose: businessPurpose,
                notes: notes,
                tags: tags,
                syncStatus: syncStatus,
                lastSyncAt: lastSyncAt,
                metadata: metadata,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReceiptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReceiptsTable,
      ReceiptEntity,
      $$ReceiptsTableFilterComposer,
      $$ReceiptsTableOrderingComposer,
      $$ReceiptsTableAnnotationComposer,
      $$ReceiptsTableCreateCompanionBuilder,
      $$ReceiptsTableUpdateCompanionBuilder,
      (
        ReceiptEntity,
        BaseReferences<_$AppDatabase, $ReceiptsTable, ReceiptEntity>,
      ),
      ReceiptEntity,
      PrefetchHooks Function()
    >;
typedef $$QueueEntriesTableCreateCompanionBuilder =
    QueueEntriesCompanion Function({
      required String id,
      required String endpoint,
      required String method,
      Value<String> headers,
      Value<String?> body,
      required DateTime createdAt,
      Value<DateTime?> lastAttemptAt,
      Value<int> retryCount,
      Value<int> maxRetries,
      Value<String> status,
      Value<String?> errorMessage,
      Value<String?> feature,
      Value<String?> userId,
      Value<int> rowid,
    });
typedef $$QueueEntriesTableUpdateCompanionBuilder =
    QueueEntriesCompanion Function({
      Value<String> id,
      Value<String> endpoint,
      Value<String> method,
      Value<String> headers,
      Value<String?> body,
      Value<DateTime> createdAt,
      Value<DateTime?> lastAttemptAt,
      Value<int> retryCount,
      Value<int> maxRetries,
      Value<String> status,
      Value<String?> errorMessage,
      Value<String?> feature,
      Value<String?> userId,
      Value<int> rowid,
    });

class $$QueueEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $QueueEntriesTable> {
  $$QueueEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headers => $composableBuilder(
    column: $table.headers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxRetries => $composableBuilder(
    column: $table.maxRetries,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feature => $composableBuilder(
    column: $table.feature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QueueEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $QueueEntriesTable> {
  $$QueueEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headers => $composableBuilder(
    column: $table.headers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxRetries => $composableBuilder(
    column: $table.maxRetries,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feature => $composableBuilder(
    column: $table.feature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QueueEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueueEntriesTable> {
  $$QueueEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get endpoint =>
      $composableBuilder(column: $table.endpoint, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get headers =>
      $composableBuilder(column: $table.headers, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxRetries => $composableBuilder(
    column: $table.maxRetries,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get feature =>
      $composableBuilder(column: $table.feature, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);
}

class $$QueueEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueueEntriesTable,
          QueueEntryEntity,
          $$QueueEntriesTableFilterComposer,
          $$QueueEntriesTableOrderingComposer,
          $$QueueEntriesTableAnnotationComposer,
          $$QueueEntriesTableCreateCompanionBuilder,
          $$QueueEntriesTableUpdateCompanionBuilder,
          (
            QueueEntryEntity,
            BaseReferences<_$AppDatabase, $QueueEntriesTable, QueueEntryEntity>,
          ),
          QueueEntryEntity,
          PrefetchHooks Function()
        > {
  $$QueueEntriesTableTableManager(_$AppDatabase db, $QueueEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> endpoint = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> headers = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<int> maxRetries = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String?> feature = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QueueEntriesCompanion(
                id: id,
                endpoint: endpoint,
                method: method,
                headers: headers,
                body: body,
                createdAt: createdAt,
                lastAttemptAt: lastAttemptAt,
                retryCount: retryCount,
                maxRetries: maxRetries,
                status: status,
                errorMessage: errorMessage,
                feature: feature,
                userId: userId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String endpoint,
                required String method,
                Value<String> headers = const Value.absent(),
                Value<String?> body = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<int> maxRetries = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String?> feature = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QueueEntriesCompanion.insert(
                id: id,
                endpoint: endpoint,
                method: method,
                headers: headers,
                body: body,
                createdAt: createdAt,
                lastAttemptAt: lastAttemptAt,
                retryCount: retryCount,
                maxRetries: maxRetries,
                status: status,
                errorMessage: errorMessage,
                feature: feature,
                userId: userId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QueueEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueueEntriesTable,
      QueueEntryEntity,
      $$QueueEntriesTableFilterComposer,
      $$QueueEntriesTableOrderingComposer,
      $$QueueEntriesTableAnnotationComposer,
      $$QueueEntriesTableCreateCompanionBuilder,
      $$QueueEntriesTableUpdateCompanionBuilder,
      (
        QueueEntryEntity,
        BaseReferences<_$AppDatabase, $QueueEntriesTable, QueueEntryEntity>,
      ),
      QueueEntryEntity,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ReceiptsTableTableManager get receipts =>
      $$ReceiptsTableTableManager(_db, _db.receipts);
  $$QueueEntriesTableTableManager get queueEntries =>
      $$QueueEntriesTableTableManager(_db, _db.queueEntries);
}
