# Phase 1: Environment Abstraction - Baseline Measurement

## Date: 2025-09-10

### Current State Documentation

#### Hardcoded URLs Found: 3 instances
1. `apps/mobile/lib/features/export/services/quickbooks_api_service.dart:15`
   - `static const String _baseUrl = 'https://receipt-organizer-api.vercel.app';`
   
2. `apps/mobile/lib/features/export/services/xero_api_service.dart:15`
   - `static const String _baseUrl = 'https://receipt-organizer-api.vercel.app';`
   
3. `apps/api/middleware.ts:8`
   - CORS allowed origins includes `'https://receipt-organizer-api.vercel.app'`

#### Current Test Status
- Export validation flow tests: ✅ PASSING (3 tests)
- Integration tests: ✅ PASSING
- Current export flow: FUNCTIONAL

#### Environment Dependencies
- No environment configuration system exists
- Direct URL references in service classes
- No development/production separation
- No ability to switch endpoints for testing

#### Performance Baseline
- Test execution time: ~12 seconds
- No environment lookup overhead (hardcoded)
- Direct string constants

### Hypothesis for Phase 1.2
"We can create a minimal environment abstraction that allows runtime URL configuration without breaking existing functionality or impacting performance"

### Success Criteria
1. Zero test regressions
2. Ability to override URL via environment variable
3. Default behavior matches current (production URL)
4. No performance degradation (test time <15 seconds)
5. Works in both development and production builds