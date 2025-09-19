import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/core/services/rate_limiter_service.dart';
import 'package:receipt_organizer/core/services/enhanced_secure_storage_service.dart';
import 'package:receipt_organizer/core/services/input_validation_service.dart';
import '../helpers/platform_channel_mocks.dart';

void main() {
  group('Security Verification Tests', () {
    group('Rate Limiting', () {
      late RateLimiterService rateLimiter;

      setUp(() {
        rateLimiter = RateLimiterService(
          config: const RateLimiterConfig(
            maxRequests: 5,
            window: Duration(seconds: 10),
            burstLimit: 2,
            burstWindow: Duration(seconds: 1),
          ),
        );
      });

      test('should allow requests within limit', () async {
        final result1 = await rateLimiter.checkLimit('user1');
        expect(result1.allowed, isTrue);
        expect(result1.remainingRequests, equals(4));

        final result2 = await rateLimiter.checkLimit('user1');
        expect(result2.allowed, isTrue);
        expect(result2.remainingRequests, equals(3));
      });

      test('should block requests exceeding burst limit', () async {
        // First two requests should succeed
        await rateLimiter.checkLimit('user2');
        await rateLimiter.checkLimit('user2');

        // Third request within burst window should fail
        final result = await rateLimiter.checkLimit('user2');
        expect(result.allowed, isFalse);
        expect(result.reason, contains('Burst limit exceeded'));
      });

      test('should block requests exceeding window limit', () async {
        // Use up all requests
        for (int i = 0; i < 5; i++) {
          await rateLimiter.checkLimit('user3');
          await Future.delayed(const Duration(milliseconds: 500));
        }

        // Next request should be blocked
        final result = await rateLimiter.checkLimit('user3');
        expect(result.allowed, isFalse);
        expect(result.reason, contains('Rate limit exceeded'));
      });

      test('should track violations and apply exponential backoff', () async {
        final limiter = RateLimiterService(
          config: const RateLimiterConfig(
            maxRequests: 1,
            window: Duration(seconds: 1),
          ),
        );

        // First violation
        await limiter.checkLimit('violator');
        var result = await limiter.checkLimit('violator');
        expect(result.allowed, isFalse);

        // Multiple violations should trigger blocking
        for (int i = 0; i < 3; i++) {
          await Future.delayed(const Duration(seconds: 1));
          await limiter.checkLimit('violator');
          result = await limiter.checkLimit('violator');
        }

        // Should be blocked for extended period
        expect(result.allowed, isFalse);
        expect(result.retryAfter.inMinutes, greaterThan(0));
      });

      test('should handle different endpoints independently', () async {
        final authLimiter = ApiRateLimiter.getForEndpoint('/auth/login');
        final ocrLimiter = ApiRateLimiter.getForEndpoint('/ocr/process');

        // Auth endpoint has stricter limits
        for (int i = 0; i < 5; i++) {
          await authLimiter.checkLimit('user4');
        }
        final authResult = await authLimiter.checkLimit('user4');
        expect(authResult.allowed, isFalse);

        // OCR endpoint should still allow requests
        final ocrResult = await ocrLimiter.checkLimit('user4');
        expect(ocrResult.allowed, isTrue);
      });
    });

    group('Input Validation', () {
      test('should validate email correctly', () {
        // Valid emails
        expect(InputValidationService.validateEmail('user@example.com').isValid, isTrue);
        expect(InputValidationService.validateEmail('test.user+tag@domain.co.uk').isValid, isTrue);

        // Invalid emails
        expect(InputValidationService.validateEmail('').isValid, isFalse);
        expect(InputValidationService.validateEmail('notanemail').isValid, isFalse);
        expect(InputValidationService.validateEmail('@example.com').isValid, isFalse);
        expect(InputValidationService.validateEmail('user@').isValid, isFalse);
      });

      test('should detect SQL injection attempts', () {
        final maliciousInputs = [
          "'; DROP TABLE users; --",
          "1' OR '1'='1",
          "admin' --",
          "' UNION SELECT * FROM passwords --",
        ];

        for (final input in maliciousInputs) {
          final result = InputValidationService.validateVendorName(input);
          expect(result.isValid, isFalse);
          expect(result.isSuspicious, isTrue);
        }
      });

      test('should detect XSS attempts', () {
        final xssInputs = [
          '<script>alert("XSS")</script>',
          '<img src=x onerror=alert("XSS")>',
          'javascript:alert("XSS")',
          '<iframe src="evil.com"></iframe>',
          '<div onmouseover="alert(1)">test</div>',
        ];

        for (final input in xssInputs) {
          final result = InputValidationService.validateNotes(input);
          expect(result.isValid, isFalse);
          expect(result.isSuspicious, isTrue);
        }
      });

      test('should validate and sanitize vendor names', () {
        // Valid vendor names
        var result = InputValidationService.validateVendorName('Walmart');
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals('Walmart'));

        result = InputValidationService.validateVendorName("O'Reilly Auto Parts");
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals("O&#39;Reilly Auto Parts"));

        // HTML entities should be escaped
        result = InputValidationService.validateVendorName('Store <Test>');
        expect(result.isValid, isTrue);
        expect(result.sanitizedValue, equals('Store &lt;Test&gt;'));

        // Invalid vendor names
        expect(InputValidationService.validateVendorName('').isValid, isFalse);
        expect(InputValidationService.validateVendorName('A').isValid, isFalse);
        expect(InputValidationService.validateVendorName('A' * 101).isValid, isFalse);
      });

      test('should validate amounts correctly', () {
        // Valid amounts
        var result = InputValidationService.validateAmount('99.99');
        expect(result.isValid, isTrue);
        expect(result.parsedValue, equals(99.99));

        result = InputValidationService.validateAmount('\$1,234.56');
        expect(result.isValid, isTrue);
        expect(result.parsedValue, equals(1234.56));

        // With constraints
        result = InputValidationService.validateAmount('50', min: 0, max: 100);
        expect(result.isValid, isTrue);

        result = InputValidationService.validateAmount('150', min: 0, max: 100);
        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('must not exceed'));

        result = InputValidationService.validateAmount('-10', min: 0);
        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('must be at least'));

        // Invalid amounts
        expect(InputValidationService.validateAmount('').isValid, isFalse);
        expect(InputValidationService.validateAmount('abc').isValid, isFalse);
        expect(InputValidationService.validateAmount('12.345', decimalPlaces: 2).isValid, isFalse);
      });

      test('should validate phone numbers', () {
        // Valid phone numbers
        expect(InputValidationService.validatePhone('+1 234 567 8900').isValid, isTrue);
        expect(InputValidationService.validatePhone('(555) 123-4567').isValid, isTrue);
        expect(InputValidationService.validatePhone('9876543210').isValid, isTrue);

        // Invalid phone numbers
        expect(InputValidationService.validatePhone('').isValid, isFalse);
        expect(InputValidationService.validatePhone('123').isValid, isFalse);
        expect(InputValidationService.validatePhone('phone-number').isValid, isFalse);
      });

      test('should validate dates', () {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final tomorrow = now.add(const Duration(days: 1));
        final yearAgo = now.subtract(const Duration(days: 365));

        // Valid dates
        expect(InputValidationService.validateDate(now).isValid, isTrue);
        expect(InputValidationService.validateDate(yesterday).isValid, isTrue);

        // Future dates not allowed by default
        expect(InputValidationService.validateDate(tomorrow).isValid, isFalse);

        // Future dates allowed when specified
        expect(
          InputValidationService.validateDate(tomorrow, allowFuture: true).isValid,
          isTrue,
        );

        // Date range constraints
        expect(
          InputValidationService.validateDate(
            yearAgo,
            minDate: now.subtract(const Duration(days: 30)),
          ).isValid,
          isFalse,
        );
      });

      test('should validate file paths', () {
        // Valid paths
        expect(InputValidationService.validateFilePath('/path/to/file.jpg').isValid, isTrue);
        expect(InputValidationService.validateFilePath('C:\\Users\\file.pdf').isValid, isTrue);

        // Path traversal attempts
        expect(InputValidationService.validateFilePath('../../../etc/passwd').isValid, isFalse);
        expect(InputValidationService.validateFilePath('~/sensitive/file').isValid, isFalse);

        // Null byte injection
        expect(InputValidationService.validateFilePath('file.jpg\x00.exe').isValid, isFalse);
      });

      test('should validate forms with multiple fields', () {
        final formData = {
          'email': 'user@example.com',
          'amount': '99.99',
          'vendor': 'Test Store',
          'notes': 'Some notes',
        };

        final validators = {
          'email': (value) => InputValidationService.validateEmail(value),
          'amount': (value) => InputValidationService.validateAmount(value),
          'vendor': (value) => InputValidationService.validateVendorName(value),
          'notes': (value) => InputValidationService.validateNotes(value),
        };

        final result = InputValidationService.validateForm(formData, validators: validators);
        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
        expect(result.sanitizedData['email'], equals('user@example.com'));

        // Form with errors
        formData['email'] = 'invalid-email';
        formData['amount'] = 'not-a-number';

        final errorResult = InputValidationService.validateForm(formData, validators: validators);
        expect(errorResult.isValid, isFalse);
        expect(errorResult.errors.length, equals(2));
        expect(errorResult.errors.containsKey('email'), isTrue);
        expect(errorResult.errors.containsKey('amount'), isTrue);
      });
    });

    group('Secure Storage', () {
      late EnhancedSecureStorageService storage;
      late SecureCredentialsManager credentials;

      setUp(() {
        setupPlatformChannelMocks();
        storage = EnhancedSecureStorageService();
        credentials = SecureCredentialsManager(storage);
      });

      test('should store and retrieve encrypted data', () async {
        await storage.storeSecure(
          key: 'test_key',
          value: 'sensitive_value',
          category: EnhancedSecureStorageService.categoryApi,
        );

        final retrieved = await storage.retrieveSecure(
          key: 'test_key',
          category: EnhancedSecureStorageService.categoryApi,
        );

        expect(retrieved, equals('sensitive_value'));
      });

      test('should handle API credentials securely', () async {
        await credentials.storeApiCredentials(
          service: 'openai',
          apiKey: 'sk-test-key-123',
          apiSecret: 'secret-456',
        );

        final creds = await credentials.getApiCredentials('openai');
        expect(creds, isNotNull);
        expect(creds!.apiKey, equals('sk-test-key-123'));
        expect(creds.apiSecret, equals('secret-456'));
      });

      test('should handle auth tokens', () async {
        await credentials.storeAuthToken(
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
          refreshToken: 'refresh-token-123',
        );

        final tokens = await credentials.getAuthTokens();
        expect(tokens, isNotNull);
        expect(tokens!.accessToken, equals('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'));
        expect(tokens.refreshToken, equals('refresh-token-123'));
      });

      test('should clear category data', () async {
        await storage.storeSecure(
          key: 'api_key1',
          value: 'value1',
          category: EnhancedSecureStorageService.categoryApi,
        );

        await storage.storeSecure(
          key: 'api_key2',
          value: 'value2',
          category: EnhancedSecureStorageService.categoryApi,
        );

        await storage.storeSecure(
          key: 'auth_token',
          value: 'token',
          category: EnhancedSecureStorageService.categoryAuth,
        );

        await storage.clearCategory(EnhancedSecureStorageService.categoryApi);

        // API data should be cleared
        var result = await storage.retrieveSecure(
          key: 'api_key1',
          category: EnhancedSecureStorageService.categoryApi,
        );
        expect(result, isNull);

        // Auth data should remain
        result = await storage.retrieveSecure(
          key: 'auth_token',
          category: EnhancedSecureStorageService.categoryAuth,
        );
        expect(result, equals('token'));
      });

      test('should maintain audit log', () async {
        await storage.storeSecure(
          key: 'audit_test',
          value: 'test_value',
          category: EnhancedSecureStorageService.categoryApi,
        );

        await storage.retrieveSecure(
          key: 'audit_test',
          category: EnhancedSecureStorageService.categoryApi,
        );

        await storage.deleteSecure(
          key: 'audit_test',
          category: EnhancedSecureStorageService.categoryApi,
        );

        final auditLog = await storage.getAuditLog();
        expect(auditLog.length, greaterThanOrEqualTo(3));

        // Should have store, retrieve, and delete actions
        final actions = auditLog.map((e) => e['action']).toList();
        expect(actions, contains('store'));
        expect(actions, contains('retrieve'));
        expect(actions, contains('delete'));
      });

      test('should check storage availability', () async {
        final isAvailable = await storage.isAvailable();
        expect(isAvailable, isTrue);
      });
    });

    group('Integration - Security Pipeline', () {
      test('complete security flow for sensitive operation', () async {
        // 1. Validate input
        const userInput = 'Test Vendor';
        final validationResult = InputValidationService.validateVendorName(userInput);
        expect(validationResult.isValid, isTrue);

        // 2. Check rate limit
        final rateLimiter = RateLimiterService();
        final rateLimitResult = await rateLimiter.checkLimit('test-user');
        expect(rateLimitResult.allowed, isTrue);

        // 3. Store sensitive data securely
        final storage = EnhancedSecureStorageService();
        await storage.storeSecure(
          key: 'vendor_name',
          value: validationResult.sanitizedValue!,
          category: EnhancedSecureStorageService.categoryPersonal,
        );

        // 4. Retrieve and verify
        final retrieved = await storage.retrieveSecure(
          key: 'vendor_name',
          category: EnhancedSecureStorageService.categoryPersonal,
        );
        expect(retrieved, isNotNull);
      });
    });
  });
}