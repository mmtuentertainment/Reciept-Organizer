# Monitoring Setup Guide

## Overview

The Receipt Organizer app includes comprehensive monitoring for:
- Performance tracking
- Error logging
- User analytics
- API usage monitoring
- Real-time health status

## Components

### 1. MonitoringService (`lib/core/services/monitoring_service.dart`)

Core service that tracks:
- **Performance Metrics**: Operation duration, percentiles (P50, P95, P99)
- **Error Tracking**: Categorized errors with stack traces
- **Session Statistics**: API calls, DB operations, sync events
- **Health Status**: System health indicator with error rates

### 2. Monitoring Dashboard (`lib/features/settings/screens/monitoring_dashboard.dart`)

Visual dashboard showing:
- System health status
- Session statistics
- Performance metrics
- Error summary
- Recent activity

### 3. Database Schema (`infrastructure/supabase/monitoring-schema.sql`)

Tables for persistent monitoring:
- `error_logs`: Application errors
- `performance_metrics`: Operation timings
- `analytics_events`: User actions
- `api_usage`: API call tracking
- `user_sessions`: Session tracking
- `daily_metrics`: Aggregated metrics

## Setup Instructions

### Step 1: Deploy Database Schema

```sql
-- Run in Supabase SQL Editor
-- Copy contents of infrastructure/supabase/monitoring-schema.sql
```

### Step 2: Integrate Monitoring in Code

#### Track Performance
```dart
// Use the monitored extension
await someAsyncOperation().monitored('operation_name');

// Or manually track
final stopwatch = Stopwatch()..start();
// ... do work ...
stopwatch.stop();
MonitoringService.instance.trackPerformance(
  'operation_name', 
  stopwatch.elapsedMilliseconds.toDouble()
);
```

#### Track Errors
```dart
try {
  // ... operation ...
} catch (error, stackTrace) {
  MonitoringService.instance.trackError(
    'category', 
    error, 
    stackTrace
  );
  rethrow;
}
```

#### Track User Actions
```dart
MonitoringService.instance.trackUserAction(
  'button_clicked',
  {'button': 'capture_receipt'}
);
```

### Step 3: Add Dashboard to Settings

```dart
// In your settings screen
ListTile(
  leading: Icon(Icons.analytics),
  title: Text('Monitoring Dashboard'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MonitoringDashboard(),
      ),
    );
  },
)
```

### Step 4: Configure Automated Reporting

1. **Daily Aggregation** (Supabase Function):
```sql
-- Schedule this to run daily
SELECT aggregate_daily_metrics();
```

2. **Error Alerts** (Optional):
```sql
-- Create trigger for critical errors
CREATE OR REPLACE FUNCTION notify_critical_error()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.category = 'critical' THEN
        -- Send notification (webhook, email, etc.)
        PERFORM pg_notify('critical_error', row_to_json(NEW)::text);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER critical_error_trigger
AFTER INSERT ON public.error_logs
FOR EACH ROW
EXECUTE FUNCTION notify_critical_error();
```

## Integration Examples

### Receipt Service
```dart
class ReceiptRepository {
  Future<Receipt> createReceipt(Receipt receipt) async {
    return await _dbService
      .createReceipt(receipt)
      .monitored('create_receipt');
  }
  
  Future<List<Receipt>> getReceipts() async {
    try {
      return await _dbService
        .getReceipts()
        .monitored('get_receipts');
    } catch (e, stack) {
      MonitoringService.instance.trackError('database', e, stack);
      rethrow;
    }
  }
}
```

### API Service
```dart
class ApiService {
  Future<Response> makeRequest(String endpoint) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final response = await http.get(Uri.parse(endpoint));
      stopwatch.stop();
      
      MonitoringService.instance.trackApiCall(
        endpoint,
        response.statusCode,
        stopwatch.elapsedMilliseconds.toDouble(),
      );
      
      return response;
    } catch (e) {
      stopwatch.stop();
      MonitoringService.instance.trackApiCall(
        endpoint,
        0,
        stopwatch.elapsedMilliseconds.toDouble(),
      );
      rethrow;
    }
  }
}
```

### Auth Service
```dart
class AuthService {
  Future<void> signIn(String email, String password) async {
    MonitoringService.instance.trackUserAction('sign_in_attempt');
    
    try {
      final result = await supabase.auth.signIn(
        email: email,
        password: password,
      ).monitored('auth_sign_in');
      
      MonitoringService.instance.trackUserAction('sign_in_success');
    } catch (e) {
      MonitoringService.instance.trackUserAction('sign_in_failed');
      MonitoringService.instance.trackError('auth', e);
      rethrow;
    }
  }
}
```

## Monitoring Metrics

### Key Performance Indicators (KPIs)

| Metric | Target | Alert Threshold |
|--------|--------|-----------------|
| Error Rate | < 1% | > 5% |
| API Response Time (P95) | < 1s | > 3s |
| Database Query Time (P95) | < 100ms | > 500ms |
| OCR Processing Time | < 5s | > 10s |
| App Startup Time | < 3s | > 5s |
| Sync Latency | < 1s | > 3s |

### Error Categories

- **critical**: App crashes, data loss
- **auth**: Authentication failures
- **database**: Database operations
- **api**: External API calls
- **sync**: Synchronization issues
- **ocr**: OCR processing errors
- **storage**: File storage issues

## Production Monitoring

### 1. External Services Integration

#### Sentry (Error Tracking)
```yaml
# pubspec.yaml
dependencies:
  sentry_flutter: ^7.14.0
```

```dart
// main.dart
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN';
      options.tracesSampleRate = 0.3;
    },
    appRunner: () => runApp(MyApp()),
  );
}
```

#### Google Analytics
```yaml
dependencies:
  firebase_analytics: ^10.7.0
```

```dart
// In MonitoringService
import 'package:firebase_analytics/firebase_analytics.dart';

final _analytics = FirebaseAnalytics.instance;

void _sendToAnalytics(String event, Map<String, dynamic> properties) {
  _analytics.logEvent(
    name: event,
    parameters: properties,
  );
}
```

### 2. Monitoring Dashboard (Supabase)

Create views for dashboard:
```sql
-- Recent errors view
CREATE VIEW monitoring_recent_errors AS
SELECT 
    category,
    error_message,
    COUNT(*) as count,
    MAX(created_at) as last_seen
FROM public.error_logs
WHERE created_at > CURRENT_TIMESTAMP - INTERVAL '24 hours'
GROUP BY category, error_message
ORDER BY count DESC;

-- Performance summary view
CREATE VIEW monitoring_performance_summary AS
SELECT 
    operation,
    COUNT(*) as count,
    AVG(duration_ms) as avg_ms,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY duration_ms) as p50_ms,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY duration_ms) as p95_ms
FROM public.performance_metrics
WHERE created_at > CURRENT_TIMESTAMP - INTERVAL '24 hours'
GROUP BY operation;
```

### 3. Alerting Rules

```sql
-- Function to check health status
CREATE OR REPLACE FUNCTION check_system_health()
RETURNS TABLE(
    status VARCHAR(20),
    error_rate DECIMAL(5, 2),
    slow_queries INTEGER,
    recent_errors INTEGER
) AS $$
DECLARE
    v_error_rate DECIMAL(5, 2);
    v_slow_queries INTEGER;
    v_recent_errors INTEGER;
    v_status VARCHAR(20);
BEGIN
    -- Calculate error rate
    SELECT 
        CASE 
            WHEN COUNT(*) > 0 
            THEN (SUM(CASE WHEN el.id IS NOT NULL THEN 1 ELSE 0 END)::DECIMAL / COUNT(*)::DECIMAL * 100)
            ELSE 0
        END INTO v_error_rate
    FROM public.performance_metrics pm
    LEFT JOIN public.error_logs el 
        ON el.created_at BETWEEN pm.created_at - INTERVAL '1 minute' 
        AND pm.created_at + INTERVAL '1 minute'
    WHERE pm.created_at > CURRENT_TIMESTAMP - INTERVAL '1 hour';
    
    -- Count slow queries
    SELECT COUNT(*) INTO v_slow_queries
    FROM public.performance_metrics
    WHERE duration_ms > 1000
        AND created_at > CURRENT_TIMESTAMP - INTERVAL '1 hour';
    
    -- Count recent errors
    SELECT COUNT(*) INTO v_recent_errors
    FROM public.error_logs
    WHERE created_at > CURRENT_TIMESTAMP - INTERVAL '5 minutes';
    
    -- Determine status
    IF v_error_rate > 10 OR v_recent_errors > 10 THEN
        v_status := 'unhealthy';
    ELSIF v_error_rate > 5 OR v_recent_errors > 5 OR v_slow_queries > 10 THEN
        v_status := 'degraded';
    ELSE
        v_status := 'healthy';
    END IF;
    
    RETURN QUERY SELECT v_status, v_error_rate, v_slow_queries, v_recent_errors;
END;
$$ LANGUAGE plpgsql;
```

## Testing Monitoring

### Manual Testing
1. Open the app
2. Navigate to Settings → Monitoring Dashboard
3. Perform various operations (create receipts, sync, etc.)
4. Check that metrics appear in dashboard
5. Trigger errors intentionally to test error tracking

### Automated Testing
```dart
// test/monitoring_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_organizer/core/services/monitoring_service.dart';

void main() {
  group('MonitoringService', () {
    final monitoring = MonitoringService.instance;
    
    setUp(() {
      monitoring.clearData();
    });
    
    test('tracks performance metrics', () {
      monitoring.trackPerformance('test_op', 100.0);
      monitoring.trackPerformance('test_op', 150.0);
      monitoring.trackPerformance('test_op', 200.0);
      
      final summary = monitoring.getPerformanceSummary('test_op');
      expect(summary['count'], 3);
      expect(summary['avg'], '150.00');
      expect(summary['p50'], '150.00');
    });
    
    test('tracks errors', () {
      monitoring.trackError('test', 'Test error');
      
      final health = monitoring.getHealthStatus();
      expect(health['recent_errors'], contains('test'));
    });
    
    test('calculates health status', () {
      // Simulate healthy state
      monitoring.trackApiCall('/api/test', 200, 100.0);
      
      var health = monitoring.getHealthStatus();
      expect(health['status'], 'healthy');
      
      // Simulate unhealthy state
      for (int i = 0; i < 10; i++) {
        monitoring.trackApiCall('/api/test', 500, 100.0);
      }
      
      health = monitoring.getHealthStatus();
      expect(health['status'], isNot('healthy'));
    });
  });
}
```

## Maintenance

### Daily Tasks
- Review error logs for new issues
- Check performance degradation
- Monitor error rate trends

### Weekly Tasks
- Analyze user behavior patterns
- Review slow operations
- Update alerting thresholds if needed

### Monthly Tasks
- Generate performance reports
- Clean up old monitoring data
- Review and optimize slow queries

### Data Retention
```sql
-- Clean up old monitoring data (run monthly)
DELETE FROM public.error_logs 
WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '90 days';

DELETE FROM public.performance_metrics 
WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '30 days';

DELETE FROM public.analytics_events 
WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '90 days';

-- Keep daily metrics longer for trends
DELETE FROM public.daily_metrics 
WHERE date < CURRENT_DATE - INTERVAL '1 year';
```

## Troubleshooting

### High Error Rate
1. Check recent deployments
2. Review error categories in dashboard
3. Check external service status
4. Review recent code changes

### Performance Degradation
1. Check database query performance
2. Review API response times
3. Check device storage space
4. Monitor memory usage

### Missing Metrics
1. Verify monitoring service is initialized
2. Check network connectivity
3. Verify Supabase connection
4. Review RLS policies

## Next Steps

1. ✅ Deploy monitoring schema to Supabase
2. ✅ Integrate MonitoringService in app
3. ✅ Add dashboard to settings
4. ⏭️ Configure production error tracking (Sentry)
5. ⏭️ Set up analytics service (Firebase/Mixpanel)
6. ⏭️ Create monitoring alerts
7. ⏭️ Schedule daily aggregation jobs