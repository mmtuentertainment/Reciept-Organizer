import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Mock user for testing
final mockUser = User(
  id: 'test-user-1',
  email: 'test@example.com',
  appMetadata: {'provider': 'email'},
  userMetadata: {
    'full_name': 'Test User',
    'username': 'testuser1',
  },
  aud: 'authenticated',
  createdAt: '2024-01-01T00:00:00Z',
);

/// Mock admin user for testing
final mockAdminUser = User(
  id: 'admin-user-1',
  email: 'admin@example.com',
  appMetadata: {'provider': 'email', 'role': 'admin'},
  userMetadata: {
    'full_name': 'Admin User',
    'username': 'adminuser',
  },
  aud: 'authenticated',
  createdAt: '2024-01-01T00:00:00Z',
);

/// Mock session for testing
final mockSession = Session(
  accessToken: 'mock-access-token',
  refreshToken: 'mock-refresh-token',
  expiresIn: 3600,
  tokenType: 'bearer',
  user: mockUser,
);

/// Mock Supabase client for testing
class MockSupabaseClient extends Mock implements SupabaseClient {
  final MockGoTrueClient auth = MockGoTrueClient();

  @override
  SupabaseStorageClient get storage => MockStorageClient();

  @override
  SupabaseQueryBuilder from(String table) => MockQueryBuilder();
}

/// Mock auth client
class MockGoTrueClient extends Mock implements GoTrueClient {
  Session? _currentSession = mockSession;
  User? _currentUser = mockUser;

  @override
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
    String? captchaToken,
  }) async {
    if (email == 'test@example.com' && password == 'TestPassword123!') {
      return AuthResponse(session: mockSession, user: mockUser);
    }
    throw AuthException('Invalid credentials');
  }

  @override
  Future<void> signOut() async {
    _currentSession = null;
    _currentUser = null;
  }

  @override
  Session? get currentSession => _currentSession;

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<AuthState> get onAuthStateChange => Stream.value(
    AuthState(AuthChangeEvent.signedIn, mockSession),
  );
}

/// Mock storage client
class MockStorageClient extends Mock implements SupabaseStorageClient {
  @override
  StorageBucket from(String id) => MockStorageBucket();
}

/// Mock storage bucket
class MockStorageBucket extends Mock implements StorageBucket {
  @override
  Future<String> upload(
    String path,
    dynamic file, {
    FileOptions? fileOptions,
    bool? upsert,
  }) async {
    return 'test/path/$path';
  }

  @override
  String getPublicUrl(String path) {
    return 'https://test.storage.url/$path';
  }
}

/// Mock query builder
class MockQueryBuilder extends Mock implements SupabaseQueryBuilder {
  final List<Map<String, dynamic>> _mockData = [];

  @override
  PostgrestFilterBuilder select([String? columns]) {
    return MockFilterBuilder(_mockData);
  }

  @override
  PostgrestFilterBuilder insert(dynamic values) {
    if (values is List) {
      _mockData.addAll(values);
    } else {
      _mockData.add(values);
    }
    return MockFilterBuilder(_mockData);
  }
}

/// Mock filter builder
class MockFilterBuilder extends Mock implements PostgrestFilterBuilder {
  final List<Map<String, dynamic>> data;

  MockFilterBuilder(this.data);

  @override
  PostgrestFilterBuilder eq(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder neq(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder gt(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder order(String column, {bool ascending = false}) => this;

  @override
  PostgrestFilterBuilder limit(int count) => this;

  @override
  Future<PostgrestResponse> execute() async {
    return PostgrestResponse(
      data: data,
      error: null,
      count: data.length,
      status: 200,
    );
  }
}

/// Test helper class for auth testing
class AuthTestHelper {
  static late MockSupabaseClient mockClient;

  /// Setup auth mocks for testing
  static void setupMocks() {
    mockClient = MockSupabaseClient();

    // Initialize Supabase with mock client
    Supabase.instance = Supabase(
      url: 'https://test.supabase.co',
      anonKey: 'test-anon-key',
      client: mockClient,
    );
  }

  /// Simulate user sign in
  static void simulateSignIn({User? user}) {
    final targetUser = user ?? mockUser;
    mockClient.auth._currentUser = targetUser;
    mockClient.auth._currentSession = Session(
      accessToken: 'mock-access-token',
      refreshToken: 'mock-refresh-token',
      expiresIn: 3600,
      tokenType: 'bearer',
      user: targetUser,
    );
  }

  /// Simulate user sign out
  static void simulateSignOut() {
    mockClient.auth._currentUser = null;
    mockClient.auth._currentSession = null;
  }

  /// Simulate session expiry
  static void simulateSessionExpiry() {
    if (mockClient.auth._currentSession != null) {
      // Create expired session
      mockClient.auth._currentSession = Session(
        accessToken: 'expired-token',
        refreshToken: 'expired-refresh',
        expiresIn: -1,
        tokenType: 'bearer',
        user: mockClient.auth._currentUser!,
      );
    }
  }

  /// Create test data
  static Map<String, dynamic> createTestReceipt({
    String? userId,
    String? merchant,
    double? amount,
  }) {
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'user_id': userId ?? 'test-user-1',
      'merchant': merchant ?? 'Test Store',
      'amount': amount ?? 99.99,
      'receipt_date': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// Reset all mocks
  static void resetMocks() {
    mockClient = MockSupabaseClient();
    simulateSignOut();
  }
}

/// Feature flag mock for testing
class FeatureFlagMock {
  static final Map<String, dynamic> _flags = {
    'auth_enabled': false,
    'auth_bypass': true,
    'auth_rollout_percentage': 0,
  };

  static bool isEnabled(String flag) {
    return _flags[flag] == true;
  }

  static dynamic getValue(String flag) {
    return _flags[flag];
  }

  static void setFlag(String flag, dynamic value) {
    _flags[flag] = value;
  }

  static void reset() {
    _flags['auth_enabled'] = false;
    _flags['auth_bypass'] = true;
    _flags['auth_rollout_percentage'] = 0;
  }
}