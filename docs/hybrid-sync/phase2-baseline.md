# Phase 2: Offline Detection - Baseline Measurement

## Date: 2025-09-10

### Current State Documentation

#### Network Error Handling: NONE
- No connectivity checks before API calls
- API calls fail with generic HTTP exceptions
- No user feedback about offline state
- No retry mechanism

#### Current API Call Patterns
1. **QuickBooks Service**
   - Direct HTTP calls to `_baseUrl` (now via Environment)
   - Throws Exception on failure
   - No offline detection
   
2. **Xero Service**
   - Direct HTTP calls to `_baseUrl` (now via Environment)
   - Throws Exception on failure
   - No offline detection

3. **Validation Service**
   - Makes HTTP POST to `/api/quickbooks/validate`
   - No pre-flight connectivity check
   - Fails silently when offline

#### User Experience When Offline
- Error dialogs with technical messages
- No indication that device is offline
- No queuing of requests
- Lost work if network fails during export

#### Performance Baseline
- Failed API call timeout: ~30 seconds (default HTTP timeout)
- No cached responses
- No optimistic UI updates
- Full blocking during network requests

### Hypothesis for Phase 2.2
"We can detect network connectivity changes and provide appropriate user feedback without adding significant complexity or performance overhead"

### Success Criteria
1. Detect offline state before API calls
2. Provide clear user feedback
3. Prevent unnecessary API attempts when offline
4. Maintain sub-second detection time
5. Work on both Android and iOS