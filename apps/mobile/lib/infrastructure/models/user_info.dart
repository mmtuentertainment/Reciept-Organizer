/// User information model for infrastructure layer
class UserInfo {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime lastSignInAt;
  final Map<String, dynamic> metadata;
  
  UserInfo({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
    this.isAnonymous = false,
    required this.createdAt,
    required this.lastSignInAt,
    this.metadata = const {},
  });
}