import 'dart:math';

/// Comprehensive receipt test dataset for CRUD testing
/// 70% valid receipts, 30% malformed/bad receipts
class ReceiptTestDataset {
  static final _random = Random(42); // Seed for reproducibility

  /// Generate complete test dataset
  static List<Map<String, dynamic>> generateCompleteDataset() {
    final List<Map<String, dynamic>> dataset = [];

    // Academic receipts (20 samples)
    dataset.addAll(_generateAcademicReceipts());

    // Business receipts (25 samples)
    dataset.addAll(_generateBusinessReceipts());

    // Retail/Public receipts (25 samples)
    dataset.addAll(_generateRetailReceipts());

    // International format receipts (15 samples)
    dataset.addAll(_generateInternationalReceipts());

    // Edge case valid receipts (15 samples)
    dataset.addAll(_generateEdgeCaseReceipts());

    // Bad/Malformed receipts (43 samples - 30% of 143 total)
    dataset.addAll(_generateBadReceipts());

    return dataset;
  }

  /// Academic institution receipts
  static List<Map<String, dynamic>> _generateAcademicReceipts() {
    return [
      {
        'vendor_name': 'MIT Bookstore',
        'receipt_date': '2024-09-15',
        'total_amount': 342.50,
        'tax_amount': 21.50,
        'category': 'Education',
        'items': 'Calculus Textbook, Engineering Notebook Set',
        'payment_method': 'Student Card',
        'ocr_confidence': 95.5,
        'tags': ['textbooks', 'fall-semester', 'engineering'],
      },
      {
        'vendor_name': 'Stanford University Dining',
        'receipt_date': '2024-10-03',
        'total_amount': 12.75,
        'tax_amount': 0.98,
        'category': 'Food & Dining',
        'payment_method': 'Meal Plan',
        'ocr_confidence': 92.0,
      },
      {
        'vendor_name': 'Harvard COOP',
        'receipt_date': '2024-11-20',
        'total_amount': 89.99,
        'tax_amount': 5.62,
        'category': 'Office Supplies',
        'items': 'Lab Notebooks, Scientific Calculator',
        'ocr_confidence': 88.5,
      },
      {
        'vendor_name': 'UC Berkeley Student Store',
        'receipt_date': '2024-08-28',
        'total_amount': 567.00,
        'tax_amount': 49.61,
        'category': 'Education',
        'items': 'Semester Textbook Bundle',
        'payment_method': 'Financial Aid',
        'ocr_confidence': 91.0,
      },
      {
        'vendor_name': 'Oxford University Press',
        'receipt_date': '2024-07-15',
        'total_amount': 234.50,
        'tax_amount': 0.00, // Academic exemption
        'category': 'Education',
        'items': 'Research Journals Subscription',
        'payment_method': 'Department Card',
        'ocr_confidence': 97.0,
      },
      // More academic receipts
      ...List.generate(15, (i) => {
        'vendor_name': _academicVendors[i % _academicVendors.length],
        'receipt_date': _generateDate(2024, i),
        'total_amount': _generateAmount(50, 800),
        'tax_amount': _generateTax(),
        'category': i % 3 == 0 ? 'Education' : 'Office Supplies',
        'payment_method': _academicPaymentMethods[i % _academicPaymentMethods.length],
        'ocr_confidence': _generateConfidence(85, 98),
        'tags': _generateAcademicTags(i),
      }),
    ];
  }

  /// Business receipts
  static List<Map<String, dynamic>> _generateBusinessReceipts() {
    return [
      {
        'vendor_name': 'Staples Business Advantage',
        'receipt_date': '2024-10-15',
        'total_amount': 458.92,
        'tax_amount': 36.71,
        'tip_amount': 0.00,
        'category': 'Office Supplies',
        'subcategory': 'Bulk Purchase',
        'items': 'Printer Paper (10 reams), Toner Cartridges',
        'payment_method': 'Corporate Card',
        'ocr_confidence': 94.5,
        'business_purpose': 'Q4 Office Supplies Restock',
        'needs_review': false,
      },
      {
        'vendor_name': 'Amazon Web Services',
        'receipt_date': '2024-11-01',
        'total_amount': 1247.83,
        'tax_amount': 0.00,
        'category': 'Software & Subscriptions',
        'subcategory': 'Cloud Services',
        'payment_method': 'ACH Transfer',
        'ocr_confidence': 99.0,
        'business_purpose': 'Monthly Cloud Infrastructure',
      },
      {
        'vendor_name': 'FedEx Office',
        'receipt_date': '2024-09-22',
        'total_amount': 89.50,
        'tax_amount': 7.16,
        'category': 'Professional Services',
        'items': 'Business Cards (500), Letterhead Printing',
        'payment_method': 'Credit Card',
        'ocr_confidence': 91.5,
      },
      {
        'vendor_name': 'Uber for Business',
        'receipt_date': '2024-10-28',
        'total_amount': 34.67,
        'tax_amount': 2.77,
        'tip_amount': 5.00,
        'category': 'Travel & Transportation',
        'subcategory': 'Local Transport',
        'payment_method': 'Business Account',
        'ocr_confidence': 96.0,
        'business_purpose': 'Client Meeting Downtown',
      },
      {
        'vendor_name': 'Zoom Communications',
        'receipt_date': '2024-11-15',
        'total_amount': 149.90,
        'tax_amount': 11.99,
        'category': 'Software & Subscriptions',
        'payment_method': 'Credit Card',
        'ocr_confidence': 98.5,
      },
      // More business receipts
      ...List.generate(20, (i) => {
        'vendor_name': _businessVendors[i % _businessVendors.length],
        'receipt_date': _generateDate(2024, i + 20),
        'total_amount': _generateAmount(25, 2500),
        'tax_amount': _generateTax(),
        'tip_amount': i % 4 == 0 ? _generateAmount(5, 50) : null,
        'category': _businessCategories[i % _businessCategories.length],
        'payment_method': _businessPaymentMethods[i % _businessPaymentMethods.length],
        'ocr_confidence': _generateConfidence(88, 99),
        'business_purpose': _generateBusinessPurpose(i),
        'needs_review': i % 5 == 0,
      }),
    ];
  }

  /// Retail/Public receipts
  static List<Map<String, dynamic>> _generateRetailReceipts() {
    return [
      {
        'vendor_name': 'Whole Foods Market #10234',
        'receipt_date': '2024-11-18',
        'total_amount': 127.43,
        'tax_amount': 9.83,
        'category': 'Groceries',
        'items': 'Organic Produce, Dairy, Bakery Items',
        'payment_method': 'Debit Card',
        'ocr_confidence': 93.0,
        'tags': ['groceries', 'weekly-shopping'],
      },
      {
        'vendor_name': 'Target Store #1842',
        'receipt_date': '2024-10-25',
        'total_amount': 245.67,
        'tax_amount': 19.65,
        'category': 'Retail',
        'items': 'Household Items, Electronics Accessories',
        'payment_method': 'RedCard',
        'ocr_confidence': 95.5,
      },
      {
        'vendor_name': 'Starbucks Coffee #7823',
        'receipt_date': '2024-11-20',
        'total_amount': 6.75,
        'tax_amount': 0.54,
        'tip_amount': 1.00,
        'category': 'Food & Dining',
        'payment_method': 'Mobile App',
        'ocr_confidence': 97.0,
      },
      {
        'vendor_name': 'CVS Pharmacy #4521',
        'receipt_date': '2024-09-30',
        'total_amount': 45.23,
        'tax_amount': 3.62,
        'category': 'Healthcare',
        'items': 'Prescription, OTC Medicine',
        'payment_method': 'FSA Card',
        'ocr_confidence': 94.0,
      },
      {
        'vendor_name': 'Shell Gas Station #9876',
        'receipt_date': '2024-11-15',
        'total_amount': 52.45,
        'tax_amount': 4.20,
        'category': 'Transportation',
        'subcategory': 'Fuel',
        'payment_method': 'Credit Card',
        'ocr_confidence': 92.5,
      },
      // More retail receipts
      ...List.generate(20, (i) => {
        'vendor_name': _retailVendors[i % _retailVendors.length],
        'receipt_date': _generateDate(2024, i + 40),
        'total_amount': _generateAmount(5, 500),
        'tax_amount': _generateTax(),
        'tip_amount': i % 3 == 0 ? _generateAmount(2, 20) : null,
        'category': _retailCategories[i % _retailCategories.length],
        'payment_method': _retailPaymentMethods[i % _retailPaymentMethods.length],
        'ocr_confidence': _generateConfidence(87, 98),
        'tags': _generateRetailTags(i),
      }),
    ];
  }

  /// International format receipts (different date/currency formats)
  static List<Map<String, dynamic>> _generateInternationalReceipts() {
    return [
      // European format (DD/MM/YYYY, EUR)
      {
        'vendor_name': 'Carrefour Paris',
        'receipt_date': '2024-15-10', // Wrong format intentionally
        'total_amount': 89.50,
        'tax_amount': 17.90,
        'currency': 'EUR',
        'category': 'Groceries',
        'payment_method': 'Carte Bancaire',
        'ocr_confidence': 89.0,
        'raw_ocr_text': 'Date: 15/10/2024\nMontant: 89,50€',
      },
      // UK format (GBP)
      {
        'vendor_name': 'Tesco Express London',
        'receipt_date': '2024-11-08',
        'total_amount': 34.99,
        'tax_amount': 5.83,
        'currency': 'GBP',
        'category': 'Groceries',
        'payment_method': 'Contactless',
        'ocr_confidence': 91.5,
        'raw_ocr_text': 'VAT: £5.83\\nTotal: £34.99',
      },
      // Japanese format (JPY)
      {
        'vendor_name': 'セブンイレブン東京', // 7-Eleven Tokyo
        'receipt_date': '2024-11-10',
        'total_amount': 2580,
        'tax_amount': 234,
        'currency': 'JPY',
        'category': 'Convenience Store',
        'payment_method': 'IC Card',
        'ocr_confidence': 86.0,
        'raw_ocr_text': '合計: ¥2,580',
      },
      // Canadian format (CAD)
      {
        'vendor_name': 'Tim Hortons #4521',
        'receipt_date': '2024-11-12',
        'total_amount': 8.45,
        'tax_amount': 1.10,
        'currency': 'CAD',
        'category': 'Food & Dining',
        'payment_method': 'Tim Card',
        'ocr_confidence': 94.5,
        'raw_ocr_text': 'HST: \$1.10\\nTotal: \$8.45 CAD',
      },
      // Australian format (AUD)
      {
        'vendor_name': 'Woolworths Sydney',
        'receipt_date': '2024-11-05',
        'total_amount': 156.80,
        'tax_amount': 14.25,
        'currency': 'AUD',
        'category': 'Groceries',
        'payment_method': 'PayWave',
        'ocr_confidence': 92.0,
        'raw_ocr_text': 'GST: \$14.25\\nTotal: \$156.80 AUD',
      },
      // More international receipts
      ...List.generate(10, (i) => {
        'vendor_name': _internationalVendors[i % _internationalVendors.length],
        'receipt_date': _generateDate(2024, i + 60),
        'total_amount': _generateAmount(10, 1000),
        'tax_amount': _generateTax(),
        'currency': _currencies[i % _currencies.length],
        'category': _retailCategories[i % _retailCategories.length],
        'payment_method': 'Card',
        'ocr_confidence': _generateConfidence(85, 95),
      }),
    ];
  }

  /// Edge case valid receipts (unusual but valid)
  static List<Map<String, dynamic>> _generateEdgeCaseReceipts() {
    return [
      // Zero tax receipt
      {
        'vendor_name': 'Oregon No-Tax Store',
        'receipt_date': '2024-11-01',
        'total_amount': 299.99,
        'tax_amount': 0.00,
        'category': 'Electronics',
        'notes': 'No sales tax in Oregon',
        'ocr_confidence': 95.0,
      },
      // Very old receipt
      {
        'vendor_name': 'Vintage Books Archive',
        'receipt_date': '2020-03-15',
        'total_amount': 45.00,
        'tax_amount': 3.60,
        'category': 'Books',
        'notes': 'Old receipt for tax records',
        'ocr_confidence': 72.0, // Lower due to age
      },
      // Very large amount
      {
        'vendor_name': 'Dell Business Solutions',
        'receipt_date': '2024-10-01',
        'total_amount': 25847.50,
        'tax_amount': 2068.00,
        'category': 'Equipment & Hardware',
        'notes': 'Server farm purchase',
        'business_purpose': 'Data center upgrade',
        'ocr_confidence': 98.5,
      },
      // Very small amount
      {
        'vendor_name': 'Penny Candy Store',
        'receipt_date': '2024-11-20',
        'total_amount': 0.25,
        'tax_amount': 0.02,
        'category': 'Other',
        'ocr_confidence': 85.0,
      },
      // Multiple currencies on same receipt
      {
        'vendor_name': 'Airport Duty Free',
        'receipt_date': '2024-09-28',
        'total_amount': 150.00,
        'tax_amount': 0.00,
        'currency': 'USD',
        'notes': 'Also showed EUR 138.50',
        'category': 'Retail',
        'ocr_confidence': 88.0,
      },
      // Receipt with negative amount (refund)
      {
        'vendor_name': 'Best Buy Return Center',
        'receipt_date': '2024-11-10',
        'total_amount': -89.99,
        'tax_amount': -7.20,
        'category': 'Electronics',
        'notes': 'Product return/refund',
        'ocr_confidence': 93.0,
      },
      // Receipt with excessive decimal places
      {
        'vendor_name': 'Gas Station Precision',
        'receipt_date': '2024-11-15',
        'total_amount': 45.789, // Gas price per gallon calculation
        'tax_amount': 3.663,
        'category': 'Transportation',
        'ocr_confidence': 91.0,
      },
      // Unicode vendor name
      {
        'vendor_name': '北京饭店 (Beijing Restaurant)',
        'receipt_date': '2024-10-30',
        'total_amount': 68.88,
        'tax_amount': 5.51,
        'category': 'Food & Dining',
        'ocr_confidence': 84.0,
      },
      // Long vendor name
      {
        'vendor_name': 'The Really Long Named Corporation of Greater Metropolitan Area District Store #12345-B',
        'receipt_date': '2024-11-05',
        'total_amount': 123.45,
        'tax_amount': 9.88,
        'category': 'Retail',
        'ocr_confidence': 87.5,
      },
      // Future dated receipt (post-dated check scenario)
      {
        'vendor_name': 'Advance Payment Services',
        'receipt_date': '2025-01-01',
        'total_amount': 500.00,
        'tax_amount': 40.00,
        'category': 'Professional Services',
        'notes': 'Post-dated for January payment',
        'ocr_confidence': 96.0,
      },
      // More edge cases
      ...List.generate(5, (i) => {
        'vendor_name': 'Edge Case Vendor ${i + 1}',
        'receipt_date': _generateDate(2024, i + 70),
        'total_amount': i % 2 == 0 ? 0.01 * (i + 1) : 10000.00 + i,
        'tax_amount': _generateTax(),
        'category': _businessCategories[i % _businessCategories.length],
        'ocr_confidence': _generateConfidence(70, 99),
        'notes': 'Edge case test ${i + 1}',
      }),
    ];
  }

  /// Bad/Malformed receipts (30% of dataset for error testing)
  static List<Map<String, dynamic>> _generateBadReceipts() {
    return [
      // Missing required fields
      {
        'vendor_name': null, // Missing vendor
        'receipt_date': '2024-11-01',
        'total_amount': 45.00,
        'tax_amount': 3.60,
      },
      {
        'vendor_name': 'Test Store',
        'receipt_date': null, // Missing date
        'total_amount': 45.00,
        'tax_amount': 3.60,
      },
      {
        'vendor_name': 'Test Store',
        'receipt_date': '2024-11-01',
        'total_amount': null, // Missing amount
        'tax_amount': 3.60,
      },
      // Invalid date formats
      {
        'vendor_name': 'Date Error Store',
        'receipt_date': '11/20/2024', // Wrong format
        'total_amount': 45.00,
        'tax_amount': 3.60,
      },
      {
        'vendor_name': 'Date Error Store 2',
        'receipt_date': '2024-13-45', // Invalid date
        'total_amount': 45.00,
        'tax_amount': 3.60,
      },
      {
        'vendor_name': 'Date Error Store 3',
        'receipt_date': 'November 20, 2024', // Text date
        'total_amount': 45.00,
        'tax_amount': 3.60,
      },
      // Invalid amounts
      {
        'vendor_name': 'Amount Error Store',
        'receipt_date': '2024-11-01',
        'total_amount': -0.01, // Invalid negative (except refunds)
        'tax_amount': 3.60,
      },
      {
        'vendor_name': 'Amount Error Store 2',
        'receipt_date': '2024-11-01',
        'total_amount': 'forty-five dollars', // String amount
        'tax_amount': 3.60,
      },
      {
        'vendor_name': 'Amount Error Store 3',
        'receipt_date': '2024-11-01',
        'total_amount': double.nan, // NaN
        'tax_amount': 3.60,
      },
      {
        'vendor_name': 'Amount Error Store 4',
        'receipt_date': '2024-11-01',
        'total_amount': double.infinity, // Infinity
        'tax_amount': 3.60,
      },
      // Invalid tax amounts
      {
        'vendor_name': 'Tax Error Store',
        'receipt_date': '2024-11-01',
        'total_amount': 45.00,
        'tax_amount': 50.00, // Tax > Total
      },
      {
        'vendor_name': 'Tax Error Store 2',
        'receipt_date': '2024-11-01',
        'total_amount': 45.00,
        'tax_amount': -5.00, // Negative tax
      },
      // Invalid currency codes
      {
        'vendor_name': 'Currency Error Store',
        'receipt_date': '2024-11-01',
        'total_amount': 45.00,
        'tax_amount': 3.60,
        'currency': 'DOLLAR', // Invalid code
      },
      {
        'vendor_name': 'Currency Error Store 2',
        'receipt_date': '2024-11-01',
        'total_amount': 45.00,
        'tax_amount': 3.60,
        'currency': 'US', // Too short
      },
      {
        'vendor_name': 'Currency Error Store 3',
        'receipt_date': '2024-11-01',
        'total_amount': 45.00,
        'tax_amount': 3.60,
        'currency': '123', // Numbers
      },
      // Invalid confidence scores
      {
        'vendor_name': 'Confidence Error Store',
        'receipt_date': '2024-11-01',
        'total_amount': 45.00,
        'tax_amount': 3.60,
        'ocr_confidence': 101.0, // > 100
      },
      {
        'vendor_name': 'Confidence Error Store 2',
        'receipt_date': '2024-11-01',
        'total_amount': 45.00,
        'tax_amount': 3.60,
        'ocr_confidence': -10.0, // < 0
      },
      // SQL injection attempts
      {
        'vendor_name': "'; DROP TABLE receipts; --",
        'receipt_date': '2024-11-01',
        'total_amount': 45.00,
        'tax_amount': 3.60,
      },
      {
        'vendor_name': 'Test Store',
        'receipt_date': '2024-11-01',
        'total_amount': 45.00,
        'tax_amount': 3.60,
        'notes': "'; DELETE FROM receipts WHERE 1=1; --",
      },
      // XSS attempts
      {
        'vendor_name': '<script>alert("XSS")</script>',
        'receipt_date': '2024-11-01',
        'total_amount': 45.00,
        'tax_amount': 3.60,
      },
      {
        'vendor_name': 'Test Store',
        'receipt_date': '2024-11-01',
        'total_amount': 45.00,
        'tax_amount': 3.60,
        'notes': '<img src=x onerror=alert(1)>',
      },
      // Extremely long strings
      {
        'vendor_name': 'A' * 1000, // 1000 character vendor name
        'receipt_date': '2024-11-01',
        'total_amount': 45.00,
        'tax_amount': 3.60,
      },
      {
        'vendor_name': 'Test Store',
        'receipt_date': '2024-11-01',
        'total_amount': 45.00,
        'tax_amount': 3.60,
        'notes': 'B' * 10000, // 10000 character notes
      },
      // Invalid category references
      {
        'vendor_name': 'Category Error Store',
        'receipt_date': '2024-11-01',
        'total_amount': 45.00,
        'tax_amount': 3.60,
        'category_id': '00000000-0000-0000-0000-000000000000', // Invalid UUID
      },
      {
        'vendor_name': 'Category Error Store 2',
        'receipt_date': '2024-11-01',
        'total_amount': 45.00,
        'tax_amount': 3.60,
        'category_id': 'not-a-uuid', // Not a UUID
      },
      // Duplicate entries (same vendor, date, amount)
      {
        'vendor_name': 'Duplicate Store',
        'receipt_date': '2024-11-01',
        'total_amount': 99.99,
        'tax_amount': 8.00,
      },
      {
        'vendor_name': 'Duplicate Store',
        'receipt_date': '2024-11-01',
        'total_amount': 99.99,
        'tax_amount': 8.00,
      },
      // Invalid boolean values
      {
        'vendor_name': 'Boolean Error Store',
        'receipt_date': '2024-11-01',
        'total_amount': 45.00,
        'tax_amount': 3.60,
        'is_processed': 'yes', // String instead of boolean
        'needs_review': 1, // Number instead of boolean
      },
      // Invalid array/JSON fields
      {
        'vendor_name': 'Array Error Store',
        'receipt_date': '2024-11-01',
        'total_amount': 45.00,
        'tax_amount': 3.60,
        'tags': 'tag1,tag2,tag3', // String instead of array
      },
      {
        'vendor_name': 'Array Error Store 2',
        'receipt_date': '2024-11-01',
        'total_amount': 45.00,
        'tax_amount': 3.60,
        'tags': {'tag': 'value'}, // Object instead of array
      },
      // Corrupted OCR text
      {
        'vendor_name': 'Ẅ̸̳́ë̶͇́ì̴̺r̶̺̈d̸̰̈ ̷͇̇S̶̱̈t̶̳́ö̴͉́r̶̰̈ë̶̺́',
        'receipt_date': '2024-11-01',
        'total_amount': 45.00,
        'tax_amount': 3.60,
        'ocr_raw_text': '�����������',
      },
      // More bad receipts
      ...List.generate(10, (i) => {
        'vendor_name': i % 3 == 0 ? null : 'Bad Vendor $i',
        'receipt_date': i % 4 == 0 ? 'bad-date-$i' : _generateDate(2024, i + 100),
        'total_amount': i % 5 == 0 ? null : _generateAmount(-100, 0),
        'tax_amount': i % 2 == 0 ? 999999.99 : null,
        'ocr_confidence': 150.0 + i,
        'error_type': 'Generated bad receipt $i',
      }),
    ];
  }

  // Helper data arrays
  static const _academicVendors = [
    'Yale Bookstore', 'Princeton Store', 'Columbia Books', 'NYU Campus Store',
    'UCLA Store', 'Duke University Store', 'Northwestern Books', 'Rice Campus Store',
    'Vanderbilt Bookstore', 'Georgetown Books', 'Boston University Store',
    'University of Chicago Store', 'Cornell Store', 'Brown Bookstore', 'Dartmouth Co-op'
  ];

  static const _businessVendors = [
    'Office Depot', 'Microsoft 365', 'Adobe Creative Cloud', 'Salesforce',
    'HubSpot', 'LinkedIn Premium', 'Google Workspace', 'Slack Technologies',
    'Dropbox Business', 'WeWork', 'Regus Office Space', 'Enterprise Rent-A-Car',
    'Hertz Business', 'Delta Airlines', 'United Airlines', 'Marriott Hotels',
    'Hilton Business', 'American Express', 'QuickBooks', 'Xero Accounting'
  ];

  static const _retailVendors = [
    'Walmart Supercenter', 'Kroger', 'Costco Wholesale', 'Sam\'s Club',
    'Trader Joe\'s', 'Safeway', 'Publix', 'H-E-B', 'Meijer', 'Albertsons',
    'Home Depot', 'Lowe\'s', 'Best Buy', 'Dick\'s Sporting Goods', 'Macy\'s',
    'Nordstrom', 'TJ Maxx', 'Ross Stores', 'Burlington', 'Dollar General'
  ];

  static const _internationalVendors = [
    'Sainsbury\'s UK', 'REWE Germany', 'Auchan France', 'Mercadona Spain',
    'ICA Sweden', 'Albert Heijn Netherlands', 'Migros Switzerland',
    'Loblaws Canada', 'Coles Australia', 'FamilyMart Japan'
  ];

  static const _currencies = ['EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'SEK', 'NOK', 'DKK', 'NZD'];

  static const _businessCategories = [
    'Office Supplies', 'Software & Subscriptions', 'Professional Services',
    'Travel & Transportation', 'Marketing & Advertising', 'Equipment & Hardware',
    'Business Meals', 'Utilities', 'Insurance', 'Legal Services'
  ];

  static const _retailCategories = [
    'Groceries', 'Food & Dining', 'Retail', 'Electronics', 'Clothing',
    'Healthcare', 'Transportation', 'Entertainment', 'Home Improvement', 'Personal Care'
  ];

  static const _academicPaymentMethods = [
    'Student Card', 'Financial Aid', 'Department Card', 'Grant Funding', 'Scholarship Account'
  ];

  static const _businessPaymentMethods = [
    'Corporate Card', 'ACH Transfer', 'Wire Transfer', 'Business Account', 'Purchase Order'
  ];

  static const _retailPaymentMethods = [
    'Credit Card', 'Debit Card', 'Cash', 'Mobile Payment', 'Store Card', 'Gift Card'
  ];

  // Helper functions
  static String _generateDate(int year, int seed) {
    final month = (seed % 12) + 1;
    final day = (seed % 28) + 1;
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  static double _generateAmount(double min, double max) {
    return (min + _random.nextDouble() * (max - min)).roundToDouble();
  }

  static double? _generateTax() {
    final rate = _random.nextDouble() * 0.10; // 0-10% tax rate
    return (_random.nextDouble() * 100 * rate).roundToDouble();
  }

  static double _generateConfidence(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }

  static List<String> _generateAcademicTags(int seed) {
    final tags = ['education', 'textbooks', 'supplies', 'research', 'lab-equipment'];
    return tags.take((seed % 3) + 1).toList();
  }

  static List<String> _generateRetailTags(int seed) {
    final tags = ['shopping', 'retail', 'personal', 'household', 'essentials'];
    return tags.take((seed % 2) + 1).toList();
  }

  static String _generateBusinessPurpose(int seed) {
    final purposes = [
      'Client meeting expenses',
      'Team building event',
      'Office supplies restock',
      'Software license renewal',
      'Travel for conference',
      'Marketing campaign',
      'Equipment upgrade',
      'Professional development'
    ];
    return purposes[seed % purposes.length];
  }

  /// Get dataset statistics
  static Map<String, dynamic> getDatasetStatistics(List<Map<String, dynamic>> dataset) {
    int validCount = 0;
    int invalidCount = 0;
    Map<String, int> categoryCount = {};
    Map<String, int> currencyCount = {};
    double totalAmount = 0;
    int missingFields = 0;

    for (final receipt in dataset) {
      // Check validity
      bool isValid = receipt['vendor_name'] != null &&
          receipt['receipt_date'] != null &&
          receipt['total_amount'] != null &&
          receipt['total_amount'] is num &&
          (receipt['total_amount'] as num) >= 0;

      if (isValid) {
        validCount++;
        totalAmount += (receipt['total_amount'] as num).toDouble();
      } else {
        invalidCount++;
      }

      // Count categories
      final category = receipt['category']?.toString() ?? 'Uncategorized';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;

      // Count currencies
      final currency = receipt['currency']?.toString() ?? 'USD';
      currencyCount[currency] = (currencyCount[currency] ?? 0) + 1;

      // Count missing fields
      receipt.forEach((key, value) {
        if (value == null) missingFields++;
      });
    }

    return {
      'total_receipts': dataset.length,
      'valid_receipts': validCount,
      'invalid_receipts': invalidCount,
      'validity_percentage': (validCount / dataset.length * 100).toStringAsFixed(1),
      'categories': categoryCount,
      'currencies': currencyCount,
      'total_amount': totalAmount.toStringAsFixed(2),
      'average_amount': (totalAmount / validCount).toStringAsFixed(2),
      'missing_fields': missingFields,
    };
  }
}