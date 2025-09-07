/// Interface for merchant normalization service
abstract class IMerchantNormalizationService {
  /// Normalizes a merchant name according to defined rules
  /// Returns the normalized name, preserving original if no rules apply
  String normalize(String? merchantName);
  
  /// Clears the normalization cache
  void clearCache();
  
  /// Gets current cache size for monitoring
  int get cacheSize;
}