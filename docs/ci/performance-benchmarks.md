# Performance Benchmarks for CI Pipeline

## Merchant Name Normalization Performance Requirements

This document defines the performance benchmarks that must be validated in the CI pipeline for the merchant normalization feature.

### Critical Performance Targets

#### 1. Single Merchant Normalization
- **Target**: <50ms per merchant (p95)
- **Acceptable**: <100ms (p99)
- **Failure Threshold**: >200ms

#### 2. Batch Normalization (100 merchants)
- **Target**: <500ms total
- **Acceptable**: <1000ms
- **Failure Threshold**: >2000ms

#### 3. OCR Processing Impact
- **Target**: <5% increase in overall OCR time
- **Acceptable**: <10% increase
- **Failure Threshold**: >15% increase

#### 4. Memory Usage
- **Target**: <1MB additional memory for normalization service
- **Acceptable**: <2MB
- **Failure Threshold**: >5MB

### Benchmark Implementation

#### Performance Test Suite Location
```
test/benchmarks/merchant_normalization_performance_test.dart
```

#### CI Pipeline Integration
```yaml
# In .github/workflows/ci.yaml or flutter test command
flutter test test/benchmarks/merchant_normalization_performance_test.dart --reporter=json
```

### Benchmark Scenarios

1. **Cold Start Performance**
   - First normalization after service initialization
   - Includes dictionary loading time
   - Target: <100ms

2. **Warm Performance**
   - Subsequent normalizations with cached dictionary
   - Target: <50ms per merchant

3. **Edge Case Performance**
   - Very long merchant names (100+ characters)
   - Special character heavy names
   - International character sets
   - Target: <75ms per merchant

4. **Concurrent Processing**
   - Multiple normalization requests in parallel
   - Target: Linear scaling up to 10 concurrent requests

### Measurement Methodology

#### Timing Precision
- Use `Stopwatch` class for microsecond precision
- Exclude test setup/teardown time
- Average over 100 iterations minimum

#### Statistical Analysis
- Report p50, p95, p99 percentiles
- Calculate standard deviation
- Identify outliers (>3 standard deviations)

#### Environment Consistency
- Run on consistent CI hardware
- Disable other intensive processes
- Use release mode builds for accurate timing

### Performance Monitoring

#### Regression Detection
- Compare against baseline from previous commits
- Alert on >10% performance degradation
- Store historical benchmark data

#### Continuous Improvement
- Track performance trends over time
- Identify optimization opportunities
- Document performance improvements

### Benchmark Output Format

```json
{
  "merchant_normalization_benchmarks": {
    "single_merchant": {
      "p50": 35,
      "p95": 48,
      "p99": 52,
      "unit": "milliseconds"
    },
    "batch_100": {
      "total_time": 450,
      "per_merchant_avg": 4.5,
      "unit": "milliseconds"
    },
    "ocr_impact": {
      "baseline": 4800,
      "with_normalization": 4920,
      "increase_percent": 2.5,
      "unit": "milliseconds"
    },
    "memory_usage": {
      "baseline": 45.2,
      "with_service": 46.1,
      "increase": 0.9,
      "unit": "megabytes"
    }
  }
}
```

### Failure Handling

When benchmarks fail:
1. Block the PR/merge
2. Generate detailed performance report
3. Include profiling data for bottlenecks
4. Suggest optimization areas

### Integration with Flutter DevTools

For local performance debugging:
1. Use Flutter DevTools Timeline view
2. Enable performance overlay
3. Profile with `flutter run --profile`
4. Analyze frame rendering times

### Performance Optimization Guidelines

1. **Caching Strategy**
   - Cache normalized results for common merchants
   - Use LRU cache with 1000 entry limit
   - Clear cache on low memory warnings

2. **String Operations**
   - Avoid regex where simple string operations suffice
   - Pre-compile all regex patterns
   - Use efficient string builders

3. **Lazy Loading**
   - Load merchant dictionary on first use
   - Don't load abbreviations until needed
   - Stream large datasets rather than load all at once

### Review Frequency

- Benchmark targets reviewed quarterly
- Adjusted based on user feedback and device capabilities
- Document any changes to targets with rationale