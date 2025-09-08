import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receipt_organizer/features/capture/providers/capture_provider.dart';

/// Provider that handles initialization of other providers
/// This ensures initialization happens after the provider tree is built
final providerInitializerProvider = Provider<ProviderInitializer>((ref) {
  return ProviderInitializer(ref);
});

/// Service that initializes providers that need setup after creation
class ProviderInitializer {
  final Ref ref;
  bool _initialized = false;
  
  ProviderInitializer(this.ref);
  
  /// Initialize all providers that need post-creation setup
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Initialize capture provider
      final captureNotifier = ref.read(captureProvider.notifier);
      await captureNotifier.initialize();
      
      _initialized = true;
    } catch (e) {
      // Log but don't throw - allow app to continue
      debugPrint('Provider initialization warning: $e');
    }
  }
  
  /// Check if initialization has completed
  bool get isInitialized => _initialized;
}

/// FutureProvider that ensures all providers are initialized
final appInitializationProvider = FutureProvider<void>((ref) async {
  final initializer = ref.read(providerInitializerProvider);
  await initializer.initialize();
});