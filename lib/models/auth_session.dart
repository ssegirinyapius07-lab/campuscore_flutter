class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.userId,
    required this.role,
    required this.displayName,
  });

  final String accessToken;
  final String userId;
  final String role;
  final String displayName;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['access'] as String? ?? '',
      userId: json['user_id'].toString(),
      role: json['role'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
    );
  }
}
