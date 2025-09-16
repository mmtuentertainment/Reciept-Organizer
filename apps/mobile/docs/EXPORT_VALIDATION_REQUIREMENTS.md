# Export Format Validation Requirements

## Overview
This document defines the validation requirements for exporting receipts to QuickBooks and Xero accounting systems. All export functionality must pass these validation checks before data is sent to external systems.

## QuickBooks Requirements

### Format Options
1. **3-Column Format**: Date, Description, Amount
2. **4-Column Format**: Date, Description, Debit, Credit

### Date Format
- **Required Format**: MM/DD/YYYY
- **Valid Range**: 1900-2100
- **Examples**:
  - ✅ 03/15/2024
  - ✅ 12/31/2025
  - ❌ 15/03/2024 (DD/MM/YYYY not accepted)
  - ❌ 2024-03-15 (ISO format not accepted)

### Amount Format
- **Decimal Places**: Exactly 2 (e.g., 99.99)
- **Maximum Value**: 999,999.99
- **Negative Values**: Allowed for refunds
- **Thousands Separator**: Optional comma

### Description Field
- **Maximum Length**: 4,000 characters
- **Special Characters**: Must be properly escaped
- **CSV Injection Prevention**: Required

### Batch Limits
- **Recommended**: 1,000 rows per import
- **Maximum**: No hard limit, but performance degrades above 1,000

### CSV Requirements
- **Encoding**: UTF-8
- **Line Endings**: CRLF or LF
- **Header Row**: Required
- **Field Escaping**: Double quotes for fields containing commas, quotes, or newlines

## Xero Requirements

### Required Fields
1. **ContactName**: Vendor/merchant name (required)
2. **InvoiceNumber**: Unique identifier (required)
3. **InvoiceDate**: Transaction date (required)

### Date Format
- **Required Format**: DD/MM/YYYY
- **Valid Range**: 1900-2100
- **Examples**:
  - ✅ 15/03/2024
  - ✅ 31/12/2025
  - ❌ 03/15/2024 (MM/DD/YYYY not accepted)
  - ❌ 2024-03-15 (ISO format not accepted)

### Amount Format
- **Decimal Places**: 2-4 decimal places
- **Maximum Value**: 999,999,999.9999
- **Tax Handling**: Separate UnitAmount and TaxAmount fields

### Additional Fields
- **DueDate**: Usually same as InvoiceDate
- **Quantity**: Default to 1 for receipts
- **AccountCode**: Expense account code (e.g., 400)
- **TaxType**: "Tax on Purchases" for receipts

### Batch Limits
- **Recommended**: 500 rows per import
- **Maximum**: 1,000 rows (hard limit)

## CSV Injection Prevention

### Dangerous Characters
The following characters at the start of a field are considered dangerous:
- `=` (Formula injection)
- `+` (Formula injection)
- `-` (Formula injection)
- `@` (Formula injection)
- Tab character
- Carriage return
- Line feed

### Sanitization Strategy
1. Remove dangerous characters from the start of fields
2. Escape special characters properly
3. Validate all fields before export
4. Log any modifications made

## Validation Process

### Pre-Export Validation
1. **Required Fields Check**: Ensure all required fields have values
2. **Format Validation**: Verify dates, amounts match target system
3. **Length Validation**: Check field lengths against limits
4. **Character Validation**: Identify and handle special characters
5. **Batch Size Check**: Split large datasets if needed

### Validation Results
Each validation returns:
- **isValid**: Boolean indicating if export can proceed
- **errors**: List of critical issues that must be fixed
- **warnings**: List of non-critical issues to review
- **errorCount**: Total number of errors found
- **warningCount**: Total number of warnings found

## Error Handling

### Critical Errors (Block Export)
- Missing required fields
- Invalid date formats
- Invalid amount formats
- CSV injection attempts detected
- Field length exceeded

### Warnings (Allow Export with Caution)
- Batch size exceeds recommendations
- Special characters that may cause issues
- Very long descriptions
- Future-dated transactions

## Testing Requirements

### Unit Tests
- Date format conversion
- Amount formatting and precision
- Special character escaping
- CSV injection prevention
- Field length validation

### Integration Tests
- Full export workflow with valid data
- Edge case handling
- Large dataset performance
- Error recovery scenarios

### Performance Benchmarks
- 100 receipts: < 100ms
- 1,000 receipts: < 500ms
- 10,000 receipts: < 5 seconds

## Implementation Checklist

- [x] Date format converter (MM/DD/YYYY ↔ DD/MM/YYYY)
- [x] Amount formatter with precision control
- [x] CSV injection sanitizer
- [x] Special character escaper
- [x] Batch splitter for large datasets
- [x] Validation result aggregator
- [x] Error message formatter
- [x] Test data generator with edge cases
- [x] QuickBooks format validator
- [x] Xero format validator
- [x] Generic CSV validator
- [x] Performance benchmarks

## API Integration

### QuickBooks Sandbox
- Client ID: Provided by user
- Client Secret: Provided by user
- Company ID: Provided by user
- OAuth 2.0 flow required
- Sandbox URL: https://sandbox-quickbooks.api.intuit.com

### Xero Sandbox
- Currently using public documentation
- No sandbox credentials available yet
- Format validation based on official specs

## Next Steps

1. ✅ Complete validation framework
2. ✅ Integrate QuickBooks sandbox
3. ⏳ Await Xero sandbox credentials
4. 🔄 Implement actual export functionality (Stories 3.9-3.12)
5. 📊 Create export UI with format selection
6. 🧪 End-to-end testing with real sandboxes