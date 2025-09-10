import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/receipt.dart';
import 'quickbooks_api_service.dart';

/// Service for interacting with Xero API via Vercel proxy
class XeroAPIService {
  static final XeroAPIService _instance = XeroAPIService._internal();
  factory XeroAPIService() => _instance;
  XeroAPIService._internal();
  
  // TODO: Update with production URL when deployed
  static const String _baseUrl = 'http://localhost:3001';
  final _secureStorage = const FlutterSecureStorage();
  String? _sessionId;
  String? _sessionToken;
  
  /// Generate OAuth 2.0 authorization URL via Vercel proxy (handles PKCE)
  Future<String> getAuthorizationUrl() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/auth/xero'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _sessionId = data['sessionId'];
        _sessionToken = data['sessionToken'];
        
        // Store session info for later
        await _secureStorage.write(key: 'xero_session_id', value: _sessionId);
        await _secureStorage.write(key: 'xero_session_token', value: _sessionToken);
        
        return data['authUrl'];
      } else {
        throw Exception('Failed to get authorization URL: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to auth service: $e');
    }
  }
  
  /// Handle OAuth callback via Vercel proxy
  Future<Map<String, dynamic>> handleCallback(String code, String state) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/xero/callback'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'code': code,
        'state': state,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Store authentication status
      await _secureStorage.write(key: 'xero_authenticated', value: 'true');
      if (data['sessionToken'] != null) {
        await _secureStorage.write(key: 'xero_session_token', value: data['sessionToken']);
      }
      
      return data;
    } else {
      throw Exception('Failed to handle callback: ${response.body}');
    }
  }
  
  /// Refresh access token
  Future<void> refreshAccessToken() async {
    final refreshToken = await APICredentials.getXeroRefreshToken();
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }
    
    final response = await http.post(
      Uri.parse(APICredentials.xeroTokenUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': APICredentials.xeroClientId,
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Update stored tokens
      await APICredentials.storeXeroTokens(
        accessToken: data['access_token'],
        refreshToken: data['refresh_token'],
      );
    } else {
      throw Exception('Failed to refresh token: ${response.body}');
    }
  }
  
  /// Create expense bills in Xero (using Invoice with Type=ACCPAY)
  Future<Map<String, dynamic>> createExpenseBills(List<Receipt> receipts) async {
    final accessToken = await APICredentials.getXeroAccessToken();
    final tenantId = await APICredentials.getXeroTenantId();
    
    if (accessToken == null || tenantId == null) {
      throw Exception('Not authenticated with Xero');
    }
    
    // Convert receipts to Xero Invoice format (max 50 per batch)
    final batches = <List<Receipt>>[];
    for (var i = 0; i < receipts.length; i += 50) {
      batches.add(receipts.skip(i).take(50).toList());
    }
    
    final results = <Map<String, dynamic>>[];
    
    for (final batch in batches) {
      final invoicesData = {
        'Invoices': batch.map(_convertReceiptToInvoice).toList(),
      };
      
      final response = await http.post(
        Uri.parse('${APICredentials.xeroApiBaseUrl}/Invoices'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'xero-tenant-id': tenantId,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(invoicesData),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        results.add(json.decode(response.body));
      } else if (response.statusCode == 401) {
        // Token expired, try refreshing
        await refreshAccessToken();
        // Retry the request
        return createExpenseBills(receipts);
      } else {
        throw Exception('Failed to create expense bills: ${response.body}');
      }
    }
    
    return {'batches': results};
  }
  
  /// Validate receipts against Xero requirements
  Future<ValidationResult> validateReceipts(List<Receipt> receipts) async {
    final errors = <String>[];
    final warnings = <String>[];
    
    try {
      // Check authentication
      final accessToken = await APICredentials.getXeroAccessToken();
      if (accessToken == null) {
        errors.add('Not authenticated with Xero. Please connect your account.');
        return ValidationResult(isValid: false, errors: errors, warnings: warnings);
      }
      
      // Check batch size limit
      if (receipts.length > 50) {
        warnings.add('Xero allows max 50 invoices per batch. Will process in multiple batches.');
      }
      
      // Validate each receipt
      for (var i = 0; i < receipts.length; i++) {
        final receipt = receipts[i];
        
        // Check required fields
        if (receipt.merchantName == null || receipt.merchantName!.isEmpty) {
          errors.add('Receipt ${i + 1}: Missing merchant name (Contact required)');
        }
        
        if (receipt.date == null) {
          errors.add('Receipt ${i + 1}: Missing date');
        }
        
        if (receipt.totalAmount == null || receipt.totalAmount! <= 0) {
          errors.add('Receipt ${i + 1}: Invalid total amount');
        }
        
        // Xero specific validations
        if (receipt.date != null) {
          // Xero doesn't accept dates too far in the past
          final oldestAllowedDate = DateTime.now().subtract(const Duration(days: 365 * 7));
          if (receipt.date!.isBefore(oldestAllowedDate)) {
            errors.add('Receipt ${i + 1}: Date is more than 7 years old (Xero limit)');
          }
          
          // Future dates warning
          if (receipt.date!.isAfter(DateTime.now())) {
            warnings.add('Receipt ${i + 1}: Future dated transaction');
          }
        }
        
        // Check for merchant name length (Xero limit is 500 chars for contact name)
        if (receipt.merchantName != null && receipt.merchantName!.length > 500) {
          errors.add('Receipt ${i + 1}: Merchant name exceeds 500 characters');
        }
        
        // Check for duplicate transactions
        final duplicates = receipts.where((r) => 
          r != receipt &&
          r.merchantName == receipt.merchantName &&
          r.totalAmount == receipt.totalAmount &&
          r.date?.day == receipt.date?.day &&
          r.date?.month == receipt.date?.month &&
          r.date?.year == receipt.date?.year
        );
        
        if (duplicates.isNotEmpty) {
          warnings.add('Receipt ${i + 1}: Possible duplicate transaction');
        }
        
        // Validate tax amount
        if (receipt.taxAmount != null && receipt.taxAmount! > receipt.totalAmount!) {
          errors.add('Receipt ${i + 1}: Tax amount exceeds total amount');
        }
      }
      
      // Test connection with API
      try {
        final tenantId = await APICredentials.getXeroTenantId();
        if (tenantId != null) {
          final testResponse = await http.get(
            Uri.parse('${APICredentials.xeroApiBaseUrl}/Organisation'),
            headers: {
              'Authorization': 'Bearer $accessToken',
              'xero-tenant-id': tenantId,
              'Accept': 'application/json',
            },
          );
          
          if (testResponse.statusCode == 401) {
            await refreshAccessToken();
          } else if (testResponse.statusCode != 200) {
            warnings.add('Xero API connection test failed. Some validations may be incomplete.');
          }
        }
      } catch (e) {
        warnings.add('Could not verify Xero connection: ${e.toString()}');
      }
      
      // Check API rate limits
      warnings.add('Note: Xero API has a limit of 5,000 calls per day');
      
    } catch (e) {
      errors.add('Validation error: ${e.toString()}');
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
  
  /// Convert Receipt to Xero Invoice format (Type=ACCPAY for bills)
  Map<String, dynamic> _convertReceiptToInvoice(Receipt receipt) {
    final lineAmount = receipt.totalAmount ?? 0.0;
    final taxAmount = receipt.taxAmount ?? 0.0;
    final subtotal = lineAmount - taxAmount;
    
    return {
      'Type': 'ACCPAY', // Accounts Payable (Bill)
      'Contact': {
        'Name': receipt.merchantName ?? 'Unknown Vendor',
      },
      'Date': receipt.date?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0],
      'DueDate': receipt.date?.add(const Duration(days: 30)).toIso8601String().split('T')[0] ?? 
                 DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T')[0],
      'LineAmountTypes': 'Inclusive', // Total includes tax
      'Status': 'DRAFT', // Create as draft for review
      'Reference': 'Receipt Organizer Import - ${receipt.id}',
      'LineItems': [
        {
          'Description': 'Expense from ${receipt.merchantName ?? "Unknown"}',
          'Quantity': 1,
          'UnitAmount': lineAmount,
          'AccountCode': '400', // Default expense account - should be configurable
          'TaxType': taxAmount > 0 ? 'OUTPUT' : 'NONE',
          'TaxAmount': taxAmount,
        }
      ],
    };
  }
  
  /// Check if authenticated
  Future<bool> isAuthenticated() async {
    final auth = await _secureStorage.read(key: 'xero_authenticated');
    return auth == 'true';
  }
  
  /// Clear authentication
  Future<void> logout() async {
    await _secureStorage.delete(key: 'xero_session_id');
    await _secureStorage.delete(key: 'xero_session_token');
    await _secureStorage.delete(key: 'xero_authenticated');
  }
}