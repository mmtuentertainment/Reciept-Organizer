import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/merchant_dictionary.dart';
import 'interfaces/i_merchant_normalization_service.dart';

/// Service for normalizing merchant names from OCR text
/// 
/// Applies normalization rules in order:
/// 1. Direct abbreviation lookup
/// 2. Franchise pattern matching  
/// 3. Suffix removal
/// 4. Case normalization
/// 5. Special character handling
class MerchantNormalizationService implements IMerchantNormalizationService {
  final Map<String, String> _normalizationCache = {};
  static const int _maxCacheSize = 1000;

  /// Normalizes a merchant name according to defined rules
  /// Returns the normalized name, preserving original if no rules apply
  @override
  String normalize(String? merchantName) {
    if (merchantName == null || merchantName.trim().isEmpty) {
      return '';
    }

    final trimmed = merchantName.trim();
    
    // Check cache first
    if (_normalizationCache.containsKey(trimmed)) {
      return _normalizationCache[trimmed]!;
    }

    // Apply normalization rules
    var normalized = trimmed;
    
    // 1. Check direct abbreviations
    final upperCase = normalized.toUpperCase();
    if (MerchantDictionary.abbreviations.containsKey(upperCase)) {
      normalized = MerchantDictionary.abbreviations[upperCase]!;
    } else {
      // 2. Apply franchise patterns
      normalized = _applyFranchisePatterns(normalized);
      
      // 3. Remove location suffixes
      normalized = _removeSuffixes(normalized);
      
      // 4. Fix case for known proper nouns
      normalized = _applyProperNounCases(normalized);
      
      // 5. Apply general case normalization if not handled above
      if (normalized == normalized.toUpperCase()) {
        normalized = _normalizeCase(normalized);
      }
    }

    // Clean up any extra spaces
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Manage cache size
    if (_normalizationCache.length >= _maxCacheSize) {
      _normalizationCache.clear();
    }
    
    _normalizationCache[trimmed] = normalized;
    return normalized;
  }

  /// Applies franchise pattern matching
  String _applyFranchisePatterns(String merchant) {
    for (final pattern in MerchantDictionary.franchisePatterns) {
      if (pattern.regex.hasMatch(merchant)) {
        return pattern.normalizedName;
      }
    }
    return merchant;
  }

  /// Removes common suffixes like location indicators
  String _removeSuffixes(String merchant) {
    var result = merchant;
    for (final suffixPattern in MerchantDictionary.suffixesToRemove) {
      result = result.replaceAll(RegExp(suffixPattern, caseSensitive: false), '');
    }
    return result.trim();
  }

  /// Applies proper noun case rules
  String _applyProperNounCases(String merchant) {
    final upperCase = merchant.toUpperCase();
    if (MerchantDictionary.properNounCases.containsKey(upperCase)) {
      return MerchantDictionary.properNounCases[upperCase]!;
    }
    return merchant;
  }

  /// Normalizes case for general text (Title Case with special handling)
  String _normalizeCase(String text) {
    if (text.isEmpty) return text;

    // Check if it's a known uppercase word
    if (MerchantDictionary.uppercaseWords.contains(text)) {
      return text;
    }

    // Split by spaces and handle each word
    final words = text.split(' ');
    final normalizedWords = <String>[];

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      if (word.isEmpty) continue;

      // Keep uppercase for known acronyms
      if (MerchantDictionary.uppercaseWords.contains(word)) {
        normalizedWords.add(word);
      }
      // Lowercase for known articles (except first word)
      else if (i > 0 && MerchantDictionary.lowercaseWords.contains(word.toLowerCase())) {
        normalizedWords.add(word.toLowerCase());
      }
      // Title case for regular words
      else {
        normalizedWords.add(_toTitleCase(word));
      }
    }

    return normalizedWords.join(' ');
  }

  /// Converts a single word to title case
  String _toTitleCase(String word) {
    if (word.isEmpty) return word;
    
    // Handle words with apostrophes (e.g., McDonald's)
    if (word.contains("'")) {
      final parts = word.split("'");
      return parts.map((part) => _capitalizeFirst(part)).join("'");
    }
    
    // Handle hyphenated words (e.g., Chick-fil-A)
    if (word.contains('-')) {
      final parts = word.split('-');
      return parts.map((part) => _capitalizeFirst(part)).join('-');
    }
    
    // Handle dots (e.g., T.J.Maxx)
    if (word.contains('.')) {
      final parts = word.split('.');
      return parts.map((part) => _capitalizeFirst(part)).join('.');
    }

    return _capitalizeFirst(word);
  }

  /// Capitalizes the first letter of a word
  String _capitalizeFirst(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  /// Clears the normalization cache
  @override
  void clearCache() {
    _normalizationCache.clear();
  }

  /// Gets current cache size for monitoring
  @override
  int get cacheSize => _normalizationCache.length;
}

/// Provider for MerchantNormalizationService
final merchantNormalizationServiceProvider = Provider<MerchantNormalizationService>((ref) {
  return MerchantNormalizationService();
});