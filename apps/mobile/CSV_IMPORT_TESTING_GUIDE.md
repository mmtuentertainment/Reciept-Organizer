# CSV Import Testing Guide

## Overview

This guide provides step-by-step instructions for testing the CSV export functionality with QuickBooks and Xero accounting software. The goal is to ensure exported receipt data imports correctly without data loss or corruption.

## Test Files

### Generated Test Files
1. **QuickBooks Format**:
   - `exports/test_quickbooks_comprehensive.csv` - 50+ test cases
   - `exports/sample_quickbooks.csv` - Basic sample

2. **Xero Format**:
   - `exports/test_xero_comprehensive.csv` - 50+ test cases  
   - `exports/sample_xero.csv` - Basic sample

3. **Generic Format**:
   - `exports/sample_generic.csv` - Universal format

## QuickBooks Import Testing

### Prerequisites
- QuickBooks Online account (trial acceptable)
- QuickBooks Desktop 2023+ (optional)
- Admin or Company Admin role

### Import Steps - QuickBooks Online

1. **Navigate to Banking**
   - Go to Banking → Banking
   - Click "Upload transactions" 
   - Select account (e.g., "Business Checking")

2. **Upload File**
   - Click "Browse" and select CSV file
   - QuickBooks will analyze the file

3. **Map Fields**
   - Date → Date
   - Amount → Amount
   - Payee → Description/Payee
   - Category → Category
   - Memo → Memo
   - Tax → Sales Tax (if available)
   - Notes → Add to Memo

4. **Review Mapping**
   - Verify date format (MM/DD/YYYY)
   - Confirm amounts are positive
   - Check special characters display correctly

5. **Import Settings**
   - Select "2 column" for amounts
   - Choose "Expenses" for transaction type
   - Set appropriate tax codes

### Validation Checklist - QuickBooks

#### Data Integrity
- [ ] All 50+ test records imported
- [ ] No records skipped or errored
- [ ] Dates converted correctly
- [ ] Amounts match exactly
- [ ] Tax amounts preserved

#### Special Characters
- [ ] Double quotes handled ("""ABC Company, Inc.""")
- [ ] Single quotes preserved (O'Reilly)
- [ ] Commas in text fields (Merchant with, comma)
- [ ] Accented characters (Café José)
- [ ] Trademark symbols (McDonald's®)

#### CSV Injection Prevention
- [ ] Formula prefixes escaped ('=DANGEROUS)
- [ ] Plus signs handled ('+1234567890)
- [ ] Minus signs handled ('-Negative Start)
- [ ] At symbols handled ('@Command Test)

#### Edge Cases
- [ ] $0.01 minimum amount
- [ ] $9,999.99 regular large amount
- [ ] $1,234,567.89 very large amount
- [ ] $0.00 zero amount
- [ ] Multiple decimal places rounded correctly

#### Date Handling
- [ ] Leap day (02/29/2024)
- [ ] Year boundaries (12/31/2024, 01/01/2025)
- [ ] Various months represented
- [ ] Historical dates (2023)

### QuickBooks Desktop Testing

1. **File Menu Import**
   - File → Utilities → Import → IIF Files
   - Note: May need to convert CSV to IIF format

2. **Bank Feeds Center**
   - Banking → Bank Feeds → Import Web Connect
   - Select CSV file type if supported

3. **Transaction Pro Importer** (if available)
   - More robust CSV handling
   - Better error reporting

## Xero Import Testing

### Prerequisites
- Xero account (30-day trial available)
- Advisor or Standard user role
- Bank account set up in Xero

### Import Steps - Xero

1. **Navigate to Bank Transactions**
   - Accounting → Bank accounts
   - Select account
   - Click "Import a statement"

2. **Upload CSV**
   - Drag and drop or browse for file
   - Select "CSV" format

3. **Map Columns**
   - Date → Transaction Date
   - Amount → Transaction Amount  
   - Payee → Payee
   - Description → Description
   - Account Code → Account Code (optional)
   - Tax Amount → Tax Amount
   - Notes → Reference/Particulars

4. **Date Format**
   - Select DD/MM/YYYY format
   - Verify dates parse correctly

5. **Import Options**
   - Choose "Import as draft" first
   - Review before confirming

### Validation Checklist - Xero

#### Data Format
- [ ] DD/MM/YYYY dates recognized
- [ ] All amounts imported as expenses (positive)
- [ ] Account codes mapped (400, 429, etc.)
- [ ] Tax amounts in separate column

#### Text Handling
- [ ] Multi-line descriptions (with newlines)
- [ ] Tab characters handled
- [ ] Semicolons preserved
- [ ] Unicode characters (€£¥)
- [ ] Extended Latin (ñ, ü, ï)

#### Account Code Validation
- [ ] 400 - Office/General Expenses
- [ ] 404 - Professional Fees
- [ ] 410 - Advertising/Marketing
- [ ] 420 - Computer/IT Expenses
- [ ] 425 - Repairs & Maintenance
- [ ] 429 - Entertainment
- [ ] 433 - Training
- [ ] 440 - Equipment Hire
- [ ] 442 - Internet
- [ ] 445 - Utilities
- [ ] 449 - Motor Vehicle
- [ ] 493 - General/Miscellaneous
- [ ] 260 - Capital Assets (large purchases)
- [ ] 300 - Sales/Retail (if applicable)

#### Large Data Sets
- [ ] 50+ transactions import successfully
- [ ] No timeout errors
- [ ] Progress indicator works
- [ ] Can handle 1MB+ files

## Generic Format Testing

### Compatibility Testing
Test generic format with:
- [ ] Excel/Google Sheets
- [ ] LibreOffice Calc
- [ ] Apple Numbers
- [ ] Other accounting software

### Validation
- [ ] Opens without import wizard
- [ ] All columns visible
- [ ] No data truncation
- [ ] Formulas not executed
- [ ] Special characters intact

## Common Issues & Solutions

### QuickBooks Issues

1. **Date Format Errors**
   - Solution: Ensure MM/DD/YYYY format
   - Use Excel to reformat if needed

2. **Duplicate Detection**
   - QuickBooks may flag similar transactions
   - Review and merge or accept as needed

3. **Category Not Found**
   - Create categories before import
   - Or map to existing categories

### Xero Issues

1. **Account Code Invalid**
   - Ensure codes match Chart of Accounts
   - Use generic code (493) if unsure

2. **Tax Calculation Differences**
   - May need to adjust tax settings
   - Check inclusive/exclusive tax handling

3. **Statement Lines Limit**
   - Xero may limit imports to 1000 lines
   - Split large files if needed

## Performance Benchmarks

### Expected Import Times
- 50 transactions: < 30 seconds
- 500 transactions: < 2 minutes
- 5000 transactions: < 10 minutes

### File Size Limits
- QuickBooks Online: 1MB (approx 2000 rows)
- QuickBooks Desktop: 14MB
- Xero: 1MB initially, larger with support

## Security Validation

### CSV Injection Prevention
Verify these entries import as text, not formulas:
- '=1+1 (should show as '=1+1, not 2)
- '+REF! (should not cause Excel error)
- '-FORMULA() (should not execute)
- '@SUM(A:A) (should not calculate)

### Data Privacy
- [ ] No sensitive data in test files
- [ ] Use fictional merchant names
- [ ] Amounts are reasonable test values
- [ ] No real receipt numbers

## Reporting Issues

### Information to Capture
1. Software version (QB/Xero)
2. Browser used
3. Exact error message
4. Screenshot of issue
5. Row number causing problem
6. Special characters involved

### Issue Categories
- **Critical**: Import fails completely
- **Major**: Data corruption/loss
- **Minor**: Formatting issues
- **Enhancement**: Feature requests

## Success Criteria

### QuickBooks Import
- ✅ 100% of records imported
- ✅ No data transformation errors
- ✅ Special characters preserved
- ✅ CSV injection attempts blocked
- ✅ Performance acceptable

### Xero Import  
- ✅ All records imported as drafts
- ✅ Account codes recognized
- ✅ Tax amounts separate
- ✅ Dates in correct format
- ✅ No timeout errors

### Generic Format
- ✅ Opens in all spreadsheet apps
- ✅ No compatibility warnings
- ✅ Data integrity maintained
- ✅ Can be re-saved without loss

## Sign-off

### Test Execution
- Date tested: ___________
- Tester name: ___________
- QuickBooks version: ___________
- Xero version: ___________
- Issues found: ___________

### Approval
- [ ] QuickBooks import approved
- [ ] Xero import approved  
- [ ] Generic format approved
- [ ] Documentation complete

---

**Note**: Always test with a demo/sandbox account first. Never import test data into production accounting systems without approval.