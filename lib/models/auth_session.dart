class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.role,
    required this.displayName,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
  final String role;
  final String displayName;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['access'] as String? ?? '',
      refreshToken: json['refresh'] as String? ?? '',
      userId: json['user_id']?.toString() ?? '',
      role: json['role'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
    );
  }

  factory AuthSession.fromStoredJson(Map<String, dynamic> json) => AuthSession(
    accessToken: json['accessToken'] as String? ?? '',
    refreshToken: json['refreshToken'] as String? ?? '',
    userId: json['userId'] as String? ?? '',
    role: json['role'] as String? ?? '',
    displayName: json['displayName'] as String? ?? '',
  );

  Map<String, dynamic> toStoredJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'userId': userId,
    'role': role,
    'displayName': displayName,
  };
}