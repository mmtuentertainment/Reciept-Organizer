# Integration Documentation

## Overview
This directory contains documentation for integrating the Receipt Organizer app with external services and platforms.

## Available Integrations

### 1. Supabase Cloud Backend
- **Status**: ✅ Implemented
- **Purpose**: Authentication, data sync, and realtime updates
- **Documentation**: See infrastructure/supabase/SETUP.md

### 2. QuickBooks Export
- **Status**: ✅ Validation implemented
- **Purpose**: Export receipts to QuickBooks-compatible CSV format
- **Features**:
  - Pre-flight validation
  - Format compliance checking
  - Field mapping and transformation

### 3. Xero Export
- **Status**: ✅ Validation implemented
- **Purpose**: Export receipts to Xero-compatible CSV format
- **Features**:
  - Date format conversion
  - Amount validation
  - Required field checking

## API Integrations

### Export API Service
Located at: `apps/mobile/lib/features/export/services/`

The app includes API service stubs for future cloud integrations:
- `xero_api_service.dart` - Xero API integration (ready for implementation)
- `api_credentials.dart` - Secure credential management

## Environment Configuration

### Development
```bash
# Local Supabase
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=<local-dev-key>

# API Backend
API_URL=http://localhost:3001
```

### Production
```bash
# Production Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=<production-key>

# Production API
API_URL=https://receipt-organizer-api.vercel.app
```

## Testing Integrations

### Supabase Integration Tests
```bash
CI=true flutter test test/infrastructure/supabase_integration_test.dart
```

### Export Validation Tests
```bash
flutter test test/integration/export_validation_flow_test.dart
```

## Security Considerations

1. **API Keys**: Never commit API keys to version control
2. **Environment Variables**: Use `--dart-define` for sensitive configuration
3. **RLS Policies**: Ensure Row Level Security is enabled on all Supabase tables
4. **Data Validation**: Always validate data before sending to external services

## Next Steps

1. Implement OAuth flow for QuickBooks
2. Add Xero API authentication
3. Build webhook endpoints for real-time sync
4. Add support for additional accounting platforms