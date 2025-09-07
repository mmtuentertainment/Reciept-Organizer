/// Merchant dictionary for normalization
/// Contains common vendor mappings and normalization rules
/// 
/// Rules are applied in this order:
/// 1. Direct abbreviation lookup
/// 2. Franchise pattern matching
/// 3. Suffix removal
/// 4. Case normalization
/// 5. Special character handling

class MerchantDictionary {
  /// Common abbreviations to full merchant names
  static const Map<String, String> abbreviations = {
    // Fast food
    'MCD': 'McDonalds',
    'SBUX': 'Starbucks',
    'SBUCKS': 'Starbucks',
    'KFC': 'KFC',
    'BK': 'Burger King',
    'TB': 'Taco Bell',
    'CFA': 'Chick-fil-A',
    
    // Retail
    'TGT': 'Target',
    'WMT': 'Walmart',
    'HD': 'Home Depot',
    'BBY': 'Best Buy',
    'AMZN': 'Amazon',
    'COST': 'Costco',
    'CVS': 'CVS',
    
    // Grocery
    'KR': 'Kroger',
    'SWAY': 'Safeway',
    'WFM': 'Whole Foods',
    'TJ': 'Trader Joes',
    'ALDI': 'ALDI',
    
    // Other
    'WBA': 'Walgreens',
    'LOW': 'Lowes',
    'DG': 'Dollar General',
    'FDX': 'FedEx',
    'UPS': 'UPS',
  };

  /// Common franchise patterns with their normalized forms
  /// Order matters - more specific patterns first
  static const List<FranchisePattern> franchisePatterns = [
    // McDonald's patterns
    FranchisePattern(r'MCDONALDS?\s*(?:#|STORE\s*#?|-)?\s*\d+', 'McDonalds'),
    FranchisePattern(r"MCDONALD'?S?\s*(?:#|STORE\s*#?|-)?\s*\d+", 'McDonalds'),
    FranchisePattern(r'MCD\s*#?\d+', 'McDonalds'),
    
    // Starbucks patterns
    FranchisePattern(r'STARBUCKS\s*(?:#|STORE\s*#?|-)?\s*\d+', 'Starbucks'),
    FranchisePattern(r'STARBUCKS\s+COFFEE\s*(?:#|STORE\s*#?|-)?\s*\d+', 'Starbucks Coffee'),
    FranchisePattern(r'SBUX\s*#?\d+', 'Starbucks'),
    
    // Walmart patterns
    FranchisePattern(r'WAL-?MART\s*(?:#|STORE\s*#?|-)?\s*\d+', 'Walmart'),
    FranchisePattern(r'WALMART\s*(?:#|STORE\s*#?|-)?\s*\d+', 'Walmart'),
    FranchisePattern(r'WALMART\s+SUPERCENTER', 'Walmart Supercenter'),
    FranchisePattern(r'WAL\s*MART\s+STORE\s*\d+', 'Walmart'),
    
    // Target patterns
    FranchisePattern(r'TARGET\s*(?:#|STORE\s*#?|T-)?\s*T?\d+', 'Target'),
    FranchisePattern(r'TGT\s*#?\d+', 'Target'),
    
    // CVS patterns
    FranchisePattern(r'CVS/?PHARM(?:ACY)?\s*(?:#|STORE\s*#?|-)?\s*\d+', 'CVS Pharmacy'),
    FranchisePattern(r'CVS\s*(?:#|STORE\s*#?|-)?\s*\d+', 'CVS'),
    
    // Costco patterns
    FranchisePattern(r'COSTCO\s*(?:#|STORE\s*#?|WHSE\s*#?)?\s*\d+', 'Costco'),
    FranchisePattern(r'COSTCO\s+WHOLESALE', 'Costco Wholesale'),
    FranchisePattern(r'COSTCO\s+GAS\s*(?:#)?\s*\d*', 'Costco Gas'),
    
    // Home Depot patterns
    FranchisePattern(r'(?:THE\s+)?HOME\s+DEPOT\s*(?:#|STORE\s*#?)?\s*\d+', 'The Home Depot'),
    FranchisePattern(r'HD\s*#?\d+', 'Home Depot'),
    
    // Gas stations
    FranchisePattern(r'SHELL\s*(?:#|STATION\s*#?)?\s*\d+', 'Shell'),
    FranchisePattern(r'CHEVRON\s*(?:#|STATION\s*#?)?\s*\d+', 'Chevron'),
    FranchisePattern(r'EXXON\s*MOBIL\s*(?:#)?\s*\d+', 'ExxonMobil'),
    FranchisePattern(r'BP\s*(?:#|STATION\s*#?)?\s*\d+', 'BP'),
    
    // Restaurants
    FranchisePattern(r'SUBWAY\s*(?:#|STORE\s*#?)?\s*\d+', 'Subway'),
    FranchisePattern(r'CHIPOTLE\s+MEXICAN\s+GRILL', 'Chipotle Mexican Grill'),
    FranchisePattern(r'TACO\s+BELL\s*(?:#)?\s*\d+', 'Taco Bell'),
    FranchisePattern(r'PIZZA\s+HUT\s*(?:#)?\s*\d+', 'Pizza Hut'),
    FranchisePattern(r'DOMINOS?\s*(?:#)?\s*\d+', 'Dominos'),
    FranchisePattern(r"DUNKIN'?\s*(?:#)?\s*\d+", 'Dunkin'),
    FranchisePattern(r'CHICK-?FIL-?A\s*(?:#)?\s*\d+', 'Chick-fil-A'),
    FranchisePattern(r'IN-?N-?OUT\s*(?:#)?\s*\d+', 'In-N-Out'),
    FranchisePattern(r"WENDY'?S\s*(?:#)?\s*\d+", "Wendy's"),
    FranchisePattern(r"ARBY'?S\s*(?:#)?\s*\d+", "Arby's"),
    
    // Special format stores
    FranchisePattern(r'7-?ELEVEN\s*(?:#)?\s*\d*', '7-Eleven'),
    FranchisePattern(r"TRADER\s+JOE'?S?", 'Trader Joes'),
    FranchisePattern(r'WHOLE\s+FOODS?', 'Whole Foods'),
    FranchisePattern(r'BEST\s+BUY\s*(?:#)?\s*\d*', 'Best Buy'),
    FranchisePattern(r"DICK'?S\s+SPORTING", "Dick's Sporting"),
    FranchisePattern(r"BJ'?S\s+WHOLESALE", "BJ's Wholesale"),
    FranchisePattern(r'T\.?J\.?\s*MAXX?', 'T.J.Maxx'),
  ];

  /// Suffixes to remove (case insensitive)
  static const List<String> suffixesToRemove = [
    // Location indicators
    r'\s*-\s*[A-Z\s]+(?:ST|AVE|BLVD|RD|PLAZA|MALL|CENTER|DOWNTOWN|NORTH|SOUTH|EAST|WEST)$',
    r'\s*-\s*\d+[A-Z]{2}\s+(?:ST|AVE|BLVD|RD)$',
    r'\s*-\s*INSIDE\s+\w+$',
    r'\s*-\s*24HR$',
    r'\s*-\s*24\s*HRS?$',
    
    // Store type indicators (unless part of official name)
    r'\s+STORE$',
    r'\s+RESTAURANT$',
    r'\s+MARKET$',
    r'\s+STATION$',
    
    // Generic number patterns at end
    r'\s+\d{5,}$',  // 5+ digits at end
    r'\s+00\d{3,}$', // Leading zeros pattern
  ];

  /// Special case handling for proper nouns
  static const Map<String, String> properNounCases = {
    // Maintain specific capitalizations
    'MCDONALDS': 'McDonalds',
    'MCDONALD\'S': 'McDonalds',
    'O\'REILLY': 'O\'Reilly',
    'T.J.MAXX': 'T.J.Maxx',
    'TJMAXX': 'T.J.Maxx',
    'AT&T': 'AT&T',
    'H&M': 'H&M',
    'IKEA': 'IKEA',
    'ALDI': 'ALDI',
    'LIDL': 'LIDL',
    'UNIQLO': 'UNIQLO',
    'MUJI': 'MUJI',
    'DAISO': 'DAISO',
    'CVS': 'CVS',
    'UPS': 'UPS',
    'USPS': 'USPS',
    'KFC': 'KFC',
    'BP': 'BP',
    "BJ'S": "BJ's",
  };

  /// Words that should remain uppercase
  static const Set<String> uppercaseWords = {
    'CVS', 'UPS', 'USPS', 'KFC', 'BP', 'AT&T', 'H&M', 
    'IKEA', 'ALDI', 'LIDL', 'UNIQLO', 'MUJI', 'DAISO',
    'LLC', 'INC', 'CO', 'CORP', 'USA', 'UK',
  };

  /// Words that should be lowercase in title case
  static const Set<String> lowercaseWords = {
    'and', 'or', 'the', 'of', 'in', 'at', 'by', 'for', 'with',
  };
}

/// Pattern matching for franchise normalization
class FranchisePattern {
  final String pattern;
  final String normalizedName;

  const FranchisePattern(this.pattern, this.normalizedName);
  
  RegExp get regex => RegExp(pattern, caseSensitive: false);
}