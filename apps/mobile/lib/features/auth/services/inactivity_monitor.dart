import 'dart:async';
import 'package:flutter/widgets.dart';

/// Service to monitor user inactivity and trigger timeout actions
class InactivityMonitor extends WidgetsBindingObserver {
  Timer? _timer;
  final Duration timeout;
  final VoidCallback onTimeout;
  DateTime? _lastActivity;
  bool _isActive = true;

  InactivityMonitor({
    required this.timeout,
    required this.onTimeout,
  }) {
    // Start monitoring app lifecycle
    WidgetsBinding.instance.addObserver(this);
    startTimer();
  }

  /// Start or restart the inactivity timer
  void startTimer() {
    _timer?.cancel();
    _lastActivity = DateTime.now();
    _isActive = true;

    _timer = Timer(timeout, () {
      if (_isActive) {
        _isActive = false;
        onTimeout();
      }
    });
  }

  /// Reset the timer on user activity
  void resetTimer() {
    if (_isActive) {
      startTimer();
    }
  }

  /// Stop the timer
  void stopTimer() {
    _timer?.cancel();
    _isActive = false;
  }

  /// Resume monitoring after being paused
  void resume() {
    if (!_isActive) {
      _isActive = true;
      startTimer();
    }
  }

  /// Get time since last activity
  Duration? get timeSinceLastActivity {
    if (_lastActivity == null) return null;
    return DateTime.now().difference(_lastActivity!);
  }

  /// Check if currently monitoring
  bool get isActive => _isActive;

  /// Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App is visible and responding to user input
        if (_lastActivity != null) {
          final inactiveTime = DateTime.now().difference(_lastActivity!);
          if (inactiveTime >= timeout) {
            // User was away too long, trigger timeout
            _isActive = false;
            onTimeout();
          } else {
            // Resume monitoring
            resume();
          }
        } else {
          resume();
        }
        break;

      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App is not visible or responding to user input
        // Record the time when app went to background
        _lastActivity = DateTime.now();
        stopTimer();
        break;

      case AppLifecycleState.detached:
        // App is still hosted but detached from any host views
        stopTimer();
        break;

      case AppLifecycleState.hidden:
        // App is hidden (iOS 14+ and Android 10+)
        _lastActivity = DateTime.now();
        stopTimer();
        break;
    }
  }

  /// Clean up resources
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
  }
}

/// Widget that wraps content and monitors for user interaction
class InactivityWrapper extends StatefulWidget {
  final Widget child;
  final Duration timeout;
  final VoidCallback onTimeout;
  final bool enabled;

  const InactivityWrapper({
    Key? key,
    required this.child,
    required this.timeout,
    required this.onTimeout,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<InactivityWrapper> createState() => _InactivityWrapperState();
}

class _InactivityWrapperState extends State<InactivityWrapper> {
  late InactivityMonitor _monitor;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _monitor = InactivityMonitor(
        timeout: widget.timeout,
        onTimeout: widget.onTimeout,
      );
    }
  }

  @override
  void didUpdateWidget(InactivityWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _monitor = InactivityMonitor(
          timeout: widget.timeout,
          onTimeout: widget.onTimeout,
        );
      } else {
        _monitor.dispose();
      }
    }
  }

  @override
  void dispose() {
    if (widget.enabled) {
      _monitor.dispose();
    }
    super.dispose();
  }

  void _handleUserInteraction() {
    if (widget.enabled) {
      _monitor.resetTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _handleUserInteraction,
      onPanDown: (_) => _handleUserInteraction(),
      onScaleStart: (_) => _handleUserInteraction(),
      child: MouseRegion(
        onHover: (_) => _handleUserInteraction(),
        child: widget.child,
      ),
    );
  }
}