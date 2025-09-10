#!/usr/bin/env node

/**
 * Simple test script to verify OAuth endpoints
 * Run with: node test-oauth.js
 */

const BASE_URL = 'http://localhost:3001';

async function testQuickBooksOAuth() {
  console.log('\n🔍 Testing QuickBooks OAuth...');
  
  try {
    const response = await fetch(`${BASE_URL}/api/auth/quickbooks`);
    const data = await response.json();
    
    if (data.success && data.authUrl) {
      console.log('✅ QuickBooks OAuth endpoint working');
      console.log('   Auth URL:', data.authUrl.substring(0, 50) + '...');
      console.log('   Session ID:', data.sessionId);
      return true;
    } else {
      console.error('❌ QuickBooks OAuth failed:', data);
      return false;
    }
  } catch (error) {
    console.error('❌ QuickBooks OAuth error:', error.message);
    return false;
  }
}

async function testXeroOAuth() {
  console.log('\n🔍 Testing Xero OAuth...');
  
  try {
    const response = await fetch(`${BASE_URL}/api/auth/xero`);
    const data = await response.json();
    
    if (data.success && data.authUrl) {
      console.log('✅ Xero OAuth endpoint working');
      console.log('   Auth URL:', data.authUrl.substring(0, 50) + '...');
      console.log('   Session ID:', data.sessionId);
      return true;
    } else {
      console.error('❌ Xero OAuth failed:', data);
      return false;
    }
  } catch (error) {
    console.error('❌ Xero OAuth error:', error.message);
    return false;
  }
}

async function testValidationEndpoints() {
  console.log('\n🔍 Testing validation endpoints...');
  
  const testReceipts = [
    {
      merchantName: 'Test Store',
      date: new Date().toISOString(),
      totalAmount: 100.00,
      taxAmount: 10.00
    }
  ];
  
  // Test QuickBooks validation
  try {
    const qbResponse = await fetch(`${BASE_URL}/api/quickbooks/validate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer test-token'
      },
      body: JSON.stringify({ receipts: testReceipts })
    });
    
    const qbData = await qbResponse.json();
    console.log('✅ QuickBooks validation endpoint working');
    console.log('   Valid:', qbData.isValid);
    console.log('   Errors:', qbData.errors?.length || 0);
    console.log('   Warnings:', qbData.warnings?.length || 0);
  } catch (error) {
    console.error('❌ QuickBooks validation error:', error.message);
  }
  
  // Test Xero validation
  try {
    const xeroResponse = await fetch(`${BASE_URL}/api/xero/validate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer test-token'
      },
      body: JSON.stringify({ receipts: testReceipts })
    });
    
    const xeroData = await xeroResponse.json();
    console.log('✅ Xero validation endpoint working');
    console.log('   Valid:', xeroData.isValid);
    console.log('   Errors:', xeroData.errors?.length || 0);
    console.log('   Warnings:', xeroData.warnings?.length || 0);
  } catch (error) {
    console.error('❌ Xero validation error:', error.message);
  }
}

async function main() {
  console.log('========================================');
  console.log('Receipt Organizer OAuth Test Suite');
  console.log('========================================');
  console.log(`Testing endpoints at: ${BASE_URL}`);
  
  const qbOK = await testQuickBooksOAuth();
  const xeroOK = await testXeroOAuth();
  await testValidationEndpoints();
  
  console.log('\n========================================');
  console.log('Test Summary:');
  console.log(`QuickBooks OAuth: ${qbOK ? '✅ PASS' : '❌ FAIL'}`);
  console.log(`Xero OAuth: ${xeroOK ? '✅ PASS' : '❌ FAIL'}`);
  console.log('========================================\n');
  
  if (!qbOK || !xeroOK) {
    console.log('⚠️  Make sure the API server is running:');
    console.log('   cd apps/api && npm run dev');
    process.exit(1);
  }
}

main().catch(console.error);