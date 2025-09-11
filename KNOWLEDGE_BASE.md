# Receipt Organizer Knowledge Base
<!-- @poml:meta
  type: "knowledge-base"
  version: "1.0.0"
  created: "2025-01-11"
  purpose: "Comprehensive knowledge base for offline-first to hybrid cloud migration"
-->

## 📚 Master Context and Relationships
<!-- @poml:context:master
  framework: "Flutter + Supabase + Vercel"
  pattern: "Hybrid Cloud with Offline-First Fallback"
  migration: "17-day phased approach"
-->

### Project Overview
- **Current State**: Offline-first Flutter app with 131 failing tests
- **Target State**: Hybrid cloud architecture with Supabase backend
- **Root Cause**: path_provider MissingPluginException in test environment
- **Solution**: Mock-first testing with cloud synchronization

### Key Discoveries
1. **Test Failures**: 131 tests fail due to file system dependencies
2. **Architecture Mismatch**: Offline-first conflicts with mobile app requirements
3. **Testing Strategy**: Mock services eliminate file system dependencies
4. **Hybrid Approach**: Local SQLite cache + Supabase cloud = optimal solution

## 🔧 Technology Stack Documentation

### Flutter & Dart (v3.24+)
<!-- @poml:tech:flutter
  version: "3.24+"
  state-management: "Riverpod 2.4+"
  testing: "flutter_test, mockito"
-->

#### Key Patterns
```dart
// Riverpod State Management
final receiptProvider = StateNotifierProvider<ReceiptNotifier, ReceiptState>((ref) {
  return ReceiptNotifier(ref.read(repositoryProvider));
});

// Repository Pattern
abstract class IReceiptRepository {
  Future<List<Receipt>> getAllReceipts();
  Future<Receipt> createReceipt(Receipt receipt);
}

// Mock for Testing
class MockReceiptRepository implements IReceiptRepository {
  final List<Receipt> _receipts = [];
  
  @override
  Future<List<Receipt>> getAllReceipts() async => _receipts;
}
```

### Supabase (v2.10.0)
<!-- @poml:tech:supabase
  sdk: "supabase_flutter 2.10.0"
  features: ["Auth", "Database", "Storage", "Realtime"]
-->

#### Configuration
```dart
// Initialize Supabase
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_ANON_KEY',
  authOptions: FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce,
  ),
  realtimeClientOptions: RealtimeClientOptions(
    logLevel: RealtimeLogLevel.info,
  ),
  storageOptions: StorageFileApi(
    bucketId: 'receipts',
  ),
);

// Database Schema
CREATE TABLE receipts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),
  merchant_name TEXT,
  receipt_date DATE,
  total_amount DECIMAL(10,2),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

// Row Level Security
ALTER TABLE receipts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own receipts"
ON receipts FOR ALL
USING (auth.uid() = user_id);
```

### Vercel Deployment
<!-- @poml:tech:vercel
  framework: "Next.js 15.5.2"
  runtime: "Edge Runtime"
  features: ["Serverless", "Edge Functions", "Analytics"]
-->

#### API Routes
```typescript
// app/api/validate/route.ts
import { NextRequest, NextResponse } from 'next/server';

export async function POST(request: NextRequest) {
  const { receipts } = await request.json();
  
  // Validation logic
  const errors = validateReceipts(receipts);
  
  return NextResponse.json({
    isValid: errors.length === 0,
    errors,
  });
}

// Rate Limiting with Upstash
import { rateLimit } from '@/lib/ratelimit';

const { success } = await rateLimit(request, 'validation');
if (!success) {
  return NextResponse.json(
    { error: 'Too many requests' },
    { status: 429 }
  );
}
```

### SQLite & Sqflite
<!-- @poml:tech:sqlite
  package: "sqflite"
  version: "2.3.0"
  usage: "Local caching layer"
-->

#### Implementation
```dart
// Local Database
class LocalDatabase {
  static const String _databaseName = 'receipts.db';
  static const int _databaseVersion = 1;
  
  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE receipts (
            id TEXT PRIMARY KEY,
            merchant_name TEXT,
            receipt_date TEXT,
            total_amount REAL,
            sync_status TEXT,
            sync_version INTEGER
          )
        ''');
        
        // Create indexes for performance
        await db.execute(
          'CREATE INDEX idx_sync_status ON receipts (sync_status)'
        );
      },
    );
  }
}
```

## 🏗️ Codebase Patterns & Examples

### Repository Pattern with Strategy
```dart
// From: lib/data/repositories/receipt_repository.dart
class HybridReceiptRepository implements IReceiptRepository {
  final LocalReceiptRepository _local;
  final CloudReceiptRepository _cloud;
  final ConnectivityService _connectivity;
  
  @override
  Future<List<Receipt>> getAllReceipts() async {
    if (await _connectivity.isOnline()) {
      try {
        final cloudReceipts = await _cloud.getAllReceipts();
        await _local.cacheReceipts(cloudReceipts);
        return cloudReceipts;
      } catch (e) {
        // Fallback to local on cloud failure
        return _local.getAllReceipts();
      }
    }
    return _local.getAllReceipts();
  }
}
```

### State Management with Riverpod
```dart
// From: lib/features/capture/providers/capture_provider.dart
class CaptureNotifier extends StateNotifier<CaptureState> {
  final OCRService _ocrService;
  final RetrySessionManager _sessionManager;
  
  Future<bool> processCapture(
    Uint8List imageData, {
    EdgeDetectionResult? edgeDetection,
  }) async {
    state = state.copyWith(isProcessing: true);
    
    try {
      final result = await _ocrService.processReceipt(imageData);
      final failure = _ocrService.detectFailure(result, imageData);
      
      if (failure.isFailure) {
        state = state.copyWith(
          isRetryMode: true,
          lastFailureReason: failure.reason,
        );
        return false;
      }
      
      state = state.copyWith(
        lastProcessingResult: result,
        clearFailure: true,
      );
      return true;
    } catch (e) {
      // Handle error
      return false;
    }
  }
}
```

### Mock Services for Testing
```dart
// From: test/helpers/provider_test_helpers.dart
class MockImageStorageService implements IImageStorageService {
  final Map<String, Uint8List> _storage = {};
  
  @override
  Future<String> saveTemporary(Uint8List imageData) async {
    final path = '/mock/temp/${DateTime.now().millisecondsSinceEpoch}.jpg';
    _storage[path] = imageData;
    return path;
  }
  
  @override
  Future<Uint8List?> loadImage(String path) async {
    return _storage[path];
  }
}

// Test Setup
class TestProviderScope extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        imageStorageServiceProvider.overrideWithValue(
          MockImageStorageService()
        ),
      ],
      child: child,
    );
  }
}
```

## 🔄 Migration Implementation Guide

### Phase 1: Foundation (Days 1-2)
```dart
// Create abstraction interfaces
abstract class IReceiptRepository {
  Future<List<Receipt>> getAllReceipts();
  Future<Receipt> createReceipt(Receipt receipt);
  Future<void> deleteReceipt(String id);
}

abstract class IImageStorageService {
  Future<String> saveImage(Uint8List data);
  Future<Uint8List?> loadImage(String path);
}

// Implement mocks for testing
class MockReceiptRepository implements IReceiptRepository {
  // In-memory implementation
}
```

### Phase 2: Supabase Setup (Days 3-4)
```dart
// Initialize Supabase client
final supabase = Supabase.instance.client;

// Cloud repository implementation
class CloudReceiptRepository implements IReceiptRepository {
  @override
  Future<Receipt> createReceipt(Receipt receipt) async {
    final response = await supabase
      .from('receipts')
      .insert(receipt.toJson())
      .select()
      .single();
    
    return Receipt.fromJson(response);
  }
}
```

### Phase 3: Dual-Write Pattern (Days 5-6)
```dart
class TransitionRepository implements IReceiptRepository {
  @override
  Future<Receipt> createReceipt(Receipt receipt) async {
    // Write to local first
    final local = await _local.createReceipt(receipt);
    
    // Queue cloud write
    _syncQueue.enqueue(CreateOperation(receipt));
    
    return local;
  }
}
```

### Phase 4: Sync Engine (Days 9-10)
```dart
class SyncEngine {
  final Queue<SyncOperation> _queue = Queue();
  
  Future<void> sync() async {
    while (_queue.isNotEmpty && await isOnline()) {
      final operation = _queue.first;
      
      try {
        await _executeOperation(operation);
        _queue.removeFirst();
      } catch (e) {
        await _handleSyncError(operation, e);
        break;
      }
    }
  }
}
```

## 🧪 Testing Strategy Evolution

### Before: File System Dependencies
```dart
// FAILS: MissingPluginException
test('saves image to file system', () async {
  final service = ImageStorageService();
  final path = await service.saveTemporary(imageData);
  expect(File(path).existsSync(), isTrue); // FAILS!
});
```

### After: Mock-First Testing
```dart
// PASSES: No file system dependency
test('saves image to storage', () async {
  final service = MockImageStorageService();
  final path = await service.saveTemporary(imageData);
  expect(path, isNotEmpty);
  
  final loaded = await service.loadImage(path);
  expect(loaded, equals(imageData));
});
```

## ⚠️ Known Issues & Workarounds

### 1. path_provider MissingPluginException
**Issue**: Tests fail with MissingPluginException when accessing file system
**Solution**: Use mock services that store data in memory

### 2. MockSupabaseHttpClient
**Issue**: Supabase client requires HTTP client in tests
**Solution**: 
```dart
class MockSupabaseHttpClient extends Mock implements Client {
  @override
  Future<Response> post(Uri url, {body, headers}) async {
    return Response('{"id": "123"}', 200);
  }
}
```

### 3. Riverpod AsyncValue in Tests
**Issue**: AsyncValue doesn't update in tests
**Solution**: Use container.read() instead of watch in tests

## 📊 Performance Optimization

### Caching Strategy
```dart
class CacheManager {
  static const Duration dataTTL = Duration(hours: 1);
  static const Duration imageTTL = Duration(days: 7);
  
  Future<T?> getCached<T>(String key) async {
    final entry = _cache[key];
    if (entry != null && !_isExpired(entry)) {
      return entry.data as T;
    }
    return null;
  }
}
```

### Query Optimization
```sql
-- Indexed queries for date ranges
CREATE INDEX idx_receipt_date ON receipts (receipt_date);
CREATE INDEX idx_user_date ON receipts (user_id, receipt_date);

-- Efficient pagination
SELECT * FROM receipts 
WHERE user_id = $1 
ORDER BY created_at DESC 
LIMIT $2 OFFSET $3;
```

## 🚀 Deployment Checklist

### Pre-Deployment
- [ ] All 571 tests passing
- [ ] Supabase project configured
- [ ] Environment variables set
- [ ] Feature flags configured
- [ ] Monitoring setup (Sentry, Analytics)

### Deployment Steps
1. Deploy Vercel API: `vercel --prod`
2. Run database migrations
3. Enable Row Level Security
4. Configure feature flags
5. Deploy mobile app (staged rollout)

### Post-Deployment
- [ ] Monitor error rates
- [ ] Check sync success rates
- [ ] Validate performance metrics
- [ ] User feedback collection

## 🔗 Related Documents

- [Architecture Document](apps/mobile/docs/architecture.md) - Complete migration architecture
- [Migration Plan](MIGRATION_PLAN.md) - Detailed 17-day implementation plan
- [Sharded PRD](docs/sharded-prd/) - Product requirements
- [Sharded Architecture](docs/sharded-architecture/) - Technical specifications

## 📈 Success Metrics

### Technical Metrics
- Test Coverage: > 95%
- All Tests Passing: 571/571
- Sync Success Rate: > 99%
- API Response Time: < 200ms p95
- App Load Time: < 2s

### Business Metrics
- User Retention: Maintain current levels
- Support Tickets: < 1% of users
- Feature Adoption: > 80% use cloud sync
- User Satisfaction: > 4.5/5 rating

## 🛠️ Troubleshooting Guide

### Common Issues

#### Tests Still Failing
```bash
# Clear test cache
flutter clean
flutter pub get
flutter test --no-pub

# Run with verbose output
flutter test --reporter expanded
```

#### Supabase Connection Issues
```dart
// Check connection
final isConnected = supabase.auth.currentSession != null;

// Test with curl
curl YOUR_SUPABASE_URL/rest/v1/receipts \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Authorization: Bearer YOUR_ANON_KEY"
```

#### Sync Failures
```dart
// Debug sync queue
final queue = ref.read(syncQueueProvider);
print('Pending operations: ${queue.length}');
print('Failed operations: ${queue.failedCount}');

// Force retry
await syncEngine.retryFailedOperations();
```

## 🎯 Next Steps

1. **Immediate**: Fix remaining test failures using mock services
2. **Week 1**: Implement repository interfaces and mocks
3. **Week 2**: Set up Supabase and implement sync engine
4. **Week 3**: Deploy and monitor staged rollout

---

*Knowledge Base Version: 1.0.0*
*Last Updated: 2025-01-11*
*Migration Status: Planning Complete, Implementation Ready*