import 'package:flutter/foundation.dart';

/// Authentication provider stub
abstract class AuthProvider extends ChangeNotifier {
  bool get isAuthenticated;
  String? get currentUserId;
  String? get userEmail;

  Future<void> signIn(String email, String password);
  Future<void> signOut();
  Future<void> signUp(String email, String password);
  Future<bool> checkAuthStatus();
}