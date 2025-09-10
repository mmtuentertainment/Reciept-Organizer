import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import '../config/environment.dart';

/// Service for monitoring network connectivity
/// 
/// EXPERIMENT: Phase 2 - Minimal offline detection
/// This service provides:
/// 1. Real-time connectivity monitoring
/// 2. API endpoint reachability checks
/// 3. Offline state management
class NetworkConnectivityService {
  static final NetworkConnectivityService _instance = NetworkConnectivityService._internal();
  factory NetworkConnectivityService() => _instance;
  NetworkConnectivityService._internal();
  
  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  
  // Current connectivity state
  bool _isConnected = true;
  bool _isApiReachable = true;
  
  // Stream controller for connectivity changes
  final _connectivityController = StreamController<bool>.broadcast();
  
  // Public getters
  bool get isConnected => _isConnected;
  bool get isApiReachable => _isApiReachable;
  Stream<bool> get connectivityStream => _connectivityController.stream;
  
  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    await checkConnectivity();
    
    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _handleConnectivityChange(results);
    });
  }
  
  /// Clean up resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
  
  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _handleConnectivityChange(results);
      return _isConnected;
    } catch (e) {
      // If we can't check connectivity, assume we're offline
      _updateConnectivityState(false);
      return false;
    }
  }
  
  /// Check if API endpoint is reachable
  /// Uses a lightweight endpoint that should always be available
  Future<bool> checkApiReachability() async {
    if (!_isConnected) {
      _isApiReachable = false;
      return false;
    }
    
    try {
      // Import Environment to get the API URL
      final apiUrl = _getApiUrl();
      
      // Try a simple HEAD request to the API
      // This is lightweight and doesn't transfer data
      final response = await http.head(
        Uri.parse('$apiUrl/health'),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          // Timeout - API not reachable
          return http.Response('', 408); // Request Timeout
        },
      );
      
      // Consider API reachable if we get any response
      // (even error responses mean the server is up)
      _isApiReachable = response.statusCode < 500;
      return _isApiReachable;
    } catch (e) {
      _isApiReachable = false;
      return false;
    }
  }
  
  /// Handle connectivity changes
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    // We're connected if we have any type of connection
    final hasConnection = results.isNotEmpty && 
                         !results.contains(ConnectivityResult.none);
    
    _updateConnectivityState(hasConnection);
    
    // If we have connection, check API reachability
    if (hasConnection) {
      checkApiReachability();
    } else {
      _isApiReachable = false;
    }
  }
  
  /// Update connectivity state and notify listeners
  void _updateConnectivityState(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      _connectivityController.add(isConnected);
    }
  }
  
  /// Get API URL from Environment
  String _getApiUrl() {
    return Environment.apiUrl;
  }
  
  /// Check if we should attempt an API call
  /// This is the main method services should use
  bool canMakeApiCall() {
    return _isConnected && _isApiReachable;
  }
  
  /// Force a connectivity and reachability check
  /// Useful after network errors or before critical operations
  Future<bool> forceCheck() async {
    await checkConnectivity();
    if (_isConnected) {
      await checkApiReachability();
    }
    return canMakeApiCall();
  }
}