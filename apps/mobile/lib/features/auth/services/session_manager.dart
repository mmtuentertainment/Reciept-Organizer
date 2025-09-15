import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../infrastructure/config/supabase_config.dart';
import 'auth_service.dart';

class SessionManager {
  static Timer? _refreshTimer;
  static bool _isInitialized = false;

  /// Initialize session management
  static void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    // Start session refresh timer
    _startRefreshTimer();

    // Listen to auth state changes
    AuthService.authStateChanges.listen((authState) {
      if (authState.event == AuthChangeEvent.signedIn) {
        _startRefreshTimer();
        debugPrint('🔐 User signed in, starting session refresh timer');
      } else if (authState.event == AuthChangeEvent.signedOut) {
        _stopRefreshTimer();
        debugPrint('🔓 User signed out, stopping session refresh timer');
      } else if (authState.event == AuthChangeEvent.tokenRefreshed) {
        debugPrint('🔄 Session token refreshed');
      } else if (authState.event == AuthChangeEvent.userUpdated) {
        debugPrint('👤 User profile updated');
      }
    });

    // Handle app lifecycle changes
    WidgetsBinding.instance.addObserver(_AppLifecycleObserver());
  }

  /// Start the refresh timer
  static void _startRefreshTimer() {
    _stopRefreshTimer();

    // Check session every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      AuthService.checkAndRefreshSession();
    });
  }

  /// Stop the refresh timer
  static void _stopRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Manually refresh session
  static Future<bool> refreshSession() async {
    try {
      await AuthService.refreshSession();
      return true;
    } catch (e) {
      debugPrint('❌ Failed to refresh session: $e');
      return false;
    }
  }

  /// Check if session is valid
  static bool isSessionValid() {
    final session = AuthService.currentSession;
    if (session == null) return false;

    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return expiresAt > now;
  }

  /// Get time until session expires
  static Duration? getTimeUntilExpiry() {
    final session = AuthService.currentSession;
    if (session == null) return null;

    final expiresAt = session.expiresAt;
    if (expiresAt == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final secondsUntilExpiry = expiresAt - now;

    return Duration(seconds: secondsUntilExpiry.clamp(0, double.infinity).toInt());
  }

  /// Handle deep links for OAuth callbacks
  static Future<bool> handleDeepLink(Uri uri) async {
    try {
      // Check if this is an auth callback
      if (uri.path == '/login-callback' || uri.path == '/reset-password') {
        await AuthService.setSessionFromUrl(uri);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Failed to handle deep link: $e');
      return false;
    }
  }

  /// Clean up resources
  static void dispose() {
    _stopRefreshTimer();
    _isInitialized = false;
  }
}

/// Observer for app lifecycle changes
class _AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground - check session
        debugPrint('📱 App resumed - checking session');
        AuthService.checkAndRefreshSession();
        SessionManager._startRefreshTimer();
        break;
      case AppLifecycleState.paused:
        // App went to background - stop timer
        debugPrint('📱 App paused - stopping refresh timer');
        SessionManager._stopRefreshTimer();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // No action needed
        break;
    }
  }
}