/// Comprehensive merchant test dataset for normalization testing
/// Covers edge cases, common franchises, and various formats
/// 
/// Test categories:
/// - Franchise with store numbers
/// - All caps variations
/// - Special characters and punctuation
/// - International names
/// - Abbreviations
/// - Location suffixes
/// - Already clean names
/// - Edge cases (empty, null, very long)

class MerchantTestData {
  /// Common franchise test cases with expected normalizations
  static const Map<String, String> franchiseTestCases = {
    // McDonald's variations
    'MCDONALDS #4521': 'McDonalds',
    'MCDONALD\'S #123': 'McDonalds',
    'McDonalds Store #789': 'McDonalds',
    'MCDONALDS - STORE 456': 'McDonalds',
    'MCD #1234': 'McDonalds',
    'MCDONALDS 00123': 'McDonalds',
    
    // Starbucks variations
    'STARBUCKS #12345': 'Starbucks',
    'STARBUCKS STORE #678': 'Starbucks',
    'STARBUCKS - 5TH AVE': 'Starbucks',
    'STARBUCKS COFFEE #890': 'Starbucks Coffee',
    'SBUX #123': 'Starbucks',
    
    // Walmart variations
    'WALMART #1234': 'Walmart',
    'WAL-MART #5678': 'Walmart',
    'WALMART SUPERCENTER': 'Walmart Supercenter',
    'WALMART.COM': 'Walmart.com',
    'WAL MART STORE 123': 'Walmart',
    
    // Target variations
    'TARGET #T1234': 'Target',
    'TARGET STORE T-5678': 'Target',
    'TARGET.COM': 'Target.com',
    'TGT #123': 'Target',
    
    // CVS variations
    'CVS/PHARMACY #12345': 'CVS Pharmacy',
    'CVS #1234': 'CVS',
    'CVS PHARMACY #567': 'CVS Pharmacy',
    'CVS/PHARM #890': 'CVS Pharmacy',
    
    // Costco variations
    'COSTCO #123': 'Costco',
    'COSTCO WHSE #456': 'Costco',
    'COSTCO WHOLESALE': 'Costco Wholesale',
    'COSTCO GAS #789': 'Costco Gas',
    
    // Home Depot variations
    'HOME DEPOT #1234': 'Home Depot',
    'THE HOME DEPOT #567': 'The Home Depot',
    'HOME DEPOT STORE 890': 'Home Depot',
    'HD #123': 'Home Depot',
  };

  /// All caps variations that need case correction
  static const Map<String, String> caseNormalizationTestCases = {
    'AMAZON.COM': 'Amazon.com',
    'BEST BUY': 'Best Buy',
    'WHOLE FOODS': 'Whole Foods',
    'TRADER JOES': 'Trader Joes',
    'KROGER': 'Kroger',
    'SAFEWAY': 'Safeway',
    'WALGREENS': 'Walgreens',
    'LOWES': 'Lowes',
    'PUBLIX': 'Publix',
    'CHIPOTLE': 'Chipotle',
  };

  /// Special characters and punctuation handling
  static const Map<String, String> specialCharacterTestCases = {
    '7-ELEVEN': '7-Eleven',
    '7-ELEVEN #12345': '7-Eleven',
    'AT&T STORE': 'AT&T Store',
    'H&M': 'H&M',
    'T.J.MAXX': 'T.J.Maxx',
    'BJ\'S WHOLESALE': 'BJ\'s Wholesale',
    'DICK\'S SPORTING': 'Dick\'s Sporting',
    'MACY\'S': 'Macy\'s',
    'WENDY\'S #123': 'Wendy\'s',
    'ARBY\'S #456': 'Arby\'s',
  };

  /// Abbreviation expansion test cases
  static const Map<String, String> abbreviationTestCases = {
    'MCD': 'McDonalds',
    'SBUX': 'Starbucks',
    'TGT': 'Target',
    'HD': 'Home Depot',
    'BBY': 'Best Buy',
    'WMT': 'Walmart',
    'AMZN': 'Amazon',
    'KR': 'Kroger',
    'WBA': 'Walgreens',
    'CVS': 'CVS',
  };

  /// Location suffix removal test cases
  static const Map<String, String> locationSuffixTestCases = {
    'STARBUCKS - MAIN ST': 'Starbucks',
    'MCDONALDS - DOWNTOWN': 'McDonalds',
    'TARGET - PLAZA NORTH': 'Target',
    'WALMART - SUPERCENTER #123': 'Walmart Supercenter',
    'SUBWAY - INSIDE WALMART': 'Subway',
    'COSTCO - SAN DIEGO': 'Costco',
    'SAFEWAY - 24HR': 'Safeway',
  };

  /// Already clean names that should not change
  static const List<String> alreadyCleanTestCases = [
    'Apple Store',
    'Microsoft Store',
    'Google Store',
    'Amazon',
    'Netflix',
    'Spotify',
    'Adobe',
    'Zoom',
    'Slack',
    'GitHub',
  ];

  /// Edge cases for error handling
  static const Map<String?, String> edgeCaseTestCases = {
    null: '',
    '': '',
    ' ': '',
    '   ': '',
    '#': '',
    '#123': '',
    '###': '',
    'STORE #': 'Store',
    '- - -': '',
    '!!!': '',
    '@@@': '',
  };

  /// Very long merchant names
  static const Map<String, String> longNameTestCases = {
    'MCDONALDS RESTAURANT STORE NUMBER 12345 LOCATED AT MAIN STREET PLAZA': 'McDonalds Restaurant',
    'THE VERY LONG MERCHANT NAME THAT EXCEEDS REASONABLE LENGTH FOR DISPLAY #123': 'The Very Long Merchant Name That Exceeds Reasonable Length For Display',
    'A' * 100 + ' #123': 'A' * 100,
  };

  /// International/special format test cases
  static const Map<String, String> internationalTestCases = {
    'IKEA #123': 'IKEA',
    'H&M HENNES & MAURITZ': 'H&M',
    'ALDI #456': 'ALDI',
    'LIDL STORE 789': 'LIDL',
    'UNIQLO #123': 'UNIQLO',
    'MUJI STORE': 'MUJI',
    'DAISO #456': 'DAISO',
  };

  /// Gas station variations
  static const Map<String, String> gasStationTestCases = {
    'SHELL #12345': 'Shell',
    'CHEVRON #67890': 'Chevron',
    'EXXONMOBIL #123': 'ExxonMobil',
    'BP #456': 'BP',
    'MOBIL #789': 'Mobil',
    'TEXACO #012': 'Texaco',
    'CITGO #345': 'Citgo',
    'SUNOCO #678': 'Sunoco',
    'MARATHON #901': 'Marathon',
    'SPEEDWAY #234': 'Speedway',
  };

  /// Restaurant chains
  static const Map<String, String> restaurantTestCases = {
    'SUBWAY #12345': 'Subway',
    'CHIPOTLE MEXICAN GRILL': 'Chipotle Mexican Grill',
    'TACO BELL #123': 'Taco Bell',
    'KFC #456': 'KFC',
    'PIZZA HUT #789': 'Pizza Hut',
    'DOMINOS #012': 'Dominos',
    'DUNKIN #345': 'Dunkin',
    'PANERA BREAD': 'Panera Bread',
    'CHICK-FIL-A #678': 'Chick-fil-A',
    'IN-N-OUT #901': 'In-N-Out',
  };

  /// Get all test cases as a single map for comprehensive testing
  static Map<String?, String> getAllTestCases() {
    final allCases = <String?, String>{};
    
    allCases.addAll(franchiseTestCases);
    allCases.addAll(caseNormalizationTestCases);
    allCases.addAll(specialCharacterTestCases);
    allCases.addAll(abbreviationTestCases);
    allCases.addAll(locationSuffixTestCases);
    allCases.addAll(longNameTestCases);
    allCases.addAll(internationalTestCases);
    allCases.addAll(gasStationTestCases);
    allCases.addAll(restaurantTestCases);
    allCases.addAll(edgeCaseTestCases);
    
    // Add already clean cases (should return unchanged)
    for (final clean in alreadyCleanTestCases) {
      allCases[clean] = clean;
    }
    
    return allCases;
  }

  /// Performance test dataset - large number of random variations
  static List<String> generatePerformanceTestData({int count = 1000}) {
    final merchants = <String>[];
    final baseNames = [
      'McDonalds', 'Starbucks', 'Walmart', 'Target', 'CVS',
      'Costco', 'Home Depot', 'Best Buy', 'Kroger', 'Safeway',
    ];
    
    for (int i = 0; i < count; i++) {
      final base = baseNames[i % baseNames.length];
      final storeNum = (i * 123) % 10000;
      
      // Generate various formats
      switch (i % 5) {
        case 0:
          merchants.add('${base.toUpperCase()} #$storeNum');
          break;
        case 1:
          merchants.add('$base Store #$storeNum');
          break;
        case 2:
          merchants.add('${base.toUpperCase()} - STORE $storeNum');
          break;
        case 3:
          merchants.add('$base ${storeNum.toString().padLeft(5, '0')}');
          break;
        case 4:
          merchants.add(base);
          break;
      }
    }
    
    return merchants;
  }
}