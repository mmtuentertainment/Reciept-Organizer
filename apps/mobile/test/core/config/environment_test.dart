import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/core/config/environment.dart';

void main() {
  group('Environment Configuration', () {
    test('should use default production URL when no override', () {
      // This test verifies the default behavior
      expect(Environment.apiUrl, equals('https://receipt-organizer-api.vercel.app'));
    });
    
    test('should correctly report development mode', () {
      // Default should be false
      expect(Environment.isDevelopment, isFalse);
    });
    
    test('logConfiguration should not throw', () {
      // Ensure logging works without errors
      expect(() => Environment.logConfiguration(), returnsNormally);
    });
  });
}