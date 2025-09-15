import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Test utilities for authentication testing
/// Uses test user isolation with production Supabase

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockAuthResponse extends Mock implements AuthResponse {}
class MockSession extends Mock implements Session {}
class MockUser extends Mock implements User {}

/// Test user factory
class TestUserFactory {
  static const String testPrefix = 'test_';

  /// Generate test user email
  static String generateTestEmail() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${testPrefix}user_$timestamp@example.com';
  }

  /// Create mock authenticated user
  static User createMockUser({
    String? id,
    String? email,
    Map<String, dynamic>? metadata,
  }) {
    final mockUser = MockUser();
    final userId = id ?? 'test-user-${DateTime.now().millisecondsSinceEpoch}';
    final userEmail = email ?? generateTestEmail();

    when(() => mockUser.id).thenReturn(userId);
    when(() => mockUser.email).thenReturn(userEmail);
    when(() => mockUser.userMetadata).thenReturn({
      'test_user': true,
      'created_for_testing': true,
      ...?metadata,
    });
    when(() => mockUser.createdAt).thenReturn(DateTime.now().toIso8601String());

    return mockUser;
  }

  /// Create mock session
  static Session createMockSession({
    User? user,
    String? accessToken,
    int expiresIn = 3600,
  }) {
    final mockSession = MockSession();
    final mockUser = user ?? createMockUser();
    final token = accessToken ?? 'test-access-token-${DateTime.now().millisecondsSinceEpoch}';

    when(() => mockSession.user).thenReturn(mockUser);
    when(() => mockSession.accessToken).thenReturn(token);
    when(() => mockSession.refreshToken).thenReturn('test-refresh-token');
    when(() => mockSession.expiresIn).thenReturn(expiresIn);
    when(() => mockSession.tokenType).thenReturn('bearer');
    when(() => mockSession.expiresAt).thenReturn(
      DateTime.now().add(Duration(seconds: expiresIn)).millisecondsSinceEpoch ~/ 1000,
    );

    return mockSession;
  }
}

/// Auth test helpers
class AuthTestHelpers {
  /// Setup Supabase auth mocks
  static MockSupabaseClient setupAuthMocks({
    Session? initialSession,
    bool isAuthenticated = false,
  }) {
    final mockClient = MockSupabaseClient();
    final mockAuth = MockGoTrueClient();

    when(() => mockClient.auth).thenReturn(mockAuth);

    // Mock current session
    final session = isAuthenticated
        ? (initialSession ?? TestUserFactory.createMockSession())
        : null;

    when(() => mockAuth.currentSession).thenReturn(session);
    when(() => mockAuth.currentUser).thenReturn(session?.user);

    // Mock auth methods
    when(() => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async {
      final mockResponse = MockAuthResponse();
      when(() => mockResponse.session).thenReturn(
        TestUserFactory.createMockSession(),
      );
      when(() => mockResponse.user).thenReturn(
        TestUserFactory.createMockUser(),
      );
      return mockResponse;
    });

    when(() => mockAuth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async {
      final mockResponse = MockAuthResponse();
      when(() => mockResponse.session).thenReturn(
        TestUserFactory.createMockSession(),
      );
      when(() => mockResponse.user).thenReturn(
        TestUserFactory.createMockUser(),
      );
      return mockResponse;
    });

    when(() => mockAuth.signOut()).thenAnswer((_) async {});

    // Mock session refresh
    when(() => mockAuth.refreshSession()).thenAnswer((_) async {
      final mockResponse = MockAuthResponse();
      when(() => mockResponse.session).thenReturn(
        TestUserFactory.createMockSession(),
      );
      return mockResponse;
    });

    // Mock auth state changes
    when(() => mockAuth.onAuthStateChange).thenAnswer((_) {
      return Stream.value((
        AuthChangeEvent.signedIn,
        TestUserFactory.createMockSession(),
      ));
    });

    return mockClient;
  }

  /// Verify auth was called correctly
  static void verifyAuthCalled(MockGoTrueClient mockAuth, {
    bool signIn = false,
    bool signUp = false,
    bool signOut = false,
    bool refresh = false,
  }) {
    if (signIn) {
      verify(() => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).called(1);
    }

    if (signUp) {
      verify(() => mockAuth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).called(1);
    }

    if (signOut) {
      verify(() => mockAuth.signOut()).called(1);
    }

    if (refresh) {
      verify(() => mockAuth.refreshSession()).called(1);
    }
  }

  /// Clean up test users (for integration tests)
  static Future<void> cleanupTestUsers(SupabaseClient client) async {
    try {
      // Delete test user data
      await client.from('receipts').delete().match({
        'user_id': client.auth.currentUser?.id,
      });

      // Note: Cannot delete auth.users directly from client
      // This would need to be done via MCP commands or admin API
    } catch (e) {
      print('Error cleaning up test users: $e');
    }
  }
}

/// Test data generators
class AuthTestData {
  static const validTestEmail = 'test_valid@example.com';
  static const validTestPassword = 'TestPassword123!';

  static const invalidEmail = 'invalid-email';
  static const weakPassword = '123';

  static Map<String, dynamic> get validSignupData => {
        'email': TestUserFactory.generateTestEmail(),
        'password': validTestPassword,
      };

  static Map<String, dynamic> get validLoginData => {
        'email': validTestEmail,
        'password': validTestPassword,
      };

  static Map<String, dynamic> get invalidEmailData => {
        'email': invalidEmail,
        'password': validTestPassword,
      };

  static Map<String, dynamic> get weakPasswordData => {
        'email': TestUserFactory.generateTestEmail(),
        'password': weakPassword,
      };
}

/// Test expectations
class AuthTestExpectations {
  /// Expect valid session
  static void expectValidSession(Session? session) {
    expect(session, isNotNull);
    expect(session!.accessToken, isNotEmpty);
    expect(session.user, isNotNull);
    expect(session.expiresIn, greaterThan(0));
  }

  /// Expect valid user
  static void expectValidUser(User? user) {
    expect(user, isNotNull);
    expect(user!.id, isNotEmpty);
    expect(user.email, contains('@'));
  }

  /// Expect test user metadata
  static void expectTestUserMetadata(User user) {
    expect(user.userMetadata?['test_user'], isTrue);
    expect(user.email, startsWith(TestUserFactory.testPrefix));
  }
}