import '../models/auth_session.dart';
import 'api_client.dart';

class AuthService {
  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AuthSession> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login/',
      body: {
        'identifier': identifier.trim(),
        'password': password,
      },
    );
    return AuthSession.fromJson(response);
  }

  Future<AuthSession> me(AuthSession session) async {
    final response = await _apiClient.get(
      '/auth/me/',
      headers: {'Authorization': 'Bearer ${session.accessToken}'},
    );

    return AuthSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      userId: response['id']?.toString() ?? session.userId,
      role: response['role'] as String? ?? session.role,
      displayName: response['display_name'] as String? ?? session.displayName,
    );
  }

  Future<AuthSession> refresh(String refreshToken) async {
    final response = await _apiClient.post(
      '/auth/refresh/',
      body: {'refresh': refreshToken},
    );
    return AuthSession(
      accessToken: response['access'] as String? ?? '',
      refreshToken: response['refresh'] as String? ?? refreshToken,
      userId: response['user_id']?.toString() ?? '',
      role: response['role'] as String? ?? '',
      displayName: response['display_name'] as String? ?? '',
    );
  }

  Future<void> logout(AuthSession session) async {
    await _apiClient.post(
      '/auth/logout/',
      body: {'refresh': session.refreshToken},
      headers: {'Authorization': 'Bearer ${session.accessToken}'},
    );
  }

  void dispose() => _apiClient.dispose();
}