import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:receipt_organizer/features/auth/providers/auth_provider.dart';
import 'package:receipt_organizer/features/auth/screens/login_screen.dart';

/// Widget that guards routes requiring authentication
class AuthGuard extends ConsumerWidget {
  final Widget child;
  final bool allowOffline;
  
  const AuthGuard({
    super.key,
    required this.child,
    this.allowOffline = false,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    // Show loading while checking auth state
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // If authenticated, show the child widget
    if (authState.isAuthenticated) {
      return child;
    }
    
    // If offline mode is allowed and no auth, show child
    if (allowOffline && !authState.isAuthenticated) {
      return child;
    }
    
    // Otherwise, show login screen
    return const LoginScreen();
  }
}

/// Widget to show different content based on auth state
class AuthBuilder extends ConsumerWidget {
  final Widget Function(BuildContext context, User user) authenticated;
  final Widget Function(BuildContext context) unauthenticated;
  final Widget Function(BuildContext context)? loading;
  
  const AuthBuilder({
    super.key,
    required this.authenticated,
    required this.unauthenticated,
    this.loading,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    if (authState.isLoading) {
      return loading ?? 
        const Center(
          child: CircularProgressIndicator(),
        );
    }
    
    if (authState.isAuthenticated && authState.user != null) {
      return authenticated(context, authState.user!);
    }
    
    return unauthenticated(context);
  }
}