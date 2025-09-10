import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/models/receipt.dart';
import '../../../core/config/environment.dart';
import '../../../core/services/network_connectivity_service.dart';
import '../../../core/services/request_queue_service.dart';
import '../../../core/services/background_sync_service.dart';

/// Service for interacting with QuickBooks API via Vercel proxy
class QuickBooksAPIService {
  static final QuickBooksAPIService _instance = QuickBooksAPIService._internal();
  factory QuickBooksAPIService() => _instance;
  QuickBooksAPIService._internal();
  
  // EXPERIMENT: Using Environment configuration instead of hardcoded URL
  static String get _baseUrl => Environment.apiUrl;
  final _secureStorage = const FlutterSecureStorage();
  String? _sessionId;
  String? _sessionToken;
  
  /// Generate OAuth 2.0 authorization URL via Vercel proxy
  Future<String> getAuthorizationUrl() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/auth/quickbooks'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _sessionId = data['sessionId'];
        _sessionToken = data['sessionToken'];
        
        // Store session info for later
        await _secureStorage.write(key: 'qb_session_id', value: _sessionId);
        await _secureStorage.write(key: 'qb_session_token', value: _sessionToken);
        
        return data['authUrl'];
      } else {
        throw Exception('Failed to get authorization URL: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to auth service: $e');
    }
  }
  
  /// Handle OAuth callback via Vercel proxy
  Future<Map<String, dynamic>> handleCallback(String code, String state, String? realmId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/quickbooks/callback'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'code': code,
        'state': state,
        'realmId': realmId,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Store authentication status
      await _secureStorage.write(key: 'qb_authenticated', value: 'true');
      if (data['sessionToken'] != null) {
        await _secureStorage.write(key: 'qb_session_token', value: data['sessionToken']);
      }
      
      return data;
    } else {
      throw Exception('Failed to handle callback: ${response.body}');
    }
  }
  
  /// Refresh access token via Vercel proxy
  Future<void> refreshAccessToken() async {
    final sessionToken = await _secureStorage.read(key: 'qb_session_token');
    if (sessionToken == null) {
      throw Exception('No session token available');
    }
    
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/quickbooks/refresh'),
      headers: {
        'Authorization': 'Bearer $sessionToken',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Token refreshed server-side
    } else {
      throw Exception('Failed to refresh token: ${response.body}');
    }
  }
  
  /// Create a purchase (expense) in QuickBooks via proxy
  Future<Map<String, dynamic>> createPurchase(Receipt receipt) async {
    final sessionToken = await _secureStorage.read(key: 'qb_session_token');
    if (sessionToken == null) {
      throw Exception('Not authenticated with QuickBooks');
    }
    
    // This would be implemented on the Vercel side
    throw UnimplementedError('Purchase creation should be implemented via Vercel proxy');
  }
  
  /// Validate receipts via Vercel proxy
  Future<ValidationResult> validateReceipts(List<Receipt> receipts) async {
    // EXPERIMENT: Phase 3.4 - Test queue mechanism with single endpoint
    final connectivity = NetworkConnectivityService();
    final queueService = RequestQueueService();
    
    // Check if we can make API calls
    if (!connectivity.canMakeApiCall()) {
      // Queue the validation request for later
      final sessionToken = await _secureStorage.read(key: 'qb_session_token');
      
      final requestBody = {
        'receipts': receipts.map((r) => {
          'merchantName': r.merchantName,
          'date': r.date?.toIso8601String(),
          'totalAmount': r.totalAmount,
          'taxAmount': r.taxAmount,
        }).toList(),
      };
      
      final queueId = await queueService.queueRequest(
        endpoint: '$_baseUrl/api/quickbooks/validate',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': sessionToken != null ? 'Bearer $sessionToken' : '',
        },
        body: requestBody,
        feature: 'quickbooks_validation',
      );
      
      // EXPERIMENT: Phase 4 - Trigger background sync for faster processing
      final backgroundSync = BackgroundSyncService();
      if (backgroundSync.isBackgroundSyncAvailable()) {
        // Schedule a one-time sync in 1 minute
        await backgroundSync.registerOneTimeSync(
          delay: const Duration(minutes: 1),
        );
      }
      
      // Return offline validation result with queue information
      return ValidationResult(
        isValid: false,
        errors: ['Validation queued for processing when online.'],
        warnings: ['Request ID: $queueId. Will retry automatically when connection is restored.'],
      );
    }
    
    final sessionToken = await _secureStorage.read(key: 'qb_session_token');
    
    final response = await http.post(
      Uri.parse('$_baseUrl/api/quickbooks/validate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': sessionToken != null ? 'Bearer $sessionToken' : '',
      },
      body: json.encode({
        'receipts': receipts.map((r) => {
          'merchantName': r.merchantName,
          'date': r.date?.toIso8601String(),
          'totalAmount': r.totalAmount,
          'taxAmount': r.taxAmount,
        }).toList(),
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Convert API response to ValidationResult
      final errors = (data['errors'] as List? ?? [])
          .map((e) => e['message'] as String)
          .toList();
      final warnings = (data['warnings'] as List? ?? [])
          .map((w) => w['message'] as String)
          .toList();
      
      return ValidationResult(
        isValid: data['isValid'] ?? false,
        errors: errors,
        warnings: warnings,
      );
    } else {
      throw Exception('Validation failed: ${response.body}');
    }
  }
  
  /// Check if authenticated
  Future<bool> isAuthenticated() async {
    final auth = await _secureStorage.read(key: 'qb_authenticated');
    return auth == 'true';
  }
  
  /// Clear authentication
  Future<void> logout() async {
    await _secureStorage.delete(key: 'qb_session_id');
    await _secureStorage.delete(key: 'qb_session_token');
    await _secureStorage.delete(key: 'qb_authenticated');
  }
}

/// Result of validation
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  
  ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });
}