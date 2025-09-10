# Phase 4: Background Sync - Baseline Measurement

## Date: 2025-09-10

### Current State Documentation

#### Background Processing: NONE
- Queue only processes when app is active
- No background execution capability
- Queue processing stops when app is closed
- No periodic sync when backgrounded

#### Current Limitations

1. **App Lifecycle Dependency**
   - Queue timer stops when app backgrounded
   - No processing when app terminated
   - Lost retry opportunities
   
2. **Battery Optimization Impact**
   - Android Doze mode stops timers
   - iOS suspends app after ~30 seconds
   - No wake capability for sync

3. **User Experience Issues**
   - Must keep app open for retries
   - No background notifications
   - Delayed sync until app reopened
   - Potential for stale queue

#### Platform Constraints

**Android**
- Doze mode restrictions (API 23+)
- App Standby buckets (API 28+)
- Background execution limits
- Battery optimization kills processes

**iOS**
- 30-second background execution
- Background fetch deprecated
- BGTaskScheduler requirements (iOS 13+)
- Limited wake opportunities

#### Queue Processing Currently

```dart
// Current implementation - foreground only
Timer.periodic(Duration(seconds: 30), (_) {
  if (_connectivity.canMakeApiCall()) {
    processQueue();
  }
});
```

### Problems This Causes

1. **Delayed Processing**: Queue items wait until app reopened
2. **Failed Syncs**: Time-sensitive requests expire
3. **Poor UX**: Users must remember to open app
4. **Battery Drain**: Keeping app open for sync

### Hypothesis for Phase 4.2
"We can create a minimal background worker abstraction that delegates to platform-specific implementations while maintaining consistent behavior"

### Success Criteria
1. Queue processes when app backgrounded
2. Periodic sync every 15-30 minutes
3. Respects battery optimization
4. Works on Android 7+ and iOS 13+
5. Minimal battery impact (<1% per day)
6. Graceful degradation if unavailable

### Measurement Plan
- Background execution frequency
- Battery consumption metrics
- Queue processing success rate
- Time to sync after queuing
- Platform-specific limitations

### Risk Assessment
- **Complexity**: Platform-specific code required
- **Testing**: Requires real devices
- **Permissions**: User consent needed
- **Reliability**: OS may restrict execution